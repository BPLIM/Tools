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
			di "{err:[Error: program checkmd_mpz] One or more variables have not been found" ///
				" on the dataset}"
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
		di "Counting the number of observations for which variable is missing, zero, positive" 
			"or has a value label missing"
	}
	******************************************************************************************
	local i = 1
	foreach var in `variables' {
		local `var' = `i' // locals' names max 31 while vars 32
		// variable missing
		quietly count if missing(`var')
		local m``var'' = r(N)
		if "`verbose'" == "verbose" {
			di ""
			di "missing: `var' -> `m``var'''"
		}
		// variable > 0
		capture count if `var'> 0 & !missing(`var')
		if _rc == 0 {
			local p``var'' = r(N)
		}
		else {
			local p``var'' = .
		}
		if "`verbose'" == "verbose" {
			di "positive: `var' -> `p``var'''"
		}
		// varible = 0
		capture count if `var' == 0 
		if _rc == 0 {
			local z``var'' = r(N)
		}
		else {
			local z``var'' = .
		}
		if "`verbose'" == "verbose" {
			di "zeros: `var' -> `z``var'''"
		}
		// value label missing
		foreach catvar in `check_label' {
			if "`catvar'" == "`var'" {
				tempvar decvar
				decode `var', gen(`decvar')
				quietly count if missing(`decvar') & !missing(`var')
				local v``var'' = `r(N)'
				continue, break
			}
			else {
				local v``var'' = .
			}
		}	
		if "`verbose'" == "verbose" {
			di "missing value label: `var' -> `v``var'''"
		}
		// local type for rownames
		local t``var'': type `var'
		local r``var'' = "`var'[`t``var''']"
		local rownames = "`rownames'" + " `r``var'''"
		if "`verbose'" == "verbose" {
			di ""
			di "Creating rownames:"
			di ""
			di "`rownames'"
		}
		local ++i
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
		matrix A[`i',1] = `m``var'''
		matrix A[`i',2] = `p``var'''
		matrix A[`i',3] = `z``var'''
		matrix A[`i',4] = `v``var'''
		if "`verbose'" == "verbose" {
			di "matrix A[`i',1] = `m``var'''"
			di "matrix A[`i',2] = `p``var'''"
			di "matrix A[`i',3] = `z``var'''"
			di "matrix A[`i',4] = `v``var'''"
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
