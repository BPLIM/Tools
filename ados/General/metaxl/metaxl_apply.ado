*! version 0.2 8Nov2023
* Programmed by Gustavo Iglésias

program define metaxl_apply
/*
Applies metadata to data in memory. 
*/

syntax, METAfile(string) [DOfile(string) TRUNCate CHARS NOTES]

qui describe 
if `r(N)' == 0 | `r(k)' == 0 {
	di as error "No data in memory"
	exit 198
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
	metaxl_truncate
}

qui metaxl_check, meta(`metafile')

if trim(`"`r(inconsistencies)'"') != "" {
    di as error `""`metafile'" contains inconsitencies. Cannot apply meta "' ///
	`"data. Please run the command "metaxl check" with option "checkfile" to get"' ///
	" a more thourough look at the inconsitencies found."
	exit 198
}

local metafile "`metafile'.xlsx"

metaxl clear

tempname metaframe
frame create `metaframe'
cap file close metado
if ("`dofile'" == "") {
	tempname tempdo
	qui file open metado using "`tempdo'.do", write replace
}
else {
	qui file open metado using "`dofile'.do", write replace
}

write_data_features, metafile(`metafile') metaframe(`metaframe') `chars' `notes'

get_data_features, metafile(`metafile') metaframe(`metaframe')
local labellang "`r(labellang)'"

write_var_features, metafile(`metafile') metaframe(`metaframe') labellang(`labellang') ///
	`chars' `notes'

// file write metado `"save "`file'", replace"' _n

file write metado `"compress"' _n

file close metado

if ("`dofile'" == "") {
	run "`tempdo'.do"
	cap rm "`tempdo'.do"
}
else {
	run "`dofile'.do"
	di as text "File " as result "`dofile'.do" as text " saved"
}


end


program define write_data_features

syntax, metafile(string) metaframe(string) [CHARS NOTES]

get_data_features, metafile(`metafile') metaframe(`metaframe')

file write metado `"* Data features"' _n
if ("`r(datalabel)'" != "") file write metado `"label data "`r(datalabel)'""' _n
if ("`r(sorted_by)'" != "") file write metado `"sort `r(sorted_by)'"' _n
local labellang "`r(labellang)'"
foreach lang in `labellang' {
    file write metado `"cap label language `lang', new"' _n
}

if ("`notes'" == "notes") {
	if (`r(note_count)') {
		forvalues i=1/`r(note_count)' {
			file write metado `"note: `r(data_note_`i')'"' _n
		}
	}	
	else {
		di 
		di "{err:Data notes not available in metadata file}"
	}
}

if ("`chars'" == "chars") {
	if ("`r(data_chars)'" == "") local data_chars 0
	else local data_chars `r(data_chars)'
	if (`data_chars)') {
		frame `metaframe' {
			cap import excel using `metafile', sheet("char__dta") first clear
			if (_rc == 601) {
				di
				di "{err:Worksheet {bf:char__dta} not found in metafile}"
			}
			else {
				* Remove Stata default chars 
				qui drop if substr(char, 1, 1) == "_" | ///
					substr(char, 1, length("datasignature")) == "datasignature" | ///
					substr(char, 1, 4) == "note"
				qui count 
				if `r(N)' {
					forvalues i=1/`r(N)' {
						local char = char[`i']
						local value = value[`i']
						file write metado `"char _dta[`char'] `value'"' _n
					}	
				}				
			}
		}
	}
	else {
		di 
		di "{err:Data characteristics not available in metadata file}"		
	}
}


file write metado _n(2)

end


program define get_data_features, rclass

syntax, metafile(string) metaframe(string)

frame `metaframe' {
    qui import excel using `metafile', sheet("data_features_gen") clear first
	local excel_sheet "data_features_gen"
	local i = 1
	foreach feature in "Data Label" "Sorted by" "Label languages" "Data characteristics" {
		qui glevelsof Content if Feature == "`feature'", local(levels`i')
		if ("`feature'" == "Data Label") return local datalabel `: word 1 of `levels`i'''
		if ("`feature'" == "Sorted by") return local sorted_by `: word 1 of `levels`i'''
		if ("`feature'" == "Label languages") return local labellang `: word 1 of `levels`i'''
		if ("`feature'" == "Data characteristics") return local data_chars `: word 1 of `levels`i'''
		local ++i
	}
	* Notes
	qui glevelsof Content if strpos(Feature, "Data note"), local(notes_levels) 
	return local note_count = `: word count `notes_levels''
	local i = 1
	foreach note in `notes_levels' {
	    return local data_note_`i' = `"`note'"'
		local ++i
	}
	clear
}

end


program define write_var_features

syntax, metafile(string) metaframe(string) labellang(string) [CHARS NOTES]

tempfile temp
tempname fvallab fchars fnotes
foreach frm in fvallab fchars fnotes {
    frame create ``frm''
}
qui ds
local variables "`r(varlist)'"

frame `metaframe' {
	qui local_to_column, local(`variables') col(variable)
	qui save "`temp'", replace
    qui import excel using `metafile', sheet("variables") first clear
	tempvar _merge
	qui merge 1:1 variable using `temp', gen(`_merge')
	qui count 
	forvalues i=1/`r(N)' {
		local var = variable[`i']
		if `_merge'[`i'] == 1 {
			di as error `"variable "`var'" only available in "`metafile'""'
		}
		else if `_merge'[`i'] == 2 {
			di as error `"variable "`var'" not found in "`metafile'""'
		}
		else {
			file write metado `"**** `var' ****"' _n(2)
			local var_type = type[`i']
			write_var_type, var(`var') type(`var_type')
			local var_format = format[`i'] 
			write_var_format, var(`var') format(`var_format') 
			foreach lang in `labellang' {
				if  !missing(label_`lang'[`i']) {
					local label_`lang' = label_`lang'[`i']
					write_label, var(`var') lang(`lang') label(`"`label_`lang''"')
				}
				if !missing(value_label_`lang'[`i']) {
					local value_label_`lang' = value_label_`lang'[`i']
					* Check if value label is already defined
					check_vldef, vl(`value_label_`lang'') vls(`vls')
					if `r(vldef)' {
						write_value_label, var(`var') frame(`fvallab') lang(`lang') ///
							value_label(`value_label_`lang'') metafile(`metafile') 				
					}
					else {
						local vls = "`vls'" + " `value_label_`lang''"
						local vls = trim("`vls'")
						write_value_label, var(`var') frame(`fvallab') lang(`lang') ///
							value_label(`value_label_`lang'') metafile(`metafile') def						
					}
				}
			}
			if ("`chars'" == "chars") {
				local chars_var = chars[`i']
				if (`chars_var' > 0) {
					cap write_chars, var(`var') frame(`fchars') metafile(`metafile')
					if (_rc == 601) {
						di 
						di "{err:worksheet {bf:char_`var'} not found. Skipping }" ///
							"{err:apply for {bf:`var'} characteristic}"
					}
				}
			}
			if ("`notes'" == "notes") {
				local notes_var = notes[`i']
				if (`notes_var' > 0) {
					cap write_notes, var(`var') frame(`fnotes') metafile(`metafile')
					if (_rc == 601) {
						di 
						di "{err:worksheet {bf:note_`var'} not found. Skipping }" ///
							"{err:apply for {bf:`var'} note}"
					}
				}
			}
			file write metado _n(2)
		}
	}
}

foreach frm in fvallab fchars fnotes {
    frame drop ``frm''
}

end


program define check_vldef, rclass

syntax, vl(string) [vls(string)] 

local def 0

foreach lab in `vls' {
	if trim("`vl'") == trim("`lab'") {
		return local vldef 1
		local def 1
		continue, break
	}
}

if (!`def') return local vldef 0

end


program define local_to_column

syntax, local(string) col(string)

local i = 1
foreach item in `local' {
	set obs `i'
	if `i' == 1 {
		gen `col' = "`item'" in `i'
	}
	else {
		replace `col' = "`item'" in `i'
	}
	local ++i
}

end


program define write_var_type

syntax, var(string) type(string) 

file write metado `"* Type"' _n
file write metado `"recast `type' `var'"' _n

end


program define write_var_format

syntax, var(string) format(string) 

file write metado `"* Format"' _n
file write metado `"format `format' `var'"' _n

end


program define write_label

syntax, var(string) lang(string) label(string)

// di `"`label'"'

file write metado `"* Variable label - `lang'"' _n
file write metado `"label language `lang'"' _n
file write metado `"label variable `var' `"`label'"'"' _n

end


program define write_value_label

syntax, var(string) frame(string) lang(string) value_label(string) /// 
		metafile(string) [def]

file write metado `"* Value label - `lang'"' _n
frame `frame' {
	qui import excel using `metafile', sheet("vl_`value_label'") first clear
	qui count 
	if "`def'" == "def" {
		forvalues i=1/`r(N)' {
			local value = value[`i']
			local label = label[`i']
			file write metado `"label define `value_label' `value' `"`label'"', add"' _n
		}
	}
	file write metado `"label values `var' `value_label', nofix"' _n
}

end


program define write_chars

syntax, var(string) frame(string) metafile(string)

frame `frame' {
	qui import excel using `metafile', sheet("char_`var'") first clear
	* Remove Stata default chars 
	qui drop if substr(char, 1, 1) == "_" | ///
		substr(char, 1, length("datasignature")) == "datasignature" | ///
		substr(char, 1, length("destring")) == "destring" | ///
		substr(char, 1, length("tostring")) == "tostring" | ///
		substr(char, 1, 4) == "note"
	qui count 
	if `r(N)' {
	    file write metado `"* Characteristics"' _n
		forvalues i=1/`r(N)' {
			local char = char[`i']
			local value = value[`i']
			file write metado `"char `var'[`char'] `value'"' _n
		}
	}
}

end


program define write_notes

syntax, var(string) frame(string) metafile(string)

file write metado `"* Notes"' _n
frame `frame' {
	qui import excel using `metafile', sheet("note_`var'") first clear
	qui count 
	forvalues i=1/`r(N)' {
	    local note = note[`i']
		file write metado `"note `var': `note'"' _n
	}
}

end
