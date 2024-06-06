program define validarcae_div3

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
			label define divlabel3`j' -99 "Invalid code", add modify 
			label define divlabel3`j' -98 "Ambiguous validation, not able to convert", ///
				add modify 
		}
		else {
			label define divlabel3`j' -99 "Código inválido", add modify 
			label define divlabel3`j' -98 "Validação ambígua, código não convertido", ///
				add modify 		
		}
		forvalues i = 1/`total' {
			local value = _cae_num[`i']
			local label = divlabel[`i']     
			label define divlabel3`j' `value' `"`label'"', add modify    
		}
		qui label save divlabel3`j' using lixo, replace
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
		inlist(_valid_cae_3, 2, 20, 200, 2000)
}
else {
    cap confirm var _solved
	if _rc {
	    qui replace _cae_str = "0" + _cae_str if ///
			inlist(_valid_cae_3, 2, 20, 200, 2000)
	}
	else {
	    qui replace _cae_str = "0" + _cae_str if ///
			inlist(_valid_cae_3, 2, 20, 200, 2000) & _solved != 1
	}
}

qui replace `len' = length(_cae_str)

tempvar _merge


foreach item in `levels' {
	if "`item'" == "1" {
		qui clonevar _cae_str_original = _cae_str
		cap drop rev3_section
		qui replace _cae_str = "A" if inlist(substr(_cae_str,1,2), "01", "02", "03")
		qui replace _cae_str = "B" if inlist(substr(_cae_str,1,2), "05", "06", "07", "08", "09")
		qui replace _cae_str = "C" if inlist(substr(_cae_str,1,2), "10", "11", "12", "13", "14", "15", "16")
		qui replace _cae_str = "C" if inlist(substr(_cae_str,1,2), "17", "18", "19", "20", "21", "22", "23") 
		qui replace _cae_str = "C" if inlist(substr(_cae_str,1,2), "24", "25", "26", "27", "28", "29", "30")
		qui replace _cae_str = "C" if inlist(substr(_cae_str,1,2), "31", "32", "33")
		qui replace _cae_str = "D" if inlist(substr(_cae_str,1,2), "35")
		qui replace _cae_str = "E" if inlist(substr(_cae_str,1,2), "36", "37", "38", "39")
		qui replace _cae_str = "F" if inlist(substr(_cae_str,1,2), "41", "42", "43")
		qui replace _cae_str = "G" if inlist(substr(_cae_str,1,2), "45", "46", "47")
		qui replace _cae_str = "H" if inlist(substr(_cae_str,1,2), "49", "50", "51", "52", "53")
		qui replace _cae_str = "I" if inlist(substr(_cae_str,1,2), "55", "56")
		qui replace _cae_str = "J" if inlist(substr(_cae_str,1,2), "58", "59", "60", "61", "62", "63")
		qui replace _cae_str = "K" if inlist(substr(_cae_str,1,2), "64", "65", "66")
		qui replace _cae_str = "L" if inlist(substr(_cae_str,1,2), "68")
		qui replace _cae_str = "M" if inlist(substr(_cae_str,1,2), "69", "70", "71", "72", "73", "74", "75")
		qui replace _cae_str = "N" if inlist(substr(_cae_str,1,2), "77", "78", "79", "80", "81", "82")
		qui replace _cae_str = "O" if inlist(substr(_cae_str,1,2), "84")
		qui replace _cae_str = "P" if inlist(substr(_cae_str,1,2), "85")
		qui replace _cae_str = "Q" if inlist(substr(_cae_str,1,2), "86", "87", "88")
		qui replace _cae_str = "R" if inlist(substr(_cae_str,1,2), "90", "91", "92", "93")
		qui replace _cae_str = "S" if inlist(substr(_cae_str,1,2), "94", "95", "96")
		qui replace _cae_str = "T" if inlist(substr(_cae_str,1,2), "97", "98")
		qui replace _cae_str = "U" if inlist(substr(_cae_str,1,2), "99")
		qui merge m:1 _cae_str using "`file'", gen(`_merge')
		qui drop if `_merge' == 2
		qui drop `_merge'
		qui drop _des_pt
		qui drop _des_en
		qui drop _cae_str
		qui rename _cae_str_original _cae_str
		qui rename _cae_num rev3_section
		qui replace rev3_section = -99 if _valid_cae_3 == 0
		qui replace rev3_section = -99 if _valid_cae_3 == 200000
		if ("`force'" != "force") qui replace rev3_section = -98 if ///
			inlist(_valid_cae_3, 30, 300, 3000) 
		if (`zero_dropped' == 0) qui replace rev3_section = -98 if ///
			(!missing(_zerosdropped) & !inlist(_valid_cae_`rev',2,10,20,100,200,1000,2000))
		qui replace rev3_section = -99 if `len' < 2
		label values rev3_section divlabel32
		label var rev3_section "CAE Rev. 3 Section (Level 1)"
	}
	if "`item'" == "2" {
		qui clonevar _cae_str_original = _cae_str
		cap drop rev3_division
		qui replace _cae_str = substr(_cae_str,1,2) 
		qui merge m:1 _cae_str using "`file'", gen(`_merge')
		qui drop if `_merge' == 2
		qui drop `_merge'
		qui drop _des_pt
		qui drop _des_en
		qui drop _cae_str
		qui rename _cae_str_original _cae_str
		qui rename _cae_num rev3_division
		qui replace rev3_division = -99 if _valid_cae_3 == 0
		qui replace rev3_division = -99 if _valid_cae_3 == 200000
		if ("`force'" != "force") qui replace rev3_division = -98 if ///
			inlist(_valid_cae_3, 30, 300, 3000) 
		if (`zero_dropped' == 0) qui replace rev3_division = -98 if ///
			(!missing(_zerosdropped) & !inlist(_valid_cae_`rev',2,10,20,100,200,1000,2000))
		qui replace rev3_division = -99 if `len' < 2 
		label values rev3_division divlabel32
		label var rev3_division "CAE Rev. 3 Division (Level 2)"
	}
	if "`item'" == "3" {
		qui clonevar _cae_str_original = _cae_str
		cap drop rev3_group
		qui replace _cae_str = substr(_cae_str,1,3) 
		qui merge m:1 _cae_str using "`file'", gen(`_merge')
		qui drop if `_merge' == 2
		qui drop `_merge'
		qui drop _des_pt
		qui drop _des_en
		qui drop _cae_str
		qui rename _cae_str_original _cae_str
		qui rename _cae_num rev3_group
		qui replace rev3_group = -99 if _valid_cae_3 == 0
		qui replace rev3_group = -99 if _valid_cae_3 == 200000
		if ("`force'" != "force") qui replace rev3_group = -98 if ///
			inlist(_valid_cae_3, 30, 300, 3000) 
		if (`zero_dropped' == 0) qui replace rev3_group = -98 if ///
			(!missing(_zerosdropped) & !inlist(_valid_cae_`rev',2,10,20,100,200,1000,2000))
		qui replace rev3_group = -99 if `len' < 3 
		label values rev3_group divlabel33
		label var rev3_group "CAE Rev. 3 Group (Level 3)"
	}
	if "`item'" == "4" {
		qui clonevar _cae_str_original = _cae_str
		cap drop rev3_class
		qui replace _cae_str = substr(_cae_str,1,4) 
		qui merge m:1 _cae_str using "`file'", gen(`_merge')
		qui drop if `_merge' == 2
		qui drop `_merge'
		qui drop _des_pt
		qui drop _des_en
		qui drop _cae_str
		qui rename _cae_str_original _cae_str
		qui rename _cae_num rev3_class
		qui replace rev3_class = -99 if _valid_cae_3 == 0
		qui replace rev3_class = -99 if _valid_cae_3 == 200000
		if ("`force'" != "force") qui replace rev3_class = -98 if ///
			inlist(_valid_cae_3, 30, 300, 3000) 
		if (`zero_dropped' == 0) qui replace rev3_class = -98 if ///
			(!missing(_zerosdropped) & !inlist(_valid_cae_`rev',2,10,20,100,200,1000,2000))
		qui replace rev3_class = -99 if `len' < 4 
		label values rev3_class divlabel34
		label var rev3_class "CAE Rev. 3 Class (Level 4)"
	}
	if "`item'" == "5" {
		cap drop rev3_subclass
		qui merge m:1 _cae_str using "`file'", gen(`_merge')
		qui drop if `_merge' == 2
		qui drop `_merge'
		qui drop _des_pt
		qui drop _des_en
		qui rename _cae_num rev3_subclass
		qui replace rev3_subclass = -99 if _valid_cae_3 == 0
		qui replace rev3_subclass = -99 if _valid_cae_3 == 200000
		if ("`force'" != "force") qui replace rev3_subclass = -98 if ///
			inlist(_valid_cae_3, 30, 300, 3000) 
		if (`zero_dropped' == 0) qui replace rev3_subclass = -98 if ///
			(!missing(_zerosdropped) & !inlist(_valid_cae_`rev',2,10,20,100,200,1000,2000))
		qui replace rev3_subclass = -99 if `len' < 5 
		label values rev3_subclass divlabel35
		label var rev3_subclass "CAE Rev. 3 Subclass (Level 5)"
	}	
}

if "`keep'" != "keep" {
	cap drop _cae_str
}

qui compress rev3_*

end
