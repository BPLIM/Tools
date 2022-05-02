*! version 0.1 23Feb2021
* Programmed by Gustavo Iglésias

program define bp_get_type, rclass

syntax varlist(min=1 max=1)

qui count 
local total = `r(N)' 
qui count if missing(`varlist')
local miss_total = `r(N)'
if `miss_total' == `total' {
	return local type = 0
}
else {
	cap confirm numeric variable `varlist'
	if _rc { 
		qui replace `varlist' = trim(`varlist')
		qui count 
		local total = `r(N)' 
		qui count if missing(`varlist')
		local miss_total = `r(N)'
		if `miss_total' == `total' {
			return local type = 0
		}
		else {
			tempvar destrvar
			qui destring `varlist', gen(`destrvar') force
			qui count if missing(`destrvar')
			if `r(N)' == `miss_total' {
				return local type = 1
			}
			else if `r(N)' == `total' {
				return local type = 2
			}
			else {
				return local type = 3
			}
		}
		drop `destrvar'
	}
	else {
		return local type = 1
	}
}

end