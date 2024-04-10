*! version 0.2 27Mar2024
* Programmed by Gustavo Iglésias
* Dependencies: gtools

program define mdata_check, rclass

syntax, METAfile(string) [CHECKfile(string) DELimit(string)]

local metafile "`metafile'.xlsx"

if trim("`checkfile'") == "" {
    local keep_check = 0
    tempname cfile
	local checkfile "`cfile'.xlsx"
}
else {
    local keep_check = 1
	gettoken checkfile replacecheck: checkfile, p(",")
	local checkfile = trim("`checkfile'")
	local checkfile "`checkfile'.xlsx"
	gettoken lixo replacecheck: replacecheck, p(",")
	cap confirm file "`checkfile'"
	if !_rc & trim("`replacecheck'") != "replace" {
		di as error `"File "`checkfile'" already exists. Please specify "' ///
		`"sub-option "replace" to overwrite the existing file"'
		exit 602
	}
	else {
		cap rm "`checkfile'"
	}
}

cap drop macro MAINSHEET CELLNUM

global MAINSHEET "Summary"
global CELLNUM = 5

cap putexcel save
qui putexcel set "`checkfile'", open modify sheet("${MAINSHEET}")
qui putexcel A1 = "Meta file", bold
qui putexcel B1 = "`metafile'"

qui putexcel A4 = "worksheet", bold
qui putexcel B4 = "warnings", bold
qui putexcel C4 = "inconsistencies", bold
qui putexcel save

* Label languages 
tempname lgframe
frame create `lgframe'
frame `lgframe' {
	qui import excel using "`metafile'", sheet("data_features_gen") clear first
	qui glevelsof Content if Features == "Label languages", local(levels)
	local labellang `levels'
}
frame drop `lgframe'


qui putexcel set "`checkfile'", open modify sheet("${MAINSHEET}")
check_ds_unusedvl, meta(`metafile')
if "`r(unused_lab)'" != "" {
	qui putexcel A$CELLNUM = "unused_value_label"
	qui putexcel B$CELLNUM = "`r(unused_lab)'"
	global CELLNUM = ${CELLNUM} + 1 
}
qui putexcel save

check_data_features, report(`checkfile') meta(`metafile')

check_duplicated_vars, report(`checkfile') meta(`metafile')

vl_problems, lang(`labellang') report(`checkfile') meta(`metafile') del("`delimit'")

check_variables_fields, report(`checkfile') meta(`metafile')

check_var_labels, lang(`labellang') report(`checkfile') meta(`metafile')

check_vallab, lang(`labellang') report(`checkfile') meta(`metafile')


if ${CELLNUM} == 5 {
	local no_inc 1
}
else {
    local no_inc 0
    tempname frinc
	frame create `frinc'
	frame `frinc' {
	    qui import excel using "`checkfile'", sheet("Summary") clear 
		rename (A B C) (worksheet warnings inconsistencies)
		qui drop if _n < 5
		qui glevelsof worksheet if real(inconsistencies) > 0, local(incon)
		qui glevelsof worksheet if real(warnings) > 0, local(warnings)
		di 
		li, noobs ab(20) div sep(1000) 
	}
    return local inconsistencies `"`incon'"'
	return local warnings `"`warnings'"'
	frame drop `frinc'
}

if `keep_check' {
    di 
	if `no_inc' {
	    di as text "No warnings or inconsitencies found. File " as result ///
		"`checkfile'" as text " will not be saved"
		if (trim("`replacecheck'") != "replace") cap rm "`checkfile'"
	}
	else {
	    di as text "File " as result "`checkfile'" as text " saved"
	}
}
else {
    cap rm "`checkfile'"
}


end


program define put_summary

syntax, file(string) value(string) [warn(int 0) inc(int 0)]

qui putexcel set "`file'", open modify sheet("${MAINSHEET}")
qui putexcel A${CELLNUM} = "`value'"
qui putexcel B${CELLNUM} = `warn'
qui putexcel C${CELLNUM} = `inc'
qui putexcel save

end 


program check_ds_unusedvl, rclass

syntax, meta(string)

tempname dtasgn
frame create `dtasgn'
frame `dtasgn' {
	cap import excel "`meta'", sheet("data_features_spec") clear first
	if !_rc {
	    qui glevelsof Content if Features == "unused_value_labels", local(levels)
	    return local unused_lab `levels'
        }
}

frame drop `dtasgn'

end


program define check_data_features

syntax, report(string) meta(string)

tempname frfeat
frame create `frfeat'
frame `frfeat' {
	qui import excel "`meta'", sheet("data_features_gen") clear first
	quietly {
	   bysort Features: keep if _N > 1
	}
	qui count
	if `r(N)' {
		qui export excel using "`report'", sheet("data_features_gen", replace) first(var)
		put_summary, file("`report'") value(data_features_gen) warn(`r(N)') 
		global CELLNUM = ${CELLNUM} + 1
	}
}
frame drop `frfeat'

end


program define check_duplicated_vars

syntax, report(string) meta(string)

tempname frvars
frame create `frvars'
frame `frvars' {
    tempvar NN 
	qui import excel "`meta'", sheet("variables") first clear
	keep variable
	bysort variable: gen `NN' = _N
	qui count if `NN' > 1
	if `r(N)' {
	    qui keep if `NN' > 1
		drop `NN'
		quietly {
		    bysort variable: keep if _n == 1
		}
		qui count
		qui export excel using "`report'", sheet("duplicated_variables", replace) first(var)
		put_summary, file("`report'") value(duplicated_variables) inc(`r(N)')
		global CELLNUM = ${CELLNUM} + 1
	}
}
frame drop `frvars'

end


program define check_variables_fields

syntax, report(string) meta(string)

tempname frfields
frame create `frfields'
frame `frfields' {
    qui import excel "`meta'", describe
	forvalues i = 1/`r(N_worksheet)' {
	    local sheet "`r(worksheet_`i')'"
		if (substr("`sheet'", 1, 4) == "data" | "`sheet'" == "variables") continue
		local sheets = "`sheets'" + " `sheet'"
	}
	local sheets = trim("`sheets'")
	qui import excel "`meta'", sheet("variables") first clear
	* Value labels 
	if "`sheets'" != "" {
		foreach var of varlist value_label* {
			check_missing_sheets `var', sheets(`sheets') feature(vl)
			local missing_sheets = "`missing_sheets'" + " `r(missing_sheets)'"
		}
	
		* Chars
		check_missing_sheets variable if chars > 0, sheets(`sheets') feature(char)
		local missing_sheets = "`missing_sheets'" + " `r(missing_sheets)'"
		* Notes 
		check_missing_sheets variable if notes > 0, sheets(`sheets') feature(note)
		local missing_sheets = "`missing_sheets'" + " `r(missing_sheets)'"
		local missing_sheets = trim("`missing_sheets'")
	}
	if "`missing_sheets'" != "" {
		clear
		local i = 1
		local num_warns = 0
		local num_incon = 0
		foreach sheet in `missing_sheets' {
		    qui set obs `i'
			if `i' == 1 {
			    qui gen missing_sheets = "`sheet'" in `i'
				qui gen type = ""
			}
			else {
			    qui replace missing_sheets = "`sheet'" in `i'
			}
			if (inlist(substr("`sheet'", 1, 4), "note", "char")) {
				local ++num_warns
				qui replace type = "warning" in `i'
			}
			else {
				local ++num_incon
				qui replace type = "inconsistency" in `i'
			}
			local ++i
		}
		
		qui export excel using "`report'", sheet("missing_sheets", replace) first(var)
		put_summary, file("`report'") value(missing_sheets) inc(`num_incon') warn(`num_warns') 
		global CELLNUM = ${CELLNUM} + 1
	}
}
frame drop `frfields'

end


program define check_missing_sheets, rclass

syntax varname [if], sheets(string) feature(string)

qui glevelsof `varlist' `if', local(levels)
foreach item in `levels' {
	local missing_sheet = 0
	foreach sheet in `sheets' {
		if (substr("`sheet'", 1, length("`feature'")) != "`feature'") continue
		if ("`feature'_`item'" == "`sheet'") {
			local missing_sheet = 1
			continue, break
		}
	}
	if !`missing_sheet' {
		local missing_sheets = "`missing_sheets'" + " `feature'_`item'"
	}
}

return local missing_sheets = trim("`missing_sheets'")

end


program define check_var_labels

/*
Checks if all variables have labels defined for every language. Inconsistencies
are reported the worksheet "var_labels"
*/

syntax, lang(string) report(string) meta(string)

tempname labframe
frame create `labframe'
frame `labframe' {
	qui import excel "`meta'", sheet("variables") all first clear
	foreach lg in `lang' {
		local keep_vars = "`keep_vars'" + " label_`lg'"
	}
	keep variable `keep_vars'
	qui gen missing_var_label = ""
	qui gen truncated = ""
	foreach lg in `lang' {
		qui replace missing_var_label = missing_var_label + " `lg'" if missing(label_`lg')
		qui replace truncated = truncated + " `lg'" if length(label_`lg') > 80
	}
	qui keep variable missing_var_label truncated
	qui keep if !missing(missing_var_label) | !missing(truncated)
	foreach var in missing_var_label truncated {
		qui count if !missing(`var')
		if (`r(N)' == 0) drop `var'	
	}
	qui count 
	if `r(N)' {
		qui export excel using "`report'", sheet("var_labels", replace) first(var) 
		put_summary, file("`report'") value(var_labels) warn(`r(N)')
		global CELLNUM = ${CELLNUM} + 1
	}
}

frame drop `labframe'

end


program define check_vallab

syntax, lang(string) report(string) meta(string)


tempname labframe vlframe
frame create `labframe'
frame `labframe' {
	tempvar dum_vl
	qui import excel "`meta'", sheet("variables") first clear
	qui gen `dum_vl' = 0
	foreach lg in `lang' {
		local keep_vars = "`keep_vars'" + " value_label_`lg'"
		* keep only variabels with a least one value label defined
		qui replace `dum_vl' = `dum_vl' + 1 if !missing(value_label_`lg')
	}
	qui keep if `dum_vl' > 0
	drop `dum_vl'
	frame put `keep_vars', into(`vlframe')
	keep variable `keep_vars'
	qui gen missing_value_label = ""
	foreach lg in `lang' {
		qui replace missing_value_label = missing_value_label + "`lg' " if missing(value_label_`lg')
	}
	qui replace missing_value_label = trim(missing_value_label)
	qui keep variable missing_value_label
	qui keep if !missing(missing_value_label)
	qui count 
	if `r(N)' {
		rename variable valuelabel
		qui export excel using "`report'", sheet("var_valuelabels", replace) first(var)
		put_summary, file("`report'") value(var_valuelabels) warn(`r(N)')
		global CELLNUM = ${CELLNUM} + 1
	}
}

end


program define vl_problems

syntax, lang(string) report(string) meta(string) [DELimit(string)]

tempname vlframe
frame create `vlframe'

frame `vlframe' {
	tempvar dum_vl
	qui import excel "`meta'", sheet("variables") first clear
	qui gen `dum_vl' = 0
	foreach lg in `lang' {
		local keep_vars = "`keep_vars'" + " value_label_`lg'"
		* keep only variabels with a least one value label defined
		qui replace `dum_vl' = `dum_vl' + 1 if !missing(value_label_`lg')
	}
	qui keep if `dum_vl' > 0
	drop `dum_vl'
	keep `keep_vars'

	foreach var in `keep_vars' {
		qui count if !missing(`var') 
		if `r(N)' {
			qui glevelsof `var', local(vls)
			foreach vl in `vls' {
				local vallabs = "`vallabs'" + " `vl'"
			}
		}
	}

	tempname vl_fr
	frame create `vl_fr'
	foreach vl in `vallabs' {
		frame `vl_fr' {
			cap import excel "`meta'", sheet("vl_`vl'") first clear
			if _rc  == 601 {
			    di
			    di as error "worksheet vl_`vl' not found"
			}
			else {
			    tempvar desc NN
				* Generate variable with the description part of the label
				if "`delimit'" != "" {
					qui gen `desc' = substr(label, strpos(label, "`delimit'") ///
						+ strlen("`delimit'"), .) if strpos(label, "`delimit'")					
				}
				else {
					qui clonevar `desc' = label
				}
			    qui gen problems = ""
				* Leading or trailing blanks
				qui replace problems = problems + "Leading or trailing blanks" if ///
					substr(label, 1, 1) == " " | ///
					substr(label, length(label), 1) == " "
				* Label not used
				cap confirm var obs
				if !_rc {
					qui replace problems = obs + " | " + problems ///
						if !missing(obs) & !missing(problems)
					qui replace problems = obs + problems ///
						if !missing(obs) & missing(problems)
					drop obs
				}
				* Duplicated descriptions
				bysort `desc': gen `NN' = _N
				qui replace problems = "Duplicated description | " + problems ///
					if `NN' > 1 & !missing(`desc') & !missing(label) & ///
					!missing(problems)
				qui replace problems = "Duplicated description" + problems ///
					if `NN' > 1 & !missing(`desc') & !missing(label) & ///
					missing(problems)
				drop `NN' `desc'
				* Duplicated labels
				bysort label: gen `NN' = _N
				qui replace problems = "Duplicated label | " + problems ///
					if `NN' > 1 & !missing(label) & !missing(problems)
				qui replace problems = "Duplicated label" + problems ///
					if `NN' > 1 & !missing(label) & missing(problems)
				drop `NN'
				* Duplicated values
				bysort value: gen `NN' = _N
				qui replace problems = "Duplicated value | " + problems ///
					if `NN' > 1 & !missing(problems)
				qui replace problems = "Duplicated value" + problems ///
					if `NN' > 1 & missing(problems)
				drop `NN'
				* Missing labels 
				qui replace problems = "Missing label | " + problems ///
					if missing(label) & !missing(problems)
				qui replace problems = "Missing label" + problems ///
					if missing(label) & missing(problems)
				* Just to be safe
				qui replace problems = trim(problems)
				* Keep only inconsistencies
				qui keep if !missing(problems)
				qui count 
				if `r(N)' {
					sort value
					qui export excel using "`report'", sheet("vl_`vl'", replace) first(var)
					qui count if strpos(problems, "Duplicated label") | ///
						strpos(problems, "Duplicated value")
					local inc = `r(N)'
					qui count if !(strpos(problems, "Duplicated label") | ///
						strpos(problems, "Duplicated value"))
					local warn = `r(N)'
					put_summary, file("`report'") value(vl_`vl') warn(`warn') inc(`inc')
					global CELLNUM = ${CELLNUM} + 1
				}			    
			}
		}
	}
	frame drop `vl_fr'
}

frame drop `vlframe'

end
