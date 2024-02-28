*! version 0.6 28Feb2024
* Programmed by Gustavo Iglésias

program define coconuts, sortpreserve

version 15

syntax [varlist(default=none)] [if], [ ///
	versions                           ///
	nuts(int 2024)                     ///
	levels(numlist >=1<=3 int asc)     ///
	keep                               ///  
	RECode                             ///
	replace                            ///
	NOnuts                             ///
	GENerate(name)                     ///
	tostring                           ///
]

di

* Get file path
mata: st_local("file_corresp", findfile("coconuts_final.dta"))


* Option versions
if "`versions'" == "versions" {
    preserve
		quietly {
		    tempvar nn
			use "`file_corresp'", clear
			keep init_date* final_date*
			keep if _n == 1
			gen `nn' = 1
			reshape long init_date final_date, i(`nn') j(nuts)
			drop `nn'
			sort nuts
		}
		di
		di as text "Correspondence between nuts and time period"
		list, noobs ab(15) sep(1000)
		di
	restore
}
* Create only a new variable for municipality with recoded codes
if "`nonuts'" == "nonuts" {
    if "`recode'" != "recode" {
	    di "{err:must specify {bf:recode} option}"
		exit 198
	}
    if "`generate'" == "" {
	    di "{err:must specify {bf:generate} option}"
		exit 198
	}
    cap confirm var `generate' 
	if !_rc {
	    di "{err:variable {bf:`generate'} already defined}"
		exit 110
	}
	tempname genvallab
	qui clonevar `generate' = `varlist'
	local vtype: type `generate'
	recode_var `generate', vtype(`vtype')
	// Get value labels
	preserve
	quietly {
		use "`file_corresp'", clear
		label save conc_lab using `genvallab', replace
	}	 
	restore
	qui do `genvallab'
	rm `genvallab'.do
	label values `generate' conc_lab
}
* Convert to nuts 
else if ("`nonuts'" != "nonuts" & "`varlist'" != "") {
	* Errors
	local varcount: word count `varlist'
	if `varcount' > 1 error 103

	if !(inlist(`nuts', 1986, 1989, 1998, 1999, 2001, 2002, 2013, 2024)) {
		di as error "Invalid NUTS Classification. Possible values are: " ///
					"1986, 1989, 1998, 1999, 2001, 2002, 2013 and 2024"
		exit 198
	}

	forvalues i = 1/3 {
		cap confirm var nuts`i'_v`nuts'
		if !_rc & "`replace'" == "" {
			di "{err:Variable(s) {bf:nuts#_v`nuts'} (# = 1, 2 or 3) already defined}"
			di "{err:Please specify option {bf:replace} to drop these variables}"
			exit 110
		}
		else {
			cap drop nuts`i'_v`nuts'
		}
	}


	cap drop _match_`nuts'
	cap label drop _matchlab

	tempvar nn
	tempfile iffile
	marksample touse

	if "`levels'" == "" {
		local levels 1 2 3
	}
	if "`if'" != "" {
		preserve
			qui keep if `touse' == 0
			qui save `iffile', replace
		restore
		qui drop if `touse' == 0
		get_nuts `varlist', file("`file_corresp'") nuts(`nuts') levels(`levels') ///
		                   `keep' `recode' gen(`generate') `tostring'
		qui append using `iffile'
	}
	else {
		get_nuts `varlist', file("`file_corresp'") nuts(`nuts') levels(`levels') ///
		                   `keep' `recode' gen(`generate') `tostring'
	}
		

}

end


program define get_nuts


syntax varlist(min=1 max=1), [ ///
	file(string)               ///
	nuts(int 2024)             ///
	levels(numlist)            ///
	keep                       ///
	recode                     ///
	GENerate(name)             ///
	tostring                   ///
]

tempfile _temp_
tempvar conc _merge_ nmiss

local var "`varlist'"
local vartype: type `var'

* Create temp file used to convert municipality to nuts
preserve
	quietly {
		use "`file'", clear
		clonevar `conc' = __conc__
		keep `conc' init_date`nuts' final_date`nuts' nuts*`nuts'
		local init_per: display %td init_date`nuts'[1]
		local final_per: display %td final_date`nuts'[1]
		drop init_date`nuts' final_date`nuts'
		egen `nmiss' = rowmiss(*)
		keep if `nmiss' == 0
		drop `nmiss'
		qui save `_temp_', replace
	}
restore

di as text "Variable `var' is `vartype'"
di 
di as text "Using NUTS `nuts' - Applicable time period:" ///
           " `init_per' - `final_per'"
di

* Allways use the numerical version
if substr("`vartype'", 1, 3) == "str" {
	qui destring `var', gen(`conc')
}
else {
	qui clonevar `conc' = `var'
}

* Recode variable if specified by the user
if ("`recode'" == "recode") recode_var `conc', vtype("`vartype'")

* Get nuts codes from temp file
foreach num in `levels' {
    local nutsvars = "`nutsvars'" + " nuts`num'_v`nuts'"
}
qui merge m:1 `conc' using `_temp_', keepusing(`nutsvars') gen(`_merge_')
qui drop if `_merge_' == 2

* Tab matched values
qui replace `_merge_' = -1 if missing(`conc')
qui replace `_merge_' = 0 if `_merge_' == 1
qui replace `_merge_' = 1 if `_merge_' == 3
label define _matchlab -1 "-1 - Missing" 0 "0 - Not matched" 1 "1 - Matched"
label values `_merge_' _matchlab
label var `_merge_' "Matched - v`nuts'"
tab `_merge_'

if "`keep'" == "keep" {
	rename `_merge_' _match_`nuts'
}
else {
    drop `_merge_'
	label drop _matchlab
}

* Generate recoded variable if specified by the user
if ("`recode'" == "recode" & "`generate'" != "") {
    cap confirm var `generate' 
	if !_rc {
	    di "{err:variable {bf:`generate'} already defined}"
		exit 110
	}
    rename `conc' `generate'
	label values `generate' conc_lab
}

* Label NUTS variables and change to string type if specified by the user (only
* applies to NUTS3 - 2002 and 2013, and NUTS2/3 - 2024)
foreach num in `levels' {
    label var nuts`num'_v`nuts' "NUTS `nuts' - Level `num'"
	if "`tostring'" == "tostring" {
	    if ((`nuts' == 2002 | `nuts' == 2013) & `num' == 3) | (`nuts' == 2024 & inlist(`num', 2, 3)) {
		    qui decode nuts`num'_v`nuts', gen(nuts`num'_v`nuts'_str)
			qui replace nuts`num'_v`nuts'_str = word(nuts`num'_v`nuts'_str, 1)
		}
	}
}

end


program define recode_var

syntax varlist(min=1 max=1), vtype(string)

if substr("`vtype'", 1, 3) == "str" {
	qui replace `varlist' = "3101" if `varlist' == "2201"
	qui replace `varlist' = "3102" if `varlist' == "2202"
	qui replace `varlist' = "3103" if `varlist' == "2203"
	qui replace `varlist' = "3104" if `varlist' == "2204"
	qui replace `varlist' = "3105" if `varlist' == "2205"
	qui replace `varlist' = "3106" if `varlist' == "2206"
	qui replace `varlist' = "3107" if `varlist' == "2208"
	qui replace `varlist' = "3108" if `varlist' == "2209"
	qui replace `varlist' = "3109" if `varlist' == "2210"
	qui replace `varlist' = "3110" if `varlist' == "2211"
	qui replace `varlist' = "3201" if `varlist' == "2207"
	qui replace `varlist' = "4101" if `varlist' == "2107"
	qui replace `varlist' = "4201" if `varlist' == "2101"
	qui replace `varlist' = "4202" if `varlist' == "2102"
	qui replace `varlist' = "4203" if `varlist' == "2103"
	qui replace `varlist' = "4204" if `varlist' == "2104"
	qui replace `varlist' = "4205" if `varlist' == "2105"
	qui replace `varlist' = "4206" if `varlist' == "2106"
	qui replace `varlist' = "4301" if `varlist' == "1901"
	qui replace `varlist' = "4302" if `varlist' == "1905"
	qui replace `varlist' = "4401" if `varlist' == "1903"
	qui replace `varlist' = "4501" if `varlist' == "1902"
	qui replace `varlist' = "4502" if `varlist' == "1904"
	qui replace `varlist' = "4601" if `varlist' == "2004"
	qui replace `varlist' = "4602" if `varlist' == "2005"
	qui replace `varlist' = "4603" if `varlist' == "2007"
	qui replace `varlist' = "4701" if `varlist' == "2002"
	qui replace `varlist' = "4801" if `varlist' == "2003"
	qui replace `varlist' = "4802" if `varlist' == "2006"
	qui replace `varlist' = "4901" if `varlist' == "2001"  
}
else {
	qui recode `varlist' (2201=3101) (2202=3102) (2203=3103) (2204=3104) ///
	                     (2205=3105) (2206=3106) (2208=3107) (2209=3108) /// 
						 (2210=3109) (2211=3110) (2207=3201) (2107=4101) ///
						 (2101=4201) (2102=4202) (2103=4203) (2104=4204) ///
						 (2105=4205) (2106=4206) (1901=4301) (1905=4302) ///
						 (1903=4401) (1902=4501) (1904=4502) (2004=4601) ///
						 (2005=4602) (2007=4603) (2002=4701) (2003=4801) ///
						 (2006=4802) (2001=4901) 
}



end
