*! version 0.1 22Feb2024
* Programmed by Gustavo Iglésias

program define sampleid

	version 14

	syntax varlist(min=1), [ ///
		sample(int 0)        ///
		TIMEvar(str)         ///
		masterid(str)        ///
		mastervars(str)      ///
		seed(int 42)         ///
		save(str)            ///
		replace              ///
	] 

	if ("`save'" == "")  {
		local saveid "master_ID"
	}
	else {
		local saveid "`save'"
	}

	cap confirm file "`saveid'.dta" 
	if !_rc {
		if ("`replace'" != "replace") { 
			di "{err:file {bf:`saveid'.dta} already exists}"
			exit 602
		}
		else {
			rm "`saveid'.dta"
		}
	}
	
	
	preserve
		sampleid_call `varlist', sample(`sample') ///
			time(`timevar') masterid(`masterid') seed(`seed') ///
			saveid(`saveid') mastervars(`mastervars')
	restore
	

end


program define sampleid_call

	version 14

	syntax varlist(min=1), [ ///
		sample(int 0)        ///
		TIMEvar(str)         ///
		masterid(str)        ///
		mastervars(str)      ///
		seed(int 42)         ///
		saveid(str)          ///
	] 

	***** Errors *****

	if ("`mastervars'" != "" & `sample' > 0) {
		di "{err:Options {bf:sample} and {bf:mastervars}} may not be combined"
		exit 198
	}
	
	if ("`mastervars'" != "") {
		foreach var in `mastervars' {
			confirm var `var'
		}
	}
	
	if ("`mastervars'" != "" & "`masterid'" == "") {
		di "{err:Option {bf:mastervars} requires option {bf:masterid}}"
		exit 198
	}

	if ("`masterid'" == "" & `sample' == 0) {
		di "{err:Please specify option {bf:sample} and/or {bf:masterid}}"
		exit 198
	}

	if (`sample' < 0 | `sample' > 100) {
		di "{err:{bf:sample} must be between 0 and 100"
		exit 198
	}

	if ("`timevar'" != "") confirm var `timevar'

	***** Get id combinations *****
	if ("`masterid'" != "") {
		confirm file "`masterid'.dta"
		preserve
			qui get_id_sample `varlist', masterid("`masterid'") save(`saveid') ///
				sample(`sample') mastervars(`mastervars')
		restore
	}
	else {
		preserve
			qui get_id_sample `varlist', sample(`sample') seed(`seed') save(`saveid')
		restore
	}

	***** Join ids with time variable if it exists *****
	if ("`timevar'" != "") {
		tempvar merged
		quietly {
			merge m:1 `varlist' using "`saveid'", gen(`merged')
			keep if `merged' == 3
			drop `merged'
			keep `varlist' `timevar'
			if ("`masterid'" != "") {
				if ("`mastervars'" != "") {
					label data "ID data [`varlist'] - collected from `masterid' - Merged on `mastervars'"
				}
				else {
					label data "ID data [`varlist'] - collected from `masterid'"
				}
			}
			else {
				label data "ID data [`varlist'] - `sample'% sample"
			}
			save "`saveid'", replace
			noi di
			noi di "file {bf:`saveid'.dta} saved"
		}
	}
	else {
		di 
		di "file {bf:`saveid'.dta} saved"
	}
	

end


program define get_id_sample 

	/*
	combinations of id variables may come from the masterid file or be sampled from 
	the current data
	*/

	syntax varlist(min=1), [masterid(str) sample(int 0) seed(int 42) save(str) mastervars(str)]

	* If the master id file is provided, id variables have to be merged
	if ("`masterid'" != "") {
		cap drop `merged'
		tempvar merged
		ds 
		if `sample' == 0 {
			quietly {
				if ("`mastervars'" != "") {
					tempfile temp 
					qui save `temp'
					keep `mastervars'
					bysort `mastervars': keep if _n == 1
					merge 1:m `mastervars' using "`masterid'", gen(`merged')
					keep if `merged' == 3
					drop `merged'
					keep `mastervars'
					bysort `mastervars': keep if _n == 1
					merge 1:m `mastervars' using "`temp'", gen(`merged')
					keep if `merged' == 3
					drop `merged'					
					keep `varlist'
					bysort `varlist': keep if _n == 1
					label data "ID data [`varlist'] - collected from `masterid' - Merged on `mastervars'"
					save "`save'", replace						
				}
				else {
					keep `varlist'
					bysort `varlist': keep if _n == 1
					merge 1:m `varlist' using "`masterid'", gen(`merged')
					keep if `merged' == 3
					drop `merged'
					keep `varlist'
					bysort `varlist': keep if _n == 1
					label data "ID data [`varlist'] - collected from `masterid'"
					save "`save'", replace					
				}
			}			
		}
		else {
			keep `varlist'
			bysort `varlist': keep if _n == 1
			merge 1:m `varlist' using "`masterid'", gen(`merged')
			keep `varlist' `merged'
			bysort `varlist': keep if _n == 1
			qui count if `merged' == 3
			local sampled = `r(N)'
			local prop = `sampled' / _N * 100
			if (`prop' < `sample') {
				tempfile temp
				local diff = `sample' - `prop'
				qui count 
				local original_obs = `r(N)'
				preserve
					keep if `merged' == 3
					save `temp', replace
				restore
				drop if `merged' == 3
				local new_prop = (_N * `diff') / `original_obs'
				set seed `seed'
				sample `new_prop'
				append using `temp'
			}
			drop `merged'
			if ("`new_prop'" == "") local new_prop 0
			label data "ID data [`varlist'] - collected from `masterid' - `new_prop'% of new ids"
			save "`save'", replace	
        }
	}
	else {
		preserve 
			quietly {
				keep `varlist'
				bysort `varlist': keep if _n == 1
				set seed `seed'
				sample `sample'
				label data "ID data [`varlist'] - `sample'% sample"
				save "`save'", replace
			}		
		restore			
	}
	
	
end
