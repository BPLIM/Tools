*! version 1.0 16Jan2018
* Programmed by Emma Zhao


* Programmed by Emma Zhao
*! 1.0 Emma Zhao 16Jan2018
* needs a panel with information on overdue credit and a benchmark credit
* uses ID, time, overdue credit, and a benchmark credit as variables 
* uses threshold of overdue credit share and number of runs as options
* flags overdue credit and returns a variable _flag with following values:
* 0 - No credit is past due
* 1 - Overdue credit below the threshold
* 2 - Overdue credit above the threshold
* flags default event and returns a variable _default with following values:
* 0 - No default occurred
* 1 - Default

capture program drop default
program define default
*set trace on

syntax varlist(min=4 max=4) [, THReshold(real 0.025) RUNs(integer 3) IGNoregap] 
version 13
tokenize `varlist'

tempvar pert dum1 dum2 checkrun ns minns
capture drop _flag _default _fdefault

qui tsset `1'  `2'

qui gen double `pert'=`3'/`4'
qui gen byte `dum1'=0 if `3'==. | `3'==0 | `4'==. | `4'==0
qui replace `dum1'=1 if `pert'<`threshold' & `pert'>0
qui replace `dum1'=2 if `pert'>=`threshold' & `pert'!=.

qui gen byte `dum2'=1 if `pert'>=`threshold' & `3'!=. & `3'!=0
qui replace `dum2'=0 if `pert'<`threshold' | `3'==. | `3'==0

qui gen `checkrun' = `dum2'

local runs2=`runs'-1

forval i =1/`runs2'{

  if "`ignoregap'"=="" {	
     qui replace `checkrun' = `checkrun' + L`i'.`dum2'
  }

  if "`ignoregap'"!="" {	
     qui replace `checkrun' = `checkrun' + `dum2'[_n-`i'] if `1'==`1'[_n-`i']
  }

}

qui gen byte _default=1 if `checkrun'==`runs'
qui replace _default=0 if `checkrun'!=`runs'


sort `1'  `2'

bysort `1': gen `ns'=_n
egen `minns'=min(`ns') if _default==1, by(`1' _default)
gen byte _fdefault=1 if `ns'==`minns'

qui rename `dum1' _flag
capture label drop lbflag
label values _flag lbflag
label define lbflag 0 "No credit is past due" 1 "Overdue credit below the threshold" 2 "Overdue credit above the threshold"
tab _flag
label var _flag "Overdue Credit Outstanding"


capture label drop lbdefault
label values _default lbdefault
label define lbdefault 0 "No default" 1 "Default"
tab _default
label var _default "Default Occurrence"

capture label drop lbfdefault
label values _fdefault lbfdefault
label define lbfdefault 1 "First default"
label var _fdefault "First default indicator"


end
