* This program validates the information provided by an csv file used to feed the ado checkmd

program define checkmd_vdata, rclass

syntax, file1(string) [verbose]

************************************* verbose ********************************************
if "`verbose'" == "verbose" {
	di ""
	di "------------------------ begin checkmd_vdata.ado ----------------------------"
}
******************************************************************************************

* Importing csv file

************************************* verbose ********************************************
if "`verbose'" == "verbose" {
	di ""
	di "Importing csv file `file1'"
}
******************************************************************************************

quietly import delimited "`file1'", delimiter(",") varnames(1) stringcols(_all) clear

quietly count
local tot = r(N)
local data_error = 0

* Checking if any attribute(var) is missing from the csv file

************************************* verbose ********************************************
if "`verbose'" == "verbose" {
	di ""
	di "Checking if any attribute(var) is missing from the csv file"
}
******************************************************************************************

local variables "check_id active check_title cond delta misstozero list_val ignoremiss ignore"
foreach item in `variables' {
	capture confirm variable `item'
	if _rc != 0 {
		di as error "[Error: csv file] Attribute `item' is missing"
		local data_error = 1
	}
}
if "`verbose'" == "verbose" & `data_error' == 0 {
	di ""
	di "No error to report"
}

* Checking if attribute active has values different from 0, 1 or 2

************************************* verbose ********************************************
if "`verbose'" == "verbose" {
	di ""
	di "Checking if attribute active has values different from 0, 1 or 2"
}
******************************************************************************************

local eactive = 0
forvalues i=1/`tot' {
	local row = `i' + 1
	if active[`i'] != "0" & active[`i'] != "1" & active[`i'] != "2" {
		di as error "[Error: csv file] Only 3 values are allowed for attribute active: 0 for inactive checks," ///
				    " 1 for active checks and 2 for generating variables. Please note that content under " ///
					"active is mandatory (row `row')"
		local data_error = 1
		local eactive = 1
	}
}
if "`verbose'" == "verbose" & `eactive' == 0 {
	di ""
	di "No error to report"
}

* Checking if there are missing values in mandatory fields (in lines with checks)

************************************* verbose ********************************************
if "`verbose'" == "verbose" {
	di ""
	di "Checking if there are missing values in mandatory fields (in lines with checks)"
}
******************************************************************************************

local echecks = 0
foreach var of varlist check_id check_title cond {
	forvalues i = 1/`tot' {
		local row = `i' + 1
		if missing(`var'[`i']) & active[`i'] == "1" {
			di as error "[Error: csv file] Content under `var' is mandatory for checks (row `row')"
			local data_error = 1
			local echecks = 1
		}
	}
}
if "`verbose'" == "verbose" & `echecks' == 0 {
	di ""
	di "No error to report"
}

* Checking if there are missing values in mandatory fields (in lines used to generate variables)

************************************* verbose ********************************************
if "`verbose'" == "verbose" {
	di ""
	di "Checking if there are missing values in mandatory fields (in lines used to generate variables)"
}
******************************************************************************************

local evargen = 0
foreach var of varlist cond {
	forvalues i = 1/`tot' {
		local row = `i' + 1
		if missing(`var'[`i']) & active[`i'] == "2" {
			di as error "[Error: csv file] Content under `var' is mandatory for generating variables (row `row')"
			local data_error = 1
			local evargen = 1
		}
	}
}
if "`verbose'" == "verbose" & `evargen' == 0 {
	di ""
	di "No error to report"
}

* Checking if delta has any observation with value 0

************************************* verbose ********************************************
if "`verbose'" == "verbose" {
	di ""
	di "Checking if delta has any observation with value 0"
}
******************************************************************************************

local edelta1 = 0
forvalues i =1/`tot' {
	local row = `i' + 1
	if delta[`i'] == "0" {
		di as error "[Error: csv file] Please do not provide any value for attribute delta for checks where delta = 0 (row `row')"
		local data_error = 1
		local edelta1 = 1
	}
}
if "`verbose'" == "verbose" & `edelta1' == 0 {
	di ""
	di "No error to report"
}

* Checking if delta has observations with non-numerical values

************************************* verbose ********************************************
if "`verbose'" == "verbose" {
	di ""
	di "Checking if delta has observations with non-numerical values"
}
******************************************************************************************

local edelta2 = 0
local num "123456789.0"
forvalues i=1/`tot' {
	local row = `i' + 1
	local error_delta = 0
	local delta = delta[`i']
	local len = length("`delta'")
	forvalues j = 1/`len' {
		local delta`j' = substr("`delta'", `j', 1)
		if regexm("`num'","`delta`j''") == 0 {
			local error_delta = `error_delta' + 1
		}
	}
	if `error_delta' == 1 & active[`i'] == "1" {
		di as error "[Error: csv file] Values for delta must be numerical (row `row')"
		local data_error = 1
		local edelta2 = 1
	}
}
if "`verbose'" == "verbose" & `edelta2' == 0 {
	di ""
	di "No error to report"
}

* Checking if list_val has observations with non-numerical values when not missing

************************************* verbose ********************************************
if "`verbose'" == "verbose" {
	di ""
	di "Checking if list_val has observations with non-numerical values when not missing"
}
******************************************************************************************

local elist_val=0
local num_space "123456789.0 "
forvalues i = 1/`tot' {
	local row = `i' + 1
	local error_list = 0
	local list_val = list_val[`i']
	local len = length("`list_val'")
	forvalues j = 1/`len' {
		local list_val`j' = substr("`list_val'", `j', 1)
		if regexm("`num_space'","`list_val`j''") == 0 {
			local error_list = `error_list' + 1
		}
	}
	if `error_list' != 0  & active[`i'] == "1" {
		di as error "[Error: csv file] Values for list_val must be numerical (row `row')"
		local data_error = 1
		local elist_val = 1
	}
}
if "`verbose'" == "verbose" & `elist_val' == 0 {
	di ""
	di "No error to report"
}

return local data_error = `data_error' 

************************************* verbose ********************************************
if "`verbose'" == "verbose" {
	di ""
	di "Returned locals:"
	di ""
	di "local data_error: `data_error'"
}
******************************************************************************************

************************************* verbose ********************************************
if "`verbose'" == "verbose" {
	di ""
	di "------------------------ end checkmd_vdata.ado ------------------------------"
}
******************************************************************************************


end
