program define unskizpanel

syntax varlist (min=2 max=2), [FILLGaps MISSVAR(str) COUNTVAR(str)]
tempvar nn ntot
tokenize `varlist'
local id `1'
local date `2'

if "`countvar'" == "" {
	local nrep _nrep
}
else {
	local nrep `countvar'
}

if "`missvar'" == "" {
    local nmiss _nmiss
}
else {
    local nmiss `missvar'
}

* Verificar que temos um skizpanel
if "`_dta[skizpanel]'" == "" {
    di "{err:the command can only be use in a skizpanel}"
    exit
}
if "`dta[option_nogaps]'" == "nogaps" & "`fillgaps'" == "" {
    di "{err:the option {bf:nogaps} was use to skiz the original panel, so the unskiz is not allow}"
    exit
}
if "`_dta[option_variables]'" != "" {
    local comma_pos = strpos("`_dta[option_variables]'", ",")
    if `comma_pos' > 0 {
        di "{err:the suboption {bf:keepvars} was use to skiz the original panel, so the unskiz is not allow}"
        exit
    }
}
if "`fillgaps'" != "" & "`_dta[option_nogaps]'" == "" {
    di "{err:the option {bf:fillgaps} can only be used in a skizpanel that was skiz using the option {bf:nogaps}}"
    exit
}

di
di "Before unskiz"
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

* Expand
if "`fillgaps'" == "" {
    qui expand `nrep'
}

* Opção fillgaps
if "`fillgaps'" != "" {
    qui gen `ntot' = `nrep' + `nmiss' 
    qui expand `ntot'
}

* Corrigir as datas
qui bysort `id' `date': gen `nn' = _n
qui bysort `id' `date': replace `date' = `date'[_n-1] + 1 if `nn' > 1
qui drop `nrep'

* _nmiss
if "`_dta[option_nogaps]'" == "nogaps" {
    label variable `nmiss' "number of missing dates in the original data"
}

* Característica
local chardta: char  _dta[ ]
foreach j of local chardta {
	char _dta[`j']
}

char _dta[unskizpanel] "unskizpanel"
if "`fillgaps'" != "" {
    char _dta[option_fillgaps] "fillgaps(`fillgaps')"
}
if "`countvar'" != "" {
    char _dta[option_countvar] "countvar(`countvar')"
}

di
di "After unskiz"
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
di

end