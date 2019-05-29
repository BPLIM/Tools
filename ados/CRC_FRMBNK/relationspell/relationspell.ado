*! version 2.0 26May2017
* Programmed by Emma Zhao


* Programmed by Emma Zhao
*! 2.0 Emma Zhao 26May2017
* uses two connected ID variables (i.e., firm, bank) and a date variable (monthly frequency) as arguments 
* uses start year and end year as options
* flags relationship status and returns a variable _relation_valid with following values:
* 0 - Relationship Discontinuity
* 1 - Relationship Presence
* Dependencies:
* requires installation of package tsspell


capture program drop relationspell
program define relationspell
*set trace on


syntax varlist(min=3 max=3) [, STArtyr(integer 1980) FINyear(integer 2015) FREquency(integer 2) GAPs(integer 0)]
version 13
tokenize `varlist'

tempvar firm bank pair1 first pair2 td year dup dup2 min max len_type len_active len_inactive
tempfile temp
capture drop _mindate _maxdate _relation_valid _spell _len _len_all _mindate_spell _maxdate_spell

if `frequency'==1 {
qui gen `year' = year(`3')				
}
if `frequency'==2 {
qui gen `td' = dofm(`3')
qui format `td' %td
qui gen `year' = yofd(`td')				
}
if `frequency'==3 {
qui gen `year' = `3'				
}

*keep if `year'>=`startyr' & `year'<=`finyear'
drop if `year'<`startyr' 
drop if `year'>`finyear'

qui tostring `1', gen(`firm')
qui tostring `2', gen(`bank')
qui gen `pair1'= `firm'+ "_"+ `bank'
bysort `pair1': gen `first'=_n==1
gen `pair2' = sum(`first')
tsset `pair2' `3'
qui egen _mindate=min(`3'), by(`pair2')
qui egen _maxdate=max(`3'), by(`pair2')
if `frequency'==1 {
qui format %td _mindate
qui format %td _maxdate
}
if `frequency'==2 {
qui format %tm _mindate
qui format %tm _maxdate
}
qui gen _relation_valid=1


tsset `pair2' `3'
qui tsspell _relation_valid
qui egen _mindate_spell=min(`3'), by(`pair2' _spell)
qui egen _maxdate_spell=max(`3'), by(`pair2' _spell)
if `frequency'==1 {
qui format %td _mindate_spell
qui format %td _maxdate_spell				
}
if `frequency'==2 {
qui format %tm _mindate_spell
qui format %tm _maxdate_spell
}
qui bysort `pair2' _spell : gen _len = _N
qui gen _len_all= _maxdate- _mindate+1
qui drop `3' _seq _end
qui sort `1' `2' _relation_valid _spell
quietly by `1' `2' _relation_valid _spell: gen `dup'=cond(_N==1, 0,_n)
qui keep if `dup'<2 & `dup' ~=.
qui rename _len _len_spell
drop _spell
save `temp', replace


gen `min'=_maxdate_spell[_n-1]+1 if `pair2' ==`pair2'[_n-1]
gen `max'= _mindate_spell-1
replace `max'=. if `min' ==.
if `frequency'==1 {
format `min' %td
format `max' %td				
}
if `frequency'==2 {
format `min' %tm
format `max' %tm
}
drop _mindate_spell _maxdate_spell _len_spell
drop if `min'==.
gen _len_spell= `max'- `min'+1
qui rename `min' _mindate_spell
qui rename `max' _maxdate_spell
replace _relation_valid=0
append using `temp'
qui sort `1' `2'  _mindate_spell _maxdate_spell
qui bysort `1' `2': gen _spell=_n
qui order `1' `2'  _relation_valid _spell _mindate_spell _maxdate_spell _len_spell


* allow relation gaps
drop if _len_spell< `gaps' & _relation_valid==0
replace _spell= _spell[_n-1] if `1'==`1'[_n-1] & `2'==`2'[_n-1] & _relation_valid== _relation_valid[_n-1]

egen _mindate_spell2 =min(_mindate_spell), by(`1' `2' _spell)
egen _maxdate_spell2 =max(_maxdate_spell), by(`1' `2' _spell)
drop _mindate_spell _maxdate_spell _spell _len_spell
rename _mindate_spell2 _mindate_spell
rename _maxdate_spell2 _maxdate_spell
bysort `1' `2' _relation_valid _mindate _maxdate _len_all _mindate_spell _maxdate_spell: gen `dup2'=cond(_N==1, 0,_n)
keep if `dup2'==1 | `dup2'==0
sort `1' `2' _mindate_spell _maxdate_spell _relation_valid
bysort `1' `2': gen _spell=cond(_N==1, 0,_n)
replace _spell=1 if _spell==0
qui egen _nb_spell=count(_spell), by(`1' `2')
gen _len_spell= _maxdate_spell-_mindate_spell+1
gen _relation= `pair2'

egen `len_type'=sum(_len_spell), by(`1' `2' _relation_valid)
gen `len_active'= `len_type' if _relation_valid==1
gen `len_inactive'= `len_type' if _relation_valid==0
egen _len_act=min(`len_active'), by(`1' `2')
egen _len_inact=min(`len_inactive'), by(`1' `2')
replace _len_act=0 if _len_act==.
replace _len_inact=0 if _len_inact==.



* formatting
order `1' `2' _relation _relation_valid _spell _mindate_spell _maxdate_spell _len_spell _nb_spell _mindate _maxdate _len_all
capture label drop _relation_valid _spell _mindate_spell _maxdate_spell _len_spell _mindate _maxdate _len_all _len_act _len_inact

label var _relation "Relationship indicator"
label var _spell "Relationship spell order"
label var _mindate_spell "Start of a relationship spell"
label var _maxdate_spell "End of a relationship spell"
label var _len_spell "Length of a relationship spell"
label var _nb_spell "Number of a relationship spell"
label var _mindate "Start of a bank-firm relationship"
label var _maxdate "End of a bank-firm relationship"
label var _len_all "Length of relationship"
label var _len_act "Length of active relationship"
label var _len_inact "Length of inactive relationship"
label var _relation_valid "Status of relationship"
label define _relation_valid_values 0 "Discontinued" 1 "Valid"
label values _relation_valid _relation_valid_values
tab _relation_valid

end
