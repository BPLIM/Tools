*! 0.4 8jul2019
* Programmed by Gustavo Iglésias
* Dependencies: 
* savesome (version 1.1.0 23feb2015) 

program define validarcae

syntax varlist(min=1 max=1), [rev(int 3) cfl dropzero getlevels(string) fl fr en]


cap which savesome 
if _rc {
	di as error "This tool uses the command savesome (version 1.1.0 23feb2015) as a dependency. Please install it before running validarcae."
	error _rc
}

cap drop _valid_cae_`rev'
cap label drop validlabel`rev'

tempvar cae_str
local namevar "`cae_str'"

preserve
	mata: st_local("filename",findfile("caecodes.txt"))
	qui import delimited `"`filename'"', encoding(iso-8859-9) clear
	qui keep if rev == `rev'
	qui drop rev
	qui rename des_pt _des_pt
	qui rename des_en _des_en
	qui rename cae_num _cae_num
	qui rename cae_str `namevar'
	tempfile temp
	qui save "`temp'", replace // file with valid cae codes
restore



local vartype: type `varlist'

di 
di "Variable `varlist' is `vartype'"
di 
di "Checking compatibility with CAE rev. `rev'"

// decode variable if specified by the user
if "`cfl'" == "cfl" {
	qui decode `varlist', gen(`cae_str')
	qui replace `cae_str' = word(`cae_str',1)
}
else {
	if substr("`vartype'",1,3) == "str" {
		qui clonevar `cae_str' = `varlist'
	}
	else {
		qui gen `cae_str' = string(`varlist')
	}
}

// save observations with missing values for variable cae
tempfile tempmiss
qui savesome if missing(`varlist') using "`tempmiss'", replace
qui drop if missing(`varlist')

tempvar strlen
qui gen `strlen' = length(`cae_str')

// if dropzero is speciied, zeros to the right will be dropped from the codes
if "`dropzero'" == "dropzero" {
	cap assert !(substr(`cae_str',`strlen',1) == "0") // while any observation has a zero in the last char
	while _rc {
		qui replace `cae_str' = substr(`cae_str',1,`strlen'-1) if substr(`cae_str',`strlen',1) == "0"
		qui replace `strlen' = length(`cae_str')
		cap assert !(substr(`cae_str',`strlen',1) == "0")
	}
	qui replace `cae_str' = "0" if missing(`cae_str') 
	qui replace `strlen' = length(`cae_str')
}

// revision 1 has 6 digits and always starts with a number different from 0
if `rev' == 1 {
	tempfile tempinvalidlength
	qui savesome if (`strlen' < 1 | `strlen' > 6) using "`tempinvalidlength'", replace
	qui drop if (`strlen' < 1 | `strlen' > 6)
	forvalues i = 1/6 {
		preserve
			qui keep if `strlen' == `i'
			qui merge m:1 `cae_str' using "`temp'"
			qui drop if _merge == 2
			qui gen int _valid_cae_`rev' = `i'1 if _merge == 3
			qui replace _valid_cae_`rev' = 99 if _merge == 1
			qui drop _merge
			qui drop `cae_str'
			tempfile temp`i'
			qui save "`temp`i''", replace
		restore
	}
	clear
	forvalues i = 1/6 {
		qui append using "`temp`i''"
	}
	qui append using "`tempmiss'"
	qui replace _valid_cae_`rev' = 0 if missing(_valid_cae_`rev')
	
	qui append using "`tempinvalidlength'"
	qui replace _valid_cae_`rev' = 99 if missing(_valid_cae_`rev')
	
	label define validlabel`rev' 0 "Missing" 11 "1 dig only" 21 "2 dig only" 31 "3 dig only" 41 "4 dig only" 51 "5 dig only" 61 "6 dig only" 99 "Invalid" 
}

// Codes from revisions 2, 21 and 3 have 5 digits and may start with a zero. So we want to check if numbers with a length smaller than 5 can still be valid codes if
// we add a 0 to the left of the code. For string variables this should not happen, because the zero is not lost on conversion. The same is true for variables
// from BPLIM datasets.
else {
	tempfile tempinvalidlength
	qui savesome if (`strlen' < 1 | `strlen' > 5) using "`tempinvalidlength'", replace
	qui drop if (`strlen' < 1 | `strlen' > 6)
	forvalues i = 1/5 {
		preserve
			qui keep if `strlen' == `i'
			if `i' == 5 {
				qui merge m:1 `cae_str' using "`temp'"
				qui drop if _merge == 2
				qui gen int _valid_cae_`rev' = `i'1 if _merge == 3
				qui replace _valid_cae_`rev' = `i'2 if _merge == 1
				qui drop _merge
				qui drop `cae_str'
				tempfile temp`i'
				qui save "`temp`i''", replace
			}
			else {
				qui merge m:1 `cae_str' using "`temp'"						// merge on the original code
				qui drop if _merge == 2
				qui rename _merge _m1
				qui replace `cae_str' = "0" + `cae_str'
				qui merge m:1 `cae_str' using "`temp'"						// merge on the code preceeded by a 0
				qui drop if _merge == 2
				qui rename _merge _m2
				qui gen int _valid_cae_`rev' = `i'1 if (_m1 == 3 & _m2 == 1) // valid at i digits only
				qui replace _valid_cae_`rev' = `i'2 if (_m1 == 1 & _m2 == 3) // valid at i + 1 digits (0 + i digits)
				qui replace _valid_cae_`rev' = `i'3 if (_m1 == 3 & _m2 == 3) // valid at i digits only or i + 1 digits (0 + i digits)
				qui replace _valid_cae_`rev' = `i'4 if (_m1 == 1 & _m2 == 1) // invalid
				qui drop _m*
				qui drop `cae_str'
				tempfile temp`i'
				qui save "`temp`i''", replace
			}
		restore
	}

	clear
	forvalues i = 1/5 {
		qui append using "`temp`i''"
	}
	qui append using "`tempmiss'"
	qui replace _valid_cae_`rev' = 0 if missing(_valid_cae_`rev')
	
	qui append using "`tempinvalidlength'"
	qui replace _valid_cae_`rev' = 99 if missing(_valid_cae_`rev')

	qui replace _valid_cae_`rev' = 99 if inlist(_valid_cae_`rev', 14, 24, 34, 44, 52)

	label define validlabel`rev' 0 "Missing" 11 "1 dig only" 12 "2 dig (0 + 1 dig)" 13 "1 dig only or 2 dig (0 + 1 dig)" ///
							21 "2 dig only" 22 "3 dig (0 + 2 dig)" 23 "2 dig only or 3 dig (0 + 2 dig)" ///
							31 "3 dig only" 32 "4 dig (0 + 3 dig)" 33 "3 dig only or 4 dig (0 + 3 dig)" ///
							41 "4 dig only" 42 "5 dig (0 + 4 dig)" 43 "4 dig only or 5 dig (0 + 4 dig)" ///
							51 "5 dig only" 99 "Invalid" 
}

					
label values _valid_cae_`rev' validlabel`rev'

tab _valid_cae_`rev'

cap drop rev
cap drop _des_pt
cap drop _des_en
cap drop _cae_num
cap drop `cae_str'


if "`getlevels'" != "" {
	foreach item in `getlevels' {
		local levelscount: word count `getlevels'
		if `rev' == 3 {
			if `levelscount' > 5 {
				di as error "CAE Rev. 3 only admits 5 levels"
				error 198
			}
			if ("`item'" != "1" & "`item'" != "2" & "`item'" != "3" & "`item'" != "4" & "`item'" != "5") {
				di as error "CAE Rev. 3 only admits 5 values for levels: 1, 2, 3, 4 and 5"
				error 198
			}
		}
		else {
			if `levelscount' > 6 {
				di as error "CAE Rev. `rev' only admits 6 levels"
				error 198
			}
			if ("`item'" != "1" & "`item'" != "2" & "`item'" != "3" & "`item'" != "4" & "`item'" != "5" & "`item'" != "6") {
				di as error "CAE Rev. `rev' only admits 6 values for levels: 1, 2, 3, 4, 5 and 6"
				error 198
			}
		}
	}

	if `rev' == 1 {
		get_div1 `varlist', file(`temp') levels(`getlevels') `fr' `cfl' namevar(`namevar') `en'
	}
	else if `rev' == 2 {
		get_div2 `varlist', file(`temp') levels(`getlevels') `fl' `fr' `cfl' namevar(`namevar') `en'
	}
	else if `rev' == 21 {
		get_div21 `varlist', file(`temp') levels(`getlevels') `fl' `fr' `cfl' namevar(`namevar') `en'
	}
	else {
		get_div3 `varlist', file(`temp') levels(`getlevels') `fl' `fr' `cfl' namevar(`namevar') `en'
	}
}

qui compress _valid_cae_`rev'

end
