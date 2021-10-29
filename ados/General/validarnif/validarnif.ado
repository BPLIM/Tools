*! version 1.1 29Oct2021
* Programmed by Paulo Guimarães


program define validarnif
* Programmed by Paulo Guimarães
* version 1.0, 27jun2016 
* Validates the nipc
* Checks that size is 9 and nipc is not missing
* only numeric
* first digit must be 1, 2, 5, 6, 7, 8 or 9
* check digit equal to last digit
* uses a var with nipc as argument and returns a variable _valid with following values:
* 0 - valid
* 1 - first digit invalid
* 2 - length is not 9
* 3 - check digit invalid
* 4 - missing nipc
* 5 - non-numeric value

syntax varlist, [force]
version 13
tempvar dum1 nipcs checkd checkd2 
local nipc = "`varlist'"

capture drop _valid 
if _rc != 111 {
    di 
    di "{text:Variable {bf:_valid} dropped}"
	di
}
capture drop `nipc'_n


local vtype: type `nipc'
if substr("`vtype'",1,3)=="str" {

	if "`force'" != "force" {
	
		di as error "Variable's type is string. Specify option force to create a numeric variable"
		error 198
	
	}
	else {
		// create numeric variable 
		qui destring `nipc', gen(`nipc'_n) force
		format %12.0g `nipc'_n
		
		// valid observations
		qui gen byte `dum1'=0
		
		// length not 9
		qui replace `dum1'=2 if `nipc'_n>999999999
		qui replace `dum1'=2 if `nipc'_n<100000000 
		
		// first digit invalid
		qui gen `nipcs'=string(`nipc'_n,"%9.0f")
		qui replace `dum1'=1 if inlist(substr(`nipcs',1,1),"4","0")&`dum1'==0
		
		// check digit invalid
		qui gen `checkd'=0
		forval i=1/8 {
			qui replace `checkd'=`checkd'+(10-`i')*real(substr(`nipcs',`i',1))
		}
		qui gen int `checkd2'=mod(`checkd',11)
		qui replace `checkd'=0 if `checkd2'<2
		qui replace `checkd'=11-`checkd2' if `checkd2'>1
		qui replace `dum1'=3 if `checkd'!=real(substr(`nipcs',9,1))&`dum1'==0
		
		// missing nipc
		qui replace `dum1' = 4 if missing(`nipc') 	
		
		// non-numeric type
		qui replace `dum1' = 5 if missing(`nipc'_n) & !missing(`nipc')	
	}
}
else {

	// valid observations
	qui gen byte `dum1'=0
	
	// length not 9
	qui replace `dum1'=2 if `nipc'>999999999
	qui replace `dum1'=2 if `nipc'<100000000 
	
	// first digit invalid
	qui gen `nipcs'=string(`nipc',"%9.0f")
	qui replace `dum1'=1 if inlist(substr(`nipcs',1,1),"4","0")&`dum1'==0
	
	// check digit invalid
	qui gen `checkd'=0
	forval i=1/8 {
		qui replace `checkd'=`checkd'+(10-`i')*real(substr(`nipcs',`i',1))
	}
	qui gen int `checkd2'=mod(`checkd',11)
	qui replace `checkd'=0 if `checkd2'<2
	qui replace `checkd'=11-`checkd2' if `checkd2'>1
	qui replace `dum1'=3 if `checkd'!=real(substr(`nipcs',9,1))&`dum1'==0
	
	// missing nipc
	qui replace `dum1' = 4 if missing(`nipc') 
	}


qui rename `dum1' _valid
capture label drop _nipcl
label define _nipcl 0 "0 Valid" 1 "1 first digit invalid" ///
	2 "2 length different from 9 digits" 3 "3 check digit invalid" ///
	4 "4 missing variable" 5 "5 non-numeric type" 
label values _valid _nipcl
label var _valid "nipc validity"
tab _valid

end
