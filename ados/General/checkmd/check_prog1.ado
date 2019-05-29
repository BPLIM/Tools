// This program checks if some logical condition is verified inside a particular dataset

program define check_prog1, rclass


syntax, check(string) id(string) title(string) [miss] [delta(real 0)]  [list_val(int 0)] [save_obs(int 50)] [verbose] [tvar(string)]


// check = condition to be verified in csv file (cond)
// id = check_id
// if option miss is specified, the missing values of variables inside check will be turned into zeros
// delta lets the user choose a margin of error for the check
// title for labeling data with inconsistencies
// option list_val specifies the number on inconsistencies displayed in the html document
// save_obs is the number of inconsistent observations that will be saved to a dataset
// The program returns 6 locals: r(tot)			-> number of observations
//								 r(inc) 		-> number of observations that meet the condition
//								 r(error),		-> some variable was not found in the dataset 
// 								 r(list_val)	-> tells file_write.do if we want to list the values with differences or not
//								 r(gen_error)	-> 1 if generating dummy resulted in error
//								 r(labels)		-> labels for the variables
// and 1 matrix:
//                               r(X)		-> matrix with frequencies



************************************* verbose ********************************************
if "`verbose'" == "verbose" {
	di ""
	di "------------------------ begin check_prog1.ado ------------------------------"
}
******************************************************************************************




// Extracting the variables from the string argument in order to check if all variables are available in the dataset. If so, r(error) will be 0 and 1 otherwise


************************************* verbose ********************************************
if "`verbose'" == "verbose" {
	di ""
	di "------------------------ Program str_clean ------------------------------"
}
******************************************************************************************

str_clean, str_arg(`check') `verbose'
local vars `r(str_var)'

if "`tvar'" != "" {
	confirm variable `tvar'
}
capture confirm variable `vars'

************************************* verbose ********************************************
if "`verbose'" == "verbose" {
	di ""
	di "Confirming if the variables specified under cond in the csv file are in the dataset. If so, local error will be 0"
}
******************************************************************************************

// labels for `vars'

/*
foreach item in `vars' {
	local label: variable label `item'
	if length("`label'")>0 {
		local labels  "`labels'" _n "`item': `label'"
	}
}

return local labels = `"`labels'"'

*/



if _rc==0 {
	return local error = 0
	local error = 0

	tempvar dummy 


	// Turning missing values to zeros if specified by option miss 
	
	************************************* verbose ********************************************
	if "`verbose'" == "verbose" {
		di ""
		di "Turning missing values to zeros if specified by option miss (option in csv file)"
	}
	******************************************************************************************

	if "`miss'" == "miss" {
		foreach item in `vars' {
			quietly replace `item' = 0 if missing(`item')
		}
	}

	
	// Returning local r(tot)
	
	************************************* verbose ********************************************
	if "`verbose'" == "verbose" {
		di ""
		di "Returning local r(tot)"
	}
	******************************************************************************************
	
	quietly count 
	local tot = r(N)
	return local tot = `tot'
	if "`tvar'" != "" {
		quietly glevelsof(`tvar'), local(levels)
		foreach item in `levels' {
			quietly count if `tvar' == `item'
			local tot_`item' = r(N)
			return local tot_`item' = `tot_`item''		
		}
	}
	
	
	// Assert condition before generating variables. If there are no inconsistencies, it's more efficient to skip the next steps
	
	************************************* verbose ********************************************
	if "`verbose'" == "verbose" {
		di ""
		di "Assert condition before generating variables. If there are no inconsistencies, it's more efficient to skip the next steps. This step returns local asrt"
	}
	******************************************************************************************
	
	if `delta' == 0 {
		local final_check = `"`check'"'
	}
	else {
		if regexm("`check'","==") == 1 {
			local check_first = regexr("`check'","==","<=") + "+`delta'"
			local check_second = regexr("`check'","==",">=") + "-`delta'"
			local final_check = "`check_first'" + " & " + "`check_second'"
		}
		else if regexm("`check'",">") == 1 {
			local final_check = "`check'" + "+`delta'"

		}
		else if regexm("`check'","<") == 1 {
			local final_check = "`check'" + "-`delta'"
		}
	}
	
	
	capture assert (`final_check')
	
	if _rc == 0 {
		return local asrt = 0
		local asrt = 0
		return local gen_error = 0
		local gen_error = 0
	}
	else if _rc != 0 & _rc != 9 {
		return local asrt = 111
		local asrt = 111
		return local gen_error = 1
		local gen_error = 1
	
	}
	else if _rc == 9 {
		return local asrt = 9
		local asrt = 9
		return local gen_error = 0
		local gen_error = 0
				
		// Generating the variable as specified by the formula in the csv document
		
		************************************* verbose ********************************************
		if "`verbose'" == "verbose" {
			di ""
			di "Generating the dummy variable as specified by the formula in the csv document. If there is an error when generating the variable, local gen_error = 1"
		}
		******************************************************************************************
		
		if `delta' == 0 {
			capture quietly gen `dummy' = (`check')
			if _rc != 0 {
				return local gen_error = 1
				local gen_error = 1
			}
			else {
				return local gen_error = 0
				local gen_error = 0
			}
		}
		else {
			if regexm("`check'","==") == 1 {
				local check_first = regexr("`check'","==","<=") + "+`delta'"
				local check_second = regexr("`check'","==",">=") + "-`delta'"
				local final_check = "`check_first'" + " & " + "`check_second'"
				capture quietly gen `dummy' = (`final_check')
				if _rc != 0 {
					return local gen_error = 1
					local gen_error = 1
				}
				else {
					return local gen_error = 0
					local gen_error = 0
				}
			}
			else if regexm("`check'",">") == 1 {
				local final_check = "`check'" + "+`delta'"
				capture quietly gen `dummy' = (`final_check')
				if _rc != 0 {
					return local gen_error = 1
					local gen_error = 1
				}
				else {
					return local gen_error = 0
					local gen_error = 0
				}
			}
			else if regexm("`check'","<") == 1 {
				local final_check = "`check'" + "-`delta'"
				capture quietly gen `dummy' = (`final_check')
				if _rc != 0 {
					return local gen_error = 1
					local gen_error = 1
				}
				else {
					return local gen_error = 0
					local gen_error = 0
				}
			}
		}
		
		if `gen_error' == 0 {
			label var `dummy' "Check"
			
			// Returning locals r(inc) and r(list_val)
			
			************************************* verbose ********************************************
			if "`verbose'" == "verbose" {
				di ""
				di "Returning local r(inc) and r(list_val) "
			}
			******************************************************************************************
			
			quietly count if `dummy' == 0
			return local inc = r(N)
			local inc = r(N)
			if "`tvar'" != "" {
				quietly glevelsof(`tvar'), local(levels)
				foreach item in `levels' {
					quietly count if `dummy' == 0 & `tvar' == `item'
					local inc_`item' = r(N)
					return local inc_`item' = `inc_`item''
				}
			}

			if `list_val' != 0 {
				return local list_valn = `list_val'
				local list_valn = `list_val'
			}
			else {
				return local list_valn = 0
				local list_valn = 0
			}

			// Generating variable diff for option list_val

			************************************* verbose ********************************************
			if "`verbose'" == "verbose" {
				di ""
				di "Generating variable diff for option list_val"
			}
			******************************************************************************************
			
			if `list_val' != 0 {
				tempvar var1 var2 abs_diff
				local check_l = subinstr("`check'","=="," ",1)
				local check_l = subinstr("`check_l'","<="," ",1)
				local check_l = subinstr("`check_l'",">="," ",1)
				local check_l = subinstr("`check_l'",">"," ",1)
				local check_l = subinstr("`check_l'","<"," ",1)
				local pos = strpos("`check_l'"," ")
				local var1_cont = substr("`check_l'",1,`pos'-1)
				local var2_cont = substr("`check_l'",`pos'+1,strlen("`check_l'")-`pos')
				quietly gen double `var1' = `var1_cont'
				quietly gen double `var2' = `var2_cont'
				quietly gen double _diff = cond(missing(`var1'),0,`var1')- cond(missing(`var2'),0,`var2')
				quietly gen `abs_diff' = abs(_diff) if `dummy' == 0
				quietly replace `abs_diff' = 0 if missing(`abs_diff')
				
			}
			
			
			// Returning matrix r(X) and saving a dataset with inconsistent values
			
			************************************* verbose ********************************************
			if "`verbose'" == "verbose" {
				di ""
				di "Returning matrix r(X) and saving a dataset with inconsistent values"
			}
			******************************************************************************************			
			
			if `inc' > 0 {
				if `inc' != `tot' {
					quietly tab `dummy', matcell(y)
					matrix A =(el(y,1,1), el(y,1,1)/r(N)*100,el(y,1,1)/r(N)*100\el(y,2,1),el(y,2,1)/r(N)*100,100.00)
					matrix rownames A = Inconsistent Consistent
					matrix colnames A = Freq. Percent Cum.
					matrix X = A
					return matrix X = A
				}
				if `inc'>0 & ${internal}==1 {
					if `list_val' != 0 {
						gsort -`abs_diff'
					}
					quietly count if `dummy' == 0
					if r(N) < `list_val' {
						if "`verbose'" == "verbose" {
							di ""
							di "Returning local r(count_list) "
						}
						local count_list = r(N)
						return local count_list = r(N)
					}
					else {
						if "`verbose'" == "verbose" {
							di ""
							di "Returning local r(count_list) "
						}
						local count_list = `list_val'
						return local count_list = `list_val'
					}
					preserve
						if `list_val' != 0 {
							gsort -`abs_diff'
							keep ${id} `tvar' `vars' _diff `dummy'
							order ${id} `tvar' `vars' _diff
						}
						else {
							keep ${id} `tvar' `vars' `dummy'
							order ${id} `tvar' `vars' 
							sort `dummy'
						}
				
						quietly gen nn = _n
						quietly keep if `dummy'==0 & nn <= `count_list'
						quietly drop `dummy' nn
						
						quietly save "${out_path}/temp_file", replace
					restore
					
					preserve
						if `list_val' != 0 {
							gsort -`abs_diff'
							keep ${id} `tvar' `vars' _diff `dummy'
						}
						else {
							keep ${id} `tvar' `vars' `dummy'
							sort `dummy'
						}
						quietly gen nn = _n
						if `save_obs' == 0 {
							quietly keep if `dummy'==0 
						}
						else {
							quietly keep if `dummy'==0 & nn <= `save_obs'
						}
						quietly drop `dummy' nn
						note: "`title'"
						capture mkdir "${out_path}/Reports/report_${dta_file}/${c_date}/Data Inconsistencies"
						capture mkdir "${out_path}/Reports/report_${dta_file}/${c_date}/Data Inconsistencies/`id'"
						capture quietly saveold "${out_path}/Reports/report_${dta_file}/${c_date}/Data Inconsistencies/`id'/`id'_${dta_file}", replace
					restore
				}
			}
		}
	}
}
else {
	return local error = 1
	local error = 1
	return local gen_error = 1
	return local asrt = 111
}
	
************************************* verbose ********************************************
if "`verbose'" == "verbose" {
	di ""
	di "Returned locals:"
	di ""
	di "local error: `error'"
	di "local gen_error: `gen_error'"
	di "local asrt: `asrt'"
	di "local tot: `tot'"
	di "local inc: `inc'"
	di "local list_valn: `list_valn'"
	di "local count_list: `count_list'"
	di ""
	di "Returned matrix:"
	di ""
	if "`inc'" != "" {
		matprint X, decimals(0,0,0)
	}
}
******************************************************************************************



capture drop _diff
capture label drop difflab

************************************* verbose ********************************************
if "`verbose'" == "verbose" {
	di ""
	di "------------------------ end check_prog1.ado --------------------------------"
}
******************************************************************************************


end
