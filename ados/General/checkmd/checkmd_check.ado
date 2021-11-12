* Part of package checkmd
* Checks if some logical condition is verified inside a particular dataset

program define checkmd_check, rclass


syntax, check(string)        /// condition to be verified in csv file (cond)
		id(string)           /// check id (specified by the user)
		title(string)        /// title of the check (condition)
		[				     ///
			miss             /// specifies that missing values of variables inside the check will be set as zeros
			delta(real 0)    /// margin of error
			list_val(int 0)  /// specifies the number on inconsistencies displayed in the html document
			save_obs(int 50) /// the number of inconsistent observations that will be saved in the inconsistencies dataset
			verbose          /// displays additional information about the state of the program 
			tvar(string)     /// time variable 
			addvars(string)  /// adds specified variables to the inconsistencies dataset
			ignoremissing    /// ignores observations where one of the variables is missing
			ignore(string)   /// ignores rows where the condition, which is valid Stata code, is true
		]


************************************* verbose ********************************************
if "`verbose'" == "verbose" {
	di ""
	di "------------------------ begin checkmd_check.ado ------------------------------"
}
******************************************************************************************

/* Extracting the variables from the string argument in order to check if all variables 
are available in the dataset. If so, r(error) will be 0 and 1 otherwise*/

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
if trim(`"`ignore'"') != "" {
    str_clean, str_arg(`ignore') `verbose'
	local ignorevars `r(str_var)'
	cap confirm variable `ignorevars'
	if _rc {
	    di as error `"Could not find all variables in condition "`ignore'""'
		error 1
	}
}
capture confirm variable `vars'

************************************* verbose ********************************************
if "`verbose'" == "verbose" {
	di ""
	di "Confirming if the variables specified under cond in the csv file are in the " /// 
	   "dataset. If so, local error will be 0"
}
******************************************************************************************

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
	if "`ignoremissing'" == "ignoremissing" {
	    tempvar rowmiss dummiss
		qui egen `rowmiss' = rowmiss(`vars')
		qui gen `dummiss' = (`rowmiss' > 0)
	}
	if trim(`"`ignore'"') != "" {
	    tempvar ignoredummy
		cap gen `ignoredummy' = (`ignore')
		if _rc {
			di as error `"Error generating condition "`ignore'""'
			error 1
		}
	}

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
	
	* Assert condition before generating variables. If there are no inconsistencies, 
	* it's more efficient to skip the next steps
	
	************************************* verbose ********************************************
	if "`verbose'" == "verbose" {
		di ""
		di "Assert condition before generating variables. If there are no inconsistencies," ///
		   " it's more efficient to skip the next steps. This step returns local asrt"
	}
	******************************************************************************************
	
	if `delta' == 0 {
		local final_check = `"`check'"'
	}
	else {
		if regexm("`check'","==") {
			local check_first = regexr("`check'","==","<=") + "+`delta'"
			local check_second = regexr("`check'","==",">=") + "-`delta'"
			local final_check = "`check_first'" + " & " + "`check_second'"
		}
		else if regexm("`check'",">") {
			local final_check = "`check'" + "+`delta'"

		}
		else if regexm("`check'","<") {
			local final_check = "`check'" + "-`delta'"
		}
	}
	
	if ("`ignoremissing'" == "ignoremissing") & trim(`"`ignore'"') != "" {
	    capture assert (`final_check') | (`dummiss' == 1) | (`ignoredummy' == 1)
	}
	else if ("`ignoremissing'" == "ignoremissing") & trim(`"`ignore'"') == "" {
	    capture assert (`final_check') | (`dummiss' == 1)
	}
	else if ("`ignoremissing'" == "") & trim(`"`ignore'"') != "" {
	    capture assert (`final_check') | (`ignoredummy' == 1)
	}
	else {
		capture assert (`final_check')
	}
	
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
			di "Generating the dummy variable as specified by the formula in the csv document. " ///
			   "If there is an error when generating the variable, local gen_error = 1"
		}
		******************************************************************************************
		
		if `delta' == 0 {
			capture gen `dummy' = (`check')
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
			if regexm("`check'","==") {
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
			else if regexm("`check'",">") {
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
			else if regexm("`check'","<") {
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
		    
			if "`ignoremissing'" == "ignoremissing" {
				qui replace `dummy' = 1 if `dummiss' == 1
				drop `dummiss'
			}
			
			if trim(`"`ignore'"') != "" {
				qui replace `dummy' = 1 if `ignoredummy' == 1
				drop `ignoredummy'
			}
			
			label var `dummy' "Check"
			
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

			* Generating variable diff for option list_val

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
			
			* Returning matrix r(X) and saving a dataset with inconsistent values
			
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
				if `inc' > 0 & ${listinc} == 1 {
					if `list_val' != 0 {
						qui hashsort - `abs_diff'
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
							qui hashsort - `abs_diff'
							keep ${id} `tvar' `vars' _diff `dummy'
							order ${id} `tvar' `vars' _diff
						}
						else {
							keep ${id} `tvar' `vars' `dummy'
							order ${id} `tvar' `vars' 
							sort `dummy'
						}
						quietly gen nn = _n
						quietly keep if `dummy'== 0 & nn <= `count_list'
						quietly drop `dummy' nn
						quietly save "${out_path}/temp_file", replace
					restore
				}
				if `inc' > 0 & `save_obs' >= 0 {
					preserve
						if `list_val' != 0 {
							qui hashsort - `abs_diff'
							keep ${id} `tvar' `vars' `addvars' _diff `dummy'
						}
						else {
							keep ${id} `tvar' `vars' `addvars' `dummy'
							sort `dummy'
						}
						quietly gen nn = _n
						if `save_obs' == 0 {
							quietly keep if `dummy' == 0 
						}
						else {
							quietly keep if `dummy' == 0 & nn <= `save_obs'
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
	di "------------------------ end checkmd_check.ado --------------------------------"
}
******************************************************************************************

end


program define str_clean, rclass

* This ado cleans a string, removing characters and duplicate variables
* Takes some string as an argument
* Returns a local stored in r(str_var)

syntax, str_arg(string) [verbose]

************************************* verbose ********************************************
if "`verbose'" == "verbose" {
	di ""
	di "------------------------ begin str_clean.ado ------------------------------"
	di ""
	di `"Initial str_arg: `str_arg'"'
}
******************************************************************************************

* Removing specific characters from str_arg

************************************* verbose ********************************************
if "`verbose'" == "verbose" {
	di ""
	di "Removing specific characters from str_arg (+ - * / = > < ^ ( ) & | . , ; !)"
}
******************************************************************************************

local str_variables = subinstr("`str_arg'","+"," ",20)
local str_variables = subinstr("`str_variables'","-"," ",20)
local str_variables = subinstr("`str_variables'","*"," ",20)
local str_variables = subinstr("`str_variables'","/"," ",20)
local str_variables = subinstr("`str_variables'","="," ",20)
local str_variables = subinstr("`str_variables'",">"," ",20)
local str_variables = subinstr("`str_variables'","<"," ",20)
local str_variables = subinstr("`str_variables'","^"," ",20)
local str_variables = subinstr("`str_variables'","("," ",20)
local str_variables = subinstr("`str_variables'",")"," ",20)
local str_variables = subinstr("`str_variables'","&"," ",20)
local str_variables = subinstr("`str_variables'","|"," ",20)
local str_variables = subinstr("`str_variables'","."," ",20)
local str_variables = subinstr("`str_variables'",","," ",20)
local str_variables = subinstr("`str_variables'",";"," ",20)
local str_variables = subinstr("`str_variables'","!"," ",20)

************************************* verbose ********************************************
if "`verbose'" == "verbose" {
	di ""
	di "New str_arg: `str_variables'"
}
******************************************************************************************

// Removing elements from `vars' that are not variables

************************************* verbose ********************************************
if "`verbose'" == "verbose" {
	di ""
	di "Removing elements from str_arg that are not variables"
}
******************************************************************************************
local vars = "`str_variables'"
local vars = stritrim("`vars'")
local vars = strltrim("`vars'")
local vars = strrtrim("`vars'")
foreach var in `vars' {
	cap confirm var `var'
	if !_rc {
		local only_vars = "`only_vars'" + " `var'"
	}
}
local vars = "`only_vars'"
local vars = stritrim("`vars'")
local vars = strltrim("`vars'")
local vars = strrtrim("`vars'")

************************************* verbose ********************************************
if "`verbose'" == "verbose" {
	di ""
	di "New str_arg: `vars'"
}
******************************************************************************************

* Removing duplicate variables from str_arg

************************************* verbose ********************************************
if "`verbose'" == "verbose" {
	di ""
	di "Removing duplicate variables from str_arg"
}
******************************************************************************************

foreach item in `vars' {
	local words_but = regexr("`vars'","`item'","")
	foreach nitem in `words_but' {
		if "`item'" == "`nitem'" {
			local vars = regexr("`vars'","`item'","")
		}
	}
}

************************************* verbose ********************************************
if "`verbose'" == "verbose" {
	di ""
	di "New str_arg: `vars'"
}
******************************************************************************************

local str_var = "`vars'"
return local str_var = "`vars'"

************************************* verbose ********************************************
if "`verbose'" == "verbose" {
	di ""
	di "Returned locals:"
	di ""
	di "str_var: `str_var'"
}
******************************************************************************************

************************************* verbose ********************************************
if "`verbose'" == "verbose" {
	di ""
	di "------------------------ end str_clean.ado --------------------------------"
}
******************************************************************************************
	
end
