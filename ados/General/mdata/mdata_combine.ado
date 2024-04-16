*! version 0.1 16Apr2024
* Programmed by Gustavo Iglésias

program define mdata_combine

syntax, f1(string) f2(string) [METAfile(string) CLEAN REPLACE]

local f1 "`f1'.xlsx"
local f2 "`f2'.xlsx"
confirm file `f1'
confirm file `f2'

if trim("`metafile'") == "" {
	local metafile "metafile.xlsx"
}
else {
	local metafile "`metafile'.xlsx"
}
cap confirm file "`metafile'"
if !_rc & "`replace'" != "replace" {
	di as error `"File "`metafile'" already exists."'
	exit 602	
}
else {
	cap rm "`metafile'"
}

match_sheets, f1(`f1') f2(`f2')
local f1_only "`r(f1_only)'"
local f2_only "`r(f2_only)'"
* Display unmatched sheets
forvalues i = 1/2 {
	if "`r(f`i'_only)'" != "" {
		di
		di "Worksheets found only in `f`i'': `r(f`i'_only)'"
	} 
}

di
di as text "Combining meta files " as result `"`f1'"' as text " and " ///
	as result `"`f2'"'
* Append matched sheets and export 
foreach sheet in `r(matched)' {
    * Data features - general
	if "`sheet'" == "data_features_gen" {
	    combine_sheets, sheet(`sheet') f1(`f1') f2(`f2') meta(`metafile') ///
			unique_on(Features Content) first `clean'   
	}
	* Data features - specific
	if "`sheet'" == "data_features_spec" continue
	* Variables 
	if "`sheet'" == "variables" {
	    combine_sheets, sheet(`sheet') f1(`f1') f2(`f2') meta(`metafile') ///
			unique_on(variable label* value_label*) sort_on(variable) first `clean'
	}
	* Value labels
	if substr("`sheet'", 1, 2) == "vl" {
	    combine_sheets, sheet(`sheet') f1(`f1') f2(`f2') meta(`metafile') ///
			unique_on(value label) sort_on(value) first `clean'
	}	
	* Chars
	if substr("`sheet'", 1, 4) == "char" {
	    combine_sheets, sheet(`sheet') f1(`f1') f2(`f2') meta(`metafile') ///
			unique_on(char value) first `clean'
	}		
	* Notes
	if substr("`sheet'", 1, 4) == "note" {
	    combine_sheets, sheet(`sheet') f1(`f1') f2(`f2') meta(`metafile') ///
			unique_on(note) first `clean'
	}	
}
* Export unmatched sheets
tempname frexp
frame create `frexp'
forvalues i = 1/2 {
	foreach sheet in `f`i'_only' {
		frame `frexp' {
			qui import excel using `f`i'', sheet("`sheet'") first clear
			qui export excel using "`metafile'", sheet("`sheet'", replace) first(var)
		}
	} 
}
frame drop `frexp'

di
di as text "File " as result `"`metafile'"' as text " saved"

end


program define combine_sheets

syntax, sheet(string) f1(string) f2(string) meta(string) ///
	unique_on(string) [sort_on(string) first clean]

tempfile temp
tempname sh_frame
frame create `sh_frame'
frame `sh_frame' {
    tempvar file1
    qui import excel using "`f1'", sheet(`sheet') `first' clear
	cap ds file* 
	local fc =  `:word count `r(varlist)'' + 1
	qui gen file`fc' = "f1"
	qui gen `file1' = 1
	qui save `temp', replace 
	qui import excel using "`f2'", sheet(`sheet') `first' clear
	qui gen file`fc' = "f2"
	qui append using `temp'
	local fb = `fc' - 1
	if `fb' {
		forvalues i = 1/`fb' {
			quietly {
				bysort `unique_on' `file1': replace file`i' = file`i'[1]
			}
		}
	}
	drop `file1'
	drop_dups `unique_on', fc(`fc')
	if ("`sort_on'" != "") sort `sort_on'
	if ("`clean'" == "clean") cap drop file*
	if "`first'" == "first" {
	    qui export excel using "`meta'", sheet("`sheet'", replace) first(var)
	}
	else {
	    qui export excel using "`meta'", sheet("`sheet'", replace)
	}
}

frame drop `sh_frame'	

end


program define drop_dups, sortpreserve

syntax varlist, [fc(int 1)]

local fprev = `fc' - 1

quietly {
    bysort `varlist': replace file`fc' = "" if _N > 1
	bysort `varlist': keep if _n == 1
	cap order file`fc', after(file`fprev')
}
	
end


program define match_sheets, rclass

syntax, f1(string) f2(string)

* Get sheets in file 1 and file 2
forvalues i = 1/2 {
	qui import excel using "`f`i''", describe
	forvalues j = 1/`r(N_worksheet)' {
		local sheets_f`i' = "`sheets_f`i''" + " `r(worksheet_`j')'"
	}
}
* Get sheets only in f1 and in both f1 and f2
foreach sheet1 in `sheets_f1' {
    local match = 0
    foreach sheet2 in `sheets_f2' {
	    if ("`sheet1'" == "`sheet2'") {
		    local match = 1
			continue, break
		}
	}
	if `match' {
	    local matched = "`matched'" + " `sheet1'"
	}
	else {
	    local f1_only = "`f1_only'" + " `sheet1'"
	}
}
* Get sheets only in file 2 
foreach sheet2 in `sheets_f2' {
    local match = 0
    foreach sheet1 in `sheets_f1' {
	    if ("`sheet2'" == "`sheet1'") {
		    local match = 1
			continue, break
		}
	}
	if (!`match') local f2_only = "`f2_only'" + " `sheet2'"
}

return local matched = trim("`matched'")
return local f1_only = trim("`f1_only'")
return local f2_only = trim("`f2_only'")

end
