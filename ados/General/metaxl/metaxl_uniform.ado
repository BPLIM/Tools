*! version 0.1 16Apr2021
* Programmed by Gustavo Iglésias
* Dependencies: bpencode

program define metaxl_uniform

syntax, METAfile(string) [SHeets(string) NEWfile(string) REPLACE]

version 16

confirm file `metafile'.xlsx

if trim("`newfile'") == "" {
	local newfile "`metafile'_new.xlsx"
}
else {
	local newfile "`newfile'.xlsx"
}
cap confirm file "`newfile'"
if !_rc & "`replace'" != "replace" {
	di as error `"File "`newfile'" already exists."'
	exit 602	
}
else {
	cap rm "`newfile'"
}

local metafile `"`metafile'.xlsx"'
copy "`metafile'" "`newfile'"

* Sheets
if "`sheets'" == "" {
	qui import excel using "`metafile'", describe
	forvalues i = 1/`r(N_worksheet)' {
		local sheet "`r(worksheet_`i')'"
		if substr("`sheet'", 1, 2) == "vl" {
			local sheets = "`sheets'" + " `sheet'"
		}
	}
	local sheets = trim("`sheets'")
}
* Harmonize data
foreach sheet in `sheets' {
	harmonize, meta(`newfile') sheet(`sheet')
}

di
di as text "File " as result "`newfile'" as text " saved"

end


program define harmonize

syntax, meta(string) sheet(string)

tempname frharm
frame create `frharm'
frame `frharm' {
	tempvar code num_code desc nn1 nn2
	quietly {
		import excel using "`meta'", sheet("`sheet'") first
		gen `code' = trim(word(label, 1))
		gen `desc' = substr(label, strpos(label, " ") + 1, .)
		drop if missing(`code')
		bysort `code': gen `nn1' = _N
		bysort `code' `desc': gen `nn2' = _N
		qui count if `nn1' != `nn2'
		if `r(N)' {
			drop `code' `desc' `nn1' `nn2'
			di as error "Different descriptions for the same code in " ///
			"sheet `sheet'"
			exit 198
		}
		drop `nn1' `nn2' `desc'
		* drop duplicates
		bysort `code': keep if _n == 1
	}
	bp_get_type `code'
	if `r(type)' == 0 {
		drop `code'
		di as error "Sheet `sheet' has only missing values"
		exit 198
	}
	else if `r(type)' == 1 {
		drop `code'
		di as error "Codes in value labels only contain digits"
		exit 198
	}
	else {
		qui bpencode `code', gen(`num_code')
		drop value 
		rename `num_code' value 
		drop `code'
		order value
		sort value
		di
		di as text "Codes in sheet " as res "`sheet'" as text " harmonized"
		qui export excel using "`meta'", sheet("`sheet'", replace) first(var)
	}
}

frame drop `frharm'

end
