*! version 3.5 18jun2019
* Programmed by Paulo Guimaraes
* Dependencies:
* option checkid requires installation of package group2hdfe (version 1.01 03jul2014)
* panelstat operates faster if gtools command is installed

* To Do
* use r(tdelta) instead of "1"
* create an option for moregap information (module2a)

*---------------------------------------------------------*
* Calculates descriptive statistics for panel data
* Author: Paulo Guimaraes
*---------------------------------------------------------*
program define panelstat, rclass sortpreserve
syntax varlist (min=2 max=2) [if] [in] , [ ///
GAPS /// Analyzes data gaps
RUNS /// Analyzes runs
PATTERN /// /*  */
DEMOG /// /* demography*/
VARS /// /*basic descriptives for all variables*/
CONT /// /* ignores gaps in the time variable*/
NOSUM /// /* do not report summary of panel */
SETMAXPAT(integer 10) /// /* Maximum number of patterns in the data */
EXCEL(string) /// /* output results to excel file*/
KEEPMaxgap(string) /// /* variable contains the largest gap size for the individual*/
KEEPNgaps(string) /// /* variable contains the number of gaps for the individual*/
CHECKID(string) /// /* check whether variable can be used as an id */
DEMOBY(string) /// /* calculates demo variables based on demoby */
ABS(string) /// /* check absolute change within i */
REL(string) /// /* check relative change within i */
WIV(string) /// /* Check consistency of variables constant within ID dimension */
WTV(string) /// /* Check consistency of variables constant within TIME dimension */
TABOVERT(string) /// /*Produces a tab of the variable with # of obs per category over time*/
STATOVERT(string) /// /*Produces descriptive statistics of var over time*/
FLOWS(string) /// /*Calculates the flows for the chosen variables*/
TRANS(string) /// /*creates an indicator showing whether the transition probability is below some level*/
QUANTR(string) /// /* calculates transitions between quantiles over time of a given variable*/
FROMTO(string) /// /*calculate a matrix with number of individuals that move from categories of var at t to s*/
RETURN(string) /// /* Lists all cases where the variable returns to a previous value*/
FORCE1 /// /* if there are repeated i by t makes it work by keeping only one i per t */
FORCE2 /// /* drops all observations with repeated values by i x t */
FORCE3 /// /* drops all observations for individuals that have repeated values of i x t */
FORCESTATA /// /*forces the use of Stata commands*/
ALL ///
]
di
version 13
tokenize `varlist'

********************************************************
* Additional checks on syntax
********************************************************

* Check checkid syntax

if `"`checkid'"' != "" {
check_checkid `checkid'
local checkid "`r(vars)'"
if "`r(keep)'"=="keep" {
local keepcheckid "keepcheckid"
}
}

* Check demoby syntax
if `"`demoby'"' != "" {
check_demoby `demoby'
local demoby "`r(vars)'"
if "`r(keep)'"=="keep" {
local keepdemoby "keepdemoby"
}
if "`r(missing)'"=="missing" {
local missdemoby "missdemoby"
}
}

* Check wiv syntax
if `"`wiv'"' != "" {
check_wiv `wiv'
local wiv "`r(vars)'"
if "`r(keep)'"=="keep" {
local keepwiv "keepwiv"
}
}

* Check wtv syntax and define labels
if `"`wtv'"' != "" {
check_wtv `wtv'
local wtv "`r(vars)'"
if "`r(keep)'"=="keep" {
local keepwtv "keepwtv"
}
}

* Check abs syntax
if `"`abs'"' != "" {
global ps_abst="S"
check_abs `abs'
global ps_nla=r(lags)
global ps_absv=r(absv)
local abs "`r(vars)'"
if "`r(dif)'"=="dif" {
global ps_abst="D"
}
if "`r(keep)'"=="keep" {
local keepabs "keepabs"
foreach var of varlist `abs' {
capture drop _abs_${ps_abst}${ps_nla}_`var'
}
}
}

* Check rel syntax
if `"`rel'"' != "" {
global ps_denlag=1
check_rel `rel'
global ps_nlr=r(lags)
global ps_relv=r(relv)
local rel "`r(vars)'"
if "`r(denlag)'"=="denlag" {
global ps_denlag=0
}
if "`r(keep)'"=="keep" {
local keeprel "keeprel"
}
}

* Check tabovert syntax
if `"`tabovert'"' != "" {
check_tabovert `tabovert'
local tabovert "`r(vars)'"
}

* Check statovert syntax
if `"`statovert'"' != "" {
check_statovert `statovert'
local statovert "`r(vars)'"
}

* Check flows syntax
if `"`flows'"' != "" {
check_flows `flows'
local flows "`r(vars)'"
}

* Check trans syntax
if `"`trans'"' != "" {
check_trans `trans'
local trans "`r(vars)'"
if "`r(keep)'"=="keep" {
local keeptrans "keeptrans"
foreach var of varlist `trans' {
capture drop _trans_`var'
}
}
}

* Check quantr syntax
if `"`quantr'"' != "" {
check_quantr `quantr'
global ps_qtrel ""
global ps_qtmiss "if _tokeep<10 "
local quantr "`r(vars)'"
if "`r(rel)'"=="rel" {
global ps_qtrel ", nofreq row"
}
if "`r(missing)'"=="missing" {
global ps_qtmiss " "
}
if "`r(keep)'"=="keep" {
local keepquantr "keepquantr"
}
}

* Check fromto syntax
if `"`fromto'"' != "" {
check_fromto `fromto'
local fromto "`r(vars)'"
local fromtoval1=r(fromval)
local fromtoval2=r(toval)
}

* Check return syntax
if `"`return'"' != "" {
check_return `return'
local return "`r(vars)'"
local returnval1=r(val1)
local returnval2=r(val2)
local returnval3=r(val3)
}


* gtools
capture which gtools
if _rc==0 {
global ps_gtools "g"
di "Using gtools for faster results"
}
if "$ps_gtools"=="" {
di "You may want to install user-written GTOOLS for faster results"
}

if "`forcestata'"=="forcestata" {
global ps_gtools ""
}

* Set other Parameters
global ps_maxpat=`setmaxpat'

if "`nosum'"=="" {
local basic basic
}

if "`all'"!="" {
local gaps gaps
local runs runs
local pattern pattern
local demog demog
local vars vars
}

* Cleanup
capture drop _ord
capture drop _flag_m_*

* Save copy of data
gen long _ord=_n
preserve

tempvar touse
mark `touse' `if' `in'
qui keep if `touse'

*******************
* Create panel vars
*******************
tempvar i t
qui gengroup `1' `i'

if "`cont'"=="cont" {
tempvar yearst
gen `yearst'=string(`2')
encode `yearst', gen(`t')
drop `yearst'
label var `t' "Time (cont)"
}
else {
qui clonevar `t'=`2'
label var `t' "Time"
}

if "`excel'"!="" {
putexcel clear
gettoken excelfile option: excel, parse(", ")
gettoken left option: option, parse(", ")
if fileexists("`excelfile'.xlsx") {
if "`left'"==","&trim("`option'")=="replace" {
local replace replace
qui putexcel set "`excelfile'.xlsx", replace
putexcel a1=("")
}
if "`left'"==","&trim("`option'")=="modify" {
local modify modify
}
if ("`replace'"=="")&("`modify'"=="") {
di as err "Error: file `excelfile'.xlsx already exists. To rewrite specify the replace option "
error 602
}
}
}
else {
qui putexcel set "`excelfile'.xlsx"
}


if "`force1'"=="force1" {
di
tempvar dumnn
bys `i' `t': gen int `dumnn'=_n
qui count if `dumnn'>1
if r(N)>0 {
di as error "Warning: ignoring " r(N) " observation(s) to ensure unique values per `1' x `2' pair"
qui keep if `dumnn'==1
}
drop `dumnn'
}

if "`force2'"=="force2" {
di
tempvar dumNN
bys `i' `t': gen int `dumNN'=_N
qui count if `dumNN'>1
if r(N)>0 {
di as error "Warning: ignoring " r(N) " observation(s) with multiple values per `1' x `2' pair"
qui keep if `dumNN'==1
}
drop `dumNN'
}

if "`force3'"=="force3" {
di
tempvar dumNN dumN ni 
bys `i' `t': gen int `dumNN'=_N
bys `i': ${ps_gtools}egen `dumN'=total(`dumNN'>1)
${ps_gtools}egen `ni'=tag(`i')
qui count if `dumN'>0&`ni'==1
local nni=r(N)
qui count if `dumN'>0
if r(N)>0 {
di as error "Warning: ignoring all " r(N) " observation(s) of `nni' panel unit(s) that have multiple values per `1' x `2' pair"
qui keep if `dumNN'==1
}
drop `dumNN'
drop `dumN'
drop `ni'
}


if "`vars'"!="" {
qui ds
local allvars "`r(varlist)'"
unab temps: __*
local vars1: list allvars - temps
local ord "_ord `i' `t' `v1' `v2'"
local vars2: list vars1 - ord
foreach var of varlist `vars2' {
local vtype: type `var'
if substr("`vtype'",1,3)!="str" {
local vars3 "`vars3' `var'"
}
local vars4: list vars2 - vars3
}
}


keep _ord `i' `t' `varlist' `wiv' `wtv' `tabovert' `statovert' `flows' `checkid' `abs' `rel' ///
`trans' `quantr' `misvar' `demoby' `fromto' `return' `vars3' `vars4'

xtset, clear
capture xtset `i' `t'
if _rc>0 {
tempvar dumNN
bys `i' `t': gen int `dumNN'=_N
di as error "Invalid Panel: If you have repeated time values consider using option force1, force2, or force3 "
flist `varlist' if `dumNN'>1
error 1
}

*****************************
* Create auxiliary variables
*****************************

sort `i' `t'
qui bys `i' (`t'): gen _nn=_n
qui bys `i' (`t'): gen _NN=_N
label var _NN "Observ per individual"
qui bys `i' (`t'): gen _dift=`t'-`t'[_n-1]-1
qui replace _dift=0 if _nn==1
label var _dift "Size of time gaps"
qui bys `i': ${ps_gtools}egen _ngaps=total(_dift>0)
label var _ngaps "Number of gaps per individual"
bys `i' (`t'): gen _run=_n==1
qui bys `i' (`t'): replace _run=_run[_n-1]+`t'-`t'[_n-1]-1 if _n>1
* Note: Number of runs by individual = # gaps plus 1

**************************
* Variables to retain
**************************
tempfile temp1 temp2 temp3 temp4 temp5 temp6 temp7 temp8 temp9 temp10 temp11 temp12
if "`keepmaxgap'"!=""|"`keepngaps'"!="" {
if "`keepmaxgap'"!="" {
bys `i':  ${ps_gtools}egen int `keepmaxgap'=max(_dift)
label var `keepmaxgap' "Maximum number of gaps"
}
if "`keepngaps'"!="" {
gen int `keepngaps'=_ngaps
label var `keepngaps' "Number of gaps"
}
sort _ord
qui save `temp1'
}

**************************
* Basic panel descriptives
**************************
if "`basic'"=="basic" {
basicdescriptives `i' `t' "`excelfile'"
}

if "`gaps'"=="gaps" {
module2 `i' `t' "`excelfile'"
}

if "`runs'"=="runs" {
module5 `i' `t' "`excelfile'"
}

if "`demog'"=="demog" {
module3 `i' `t' "`excelfile'"
}

if "`pattern'"=="pattern" {
module4 `i' `t' "`excelfile'"
}

if "`vars'"!="" {
varstats `i' _nn _NN "`vars3'" "`vars4'" "`excelfile'"
}

if "`checkid'"!="" {
checkthisid `i' `t' `checkid'
sort _ord
qui save `temp4'
}

if "`demoby'"!="" {
module7 `i' `t' `demoby' "`keepdemoby'" "`missdemoby'" "`excelfile'"
if "`keepdemoby'"!="" {
sort _ord
qui save `temp9'
}
}

if "`wiv'"!="" {
local fr "Analysis of wiv variables"
if "`excelfile'"!="" {
qui putexcel set "`excelfile'.xlsx", sheet("wiv") modify
puttexttoexcel A1 "`fr'"
puttexttoexcel A4 "Total # Obs"
puttexttoexcel A5 "Nonmissing Obs"
puttexttoexcel A6 " % nonmissing"
puttexttoexcel A8 " Minimum value"
puttexttoexcel A9 " Maximum value"
puttexttoexcel A11 "Total i-Obs"
puttexttoexcel A12 "singleton non-missing"
puttexttoexcel A13 "singleton missing"
puttexttoexcel A14 "non-singleton all missing"
puttexttoexcel A15 "non-singleton one valid value"
puttexttoexcel A16 "non-singleton time invariant without missing"
puttexttoexcel A17 "non-singleton time invariant with missing"
puttexttoexcel A18 "non-singleton time variant without missing"
puttexttoexcel A19 "non-singleton time variant with missing"
}
local varwiv ""
local col=3
foreach var of varlist `wiv' {
di _dup(53) "*"
checkvar _nn _NN `i' "`var'" "`1'" "`2'" `col' "`excelfile'"
rename _w_ _wiv_`var'
label values _wiv_`var' _wivlabel
di
di "Distribution of all observations for `var'"
di
tab _wiv_`var'
if "`keepwiv'"!="" {
local varwiv `varwiv' _wiv_`var'
}
local col=`col'+1
}
if "`keepwiv'"!="" {
sort _ord
qui save `temp2'
}
}

if "`wtv'"!="" {
local fr "Analysis of wtv variables"
if "`excelfile'"!="" {
qui putexcel set "`excelfile'.xlsx", sheet("wtv") modify
puttexttoexcel A1 "`fr'"
puttexttoexcel A4 "Total # Obs"
puttexttoexcel A5 "Nonmissing Obs"
puttexttoexcel A6 " % nonmissing"
puttexttoexcel A8 " Minimum value"
puttexttoexcel A9 " Maximum value"
puttexttoexcel A11 "Total t-Obs"
puttexttoexcel A12 "t-singleton non-missing"
puttexttoexcel A13 "t-singleton missing"
puttexttoexcel A14 "non-singleton all missing"
puttexttoexcel A15 "non-singleton one valid value"
puttexttoexcel A16 "non-singleton panel invariant without missing"
puttexttoexcel A17 "non-singleton panel invariant with missing"
puttexttoexcel A18 "non-singleton panel variant without missing"
puttexttoexcel A19 "non-singleton panel variant with missing"
}
local varwtv ""
local col=3
qui bys `t' (`i'): gen _tt=_n
qui bys `t' (`i'): gen _TT=_N
foreach var of varlist `wtv' {
di _dup(53) "*"
checkvar _tt _TT `t' "`var'" "`2'" "`1'" `col' "`excelfile'"
rename _w_ _wtv_`var'
label values _wtv_`var' _wtvlabel
di
di "Distribution of all observations for `var'"
di
tab _wtv_`var'
if "`keepwtv'"!="" {
local varwtv `varwtv' _wtv_`var'
}
local col=`col'+1
}
if "`keepwtv'"!="" {
sort _ord
qui save `temp3'
}
}

if "`abs'"!="" {
checkabsval `i' `t' "`abs'"
label values _abs_* _chglabel
local varabs ""
foreach var of varlist `abs' {
local varabs "`varabs' _abs_${ps_abst}${ps_nla}_`var'"
di
di _dup(53) "*"
di "Absolute changes over time for `var' (threshold set to $ps_absv)"
di _dup(53) "*"
tab _abs_${ps_abst}${ps_nla}_`var'
di
}
if "`keepabs'"!="" {
sort _ord
qui save `temp5'
}
}

if "`rel'"!="" {
checkrelval `i' `t' "`rel'"
label values _rel_* _chglabel
local varrel ""
foreach var of varlist `rel' {
local varrel "`varrel' _rel_L${ps_nlr}_`var'"
di
di _dup(53) "*"
di "Relative changes over time for `var' (threshold set to $ps_relv)"
di _dup(53) "*"
tab _rel_L${ps_nlr}_`var'
di
if $ps_denlag {
di "Note: Relative change is calculated with respect to the average of x_{t} and x_{t-1}"
}
}
if "`keeprel'"!="" {
sort _ord
qui save `temp6'
}
}

if "`tabovert'"!="" {
foreach var of varlist `tabovert' {
tabover `t' "`var'" "`excelfile'"
}
}

if "`statovert'"!="" {
foreach var of varlist `statovert' {
statover `t' "`var'" "`excelfile'"
}
}

if "`flows'"!="" {
foreach var of varlist `flows' {
di _dup(53) "*"
local fr "Time flows for variable `var'"
di "`fr'"
di _dup(53) "*"
if "`excelfile'"!="" {
qui putexcel set "`excelfile'.xlsx", sheet("fl_`var'") modify
}
calcflow `i' `t' "`var'" "`excelfile'"
}
}

if "`trans'"!="" {
di
local vartrans ""
foreach var of varlist `trans' {
di _dup(53) "*"
local fr "Distribution of transition probabilities (t-1 to t) for classes of `var'"
di "`fr'"
di _dup(53) "*"
calctrans `i' `t' "`var'"
local vartrans `vartrans' _trans_`var'
}
if "`keeptrans'"!="" {
sort _ord
qui save `temp7'
}
}

if "`quantr'"!="" {
di
local varquantr ""
foreach var of varlist `quantr' {
di _dup(53) "*"
local fr "changes (t-1 to t) in the quartiles of `var'"
di "`fr'"
di _dup(53) "*"
calcquantr `i' `t' "`var'"
if "`keepquantr'"!="" {
local varquantr `varquantr' _quantr_`var'
rename _tokeep_ _quantr_`var'
}
}
di "Notes:"
di " quartile 1 defined as values below $ps_qtll  "
di " quartile 2 defined as values above $ps_qtll and below $ps_qtul "
di " quartile 3 defined as values above $ps_qtul  "
if "`keepquantr'"!="" {
sort _ord
qui save `temp10'
}
}

if "`fromto'"!="" {
check_valid_time `2' `fromtoval1'
check_valid_time `2' `fromtoval2'
fromto `i' `2' `fromto' `fromtoval1' `fromtoval2' "`excelfile'"
if ${ps_ftkeep} {
sort _ord
qui save `temp12'
}
}

if "`return'"!="" {
check_valid_time `2' `returnval1'
check_valid_time `2' `returnval2'
check_valid_time `2' `returnval3'
returnto `i' `2' `return' `returnval1' `returnval2' `returnval3' "`excelfile'"
if ${ps_rtkeep} {
sort _ord
qui save `temp11'
}
}

***********************************************************************
restore

tempvar mergevar

if "`keepmaxgap'"!=""|"`keepngaps'"!="" {
sort _ord
qui merge 1:1 _ord using `temp1', keepusing(`keepmaxgap' `keepngaps') generate(`mergevar')
drop `mergevar'
}

if "`keepwiv'"!=""&"`wiv'"!="" {
qui merge 1:1 _ord using `temp2', keepusing(`varwiv') generate(`mergevar')
drop `mergevar'
}

if "`keepwtv'"!=""&"`wtv'"!=""{
qui merge 1:1 _ord using `temp3', keepusing(`varwtv') generate(`mergevar')
drop `mergevar'
}

if "`checkid'"!=""&"`keepcheckid'"!="" {
qui merge 1:1 _ord using `temp4', keepusing(_check) generate(`mergevar')
drop `mergevar'
}

if "`abs'"!=""&"`keepabs'"!="" {
qui merge 1:1 _ord using `temp5', keepusing(`varabs') generate(`mergevar')
drop `mergevar'
}

if "`rel'"!=""&"`keeprel'"!="" {
qui merge 1:1 _ord using `temp6', keepusing(`varrel') generate(`mergevar')
drop `mergevar'
}

if "`trans'"!=""&"`keeptrans'"!="" {
qui merge 1:1 _ord using `temp7', keepusing(`vartrans') generate(`mergevar')
drop `mergevar'
}

if "`demoby'"!=""&"`keepdemoby'"!="" {
qui merge 1:1 _ord using `temp9', keepusing(_demoby_`demoby') generate(`mergevar')
drop `mergevar'
if "`missdemoby'"!="" {
qui recode _demoby_`demoby' (.=5)
}
label values _demoby_`demoby' _demobylab
di
di _dup(53) "*"
di "Distribution of _demoby_`demoby' is: "
di _dup(53) "*"
tab _demoby_`demoby'
}

if "`quantr'"!=""&"`keepquantr'"!="" {
qui merge 1:1 _ord using `temp10', keepusing(`varquantr') generate(`mergevar')
drop `mergevar'
}


if "`return'"!=""&${ps_rtkeep} {
capture drop _ret_`return'_`returnval1'_`returnval3'
qui merge 1:1 _ord using `temp11', keepusing(_ret_`return'_`returnval1'_`returnval3') generate(`mergevar')
capture label drop _flag
label define _flag ///
0 "0 not flagged " ///
1 "1 flagged "
label values _ret_`return'_`returnval1'_`returnval3' _flag
}

if "`fromto'"!=""&${ps_ftkeep} {
capture drop _ft_`fromto'_`fromtoval1'_`fromtoval2'
qui merge 1:1 _ord using `temp12', keepusing(_ft_`fromto'_`fromtoval1'_`fromtoval2') generate(`mergevar')
}

* Cleaning up!
capture drop _ord
global drop ps_*
end


program define module2a
args i t excel
preserve
keep `i' `t' _nn _NN _dift _ngaps
local sheet "gaps"
di _dup(53) "*"
local fr "Distribution of the size of the time gaps"
di "`fr'"
di _dup(53) "*"
qui count if _dift>0
if r(N)>0 {
tempname col1 col2
tab _dift if _dift>0, matrow(`col1') matcell(`col2')
if "`excel'"!="" {
qui putexcel set "`excel'.xlsx", sheet(`sheet') modify
puttexttoexcel A1 "`fr'"
puttabtoexcel 1 3 "Size of time gaps" `col1' `col2' `sheet'
}
di
di _dup(53) "*"
local fr "Distribution of the number of gaps by individual"
di "`fr'"
di _dup(53) "*"
tab _ngaps if _nn==1, matrow(`col1') matcell(`col2')
if "`excel'"!="" {
qui putexcel set "`excel'.xlsx", sheet(`sheet') modify
puttexttoexcel E1 "`fr'"
puttabtoexcel 5 3 "Size of time gaps" `col1' `col2' `sheet'
}
di
di _dup(53) "*"
local fr "Size of time gap vs number of gaps per individual"
di "`fr'"
di _dup(53) "*"
tempname mat1 mat2 mat3
tab _dift _ngaps if _dift>0, matcol(`mat1') matrow(`mat2') matcell(`mat3')
if "`excel'"!="" {
qui putexcel set "`excel'.xlsx", sheet(`sheet') modify
puttexttoexcel I1 "`fr'"
puttab2toexcel 9 3 "Size of time gaps" "Number of gaps per individual" `mat1' `mat2' `mat3' `sheet'
}
matrix off=colsof(`mat3')
local pos=off[1,1]+11
di _dup(53) "*"
local fr "Observations per individual vs number of time gaps"
di "`fr'"
di _dup(53) "*"
tab _NN _ngaps if _dift>0,  matcol(`mat1') matrow(`mat2') matcell(`mat3')
if "`excel'"!="" {
excelcol `pos'
local col `r(column)'
qui putexcel set "`excel'.xlsx", sheet(`sheet') modify
puttexttoexcel `col'1 "`fr'"
puttab2toexcel `pos' 3 "Observ per Individual" "Number of gaps per individual" `mat1' `mat2' `mat3' `sheet'
}
di _dup(53) "*"
matrix off=colsof(`mat3')
local pos=off[1,1]+`pos'+2
local fr "Observations per individual vs size of time gaps"
di "`fr'"
di _dup(53) "*"
tab _NN _dift if _dift>0, matcol(`mat1') matrow(`mat2') matcell(`mat3')
if "`excel'"!="" {
excelcol `pos'
local col `r(column)'
qui putexcel set "`excel'.xlsx", sheet(`sheet') modify
puttexttoexcel `col'1 "`fr'"
puttab2toexcel `pos' 3 "Observ per Individual" "Size of time gaps" `mat1' `mat2' `mat3' `sheet'
}
}
else {
di
di "There are no time gaps"
di
}
restore
end

program define module2
args i t excel
preserve
keep `i' `t' _nn _NN _dift _ngaps
local sheet "gaps"
di _dup(53) "*"
local fr "Distribution of the size of the time gaps"
di "`fr'"
di _dup(53) "*"
qui count if _dift>0
if r(N)>0 {
tempname col1 col2
tab _dift if _dift>0, matrow(`col1') matcell(`col2')
if "`excel'"!="" {
qui putexcel set "`excel'.xlsx", sheet(`sheet') modify
puttexttoexcel A1 "`fr'"
puttabtoexcel 1 3 "Size of time gaps" `col1' `col2' `sheet'
}
di
di _dup(53) "*"
local fr "Distribution of the number of gaps by individual"
di "`fr'"
di _dup(53) "*"
tab _ngaps if _nn==1, matrow(`col1') matcell(`col2')
if "`excel'"!="" {
qui putexcel set "`excel'.xlsx", sheet(`sheet') modify
puttexttoexcel E1 "`fr'"
puttabtoexcel 5 3 "Size of time gaps" `col1' `col2' `sheet'
}
di
}
else {
di
di "There are no time gaps"
di
}
restore
end


program define module3
args i t excel
preserve
local sheet "demog"
keep `i' `t'
sort `i' `t'
gen total=1
label var total "Total"
bys `i' (`t'): gen inc1=(`t'-`t'[_n-1]==1)
gen entry=1-inc1
by `i' (`t'): gen first=_n==1
gen reent=ent-first
by `i' (`t'): gen inc2=(`t'[_n+1]-`t'==1)
gen exit=1-inc2
by `i' (`t'): gen last=_n==_N
gen reex=exit-last
${ps_gtools}collapse (sum) total inc1 entry first reent inc2 exit last reex, by(`t') fast
rename `t' time
di _dup(53) "*"
local fr "Time changes - incumbents, entrants and exits"
di "`fr'"
di _dup(53) "*"
list, noobs
di "time - time period"
di "total - total number of individuals at time t "
di "inc1 - number of individuals at t that are also present at t-1 "
di "entry - number of individuals at t that are not present at t-1 "
di "first - number of individuals at t who show up for the first time at t"
di "reent - number of individuals at t that are reentering at time t"
di "inc2 - number of individuals at t that are also present at t+1 "
di "exit - number of individuals at t that are not present at t+1 "
di "last - number of individuals at t that are not present at any future time"
di "reexit - number of individuals at t not present at t+1 that appear in later times"
di
di "the following identities hold:"
di "total[t+1]=total[t]-exit[t]+entry[t+1]"
di "inc1=total-entry)"
di "entry=first+reent"
di "inc2=inc1[t+1]"
di "exit=last+reexit"
if "`excel'"!="" {
qui putexcel set "`excel'.xlsx", sheet(`sheet') modify
qui {
puttexttoexcel A1 "`fr'"
putexcel A3=("time")
putexcel B3=("total")
putexcel C3=("inc1")
putexcel D3=("entry")
putexcel E3=("first")
putexcel F3=("reent")
putexcel G3=("inc2")
putexcel H3=("exit")
putexcel I3=("last")
putexcel J3=("reexit")
}
tempname mat
mkmat _all, mat(`mat')
qui putexcel A4=matrix(`mat'), sheet(`sheet') colwise
}
restore
end

program define module4, sortpreserve
args i t excel
local sheet "pattern"
preserve
keep `i' `t'
sort `i' `t'
qui gen _dum=1
tempvar tt
sum `t', meanonly
gen `tt'=`t'-r(min)+1
local k=r(max)-r(min)+1
drop `t'
qui ${ps_gtools}reshape wide _dum, i(`i') j(`tt')
qui recode _dum1 .=0
qui gen str Pattern=string(_dum1)
if `k'>1 {
forval ct=2/`k' {
capture recode _dum`ct' .=0
qui capture replace Pattern=Pattern+string(_dum`ct')
}
}
${ps_gtools}contract Pattern
rename _freq Frequency
qui count
if r(N)<$ps_maxpat {
global ps_maxpat=r(N)
}
di
di _dup(53) "*"
local fr "Top $ps_maxpat patterns in the data"
di "`fr'"
di _dup(53) "*"
gsort - Frequency
list Pattern Frequency in 1/$ps_maxpat, ab(10)
di
di "Note: 1 if observation is in the dataset; 0 otherwise"
if "`excel'"!="" {
qui putexcel set "`excel'.xlsx", sheet(`sheet') modify
puttexttoexcel A1 "`fr'"
qui putexcel A3=("Pattern")
qui putexcel B3=("Frequency")
forval i=1/$ps_maxpat {
local rowa=Pattern[`i']
local rowb=Frequency[`i']
local row=`i'+3
puttexttoexcel A`row' "`rowa'"
putnumtoexcel B`row' "`rowb'"
}
}
restore
end

program define module5
args i t excel
local sheet "runs"
preserve
keep `i' `t' _run
sort `i' `t'
bys `i' _run: gen N=_N
label var N "Length of run"
bys `i' _run: gen n=_n
di _dup(53) "*"
local fr "Distribution of complete runs by size"
di "`fr'"
di _dup(53) "*"
tempname col1 col2
tab N if n==1, matrow(`col1') matcell(`col2')
if "`excel'"!="" {
qui putexcel set "`excel'.xlsx", sheet(`sheet') modify
puttexttoexcel A1 "`fr'"
puttabtoexcel 1 3 "Lenght of run" `col1' `col2' `sheet'
}
di
restore
end

program define module7
args i t f keep miss excel
preserve
local sheet "demoby"
capture drop if `f'==.
capture drop if `f'==""
qui keep `i' `t' `f' _nn _ord
sort `i' `t'
qui bys `i' (`t'): gen _nnn=_n
gen byte total=1
label var total "Total"
qui bys `i' (`t'): gen byte sing=_N==1
qui bys `i' (`t'): gen byte first=(_n==1)
qui by `i' (`t'): gen byte last=(_n==_N)
qui bys `i' (`t'): gen byte stay=(`f'==`f'[_n-1])
qui sum _nn, meanonly
local maxnn=r(max)-1
qui gen byte rmover=.
forval j=1/`maxnn' {
capture drop var1
capture drop var2
qui bys `i' (`t'): gen byte var1=sum((`f'==`f'[`j'])*_nnn>`j')
qui bys `i' (`t'): gen byte var2=var1==1&var1[_n-1]==0& _nnn>`j'
qui replace rmover=1 if var2==1
}
qui recode rmover .=0
qui replace rmover=rmover-stay
qui gen byte fmover=1-first-rmover-stay
qui gen byte mover=fmover+rmover
if "`keep'"!=""|"`miss'"!="" {
tempfile temp9
qui gen byte _demoby_`f'=first+2*stay+3*fmover+4*rmover
qui save `temp9', replace
}
if "`miss'"=="" {
${ps_gtools}collapse (sum) total first last sing stay mover fmover rmover, by(`t') fast
rename `t' time
di _dup(53) "*"
local fr "Decomposition of changes across `f' over time "
di "`fr'"
di _dup(53) "*"
list, noobs
di "Note: missing values of `f' are discarded for the analysis (to include specify missing option)"
di "time - time period"
di "total - total number of individuals at time t (total=firs+stay+mover)"
di "first - number of individuals at t that show up for the first time"
di "last - number of individuals at t that show up for the last time"
di "singleton - number of individuals at t that show up only that time (singletons)"
di "stayer - number of individuals at t that were present at the same category of `f' since their last observation"
di "mover - number of individuals at t that were present at a different category of `f' since their last observation (mover=fmover+rmover)"
di "fmover - number of movers at t that are for the first time at that category of `f'"
di "rmover - number of movers at t that are returning to a category of `f'"
if "`excel'"!="" {
qui putexcel set "`excel'.xlsx", sheet(`sheet') modify
qui {
puttexttoexcel A1 "`fr'"
putexcel A3=("time")
putexcel B3=("total")
putexcel C3=("first")
putexcel D3=("last")
putexcel E3=("sing")
putexcel F3=("stay")
putexcel G3=("mover")
putexcel H3=("fmover")
putexcel I3=("rmover")
}
tempname mat
mkmat _all, mat(`mat')
qui putexcel A4=matrix(`mat'), sheet(`sheet') colwise
}
}
restore
if "`miss'"!="" {
preserve
qui keep `i' `t' `f' _nn _ord
qui merge 1:1 _ord using `temp9', keepusing(first last sing stay mover fmover rmover)
drop _m
gen byte miss=`f'>=.
gen byte total=1
${ps_gtools}collapse (sum) total miss first last sing stay mover fmover rmover, by(`t') fast
rename `t' time
di _dup(53) "*"
local fr "Decomposition of changes across `f' over time "
di "`fr'"
di _dup(53) "*"
list
di "time - time period"
di "total - total number of individuals at time t (total=miss+first+stay+mover)"
di "miss - total number of individuals with missing information for `f'"
di "first - number of individuals at t that show up for the first time"
di "last - number of individuals at t that show up for the last time"
di "singleton - number of individuals at t that show up only that time (singletons)"
di "stayer - number of individuals at t that were present at the same category of `f' since their last observation"
di "mover - number of individuals at t that were present at a different category of `f' since their last observation (mover=fmover+rmover)"
di "fmover - number of movers at t that are observed for the first time at that category of `f'"
di "rmover - number of movers at t that are observed as returning to a category of `f'"
if "`excel'"!="" {
qui putexcel set "`excel'.xlsx", sheet(`sheet') modify
qui {
puttexttoexcel A1 "`fr'"
putexcel A3=("time")
putexcel B3=("total")
putexcel C3=("miss")
putexcel D3=("first")
putexcel E3=("last")
putexcel F3=("sing")
putexcel G3=("stay")
putexcel H3=("mover")
putexcel I3=("fmover")
putexcel J3=("rmover")
}
tempname mat
mkmat _all, mat(`mat')
qui putexcel A4=matrix(`mat'), sheet(`sheet') colwise
}
restore
}
if "`keep'"!="" {
qui merge 1:1 _ord using `temp9', keepusing(_demoby_`demoby')
drop _merge
}
end

program define basicdescriptives
args i t excel
xtset, clear
qui xtset `i' `t'
* reading from xtset
local tdelta=r(tdelta)
local tmax=r(tmax)
local tmin=r(tmin)
local imax=r(imax)
local imin=r(imin)
di
di as text _dup(53) "*"
di as text "Analyzing `c(filename)'"
di as text _dup(53) "*"
di
if "`excel'"!="" {
qui putexcel set "`excel'.xlsx", sheet("Main") modify
puttexttoexcel A1 "Basic Descriptive Statistics"
puttexttoexcel A3 "filename"
puttexttoexcel B3 "`c(filename)'"
puttexttoexcel A4 "time"
puttexttoexcel B4 "`c(current_time)' - `c(current_date)' "
}
qui count
local totobs=r(N)
di _dup(53) "*"
di "Basic descriptives"
di _dup(53) "*"
di "There are `totobs' time x individuals observations"
if "`excel'"!="" {
puttexttoexcel A6 "time x individuals observations:"
putnumtoexcel B6 `totobs'
}
qui count if _nn==1
local ni=r(N)
di "There are `ni' unique individuals"
if "`excel'"!="" {
puttexttoexcel A7 "Number of unique individuals:"
putnumtoexcel B7 `ni'
}
di "Time values range from `tmin' to `tmax'"
local range=`tmax'-`tmin'+1
di "Maximum time range is `range'"
if "`excel'"!="" {
puttexttoexcel A8 "Minimum time value"
putnumtoexcel B8 `tmin'
puttexttoexcel A9 "Maximum time value"
putnumtoexcel B9 `tmax'
puttexttoexcel A10 "Maximum time range"
putnumtoexcel B10 `range'
}
local avgperin=`totobs'/`ni'
di "The average number of periods per individual is " %4.2f `avgperin'
if "`excel'"!="" {
puttexttoexcel A11 "Average number of periods per individual"
putnumtoexcel B11 `avgperin'
}
local potmax=`ni'*(`tmax'-`tmin'+1)
local share1=100*`totobs'/`potmax'
di "The level of completeness is " %3.2f `share1' "%" " (100% is a fully balanced panel)"
if "`excel'"!="" {
puttexttoexcel A12 "Potential maximum # of cells"
putnumtoexcel B12 `potmax'
puttexttoexcel A13 "Level of completeness"
putnumtoexcel B13 `share1'
}
qui sum _ngaps if _nn==1, meanonly
local avggapi=r(mean)
di "Average number of gaps per individual is "  %4.2f `avggapi'
if "`excel'"!="" {
puttexttoexcel A14 "Average number of gaps per individual"
putnumtoexcel B14 `avggapi'
}
qui sum _dift if _dift>0, meanonly
local avgapsize=r(mean)
local larggap=r(max)
di "Average gap size is " %4.2f `avgapsize'
di "Largest gap is " `larggap'
di _dup(53) "*"
if "`excel'"!="" {
puttexttoexcel A15 "Average gap size is"
putnumtoexcel B15 `avgapsize'
puttexttoexcel A16 "Largest gap"
putnumtoexcel B16 `larggap'
}
*di "Average run size is "
*di "Largest run is "
di
di _dup(53) "*"
local fr "Distribution of number of observations per individual"
local sheet "obsperind"
di "`fr'"
di _dup(53) "*"
tempname col1 col2
tab _NN if _nn==1, matrow(`col1') matcell(`col2')
if "`excel'"!="" {
qui putexcel set "`excel'.xlsx", sheet(`sheet') modify
puttexttoexcel A1 "`fr'"
puttabtoexcel 1 3 "#obs per ind" `col1' `col2' `sheet'
}
*
di
di _dup(53) "*"
local fr "Number of individuals per time unit"
local sheet "indpertime"
di "`fr'"
di _dup(53) "*"
tab `t', matrow(`col1') matcell(`col2')
if "`excel'"!="" {
qui putexcel set "`excel'.xlsx", sheet(`sheet') modify
puttexttoexcel A1 "`fr'"
puttabtoexcel 1 3 "#obs per time unit" `col1' `col2' `sheet'
}
di
end

program define checkthisid
args i t var
tempvar group di dj dmj allmi nvar minv maxv
qui sum `var', meanonly
local mmm=r(max)
qui gen double `nvar'=`var'
qui replace `nvar'=_n+`mmm' if `var'==.
qui group2hdfe `i' `nvar', group(`group')
drop `nvar'
bys `group' (`i'): gen byte `di'=`i'[_N]==`i'[1]
bys `group' (`var'): gen byte `dj'=`var'[_N]==`var'[1]
bys `group' (`var'): gen byte `dmj'=`var'[_N]==.
qui gen byte _check_`var'=0
label var _check "ID checking"
qui replace _check=1 if `di'==1&`dj'==1&`dmj'==0
qui replace _check=2 if `di'==1&`dj'==0&`dmj'==0
qui replace _check=3 if `di'==0&`dj'==1&`dmj'==0
qui replace _check=4 if `di'==0&`dj'==0&`dmj'==0
* Now handle missing values
bys `group' (`var'): gen `allmi'=`var'[1]==.
qui bys `group':  ${ps_gtools}egen double `minv'=min(`var')
qui bys `group':  ${ps_gtools}egen double `maxv'=max(`var')
qui replace _check=5 if `allmi'==1
qui replace _check=6 if `di'==1&`allmi'==0&`minv'==`maxv'&`dmj'==1
qui replace _check=7 if `di'==1&`minv'!=`maxv'&`dmj'==1
qui replace _check=8 if `di'==0&`dmj'==1
capture label drop _checklabel
label define _checklabel ///
1 "1 1:1 ids coincide" ///
2 "2 1:m multiple values of `var' " ///
3 "3 m:1 multiple values of id " ///
4 "4 m:m multiple values of `var' and id " ///
5 "5 1:. all values missing for `var' " ///
6 "6 1:.1 unique values of `var' with missing " ///
7 "7 1:.m multiple values of `var' with missing " ///
8 "8 m:. multiple values of id with missing "
label values _check _checklabel
di _dup(53) "*"
di "Checking if variable `var' can be id"
di _dup(53) "*"
tab _check if _nn==1
di
end

program define checkabsval
args  i t vars
sort `i' `t'
tempvar chg
foreach var of varlist `vars' {
capture drop `chg'
qui gen double `chg'=${ps_abst}${ps_nla}.`var'
qui gen _abs_${ps_abst}${ps_nla}_`var'=0
qui replace _abs_${ps_abst}${ps_nla}_`var'=1 if `chg'>0&`chg'<=$ps_absv
qui replace _abs_${ps_abst}${ps_nla}_`var'=2 if `chg'<0&`chg'>=-$ps_absv
qui replace _abs_${ps_abst}${ps_nla}_`var'=3 if `chg'==0
qui replace _abs_${ps_abst}${ps_nla}_`var'=4 if `chg'>$ps_absv&`chg'<.
qui replace _abs_${ps_abst}${ps_nla}_`var'=5 if `chg'<-$ps_absv
qui replace _abs_${ps_abst}${ps_nla}_`var'=6 if `chg'==.
}
end

program define checkrelval
args  i t vars
sort `i' `t'
tempvar chg
foreach var of varlist `vars' {
capture drop `chg'
qui gen double `chg'=100*(`var'-l${ps_nlr}.`var')*(1+${ps_denlag})/(abs((${ps_denlag}*`var'+l${ps_nlr}.`var')))
qui gen _rel_L${ps_nlr}_`var'=0
qui replace _rel_L${ps_nlr}_`var'=1 if `chg'>0&`chg'<=$ps_relv
qui replace _rel_L${ps_nlr}_`var'=2 if `chg'<0&`chg'>=-$ps_relv
qui replace _rel_L${ps_nlr}_`var'=3 if `chg'==0
qui replace _rel_L${ps_nlr}_`var'=4 if `chg'>$ps_relv&`chg'<.
qui replace _rel_L${ps_nlr}_`var'=5 if `chg'<-$ps_relv
qui replace _rel_L${ps_nlr}_`var'=6 if `chg'==.
}
end

program define checkvar
args nn NN dim var dim1 dim2 pos excel
tempvar dum1 dum2 max min
di
di _dup(53) "*"
di "Analyzing variable `var' within `dim1' "
qui count
local totNN=r(N)
qui count if `nn'==1
local nind=r(N)
local vtype: type `var'
if substr("`vtype'",1,3)!="str" {
local num num
di _dup(53) "*"
qui sum `var', meanonly
local Nvar=r(N)
local Nmin=r(min)
local Nmax=r(max)
calmmvar `dim' `var' `nn' `NN' `dum1'
}
else {
di "`var' is a string variable!"
qui count if `var'!=""
local Nvar=r(N)
calmmvarst `dim' `var' `nn' `NN' `dum1'	
}
local shV=`Nvar'/`totNN'*100
local singnon=r(singnon)
local singmis=r(singmis)
local allmiss=r(allmiss)
local oneval=r(oneval)
local tinvnon=r(tinvnon)
local tinvmis=r(tinvmis)
local tvarnon=r(tvarnon)
local tvarmis=r(tvarmis)
local shsingnon=`singnon'/`nind'*100
local shsingmis=`singmis'/`nind'*100
local shallmiss=`allmiss'/`nind'*100
local shoneval=`oneval'/`nind'*100
local shtinvnon=`tinvnon'/`nind'*100
local shtinvmis=`tinvmis'/`nind'*100
local shtvarnon=`tvarnon'/`nind'*100
local shtvarmis=`tvarmis'/`nind'*100
di 
bys `dim': ${ps_gtools}egen _w_=total(`dum1')  
di "There are " %5.2f `shV' "% nonmissing observations (`Nvar' out of `totNN')"
di
di "For the variable `var' we have:"
if "`num'"=="num" {
di "     values range from `Nmin' to `Nmax'"
}
di "     `singnon' singleton `dim1'-observations with non-missing value (" %5.2f `shsingnon' "%) "
di "     `singmis' singleton `dim1'-observations with missing value (" %5.2f `shsingmis' "%) "
di "     `allmiss' non-singleton `dim1'-observations with all values missing (" %5.2f `shallmiss' "%) "
di "     `oneval' non-singleton `dim1'-observations with only one valid value (" %5.2f `shoneval' "%) "
di "     `tinvnon' non-singleton `dim1'-observations with `dim2' invariant and non-missing values (" %5.2f `shtinvnon' "%) "
di "     `tinvmis' non-singleton `dim1'-observations with `dim2' invariant and missing values (" %5.2f `shtinvmis' "%) "
di "     `tvarnon' non-singleton `dim1'-observations with `dim2' variant and non-missing values (" %5.2f `shtvarnon' "%) "
di "     `tvarmis' non-singleton `dim1'-observations with `dim2' variant and missing values (" %5.2f `shtvarmis' "%) "
if "`excel'"!="" {
excelcol `pos'
local col `r(column)'
puttexttoexcel `col'3 "`var'"
putnumtoexcel `col'4 `totNN'
putnumtoexcel `col'5 `Nvar'
putnumtoexcel `col'6 `shV'
putnumtoexcel `col'8 `Nmin'
putnumtoexcel `col'9 `Nmax'
putnumtoexcel `col'11 `nind'
putnumtoexcel `col'12 `singnon'
putnumtoexcel `col'13 `singmis'
putnumtoexcel `col'14 `allmiss'
putnumtoexcel `col'15 `oneval'
putnumtoexcel `col'17 `tinvnon'
putnumtoexcel `col'16 `tinvmis'
putnumtoexcel `col'19 `tvarnon'
putnumtoexcel `col'18 `tvarmis'
}
end

program define varstats
args i nn NN vars3 vars4 excel
preserve
local sheet "variables"
tempvar dum1 neword
qui keep `i' `nn' `NN' `vars3' `vars4'
local nobs=c(N)+8
qui set obs `nobs'
if "`vars3'"!="" {
foreach var of varlist `vars3' {
capture drop `dum1'
calmmvar `i' `var' `nn' `NN' `dum1'
qui replace `var'=r(singnon) in -1
qui replace `var'=r(singmis) in -2
qui replace `var'=r(allmiss) in -3
qui replace `var'=r(oneval) in -4
qui replace `var'=r(tinvnon) in -5
qui replace `var'=r(tinvmis) in -6
qui replace `var'=r(tvarnon) in -7
qui replace `var'=r(tvarmis) in -8
}
}
if "`vars4'"!="" {
gen long `neword'=_n
foreach var of varlist `vars4' {
capture drop `dum1'
calmmvarst `i' `var' `nn' `NN' `dum1'
drop `var'
gen `var'_st=.
sort `neword'
qui replace `var'_st=r(singnon) in -1
qui replace `var'_st=r(singmis) in -2
qui replace `var'_st=r(allmiss) in -3
qui replace `var'_st=r(oneval) in -4
qui replace `var'_st=r(tinvnon) in -5
qui replace `var'_st=r(tinvmis) in -6
qui replace `var'_st=r(tvarnon) in -7
qui replace `var'_st=r(tvarmis) in -8
}
drop `neword'
}
qui keep in -8/l
qui keep `vars3' `vars4'
qui xpose, clear var
rename _varname variable
order var v8 v7 v6 v5 v4 v3 v2 v1
rename v8 s_nonmiss
rename v7 s_missing
rename v6 allmissing
rename v5 onevalue
rename v4 timeinv_nm
rename v3 timeinv_wm
rename v2 timevar_nm
rename v1 timevar_wm
order var s_nonmiss s_missing allmissing onevalue timeinv_nm timeinv_wm timevar_nm timevar_wm  
sort var
di
di "Distribution of panel units by type of observation for all variables"
di
list, nocompress noobs abb(10)
di "string variables have an _st tag suffix"
di "s_nonmiss - singleton observation with nonmissing value of the variable"
di "s_missing - singleton observation with missing value for the variable"
di "allmissing - non-singleton with all missing values of the variable"
di "onevalue - non-singleton with only one valid value of the variable"
di "timeinv_nm - non-singleton with time-invariant values and nonmissing values for the variable"
di "timeinv_wm - non-singleton with time-invariant values and missing values for the variable"
di "timevar_nm - non-singleton with time-variant values and nonmissing values for the variable"
di "timevar_wm - non-singleton with time-variant values and missing values for the variable"
if "`excel'"!="" {
qui {
qui putexcel set "`excel'.xlsx", sheet(`sheet') modify
puttexttoexcel A1 "Panel unit descriptives of variables "
tempname mat1
mkmat s_nonmiss s_missing allmissing onevalue timeinv_nm timeinv_wm timevar_nm timevar_wm, mat(`mat1')
qui putexcel B4=matrix(`mat1'), sheet(`sheet') colwise
puttexttoexcel B3 "s_nonmiss"
puttexttoexcel C3 "s_missing"
puttexttoexcel D3 "allmissing"
puttexttoexcel E3 "onevalue"
puttexttoexcel F3 "timeinv_nm"
puttexttoexcel G3 "timeinv_wm"
puttexttoexcel H3 "timevar_nm"
puttexttoexcel I3 "timevar_wm"
local NN=_N
forval i=1/`NN' {
local text =var[`i']
local pos=`i'+3
puttexttoexcel A`pos' "`text'"
}
local pos=`pos'+2
puttexttoexcel A`pos' "s_nonmiss - singleton observation with nonmissing value of the variable"
local pos=`pos'+1
puttexttoexcel A`pos' "s_missing - singleton observation with missing value for the variable"
local pos=`pos'+1
puttexttoexcel A`pos' "allmissing - non-singleton with all missing values of the variable"
local pos=`pos'+1
puttexttoexcel A`pos' "onevalue - non-singleton with only one valid value of the variable"
local pos=`pos'+1
puttexttoexcel A`pos' "timeinv_nm - non-singleton with time-invariant values and nonmissing values for the variable"
local pos=`pos'+1
puttexttoexcel A`pos' "timeinv_wm - non-singleton with time-invariant values and missing values for the variable"
local pos=`pos'+1
puttexttoexcel A`pos' "timevar_nm - non-singleton with time-variant values and nonmissing values for the variable"
local pos=`pos'+1
puttexttoexcel A`pos' "timevar_wm - non-singleton with time-variant values and missing values for the variable"
}
}
restore
end

program define tabover
args t var excel
preserve
${ps_gtools}contract `t' `var'
rename _freq n
qui ${ps_gtools}reshape wide n, i(`var') j(`t')
di
di "Tabulation of `var' over time"
list, noobs
di
if "`excel'"!="" {
qui putexcel set "`excel'.xlsx", sheet("tabovert_`var'") modify
export excel using "`excel'.xlsx", sheet("tabovert_`var'") firstrow(variables)
}
restore
end

program define fromto
args i t var fromv tov excel
tempfile file1
preserve
qui keep if `t'==`tov'
keep `i' `var'
rename `var' `var'`tov'
sort `i'
qui save `file1'
restore
preserve
qui keep if `t'==`fromv'
keep `i' `var'
rename `var' `var'`fromv'
sort `i'
qui merge 1:1 `i' using `file1'
drop _m
gen byte _type=4
qui replace _type=1 if (`var'`fromv'<.)&missing(`var'`tov')
qui replace _type=2 if missing(`var'`fromv')&(`var'`tov'<.)
qui replace _type=3 if `var'`fromv'==`var'`tov' &!missing(`var'`tov')
qui drop if missing(`var'`fromv')&missing(`var'`tov')
capture label drop _fromtolabel
label define _fromtolabel 0 "0 not flagged" 1 "1 exit" 2 "2 entry" 3 "3 same" 4 "4 dif"
label values _type _fromtolabel
qui count
if r(N) >0 {
if ${ps_ftkeep} {
tempfile ftkeep
qui save `ftkeep', replace
}
${ps_gtools}contract `var'* _type
rename _freq n
if ${ps_ftmiss} {
qui drop if `var'`fromv'==.|`var'`tov'==.
}
if ${ps_ftasc}>0|${ps_ftdes}>0 {
if ${ps_ftasc} {
sort  n `var'`fromv' `var'`tov'
}
if ${ps_ftdes} {
gsort - n `var'`fromv' `var'`tov'
}
}
else {
gsort - _type `var'`fromv' `var'`tov'
}
di
di "Change of `var' from `fromv' to `tov'"
list, noobs
di
if ${ps_ftsave} {
qui save fromto_`var'_`fromv'_`tov', replace
}
if "`excel'"!="" {
qui putexcel set "`excel'.xlsx", sheet("fromto_`var'_`fromv'_`tov'") modify
export excel using "`excel'.xlsx", sheet("fromto_`var'_`fromv'_`tov'") firstrow(variables)
}
}
if r(N)==0 {
di "Error: There are no valid observations!"
}
restore

if ${ps_ftkeep} {
tempvar mergevar
qui merge m:1 `i' using `ftkeep', keepusing(_type) generate(`mergevar')
qui recode _type (.=0)
qui replace _type=0 if !(`t'==`tov'|`t'==`fromv')
capture drop _ft_`var'_`fromv'_`tov'
rename _type _ft_`var'_`fromv'_`tov'
}
end

program define returnto
args i t var val1 val2 val3 excel
tempfile file1 file2 file3
preserve
qui keep if `t'==`val2'
keep `i' `var'
rename `var' `var'`val2'
sort `i'
qui save `file1'
restore
preserve
qui keep if `t'==`val3'
keep `i' `var'
rename `var' `var'`val3'
sort `i'
qui save `file2'
restore
preserve
qui keep if `t'==`val1'
keep `i' `var'
rename `var' `var'`val1'
sort `i'
qui merge 1:1 `i' using `file1'
drop _m
sort `i'
qui merge 1:1 `i' using `file2'
drop _m
tempvar band
qui gen `band'=`var'`val1'*${ps_rtwit}/100
qui keep if (`var'`val3'<=(`var'`val1'+`band'))&(`var'`val3'>=(`var'`val1'-`band'))
qui drop if `var'`val1'==.
qui drop if `var'`val3'==.
qui drop if (`var'`val2'<=(`var'`val1'+`band'))&(`var'`val2'>=(`var'`val1'-`band'))
if ${ps_rtmiss} {
qui drop if `var'`val2'==.
}
qui count
if r(N)>0 {
if ${ps_rtkeep} {
tempfile rtkeep
qui save `rtkeep', replace
}
${ps_gtools}contract `var'*
rename _freq n
di
di "Return of `var' from `val1' to `val3'"
di
}
qui count
if r(N)==0 {
di "There are no observations!"
}
else {
if ${ps_rtasc} {
sort  n `var'`val1' `var'`val3'
}
if ${ps_rtdes} {
gsort - n `var'`val1' `var'`val3'
}
list, noobs
di
if ${ps_rtsave} {
qui save returnto_`var'_`val1'_`val2'_`val3', replace
}
if "`excel'"!="" {
qui putexcel set "`excel'.xlsx", sheet("return_`var'_`val1'_`val2'_`val3'") modify
export excel using "`excel'.xlsx", sheet("return_`var'_`val1'_`val2'_`val3'") firstrow(variables)
}
}
restore
if ${ps_rtkeep} {
tempvar mergevar
qui merge m:1 `i' using `rtkeep', keepusing(`band') generate(`mergevar')
drop `band'
qui recode `mergevar' (1=0) (3=1)
capture drop _ret_`var'_`val1'_`val3'
rename `mergevar' _ret_`var'_`val1'_`val3'
}
end

program define statover
args t var excel
preserve
keep `var' `t'
tempvar one miss zeros
gen byte `one'=1
gen byte `miss'=missing(`var')
gen byte `zeros'=`var'==0
if ${ps_sodet} {
${ps_gtools}collapse (sum) total=`one' (count) valid=`var' (sum) missing=`miss' (sum) zeros=`zeros' (mean) mean=`var' (sd) sd=`var' ///
(min) min=`var' (max) max=`var' (p1) p1=`var' (p5) p5=`var'  (p25) p25=`var' (p50) p50=`var' (p75) p75=`var' (p95) p95=`var' (p99) p99=`var'  ///
, by(`t') fast
}
else {
${ps_gtools}collapse (sum) total=`one' (count) valid=`var' (sum) missing=`miss' (sum) zeros=`zeros' (mean) mean=`var' (sd) sd=`var' ///
(p25) p25=`var' (p50) p50=`var' (p75) p75=`var' ///
, by(`t') fast
}
char `t'[varname] "time"
di
if ${ps_sodet} {
di "Descriptive statistics of `var' over time (detailed)"
}
else {
di "Descriptive statistics of `var' over time"
}
list, subvar noobs
di
if "`excel'"!="" {
qui putexcel set "`excel'.xlsx", sheet("statovert_`var'") modify
export excel using "`excel'.xlsx", sheet("statovert_`var'") firstrow(variables)
puttexttoexcel a1 "time"
}
restore
end

program define calcflow
args i t var excel
preserve
local sheet "fl_`var'"
keep `i' `t' `var'
tempvar inc inc1 inc2 ent exi exiwm
qui gen n_var=!missing(`var')
qui bys `i' (`t'): gen byte n_inc=(`t'-`t'[_n-1]==1)
qui bys `i' (`t'): gen byte n_ent=(`t'-`t'[_n-1])>1
qui bys `i' (`t'): gen byte n_exi=(`t'[_n+1]-`t'>1)& `t'[_n+1]!=.
qui bys `i' (`t'): gen `exiwm'=(`t'[_n+1]-`t'>1)& `t'[_n+1]!=.&`var'==.
qui gen byte n_inc1=n_inc&missing(`var'[_n-1])
qui gen byte n_inc2=n_inc&missing(`var')
qui gen byte n_inc0=(n_inc-n_inc1-n_inc2)>0
qui gen byte n_ent0=n_ent&!missing(`var')
qui gen byte n_miss=missing(`var')
qui gen c_inc=.
qui replace c_inc=`var'-`var'[_n-1] if n_inc
qui gen c_exp=.
qui gen n_exp=n_inc0&(`var'>`var'[_n-1])
qui replace c_exp=`var'-`var'[_n-1] if n_exp
qui gen c_cont=.
qui gen n_cont=n_inc0&(`var'<`var'[_n-1])
qui replace c_cont=`var'-`var'[_n-1] if n_cont
qui gen c_inc1=.
qui replace c_inc1=`var' if n_inc1
qui gen c_inc2=.
qui replace c_inc2=-`var'[_n-1] if n_inc2
qui gen c_ent=.
qui replace c_ent=`var' if n_ent
${ps_gtools}collapse (sum) `var'  c_* n_* , by(`t') fast
qui gen double chg=`var'-`var'[_n-1]
qui gen double c_exit=chg-c_ent-c_inc-c_inc1-c_inc2
rename `t' time
order time `var' chg c_inc c_exp c_cont c_ent c_exi c_inc1 c_inc2
list time `var' chg c_inc c_exp c_cont c_ent c_exi c_inc1 c_inc2, noobs
di "Notes:"
di "`var' - total sum of `var' at time t"
di "chg - sum of `var' at t minus t-1"
di "c_inc - changes from individuals present at t and at t-1 with valid values of `var'"
di "  of which:"
di "    c_exp - positive changes (expansions) from individuals present at t and at t-1"
di "    c_cont - negative changes (contractions) from individuals present at t and at t-1"
di "c_entry - change resulting from entry (present at t but not at t-1)"
di "c_exit - change resulting from exits (present at t-1 but not at t)"
di "c_inc1 - change from individuals present at t and t-1 but with missing data at t-1"
di "c_inc2 - change from individuals present at t and t-1 but with missing data at t"
di "`var'[t]=`var'[t-1]+chg, chg=c_inc+c_entry+c_exit+c_inc1+c_inc2, c_inc=c_exp+c_cont"
di
if "`excel'"!="" {
qui {
qui putexcel set "`excel'.xlsx", sheet(`sheet') modify
puttexttoexcel A1 "Flows for variable `var'"
putexcel A3=("time")
putexcel B3=("`var'")
putexcel C3=("chg")
putexcel D3=("chg_inc")
putexcel E3=("expansion")
putexcel F3=("contraction")
putexcel G3=("entry")
putexcel H3=("exit")
putexcel I3=("miss_1")
putexcel J3=("miss_2")
tempname mat1
mkmat time `var' chg c_inc c_exp c_cont c_ent c_exi c_inc1 c_inc2, mat(`mat1')
qui putexcel A4=matrix(`mat1'), sheet(`sheet') colwise
}
}
if $ps_flunit {
qui gen n_exi0=n_var[_n-1]-n_var+n_ent0-n_inc2+n_inc1
order time n_var n_miss n_inc0 n_exp n_cont n_ent0 n_exi0 n_inc1 n_inc2
di _dup(53) "*"
local fr "Valid observations for variable `var'"
di "`fr'"
di _dup(53) "*"
list time n_var n_miss n_inc0 n_exp n_cont n_ent0 n_exi0 n_inc1 n_inc2, noobs
di "Notes:"
di "n_var - total number of nonmissing values of `var' at time t"
di "n_miss - number of missing values of `var' at time t"
di "n_inc0 - number of observations with nonmissing values at t and t-1 (incumbents) "
di "  of which:"
di "    n_exp - number of incumbents that increased `var' from time t-1 to t"
di "    n_cont - number of incumbents that decreased `var' from time t-1 to t"
di "n_ent0 - number of entrants with nonmissing values of `var'"
di "n_exi0 - number of exits with nonmissing values of `var'"
di "n_inc1 - number of incumbents with missing values of `var' at t-1 only"
di "n_inc2 - number of incumbents with missing values of `var' at t only"
if "`excel'"!="" {
qui {
qui putexcel set "`excel'.xlsx", sheet(`sheet') modify
puttexttoexcel M1 "Valid observations of `var'"
putexcel L3=("time")
putexcel M3=("n_var")
putexcel N3=("n_miss")
putexcel O3=("n_inc")
putexcel P3=("n_exp")
putexcel Q3=("n_cont")
putexcel R3=("n_ent0")
putexcel S3=("n_exi0")
putexcel T3=("n_inc1")
putexcel U3=("n_inc2")
tempname mat2
mkmat time n_var n_miss n_inc0 n_exp n_cont n_ent0 n_exi0 n_inc1 n_inc2, mat(`mat2')
qui putexcel L4=matrix(`mat2'), sheet(`sheet') colwise
}
}
}
end

program define calcflowold
args i t var excel
preserve
local sheet "fl_`var'"
keep `i' `t' `var'
tempvar inc1
qui bys `i' (`t'): gen `inc1'=(`t'-`t'[_n-1]==1)
gen c_inc=0
qui replace c_inc=`var'-`var'[_n-1] if `inc1'
gen c_exp=0
qui replace c_exp=`var'-`var'[_n-1] if `inc1'&(`var'>`var'[_n-1])
gen c_cont=0
qui replace c_cont=`var'-`var'[_n-1] if `inc1'&(`var'<`var'[_n-1])
gen c_inc1=0
qui replace c_inc1=`var' if `inc1'&missing(`var'[_n-1])
gen c_inc2=0
qui replace c_inc2=-`var'[_n-1] if `inc1'&missing(`var')
gen c_entry=0
qui replace c_entry=`var' if `inc1'==0
${ps_gtools}collapse (sum) `var'  c_* , by(`t') fast
qui gen double chg=`var'-`var'[_n-1]
qui gen double c_exit=chg-c_entry-c_inc-c_inc1+c_inc2
rename `t' time
order time `var' chg c_inc c_exp c_cont c_entry c_exit  c_inc1 c_inc2
list, noobs
di "Notes:"
di "`var' - total sum of `var' at time t"
di "chg - sum of `var' at t minus t-1"
di "c_inc - changes from individuals present at t and at t-1 of which:"
di "    c_exp - positive changes (expansions) from individuals present at t and at t-1"
di "    c_cont - negative changes (contractions) from individuals present at t and at t-1"
di "c_entry - change resulting from entry (present at t but not at t-1)"
di "c_exit - change resulting from exits (present at t-1 but not at t)"
di "c_inc1 - change from individuals present at t and t-1 but with missing data at t-1"
di "c_inc2 - change from individuals present at t and t-1 but with missing data at t"
di "`var'[t]=`var'[t-1]+chg, chg=c_inc+c_entry+c_exit+c_inc1+c_inc2, c_inc=c_exp+c_cont"
di
if "`excel'"!="" {
qui {
qui putexcel set "`excel'.xlsx", sheet(`sheet') modify
puttexttoexcel A1 "Flows for variable `var'"
putexcel A3=("time")
putexcel B3=("`var'")
putexcel C3=("chg")
putexcel D3=("chg_inc")
putexcel E3=("expansion")
putexcel F3=("contraction")
putexcel G3=("entry")
putexcel H3=("exit")
putexcel I3=("miss_1")
putexcel J3=("miss_2")
tempname mat
mkmat _all, mat(`mat')
qui putexcel A4=matrix(`mat'), sheet(`sheet') colwise
}
}
end

program define calctrans, sortpreserve
args i t var
qui {
tempvar lt lx fx NN0 NN1 dum
gen `lx'=l.`var'
gen `lt'=l.`t'
if $ps_transmiss==0 {
gen byte `dum'=!missing(`var')*!missing(`lx')
bys `lt' `t' `var' :${ps_gtools}egen `NN0'=total(`dum')
bys `lt' `t' `var' `lx':${ps_gtools}egen `NN1'=total(`dum')
}
else {
gen byte `dum'=!missing(`var')
bys `t' `var' :${ps_gtools}egen `NN0'=total(`dum')
bys `t' `var' `lx':${ps_gtools}egen `NN1'=total(`dum')
}
gen _trans_`var'=`NN1'/`NN0'*100
qui recode _trans_`var' (0=.)
drop `dum' 
gen `dum'=.
qui replace `dum'=1 if _trans_`var'<$ps_transl
qui replace `dum'=2 if _trans_`var'<$ps_transu & _trans_`var'>=$ps_transl
qui replace `dum'=3 if _trans_`var'<100 & _trans_`var'>=$ps_transu
qui replace `dum'=4 if _trans_`var'==100
label values `dum' _translabel
label var `dum' "Distribution of probabilities"
}
tab `t' `dum'
end

program define calcquantr, sortpreserve
args i t var
qui {
sum `t', meanonly
local start=r(min)
local end=r(max)
tempvar quant
gen int `quant'=.
forval yr=`start'/`end' {
_pctile `var' if `t'==`yr', percentile($ps_qtll $ps_qtul)
qui replace `quant'=1 if `var'<=r(r1) & `t'==`yr'
qui replace `quant'=2 if `var'>r(r1) &  `var'<=r(r2) & `t'==`yr'
qui replace `quant'=3 if `var'>r(r2) & `var'<.  & `t'==`yr'
}
tempvar dum2
capture drop _tokeep_
gen _tokeep_=.
bys `i' (`t'): replace _tokeep_=1 if `quant'==1&`quant'[_n-1]==1
bys `i' (`t'): replace _tokeep_=2 if `quant'==2&`quant'[_n-1]==1
bys `i' (`t'): replace _tokeep_=3 if `quant'==3&`quant'[_n-1]==1
bys `i' (`t'): replace _tokeep_=4 if `quant'==1&`quant'[_n-1]==2
bys `i' (`t'): replace _tokeep_=5 if `quant'==2&`quant'[_n-1]==2
bys `i' (`t'): replace _tokeep_=6 if `quant'==3&`quant'[_n-1]==2
bys `i' (`t'): replace _tokeep_=7 if `quant'==1&`quant'[_n-1]==3
bys `i' (`t'): replace _tokeep_=8 if `quant'==2&`quant'[_n-1]==3
bys `i' (`t'): replace _tokeep_=9 if `quant'==3&`quant'[_n-1]==3
bys `i' (`t'): replace _tokeep_=10 if `quant'==.&`quant'[_n-1]==1
bys `i' (`t'): replace _tokeep_=11 if `quant'==.&`quant'[_n-1]==2
bys `i' (`t'): replace _tokeep_=12 if `quant'==.&`quant'[_n-1]==3
bys `i' (`t'): replace _tokeep_=13 if `quant'==1&`quant'[_n-1]==.
bys `i' (`t'): replace _tokeep_=14 if `quant'==2&`quant'[_n-1]==.
bys `i' (`t'): replace _tokeep_=15 if `quant'==3&`quant'[_n-1]==.
bys `i' (`t'): replace _tokeep_=16 if `quant'==.&`quant'[_n-1]==.
label values _tokeep_ _quantrlabel
label var _tokeep_ "Distribution of quantile changes"
}
tab `t' _tokeep_ $ps_qtmiss $ps_qtrel
end

program define puttexttoexcel
args cell content
qui putexcel `cell'=("`content'")
end

program define putnumtoexcel
args cell content
qui putexcel `cell'=(`content')
end

program define puttabtoexcel
args c r tit1 col1 col2 sheet
tempname one temp col3 mat
excelcol `c'
local colname `r(column)'
local cell1="`colname'"+"`r'"
local cp1=`c'+1
excelcol `cp1'
local colname `r(column)'
local cell2="`colname'"+"`r'"
local cp2=`c'+2
excelcol `cp2'
local colname `r(column)'
local cell3="`colname'"+"`r'"
local nr=`r'+3
excelcol `c'
local colname `r(column)'
local cell4="`colname'"+"`nr'"
matrix `one'=J(1,rowsof(`col1'),1)
matrix `temp'=`one'*`col2'
matrix `col3'=`col2'/`temp'[1,1]
matrix `mat'=(`col1',`col2',`col3')
qui putexcel `cell1'=("`tit1'")
qui putexcel `cell2'=("Frequency")
qui putexcel `cell3'=("Percent")
qui putexcel `cell4'=matrix(`mat'), sheet(`sheet') colwise
end

program define puttab2toexcel
args c r tit1 tit2 mat1 mat2 mat3 sheet
tempname one temp col3 mat
local cp1=`c'+1
local p=`r'+1
excelcol `c'
local colname `r(column)'
local cell1="`colname'"+"`p'"
local p=`r'+3
local cell4="`colname'"+"`p'"
local p=`r'
excelcol `cp1'
local colname `r(column)'
local cell2="`colname'"+"`p'"
local p=`r'+2
local cell3="`colname'"+"`p'"
local p=`r'+3
local cell5="`colname'"+"`p'"
************
qui putexcel `cell1'=("`tit1'")
qui putexcel `cell2'=("`tit2'")
qui putexcel `cell3'=matrix(`mat1'), sheet(`sheet')
qui putexcel `cell4'=matrix(`mat2'), sheet(`sheet') colwise
qui putexcel `cell5'=matrix(`mat3'), sheet(`sheet')
end

* Equivalent to egen group function but faster
program define gengroup
args v1 v2
local vtype: type `v1'
sort `v1'
gen long `v2'=.
if substr("`vtype'",1,3)=="str" {

qui replace `v2'=1 in 1 if trim(`v1')!=""
qui replace `v2'=`v2'[_n-1]+(trim(`v1')!=trim(`v1'[_n-1])) if (trim(`v1')!=""&_n>1)
}
else {
qui replace `v2'=1 in 1 if `v1'<.
qui replace `v2'=`v2'[_n-1]+(`v1'!=`v1'[_n-1]) if (`v1'<.&_n>1)
}
end

* my version of excelcol
program define excelcol, rclass
args num
if `num'<27 {
local col=char(64+`num')
return local column "`col'"
}
if `num'>26&`num'<703 {
local char1=char(64+int(`num'/26))
local char2=char(64+mod(`num',26))
return local column "`char1'`char2'"
}
if `num'>702&`num'<16385 {
local num1=int((`num'-703)/676)
local char1=char(65+`num1')
local num2=`num'-`num1'*676-676
local char2=char(64+int(`num2'/26))
local char3=char(64+mod(`num2',26))
return local column "`char1'`char2'`char3'"
}
if `num'>16384 {
di as error "Error: values above 16384 are not supported"
error 912
}
end

* Check
program define check_valid_time
args time num
qui count if `time'==`num'
if r(N)==0 {
di "Error: argument is not valid. time `num' is not valid"
error 11
}
end

* Syntax checking

*checkid
program define check_checkid, rclass
syntax varlist (min=1 max=1), [Keep ]
return local vars "`varlist'"
return local keep "`keep'"
capture drop _check_`varlist'
capture which group2hdfe
if _rc>0 {
di as err "Error: to use this option you need to install user-written package GROUP2HDFE"
error 1
}
end

*demoby
program define check_demoby, rclass
syntax varlist (min=1 max=1), [Keep Missing]
return local vars "`varlist'"
return local keep "`keep'"
return local missing "`missing'"
if `"`keep'"' == "keep" {
capture drop _demoby_`demoby'
capture label drop _demobylab
label define _demobylab ///
1 "1 first   " ///
2 "2 stayer  " ///
3 "3 fmover  " ///
4 "4 rmover  " ///
5 "5 missing "
}
end

*wiv
program define check_wiv, rclass
syntax varlist, [Keep]
return local vars "`varlist'"
return local keep "`keep'"
if `"`keep'"' == "keep" {
foreach var of varlist `varlist' {
capture drop _wiv_`var'
}
}
capture label drop _wivlabel
label define _wivlabel ///
1 "1 singleton non-missing               " ///
2 "2 singleton missing                   "   ///
3 "3 all values missing                  "  ///
4 "4 one non-missing value               " ///
5 "5 time invariant with non-missing     " ///
6 "6 time invariant with missing         " ///
7 "7 time variant with non-missing       " ///
8 "8 time variant with missing           "
end

*wtv
program define check_wtv, rclass
syntax varlist, [Keep]
return local vars "`varlist'"
return local keep "`keep'"
if `"`keep'"' == "keep" {
foreach var of varlist `varlist' {
capture drop _wtv_`var'
}
}
capture label drop _wtvlabel
label define _wtvlabel ///
1 "1 singleton non-missing            " ///
2 "2 singleton missing                " ///
3 "3 all values missing               " ///
4 "4 one non-missing value            " ///
5 "5 i-invariant with non-missing     " ///
6 "6 i-invariant with missing         " ///
7 "7 i-variant with non-missing       " ///
8 "8 i-variant with missing           "
end

program define check_tabovert, rclass
syntax varlist
return local vars "`varlist'"
end

program define check_statovert, rclass
syntax varlist, [Detail]
return local vars "`varlist'"
global ps_sodet=0
if `"`detail'"' == "detail" {
global ps_sodet=1
}
end

program define check_flows, rclass
syntax varlist, [Unit]
global ps_flunit=0
if `"`unit'"' == "unit" {
global ps_flunit=1
}
return local vars "`varlist'"
end

program define check_trans, rclass
syntax varlist, [Keep Missing Low(int 25) Upper(int 75)]
if `upper'>100 {
di "Upper limit may not exceed 100"
error 111
}
if `upper'<=`low' {
di "Upper limit must be higher than lower liwit"
error 111
}
return local vars "`varlist'"
return local keep "`keep'"
return local miss "`missing'"
global ps_transl=`low'
global ps_transu=`upper'
global ps_transmiss=0
if `"`missing'"' == "missing" {
global ps_transmiss=1
}
if $ps_transu<0|$ps_transu>100 {
di as error "Error: upper treshold cannot be outside the 0-100 interval "
error 11
}
if $ps_transl<0|$ps_transl>100 {
di as error "Error: lower treshold cannot be outside the 0-100 interval "
error 11
}
if $ps_transu<$ps_transl {
di as error "Error: upper treshold ($ps_transu) is lower than lower threshold ($ps_transl) "
error 11
}
if `"`keep'"' == "keep" {
local keeptrans "keeptrans"
foreach var of varlist `varlist' {
capture drop _trans_`var'
}
}
capture label drop _translabel
label define _translabel ///
1 "p<$ps_transl"   ///
2 "$ps_transl<=p<$ps_transu" ///
3 "$ps_transu<=p<100" ///
4 "p=100 " 
end

program define check_quantr, rclass
syntax varlist, [Keep Rel Missing Low(int 25) Upper(int 75)]
if `upper'>100 {
di "Upper limit may not exceed 100"
error 111
}
if `upper'<=`low' {
di "Upper limit must be higher than lower liwit"
error 111
}
return local vars "`varlist'"
return local keep "`keep'"
return local missing "`missing'"
return local rel "`rel'"
global ps_qtll=`low'
global ps_qtul=`upper'
if `"`keep'"' == "keep" {
local keepquantr "keepquantr"
foreach var of varlist `varlist' {
capture drop _quantr_`var'
}
}
capture label drop _quantrlabel
label define _quantrlabel ///
1 "1to1" ///
2 "1to2" ///
3 "1to3" ///
4 "2to1" ///
5 "2to2" ///
6 "2to3" ///
7 "3to1" ///
8 "3to2" ///
9 "3to3" ///
10 "1to." ///
11 "2to." ///
12 "3to." ///
13 ".to1" ///
14 ".to2" ///
15 ".to3" ///
16 ".to."
end

program define check_abs, rclass
syntax varlist, [Keep Dif Lags(integer 1) Val(integer 10)]
return local vars "`varlist'"
return local keep "`keep'"
return local dif "`dif'"
return scalar lags=`lags'
return scalar absv=`val'
if `"`keep'"' == "keep" {
foreach var of varlist `varlist' {
capture drop _abs_${ps_abst}`lags'_`var'
}
}
* Define labels
capture label drop _chglabel
label define _chglabel ///
1 "1 positive change " ///
2 "2 negative change " ///
3 "3 no change       " ///
4 "4 abnormal pos chg"  ///
5 "5 abnormal neg chg"  ///
6 "6 missing         "
end

program define check_rel, rclass
syntax varlist, [Keep DENLag Lags(integer 1) Val(integer 100)]
return local vars "`varlist'"
return local keep "`keep'"
return local denlag "`denlag'"
return scalar lags=`lags'
return scalar relv=`val'
if `"`keep'"' == "keep" {
foreach var of varlist `varlist' {
capture drop _rel_L`lags'_`var'
}
}
* Define labels
capture label drop _chglabel
label define _chglabel ///
1 "1 positive change " ///
2 "2 negative change " ///
3 "3 no change       " ///
4 "4 abnormal pos chg"  ///
5 "5 abnormal neg chg"  ///
6 "6 missing         "
end

program define calmmvar, rclass
args i var nn NN dum
tempvar c1 d1 d2
qui bys `i': gen long `c1'=sum(missing(`var')) if `i'<.
qui bys `i': gen double `d1'=sum(`var')/`nn' if `i'<.
qui bys `i': gen double `d2'=sum(abs(`d1'-`d1'[_N])) if `i'<.
qui gen byte `dum'=.
* Singleton
* 1 - Singleton with nonmissing
qui replace `dum'=1 if (`NN'==1)&(`c1'==0)
* 2 - Singleton with missing
qui replace `dum'=2 if (`NN'==1)&(`c1'==1)
** Multiple with missing
* 3 - all missing
qui replace `dum'=3 if (`NN'>1)&(`c1'==`NN')&(`NN'<.)
* 4 - Missing with one value!
qui replace `dum'=4 if (`NN'>1)&(`nn'==`NN')&(`NN'==(`c1'+1))&(`NN'<.)
* 5 - Non-missing with time-invariant
qui replace `dum'=5 if (`NN'>1)&(`nn'==`NN')&(`c1'==0)&(`d2'==0)&(`NN'<.)
* 6 - missing with time-invariant
qui replace `dum'=6 if (`NN'>1)&(`nn'==`NN')&(`c1'>0)&(`d2'==0)&(`c1'<(`NN'-1))&(`NN'<.)
* 7 - Non-missing with time-variant
qui replace `dum'=7 if (`NN'>1)&(`nn'==`NN')&(`c1'==0)&(`d2'>0)&(`NN'<.)
* 8 - missing with time-variant
qui replace `dum'=8 if (`NN'>1)&(`nn'==`NN')&(`c1'>0)&(`d2'>0)&(`c1'<(`NN'-1))&(`NN'<.)
qui count if `dum'==1
return scalar singnon=r(N)
qui count if `dum'==2
return scalar singmis=r(N)
qui count if `dum'==3
return scalar allmiss=r(N)
qui count if `dum'==4
return scalar oneval=r(N)
qui count if `dum'==5
return scalar tinvnon=r(N)
qui count if `dum'==6
return scalar tinvmis=r(N)
qui count if `dum'==7
return scalar tvarnon=r(N)
qui count if `dum'==8
return scalar tvarmis=r(N)
end

program define calmmvarst, rclass
args i var nn NN dum
tempvar c1 d1 d2
sort `i' `var'
qui bys `i': egen long `c1'=total(missing(`var')) if `i'<.
*gen cc1=`c1'
qui bys `i': gen double `d1'=sum(`var'==`var'[_n-1]) if `i'<.
qui bys `i': egen double `d2'=max(`d1') if `i'<.
qui bys `i': replace `d2'=`d2'+1 if (`var'[1]!="" & `i'<.)
*gen dd2=`d2'
*sort `i' `nn'
qui gen byte `dum'=.
* Singleton
* 1 - Singleton with nonmissing
qui replace `dum'=1 if (`NN'==1)&(`c1'==0)
* 2 - Singleton with missing
qui replace `dum'=2 if (`NN'==1)&(`c1'==1)
** Multiple with missing
* 3 - all missing
qui replace `dum'=3 if (`NN'>1)&(`nn'==`NN')&(`c1'==`NN')&(`NN'<.)
* 4 - Missing with one value!
qui replace `dum'=4 if (`NN'>1)&(`nn'==`NN')&(`NN'==(`c1'+1))&(`NN'<.)
* 5 - Non-missing with time-invariant
qui replace `dum'=5 if (`NN'>1)&(`nn'==`NN')&(`c1'==0)&(`d2'==`NN')&(`NN'<.)
* 6 - missing with time-invariant
qui replace `dum'=6 if (`NN'>1)&(`nn'==`NN')&(`NN'>(`c1'+1))&(`d2'==(`NN'-1))&(`NN'<.)
* 7 - Non-missing with time-variant
qui replace `dum'=7 if (`NN'>1)&(`nn'==`NN')&(`c1'==0)&(`d2'<`NN')&(`NN'<.)
* 8 - missing with time-variant
qui replace `dum'=8 if (`NN'>1)&(`nn'==`NN')&(`dum'==.)&(`NN'<.)
*gen ddum=`dum'
*save lixo, replace
qui count if `dum'==1
return scalar singnon=r(N)
qui count if `dum'==2
return scalar singmis=r(N)
qui count if `dum'==3
return scalar allmiss=r(N)
qui count if `dum'==4
return scalar oneval=r(N)
qui count if `dum'==5
return scalar tinvnon=r(N)
qui count if `dum'==6
return scalar tinvmis=r(N)
qui count if `dum'==7
return scalar tvarnon=r(N)
qui count if `dum'==8
return scalar tvarmis=r(N)
end

*fromto
program define check_fromto, rclass
syntax varlist (min=1 max=1), From(integer) [To(integer 0) Keep Save Missing Descend Ascend]
return local vars "`varlist'"
if `to'==0 {
local to=`from'+1
}
return scalar fromval=`from'
return scalar toval=`to'
if `to'<=`from' {
di as error "Error: from value must be lower than to value"
error 11
}
global ps_ftmiss=1
if `"`missing'"' == "missing" {
global ps_ftmiss=0
}
global ps_ftsave=0
if `"`save'"' == "save" {
global ps_ftsave=1
}
global ps_ftkeep=0
if `"`keep'"'=="keep" {
global ps_ftkeep=1
}
global ps_ftasc=0
if `"`ascend'"'=="ascend" {
global ps_ftasc=1
}
global ps_ftdes=0
if `"`descend'"'=="descend" {
global ps_ftdes=1
}
end

*returnto
program define check_return, rclass
syntax varlist (min=1 max=1), From(integer) [To(integer 0) Middle(integer 0) Keep Save Missing Ascend Descend Within(integer 0)]
return local vars "`varlist'"
if `middle'==0 {
local middle=`from'+1
}
if `to'==0 {
local to=`from'+2
}
return scalar val1=`from'
return scalar val2=`middle'
return scalar val3=`to'
if `middle'<=`from' {
di as error "Error: from value must be lower than middle value"
error 11
}
if `to'<=`middle' {
di as error "Error: middle value must be lower than to value"
error 11
}
global ps_rtmiss=1
if `"`missing'"'=="missing" {
global ps_rtmiss=0
}
global ps_rtsave=0
if `"`save'"'=="save" {
global ps_rtsave=1
}
global ps_rtkeep=0
if `"`keep'"'=="keep" {
global ps_rtkeep=1
}
global ps_rtwit=`within'
global ps_rtasc=0
if `"`ascend'"'=="ascend" {
global ps_rtasc=1
}
global ps_rtdes=0
if `"`descend'"'=="descend" {
global ps_rtdes=1
}
end
