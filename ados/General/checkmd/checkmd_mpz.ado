* This program creates a matrix of missing values, positive values and zeros for variables in a dataset
* If varlist is empty, the matrix willl contain all variables in the dataset. 
* To produce no matrix at all, simply write nompz as input in option varlist


program define checkmd_mpz, rclass

syntax, [varlist(string) verbose]

************************************* verbose ********************************************
if "`verbose'" == "verbose" {
	di ""
	di "------------------------ begin checkmd_mpz.ado ----------------------------"
}
******************************************************************************************

if "`varlist'" == "nompz" {
	capture di ""
}
else {
	if "`varlist'" == "" {
		quietly ds
		local variables `r(varlist)'
	}
	else { 
		local variables `varlist'
		capture confirm variable `variables'
		************************************* verbose ********************************************
		if "`verbose'" == "verbose" {
			di ""
			di "Confirming variables specified by the user"
		}
		******************************************************************************************
		if _rc != 0 {
			di as error "[Error: program checkmd_mpz] One or more variables have not been found on the dataset"
		}
	}
	
	// local for variables with labels

	************************************* verbose ********************************************
	if "`verbose'" == "verbose" {
		di ""
		di "Creating local for variables that have value labels"
	}
	******************************************************************************************
	
	quietly ds, has(vallabel)
	local check_label = "`r(varlist)'" 
	local check_label_count: word count `check_label'

	************************************* verbose ********************************************
	if "`verbose'" == "verbose" {
		di ""
		di "Counting the number of observations for which variable is missing, zero, positive or has a value label missing"
	}
	******************************************************************************************

	foreach var in `variables' {

		// variable missing
		quietly count if missing(`var')
		local miss_`var' = r(N)
		if "`verbose'" == "verbose" {
			di ""
			di "missing: `var' -> `miss_`var''"
		}
		// variable > 0
		capture count if `var'> 0 & !missing(`var')
		if _rc == 0 {
			local positive_`var' = r(N)
		}
		else {
			local positive_`var' = .
		}
		if "`verbose'" == "verbose" {
			di "positive: `var' -> `positive_`var''"
		}
		// varible = 0
		capture count if `var' == 0 
		if _rc == 0 {
			local zero_`var' = r(N)
		}
		else {
			local zero_`var' = .
		}
		if "`verbose'" == "verbose" {
			di "zeros: `var' -> `zero_`var''"
		}
		// value label missing
		if `check_label_count' == 1 {
			if regexm("`check_label'","`var'") == 1 {
				tempvar decvar
				decode `var', gen(`decvar')
				quietly count if missing(`decvar') & !missing(`var')
				local misslab_`var' = `r(N)'
			}
			else {
				local misslab_`var' = .
			}
		}
		else {
			if regexm("`check_label'"," `var'") == 1 | regexm("`check_label'","`var' ") == 1 {
				tempvar decvar
				decode `var', gen(`decvar')
				quietly count if missing(`decvar') & !missing(`var')
				local misslab_`var' = `r(N)'
			}
			else {
				local misslab_`var' = .
			}
		}		
		if "`verbose'" == "verbose" {
			di "missing value label: `var' -> `misslab_`var''"
		}
		// local type for rownames
		local type`var': type `var'
		local rowname`var' = "`var'[`type`var'']"
		local rownames = "`rownames'" + " `rowname`var''"
		if "`verbose'" == "verbose" {
			di ""
			di "Creating rownames:"
			di ""
			di "`rownames'"
		}
		
	}

	local var_count: word count `variables'
	
	************************************* verbose ********************************************
	if "`verbose'" == "verbose" {
		di ""
		di "Creating matrix mpz"
	}
	************************************* verbose ********************************************	
	
	mat A = J(`var_count',4,0)
	local i = 1
	foreach var in `variables' {
		matrix A[`i',1] = `miss_`var''
		matrix A[`i',2] = `positive_`var''
		matrix A[`i',3] = `zero_`var''
		matrix A[`i',4] = `misslab_`var''
		if "`verbose'" == "verbose" {
			di "matrix A[`i',1] = `miss_`var''"
			di "matrix A[`i',2] = `positive_`var''"
			di "matrix A[`i',3] = `zero_`var''"
			di "matrix A[`i',4] = `misslab_`var''"
		}
		local i = `i' + 1
	}

	matrix rownames A = `rownames'
	matrix colnames A = Missing Positive Zeros "Value label missing"
	matrix mpz = A
	
	return matrix mpz = A
	quietly count
	return local obs = r(N)
	local obs = r(N)
		
	************************************* verbose ********************************************
	if "`verbose'" == "verbose" {
		di "Returned locals and matrices:"
		di ""
		di "local obs: `obs'"
		di
		di "Matrix mpz:"
		di ""
		matprint mpz, decimals(0,0,0,0)
	}
	************************************* verbose ********************************************
}

************************************* verbose ********************************************
if "`verbose'" == "verbose" {
	di ""
	di "------------------------ end checkmd_mpz.ado ------------------------------"
}
******************************************************************************************

end
