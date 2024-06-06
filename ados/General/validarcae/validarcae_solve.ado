* Dependencies: jarowinkler

program define validarcae_solve, sortpreserve

syntax varname [if], vardesc(string) file(string) vars(string) [th(real 0.7)]


local ifnot = "!(" + trim(substr(trim("`if'"), 3, .)) + ")"

tempvar vardec code desc code0 des des0 _merge d d0 pdis len0 len1 len dis nn
tempfile tempf
quietly {
	bysort `varlist' `vardesc': gen `nn' = _n
}

cap drop _sug_code
cap drop _solved
cap label drop solvedlbl

qui clonevar `code' = `varlist'
qui clonevar `desc' = `vardesc'
qui replace `desc' = trim(ustrlower(`desc'))
qui gen `code0' = "0" + `code'

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

preserve
	qui use "`file'", clear
	keep `vars'
	rename (`vars') (`code0' `des0')
	qui replace `des0' = trim(ustrlower(`des0'))
	qui save `tempf', replace
restore

qui merge m:1 `code0' using `tempf', gen(`_merge')
qui drop if `_merge' == 2
drop `_merge'

quietly {
	jarowinkler `desc' `des', gen(`d')
	replace `d' = . if `ifnot' | `nn' != 1
	bysort `varlist' `vardesc' (`d'): replace `d' = `d'[1]
	jarowinkler `desc' `des0', gen(`d0')
	replace `d0' = . if `ifnot' | `nn' != 1
	bysort `varlist' `vardesc' (`d0'): replace `d0' = `d0'[1]
}
drop `nn'

* Keep the best match
qui replace `code' = cond(`d' > `d0', `code', `code0')
qui replace `des' = cond(`d' > `d0', `des', `des0')
qui gen `dis' = cond(`d' > `d0', `d', `d0')
drop `code0' `des0' `d' `d0'

rename `code' _sug_code

drop `desc'

qui replace _sug_code = "" if `dis' < `th' | `ifnot'
qui gen _solved = 1
qui replace _solved = 0 if `dis' < `th'
qui replace _solved = . if `ifnot'
label define solvedlbl 0 "0 unsolved for threshold = `th'" 1 "1 solved"
label values _solved solvedlbl

qui compress _sug_code

end
