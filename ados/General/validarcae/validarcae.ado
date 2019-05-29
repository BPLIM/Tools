*! version 1.0 20Feb2019
* Programmed by Gustavo Iglésias
* Dependencies:
* package matrixtools

program define validarcae

syntax varlist [if], [rev(string) tvar(string) freq excel(string) keep]

version 15

// error in file with codes
if "`excel'" == "" {
	capture confirm file caecodes.xlsx
	if _rc {
		di as error "An xlsx file with CAE codes was not found in your current working directory. Please specify the file in option excel or place the file caecodes.xlsx in your current working directory"
		error 198
	}
}

// error in number of revisions
local revcount: word count `rev'
if `revcount' > 4 {
	di as error "The maximum number of inputs for option rev is 4"
	error 198
}

// default classification
if "`rev'" == "" {
	local rev = "3"
}

// error in classification
foreach item in `rev' {
	if "`item'" != "1" & "`item'" != "2" & "`item'" != "21" & "`item'" != "3" {
		di as error "`item' is not a valid CAE classification. Valid CAE classifications include 1, 2, 21 and 3"
		error 198
	}
}

capture label drop l1
capture label drop l2
capture label drop l21
capture label drop l3
capture label drop l
capture drop rev
capture drop des
capture drop _valid_cae*
capture drop _merge
capture drop cae_code 
capture drop cae_str


local vartype: type `varlist'

preserve
	foreach item in `rev' {
		tempfile temp`item'
		quietly import excel "`excel'", firstrow clear
		if substr("`vartype'",1,3) != "str" {
			quietly drop if missing(cae_code)
		}
		quietly keep if rev == `item'
		quietly save `temp`item''
	}	
restore

if "`if'" != "" {
	tempvar id
	quietly gen `id' = _n
	preserve
	quietly keep `if'
}

// generating string variable with cae code (this variable is deleted when the program ends)
local vartype: type `varlist'
if substr("`vartype'",1,3) == "str" {
	quietly clonevar cae_str = `varlist'
	local var_merge = "cae_str"
}
else {
	quietly clonevar cae_code = `varlist'
	local var_merge = "cae_code"
}

// merge master dataset with a maximum of 4 files with cae codes for each classification. Create variable _valid_cae# = 1 for observations in which the merge is successful



foreach item in `rev' {
	quietly merge m:1 `var_merge' using `temp`item''
	quietly keep if _merge == 1 | _merge == 3
	quietly gen _valid_cae`item' = 0
	quietly replace _valid_cae`item' = 1 if (_merge == 3 & length(cae_str) == 2)
	quietly replace _valid_cae`item' = 2 if (_merge == 3 & length(cae_str) == 3)
	quietly replace _valid_cae`item' = 3 if (_merge == 3 & length(cae_str) == 4)
	quietly replace _valid_cae`item' = 4 if (_merge == 3 & length(cae_str) == 5)
	quietly replace _valid_cae`item' = 5 if (_merge == 3 & length(cae_str) == 6)
	label variable _valid_cae`item' "Valid CAE `item'"
	label define l`item' 0 "Invalid" 1 "Valid at 2 digits" 2 "Valid at 3 digits" 3 "Valid at 4 digits" 4 "Valid at 5 digits" 5 "Valid at 6 digits"
	label values _valid_cae`item' l`item'
	drop _merge
	if "`var_merge'" == "cae_code" {
		drop cae_str
	}
}

// create _valid_cae which checks if the cae code is valid according to any classification (max number of classifications = 4) specified by the user
local wordcount: word count `rev'
if `wordcount' == 1 {
	quietly gen _valid_cae = (_valid_cae`rev' != 0)
	label variable _valid_cae "Valid CAE"
	label define l 0 "Invalid" 1 "Valid"
	label values _valid_cae l
	valid_table _valid_cae, vars(_valid_cae`rev') tvar(`tvar') variable(`varlist') `freq'
}

if `wordcount' == 2 {
	local first: word 1 of `rev'
	local second: word 2 of `rev'
	quietly gen _valid_cae = (_valid_cae`first' != 0 | _valid_cae`second' != 0)
	label variable _valid_cae "Valid CAE"
	label define l 0 "Invalid" 1 "Valid"
	label values _valid_cae l
	valid_table _valid_cae, vars(_valid_cae`first' _valid_cae`second') tvar(`tvar') variable(`varlist') `freq'
}
if `wordcount' == 3 {
	local first: word 1 of `rev'
	local second: word 2 of `rev'
	local third: word 3 of `rev'
	quietly gen _valid_cae = (_valid_cae`first' != 0 | _valid_cae`second' != 0 | _valid_cae`third' != 0)
	label variable _valid_cae "Valid CAE"
	label define l 0 "Invalid" 1 "Valid"
	label values _valid_cae l
	valid_table _valid_cae, vars(_valid_cae`first' _valid_cae`second' _valid_cae`third') tvar(`tvar') variable(`varlist') `freq'
}
if `wordcount' == 4 {
	local first: word 1 of `rev'
	local second: word 2 of `rev'
	local third: word 3 of `rev'
	local fourth: word 4 of `rev'
	quietly gen _valid_cae = (_valid_cae`first' != 0 | _valid_cae`second' != 0 | _valid_cae`third' != 0 | _valid_cae`fourth' != 0)
	label variable _valid_cae "Valid CAE"
	label define l 0 "Invalid" 1 "Valid"
	label values _valid_cae l
	valid_table _valid_cae, vars(_valid_cae`first' _valid_cae`second' _valid_cae`third' _valid_cae`fourth') tvar(`tvar') variable(`varlist') `freq'
}

capture quietly drop cae_code
capture quietly drop cae_str
capture quietly drop rev
capture quietly drop des

local period1 = "1973 - 1993"
local period2 = "1994 - 2002"
local period21 = "2003 - 2007"
local period3 = "2008 - ..."

foreach item in `rev' {

	di _n
	di "Tabulation of valid and invalid codes by number of digits: CAE rev. `item' (`period`item'')"
	di ""
	tab _valid_cae`item'
}

if "`if'" != "" {
	tempfile mergefile
	quietly save `mergefile'
	restore
	quietly merge 1:1 `id' using `mergefile' 
	quietly drop _merge
}

if "`keep'" != "keep" {
	quietly drop _valid_cae*
}


end



program define valid_table, rclass

// creates table with valid and invalid cae codes. The valid cae codes are divided into the classifications specified by the user
// one of two tables is produce: one for when the user does not specify a time var and other with valid and invalid cae codes by time var

syntax varlist, vars(string) [tvar(string) freq] variable(string)

local wcount: word count `vars'
local colcount = `wcount' + 4

if "`tvar'" == "" {
	mat A = J(1,`colcount',0)
	quietly count
	mat A[1,1] = `r(N)'
	quietly count if `varlist' == 0 & !missing(`variable')
	mat A[1,2] = `r(N)'
	quietly count if missing(`variable')
	mat A[1,3] = `r(N)'
	local j = 4
	foreach var in `varlist' `vars' {
		quietly count if `var' != 0
		mat A[1,`j'] = `r(N)'
		local j = `j' + 1
	}
	di _n
	if "`freq'" == "freq" {
		mat A = A[1,1], (A[1,2...] / A[1,1]) * 100
		mat colnames A = Obs _invalid_cae missing_`variable' `varlist' `vars'
		mat rownames A = N
		di as result "Table of valid and invalid CAE codes (% of Obs)"
		di " "
		matprint A, decimals(0,2)
	}
	else {
		mat colnames A = Obs _invalid_cae missing_`variable' `varlist' `vars'
		mat rownames A = N
		di as result "Table of valid and invalid CAE codes"
		di " "
		matprint A, decimals(0)
	}
}
else {
	quietly levelsof(`tvar'), local(levels)
	local levcount: word count `levels'
	mat A = J(`levcount',`colcount',0)
	local i = 1
	foreach lev in `levels' {
		quietly count if `tvar' == `lev' 
		mat A[`i',1] = `r(N)'
		quietly count if `varlist' == 0  & `tvar' == `lev' & !missing(`variable')
		mat A[`i',2] = `r(N)'
		quietly count if missing(`variable') & `tvar' == `lev'
		mat A[`i',3] = `r(N)'
		local j = 4
		foreach var in `varlist' `vars' {
			if "`var'" == "`varlist'" {
				quietly count if `var' == 1 & `tvar' == `lev'
			}
			else {
				quietly count if `var' != 0 & `tvar' == `lev'
			}
			mat A[`i',`j'] = `r(N)'
			local j = `j' + 1
		}
		local i = `i' + 1
	}


	di _n
	if "`freq'" == "freq" {
		mat B = A[1...,2...]
		mata : st_matrix("B", st_matrix("B")[1...,1...]:/st_matrix("A")[1...,1]*100)
		mat A = A[1...,1], B
		mat colnames A = Obs _invalid_cae missing_`variable' `varlist' `vars' 
		mat rownames A = `levels' 
		di as result "Table of valid and invalid CAE codes (% of Obs)"
		di " "
		matprint A, decimals(0,2)
	}
	else {
		di as result "Table of valid and invalid CAE codes"
		di " "
		mat colnames A = Obs _invalid_cae missing_`variable' `varlist' `vars' 
		mat rownames A = `levels' 
		matprint A, decimals(0)
	}

}

return matrix _valid_cae = A

end
