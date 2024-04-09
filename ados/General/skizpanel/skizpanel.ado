*! 0.2 27feb2024

program define skizpanel

syntax varlist (min=2 max=2), [VARiables(string) NOGAPS APPEND(string) COUNTVAR(string) IGNORECASE SKIZAGAIN REPORT STATS]
tokenize `varlist'
tempvar dif dum spell nn end_date

local id `1'
local date `2'
if "`countvar'" == "" {
	local nrep _nrep
}
else {
	local nrep `countvar'
}

* Confirm paneldata
qui xtset `id' `date' 

* Confirm the possibility of the options append and skizagain
if ("`append'" != "" | "`skizagain'" != "") & "`_dta[skizpanel]'" == "" {
	di "{err:the file in memory should be a skizpanel}"
	exit
}

if ("`append'" != "" | "`skizagain'" != "") & "`countvar'" == "" {
	local nrep _nrep
} 

if "`append'" != "" {
	qui sum `date'
	local min_use = `r(min)'
	local max_use = `r(max)'

	preserve
	qui use "`append'", clear
	qui sum `date'
	local min_append = `r(min)'
	local max_append = `r(max)'
	* Confirmar se o append está skizado
	if "`_dta[skizpanel]'" == "" {
		di "{err:the append file shoud be a skizpanel}"
		exit
	}
	restore

	if `min_append' <= `max_use' & `min_use' <= `max_append' {
		di "{err:the append file is contain on the file in memory so data overlap will happen}"
		exit
	}
}

if "`stats'" == "stats" {
	stats, id(`id') nrep(`nrep')
}
else {

* Define characteristics
char _dta[skizpanel] "skizpanel"
if "`variables'" != "" {
	char _dta[option_variables] "var(`variables')"
}
if "`nogaps'" == "nogaps" {
	char _dta[option_nogaps] "nogaps"
}
if "`append'" != "" {
	char _dta[option_append] "append(`append')"
}
if "`countvar'" != "" {
	char _dta[option_countvar] "countvar(`countvar')"
}
if "`ignorecase'" == "ignorecase" {
	char _dta[option_ignorecase] "ignorecase"
}
if "`skizagain'" == "skizagain" {
	char _dta[option_skizagain] "skizagain"
}

di
di "Before skiz"
qui count
di "Number of observations: `r(N)'" 
local obs `r(N)'
qui preserve
qui contract `id' 
qui count 
di "Number of unique ids: `r(N)'"
local ids `r(N)'
qui restore
di "Ratio between unique ids and observations (%): " round((`ids' / `obs') * 100, 0.01) 	

if "`append'" != "" {
	qui append using "`append'"
}

if "`variables'" == "" {
	qui ds
	local variables `r(varlist)'
	local variables: list variables - date
	if "`append'" != "" | "`skizagain'" != "" {
		local variables: list variables - nrep
	}
}
else {
	parse_variablesarg, arg(`variables')
	local variables `r(varlist)'
	local variables: list variables - date
	local variables: list variables - id
	if "`append'" != "" | "`skizagain'" != "" {
		local variables: list variables - nrep
	}
	local variables `1' `variables' 
	
	if "`r(keepvars)'" == "" {
		if "`append'" != "" | "`skizagain'" != "" {
			keep `variables' `date' `nrep'
		} 
		else {
			keep `variables' `date'
		}
	}
}

if "`ignorecase'" == "ignorecase" {
	foreach var of local variables {
		qui local vartype: type `var'
		if "`vartype'" != "byte" & "`vartype'" != "int" & "`vartype'" != "long" & "`vartype'" != "float" & "`vartype'" != "double" {
			qui replace `var' = strlower(`var')
		}
	}
}

foreach var of local variables {
	local cond = "`cond'" + "(`var' == `var'[_n-1]) & "
}

local len_string: strlen local cond
local num = `len_string' - 2
local cond1 = substr("`cond'", 1, `num')

sort `id' `date'

if "`nogaps'" == "" {
	if "`append'" != "" | "`skizagain'" != "" {
		qui gen `end_date' = `date' + `nrep' - 1
    	qui format `end_date' %tdDD/NN/CCYY
		qui gen int `dif' = `date' - `end_date'[_n-1]
	}
	else {
		qui gen int `dif' = `date' - `date'[_n-1]
	}
	qui gen byte `dum' = `cond1' & `dif' == 1
}
else {
	qui gen byte `dum' = `cond1'
}

qui gen int `spell' = 1 in 1
qui replace `spell' = `spell'[_n-1] + (1 - `dum') if _n > 1

if "`append'" != "" | "`skizagain'" != "" {
	qui bysort `spell': egen NN = total(`nrep')
	qui drop `nrep'
	qui rename NN `nrep' 
}
else {
	qui bysort `spell': gen `nrep' = _N
}

if "`nogaps'" == "nogaps" {
	qui sort `id' `date'
	qui bysort `spell': gen ntot = `date'[_N] - `date'[1] + 1
	qui bysort `spell': gen _nmiss = ntot - `nrep'
	qui drop ntot
	qui label variable _nmiss "number of dates missing"
}

qui bysort `spell': gen `nn' = _n
if "`r(keepvars)'" == "last" {
	qui bysort `spell': keep if `nn' == _N
}
else {
	qui bysort `spell': keep if `nn' == 1
}

qui label variable `nrep' "number of repetitions"


di
di "After skiz"
qui sum `nrep' [iweight = `nrep']
local pobs `r(sum_w)'
di "Number of observations: `r(N)'" 
local obs `r(N)'
qui preserve
qui contract `id' 
qui count 
di "Number of unique ids: `r(N)'"
local ids `r(N)'
qui restore
di "Ratio between unique ids and observations (%): " round((`ids' / `obs') * 100, 0.01) 

di
di "Skizpanel is " round((`obs' / `pobs') * 100, 0.01) "% of the original panel"	

* Rename nrep
if "`countvar'" == "" {
	qui rename `nrep' _nrep
}
else {
	qui rename `nrep' `countvar'
}

if "`report'" == "report" {
	difreport, variables(`variables') id(`id')
}

}

end

program define parse_variablesarg, rclass

	/*
	Parse arguments in option variables. Must be of the form: 
		variables(varlist, keepvars(first | last))
	*/
	
	syntax, arg(str) 

	local comma_pos = strpos("`arg'", ",")
	if `comma_pos' == 0 {
		local firstarg `arg'
		return local varlist `firstarg'
	}
	else {
		local firstarg = trim(substr("`arg'", 1, `comma_pos' - 1))
		local lastarg = trim(substr("`arg'", `comma_pos' + 1, .))

		* Get keepvars sub-option
		gettoken keepvars lastarg: lastarg, p("(")
		local keepvars = trim("`keepvars'")

		* Get observation 
		gettoken lixo lastarg : lastarg, p("(")	
		gettoken obs lastarg : lastarg, p(")")
		local obs = trim("`obs'")
		
		return local varlist `firstarg'
		return local keepvars `obs'
	}

end

program define difreport

syntax, variables(str) id(str)

di
di "Changes report"

if "`_dta[option_nogaps]'" == "nogaps" {
	qui count if _nmiss > 0
	di "Number of time gaps: `r(N)'"
	local nmiss _nmiss
	local variables: list variables - nmiss
}
else {
	di "Skizpanel without nogaps option"
}

local variables: list variables - id

di
foreach var of local variables {
	qui sort id `date'
	qui gen dif_`var' = 0
	qui bysort id: replace dif_`var' = 1 if `var' != `var'[_n-1] & _n > 1
	qui egen count_`var' = total(dif_`var')
	di "Changes in variable `var': " count_`var'
}

drop dif* count*

end

program define stats

syntax, id(str) nrep(str)

di
di "Stats"

qui sum `nrep' [iweight = `nrep']
di
di "Number of observations before the skiz: `r(sum_w)'"
di "Number of observations after the skiz: `r(N)'"
di "Skizpanel is " round((`r(N)' / `r(sum_w)') * 100, 0.01) "% of the original panel"

di 
qui preserve
qui contract id
qui count
di "Number of unique ids: `r(N)'"
qui restore

di
di "Descriptive statistics"
qui ds
local variables `r(varlist)'
local name name
local brand brand
local notes notes
local variables: list variables - name
local variables: list variables - brand
local variables: list variables - notes

sum `variables' [iweight = `nrep'], format

end