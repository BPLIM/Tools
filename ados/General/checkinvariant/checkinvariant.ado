*! -checkinvariant- Check if a variable is invariant within a group
*! Luís Fonseca, https://github.com/luispfonseca

program define checkinvariant, rclass

syntax varlist, by(varlist) [ALLOWMISSing fill DROPINVARiant DROPVARiant KEEPINVARiant KEEPVARiant VERBose]

if "`allowmissing'" == "" & "`fill'" != "" {
	di as error "The fill option can only be called with the allowmissing option."
	error 198
}
if "`dropinvariant'" != "" & "`dropvariant'" != "" {
	di as error "Choose only one between dropinvariant and dropvariant."
	error 198
}
if "`keepinvariant'" != "" & "`keepvariant'" != "" {
	di as error "Choose only one between keepinvariant and keepvariant."
	error 198
}
local dropcondition "`dropvariant'`dropinvariant'"
local keepcondition "`keepvariant'`keepinvariant'"
if "`dropcondition'" != "" & "`keepcondition'" != "" {
	di as error "Choose only one condition between keep and drop."
	error 198
}

* ensure no duplicates in the varlist to loop over
local varlist : list uniq varlist

* exclude the by variables from the list if they are passed (e.g. in _all)
local varlist: list varlist - by

tempvar originalsort
qui gen `originalsort' = _n

* compute results
foreach var in `varlist' {

	*gegen doesn't take strings as input
	if substr("`:type `var''" , 1, 3) == "str" {
		tempvar grouped_string
		qui gegen `grouped_string' = group(`var')
		local finalvar `grouped_string'
	}
	else {
		local finalvar `var'
	}

	tempvar first_value
	gegen `first_value' = firstnm(`finalvar'), by(`by')

	local missing_condition ""
	if "`allowmissing'" != "" {
		local missing_condition " | mi(`finalvar')"
	}

	cap assert `finalvar' == `first_value' `missing_condition'

	if c(rc) == 0 {
		if "`verbose'" != "" {
			di as result "Invariant within `by': `var'"
		}
		local invariantvarlist `invariantvarlist' `var'
		if "`fill'" != "" & "`allowmissing'" != "" {
			cap assert `finalvar' == `first_value'
			if c(rc) {
				* gegen doesn't take strings as input, so I have to recover
				* the nonmissing values of strings in an inefficient way
				if substr("`:type `var''" , 1, 3) == "str" {
					qui hashsort `by' - `var'
					qui by `by': replace `var' = `var'[1]
				}
				else { // for numeric variables, can recover previously computed
					qui replace `var' = `first_value' if mi(`var')
				}
				local filledvarlist `filledvarlist' `var'
				local invariantvarlist: list invariantvarlist - var
			}
		}
	}
	else {
		if "`verbose'" != "" {
			di as result "  Variant within `by': `var'"
		}
		local   variantvarlist   `variantvarlist' `var'
	}
}

qui hashsort `originalsort'

if "`invariantvarlist'" != "" {
	di as result "Invariant within `by':"
	foreach var in `invariantvarlist' {
		di as result "`var'"
	}
}
if "`variantvarlist'" != "" {
	di as result "Variant within `by':"
	foreach var in `variantvarlist' {
		di as result "`var'"
	}
}
if "`filledvarlist'" != "" {
	di as result "Variables whose missing values were replaced by unique non-missing value:"
	foreach var in `filledvarlist' {
		di as result "`var'"
	}
}

return local varlist = "`varlist'"
return local by      = "`by'"

return local invariantvarlist "`invariantvarlist'"
return local   variantvarlist   "`variantvarlist'"
return local    filledvarlist    "`filledvarlist'"

return scalar numinvariant = `:word count `invariantvarlist''
return scalar   numvariant = `:word count   `variantvarlist''
if "`fill'" != "" & "`allowmissing'" != "" {
	return scalar numfilled    = `:word count    `filledvarlist''
}

if "`dropinvariant'" != "" {
	if "`invariantvarlist'" != "" {
		di as result "Dropping invariant variables:"
		di as result "`invariantvarlist'"
		local todrop `invariantvarlist'
	}
	if "`filledvarlist'" != "" {
		di as result "Dropping filled variables:"
		di as result "`filledvarlist'"
		local todrop `todrop' `filledvarlist'
	}
	cap drop `todrop'
}
if "`dropvariant'" != "" {
	if "`variantvarlist'" != "" {
		di as result "Dropping variant variables:"
		di as result "`variantvarlist'"
		drop `variantvarlist'
	}
}

if "`keepinvariant'" != "" {
	if "`invariantvarlist'" != "" {
		di as result "Keeping invariant variables:"
		di as result "`invariantvarlist'"
		local tokeep `invariantvarlist'
	}
	if "`filledvarlist'" != "" {
		di as result "Keeping filled variables:"
		di as result "`filledvarlist'"
		local tokeep `tokeep' `filledvarlist'
	}
	local tokeep `by' `tokeep'
	keep `tokeep'
}
if "`keepvariant'" != "" {
	if "`variantvarlist'" != "" {
		di as result "Keeping variant variables:"
		di as result "`variantvarlist'"
		local tokeep `variantvarlist'
	}
	local tokeep `by' `tokeep'
	keep `tokeep'
}

end
