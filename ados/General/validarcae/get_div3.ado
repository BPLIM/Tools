program define get_div3

syntax varlist, [file(string) levels(string) fl fr cfl en] namevar(string) 

cap drop rev3_*

preserve
	qui use "`file'", clear
	if "`en'" == "en" {
		qui keep _cae_num `namevar' _des_en 
		qui gen divlabel = `namevar' + " - " + _des_en
		keep _cae_num divlabel
	}
	else {
		qui keep _cae_num `namevar' _des_pt
		qui gen divlabel = `namevar' + " - " + _des_pt
		keep _cae_num divlabel
	}
	quietly count 
	local total = r(N)
	label define divlabel3 -99 "Unsuccessful conversion", add modify 
	forvalues i = 1/`total' {
		local value = _cae_num[`i']
		local label = divlabel[`i']     
		label define divlabel3 `value' `"`label'"', add modify    
	}
	qui label save divlabel3 using lixo, replace
restore

qui do lixo.do
rm lixo.do


local var "`varlist'"
tempvar vardiv

local vartype: type `var'
local vallabel: value label `var'

// decode variable if specified by the user
if "`cfl'" == "cfl" {
	qui decode `var', gen(`vardiv')
	qui replace `vardiv' = word(`vardiv',1)
}
else {
	if substr("`vartype'",1,3) == "str" {
		qui clonevar `vardiv' = `var'
	}
	else {
		qui gen `vardiv' = string(`var')
	}
}

tempvar len
qui gen `len' = length(`vardiv')

if "`fr'" == "fr" {
	cap assert !(substr(`vardiv',`len',1) == "0") // while any observation has a zero in the last char
	while _rc {
		qui replace `vardiv' = substr(`vardiv',1,`len'-1) if substr(`vardiv',`len',1) == "0"
		qui replace `len' = length(`vardiv')
		cap assert !(substr(`vardiv',`len',1) == "0")
	}
	qui replace `vardiv' = "0" if missing(`vardiv') 
	qui replace `len' = length(`vardiv')
}

qui replace `vardiv' = "0" + `vardiv' if inlist(_valid_cae_3, 12, 22, 32, 42)

if "`fl'" == "fl" {
	qui replace `vardiv' = "0" + `vardiv' if inlist(_valid_cae_3, 13, 23, 33, 43)
}

qui replace `len' = length(`vardiv')

foreach item in `levels' {
	if "`item'" == "1" {
		qui gen `namevar' = ""
		qui replace `namevar' = "A" if inlist(substr(`vardiv',1,2), "01", "02", "03")
		qui replace `namevar' = "B" if inlist(substr(`vardiv',1,2), "05", "06", "07", "08", "09")
		qui replace `namevar' = "C" if inlist(substr(`vardiv',1,2), "10", "11", "12", "13", "14", "15", "16")
		qui replace `namevar' = "C" if inlist(substr(`vardiv',1,2), "17", "18", "19", "20", "21", "22", "23") 
		qui replace `namevar' = "C" if inlist(substr(`vardiv',1,2), "24", "25", "26", "27", "28", "29", "30")
		qui replace `namevar' = "C" if inlist(substr(`vardiv',1,2), "31", "32", "33")
		qui replace `namevar' = "D" if inlist(substr(`vardiv',1,2), "35")
		qui replace `namevar' = "E" if inlist(substr(`vardiv',1,2), "36", "37", "38", "39")
		qui replace `namevar' = "F" if inlist(substr(`vardiv',1,2), "41", "42", "43")
		qui replace `namevar' = "G" if inlist(substr(`vardiv',1,2), "45", "46", "47")
		qui replace `namevar' = "H" if inlist(substr(`vardiv',1,2), "49", "50", "51", "52", "53")
		qui replace `namevar' = "I" if inlist(substr(`vardiv',1,2), "55", "56")
		qui replace `namevar' = "J" if inlist(substr(`vardiv',1,2), "58", "59", "60", "61", "62", "63")
		qui replace `namevar' = "K" if inlist(substr(`vardiv',1,2), "64", "65", "66")
		qui replace `namevar' = "L" if inlist(substr(`vardiv',1,2), "68")
		qui replace `namevar' = "M" if inlist(substr(`vardiv',1,2), "69", "70", "71", "72", "73", "74", "75")
		qui replace `namevar' = "N" if inlist(substr(`vardiv',1,2), "77", "78", "79", "80", "81", "82")
		qui replace `namevar' = "O" if inlist(substr(`vardiv',1,2), "84")
		qui replace `namevar' = "P" if inlist(substr(`vardiv',1,2), "85")
		qui replace `namevar' = "Q" if inlist(substr(`vardiv',1,2), "86", "87", "88")
		qui replace `namevar' = "R" if inlist(substr(`vardiv',1,2), "90", "91", "92", "93")
		qui replace `namevar' = "S" if inlist(substr(`vardiv',1,2), "94", "95", "96")
		qui replace `namevar' = "T" if inlist(substr(`vardiv',1,2), "97", "98")
		qui replace `namevar' = "U" if inlist(substr(`vardiv',1,2), "99")
		qui merge m:1 `namevar' using "`file'"
		qui drop if _m == 2
		qui drop _m
		qui drop _des_pt
		qui drop _des_en
		qui drop `namevar'
		qui rename _cae_num rev3_section
		//qui rename _des rev3_section_des
		//qui gen rev3_section_conv = (_valid_cae_3 != 0 & _valid_cae_3 != 99 & `len' >= 2)
		qui replace rev3_section = -99 if _valid_cae_3 == 0
		qui replace rev3_section = -99 if _valid_cae_3 == 99
		qui replace rev3_section = -99 if `len' < 2 /*
		qui replace rev3_section_des = "" if _valid_cae_3 == 0
		qui replace rev3_section_des = "" if _valid_cae_3 == 99
		qui replace rev3_section_des = "" if `len' < 2
		label define l3section 0 "Unsuccessful conversion" 1 "Successful conversion"
		label values rev3_section_conv l3section*/
		label values rev3_section divlabel3
		label var rev3_section "CAE Rev. 3 Section (Level 1)"
	}
	if "`item'" == "2" {
		qui gen str2 `namevar' = substr(`vardiv',1,2) 
		qui merge m:1 `namevar' using "`file'"
		qui drop if _m == 2
		qui drop _m
		qui drop _des_pt
		qui drop _des_en
		qui drop `namevar'
		qui rename _cae_num rev3_division
		//qui rename _des rev3_division_des
		//qui gen rev3_division_conv = (_valid_cae_3 != 0 & _valid_cae_3 != 99 & `len' >= 2)
		qui replace rev3_division = -99 if _valid_cae_3 == 0
		qui replace rev3_division = -99 if _valid_cae_3 == 99
		qui replace rev3_division = -99 if `len' < 2 /*
		qui replace rev3_division_des = "" if _valid_cae_3 == 0
		qui replace rev3_division_des = "" if _valid_cae_3 == 99
		qui replace rev3_division_des = "" if `len' < 2
		label define l3division 0 "Unsuccessful conversion" 1 "Successful conversion"
		label values rev3_division_conv l3division*/
		label values rev3_division divlabel3
		label var rev3_division "CAE Rev. 3 Division (Level 2)"
	}
	if "`item'" == "3" {
		qui gen str3 `namevar' = substr(`vardiv',1,3) 
		qui merge m:1 `namevar' using "`file'"
		qui drop if _m == 2
		qui drop _m
		qui drop _des_pt
		qui drop _des_en
		qui drop `namevar'
		qui rename _cae_num rev3_group
		//qui rename _des rev3_group_des
		//qui gen rev3_group_conv = (_valid_cae_3 != 0 & _valid_cae_3 != 99 & `len' >= 3)
		qui replace rev3_group = -99 if _valid_cae_3 == 0
		qui replace rev3_group = -99 if _valid_cae_3 == 99
		qui replace rev3_group = -99 if `len' < 3 /*
		qui replace rev3_group_des = "" if _valid_cae_3 == 0
		qui replace rev3_group_des = "" if _valid_cae_3 == 99
		qui replace rev3_group_des = "" if `len' < 3
		label define l3group 0 "Unsuccessful conversion" 1 "Successful conversion"
		label values rev3_group_conv l3group*/
		label values rev3_group divlabel3
		label var rev3_group "CAE Rev. 3 Group (Level 3)"
	}
	if "`item'" == "4" {
		qui gen str4 `namevar' = substr(`vardiv',1,4) 
		qui merge m:1 `namevar' using "`file'"
		qui drop if _m == 2
		qui drop _m
		qui drop _des_pt
		qui drop _des_en
		qui drop `namevar'
		qui rename _cae_num rev3_class
		//qui rename _des rev3_class_des
		//qui gen rev3_class_conv = (_valid_cae_3 != 0 & _valid_cae_3 != 99 & `len' >= 4)
		qui replace rev3_class = -99 if _valid_cae_3 == 0
		qui replace rev3_class = -99 if _valid_cae_3 == 99
		qui replace rev3_class = -99 if `len' < 4 /*
		qui replace rev3_class_des = "" if _valid_cae_3 == 0
		qui replace rev3_class_des = "" if _valid_cae_3 == 99
		qui replace rev3_class_des = "" if `len' < 4
		label define l3class 0 "Unsuccessful conversion" 1 "Successful conversion"
		label values rev3_class_conv l3class*/
		label values rev3_class divlabel3
		label var rev3_class "CAE Rev. 3 Class (Level 4)"
	}
	if "`item'" == "5" {
		qui clonevar `namevar' = `vardiv'
		qui merge m:1 `namevar' using "`file'"
		qui drop if _m == 2
		qui drop _m
		qui drop _des_pt
		qui drop _des_en
		qui drop `namevar'
		qui rename _cae_num rev3_subclass
		//qui rename _des rev3_subclass_des
		//qui gen rev3_subclass_conv = (_valid_cae_3 != 0 & _valid_cae_3 != 99 & `len' == 5)
		qui replace rev3_subclass = -99 if _valid_cae_3 == 0
		qui replace rev3_subclass = -99 if _valid_cae_3 == 99
		qui replace rev3_subclass = -99 if `len' < 5 /*
		qui replace rev3_subclass_des = "" if _valid_cae_3 == 0
		qui replace rev3_subclass_des = "" if _valid_cae_3 == 99
		qui replace rev3_subclass_des = "" if `len' < 5
		label define l3subclass 0 "Unsuccessful conversion" 1 "Successful conversion"
		label values rev3_subclass_conv l3subclass*/
		label values rev3_subclass divlabel3
		label var rev3_subclass "CAE Rev. 3 Subclass (Level 5)"
	}	


}

qui compress rev3_*

end
