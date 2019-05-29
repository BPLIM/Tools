// This ado cleans a string, removing characters and duplicate variables
// Takes some string as an argument
// Returns a local stored in r(str_variables)


program define str_clean, rclass
	syntax, str_arg(string) [verbose] // [words(string)]
	
	************************************* verbose ********************************************
	if "`verbose'" == "verbose" {
		di ""
		di "------------------------ begin str_clean.ado ------------------------------"
		di ""
		di `"Initial str_arg: `str_arg'"'
	}
	******************************************************************************************
	
	// Removing specific characters from str_arg
	
	
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
	quietly ds
	foreach item in `vars' {
		local out = 0
		foreach var in `r(varlist)' {
			if "`item'" == "`var'" {
				local out = `out' + 1
			}
		}
		if `out' == 0 {
			local pos = strpos("`vars'","`item'")
			local leni = length("`item'")
			local lenv = length("`vars'")
			if `pos'==1 {
				local vars = substr("`vars'",`leni'+1,`lenv'-`leni')
			}
			else {
				local posn = strpos("`vars'"," `item'")
				local lenin = length(" `item'")
				local lenvn = length("`vars'")
				local vars = substr("`vars'",1,`posn'-1) + substr("`vars'",`posn'+`lenin',`lenvn'-`lenin'-`posn'+1)
			}
			local vars = stritrim("`vars'")
			local vars = strltrim("`vars'")
			local vars = strrtrim("`vars'")
		}
	}

	************************************* verbose ********************************************
	if "`verbose'" == "verbose" {
		di ""
		di "New str_arg: `vars'"
	}
	******************************************************************************************
	
	// Removing duplicate variables from str_arg
	
	************************************* verbose ********************************************
	if "`verbose'" == "verbose" {
		di ""
		di "Removing duplicate variables from str_arg"
	}
	******************************************************************************************
	
	foreach item in `vars' {
		//di "str_variables: `vars'"
		//di "item: `item'"
		local words_but = regexr("`vars'","`item'","")
		//di "words_but: `words_but'"
		foreach nitem in `words_but' {
			//di "nitem: `nitem'"
			//if regexm("`words_but'","`item'") == 1 {
			if "`item'" == "`nitem'" {
				local vars = regexr("`vars'","`item'","")
			}
		}
	}
	//di "variables: `vars'"
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
