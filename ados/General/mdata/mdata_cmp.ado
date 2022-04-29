*! version 0.1 2Aug2021
* Programmed by Gustavo Iglésias
* Dependencies: gtools

program define mdata_cmp, rclass
/*
Compares metadata for two Stata data sets. The metadata must
be stored in an Excel file. This can be achieved using the
command mdata extract
*/

syntax, NEWfile(string) OLDfile(string) [export(string)]

version 16

if trim("`export'") == "" {
	local export "metacmp.xlsx"
	cap confirm file "`export'"
	if !_rc {
		di as error `"File "`export'" already exists. Please specify "' ///
		`"option "export" to save the file under a different name"'
		exit 602
	}
}
else {
	gettoken export replaceexp: export, p(",")
	local export = trim("`export'")
	local export "`export'.xlsx"
	gettoken lixo replaceexp: replaceexp, p(",")
	cap confirm file "`export'"
	if !_rc & trim("`replaceexp'") != "replace" {
		di as error `"File "`export'" already exists. Please specify"' ///
		`"sub-option "replace" to overwrite the existing file"'
		exit 602
	}
	else {
		cap rm "`export'"
	}
}

cap drop macro MAINSHEET CELLNUM

global MAINSHEET "Summary"
global CELLNUM = 5

cap putexcel save

qui putexcel set "`export'", open modify sheet("${MAINSHEET}")
qui putexcel A1 = "Old File", bold
qui putexcel A2 = "New File", bold
qui putexcel A4 = "Sheet", bold
qui putexcel B4 = "Inconsistencies found", bold
qui putexcel B1 = "`oldfile'.xlsx"
qui putexcel B2 = "`newfile'.xlsx"
qui putexcel save
 

compare_vars, new(`newfile'.xlsx) old(`oldfile'.xlsx) export(`export')

compare_sheets, new(`newfile'.xlsx) old(`oldfile'.xlsx) export(`export')

if ${CELLNUM} == 5 {
    di
	di as text "No inconsitencies found. File " as result ///
	"`export'" as text " will not be saved"
	cap rm "`export'"
}
else {
    tempname frinc
	frame create `frinc'
	frame `frinc' {
	    qui import excel using "`export'", sheet("Summary") clear 
		keep A B
		rename (A B) (worksheet inconsistencies)
		qui drop if _n < 5
		di 
		li, noobs ab(20) div sep(1000) 
	}
	frame drop `frinc'
	di 
	di as text "File " as result "`export'" as text " saved"   
}

return local inconsistencies = ${CELLNUM} - 5

end


program define put_summary

syntax, file(string) value(string) [num(int 0)]

qui putexcel set "`file'", open modify sheet("${MAINSHEET}")
qui putexcel A${CELLNUM} = "`value'"
qui putexcel B${CELLNUM} = `num'
qui putexcel save

end 


program define compare_vars
/*
Compares the worksheet "variables" found in both excel files:
	- compares if there are unmatched variables - first section;
	- compares if variables' features are the same (labels, chars, etc)- second section
	- compares the contents of variables' features - third section
*/

syntax, old(string) new(string) export(string)

* We use frames as an alternative to preserve / restore
tempname frameold framenew
tempfile temp
frame create `frameold'
frame create `framenew'
* Read worksheets
frame `frameold' {
    qui import excel using "`old'", sheet("variables") first clear
	* rename variables to compare them after the merge
	rename_vars, prefix(_old_)
}
frame `framenew' {
    qui import excel using "`new'", sheet("variables") first clear
	* rename variables to compare them after the merge
	rename_vars, prefix(_new_)
	qui save "`temp'", replace
}
* Compare worksheets
frame `frameold' {
	* First section
	qui merge 1:1 variable using `temp'
	qui count if _m != 3
	local var_count = `r(N)'
	if `r(N)' {
		put_summary, file("`export'") value(Variables) num(`r(N)')
		global CELLNUM = ${CELLNUM} + 1
		qui gen desc = "old" if _m == 1
		qui replace desc = "new" if _m == 2
		qui export excel variable desc using "`export'" if _m != 3, ///
			sheet("Variables", modify) first(var)
	}
	qui keep if _m == 3
	drop _m 
	* Second section 
	compare_columns
	if `r(col_inc)' {
		qui putexcel set "`export'", open modify sheet("Variables' Features")
		putexcel A1 = "feature"
		putexcel B1 = "desc" 
		local cell_num = 2
		foreach col in `r(cols_master)' {
			putexcel A`cell_num' = "`col'"
			putexcel B`cell_num' =  "old"
			local cell_num = `cell_num' + 1
		}
		foreach col in `r(cols_using)' {
			putexcel A`cell_num' = "`col'"
			putexcel B`cell_num' = "new"
			local cell_num = `cell_num' + 1
		}
		qui putexcel save
		local inc = `cell_num' - 2
		put_summary, file("`export'") value(Variables' Features) num(`inc')
		global CELLNUM = ${CELLNUM} + 1
		
	}
	* Third section
	tempvar temp
	foreach var in `r(matched)' {
	    qui gen `temp' =  (_new_`var' == _old_`var')
		qui count if `temp' == 0
		if `r(N)' {
			put_summary, file("`export'") value(Variables' `var') num(`r(N)')
			global CELLNUM = ${CELLNUM} + 1
			qui export excel variable _new_`var' _old_`var' using "`export'" if `temp' == 0, ///
				sheet("Variables' `var'", modify) first(var) 
		}
		else {
			* index code
		}
		drop `temp'
	}
}

frame drop `frameold'
frame drop `framenew'

end


program define rename_vars
/*
renames variables from <var_name> to <prefixvar_name>,
excluding the variable named variable
*/

syntax, prefix(string)

	qui ds 
	local vars "`r(varlist)'"
	local id "variable"
	local rem_vars: list vars - id
	foreach var in `rem_vars' {
	    rename `var' `prefix'`var'
	}

end


program define compare_columns, rclass
/*
Compares variables features in the "variables" worksheet
Returned locals:
	matched - matched features
	cols_master - features only in old file 
	cols_using - features only in new file
*/

tempvar column
tempfile temp
tempname frold frnew
frame create `frold' 
frame create `frnew'

qui ds
local vars "`r(varlist)'"
local var "variable"
local rem_vars: list vars - var 
foreach var in `rem_vars' {
    if strpos("`var'", "_old_") local vars_old = "`vars_old'" + " `var'"
	if strpos("`var'", "_new_") local vars_new = "`vars_new'" + " `var'"
}
* Convert locals to columns
frame `frold': local_to_column, local(`vars_old') var(`column') first(6)
frame `frnew' {
    local_to_column, local(`vars_new') var(`column') first(6)
	qui save `temp', replace
}
* Compare columns (each column contains variables' features)
frame `frold' {
    qui merge 1:1 `column' using `temp'
	qui count if _m != 3
	local col_inc = r(N)
	qui glevelsof `column' if _m == 3, local(matched)
	qui glevelsof `column' if _m == 1, local(cols_master)
	qui glevelsof `column' if _m == 2, local(cols_using)
}
* Return locals
return local col_inc = `col_inc'
return local matched = `"`matched'"'
return local cols_master = `"`cols_master'"'
return local cols_using = `"`cols_using'"'

frame drop `frnew'
frame drop `frold'


end


program define compare_sheets
/*
Compare worksheets found in both excel files. Worksheets have information
on variables' characteristics, value labels and notes. 
First we check if the worksheets are the same in both files.
For worksheets found in both files we compare their content.
*/
syntax, old(string) new(string) export(string)

tempname frameold framenew
tempvar sheet
tempfile temp
frame create `frameold'
frame create `framenew'
* Read worksheets and save them in a local
frame `frameold' {
    qui import excel using "`old'", describe
	forvalues i=1/`r(N_worksheet)' {
	    local old_sheets = "`old_sheets'" + " `r(worksheet_`i')'"
	}
	local_to_column, local(`old_sheets') var(`sheet') 
}

frame `framenew' {
    qui import excel using "`new'", describe
	forvalues i=1/`r(N_worksheet)' {
	    local new_sheets = "`new_sheets'" + " `r(worksheet_`i')'"
	}
	local_to_column, local(`new_sheets') var(`sheet') 
	qui save "`temp'", replace
}
* Compare worksheets
frame `frameold' {
	qui merge 1:1 `sheet' using `temp'
	qui count if _m != 3
	if `r(N)' {
		put_summary, file("`export'") value(Sheets) num(`r(N)')
		global CELLNUM = ${CELLNUM} + 1
	    qui gen desc = "old" if _m == 1
		replace desc = "new" if _m == 2
		rename `sheet' sheet 
		qui export excel sheet desc using "`export'" if _m != 3, ///
			sheet("Sheets", modify) first(var)
		drop desc
		rename sheet `sheet'
	}
	qui keep if _m == 3
	drop _m  
	* Compares worksheets' contents
	qui glevelsof `sheet', local(sheets)
	foreach wsheet in `sheets' {
		* Compare value labels
	    if substr("`wsheet'", 1, 2) == "vl" {
		    compare_vl, sheet(`wsheet') old(`old') new(`new') export(`export')
		} 
		* Compares characteristics
	    else if substr("`wsheet'", 1, 4) == "char" {
		    compare_char, sheet(`wsheet') old(`old') new(`new') export(`export')
		}
		* Compare notes
	    else if substr("`wsheet'", 1, 5) == "notes" {
		    compare_notes, sheet(`wsheet') old(`old') new(`new') export(`export')
		}
		else {
			continue
		}
	}
}
	
frame drop `frameold'
frame drop `framenew'

end


program define compare_vl
/*
Compare value labels between files. Value labels are stored in a worksheet. 
We first compare values to check if there are unmatched values. For matched values
we also compare their labels. If any inconsistency is found, a worksheet named 
vl_valname (where valname is the value label name) is created displaying all 
inconsistencies
*/

syntax, sheet(string) old(string) new(string) export(string)

tempvar equal_label
tempfile temp
tempname frameold framenew
frame create `frameold'
frame create `framenew'
* Read value labels worksheets
frame `frameold' {
    qui import excel using "`old'", sheet(`sheet')  first
	rename label label_old
}
frame `framenew' {
    qui import excel using "`new'", sheet(`sheet')  first
	rename label label_new
	qui save "`temp'", replace
}

frame `frameold' {
    local incon = 0
	* Compare values
	qui merge 1:1 value using `temp'
	qui count if _m != 3
	if `r(N)' {
	    qui gen desc = "old" if _m == 1
		qui replace desc = "new" if _m == 2
		local incon = `incon' + `r(N)'
	}
	* Compare labels
	qui gen `equal_label' = (label_new == label_old)
	qui count if _m == 3 & `equal_label' == 0
	if `r(N)' {
		if `incon' {
			qui replace desc = "different label" if _m == 3 & `equal_label' == 0
		}
		else {
			qui gen desc = "different label" if _m == 3 & `equal_label' == 0
		}
		local incon = `incon' + `r(N)'
	}
	if `incon' {
		put_summary, file("`export'") value(`sheet') num(`incon')
		global CELLNUM = ${CELLNUM} + 1
	    qui export excel value desc label_old label_new ///
			using "`export'" if (_m != 3) | (_m == 3 & `equal_label' == 0) , ///
			sheet("`sheet'", modify) first(var)
	}
	
}
	
frame drop `frameold'
frame drop `framenew'

end


program define compare_char
/*
Compare characteristics between files. Variables' characteristics are stored in a worksheet. 
We first check if there are unmatched chars. For matched chars
we also compare their values. If any inconsistency is found, a worksheet named
char_varname (where variable is the name of the variable) is created displaying 
all inconsistencies
*/
syntax, sheet(string) old(string) new(string) export(string)

tempvar equal_value
tempfile temp
tempname frameold framenew
frame create `frameold'
frame create `framenew'
* Read chars worksheets
frame `frameold' {
    qui import excel using "`old'", sheet(`sheet') first
	* Remove Stata default chars 
	qui drop if substr(char, 1, 1) == "_" | ///
		substr(char, 1, length("datasignature")) == "datasignature" | ///
		substr(char, 1, length("destring")) == "destring" | ///
		substr(char, 1, length("tostring")) == "tostring" | ///
		substr(char, 1, 4) == "note"
	rename value value_old
}
frame `framenew' {
    qui import excel using "`new'", sheet(`sheet') first
	* Remove Stata default chars 
	qui drop if substr(char, 1, 1) == "_" | ///
		substr(char, 1, length("datasignature")) == "datasignature" | ///
		substr(char, 1, length("destring")) == "destring" | ///
		substr(char, 1, length("tostring")) == "tostring" | ///
		substr(char, 1, 4) == "note"
	rename value value_new
	qui save "`temp'", replace
}

frame `frameold' {
    local incon = 0
	* Compare chars
	qui merge 1:1 char using `temp'
	qui count if _m != 3
	if `r(N)' {
	    qui gen desc = "old" if _m == 1
		qui replace desc = "new" if _m == 2
		local incon = `incon' + `r(N)'
	}
	* Compare chars' values
	qui gen `equal_value' = (value_new == value_old)
	qui count if _m == 3 & `equal_value' == 0
	if `r(N)' {
		if `incon' {
			qui replace desc = "different value" if _m == 3 & `equal_value' == 0
		}
		else {
			qui gen desc = "different value" if _m == 3 & `equal_value' == 0
		}
		local incon = `incon' + `r(N)'
	}
	if `incon' {
		put_summary, file("`export'") value(`sheet') num(`incon')
		global CELLNUM = ${CELLNUM} + 1
	    qui export excel char desc value_old value_new ///
			using "`export'" if (_m != 3) | (_m == 3 & `equal_value' == 0) , ///
			sheet("`sheet'", modify) first(var)
	}
}
	
frame drop `frameold'
frame drop `framenew'

end


program define compare_notes
/*
Compare characteristics between files. If any inconsistency is found, a worksheet named
notes_varname (where variable is the name of the variable) is created displaying 
all inconsistencies
*/
syntax, sheet(string) old(string) new(string) export(string)

tempfile temp
tempname frameold framenew
frame create `frameold'
frame create `framenew'
* Read notes worksheets
frame `frameold': qui import excel using "`old'", sheet(`sheet')  first
frame `framenew' {
    qui import excel using "`new'", sheet(`sheet') first
	qui save "`temp'", replace
}
* Compare notes
frame `frameold' {
	qui merge 1:1 note using `temp'
	qui count if _m != 3
	if `r(N)' {
		put_summary, file("`export'") value(`sheet') num(`r(N)')
		global CELLNUM = ${CELLNUM} + 1
	    qui gen desc = "old" if _m == 1
		qui replace desc = "new" if _m == 2
	    qui export excel note desc using "`export'" if (_m != 3), ///
			sheet("`sheet'", modify) first(var)
	}
}
	
frame drop `frameold'
frame drop `framenew'

end


program define local_to_column
/*
Convert a local with many values to a column 
named <var>
*/

syntax, local(string) var(string) [first(int 1)]

local i = 1
foreach item in `local' {
    qui set obs `i'
	if `i' == 1 {
	    qui gen `var' = substr("`item'", `first', .) in `i'
	}
	else {
	    qui replace `var' = substr("`item'", `first', .) in `i'
	}
	local ++ i
}

end


