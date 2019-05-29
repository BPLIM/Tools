// This ado has a file as an argument
// The argument is the csv document used to get the checks we wish to perform and stata code to generate variables
// It returns locals with information (id, title, etc) that we will use to report the information in markdown



program define ext_inf, rclass

syntax, file(string) [verbose]


************************************* verbose ********************************************
if "`verbose'" == "verbose" {
	di ""
	di "------------------------ begin ext_inf.ado ------------------------------"
}
******************************************************************************************
	
	// Importing the csv file
	
	************************************* verbose ********************************************
	if "`verbose'" == "verbose" {
		di ""
		di "Importing the csv file"
	}
	******************************************************************************************
	
	quietly import delimited "`file'", delimiter(",") varnames(1) stringcols(_all) clear
	//quietly import excel using "`file'", firstrow allstring clear 
	
	// Returning information on checks that will be performed
	
	************************************* verbose ********************************************
	if "`verbose'" == "verbose" {
		di ""
		di "Returning information on checks from the csv file"
		di ""
		di "Returned locals:"
	}
	******************************************************************************************
	
	preserve
		quietly keep if active == "1" 
		quietly count
		forval i = 1/ `r(N)' {
			return local id_`i' = check_id in `i'
			return local title_`i' = check_title in `i'
			return local cond_`i' = cond in `i'
			capture return local option_`i' = option in `i'
			if delta[`i'] == "" {
				return local delta_`i' = 0
			}
			else {
				return local delta_`i' = delta in `i'
			}
			if list_val[`i'] == "" {
				return local list_val_`i' = 0
			}
			else {
				return local list_val_`i' = list_val in `i'
			}
			if "`verbose'" == "verbose" {
				di ""
				local id_`i' = check_id in `i'
				local title_`i' = check_title in `i'
				local cond_`i' = cond in `i'
				local option_`i' = option in `i'
				if delta[`i'] == "" {
					local delta_`i' = 0
				}
				else {
					local delta_`i' = delta in `i'
				}
				if list_val[`i'] == "" {
					local list_val_`i' = 0
				}
				else {
					local list_val_`i' = list_val in `i'
				}
				di `"local id_`i' = `id_`i''"'
				di `"local title_`i' = `title_`i''"'
				di `"local cond_`i' = `cond_`i''"'
				di `"local option_`i' = `option_`i''"'
				di `"local delta_`i' = `delta_`i''"'
				di `"local list_val_`i' = `list_val_`i''"'
			}
			
		}
	restore 
	
	// Returning stata code used to generate variables
	
	************************************* verbose ********************************************
	if "`verbose'" == "verbose" {
		di ""
		di "Returning information on stata code"
		di ""
		di "Returned code lines:"
	}
	******************************************************************************************
	
	preserve
		quietly keep if active == "2" 
		quietly count
		forval i = 1/ `r(N)' {
			return local gen_`i' = cond in `i'		
			if "`verbose'" == "verbose" {
				local gen_`i' = cond in `i'
				di `"local gen_`i' = `gen_`i''"'
			}
		}
	restore
	
************************************* verbose ********************************************
if "`verbose'" == "verbose" {
	di ""
	di "------------------------ end ext_inf.ado ------------------------------"
}
******************************************************************************************
	
end
