*! version 0.1 22Jul2025
* Programmed by Gustavo Iglésias
* Dependencies: gtools

program define metaxl_cmp, rclass
/*
Compares metadata for two Stata data sets. The metadata must
be stored in an Excel file. This can be achieved using the
command metaxl extract
*/

syntax, f1(string) f2(string) [export(string) REPLACE]

version 16

if trim("`export'") == "" {
	local export "metacmp.xlsx"
}
else {
	local export "`export'.xlsx"
}
cap confirm file "`export'"
if !_rc & "`replace'" != "replace" {
	di as error `"File "`export'" already exists."'
	exit 602	
}
else {
	cap rm "`export'"
}

cap drop macro MAINSHEET CELLNUM

global MAINSHEET "Summary"
global CELLNUM = 5

cap putexcel save

qui putexcel set "`export'", open modify sheet("${MAINSHEET}")
qui putexcel A1 = "f2", bold
qui putexcel A2 = "f1", bold
qui putexcel A4 = "Sheet", bold
qui putexcel B4 = "Inconsistencies found", bold
qui putexcel B1 = "`f2'.xlsx"
qui putexcel B2 = "`f1'.xlsx"
qui putexcel save
 

compare_vars, new(`f1'.xlsx) old(`f2'.xlsx) export(`export')

compare_sheets, new(`f1'.xlsx) old(`f2'.xlsx) export(`export')

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
	rename_vars, prefix(_f2_)
}
frame `framenew' {
    qui import excel using "`new'", sheet("variables") first clear
	* rename variables to compare them after the merge
	rename_vars, prefix(_f1_)
	qui save "`temp'", replace
}
* Compare worksheets
frame `frameold' {
	* First section
	tempvar _merge
	qui merge 1:1 variable using `temp', gen(`_merge')
	qui count if `_merge' != 3
	local var_count = `r(N)'
	if `r(N)' {
		put_summary, file("`export'") value(Variables) num(`r(N)')
		global CELLNUM = ${CELLNUM} + 1
		qui gen desc = "f2" if `_merge' == 1
		qui replace desc = "f1" if `_merge' == 2
		qui export excel variable desc using "`export'" if `_merge' != 3, ///
			sheet("Variables", modify) first(var)
	}
	qui keep if `_merge' == 3
	drop `_merge'
	* Second section 
	compare_columns
	if `r(col_inc)' {
		qui putexcel set "`export'", open modify sheet("Variables' Features")
		putexcel A1 = "feature"
		putexcel B1 = "desc" 
		local cell_num = 2
		foreach col in `r(cols_master)' {
			putexcel A`cell_num' = "`col'"
			putexcel B`cell_num' =  "f2"
			local cell_num = `cell_num' + 1
		}
		foreach col in `r(cols_using)' {
			putexcel A`cell_num' = "`col'"
			putexcel B`cell_num' = "f1"
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
	    qui gen `temp' =  (_f1_`var' == _f2_`var')
		qui count if `temp' == 0
		if `r(N)' {
			put_summary, file("`export'") value(Variables' `var') num(`r(N)')
			global CELLNUM = ${CELLNUM} + 1
			qui export excel variable _f1_`var' _f2_`var' using "`export'" if `temp' == 0, ///
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
    if strpos("`var'", "_f2_") local vars_old = "`vars_old'" + " `var'"
	if strpos("`var'", "_f1_") local vars_new = "`vars_new'" + " `var'"
}
* Convert locals to columns
frame `frold': local_to_column, local(`vars_old') var(`column') first(5)
frame `frnew' {
    local_to_column, local(`vars_new') var(`column') first(5)
	qui save `temp', replace
}
* Compare columns (each column contains variables' features)
frame `frold' {
	tempvar _merge
    qui merge 1:1 `column' using `temp', gen(`_merge')
	qui count if `_merge' != 3
	local col_inc = r(N)
	qui glevelsof `column' if `_merge' == 3, local(matched)
	qui glevelsof `column' if `_merge' == 1, local(cols_master)
	qui glevelsof `column' if `_merge' == 2, local(cols_using)
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
	tempvar _merge
	qui merge 1:1 `sheet' using `temp', gen(`_merge')
	qui count if `_merge' != 3
	if `r(N)' {
		put_summary, file("`export'") value(Sheets) num(`r(N)')
		global CELLNUM = ${CELLNUM} + 1
	    qui gen desc = "f2" if `_merge' == 1
		qui replace desc = "f1" if `_merge' == 2
		rename `sheet' sheet 
		qui export excel sheet desc using "`export'" if `_merge' != 3, ///
			sheet("Sheets", modify) first(var)
		drop desc
		rename sheet `sheet'
	}
	qui keep if `_merge' == 3
	drop `_merge'  
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
	qui tostring value, replace
	rename label label_f2
}
frame `framenew' {
    qui import excel using "`new'", sheet(`sheet')  first
	qui tostring value, replace
	rename label label_f1
	qui save "`temp'", replace
}

frame `frameold' {
    local incon = 0
	* Compare values
	tempvar _merge 
	qui merge 1:1 value using `temp', gen(`_merge')
	qui count if `_merge' != 3
	if `r(N)' {
	    qui gen desc = "f2" if `_merge' == 1
		qui replace desc = "f1" if `_merge' == 2
		local incon = `incon' + `r(N)'
	}
	* Compare labels
	qui gen `equal_label' = (label_f1 == label_f2)
	qui count if `_merge' == 3 & `equal_label' == 0
	if `r(N)' {
		if `incon' {
			qui replace desc = "different label" if `_merge' == 3 & `equal_label' == 0
		}
		else {
			qui gen desc = "different label" if `_merge' == 3 & `equal_label' == 0
		}
		local incon = `incon' + `r(N)'
	}
	if `incon' {
		put_summary, file("`export'") value(`sheet') num(`incon')
		global CELLNUM = ${CELLNUM} + 1
	    qui export excel value desc label_f2 label_f1 ///
			using "`export'" if (`_merge' != 3) | (`_merge' == 3 & `equal_label' == 0) , ///
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
	rename value value_f2
}
frame `framenew' {
    qui import excel using "`new'", sheet(`sheet') first
	* Remove Stata default chars 
	qui drop if substr(char, 1, 1) == "_" | ///
		substr(char, 1, length("datasignature")) == "datasignature" | ///
		substr(char, 1, length("destring")) == "destring" | ///
		substr(char, 1, length("tostring")) == "tostring" | ///
		substr(char, 1, 4) == "note"
	rename value value_f1
	qui save "`temp'", replace
}

frame `frameold' {
    local incon = 0
	* Compare chars
	tempvar _merge
	qui merge 1:1 char using `temp', gen(`_merge')
	qui count if `_merge' != 3
	if `r(N)' {
	    qui gen desc = "f2" if `_merge' == 1
		qui replace desc = "f1" if `_merge' == 2
		local incon = `incon' + `r(N)'
	}
	* Compare chars' values
	qui gen `equal_value' = (value_f1 == value_f2)
	qui count if `_merge' == 3 & `equal_value' == 0
	if `r(N)' {
		if `incon' {
			qui replace desc = "different value" if `_merge' == 3 & `equal_value' == 0
		}
		else {
			qui gen desc = "different value" if `_merge' == 3 & `equal_value' == 0
		}
		local incon = `incon' + `r(N)'
	}
	if `incon' {
		put_summary, file("`export'") value(`sheet') num(`incon')
		global CELLNUM = ${CELLNUM} + 1
	    qui export excel char desc value_f2 value_f1 ///
			using "`export'" if (`_merge' != 3) | (`_merge' == 3 & `equal_value' == 0) , ///
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
	tempvar _merge
	qui merge 1:1 note using `temp', gen(`_merge')
	qui count if `_merge' != 3
	if `r(N)' {
		put_summary, file("`export'") value(`sheet') num(`r(N)')
		global CELLNUM = ${CELLNUM} + 1
	    qui gen desc = "f2" if `_merge' == 1
		qui replace desc = "f1" if `_merge' == 2
	    qui export excel note desc using "`export'" if (`_merge' != 3), ///
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


