*! 0.1 27Feb2024
* Programmed by Gustavo Iglésias
* Dependencies:
* 	labmask

program define validarloc, sortpreserve

	version 14

	syntax varname [if/], [ ///
		REFdate(str)        ///
		getlevels(str)      ///
	]
	
	cap drop _valid_loc
	cap drop _valid_from
	cap drop _valid_to
	cap label drop lblvalid
	
	* Check that dependencies are installed
	cap which labmask
	if _rc {
		di "{err:Please install {bf:{help labmask}} to run this command}"
		exit _rc
	}
	
	if ("`getlevels'" != "" & "`refdate'" == "") {
		di "{err:Options {bf:getlevels} requires a reference date ({bf:refdate})}"
		exit 198
	}
	
	tempvar loc_code
	* Clone varlist (convert to string if numeric)
	if substr("`: type `varlist''", 1, 3) == "str" {
		qui clonevar `loc_code' = `varlist'
	}
	else {
		qui tostring `varlist', gen(`loc_code')
		qui replace `loc_code' = "" if `loc_code' == "."
	}
	
	tempvar length
	qui gen `length' = strlen(`loc_code')
	* Replace codes that have 1, 3, and 5 digits (should always have 2, 4 and 6)
	qui replace `loc_code' = "0" + `loc_code' if inlist(`length', 1, 3, 5)
	qui replace `length' = strlen(`loc_code')
	* Check if codes have different lengths
	qui sum `length' if !missing(`loc_code')
	local code_len = r(min)
	if `code_len' != r(max) {
		di "{err:Different lengths inside `name', which implies different territorial units}"
		exit 198
	}
	drop `length'
	
	if `code_len' == 2 {
		di 
		di "Validating district codes..."
	}
	else if `code_len' == 4 {
		di 
		di "Validating municipality codes..."
	}
	else if `code_len' == 6 {
		di 
		di "Validating parish codes..."
	}

	* Call program 
	tempfile valid_loc
	preserve 
		if ("`if'" != "") {
			qui keep if `if'
		}
		validarloc_call `loc_code', refdate(`refdate') ///
			getlevels(`getlevels') tempfile(`valid_loc') ///
			name(`varlist') code_len(`code_len')
	restore
	
	tempvar _merge
	cap merge m:1 `loc_code' using `valid_loc', gen(`_merge')
	if !_rc {
		qui drop if `_merge' == 2
		drop `_merge'
		qui replace _valid_loc = . if missing(`varlist')
	}
	tab _valid_loc, miss
	
end


program define validarloc_call

	syntax varname, [   ///
		REFdate(str)    ///
		getlevels(str)  ///
		tempfile(str)   ///
		name(str)       ///
		code_len(int 6) ///
	]
	
	* File to merge codes
	mata: st_local("FILE", findfile("versoes.dta"))
	
	local loc_code = "`varlist'"

	* drop duplicates
	quietly {
		bysort `loc_code': keep if _n == 1
	}
	
	* Manipulate external file 
	tempfile locfile
	preserve 
		tempvar length_in_loc
		use "`FILE'", clear
		collapse (min) data_inicio (max) data_fim, by(codigo)
		qui gen `length_in_loc' = strlen(codigo)
		qui keep if `length_in_loc' == `code_len'
		drop `length_in_loc'
		rename (codigo data_inicio data_fim) (`loc_code' _valid_from _valid_to)
		qui save "`locfile'", replace
	restore
	
	* Merge with external file to get valid codes
	tempvar _merge
	qui merge m:1 `loc_code' using "`locfile'", gen(`_merge')
	qui drop if `_merge' == 2
	
	* Variable to assert the validity of codes
	gen byte _valid_loc = 0
	qui replace _valid_loc = 1 if `_merge' == 3
	drop `_merge'
	label define lblvalid 0 "0 Invalid" 1 "1 Valid from-to"
	
	* If the user provides a reference date, the validity code changes
	if ("`refdate'" != "") {
		local _date = date("`refdate'", "DMY")
		qui sum _valid_from
		local _min_date = r(min)
		qui sum _valid_to
		local _max_date = r(max)
		if (`_date' < `_min_date' | `_date' > `_max_date') {
			drop _valid_loc
			label drop lblvalid
			di 
			di "{err:Reference date {bf:`refdate'} not covered in validation file. Aborting validation}"
			exit 198
		}
		qui replace _valid_loc = 2 if !inrange(`_date', _valid_from, _valid_to) & _valid_loc == 1
		qui replace _valid_loc = 3 if inrange(`_date', _valid_from, _valid_to) & _valid_loc == 1
		label define lblvalid 2 "2 Invalid for reference date `refdate'", add
		label define lblvalid 3 "3 Valid for reference date `refdate'", add
	}
	
	label values _valid_loc lblvalid
	label var _valid_loc "Division validity"
	label var _valid_from "Valid from"
	label var _valid_to "Valid until"

	
	if "`getlevels'" != "" {
		parse_getlevels, arg(`getlevels') code_len(`code_len')
		local to_num `r(to_num)'
		local levels `r(levels)'
		
		getlevels `loc_code', levels(`levels') valid(_valid_loc) refdate(`_date') ///
			to_num(`to_num') mergefile(`FILE')
	}	

	qui save `tempfile', replace
	
end


program define getlevels

	syntax varname, levels(str) valid(str) refdate(int) to_num(int) mergefile(str)
	
	local uta1 "_district"
	local uta2 "_municipality"
	local uta3 "_parish"
	foreach level in `levels' {
		cap drop `uta`level''
		cap drop `uta`level''_des
		tempfile tempmerge
		local level_length = `level' * 2
		qui gen `uta`level'' = substr(`varlist', 1, `level_length') 
		preserve
			tempvar length
			qui use "`mergefile'", clear
			qui gen `length' = strlen(codigo)
			qui keep if `length' == `level_length'
			qui keep if inrange(`refdate', data_inicio, data_fim)
			drop data_inicio data_fim
			rename codigo `uta`level''
			rename designacao `uta`level''_des
			qui save "`tempmerge'", replace
		restore
		
		tempvar _merge 
		qui merge m:1 `uta`level'' using "`tempmerge'", gen(`_merge')
		qui drop if `_merge' == 2
		qui replace `uta`level'' = "" if inlist(`valid', 0, 2)
		qui replace `uta`level''_des = "" if inlist(`valid', 0, 2)
		qui compress `uta`level''
		qui compress `uta`level''_des
		if (`level') == 1 {
			label var `uta`level'' "District"
			label var `uta`level''_des "District designation"
		}
		if (`level') == 2 {
			label var `uta`level'' "Municipality"
			label var `uta`level''_des "Municipality designation"
		}
		if (`level') == 3 {
			label var `uta`level'' "Parish"
			label var `uta`level''_des "Parish designation"
		}
		if (`to_num') {
			convert_to_numeric `uta`level'' `uta`level''_des, level(`level')
		}
	}


end


program define convert_to_numeric

	syntax varlist(min=2 max=2), level(int)
	
	tokenize `varlist'

	tempvar code labvar

	quietly {
		gen `labvar' = `1' + " " + `2'
		clonevar `code' = `1'
		if `level' == 3 {
			replace `code' = subinstr(`code', "A", "10", .)
			replace `code' = subinstr(`code', "B", "11", .)
			replace `code' = subinstr(`code', "C", "12", .)
			replace `code' = subinstr(`code', "D", "13", .)
			replace `code' = subinstr(`code', "E", "14", .)
			replace `code' = subinstr(`code', "F", "15", .)
			replace `code' = subinstr(`code', "G", "16", .)
			replace `code' = subinstr(`code', "H", "17", .)
		}
	}

	qui destring `code', replace

	labmask `code', values(`labvar') lbl(`1'lbl)
	
	drop `1' `2'

	rename `code' `1'

end


program define parse_getlevels, rclass

	syntax, arg(str) code_len(int)

	gettoken levels arg : arg, p(",")
	gettoken lixo arg : arg, p(",")
	gettoken to_numeric arg : arg, p(",")

	local levels = trim("`levels'")
	local to_num = trim("`to_numeric'")
	
	* Errors in levels 
	if `code_len' == 6 {
		local levels_list 1 2 3
		local uta "parish"
	}
	if `code_len' == 4 {
		local levels_list 1 2
		local uta "municipality"
	}
	if `code_len' == 2 {
		local levels_list 1
		local uta "district"
	}
	local levels: list uniq levels
	local common: list levels & levels_list
	local not_found: list levels - common
	
	if trim("`not_found'") != "" {
		di _new "{err:Invalid level(s) for `uta' (`not_found'). Possible values: `levels_list'}"
		exit 121
	}

	if "`to_num'" == "num" {
		return local to_num = 1
	}
	else {
		return local to_num = 0
	}
	return local levels = "`levels'"

end
