program define get_div1

syntax varlist, [file(string) levels(string) en keep]



forvalues j= 1/6 {
	preserve
		qui use "`file'", clear
			qui keep if length(_cae_str) == `j'
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
			label define divlabel1`j' -99 "Unsuccessful conversion", add modify 
		}
		else {
			label define divlabel1`j' -99 "Conversão indisponível", add modify 		
		}
		forvalues i = 1/`total' {
			local value = _cae_num[`i']
			local label = divlabel[`i']     
			label define divlabel1`j' `value' `"`label'"', add modify    
		}
		qui label save divlabel1`j' using lixo, replace
	restore
	qui do lixo.do
	qui rm lixo.do
}

tempvar len
qui gen `len' = length(_cae_str)


foreach item in `levels' {
		
	if "`item'" == "1" {
		qui clonevar _cae_str_original = _cae_str
		cap drop rev1_division
		qui replace _cae_str = substr(_cae_str,1,1) 
		qui merge m:1 _cae_str using "`file'"
		qui drop if _m == 2
		qui drop _m
		qui drop _des_pt
		qui drop _des_en
		qui drop _cae_str
		qui rename _cae_str_original _cae_str
		qui rename _cae_num rev1_division
		qui replace rev1_division = -99 if _valid_cae_1 == 0
		qui replace rev1_division = -99 if _valid_cae_1 == 99
		qui replace rev1_division = -99 if `len' < 1
		label var rev1_division "CAE Rev. 1 Division (Level 1)"
		label values rev1_division divlabel11
	}	
	if "`item'" == "2" {
		qui clonevar _cae_str_original = _cae_str
		cap drop rev1_subdivision
		qui replace _cae_str = substr(_cae_str,1,2)
		qui merge m:1 _cae_str using "`file'"
		qui drop if _m == 2
		qui drop _m
		qui drop _des_pt
		qui drop _des_en
		qui drop _cae_str
		qui rename _cae_str_original _cae_str
		qui rename _cae_num rev1_subdivision
		qui replace rev1_subdivision = -99 if _valid_cae_1 == 0
		qui replace rev1_subdivision = -99 if _valid_cae_1 == 99
		qui replace rev1_subdivision = -99 if `len' < 2 
		label var rev1_subdivision "CAE Rev. 1 Subdivision (Level 2)"
		label values rev1_subdivision divlabel12
	}
	if "`item'" == "3" {
		qui clonevar _cae_str_original = _cae_str
		cap drop rev1_class
		qui replace _cae_str = substr(_cae_str,1,3) 
		qui merge m:1 _cae_str using "`file'"
		qui drop if _m == 2
		qui drop _m
		qui drop _des_pt
		qui drop _des_en
		qui drop _cae_str
		qui rename _cae_str_original _cae_str
		qui rename _cae_num rev1_class
		qui replace rev1_class = -99 if _valid_cae_1 == 0
		qui replace rev1_class = -99 if _valid_cae_1 == 99
		qui replace rev1_class = -99 if `len' < 3
		label var rev1_class "CAE Rev. 1 Class (Level 3)"
		label values rev1_class divlabel13
	}
	if "`item'" == "4" {
		qui clonevar _cae_str_original = _cae_str
		cap drop rev1_group
		qui replace _cae_str = substr(_cae_str,1,4) 
		qui merge m:1 _cae_str using "`file'"
		qui drop if _m == 2
		qui drop _m
		qui drop _des_pt
		qui drop _des_en
		qui drop _cae_str
		qui rename _cae_str_original _cae_str
		qui rename _cae_num rev1_group
		qui replace rev1_group = -99 if _valid_cae_1 == 0
		qui replace rev1_group = -99 if _valid_cae_1 == 99
		qui replace rev1_group = -99 if `len' < 4 
		label values rev1_group divlabel14
		label var rev1_group "CAE Rev. 1 Group (Level 4)"
	}
	if "`item'" == "5" {
		qui clonevar _cae_str_original = _cae_str
		cap drop rev1_subgroup
		qui replace _cae_str = substr(_cae_str,1,5) 
		qui merge m:1 _cae_str using "`file'"
		qui drop if _m == 2
		qui drop _m
		qui drop _des_pt
		qui drop _des_en
		qui drop _cae_str
		qui rename _cae_str_original _cae_str
		qui rename _cae_num rev1_subgroup
		qui replace rev1_subgroup = -99 if _valid_cae_1 == 0
		qui replace rev1_subgroup = -99 if _valid_cae_1 == 99
		qui replace rev1_subgroup = -99 if `len' < 5
		label var rev1_subgroup "CAE Rev. 1 Subgroup (Level 5)"
		label values rev1_subgroup divlabel15
	}
	if "`item'" == "6" {
		cap drop rev1_split
		qui merge m:1 _cae_str using "`file'"
		qui drop if _m == 2
		qui drop _m
		qui drop _des_pt
		qui drop _des_en
		qui rename _cae_num rev1_split
		qui replace rev1_split = -99 if _valid_cae_1 == 0
		qui replace rev1_split = -99 if _valid_cae_1 == 99
		qui replace rev1_split = -99 if `len' < 6 
		label values rev1_split divlabel16
		label var rev1_split "CAE Rev. 1 Split (Level 6)"
	}	


}

if "`keep'" != "keep" {
	cap drop _cae_str
}

qui compress rev1_*

end
