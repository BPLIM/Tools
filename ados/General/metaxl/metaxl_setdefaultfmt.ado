*! version 0.1 5Feb2021
* Programmed by Gustavo Iglésias

program define metaxl_setdefaultfmt

syntax varlist

di

foreach var of varlist `varlist' {
	local vtype: type `var'
	if "`vtype'" == "byte" {
	    local format "%8.0g"
	}
	else if "`vtype'" == "int" {
	    local format "%8.0g"
	}
	else if "`vtype'" == "long" {
	    local format "%12.0g"
	}
	else if "`vtype'" == "float" {
	    local format "%9.0g"
	}
	else if "`vtype'" == "double" {
	    local format "%10.0g"
	}
	else if substr("`vtype'", 1, 3) == "str" {
	    if substr("`vtype'", 4, 1) == "L" {
		    local format "%9s"
		}
		else {
		    local num = substr("`vtype'", 4, .)
			local format "%`num's"
		}
	}
	di as result "`var'" as text " format set to `format'"
	format `format' `var'
}

end
