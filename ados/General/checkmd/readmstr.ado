// This program splits the string option merge in the program check_consistency into different options (file type key [obs_keep keep1 keep2])


program define readmstr, rclass


syntax, merge(string) [verbose]

************************************* verbose ********************************************
if "`verbose'" == "verbose" {
	di ""
	di "------------------------ begin readmstr.ado ----------------------------"
}
******************************************************************************************

// Errors 

************************************* verbose ********************************************
if "`verbose'" == "verbose" {
	di ""
	di "Errors in option merge regarding file, type and key (mandatory)"
}
******************************************************************************************

if regexm(`"`merge'"', "file") == 0 {
	di as error "You must provide a file name for option merge -> ex: file(filename)"
	error 1
}
else {
	if "`verbose'" == "verbose" {
		di ""
		di "No error to report in option file"
	}
}
	

if regexm(`"`merge'"', "type") == 0 {
	di as error "Option type is mandatory for merges -> ex: type(1:1)"
	error 1
}
else {
	if "`verbose'" == "verbose" {
		di ""
		di "No error to report in option type"
	}
}

if regexm(`"`merge'"', "key") == 0 {
	di as error "A key variable(s) is necessary to merge two files -> ex: key(variable(s) name(s))"
	error 1
}
else {
	if "`verbose'" == "verbose" {
		di ""
		di "No error to report in option key"
	}
}

// Spliting merge into options 

************************************* verbose ********************************************
if "`verbose'" == "verbose" {
	di ""
	di "Spliting merge into options"
}
******************************************************************************************

local i = 1
local case = 0
while `case' == 0 {
	gettoken first merge: merge, parse(") ")
	local op`i' = `"`first'"'
	if length(`"`first'"')==0 {
		local case = 1
	}
	local i = `i' + 1
}

local lim = `i'-2

local words = "file type key obs_keep keep1 keep2"
foreach item in `words' {
	forvalues i=1/`lim' {
		local prev = `i' - 1
		if mod(`i',2) == 0 {
			local op = `"`op`prev''"' + `"`op`i''"'
			if regexm(`"`op'"',"`item'") == 1 {
				local `item' = `"`op'"'
			}
		}
	}
	if length(`"``item''"') == 0 {
		local `item' = "none"
	}
}


// Program getopt, to get the inputs inside parenthesis (defined at the bottom)

local words = "file type key obs_keep keep1 keep2"
foreach item in `words' {
	if length(`"``item''"') == 4 {
		local `item' = "none"
	}
	else if length(`"``item''"') > 4 {
		getopt `"``item''"'
		local `item' = "`r(opt)'"
	}

}

// Replacing "," by space in obs_keep keep1 keep2

local wordsl = "obs_keep keep1 keep2 key"
foreach item in `wordsl' {
	if `"``item''"' != "none" {
		local `item' = subinstr(`"``item''"',","," ",500)
	}
}

// Errors

************************************* verbose ********************************************
if "`verbose'" == "verbose" {
	di ""
	di "Input errors for options type and key"
}
******************************************************************************************

if "`type'" != "1:1" & "`type'" != "m:1" & "`type'" != "1:m" {
	di as error "option type only allows three inputs: 1:1, 1:m or m:1"
	error 1
}
else {
	if "`verbose'" == "verbose" {
		di ""
		di "No input errors for option type found"
	}
}


local error_obs1 = 0
foreach item in `obs_keep' {
	if "`item'" != "1" & "`item'" != "2" & "`item'" != "3" & "`item'" != "none" {
		di as error "option obs_keep only allows three inputs: 1, 2 or 3 (with possible combinations between them)"
		error 1
		local error_obs1 = `error_obs1'+1
	}
}

local error_obs2 = 0
if "`obs_keep'" != "none" {
	local wcount: word count `obs_keep'
	if `wcount' == 3 {
		di as error "The option obs_keep was wrongly specified. Please note that for this option you only need to pass # (or # #)" 
		di as error "as an argument, meaning that observations that satisfy _merge == # will be kept in the dataset. To keep all " 
		di as error "observations, please do not specify this option"
		error 1
		local error_obs2 = `error_obs2'+1
	}
}

if `error_obs1' == 0 & `error_obs2' == 0 & "`verbose'" == "`verbose'" {
	di ""
	di "No input errors for option obs_keep found"
}


return local file = `"`file'"'
return local type = `"`type'"'
return local key = `"`key'"'
return local obs_keep = `"`obs_keep'"'
return local keep1 = `"`keep1'"'
return local keep2 = `"`keep2'"'

************************************* verbose ********************************************
if "`verbose'" == "verbose" {
	di ""
	di "Returned locals:"
	di ""
	di `"local file		: `file'"'
	di `"local type		: `type'"'
	di `"local key		: `key'"'
	di `"local obs_keep	: `obs_keep'"'
	di `"local keep1	: `keep1'"'
	di `"local keep2	: `keep2'"'
}
******************************************************************************************



************************************* verbose ********************************************
if "`verbose'" == "verbose" {
	di ""
	di "------------------------ end readmstr.ado ------------------------------"
}
******************************************************************************************

end


program define getopt, rclass

args arg

gettoken first arg: arg, parse("(")
gettoken second arg: arg, parse("(")
gettoken third arg: arg, parse(")")

return local opt = `"`third'"'

end
