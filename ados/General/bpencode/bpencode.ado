*! version 0.1 30Apr2021
* Programmed by Gustavo Iglésias
* Dependencies: gtools

program define bpencode, sortpreserve

version 16

syntax varlist(min=1 max=1),  [ ///
	vl(string)       ///
	GENerate(string) ///
	vlname(string)   ///
	METAfile(string) ///
	vlsheet(string)  ///
	dropzeros 		 ///
]

qui count if missing(`varlist')
if `r(N)' == _N {
	di as text "Variable " as result "`varlist'" as text " contains only missing values."
	if ("`generate'" == "") local generate "_enc_`varlist'" 
	cap gen long `generate' = real(`varlist')
	if _rc {
	    qui clonevar `generate' = `varlist'
	}
	qui compress `generate'
}
else {
	* Label values from file provided by the user
	if "`metafile'" != "" {
		local meta "`metafile'.xlsx"
		confirm file "`meta'"
		if ("`generate'" == "") local generate "_enc_`varlist'" 
		if "`vlsheet'" == "" {
			di as error "Option vlsheet is mandatory when the user specifies option metafile"
			exit 198
		}
		import_vl `varlist', vl(`vl') gen(`generate') meta(`meta') ///
			vlsheet(`vlsheet') `dropzeros'
	}
	else {
		if ("`vlname'" == "") local vlname "`vl'"
		if ("`generate'" == "") local generate "_enc_`varlist'" 
		* Find if variable contains letters, numbers or both
		bp_get_type `varlist'
		* Encode variable depending on the previous result
		if `r(type)' == 1 {
			encode_numbers `varlist', gen(`generate')
		}
		else if `r(type)' == 2 {
			encode_letters `varlist', gen(`generate')
		}
		else {
			encode_mixed `varlist', gen(`generate')
		}
		* Label values 
		if "`vl'" != "" {
			gen_vl `generate', vl(`vl') var(`varlist') vlname(`vlname') `dropzeros'
		}
	}
}

end


program define encode_numbers

syntax varlist(min=1 max=1) [if], GENerate(string)

di
di as text "Encoding " as result "`varlist'"

tempvar NN0 NN1

local vtype: type `varlist'
if substr("`vtype'", 1, 3) == "str" {
	quietly {
		bysort `varlist': gen `NN0' = _N
		qui gen long `generate' = real(`varlist') `if'
		bysort `generate': gen `NN1' = _N
		cap assert `NN0' == `NN1' 
		if _rc {
			di as error "`varlist' not constant within groups of `generate'"
			exit 198
		}
	}
}
else {
	qui clonevar `generate' = `varlist' `if'
}
qui compress `generate'

end


program define encode_letters

syntax varlist(min=1 max=1) [if], GENerate(string) [max_value(int 0)]

di
di as text "Encoding " as result "`varlist'"

sort `varlist'
qui gegen long `generate' = group(`varlist') `if'
if `max_value' {
	qui replace `generate' = `generate' + `max_value'   
}
else {
	qui sum `generate'
	get_factor, num(`r(max)')
	qui replace `generate' = `generate' + `r(factor)'
}
qui compress `generate'

end


program define encode_mixed

syntax varlist(min=1 max=1) [if], GENerate(string) [max_value(int 0)]

di
di as text "Encoding " as result "`varlist'"

tempvar destr splittype
qui gen `splittype' = 0
qui destring `varlist', gen(`destr') force 
qui replace `splittype' = 1 if !missing(`varlist') & missing(`destr')
drop `destr'
* encode only values with letters
sort `splittype' `varlist'
if `max_value' {
    qui gegen long `generate' = group(`varlist') `if' & `splittype' == 1
	qui replace `generate' = real(`varlist') `if' & `splittype' == 0
	qui replace `generate' = `generate' + `max_value' `if' & `splittype' == 1
}
else {
	qui gegen long `generate' = group(`varlist') if `splittype' == 1
	qui replace `generate' = real(`varlist') if `splittype' == 0
	/* values with letters will have one or two more digit than the maximum number of digits
	 of only number digits*/
	qui sum `generate' if `splittype' == 0
	get_factor, num(`r(max)')
	qui replace `generate' = `generate' + `r(factor)' if `splittype' == 1 
}
qui compress `generate'
drop `splittype'

end


program define gen_vl

syntax varlist(min=1 max=1), vl(string) var(string) vlname(string) [ ///
	frommeta dropzeros ///
]

cap file close vldo
cap label drop `vlname'

tempname vlframe applyvl
frame put `varlist' `vl' `var', into(`vlframe')
frame `vlframe' {
	qui drop if missing(`varlist')
	quietly {
		bysort `varlist': keep if _n == 1
	}
	qui file open vldo using "`applyvl'.do", write replace
	qui count 
	di 
	forvalues i=1/`r(N)' {
		/*
		if trim(`vl'[`i']) == "" {
			di as text "Value " as result `var'[`i'] ///
			as text " has no label"
		}*/
		
			local value = `varlist'[`i']
			if (`value' >= 2147483622 | `value' <= -2147483648) {
				di as error "`value' outside of value range allowed for label define"
				exit 198
			}
			if "`frommeta'" != "" {
				local label = `vl'[`i']
			}
			else {
				local var_label = `var'[`i']
				* Drop left zeros
				if "`dropzeros'" == "dropzeros" {
					if substr("`var_label'", 1, 1) == "0" {
						drop_zeros, val(`var_label')
						local var_label = "`r(val)'"
					}
				}
				if trim(`vl'[`i']) == "" {
					local label = "*`var_label'"
				} 
				else {
					if trim("`var'") == trim("`vl'") {
						local label = "`var_label'"
					}
					else {
						local label = "`var_label' " + `vl'[`i']						
					}
				}
			}
			local label = strtrim(stritrim(`"`label'"'))
			file write vldo `"label define `vlname' `value' `"`label'"', add"' _n
		
	}
	file write vldo `"label values `varlist' `vlname', nofix"' _n
	file close vldo 
	clear
}

frame drop `vlframe'

run "`applyvl'.do"
rm "`applyvl'.do"

end


program define drop_zeros, rclass 

syntax, val(string)

local case 1
while `case' {
	if substr("`val'", 1, 1) == "0" & length("`val'") > 1 {
		local val = substr("`val'", 2, .)
	}
	else {
		continue, break
	}
}

return local val `val'

end


program define import_vl

syntax varlist, gen(string) meta(string) vlsheet(string) dropzeros [vl(string)]

tempname vlframe 
tempvar value label _merge _not_labelled
tempfile temp 
frame create `vlframe'
frame `vlframe' {
	qui import excel using "`meta'", first sheet("vl_`vlsheet'") clear
	qui gen `varlist' = word(label, 1)
	rename value `value'
	rename label `label'
	qui sum `value'
	local max_value = `r(max)'
	qui save "`temp'"
}

qui merge m:1 `varlist' using `temp', gen(`_merge') keepusing(`value' `label')
qui gen `_not_labelled' = (`_merge' == 1 & !missing(`varlist'))
qui count if `_not_labelled' == 1
if `r(N)' {
    * Display info 
	di 
	di "New values:"
	tab `varlist' if `_not_labelled' == 1
	di
}
if ("`vl'" != "") check_label `varlist' `vl' `label' `_merge'
qui drop if `_merge' == 2
drop `_merge'
* Label values based on meta
rename `value' `gen'
gen_vl `gen', vl(`label') var(`varlist') vlname(`vlsheet') frommeta `dropzeros'
drop `label'
* In case there are new values 
qui count if `_not_labelled' == 1
if `r(N)' {
    * Encode new values
    bp_get_type `varlist'
	tempvar temp
	if `r(type)' == 1 {
		encode_numbers `varlist' if `_not_labelled' == 1, ///
			gen(`temp')
	}
	else if `r(type)' == 2 {
		encode_letters `varlist' if `_not_labelled' == 1, ///
			gen(`temp') max_value(`max_value')
	}
	else {
		encode_mixed `varlist' if `_not_labelled' == 1, ///
			gen(`temp') max_value(`max_value')
	}
	qui replace `gen' = `temp' if `_not_labelled' == 1
	drop `temp'
	* Label new values
	if "`vl'" != "" {
		add_vl `gen', vl(`vl') var(`varlist') vlname(`vlsheet') ///
			filter(`_not_labelled') 		
	}
}

drop `_not_labelled'

end


program define check_label

syntax varlist(min=4 max=4)

tempname checkfr
tokenize `varlist'
frame put `1' `2' `3' `4', into(`checkfr')
frame `checkfr' {
    qui keep if `4' == 3
	drop `4'
	quietly {
	    bys `1': keep if _n == 1
	}
	* Remove value (label is of the form "#### label")
	qui replace `3' = substr(`3', strpos(`3', " ") + 1, .)
	qui count if `2' != `3'
	if `r(N)' {
		rename `3' label_from_meta
		di 
		di "Inconsistent labels:"
		li `1' `2' label_from_meta if `2' != label_from_meta, ab(20) noo
	}
}
frame drop `checkfr'

end


program define add_vl

syntax varlist(min=1 max=1), vl(string) var(string) ///
	   vlname(string) filter(string) 
	
di
di as text "Using " as result "`vl'" as text " to add labels to new values"

cap file close vldo

tempname vlframe addvl
frame put `varlist' `vl' `var' `filter', into(`vlframe')
frame `vlframe' {
	qui drop if missing(`varlist')
	qui keep if `filter' == 1
	drop `filter'
	quietly {
		bysort `varlist': keep if _n == 1
	}
	qui file open vldo using "`addvl'.do", write replace
	qui count 
	di 
	forvalues i=1/`r(N)' {
		if trim(`vl'[`i']) == "" {
			di as text "Value " as result `var'[`i'] ///
			as text " has no label"
		}
		else {
			local value = `varlist'[`i']
			if (`value' >= 2147483622 | `value' <= -2147483648) {
				di as error "`value' outside of value range allowed for label define"
				exit 198
				
			}
			local var_label = `var'[`i']
			if trim("`var'") == trim("`vl'") {
				local label = "`var_label'"
			}
			else {
				local label = "`var_label' " + `vl'[`i']						
			}
			local label = strtrim(stritrim(`"`label'"'))
			file write vldo `"label define `vlname' `value' `"`label'"', add"' _n
		}
	}
	file write vldo `"label values `varlist' `vlname', nofix"' _n
	file close vldo 
}

frame drop `vlframe'

run "`addvl'.do"
rm "`addvl'.do"

end


program define get_factor, rclass

syntax, [num(int 0)]

local num_digits = floor(log10(`num')) + 1

if `num_digits' <= 5 {
	return local factor = 10 ^ (`num_digits' + 1)
}
else {
	return local factor = 10 ^ `num_digits'
}

end
