*! 0.7 9Apr2021
* Programmed by Gustavo Iglésias
* Dependencies: 
* savesome (version 1.1.0 23feb2015)
* ustrdist

program define validarcae

syntax varlist(min=1 max=1) [if], [ ///
	rev(int 3) fromlabel dropzero keep getlevels(string) solve(string) ///
]

if ("`solve'" != "") {
	parse_solve, solve(`solve')
	local solvevar "`r(solvevar)'"
	local solveth `r(solveth)'
	local _solved "`r(_solved)'"
	local eng "`r(eng)'"
}

cap which savesome 
if _rc {
	di as error "This tool uses the command savesome (version 1.1.0 23feb2015)" ///
		"as a dependency. Please install it before running validarcae."
	error _rc
}

tempvar sortvar
qui gen `sortvar' = _n

if ("`if'" != "") {
	// create local with condition (without if)
	local if_w "if"
	local cond: list if - if_w
	local cond = trim("`cond'")
	
	// save obs (not if)
	tempfile tempifnot
	qui savesome if !(`cond') using "`tempifnot'", replace
	qui drop if !(`cond')
}

cap drop _cae_str
cap drop _valid_cae_`rev'
cap label drop validlabel`rev'


preserve
	mata: st_local("filename",findfile("caecodes.txt"))
	qui import delimited `"`filename'"', encoding(UTF-8) clear
	qui keep if rev == `rev'
	qui drop rev
	qui rename des_pt _des_pt
	qui rename des_en _des_en
	qui rename cae_num _cae_num
	qui rename cae_str _cae_str
	tempfile temp
	qui save "`temp'", replace // file with valid cae codes
restore

local vartype: type `varlist'

di 
di as text "Variable " as result "`varlist'" as text " is " ///
	as result "`vartype'"
di 
di as text "Checking compatibility with " as result "CAE rev. `rev'"

// decode variable if specified by the user
if "`fromlabel'" == "fromlabel" {
	qui decode `varlist', gen(_cae_str)
	qui replace _cae_str = word(_cae_str,1)
	tempvar decode_len 
	qui gen `decode_len' = length(_cae_str)
	label variable `decode_len' "Length"
	qui levelsof `decode_len', local(lenlevels)
	local lencount: word count `lenlevels'
	if `lencount' > 1 {
		di as error "Warning: codes retrieved from label do not have the same" ///
			"length for every observation" _n
		tab `decode_len'
		di _n
	}
}
else {
	if substr("`vartype'",1,3) == "str" {
		qui clonevar _cae_str = `varlist'
	}
	else {
		qui gen _cae_str = string(`varlist')
	}
}

// save observations with missing values for variable cae
tempfile tempmiss
qui savesome if missing(`varlist') using "`tempmiss'", replace
qui drop if missing(`varlist')

tempvar strlen
qui gen `strlen' = length(_cae_str)

tempvar _merge _m1 _m2

// revision 1 has 6 digits and always starts with a number different from 0
if `rev' == 1 {
	tempfile tempinvalidlength
	qui savesome if (`strlen' < 1 | `strlen' > 6) using "`tempinvalidlength'", replace
	qui drop if (`strlen' < 1 | `strlen' > 6)
	forvalues i = 1/6 {
		preserve
			qui keep if `strlen' == `i'
			qui merge m:1 _cae_str using "`temp'", gen(`_merge')
			qui drop if `_merge' == 2
			qui gen long _valid_cae_`rev' = 10 ^ (`i' - 1) if `_merge' == 3
			qui replace _valid_cae_`rev' = 200000 if `_merge' == 1
			qui drop `_merge'
			tempfile temp`i'
			qui save "`temp`i''", replace
		restore
	}
	clear
	forvalues i = 1/6 {
		qui append using "`temp`i''"
	}
	
	if "`dropzero'" == "dropzero" {
		cap assert _valid_cae_`rev' != 200000
		if _rc {
			tempfile zerodropfile
			qui savesome if (_valid_cae_`rev' == 200000 &  ///
				substr(_cae_str,-1,1) == "0" & `strlen' > 1) ///
				using `"`zerodropfile'"', replace
			qui drop if (_valid_cae_`rev' == 200000 & ///
				substr(_cae_str,-1,1) == "0" & `strlen' > 1)
			preserve
				data_dropzero1, file1(`zerodropfile') file2(`temp') rev(`rev')
			restore
			qui append using `"`zerodropfile'"'
		}
	}
	
	
	qui append using "`tempmiss'"
	qui replace _valid_cae_`rev' = 0 if missing(_valid_cae_`rev')
	
	qui append using "`tempinvalidlength'"
	qui replace _valid_cae_`rev' = 200000 if missing(_valid_cae_`rev')
	
	label define validlabel`rev' 0 "0 - Missing" 1 "1 - 1d" 10 "10 - 2d" ///
		100 "100 - 3d" 1000 "1000 - 4d" 10000 "10000 - 5d" 100000 "100000 - 6d" ///
		200000 "200000 - Invalid" 

	if "`dropzero'" == "dropzero" {
		addlabel, rev(`rev')
	}
	
}

/* Codes from revisions 2, 21 and 3 have 5 digits and may start with a zero. So 
we want to check if numbers with a length smaller than 5 can still be valid 
codes if we add a 0 to the left of the code. For string variables this should 
not happen, because the zero is not lost on conversion. The same is true for 
variables from BPLIM datasets. */
else {
	tempfile tempinvalidlength
	qui savesome if (`strlen' < 1 | `strlen' > 5) using "`tempinvalidlength'", replace
	qui drop if (`strlen' < 1 | `strlen' > 5)
	forvalues i = 1/5 {
		preserve
			qui keep if `strlen' == `i'
			if `i' == 5 {
				qui merge m:1 _cae_str using "`temp'", gen(`_merge')
				qui drop if `_merge' == 2
				qui gen long _valid_cae_`rev' = 10000 if `_merge' == 3
				qui replace _valid_cae_`rev' = 200000 if `_merge' == 1
				qui drop `_merge'
				tempfile temp`i'
				qui save "`temp`i''", replace
			}
			else {
			    * merge on the original code
				qui merge m:1 _cae_str using "`temp'", gen(`_merge')						
				qui drop if `_merge'== 2
				qui rename `_merge' `_m1'
				qui replace _cae_str = "0" + _cae_str
				* merge on the code preceeded by a 0
				qui merge m:1 _cae_str using "`temp'", gen(`_merge')						
				qui drop if `_merge' == 2
				qui rename `_merge' `_m2'
				* valid at i digits only
				qui gen long _valid_cae_`rev' = 1 * (10 ^ (`i' - 1)) ///
					if (`_m1' == 3 & `_m2' == 1) 
				* valid at i + 1 digits (0 + i digits)
				qui replace _valid_cae_`rev' = 2 * (10 ^ (`i' - 1)) ///
					if (`_m1' == 1 & `_m2' == 3)
				* valid at i digits only or i + 1 digits (0 + i digits)
				qui replace _valid_cae_`rev' = 3 * (10 ^ (`i' - 1)) ///
					if (`_m1' == 3 & `_m2' == 3) 
				* invalid
				qui replace _valid_cae_`rev' = 200000 if (`_m1' == 1 & `_m2' == 1) 
				qui drop `_m1' `_m2'
				qui replace _cae_str = substr(_cae_str,2,.)
				tempfile temp`i'
				qui save "`temp`i''", replace
			}
		restore
	}

	clear
	forvalues i = 1/5 {
		qui append using "`temp`i''"
	}
	
	
	if "`dropzero'" == "dropzero" {
		cap assert _valid_cae_`rev' != 200000
		if _rc {
			tempfile zerodropfile
			qui savesome if (_valid_cae_`rev' == 200000 & /// 
				substr(_cae_str,-1,1) == "0" & `strlen' > 1) ///
				using `"`zerodropfile'"', replace
			qui drop if (_valid_cae_`rev' == 200000 & ///
				substr(_cae_str,-1,1) == "0" & `strlen' > 1)
			preserve
				data_dropzero2, file1(`zerodropfile') file2(`temp') rev(`rev')
			restore
			qui append using `"`zerodropfile'"'
		}
	}
	
	qui append using "`tempmiss'"
	qui replace _valid_cae_`rev' = 0 if missing(_valid_cae_`rev')
	
	qui append using "`tempinvalidlength'"
	qui replace _valid_cae_`rev' = 200000 if missing(_valid_cae_`rev')


	label define validlabel`rev' 0 "0 - Missing" 2 "2 - 2d(0+1)" ///
		10 "10 - 2d" 20 "20 - 3d(0+2)" 30 "30 - 2d or 3d(0+2)" ///
		100 "100 - 3d" 200 "200 - 4d(0+3)" 300 "300 - 3d or 4d(0+3)" ///
		1000 "1000 - 4d" 2000 "2000 - 5d(0+4)" 3000 "3000 - 4d or 5d(0+4)" ///
		10000 "10000 - 5d" 200000 "200000 - Invalid" 
							
		
	if "`dropzero'" == "dropzero" {
		addlabel, rev(`rev')
	}
	
	if trim("`solvevar'") != "" {
	    solve_valid _cae_str if inlist(_valid_cae_`rev', 30, 300, 3000), ///
			solvevar(`solvevar') valid(_valid_cae_`rev') th(`solveth')  ///
			`eng' file(`temp')
	} 
}

					
label values _valid_cae_`rev' validlabel`rev'

di
di as text "***************************"
di as text "*******" as result " Valid codes " as text "*******"
di as text "***************************"
tab _valid_cae_`rev'

cap drop rev
cap drop _des_pt
cap drop _des_en
cap drop _cae_num



if "`getlevels'" != "" {
	getlevelsparser, getlevels(`getlevels')
	local levels = "`r(levels)'"
	local en = "`r(en)'"
	local force = "`r(force)'"
	foreach item in `levels' {
		local levelscount: word count `levels'
		if `rev' == 3 {
			if `levelscount' > 5 {
				di as error "CAE Rev. 3 only admits 5 levels"
				error 198
			}
			if ("`item'" != "1" & "`item'" != "2" & "`item'" != "3" &  /// 
				"`item'" != "4" & "`item'" != "5") {
				di as error "CAE Rev. 3 only admits 5 values for levels: "///
					"1, 2, 3, 4 and 5"
				error 198
			}
		}
		else {
			if `levelscount' > 6 {
				di as error "CAE Rev. `rev' only admits 6 levels"
				error 198
			}
			if ("`item'" != "1" & "`item'" != "2" & "`item'" != "3" & ///
				"`item'" != "4" & "`item'" != "5" & "`item'" != "6") {
				di as error "CAE Rev. `rev' only admits 6 values for " ///
					"levels: 1, 2, 3, 4, 5 and 6"
				error 198
			}
		}
	}

	if `rev' == 1 {
		validarcae_div1 `varlist', file(`temp') levels(`levels') `keep' `en'
	}
	else if `rev' == 2 {
		validarcae_div2 `varlist', file(`temp') levels(`levels') `keep' `en' ///
			`force' `_solved'
	}
	else if `rev' == 21 {
		validarcae_div21 `varlist', file(`temp') levels(`levels') `keep' `en' ///
			`force' `_solved'
	}
	else {
		validarcae_div3 `varlist', file(`temp') levels(`levels') `keep' `en' ///
			`force' `_solved'
	}
	qui count if inlist(_valid_cae_`rev', 30, 300, 3000)
	if `r(N)' {
		di 
		di as result "`r(N)' " as text "codes not converted due to " ///
			"ambiguities"
	}
	if "`keep'" != "keep" {
		cap drop _cae_str
	}
}
else {
	if "`keep'" != "keep" {
		cap drop _cae_str
	}
	else {
		if inlist(`rev', 2, 21, 3){
		    if trim("`solvevar'") == "" {
				qui replace _cae_str = "0" + _cae_str if ///
					inlist(_valid_cae_`rev', 2, 20, 200, 2000)
			}
			else {
				qui replace _cae_str = "0" + _cae_str if ///
					inlist(_valid_cae_`rev', 2, 20, 200, 2000) & _solved != 1			    
			}
		}	
	}
}

if ("`if'" != "") {
	qui append using "`tempifnot'"
}

qui sort `sortvar'
cap drop `sortvar'

qui compress _valid_cae_`rev'
cap compress _cae_str

end


program define solve_valid

syntax varlist [if], valid(str) solvevar(str) file(str) [th(real 0.5) eng]

tempvar len

if "`eng'" == "eng" {
	validarcae_solve `varlist' `if', ///
		vardesc(`solvevar') file(`file') vars(_cae_str _des_en) th(`th')		
}
else {
	validarcae_solve `varlist' `if', ///
		vardesc(`solvevar') file(`file') vars(_cae_str _des_pt) th(`th')		
}
qui replace `varlist' = _sug_code `if' & _solved == 1
qui drop _sug_code
qui gen `len' = length(`varlist') `if'

qui replace `valid' = 10 if `valid' == 30 & `len' == 2 & _solved == 1
qui replace `valid' = 20 if `valid' == 30 & `len' == 3 & _solved == 1
qui replace `valid' = 100 if `valid' == 300 & `len' == 3 & _solved == 1
qui replace `valid' = 200 if `valid' == 300 & `len' == 4 & _solved == 1
qui replace `valid' = 1000 if `valid' == 3000 & `len' == 4 & _solved == 1
qui replace `valid' = 2000 if `valid' == 3000 & `len' == 5 & _solved == 1

qui count if _solved == 1
di 
di as result "`r(N)'" as text " ambiguities solved using variable " ///
	as result "`solvevar'" as text " and threshold " as result "`th'"

qui drop `len'

tab _solved 

end


program define parse_solve, rclass

syntax, solve(string)

cap which ustrdist
if _rc {
	di as error "Option solve requires command ustrdist"
	exit _rc
}
gettoken solvevar solveopt: solve, p(",")
gettoken lixo solveopt: solveopt, p(",")
local solveopt = trim("`solveopt'")
confirm var `solvevar'
if "`solveopt'" == "" {
	local solveth 0.5
}
else {
	if strpos("`solveopt'", "en") {
		local eng "eng"
		local solveth = trim(subinstr("`solveopt'", "en", "", 1))
		if "`solveth'" == "" {
			local solveth 0.5
		}
	}
	else {
		local solveopt = trim("`solveopt'")
		local solveth `solveopt'
	}
}
if `solveth' > 1 | `solveth' < 0 {
	di as error "Threshold for solving ambiguities must be between 0 and 1"
	exit 198
}
local _solved "_solv"

return local solvevar `solvevar'
return local solveth `solveth'
return local _solved `_solved'
return local eng `eng'

end


program define data_dropzero2


syntax, file1(string) file2(string) [rev(int 3)]

qui use `"`file1'"', clear

qui clonevar _cae_str_original = _cae_str

tempvar _merge _m1 _m2

quietly count
local j = 1
cap drop _zerosdropped
qui gen byte _zerosdropped = 0
while r(N) {
	tempvar len`j'
	qui gen `len`j'' = length(_cae_str)
	qui replace _cae_str = substr(_cae_str,1,`len`j'' - 1)
	qui replace `len`j'' = length(_cae_str)
	qui sum `len`j''
	local maxlen = r(max)
	qui replace _zerosdropped = _zerosdropped + 1
	forvalues i = 1/`maxlen' {
		preserve
			qui keep if `len`j'' == `i'
			* merge on the original code
			qui merge m:1 _cae_str using `"`file2'"', gen(`_merge')						
			qui drop if `_merge' == 2
			qui rename `_merge' `_m1'
			qui replace _cae_str = "0" + _cae_str
			* merge on the code preceeded by a 0
			qui merge m:1 _cae_str using `"`file2'"', gen(`_merge')						
			qui drop if `_merge' == 2
			qui rename `_merge' `_m2'
			* valid at i digits only
			qui gen long _valid_cae_`rev'_`j' = 1 * (10 ^ (`i' - 1)) if ///
				(`_m1' == 3 & `_m2' == 1)
			* valid at i + 1 digits (0 + i digits)
			qui replace _valid_cae_`rev'_`j' = 2 * (10 ^ (`i' - 1)) if ///
				(`_m1' == 1 & `_m2' == 3) 
			* valid at i digits only or i + 1 digits (0 + i digits)
			qui replace _valid_cae_`rev'_`j' = 3 * (10 ^ (`i' - 1)) if ///
				(`_m1' == 3 & `_m2' == 3) 
			* invalid
			qui replace _valid_cae_`rev'_`j' = 200000 if (`_m1' == 1 & `_m2' == 1) 
			qui drop `_m1' `_m2'
			qui replace _cae_str = substr(_cae_str,2,.)
			tempfile tempzero`i'
			qui save "`tempzero`i''", replace
		restore
	}
	
	clear
	forvalues i = 1/`maxlen' {
		qui append using "`tempzero`i''"
	}
	tempfile datazero`j'
	qui savesome if (substr(_cae_str,-1,1) != "0" | `len`j'' == 1) using ///
		`"`datazero`j''"', replace
	qui drop if (substr(_cae_str,-1,1) != "0" | `len`j'' == 1)
	quietly count
	local j = `j' + 1
}

local j = `j' - 1
clear
forvalues k = 1/`j' {
	qui append using `"`datazero`k''"'
}

forvalues k = 1/`j' {
	qui drop `len`k''
}

tempvar total_valid
qui egen `total_valid' = rowtotal(_valid_cae_`rev'_*)
qui replace _valid_cae_`rev' = `total_valid'
qui drop `total_valid'
qui replace _valid_cae_`rev' = 200000 if mod(_valid_cae_`rev',200000) == 0
qui replace _valid_cae_`rev' = mod(_valid_cae_`rev',200000) if ///
	mod(_valid_cae_`rev',200000) != 0
qui drop _valid_cae_`rev'_*
qui drop _cae_str
qui rename _cae_str_original _cae_str
quietly {
	replace _cae_str = "0" + substr(_cae_str,1,1) if (_valid_cae_`rev' == 2)
	replace _cae_str = substr(_cae_str,1,2) if (_valid_cae_`rev' == 10)
	replace _cae_str = "0" + substr(_cae_str,1,2) if (_valid_cae_`rev' == 20)
	replace _cae_str = substr(_cae_str,1,3) if (_valid_cae_`rev' == 100)
	replace _cae_str = "0" + substr(_cae_str,1,3) if (_valid_cae_`rev' == 200)
	replace _cae_str = substr(_cae_str,1,4) if (_valid_cae_`rev' == 1000)
	replace _cae_str = "0" + substr(_cae_str,1,4) if (_valid_cae_`rev' == 2000)
}

qui save `"`file1'"', replace


end


program define data_dropzero1


syntax, file1(string) file2(string) [rev(int 3)]

qui use `"`file1'"', clear

qui clonevar _cae_str_original = _cae_str

tempvar _merge

quietly count
local j = 1
cap drop _zerodropped
qui gen byte _zerosdropped = 0
while r(N) {
	tempvar len`j'
	qui gen `len`j'' = length(_cae_str)
	qui replace _cae_str = substr(_cae_str,1,`len`j'' - 1)
	qui replace `len`j'' = length(_cae_str)
	qui sum `len`j''
	local maxlen = r(max)
	qui replace _zerosdropped = _zerosdropped + 1
	forvalues i = 1/`maxlen' {
		preserve
			qui keep if `len`j'' == `i'
			qui merge m:1 _cae_str using `"`file2'"', gen(`_merge')
			qui drop if `_merge' == 2
			qui gen long _valid_cae_`rev'_`j' = 10 ^ (`i' - 1) if `_merge' == 3
			qui replace _valid_cae_`rev'_`j' = 200000 if `_merge' == 1
			qui drop `_merge'
			tempfile tempzero`i'
			qui save "`tempzero`i''", replace
		restore
	}
	clear
	forvalues i = 1/`maxlen' {
		qui append using "`tempzero`i''"
	}
	tempfile datazero`j'
	qui savesome if (substr(_cae_str,-1,1) != "0" | `len`j'' == 1) using ///
		`"`datazero`j''"', replace
	qui drop if (substr(_cae_str,-1,1) != "0" | `len`j'' == 1)
	quietly count
	local j = `j' + 1
}

local j = `j' - 1
clear
forvalues k = 1/`j' {
	qui append using `"`datazero`k''"'
}

forvalues k = 1/`j' {
	qui drop `len`k''
}

tempvar total_valid
qui egen `total_valid' = rowtotal(_valid_cae_`rev'_*)
qui replace _valid_cae_`rev' = `total_valid'
qui drop `total_valid'
qui replace _valid_cae_`rev' = 200000 if mod(_valid_cae_`rev',200000) == 0
qui replace _valid_cae_`rev' = mod(_valid_cae_`rev',200000) if ///
	mod(_valid_cae_`rev',200000) != 0
qui drop _valid_cae_`rev'_*
qui drop _cae_str
qui rename _cae_str_original _cae_str
quietly {
	replace _cae_str = substr(_cae_str,1,1) if (_valid_cae_`rev' == 1)
	replace _cae_str = substr(_cae_str,1,2) if (_valid_cae_`rev' == 10)
	replace _cae_str = substr(_cae_str,1,3) if (_valid_cae_`rev' == 100)
	replace _cae_str = substr(_cae_str,1,4) if (_valid_cae_`rev' == 1000)
	replace _cae_str = substr(_cae_str,1,5) if (_valid_cae_`rev' == 10000)
}

qui save `"`file1'"', replace
	
	
end


program define getlevelsparser, rclass


syntax, getlevels(string)

local pos = strpos(`"`getlevels'"',",")
if `pos' == 0 {
	return local levels = `"`getlevels'"'
	return local force = ""
	return local en = ""
}
else {
	local first = substr(`"`getlevels'"',1,`pos'-1)
	return local levels = `"`first'"'
	local second = substr(`"`getlevels'"',`pos'+1,.)
	if strpos(`"`second'"',"en") {
		return local en = "en"
	}
	else {
		return local en = ""
	}
	if strpos(`"`second'"',"force") {
		return local force = "force"
	}
	else {
		return local force = ""
	}
}

end


program define addlabel

syntax, [rev(int 3)]

if `rev' == 1 {
	label define validlabel`rev' 11 "11 - 1d | 2d " ///
		 101 "101 - 1d | 3d " ///
		 110 "110 - 2d | 3d " ///
		 111 "111 - 1d | 2d | 3d " ///
		 1001 "1001 - 1d | 4d " ///
		 1010 "1010 - 2d | 4d " ///
		 1011 "1011 - 1d | 2d | 4d " ///
		 1100 "1100 - 3d | 4d " ///
		 1101 "1101 - 1d | 3d | 4d " ///
		 1110 "1110 - 2d | 3d | 4d " ///
		 1111 "1111 - 1d | 2d | 3d | 4d " ///
		 10001 "10001 - 1d | 5d " ///
		 10010 "10010 - 2d | 5d " ///
		 10011 "10011 - 1d | 2d | 5d " ///
		 10100 "10100 - 3d | 5d " ///
		 10101 "10101 - 1d | 3d | 5d " ///
		 10110 "10110 - 2d | 3d | 5d " ///
		 10111 "10111 - 1d | 2d | 3d | 5d " ///
		 11000 "11000 - 4d | 5d " ///
		 11001 "11001 - 1d | 4d | 5d " ///
		 11010 "11010 - 2d | 4d | 5d " ///
		 11011 "11011 - 1d | 2d | 4d | 5d " ///
		 11100 "11100 - 3d | 4d | 5d " ///
		 11101 "11101 - 1d | 3d | 4d | 5d " ///
		 11110 "11110 - 2d | 3d | 4d | 5d " ///
		 11111 "11111 - 1d | 2d | 3d | 4d | 5d ", add
}
else {
	label define validlabel`rev' 12 "12 - 2d(0+1) | 2d" ///
		 22 "22 - 2d(0+1) | 3d(0+2)" ///
		 32 "32 - 2d(0+1) | 2d or 3d(0+2)" ///
		 102 "102 - 2d(0+1) | 3d" ///
		 110 "110 - 2d | 3d" ///
		 112 "112 - 2d(0+1) | 2d | 3d" ///
		 120 "120 - 3d(0+2) | 3d" ///
		 122 "122 - 2d(0+1) | 3d(0+2) | 3d" ///
		 130 "130 - 2d or 3d(0+2) | 3d" ///
		 132 "132 - 2d(0+1) | 2d or 3d(0+2) | 3d" ///
		 202 "202 - 2d(0+1) | 4d(0+3)" ///
		 210 "210 - 2d | 4d(0+3)" ///
		 212 "212 - 2d(0+1) | 2d | 4d(0+3)" ///
		 220 "220 - 3d(0+2) | 4d(0+3)" ///
		 222 "222 - 2d(0+1) | 3d(0+2) | 4d(0+3)" ///
		 230 "230 - 2d or 3d(0+2) | 4d(0+3)" ///
		 232 "232 - 2d(0+1) | 2d or 3d(0+2) | 4d(0+3)" ///
		 302 "302 - 2d(0+1) | 3d or 4d(0+3)" ///
		 310 "310 - 2d | 3d or 4d(0+3)" ///
		 312 "312 - 2d(0+1) | 2d | 3d or 4d(0+3)" ///
		 320 "320 - 3d(0+2) | 3d or 4d(0+3)" ///
		 322 "322 - 2d(0+1) | 3d(0+2) | 3d or 4d(0+3)" ///
		 330 "330 - 2d or 3d(0+2) | 3d or 4d(0+3)" ///
		 332 "332 - 2d(0+1) | 2d or 3d(0+2) | 3d or 4d(0+3)" ///
		 1002 "1002 - 2d(0+1) | 4d" ///
		 1010 "1010 - 2d | 4d" ///
		 1012 "1012 - 2d(0+1) | 2d | 4d" ///
		 1020 "1020 - 3d(0+2) | 4d" ///
		 1022 "1022 - 2d(0+1) | 3d(0+2) | 4d" ///
		 1030 "1030 - 2d or 3d(0+2) | 4d" ///
		 1032 "1032 - 2d(0+1) | 2d or 3d(0+2) | 4d" ///
		 1100 "1100 - 3d | 4d" ///
		 1102 "1102 - 2d(0+1) | 3d | 4d" ///
		 1110 "1110 - 2d | 3d | 4d" ///
		 1112 "1112 - 2d(0+1) | 2d | 3d | 4d" ///
		 1120 "1120 - 3d(0+2) | 3d | 4d" ///
		 1122 "1122 - 2d(0+1) | 3d(0+2) | 3d | 4d" ///
		 1130 "1130 - 2d or 3d(0+2) | 3d | 4d" ///
		 1132 "1132 - 2d(0+1) | 2d or 3d(0+2) | 3d | 4d" ///
		 1200 "1200 - 4d(0+3) | 4d" ///
		 1202 "1202 - 2d(0+1) | 4d(0+3) | 4d" ///
		 1210 "1210 - 2d | 4d(0+3) | 4d" ///
		 1212 "1212 - 2d(0+1) | 2d | 4d(0+3) | 4d" ///
		 1220 "1220 - 3d(0+2) | 4d(0+3) | 4d" ///
		 1222 "1222 - 2d(0+1) | 3d(0+2) | 4d(0+3) | 4d" ///
		 1230 "1230 - 2d or 3d(0+2) | 4d(0+3) | 4d" ///
		 1232 "1232 - 2d(0+1) | 2d or 3d(0+2) | 4d(0+3) | 4d" ///
		 1300 "1300 - 3d or 4d(0+3) | 4d" ///
		 1302 "1302 - 2d(0+1) | 3d or 4d(0+3) | 4d" ///
		 1310 "1310 - 2d | 3d or 4d(0+3) | 4d" ///
		 1312 "1312 - 2d(0+1) | 2d | 3d or 4d(0+3) | 4d" ///
		 1320 "1320 - 3d(0+2) | 3d or 4d(0+3) | 4d" ///
		 1322 "1322 - 2d(0+1) | 3d(0+2) | 3d or 4d(0+3) | 4d" ///
		 1330 "1330 - 2d or 3d(0+2) | 3d or 4d(0+3) | 4d" ///
		 1332 "1332 - 2d(0+1) | 2d or 3d(0+2) | 3d or 4d(0+3) | 4d" ///
		 2002 "2002 - 2d(0+1) | 5d(0+4)" ///
		 2010 "2010 - 2d | 5d(0+4)" ///
		 2012 "2012 - 2d(0+1) | 2d | 5d(0+4)" ///
		 2020 "2020 - 3d(0+2) | 5d(0+4)" ///
		 2022 "2022 - 2d(0+1) | 3d(0+2) | 5d(0+4)" ///
		 2030 "2030 - 2d or 3d(0+2) | 5d(0+4)" ///
		 2032 "2032 - 2d(0+1) | 2d or 3d(0+2) | 5d(0+4)" ///
		 2100 "2100 - 3d | 5d(0+4)" ///
		 2102 "2102 - 2d(0+1) | 3d | 5d(0+4)" ///
		 2110 "2110 - 2d | 3d | 5d(0+4)" ///
		 2112 "2112 - 2d(0+1) | 2d | 3d | 5d(0+4)" ///
		 2120 "2120 - 3d(0+2) | 3d | 5d(0+4)" ///
		 2122 "2122 - 2d(0+1) | 3d(0+2) | 3d | 5d(0+4)" ///
		 2130 "2130 - 2d or 3d(0+2) | 3d | 5d(0+4)" ///
		 2132 "2132 - 2d(0+1) | 2d or 3d(0+2) | 3d | 5d(0+4)" ///
		 2200 "2200 - 4d(0+3) | 5d(0+4)" ///
		 2202 "2202 - 2d(0+1) | 4d(0+3) | 5d(0+4)" ///
		 2210 "2210 - 2d | 4d(0+3) | 5d(0+4)" ///
		 2212 "2212 - 2d(0+1) | 2d | 4d(0+3) | 5d(0+4)" ///
		 2220 "2220 - 3d(0+2) | 4d(0+3) | 5d(0+4)" ///
		 2222 "2222 - 2d(0+1) | 3d(0+2) | 4d(0+3) | 5d(0+4)" ///
		 2230 "2230 - 2d or 3d(0+2) | 4d(0+3) | 5d(0+4)" ///
		 2232 "2232 - 2d(0+1) | 2d or 3d(0+2) | 4d(0+3) | 5d(0+4)" ///
		 2300 "2300 - 3d or 4d(0+3) | 5d(0+4)" ///
		 2302 "2302 - 2d(0+1) | 3d or 4d(0+3) | 5d(0+4)" ///
		 2310 "2310 - 2d | 3d or 4d(0+3) | 5d(0+4)" ///
		 2312 "2312 - 2d(0+1) | 2d | 3d or 4d(0+3) | 5d(0+4)" ///
		 2320 "2320 - 3d(0+2) | 3d or 4d(0+3) | 5d(0+4)" ///
		 2322 "2322 - 2d(0+1) | 3d(0+2) | 3d or 4d(0+3) | 5d(0+4)" ///
		 2330 "2330 - 2d or 3d(0+2) | 3d or 4d(0+3) | 5d(0+4)" ///
		 2332 "2332 - 2d(0+1) | 2d or 3d(0+2) | 3d or 4d(0+3) | 5d(0+4)" ///
		 3002 "3002 - 2d(0+1) | 4d or 5d(0+4)" ///
		 3010 "3010 - 2d | 4d or 5d(0+4)" ///
		 3012 "3012 - 2d(0+1) | 2d | 4d or 5d(0+4)" ///
		 3020 "3020 - 3d(0+2) | 4d or 5d(0+4)" ///
		 3022 "3022 - 2d(0+1) | 3d(0+2) | 4d or 5d(0+4)" ///
		 3030 "3030 - 2d or 3d(0+2) | 4d or 5d(0+4)" ///
		 3032 "3032 - 2d(0+1) | 2d or 3d(0+2) | 4d or 5d(0+4)" ///
		 3100 "3100 - 3d | 4d or 5d(0+4)" ///
		 3102 "3102 - 2d(0+1) | 3d | 4d or 5d(0+4)" ///
		 3110 "3110 - 2d | 3d | 4d or 5d(0+4)" ///
		 3112 "3112 - 2d(0+1) | 2d | 3d | 4d or 5d(0+4)" ///
		 3120 "3120 - 3d(0+2) | 3d | 4d or 5d(0+4)" ///
		 3122 "3122 - 2d(0+1) | 3d(0+2) | 3d | 4d or 5d(0+4)" ///
		 3130 "3130 - 2d or 3d(0+2) | 3d | 4d or 5d(0+4)" ///
		 3132 "3132 - 2d(0+1) | 2d or 3d(0+2) | 3d | 4d or 5d(0+4)" ///
		 3200 "3200 - 4d(0+3) | 4d or 5d(0+4)" ///
		 3202 "3202 - 2d(0+1) | 4d(0+3) | 4d or 5d(0+4)" ///
		 3210 "3210 - 2d | 4d(0+3) | 4d or 5d(0+4)" ///
		 3212 "3212 - 2d(0+1) | 2d | 4d(0+3) | 4d or 5d(0+4)" ///
		 3220 "3220 - 3d(0+2) | 4d(0+3) | 4d or 5d(0+4)" ///
		 3222 "3222 - 2d(0+1) | 3d(0+2) | 4d(0+3) | 4d or 5d(0+4)" ///
		 3230 "3230 - 2d or 3d(0+2) | 4d(0+3) | 4d or 5d(0+4)" ///
		 3232 "3232 - 2d(0+1) | 2d or 3d(0+2) | 4d(0+3) | 4d or 5d(0+4)" ///
		 3300 "3300 - 3d or 4d(0+3) | 4d or 5d(0+4)" ///
		 3302 "3302 - 2d(0+1) | 3d or 4d(0+3) | 4d or 5d(0+4)" ///
		 3310 "3310 - 2d | 3d or 4d(0+3) | 4d or 5d(0+4)" ///
		 3312 "3312 - 2d(0+1) | 2d | 3d or 4d(0+3) | 4d or 5d(0+4)" ///
		 3320 "3320 - 3d(0+2) | 3d or 4d(0+3) | 4d or 5d(0+4)" ///
		 3322 "3322 - 2d(0+1) | 3d(0+2) | 3d or 4d(0+3) | 4d or 5d(0+4)" ///
		 3330 "3330 - 2d or 3d(0+2) | 3d or 4d(0+3) | 4d or 5d(0+4)" ///
		 3332 "3332 - 2d(0+1) | 2d or 3d(0+2) | 3d or 4d(0+3) | 4d or 5d(0+4)", add
}

end
