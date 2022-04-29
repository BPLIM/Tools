*! version 0.1 5Feb2021
* Programmed by Gustavo Iglésias

program define mdata_truncate

* Truncate variables
qui ds
foreach var in `r(varlist)' {
	if length("`var'") > 25 {
		local new_var = substr("`var'", 1, 25)
		di 
		di as text "Truncating variable " as result "`var'"
		cap rename `var' `new_var' 
		if _rc == 110 {
			di as error "Conflict when truncating variables. Variable" ///
			" `new_var' already defined. Restoring all variables names"
			if "`group1'" != "" {
				rename (`group2') (`group1')
			}
			exit 110
		}
		else {
			local group1 = "`group1'" + " `var'"
			local group2 = "`group2'" + " `new_var'"
		}
	}
}

* Truncate value labels
tempname vlab vlabrm
qui label language
local labellang = "`r(languages)'"
local labelcount: word count `labellang'
local default_label "default"
if (`labelcount' > 1) local labellang: list labellang - default_label
* Do files for restoring or removing value labels
qui file open vldo using "`vlab'.do", write replace
qui file write vldo "* Restore value labels" _n
qui file close vldo 
qui ds 
foreach var in `r(varlist)' {
	foreach lang in `labellang' {
		qui label language `lang'
		local vl: value label `var'
		if "`vl'" != "" {
			if length("`vl'") > 27 {
				local new_vl = substr("`vl'", 1, 27)
				di 
				di as text "Truncating value label " as result "`vl'"
				cap label copy `vl' `new_vl'
				if _rc == 110 {	
					di as error "Conflict when truncating value labels. Value label" ///
					" `new_vl' already defined. Restoring all value labels names"
					run `vlab'.do
					qui rm `vlab'.do
					exit 110
				}
				else {
					label values `var' `new_vl'
					* Add code to restore value labels
					qui file open vldo using "`vlab'.do", write append
					qui file write vldo "label language `lang'" _n
					qui file write vldo "label drop `new_vl'" _n
					qui file write vldo "label values `var' `vl'" _n
					qui file close vldo
					local rmlabel = "`rmlabel'" + " `vl'"
				}
			}
		}
	}
}

foreach vl in `rmlabel' {
	qui label drop `vl'
}

cap rm `vlab'.do

end





