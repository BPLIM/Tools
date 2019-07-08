program define get_div21

syntax varlist, [file(string) levels(string) fl fr cfl en] namevar(string) 


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
	label define divlabel21 -99 "Unsuccessful conversion", add modify 
	forvalues i = 1/`total' {
		local value = _cae_num[`i']
		local label = divlabel[`i']     
		label define divlabel21 `value' `"`label'"', add modify    
	}
	qui label save divlabel21 using lixo, replace
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

qui replace `vardiv' = "0" + `vardiv' if inlist(_valid_cae_21, 12, 22, 32, 42)

if "`fl'" == "fl" {
	qui replace `vardiv' = "0" + `vardiv' if inlist(_valid_cae_21, 13, 23, 33, 43)
}

qui replace `len' = length(`vardiv')

foreach item in `levels' {
	if "`item'" == "1" | "`item'" == "2" {
		qui gen `namevar' = ""
		qui replace `namevar' = "AA" if inlist(substr(`var',1,2), "01", "02")
		qui replace `namevar' = "BB" if inlist(substr(`var',1,2), "05")
		qui replace `namevar' = "CA" if inlist(substr(`var',1,2), "10", "11", "12")
		qui replace `namevar' = "CB" if inlist(substr(`var',1,2), "13", "14") 
		qui replace `namevar' = "DA" if inlist(substr(`var',1,2), "15", "16")
		qui replace `namevar' = "DB" if inlist(substr(`var',1,2), "17", "18")
		qui replace `namevar' = "DC" if inlist(substr(`var',1,2), "19")
		qui replace `namevar' = "DD" if inlist(substr(`var',1,2), "20")
		qui replace `namevar' = "DE" if inlist(substr(`var',1,2), "21", "22")
		qui replace `namevar' = "DF" if inlist(substr(`var',1,2), "23")
		qui replace `namevar' = "DG" if inlist(substr(`var',1,2), "24")
		qui replace `namevar' = "DH" if inlist(substr(`var',1,2), "25")
		qui replace `namevar' = "DI" if inlist(substr(`var',1,2), "26")
		qui replace `namevar' = "DJ" if inlist(substr(`var',1,2), "27", "28")
		qui replace `namevar' = "DK" if inlist(substr(`var',1,2), "29")	
		qui replace `namevar' = "DL" if inlist(substr(`var',1,2), "30", "31", "32", "33")
		qui replace `namevar' = "DM" if inlist(substr(`var',1,2), "34", "35")
		qui replace `namevar' = "DN" if inlist(substr(`var',1,2), "36", "37")
		qui replace `namevar' = "EE" if inlist(substr(`var',1,2), "40", "41")
		qui replace `namevar' = "FF" if inlist(substr(`var',1,2), "45")
		qui replace `namevar' = "GG" if inlist(substr(`var',1,2), "50", "51", "52")
		qui replace `namevar' = "HH" if inlist(substr(`var',1,2), "55")
		qui replace `namevar' = "II" if inlist(substr(`var',1,2), "60", "61", "62", "63", "64")
		qui replace `namevar' = "JJ" if inlist(substr(`var',1,2), "65", "66", "67")
		qui replace `namevar' = "KK" if inlist(substr(`var',1,2), "70", "71", "72", "73", "74")
		qui replace `namevar' = "LL" if inlist(substr(`var',1,2), "75")
		qui replace `namevar' = "MM" if inlist(substr(`var',1,2), "80")
		qui replace `namevar' = "NN" if inlist(substr(`var',1,2), "85")
		qui replace `namevar' = "OO" if inlist(substr(`var',1,2), "90", "91", "92", "93")
		qui replace `namevar' = "PP" if inlist(substr(`var',1,2), "95", "96", "97")
		qui replace `namevar' = "QQ" if inlist(substr(`var',1,2), "99")
		
		if "`item'" == "1" {
			cap drop rev21_section
			qui replace `namevar' = "A" if inlist(substr(`var',1,2), "AA")
			qui replace `namevar' = "B" if inlist(substr(`var',1,2), "BB")
			qui replace `namevar' = "C" if inlist(substr(`var',1,2), "CA", "CB")
			qui replace `namevar' = "D" if inlist(substr(`var',1,2), "DA", "DB", "DC", "DD", "DE", "DF", "DG")
			qui replace `namevar' = "D" if inlist(substr(`var',1,2), "DH", "DI", "DJ", "DK", "DL", "DM", "DN")
			qui replace `namevar' = "E" if inlist(substr(`var',1,2), "EE")
			qui replace `namevar' = "F" if inlist(substr(`var',1,2), "FF")
			qui replace `namevar' = "G" if inlist(substr(`var',1,2), "GG")
			qui replace `namevar' = "H" if inlist(substr(`var',1,2), "HH")
			qui replace `namevar' = "I" if inlist(substr(`var',1,2), "II")
			qui replace `namevar' = "J" if inlist(substr(`var',1,2), "JJ")
			qui replace `namevar' = "K" if inlist(substr(`var',1,2), "KK")
			qui replace `namevar' = "L" if inlist(substr(`var',1,2), "LL")
			qui replace `namevar' = "M" if inlist(substr(`var',1,2), "MM")
			qui replace `namevar' = "N" if inlist(substr(`var',1,2), "NN")
			qui replace `namevar' = "O" if inlist(substr(`var',1,2), "OO")
			qui replace `namevar' = "P" if inlist(substr(`var',1,2), "PP")
			qui replace `namevar' = "Q" if inlist(substr(`var',1,2), "QQ")
			qui merge m:1 `namevar' using "`file'"
			qui drop if _m == 2
			qui drop _m
			qui drop _des_pt
			qui drop _des_en
			qui drop `namevar'
			qui rename _cae_num rev21_section
			qui replace rev21_section = -99 if _valid_cae_21 == 0
			qui replace rev21_section = -99 if _valid_cae_21 == 99
			qui replace rev21_section = -99 if `len' < 2 
			label values rev21_section divlabel21
			label var rev21_section "CAE Rev. 21 Section (Level 1)"
		}
		else {
			cap drop rev21_subsection
			qui merge m:1 `namevar' using "`file'"
			qui drop if _m == 2
			qui drop _m
			qui drop _des_pt
			qui drop _des_en
			qui drop `namevar'
			qui rename _cae_num rev21_subsection
			qui replace rev21_subsection = -99 if _valid_cae_21 == 0
			qui replace rev21_subsection = -99 if _valid_cae_21 == 99
			qui replace rev21_subsection = -99 if `len' < 2 
			label values rev21_subsection divlabel21
			label var rev21_subsection "CAE Rev. 21 Subsection (Level 2)"
		}
	}

	if "`item'" == "3" {
		cap drop rev21_division
		qui gen str2 `namevar' = substr(`vardiv',1,2) 
		qui merge m:1 `namevar' using "`file'"
		qui drop if _m == 2
		qui drop _m
		qui drop _des_pt
		qui drop _des_en
		qui drop `namevar'
		qui rename _cae_num rev21_division
		qui replace rev21_division = -99 if _valid_cae_21 == 0
		qui replace rev21_division = -99 if _valid_cae_21 == 99
		qui replace rev21_division = -99 if `len' < 2
		label values rev21_division divlabel21
		label var rev21_division "CAE Rev. 21 Division (Level 3)"
	}
	if "`item'" == "4" {
		cap drop rev21_group
		qui gen str3 `namevar' = substr(`vardiv',1,3) 
		qui merge m:1 `namevar' using "`file'"
		qui drop if _m == 2
		qui drop _m
		qui drop _des_pt
		qui drop _des_en
		qui drop `namevar'
		qui rename _cae_num rev21_group
		qui replace rev21_group = -99 if _valid_cae_21 == 0
		qui replace rev21_group = -99 if _valid_cae_21 == 99
		qui replace rev21_group = -99 if `len' < 3 
		label values rev21_group divlabel21
		label var rev21_group "CAE Rev. 21 Group (Level 4)"
	}
	if "`item'" == "5" {
		cap drop rev21_class
		qui gen str4 `namevar' = substr(`vardiv',1,4) 
		qui merge m:1 `namevar' using "`file'"
		qui drop if _m == 2
		qui drop _m
		qui drop _des_pt
		qui drop _des_en
		qui drop `namevar'
		qui rename _cae_num rev21_class
		qui replace rev21_class = -99 if _valid_cae_21 == 0
		qui replace rev21_class = -99 if _valid_cae_21 == 99
		qui replace rev21_class = -99 if `len' < 4
		label values rev21_class divlabel21
		label var rev21_class "CAE Rev. 21 Class (Level 5)"
	}
	if "`item'" == "6" {
		cap drop rev21_subclass
		qui clonevar `namevar' = `vardiv'
		qui merge m:1 `namevar' using "`file'"
		qui drop if _m == 2
		qui drop _m
		qui drop _des_pt
		qui drop _des_en
		qui drop `namevar'
		qui rename _cae_num rev21_subclass
		qui replace rev21_subclass = -99 if _valid_cae_21 == 0
		qui replace rev21_subclass = -99 if _valid_cae_21 == 99
		qui replace rev21_subclass = -99 if `len' < 5
		label values rev21_subclass divlabel21
		label var rev21_subclass "CAE Rev. 21 Subclass (Level 6)"
	}	


}

qui compress rev21_*

end
