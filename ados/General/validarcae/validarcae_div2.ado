program define validarcae_div2

syntax varlist, [file(string) levels(string) force en keep _solv]

forvalues j= 2/5 {
	preserve
		qui use "`file'", clear
		if `j' == 2 {
			qui keep if length(_cae_str) <= `j'
		}
		else {
			qui keep if length(_cae_str) == `j'
		}
		if "`en'" == "en" {
			qui keep _cae_num _cae_str _des_en 
			qui gen divlabel = substr(_cae_str,1, `j') + " - " + _des_en
			keep _cae_num divlabel
		}
		else {
			qui keep _cae_num _cae_str _des_pt
			qui gen divlabel = substr(_cae_str,1, `j') + " - " + _des_pt
			keep _cae_num divlabel
		}
		quietly count 
		local total = r(N)
		if "`en'" == "en" {
			label define divlabel2`j' -99 "Invalid code", add modify 
			label define divlabel2`j' -98 "Ambiguous validation, not able to convert", ///
				add modify 
		}
		else {
			label define divlabel2`j' -99 "Código inválido", add modify 
			label define divlabel2`j' -98 "Validação ambígua, código não convertido", ///
				add modify 		
		}
		forvalues i = 1/`total' {
			local value = _cae_num[`i']
			local label = divlabel[`i']     
			label define divlabel2`j' `value' `"`label'"', add modify    
		}
		qui label save divlabel2`j' using lixo, replace
	restore
	qui do lixo.do
	qui rm lixo.do
}


tempvar len
qui gen `len' = length(_cae_str)

cap confirm variable _zerosdropped
local zero_dropped = _rc


if "`_solv'" != "_solv" {
	qui replace _cae_str = "0" + _cae_str if ///
		inlist(_valid_cae_2, 2, 20, 200, 2000)
}
else {
    cap confirm var _solved
	if _rc {
	    qui replace _cae_str = "0" + _cae_str if ///
			inlist(_valid_cae_2, 2, 20, 200, 2000)
	}
	else {
	    qui replace _cae_str = "0" + _cae_str if ///
			inlist(_valid_cae_2, 2, 20, 200, 2000) & _solved != 1
	}
}

/*
if "`fl'" == "fl" {
	qui replace _cae_str = "0" + _cae_str if inlist(_valid_cae_2, 13, 23, 33, 43)
}*/

qui replace `len' = length(_cae_str)

tempvar _merge

foreach item in `levels' {		
	if "`item'" == "1" {
		cap drop rev2_section
		qui clonevar _cae_str_original = _cae_str
		qui replace _cae_str = "A" if inlist(substr(_cae_str,1,2), "01", "02")
		qui replace _cae_str = "B" if inlist(substr(_cae_str,1,2), "05")
		qui replace _cae_str = "C" if inlist(substr(_cae_str,1,2), "10", "11", "12")
		qui replace _cae_str = "C" if inlist(substr(_cae_str,1,2), "13", "14") 
		qui replace _cae_str = "D" if inlist(substr(_cae_str,1,2), "15", "16")
		qui replace _cae_str = "D" if inlist(substr(_cae_str,1,2), "17", "18")
		qui replace _cae_str = "D" if inlist(substr(_cae_str,1,2), "19")
		qui replace _cae_str = "D" if inlist(substr(_cae_str,1,2), "20")
		qui replace _cae_str = "D" if inlist(substr(_cae_str,1,2), "21", "22")
		qui replace _cae_str = "D" if inlist(substr(_cae_str,1,2), "23")
		qui replace _cae_str = "D" if inlist(substr(_cae_str,1,2), "24")
		qui replace _cae_str = "D" if inlist(substr(_cae_str,1,2), "25")
		qui replace _cae_str = "D" if inlist(substr(_cae_str,1,2), "26")
		qui replace _cae_str = "D" if inlist(substr(_cae_str,1,2), "27", "28")
		qui replace _cae_str = "D" if inlist(substr(_cae_str,1,2), "29")	
		qui replace _cae_str = "D" if inlist(substr(_cae_str,1,2), "30", "31", "32", "33")
		qui replace _cae_str = "D" if inlist(substr(_cae_str,1,2), "34", "35")
		qui replace _cae_str = "D" if inlist(substr(_cae_str,1,2), "36", "37")
		qui replace _cae_str = "E" if inlist(substr(_cae_str,1,2), "40", "41")
		qui replace _cae_str = "F" if inlist(substr(_cae_str,1,2), "45")
		qui replace _cae_str = "G" if inlist(substr(_cae_str,1,2), "50", "51", "52")
		qui replace _cae_str = "H" if inlist(substr(_cae_str,1,2), "55")
		qui replace _cae_str = "I" if inlist(substr(_cae_str,1,2), "60", "61", "62", "63", "64")
		qui replace _cae_str = "J" if inlist(substr(_cae_str,1,2), "65", "66", "67")
		qui replace _cae_str = "K" if inlist(substr(_cae_str,1,2), "70", "71", "72", "73", "74")
		qui replace _cae_str = "L" if inlist(substr(_cae_str,1,2), "75")
		qui replace _cae_str = "M" if inlist(substr(_cae_str,1,2), "80")
		qui replace _cae_str = "N" if inlist(substr(_cae_str,1,2), "85")
		qui replace _cae_str = "O" if inlist(substr(_cae_str,1,2), "90", "91", "92", "93")
		qui replace _cae_str = "P" if inlist(substr(_cae_str,1,2), "95")
		qui replace _cae_str = "Q" if inlist(substr(_cae_str,1,2), "99")
		qui merge m:1 _cae_str using "`file'", gen(`_merge')
		qui drop if `_merge' == 2
		qui drop `_merge'
		qui drop _des_pt
		qui drop _des_en
		qui drop _cae_str
		qui rename _cae_str_original _cae_str
		qui rename _cae_num rev2_section
		qui replace rev2_section = -99 if _valid_cae_2 == 0
		qui replace rev2_section = -99 if _valid_cae_2 == 200000
		if ("`force'" != "force") qui replace rev2_section = -98 if ///
			inlist(_valid_cae_2, 30, 300, 3000) 
		if (`zero_dropped' == 0) qui replace rev2_section = -98 if ///
			(!missing(_zerosdropped) & !inlist(_valid_cae_`rev',2,10,20,100,200,1000,2000))
		qui replace rev2_section = -99 if `len' < 2 
		label values rev2_section divlabel22
		label var rev2_section "CAE Rev. 2 Section (Level 1)"
	}
	if "`item'" == "2" {
		cap drop rev2_subsection
		qui clonevar _cae_str_original = _cae_str
		qui replace _cae_str = "AA" if inlist(substr(_cae_str,1,2), "01", "02")
		qui replace _cae_str = "BB" if inlist(substr(_cae_str,1,2), "05")
		qui replace _cae_str = "CA" if inlist(substr(_cae_str,1,2), "10", "11", "12")
		qui replace _cae_str = "CB" if inlist(substr(_cae_str,1,2), "13", "14") 
		qui replace _cae_str = "DA" if inlist(substr(_cae_str,1,2), "15", "16")
		qui replace _cae_str = "DB" if inlist(substr(_cae_str,1,2), "17", "18")
		qui replace _cae_str = "DC" if inlist(substr(_cae_str,1,2), "19")
		qui replace _cae_str = "DD" if inlist(substr(_cae_str,1,2), "20")
		qui replace _cae_str = "DE" if inlist(substr(_cae_str,1,2), "21", "22")
		qui replace _cae_str = "DF" if inlist(substr(_cae_str,1,2), "23")
		qui replace _cae_str = "DG" if inlist(substr(_cae_str,1,2), "24")
		qui replace _cae_str = "DH" if inlist(substr(_cae_str,1,2), "25")
		qui replace _cae_str = "DI" if inlist(substr(_cae_str,1,2), "26")
		qui replace _cae_str = "DJ" if inlist(substr(_cae_str,1,2), "27", "28")
		qui replace _cae_str = "DK" if inlist(substr(_cae_str,1,2), "29")	
		qui replace _cae_str = "DL" if inlist(substr(_cae_str,1,2), "30", "31", "32", "33")
		qui replace _cae_str = "DM" if inlist(substr(_cae_str,1,2), "34", "35")
		qui replace _cae_str = "DN" if inlist(substr(_cae_str,1,2), "36", "37")
		qui replace _cae_str = "EE" if inlist(substr(_cae_str,1,2), "40", "41")
		qui replace _cae_str = "FF" if inlist(substr(_cae_str,1,2), "45")
		qui replace _cae_str = "GG" if inlist(substr(_cae_str,1,2), "50", "51", "52")
		qui replace _cae_str = "HH" if inlist(substr(_cae_str,1,2), "55")
		qui replace _cae_str = "II" if inlist(substr(_cae_str,1,2), "60", "61", "62", "63", "64")
		qui replace _cae_str = "JJ" if inlist(substr(_cae_str,1,2), "65", "66", "67")
		qui replace _cae_str = "KK" if inlist(substr(_cae_str,1,2), "70", "71", "72", "73", "74")
		qui replace _cae_str = "LL" if inlist(substr(_cae_str,1,2), "75")
		qui replace _cae_str = "MM" if inlist(substr(_cae_str,1,2), "80")
		qui replace _cae_str = "NN" if inlist(substr(_cae_str,1,2), "85")
		qui replace _cae_str = "OO" if inlist(substr(_cae_str,1,2), "90", "91", "92", "93")
		qui replace _cae_str = "PP" if inlist(substr(_cae_str,1,2), "95")
		qui replace _cae_str = "QQ" if inlist(substr(_cae_str,1,2), "99")
		qui merge m:1 _cae_str using "`file'", gen(`_merge')
		qui drop if `_merge' == 2
		qui drop `_merge'
		qui drop _des_pt
		qui drop _des_en
		qui drop _cae_str
		qui rename _cae_str_original _cae_str
		qui rename _cae_num rev2_subsection
		qui replace rev2_subsection = -99 if _valid_cae_2 == 0
		qui replace rev2_subsection = -99 if _valid_cae_2 == 200000
		if ("`force'" != "force") qui replace rev2_subsection = -98 if ///
			inlist(_valid_cae_2, 30, 300, 3000) 
		if (`zero_dropped' == 0) qui replace rev2_subsection = -98 if ///
			(!missing(_zerosdropped) & !inlist(_valid_cae_`rev',2,10,20,100,200,1000,2000))
		qui replace rev2_subsection = -99 if `len' < 2 
		label values rev2_subsection divlabel22
		label var rev2_subsection "CAE Rev. 2 Subsection (Level 2)"
	}
	if "`item'" == "3" {
		cap drop rev2_division
		qui clonevar _cae_str_original = _cae_str
		qui replace _cae_str = substr(_cae_str,1,2) 
		qui merge m:1 _cae_str using "`file'", gen(`_merge')
		qui drop if `_merge' == 2
		qui drop `_merge'
		qui drop _des_pt
		qui drop _des_en
		qui drop _cae_str
		qui rename _cae_str_original _cae_str
		qui rename _cae_num rev2_division
		qui replace rev2_division = -99 if _valid_cae_2 == 0
		qui replace rev2_division = -99 if _valid_cae_2 == 200000
		if ("`force'" != "force") qui replace rev2_division = -98 if ///
			inlist(_valid_cae_2, 30, 300, 3000) 
		if (`zero_dropped' == 0) qui replace rev2_division = -98 if ///
			(!missing(_zerosdropped) & !inlist(_valid_cae_`rev',2,10,20,100,200,1000,2000))
		qui replace rev2_division = -99 if `len' < 2 
		label values rev2_division divlabel22
		label var rev2_division "CAE Rev. 2 Division (Level 3)"
	}
	if "`item'" == "4" {
		cap drop rev2_group
		qui clonevar _cae_str_original = _cae_str
		qui replace _cae_str = substr(_cae_str,1,3) 
		qui merge m:1 _cae_str using "`file'", gen(`_merge')
		qui drop if `_merge' == 2
		qui drop `_merge'
		qui drop _des_pt
		qui drop _des_en
		qui drop _cae_str
		qui rename _cae_str_original _cae_str
		qui rename _cae_num rev2_group
		qui replace rev2_group = -99 if _valid_cae_2 == 0
		qui replace rev2_group = -99 if _valid_cae_2 == 200000
		if ("`force'" != "force") qui replace rev2_group = -98 if ///
			inlist(_valid_cae_2, 30, 300, 3000) 
		if (`zero_dropped' == 0) qui replace rev2_group = -98 if ///
			(!missing(_zerosdropped) & !inlist(_valid_cae_`rev',2,10,20,100,200,1000,2000))
		qui replace rev2_group = -99 if `len' < 3 
		label values rev2_group divlabel23
		label var rev2_group "CAE Rev. 2 Group (Level 4)"
	}
	if "`item'" == "5" {
		cap drop rev2_class
		qui clonevar _cae_str_original = _cae_str
		qui replace _cae_str = substr(_cae_str,1,4) 
		qui merge m:1 _cae_str using "`file'", gen(`_merge')
		qui drop if `_merge' == 2
		qui drop `_merge'
		qui drop _des_pt
		qui drop _des_en
		qui drop _cae_str
		qui rename _cae_str_original _cae_str
		qui rename _cae_num rev2_class
		qui replace rev2_class = -99 if _valid_cae_2 == 0
		qui replace rev2_class = -99 if _valid_cae_2 == 200000
		if ("`force'" != "force") qui replace rev2_class = -98 if ///
			inlist(_valid_cae_2, 30, 300, 3000) 
		if (`zero_dropped' == 0) qui replace rev2_class = -98 if ///
			(!missing(_zerosdropped) & !inlist(_valid_cae_`rev',2,10,20,100,200,1000,2000))
		qui replace rev2_class = -99 if `len' < 4
		label values rev2_class divlabel24
		label var rev2_class "CAE Rev. 2 Class (Level 5)"
	}
	if "`item'" == "6" {
		cap drop rev2_subclass
		qui merge m:1 _cae_str using "`file'", gen(`_merge')
		qui drop if `_merge' == 2
		qui drop `_merge'
		qui drop _des_pt
		qui drop _des_en
		qui rename _cae_num rev2_subclass
		qui replace rev2_subclass = -99 if _valid_cae_2 == 0
		qui replace rev2_subclass = -99 if _valid_cae_2 == 200000
		if ("`force'" != "force") qui replace rev2_subclass = -98 if ///
			inlist(_valid_cae_2, 30, 300, 3000) 
		if (`zero_dropped' == 0) qui replace rev2_subclass = -98 if ///
			(!missing(_zerosdropped) & !inlist(_valid_cae_`rev',2,10,20,100,200,1000,2000))
		qui replace rev2_subclass = -99 if `len' < 5
		label values rev2_subclass divlabel25
		label var rev2_subclass "CAE Rev. 2 Subclass (Level 6)"
	}	
}
if "`keep'" != "keep" {
	cap drop _cae_str
}

qui compress rev2_*

end
