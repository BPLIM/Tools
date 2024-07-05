*! version 0.1 5Jul2024
* Programmed by Gustavo Iglésias

program define dummyfi

	version 14

	syntax namelist(min=1),  METAfile(str) [  ///
		masterid(str)                         ///
		DOfile(str)                           ///
		TIMEvar(str)                          ///
		seed(int 42)                          ///
		NAMEdummy(str)                        ///
		INVthresh(real 0.99)                  ///
		ZEROthresh(real 0.8)                  ///
		MISSthresh(real 0.8)                  ///
		replace                               ///
	] 
	
	if ("`dofile'" == "") local dofile "code_dummy"
	
	cap confirm file "`dofile'.do" 
	if !_rc {
		if ("`replace'" != "replace") { 
			di "{err:file {bf:`dofile'.do} already exists}"
			exit 602
		}
		else {
			rm "`dofile'.do"
		}
	}
	
	if ("`namedummy'" == "") local namedummy "dummy_data"
	
	preserve
		dummyfi_call `namelist', meta(`metafile') masterid(`masterid') ///
			dofile(`dofile') timevar(`timevar') seed(`seed') ///
			namedummy(`namedummy') invthresh(`invthresh') ///
			zerothresh(`zerothresh') missthresh(`missthresh')
	restore

end


program define dummyfi_call

	version 14

	syntax namelist(min=1),  METAfile(str) [  ///
		masterid(str)                         ///
		DOfile(str)                           ///
		TIMEvar(str)                          ///
		seed(int 42)                          ///
		NAMEdummy(str)                        ///
		INVthresh(real 0.99)                  ///
		ZEROthresh(real 0.8)                  ///
		MISSthresh(real 0.8)                  ///
		replace                               ///
	] 


	cap file close dummycode
	qui file open dummycode using "`dofile'.do", write text replace

	file write dummycode "* Generate Dummy Data" _n
	file write dummycode "" _n(2)

	file write dummycode "* Stata Version" _n
	file write dummycode "version `c(version)'" _n(2)
	
	file write dummycode "* Import ID data" _n
	file write dummycode `"use "`masterid'", clear"' _n(2)

	file write dummycode "* Set sort seed for reproducibility" _n
	file write dummycode "set sortseed `seed'" _n(2)
	
	file write dummycode "* Set seed for reproducibility" _n
	file write dummycode "set seed `seed'" _n(2)


	***** Get variables' info to create the dummy data *****
	preserve
		get_variables_meta, metafile(`metafile')
	restore
	local exc_vars = trim("`namelist'")
	local variables "`r(variables)'"
	local vars: list variables - exc_vars
	foreach var in `vars' {
		local `var'_label = "`r(`var'_label)'"
		local `var'_vl = "`r(`var'_vl)'"
		local `var'_type = "`r(`var'_type)'"
		local `var'_fmt = "`r(`var'_fmt)'"
		local `var'_min = "`r(`var'_min)'"
		local `var'_max = "`r(`var'_max)'"
		local `var'_inv = "`r(`var'_inv)'"
		local `var'_miss = "`r(`var'_miss)'"
		local `var'_zero = "`r(`var'_zero)'"
		local `var'_dmin = "`r(`var'_dmin)'"
		local `var'_dmax = "`r(`var'_dmax)'"
		if (substr("``var'_type'", 1, 3) == "str") continue
		* Rescale share of zeros
		local `var'_zero = ``var'_zero' / (1 - ``var'_miss')
		if ("`timevar'" != "") {
			if (``var'_inv' > `invthresh') {
				local `var'_inv = 1
			}
			else {
				local `var'_inv = 0
			}			
		}
		if (``var'_zero' > `zerothresh') {
			local `var'_zero = ``var'_zero'
		}
		else {
			local `var'_zero = 0
		}
		if (``var'_miss' > `missthresh') {
			local `var'_miss = ``var'_miss'
		}
		else {
			local `var'_miss = 0
		}
	}

	
	cap local timevar_min = ``timevar'_min'
	cap local timevar_max = ``timevar'_max'
	cap local timevar_fmt = "``timevar'_fmt'"

	
	local vars: list vars - timevar
	
	foreach var in `vars' {
		if (substr("``var'_type'", 1, 3) == "str") {
			di
			di "{text:Skipping string variable {bf:`var'}}"
			continue
		}
		else {
			if ("``var'_vl'" != "") {
				write_commands_cat `namelist', var(`var') handler(dummycode) ///
					label(``var'_label') vl(``var'_vl') type(``var'_type') ///
					format(``var'_fmt') inv(``var'_inv') meta(`metafile') ///
					datemin(``var'_dmin') datemax(``var'_dmax') ///
					miss(``var'_miss') tvar(`timevar') tmin(`timevar_min') ///
					tmax(`timevar_max') tformat(`timevar_fmt~')
			}
			else {
				write_commands_num `namelist', var(`var') handler(dummycode) ///
					label(``var'_label') type(``var'_type') format(``var'_fmt') ///
					inv(``var'_inv') min(``var'_min') max(``var'_max') ///
					datemin(``var'_dmin') datemax(``var'_dmax') ///
					miss(``var'_miss') zero(``var'_zero') tvar(`timevar') ///
					tmin(`timevar_min') tmax(`timevar_max') tformat(`timevar_fmt')
			}			
		}
	}
	
	file write dummycode "* Apply metadata" _n
	file write dummycode `"metaxl apply, meta("`metafile'")"' _n(2)

	file write dummycode "* Label data" _n
	file write dummycode `"label data "Pseudo data - Not valid for research""' _n(2)
	
	file write dummycode "* Save data" _n
	file write dummycode `"save "`namedummy'", replace"' _n

	file close dummycode
	
	di 
	di "Do-file {bf:`dofile'.do} created"

end


program define write_commands_cat

	/*
	Writes the commands for categorical variables
	*/

	syntax namelist, handler(str) var(str) meta(str) [ ///
		label(str) vl(str) type(str) format(str) inv(str) ///
		datemin(str) datemax(str) tvar(str) miss(real 0) ///
		tmin(str) tmax(str) tformat(str) ///
	]
	
	qui prob_matrix, meta(`meta') vl(`vl') var(`var')
	
	local rows = rowsof(r(`vl'))
	file write `handler' "* `var' - `label'" _n
	file write `handler' "* Generate random values from uniform" _n
	file write `handler' "gen runif = runiform()" _n
	file write `handler' "* Initial value for `var'" _n
	file write `handler' "gen `var' = ." _n
	file write `handler' "* Replace by probabilities ranges" _n
	forvalues i = 1/`rows' {
		local value = r(`vl')[`i', 1]
		local row_min = r(`vl')[`i', 2]
		local row_max = r(`vl')[`i', 3]
		* Only replace if prob > 0
		if (`row_max' > `row_min') {
			file write `handler' "replace `var' = `value' if inrange(runif, `row_min', `row_max')" _n
		}
	}
	file write `handler' "drop runif" _n
	* Replace values with missings according to share
	if (`miss') {
		file write `handler' "* Replace `var' with missing (`miss')" _n
		file write `handler' "gen runif = runiform(0, 1)" _n
		file write `handler' "replace `var' = . if runif <= `miss'" _n
		file write `handler' "drop runif" _n
	}
	* Change values if time invariant
	if "`inv'" != "" {
		if (`inv') {
			file write `handler' "* `var' time invariant" _n
			file write `handler' "bysort `namelist': replace `var' = `var'[1] if `var' < ." _n
		}	
	}
	* Replace as missing before datemin 
	if ("`datemin'" != "" & "`tmin'" != "") {
		if (`datemin' > `tmin') {
			local datemin_f: di `tformat' `datemin'
			file write `handler' "* Remove `var' before `datemin_f'" _n
			file write `handler' `"replace `var' = . if `tvar' < `datemin'"' _n
		}
	}
	* Replace as missing after datemax 
	if ("`datemax'" != "" & "`tmax'" != "") {
		if (`datemax' < `tmax') {
			local datemax_f: di `tformat' `datemax'
			file write `handler' "* Remove `var' after `datemax_f'" _n
			file write `handler' `"replace `var' = . if `tvar' > `datemax'"' _n
		}
	}
	file write `handler' "" _n(2)


end


program define prob_matrix, rclass
	
	/*
	Read the metafile and generates the probabilities for each value 
	in the value labels worksheet
	*/

	syntax, meta(str) vl(str) var(str)

	preserve
		import excel "`meta'.xlsx", sheet("vl_`vl'") firstrow clear
		drop label
		cap confirm var freq_`var'
		if _rc {
			gen double freq_`var' = 1 / _N
		}
		else {
			* In case type is string (usually not)
			destring freq_`var', replace force
			qui count if (freq_`var' < 0 | freq_`var' > 1) & !missing(freq_`var')
			if `r(N)' {
				di "{err:Probabilities must be between 0 and 1}"
				exit 121
			}
			recast double freq_`var'
			gen double cumprob = sum(freq_`var')
			* All missing
			if (cumprob[_N] == 0) {
				replace freq_`var' = 1 / _N
			}
			* Some missing
			else if (cumprob[_N] > 0 & cumprob[_N] < 1) {
				qui count if missing(freq_`var')
				qui replace freq_`var' = (1 - cumprob[_N]) / `r(N)' if missing(freq_`var')
			}
		}
		cap drop cumprob 
		gen double cumprob = sum(freq_`var')
		if (round(cumprob[_N], 0.001) > 1) {
			di "{err:Probabilities must sum up to 1}"
			exit 121			
		}
		* Generate probability ranges
		gen prob_min = cumprob[_n - 1]
		replace prob_min = 0 if _n == 1
		* Create and return matrix
		mkmat value prob_min cumprob, mat(`vl')
		return matrix `vl' = `vl'
	restore


end


program define write_commands_num

	/*
	Writes the commands for numerical values
	*/

	syntax namelist, handler(str) var(str) [ ///
		label(str) type(str) format(str) min(str) max(str) inv(str) ///
		datemin(str) datemax(str) tvar(str) miss(real 0) zero(real 0) ///
		tmin(str) tmax(str) tformat(str) ///
	]

	
	file write `handler' "* `var' - `label'" _n 
	if (`miss' == 1) {
		file write `handler' "* 100% missing values" _n
		file write `handler' "gen `type' `var' = ." _n
	}
	else {
		if (`min' == `max') {
			file write `handler' "gen `type' `var' = `min'" _n
		}
		else {
			if inlist("`type'", "float", "double") {
				file write `handler' "gen `type' `var' = runiform(`min', `max')" _n 
			}
			else {
				file write `handler' "gen `type' `var' = round(runiform(`min', `max'))" _n
			}		
		}
		* Replace values with missings according to share
		if (`miss') {
			file write `handler' "* Replace `var' with missing (`miss')" _n
			file write `handler' "gen runif = runiform(0, 1)" _n
			file write `handler' "replace `var' = . if runif <= `miss'" _n
			file write `handler' "drop runif" _n
		}
		* Replace values with zero according to share
		if (`zero' & (`min' < `max')) {
			file write `handler' "* Replace `var' with zeros (`zero')" _n
			file write `handler' "gen runif = runiform(0, 1)" _n
			file write `handler' "replace `var' = 0 if runif <= `zero' & `var' < ." _n
			file write `handler' "drop runif" _n
		}
		* Change values if time invariant
		if "`inv'" != "" {
			if (`inv' & (`min' < `max')) {
				file write `handler' "* `var' time invariant" _n
				file write `handler' "bysort `namelist': replace `var' = `var'[1] if `var' < ." _n
			}
		}
		* Replace as missing before datemin 
		if ("`datemin'" != "" & "`tmin'" != "") {
			if (`datemin' > `tmin') {
				local datemin_f: di `tformat' `datemin'
				file write `handler' "* Remove `var' before `datemin_f'" _n
				file write `handler' `"replace `var' = . if `tvar' < `datemin'"' _n
			}
		}
		* Replace as missing after datemax 
		if ("`datemax'" != "" & "`tmax'" != "") {
			if (`datemax' < `tmax') {
				local datemax_f: di `tformat' `datemax'
				file write `handler' "* Remove `var' after `datemax_f'" _n
				file write `handler' `"replace `var' = . if `tvar' > `datemax'"' _n
			}
		}		
	}

	file write `handler' "" _n(2)

end


program define get_variables_meta, rclass

	/*
	Read variables metadata and return locals with information for each variable
	*/

	syntax, metafile(str)

	qui import excel "`metafile'.xlsx", sheet("variables") allstring firstrow clear

	qui count 
	forvalues i = 1/`r(N)' {
		local var = variable[`i']
		local variables = "`variables'" + " `var'"
		* Label - Try label_en, if it does not exist, choose the first var with prefix label_ 
		cap confirm var label_en
		if _rc {
			foreach lbl of varlist label_* {
				return local `var'_label = `lbl'[`i']
				continue, break
			}
		}
		else {
			return local `var'_label = label_en[`i']
		} 
		* Value label - Try label_en, if it does not exist, choose the first var with 
		* prefix value_label_ 
		cap confirm var value_label_en
		if _rc {
			foreach vlbl of varlist value_label_* {
				return local `var'_vl = `vlbl'[`i']
				continue, break
			}
		}
		else {
			return local `var'_vl = value_label_en[`i']
		}
		* Type and format
		return local `var'_type = type[`i']
		return local `var'_fmt = format[`i']
		* Min, max and invariant
		cap return local `var'_min = p5[`i']
		cap return local `var'_max = p95[`i']
		cap return local `var'_inv = shareinv[`i']
		cap return local `var'_miss = sharemiss[`i']
		cap return local `var'_zero = sharezero[`i']
		cap return local `var'_dmin = datemin[`i']
		cap return local `var'_dmax = datemax[`i']

	}
	return local variables = trim("`variables'")

end

/*
program define validate_date

	/*
	Validates dates from metafile
	*/
	
	syntax, [date(str)]
	
	if (length("`date'") == 4) {
		if !regexm("`date'", "[0-9][0-9][0-9][0-9]") {
			di 
			di "{err:Yearly date {bf:`date'} not valid in metafile}"
			exit 121
		}
	}
	else if (length("`date'")) > 1 {
		if (date("`date'", "YMD") == . & monthly("`date'", "YM") == .) {
			di 
			di "{err:{bf:`date'} not valid in metafile. For monthly and }" ///
			`"{err:daily dates the command uses masks "YM" and "YMD". }"' ///
			"{err:See functions {bf:date} and {bf:monthly}}"
			exit 121
		} 
	}


end 
*/
