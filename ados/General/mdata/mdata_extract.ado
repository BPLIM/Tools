*! version 0.1 5Mar2021
* Programmed by Gustavo Iglésias
* Dependencies: gtools, uselabel

program define mdata_extract
/*
Extracts metadata from a data set. The output is an Excel file 
with general information about the data and variables' labels, 
value labels, notes, etc.
*/
version 16

syntax, [METAfile(string) problems CHECKfile(string) TRUNCate]

qui describe 
if `r(N)' == 0 | `r(k)' == 0 {
	di as error "No data in memory"
	exit 198
}

if trim("`metafile'") == "" {
	local metafile "metafile.xlsx"
	cap confirm file "`metafile'"
	if !_rc {
		di as error `"File "`metafile'" already exists. Please specify "' ///
		`"option "metafile" to save the file under a different name"'
		exit 602
	}
}
else {
	gettoken metafile replacemeta: metafile, p(",")
	local metafile = trim("`metafile'")
	local metafile "`metafile'.xlsx"
	gettoken lixo replacemeta: replacemeta, p(",")
	cap confirm file "`metafile'"
	if !_rc & trim("`replacemeta'") != "replace" {
		di as error `"File "`metafile'" already exists. Please specify"' ///
		`"sub-option "replace" to overwrite the existing file"'
		exit 602
	}
	else {
		cap rm "`metafile'"
	}
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
	foreach vl in `r(varlist)' {
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
	mdata_truncate
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
		labellang(`labellang') `problems'
	
	descvars, filename(`metafile') descframe(`descframe') ///
		labellang(`labellang') `problems' 
}

di 
di as text "File " as result "`metafile'" as text " saved"

if "`problems'" == "problems" {
	qui unused_valab, lang(`labellang')
	if trim("`r(unused)'") != "" {
		quietly {
			putexcel set `metafile', sheet("data_features_spec") open modify
			putexcel A6 = "unused_value_labels"
			putexcel B6 = "`r(unused)'"
			putexcel save
		}
	}
	local metafile = subinstr("`metafile'", ".xlsx", "", 1)
	if "`checkfile'" == "" {
		mdata_check, meta(`metafile') problems
	}
	else {
		mdata_check, meta(`metafile') check(`checkfile') problems
	} 
}

end


program define descdata
/*
General description of the data: file name, last update, data label,
number of observations and variables, data sorting, size, data signature 
and notes. The info is stored in the worksheet "Data Features"
*/
syntax, filename(string) descframe(string) labellang(string) [problems]


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
* mdata apply
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
		[problems report(string)]

metavars, filename(`filename') descframe(`descframe') labellang(`labellang')

metavallab, filename(`filename') labellang(`labellang') `problems' 

metachars, filename(`filename') descframe(`descframe') 

metanotes, filename(`filename') descframe(`descframe') 

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
				replace label_`lang' = "`label_`lang''" in `i'
				replace value_label_`lang' = "`value_label_`lang''" in `i'
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

syntax, filename(string) labellang(string)  [problems] 

/* Generate data with values with all the values for variables and the respective 
value label name. This will be used later to check if all values have labels */
tempname valframe
qui ds
foreach var in `r(varlist)' {
	foreach lang in `labellang' {
		qui label language `lang'
		local vl: value label `var'
		if trim("`vl'") != "" {
			frame put `var', into(`valframe')
			frame `valframe' {
				quietly {
					tempfile `vl'
					drop if missing(`var')
					bysort `var': drop if _n > 1
					rename `var' value
					gen lname = "`vl'"
					save ``vl'', replace
					clear
				}
			}
			frame drop `valframe'
		}
	}
}

* value labels 
preserve 
	tempname vlframe
	uselabel, clear
	qui describe
	if `r(N)' != 0 & `r(k)' != 0 {
		qui glevelsof lname, local(lbls)
		foreach lbl in `lbls' {
			frame put if lname == "`lbl'", into(`vlframe')
			frame `vlframe' {
				local merge_file = lname[1]
				* merge_file may not exist 
				cap merge 1:1 value using "``merge_file''"
				if _rc {
					// pass
				}
				else {
					qui replace label = "" if _m == 2
					if "`problems'" == "problems" {
						qui count if _m == 1
						local m1_prob = `r(N)'
						if `m1_prob' {
							qui gen obs = "Label not used" if _m == 1
							local var_obs`lbl' "obs"
						}
					}
					drop _m
					qui export excel value label `var_obs`lbl'' using `"`filename'"', ///
						sheet("vl_`lbl'", replace) first(var)
				}
			}
			frame drop `vlframe'
		}
	}
restore

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
local dta_chars: char _dta[]
if trim("`dta_chars'") != "" {
	local vars = "_dta " + "`vars'" 
}

foreach var in `vars' {
	local chars: char `var'[]
	if "`chars'" != "" {
		local i = 1
		foreach chr in `chars' {
			if (("`var'" == "_dta") & (substr("`chr'", 1, 4) == "note")) continue
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
