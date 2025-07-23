*! version 0.3 18Jul2025
* Programmed by Gustavo Iglésias
* Dependencies: gtools, uselabel

program define metaxl_extract
/*
Extracts metadata from a data set. The output is an Excel file 
with general information about the data and variables' labels, 
value labels, notes, etc.
*/
version 16

syntax, [METAfile(string) TRUNCate CHARS NOTES REPLACE]

qui describe 
if `r(N)' == 0 | `r(k)' == 0 {
	di as error "No data in memory"
	exit 198
}

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

if "`truncate'" == "" {
	qui ds 
	foreach var in `r(varlist)' {
		local len = length("`var'")
		if `len' > 25 {
			di as error "Length of `var' longer than 25 characters. This will" ///
			" generate an error when creating the xlsx file with the metadata." ///
			`" Please specify the option "truncate" to truncate variable names"' ///
			" longer than 25 characters"
			exit 198
		}
	}
	qui label dir 
	foreach vl in `r(names)' {
		local len = length("`vl'")
		if `len' > 25 {
			di as error "Length of value label `vl' longer than 27 characters. This will" ///
			" generate an error when creating the xlsx file with the metadata." ///
			`" Please specify the option "truncate" to truncate value label names"' ///
			" longer than 27 characters"
			exit 198
		}		
	}
}
else {
	metaxl_truncate
}


tempname descframe
frame create `descframe'
frame `descframe': clear

quietly {
	label language
	local labellang = "`r(languages)'"
	local labelcount: word count `labellang'
	local default_label "default"
	if (`labelcount' > 1) local labellang: list labellang - default_label
	
	descdata, filename(`metafile') descframe(`descframe') ///
		labellang(`labellang') `problems' `chars' `notes'
	
	descvars, filename(`metafile') descframe(`descframe') ///
		labellang(`labellang') `problems' `chars' `notes'
		
	export_data_chars, filename(`metafile')
	
	unused_valab, lang(`labellang')
	if trim("`r(unused)'") != "" {
		quietly {
			putexcel set `metafile', sheet("data_features_spec") open modify
			putexcel A6 = "unused_value_labels"
			putexcel B6 = "`r(unused)'"
			putexcel save
		}
	}
}

di 
di as text "File " as result "`metafile'" as text " saved"

end


program define export_data_chars

syntax, filename(str)

* Export data chars
tempname dtacharsfr
frame create `dtacharsfr'
local dta_chars: char _dta[]

local k = 1
foreach chr in `dta_chars' {
	if substr("`chr'", 1, 4) != "note" {
		local chr_value: char _dta[`chr']
		if `k' == 1 {
			frame `dtacharsfr' {
				set obs `k'
				gen char = "`chr'" in `k'
				gen value = `"`chr_value'"' in `k'
			}
		}
		else {
			frame `dtacharsfr' {
				set obs `k'
				replace char = "`chr'" in `k'
				replace value = `"`chr_value'"' in `k'
			}					
		}
		local ++k		
	}	
}
frame `dtacharsfr' {
	qui count 
	if `r(N)' {
		sort char
		export excel using "`filename'", sheet("char_dta", replace) first(var)	
		clear
	}
}

frame drop `dtacharsfr'

end


program define descdata
/*
General description of the data: file name, last update, data label,
number of observations and variables, data sorting, size, data signature 
and notes. The info is stored in the worksheet "Data Features"
*/
syntax, filename(string) descframe(string) labellang(string) [problems chars notes]


local fn "${S_FN}"
local fndate "${S_FNDATE}"
quietly describe, varlist
local datalabel "`r(datalabel)'"
local obs `r(N)'
local vars `r(k)'
local sorted_by "`r(sortlist)'"
local size_mb = round((`r(width)' * `r(N)') / (1024 ^ 2), 0.001)
qui datasignature
local datasignature "`r(datasignature)'"


* Create data in new frame with data characteristics which may be used by 
* metaxl apply
frame `descframe' {
	set obs 4
	gen var = "File" in 1
	gen desc = "`fn'" in 1 
	replace var = "Data Label" in 2
	replace desc = "`datalabel'" in 2
	replace var = "Sorted by" in 3
	replace desc = "`sorted_by'" in 3
	replace var = "Label languages" in 4
	replace desc = "`labellang'" in 4
}

local i = 5

notes _count notes_count : _dta
forvalues j = 1/`notes_count' {
	notes _fetch note : _dta `j'
	frame `descframe' {
		set obs `i'
		replace var = "Data note `j'" in `i'
		replace desc = `"`note'"' in `i'
	}
	local ++i
}	


* Data characteristics
local dta_chars: char _dta[]
frame `descframe' {
	* remove chars that start with note
	foreach chr in `dta_chars' {
		if substr("`chr'", 1, 4) != "note" {
			local new_chars = "`new_chars'" + " `chr'"
		}
	}
	local dta_cc: word count `new_chars' 
	set obs `i' 
	replace var = "Data characteristics" in `i'
	replace desc = "`dta_cc'" in `i'
}	


frame `descframe' {
    rename (var desc) (Features Content)
	export excel using "`filename'", sheet("data_features_gen", replace) first(var)
	clear
}

frame `descframe' {
	set obs 5
	gen var = "Last changed" in 1
	gen desc = "`fndate'" in 1
	replace var = "Number of observations" in 2
	replace desc = "`obs'" in 2
	replace var = "Number of variables" in 3
	replace desc = "`vars'" in 3
	replace var = "Size (MB)" in 4
	replace desc = "`size_mb'" in 4
	replace var = "Data signature" in 5
	replace desc = "`datasignature'" in 5
	rename (var desc) (Features Content)
	export excel using "`filename'", sheet("data_features_spec", replace) first(var)
	clear
}

end


program define descvars
/*
Extracts variables' metadata 
*/

syntax, filename(string) descframe(string) labellang(string) ///
		[problems report(string) chars NOTES]

qui metavars, filename(`filename') descframe(`descframe') labellang(`labellang')

metavallab, filename(`filename') labellang(`labellang') `problems' 

if ("`chars'" == "chars") metachars, filename(`filename') descframe(`descframe') 

if ("`notes'" == "notes") metanotes, filename(`filename') descframe(`descframe') 

end


program define metavars
/*
Extracts general information about variables: labels (one for each language),
type, format, number of characteristics, number of notes and value labels 
defined. The info is stored in the worksheet "Variables"
*/

syntax, filename(string) descframe(string) labellang(string)

local i = 1
foreach var of varlist * {
	notes _count notes_count : `var'
	foreach lang in `labellang' {
		label language `lang'
		local label_`lang': variable label `var'
		local value_label_`lang': value label `var'
	}
	local type: type `var'
	local format: format `var'
	local chars: char `var'[]
	local charcount: word count `chars'
	frame `descframe' {
		set obs `i'
		if `i' == 1 {
			gen variable = "`var'" in `i'
			foreach lang in `labellang' {
				gen label_`lang' = "`label_`lang''" in `i'
				gen value_label_`lang' = "`value_label_`lang''" in `i'
			}
			gen type = "`type'" in `i'
			gen format = "`format'" in `i'
			gen chars = `charcount' in `i'
			gen notes = `notes_count' in `i'
		}
		else {
			replace variable = "`var'" in `i'
			foreach lang in `labellang' {
				replace label_`lang' = `"`label_`lang''"' in `i'
				replace value_label_`lang' = `"`value_label_`lang''"' in `i'
			}
			replace type = "`type'" in `i'
			replace format = "`format'" in `i'
			replace chars = `charcount' in `i'
			replace notes = `notes_count' in `i'
		}
	}
	
	local ++i
}

frame `descframe' {
	export excel using "`filename'", sheet("variables", replace) first(var) 
	clear
}
	
end


program define metavallab
/*
Extracts information about each value label defined. The output is stored
in a worksheet named "vl_`vallabel'", where `vallabel' is the name of the
value label. The sheet contains every possible value for the variables and
its corresponding label
*/

syntax, filename(string) labellang(string) [problems] 

/* Generate data with values with all the values for variables and the respective 
value label name. This will be used later to check if all values have labels */

* value labels 
preserve 
	tempname vlframe
	qui uselabel, clear
	qui describe
	if `r(N)' != 0 & `r(k)' != 0 {
		qui glevelsof lname, local(lbls)
		foreach lbl in `lbls' {
			frame put if lname == "`lbl'", into(`vlframe')
			frame `vlframe' {
				qui tostring value, replace
				tempfile `lbl'
				qui save ``lbl'', replace
			}
			frame drop `vlframe'
		}
	}
restore

tempname valframe
qui ds
local varlist "`r(varlist)'"

foreach lang in `labellang' {
	qui label language `lang'
	foreach var in `varlist' {
		local var_obs ""
		
		local vl: value label `var'

		if trim("`vl'") != "" {
			noi di "`vl'"
			frame put `var', into(`valframe')
			frame `valframe' {
				quietly {
					bysort `var': drop if _n > 1
					tostring `var', gen(value)

					tempvar _merge
					* Expose errors in merge
					cap merge 1:1 value using ``vl'', gen(`_merge')
					if _rc {
						di "{err:Error exporting value labels for {bf:`vl'}}"
						exit _rc
					}
					else {
						qui count if `_merge' == 2
						if `r(N)' {
							qui gen obs_`var' = "Label not used" if `_merge' == 2
							local var_obs = "`var_obs'" + " obs_`var'"
						}

						drop `_merge'
						* Same vl for multiple variables
						local vl_exists: list vl in vl_list
						if `vl_exists' {
							append using ``vl'_file'
							save ``vl'_file', replace
						}
						else {
							tempfile `vl'_file
							save ``vl'_file', replace
						}
						
						local var_obs = trim("`var_obs'")
						order value label `var_obs' 


						* Expand the values in obs_var
						foreach ovar in `var_obs' {
							// With strings, missings go first
							bysort value (`ovar'): replace `ovar' = `ovar'[_N] ///
								if missing(`ovar')
						}
						
						bysort value: keep if _n == 1
						
						* Sort value as if it was numeric
						tempvar sortvar
						destring value, gen(`sortvar') force
						sort `sortvar'
						drop `sortvar'

						qui export excel value label `var_obs' using `"`filename'"', ///
							sheet("vl_`vl'", replace) first(var)
						clear						
					}
				}
			}
			frame drop `valframe'
			local vl_list `vl_list' `vl'
			local vl_list: list uniq vl_list
		}
	}
}

end


program define metachars
/*
Extracts information about variables' characteristics. The output is stored
in a worksheet named "char_`var'", where `var' is the name of the variable. There is
one sheet per variable. The sheet contains the name of every characteristic and 
its content.
*/

syntax, filename(string) descframe(string) 

qui ds
local vars "`r(varlist)'"

foreach var in `vars' {
	local chars: char `var'[]
	if "`chars'" != "" {
		local i = 1
		foreach chr in `chars' {
			local chr_value: char `var'[`chr']
			if `i' == 1 {
				frame `descframe' {
					set obs `i'
					gen char = "`chr'" in `i'
					gen value = `"`chr_value'"' in `i'
				}
			}
			else {
				frame `descframe' {
					set obs `i'
					replace char = "`chr'" in `i'
					replace value = `"`chr_value'"' in `i'
				}					
			}
			local ++i
		}
		frame `descframe' {
			qui count 
			if `r(N)' {
				sort char
				export excel using "`filename'", sheet("char_`var'", replace) first(var)	
				clear
			}
		}
	}
}

end



program define metanotes
/*
Extracts information about variables' notes. The output is stored in a worksheet 
named "notes_`var'", where `var' is the name of the variable. There is
one sheet per variable. The sheet contains the variables' notes 
*/
syntax, filename(string) descframe(string) 

	
foreach var of varlist * {
	notes _count notes_count : `var'
	if `notes_count' > 0 {
		forvalues i = 1/`notes_count' {
			notes _fetch note : `var' `i'
			frame `descframe' {
				set obs `i'
				if `i' == 1 {
					gen note = `"`note'"' in `i'
				}
				else {
					replace note = `"`note'"' in `i'
				}
			}
		}
		frame `descframe' {
			export excel using "`filename'", sheet("note_`var'", replace) first(var)	
			clear
		}
	}
}

end


program define unused_valab, rclass

syntax, lang(string)

qui label dir
local labels "`r(names)'"
qui ds
local vars "`r(varlist)'"

foreach vl in `labels' {
    local vl_used 0
    foreach lg in `lang' {
	    foreach var in `vars' {
			di "`lg'"
		    qui label language `lg'
			local val_lab: value label `var'
			di "`val_lab'"
			if (trim("`vl'") == trim("`val_lab'")) local vl_used = `vl_used' + 1
		}
	}
	if (`vl_used' == 0) local unused = "`unused'" + " `vl'" 
}

return local unused = "`unused'"

end
