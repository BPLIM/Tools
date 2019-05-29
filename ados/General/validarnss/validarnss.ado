*! version 1.0 20Oct2016
* Programmed by Paulo Guimarães

program define validarnss
* Programmed by Paulo Guimarães
* version 1.0, 20oct2016 
* Validates the nss (social security number)
* Checks that size is 11
* only numeric
* first digit must be 1 or 2
* check digit equal to last digit
* uses a var with nipc as argument and returns a variable _valid with following values:
* 0 - valid
* 1 - first digit invalid
* 2 - length is not 11
* 3 - check digit invalid
args nssn
version 13
tempvar dum1 nsss checkd 
capture drop _valid
local vtype: type `nssn'
if substr("`vtype'",1,3)=="str" {
di in red "Error: Variable must be numeric! "
error 198
}
qui gen byte `dum1'=0
qui replace `dum1'=2 if `nssn'>99999999999
qui replace `dum1'=2 if `nssn'<10000000000
qui gen `nsss'=string(`nssn',"%11.0f")
qui replace `dum1'=1 if !inlist(substr(`nsss',1,1),"1","2")&`dum1'==0
qui gen `checkd'=0
qui replace `checkd'= ///
29*real(substr(`nsss',1,1))+ ///
23*real(substr(`nsss',2,1))+ ///
19*real(substr(`nsss',3,1))+ ///
17*real(substr(`nsss',4,1))+ ///
13*real(substr(`nsss',5,1))+ ///
11*real(substr(`nsss',6,1))+ ///
7*real(substr(`nsss',7,1))+ ///
5*real(substr(`nsss',8,1))+ ///
3*real(substr(`nsss',9,1))+ ///
2*real(substr(`nsss',10,1))
qui replace `checkd'=9-mod(`checkd',10)
qui replace `dum1'=3 if `checkd'!=real(substr(`nsss',11,1))&`dum1'==0
qui rename `dum1' _valid
capture label drop _nssl
label define _nssl 0 "Valid" 1 "first digit invalid" 2 "length is not 11" 3 "check digit invalid"
label values _valid _nssl
label var _valid "nss validity"
tab _valid
end
