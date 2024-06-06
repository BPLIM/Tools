* Dependencies: jarowinkler

program define validarcae_sim, sortpreserve

syntax varname [if/], vardesc(string) file(string) vars(string) [rev(int 3)]

di 
di "{text:Calculating Jaro-Winkler similarity between {bf:`vardesc'} and official labels}"

tempvar vardec code desc des _merge d nn
tempfile tempf
quietly {
	bysort `varlist' `vardesc': gen `nn' = _n
}

cap drop _jwsim_rev_`rev'

qui clonevar `code' = `varlist'
qui clonevar `desc' = `vardesc'
qui replace `desc' = trim(ustrlower(`desc'))

preserve
	qui use "`file'", clear
	keep `vars'
	rename (`vars') (`code' `des')
	qui replace `des' = trim(ustrlower(`des'))
	qui save `tempf', replace
restore

qui merge m:1 `code' using `tempf', gen(`_merge')
qui drop if `_merge' == 2
drop `_merge'

quietly {
	jarowinkler `desc' `des', gen(`d')
	replace `d' = .  if `nn' != 1
	bysort `varlist' `vardesc' (`d'): replace `d' = `d'[1]
}
drop `nn' `code' `desc'

qui rename `d' _jwsim_rev_`rev'

qui replace _jwsim_rev_`rev' = . if !(`if')

end
