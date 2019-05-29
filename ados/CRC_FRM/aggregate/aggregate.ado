*! version 1.0 17Jul2018
* Programmed by Emma Zhao


* Programmed by Emma Zhao
*! 1.0 Emma Zhao 17Jul2018
* modified by Emma Zhao on 17Jul2018
* uses ID and time as variables 
* uses aggregation period (year or quarter) and aggregation method (period end or period average) as options


capture program drop aggregate
program define aggregate
*set trace on

syntax varlist(min=2 max=2) [, year quarter end avg nocheck]
version 13
tokenize `varlist'

tempvar month obsyear
cap drop year

local nocheck "`check'"


if "`year'" =="" & "`quarter'" =="" {

   	 di as error _col(20) "Error: please choose the aggregation frequency: year/quarter"

}

if "`end'" =="" & "`avg'" =="" {

    	di as error _col(20) "Error: please choose the aggregation method: end/avg"

}


if ("`year'" =="year" | "`quarter'" =="quarter") & ("`end'"=="end" | "`avg'"=="avg"){

    	preserve
    	gen int year=year(dofm(`2'))
	quietly keep if valor_global !=0 & valor_global !=.
	collapse (count) valor_global, by(year)  

        quietly gen obs = .
        quietly replace obs = 268866 if year== 1980
	quietly replace obs = 313036 if year==1981
	quietly replace obs = 367063 if year==1982
	quietly replace obs = 400957 if year==1983
	quietly replace obs = 426742 if year==1984
	quietly replace obs = 444090 if year==1985
	quietly replace obs = 473695 if year==1986
	quietly replace obs = 519290 if year==1987
	quietly replace obs = 553605 if year==1988
	quietly replace obs = 609841 if year==1989
	quietly replace obs = 665570 if year==1990
	quietly replace obs = 740073 if year==1991
	quietly replace obs = 809438 if year==1992
	quietly replace obs = 1017177 if year==1993
	quietly replace obs = 1120932 if year==1994
	quietly replace obs = 1227503 if year==1995
	quietly replace obs = 1339727 if year==1996
	quietly replace obs = 1449086 if year==1997
	quietly replace obs = 1652135 if year==1998
	quietly replace obs = 1834559 if year==1999
	quietly replace obs = 2094901 if year==2000
	quietly replace obs = 2314026 if year==2001
	quietly replace obs = 2696297 if year==2002
	quietly replace obs = 2860284 if year==2003
	quietly replace obs = 2988725 if year==2004
	quietly replace obs = 3082268 if year==2005
	quietly replace obs = 3150947 if year==2006
	quietly replace obs = 3279246 if year==2007
	quietly replace obs = 3401512 if year==2008
	quietly replace obs = 3411818 if year==2009
	quietly replace obs = 3482814 if year==2010
	quietly replace obs = 3518801 if year==2011
	quietly replace obs = 3508318 if year==2012
	quietly replace obs = 3407024 if year==2013
	quietly replace obs = 3368366 if year==2014
	quietly replace obs = 3403726 if year==2015
	quietly replace obs = 3456285 if year==2016

	quietly gen id=1 if valor_global != obs
	egen checksum=sum(id)
	local checkobs=checksum


	if "`nocheck'" =="" & `checkobs' != 0 { 
        
		restore
		di as error _col(10) "Error: Not applicable. Please run this ado on the original CRC datasets"
         
	}


	if "`nocheck'" =="nocheck" | `checkobs' == 0 { 
   
   		restore

		quietly gen int `month'=month(dofm(`2'))


		if "`year'" =="year" {

        		quietly gen int year=year(dofm(`2'))
        		capture label var year "Reporting year"

			if "`end'"=="end" {

            			quietly keep if `month'==12
            			quietly drop `2'

				capture label var `1' "Anonymized tax identification number"
            			capture label var valor_global "Total credit amount, including potential credit: December"
            			capture label var valor_efectivo "Total amount of effective credit, including overdue credit: December"
            			capture label var valor_potencial "Total amount of potential credit: December"
            			capture label var valor_vencido "Total amount of overdue credit: December"
            			capture label var valor_curto_o "Total amount of original short-term credit: December"
            			capture label var valor_longo_o "Total amount of original medium and long-term credit: December"
            			capture label var valor_curto_r "Total amount of short-term credit due in one year: December"
            			capture label var valor_longo_r "Total amount of medium and long-term credit due in more than one year: December"
            			capture label var max_relacao "Largest bank relationship in shares: December"
            			capture label var nb_relacao "Number of bank relationships: December"
            			capture label var hhi_relacao "Concentration of bank relationships: December"
            			capture label var prazomedia_o "Weighted average original maturity: December"
            			capture label var prazomedia_r "Weighted average residual maturity: December"
            			capture label var valor_prazo1_o "Amount of credit with an original maturity of <= 1 year: December"
            			capture label var valor_prazo2_o "Amount of credit with an original maturity of > 1 year and <= 5 years: December"
            			capture label var valor_prazo3_o "Amount of credit with an original maturity of > 5 years and <= 10 years: December"
            			capture label var valor_prazo4_o "Amount of credit with an original maturity of > 10 years and <= 20 years: December"
            			capture label var valor_prazo5_o "Amount of credit with an original maturity of > 20 years: December"
            			capture label var valor_prazo1_r "Amount of credit with a residual maturity of <= 1 year: December"
            			capture label var valor_prazo2_r "Amount of credit with a residual maturity of > 1 year and <= 5 years: December"
            			capture label var valor_prazo3_r "Amount of credit with a residual maturity of > 5 years and <= 10 years: December"
            			capture label var valor_prazo4_r "Amount of credit with a residual maturity of > 10 years and <= 20 years: December"
            			capture label var valor_prazo5_r "Amount of credit with a residual maturity of > 20 years: December"
            			capture label var valor_g1 "Secured credit by real collateral mortgaged: December"
            			capture label var valor_g2 "Secured credit by real collateral not mortgaged: December"
            			capture label var valor_g3 "Secured credit by financial collateral: December"
            			capture label var valor_g4 "Secured credit by personal guarantee provided by firm or individual: December"
            			capture label var valor_g5 "Secured credit by personal guarantee granted by the state or financial institution: December"
            			capture label var valor_g6 "Secured credit by other guarantees: December"

        		
            			quietly format `1' %12.0g
            			quietly capture format %15.2f valor_*
            			quietly capture format %15.2f max_relacao
            			quietly capture format %15.2f nb_relacao
            			quietly capture format %15.2f hhi_relacao
            			quietly capture order `1' year 


            			label data "CRC Aggregated - December value"
            			note:  "Modified by `c(username)' on `c(current_date)'"

        		}


        		if "`avg'"=="avg" {

            			quietly describe, varlist
            			local vars `r(varlist)'
            			local omit `1' year date
            			local want : list vars - omit
            			collapse (mean) `want', by(`1' year)


            			capture label var `1' "Anonymized tax identification number"
            			capture label var valor_global "Total credit amount, including potential credit: yearly average"
            			capture label var valor_efectivo "Total amount of effective credit, including overdue credit: yearly average"
            			capture label var valor_potencial "Total amount of potential credit: yearly average"
            			capture label var valor_vencido "Total amount of overdue credit: yearly average"
            			capture label var valor_curto_o "Total amount of original short-term credit: yearly average"
            			capture label var valor_longo_o "Total amount of original medium and long-term credit: yearly average"
            			capture label var max_relacao "Largest bank relationship in shares: yearly average"
            			capture label var nb_relacao "Number of bank relationships: yearly average"
            			capture label var hhi_relacao "Concentration of bank relationships: yearly average"
            			capture label var valor_curto_r "Total amount of short-term credit due in one year: yearly average"
            			capture label var valor_longo_r "Total amount of medium and long-term credit due in more than one year: yearly average"
            			capture label var prazomedia_o "Weighted average original maturity: yearly average"
            			capture label var prazomedia_r "Weighted average residual maturity: yearly average"
            			capture label var valor_prazo1_o "Amount of credit with an original maturity of <= 1 year: yearly average"
            			capture label var valor_prazo2_o "Amount of credit with an original maturity of > 1 year and <= 5 years: yearly average"
            			capture label var valor_prazo3_o "Amount of credit with an original maturity of > 5 years and <= 10 years: yearly average"
            			capture label var valor_prazo4_o "Amount of credit with an original maturity of > 10 years and <= 20 years: yearly average"
            			capture label var valor_prazo5_o "Amount of credit with an original maturity of > 20 years: yearly average"
            			capture label var valor_prazo1_r "Amount of credit with a residual maturity of <= 1 year: yearly average"
            			capture label var valor_prazo2_r "Amount of credit with a residual maturity of > 1 year and <= 5 years: yearly average"
            			capture label var valor_prazo3_r "Amount of credit with a residual maturity of > 5 years and <= 10 years: yearly average"
            			capture label var valor_prazo4_r "Amount of credit with a residual maturity of > 10 years and <= 20 years: yearly average"
            			capture label var valor_prazo5_r "Amount of credit with a residual maturity of > 20 years: yearly average"
            			capture label var valor_g1 "Secured credit by real collateral mortgaged: yearly average"
            			capture label var valor_g2 "Secured credit by real collateral not mortgaged: yearly average"
            			capture label var valor_g3 "Secured credit by financial collateral: yearly average"
            			capture label var valor_g4 "Secured credit by personal guarantee provided by firm or individual: yearly average"
            			capture label var valor_g5 "Secured credit by personal guarantee granted by the state or financial institution: yearly average"
            			capture label var valor_g6 "Secured credit by other guarantees: yearly average"

            			quietly format `1' %12.0g
            			quietly capture format %15.2f valor_*
            			quietly capture format %15.2f max_relacao
            			quietly capture format %15.2f nb_relacao
            			quietly capture format %15.2f hhi_relacao
            			quietly capture order `1' year 


            			label data "CRC Aggregated - yearly average"
            			note:  "Modified by `c(username)' on `c(current_date)'"

        		}

		}



 		if "`quarter'" =="quarter" {

        		gen int year=year(dofm(`2'))
        		gen int quarter=qofd(dofm(`2'))
        		capture label var quarter "Reporting quarter"

        		if "`end'"=="end" {

            			quietly keep if `month'==3 | `month'==6 | `month'==9 | `month'==12
            			drop `2'


           			capture label var `1' "Anonymized tax identification number"
            			capture label var valor_global "Total credit amount, including potential credit: quarter-end"
            			capture label var valor_efectivo "Total amount of effective credit, including overdue credit: quarter-end"
            			capture label var valor_potencial "Total amount of potential credit: quarter-end"
            			capture label var valor_vencido "Total amount of overdue credit: quarter-end"
            			capture label var valor_curto_o "Total amount of original short-term credit: quarter-end"
            			capture label var valor_longo_o "Total amount of original medium and long-term credit: quarter-end"
            			capture label var valor_curto_r "Total amount of short-term credit due in one year: quarter-end"
            			capture label var valor_longo_r "Total amount of medium and long-term credit due in more than one year: quarter-end"
            			capture label var max_relacao "Largest bank relationship in shares: quarter-end"
            			capture label var nb_relacao "Number of bank relationships: quarter-end"
            			capture label var hhi_relacao "Concentration of bank relationships: quarter-end"
            			capture label var prazomedia_o "Weighted average original maturity: quarter-end"
            			capture label var prazomedia_r "Weighted average residual maturity: quarter-end"
            			capture label var valor_prazo1_o "Amount of credit with an original maturity of <= 1 year: quarter-end"
            			capture label var valor_prazo2_o "Amount of credit with an original maturity of > 1 year and <= 5 years: quarter-end"
            			capture label var valor_prazo3_o "Amount of credit with an original maturity of > 5 years and <= 10 years: quarter-end"
            			capture label var valor_prazo4_o "Amount of credit with an original maturity of > 10 years and <= 20 years: quarter-end"
            			capture label var valor_prazo5_o "Amount of credit with an original maturity of > 20 years: quarter-end"
            			capture label var valor_prazo1_r "Amount of credit with a residual maturity of <= 1 year: quarter-end"
            			capture label var valor_prazo2_r "Amount of credit with a residual maturity of > 1 year and <= 5 years: quarter-end"
            			capture label var valor_prazo3_r "Amount of credit with a residual maturity of > 5 years and <= 10 years: quarter-end"
            			capture label var valor_prazo4_r "Amount of credit with a residual maturity of > 10 years and <= 20 years: quarter-end"
            			capture label var valor_prazo5_r "Amount of credit with a residual maturity of > 20 years: quarter-end"
            			capture label var valor_g1 "Secured credit by real collateral mortgaged: quarter-end"
            			capture label var valor_g2 "Secured credit by real collateral not mortgaged: quarter-end"
            			capture label var valor_g3 "Secured credit by financial collateral: quarter-end"
            			capture label var valor_g4 "Secured credit by personal guarantee provided by firm or individual: quarter-end"
            			capture label var valor_g5 "Secured credit by personal guarantee granted by the state or financial institution: quarter-end"
            			capture label var valor_g6 "Secured credit by other guarantees: quarter-end"


            			quietly format quarter %tq
           			quietly format `1' %12.0g
            			quietly capture format %15.2f valor_*
            			quietly capture format %15.2f max_relacao
            			quietly capture format %15.2f nb_relacao
            			quietly capture format %15.2f hhi_relacao
            			quietly capture order `1' quarter
           			cap drop year


            			label data "CRC Aggregated - quarterly end
            			note:  "Modified by `c(username)' on `c(current_date)'"

        		}


        		if "`avg'"=="avg" {

            			quietly describe, varlist
            			local vars `r(varlist)'
            			local omit `1' year quarter date
            			local want : list vars - omit
            			collapse (mean) `want', by(`1' quarter)


            			capture label var `1' "Anonymized tax identification number"
            			capture label var valor_global "Total credit amount, including potential credit: quarterly average"
            			capture label var valor_efectivo "Total amount of effective credit, including overdue credit: quarterly average"
            			capture label var valor_potencial "Total amount of potential credit: quarterly average"
            			capture label var valor_vencido "Total amount of overdue credit: quarterly average"
            			capture label var valor_curto_o "Total amount of original short-term credit: quarterly average"
            			capture label var valor_longo_o "Total amount of original medium and long-term credit: quarterly average"
            			capture label var max_relacao "Largest bank relationship in shares: quarterly average"
            			capture label var nb_relacao "Number of bank relationships: quarterly average"
            			capture label var hhi_relacao "Concentration of bank relationships: quarterly average"
            			capture label var valor_curto_r "Total amount of short-term credit due in one year: quarterly average"
            			capture label var valor_longo_r "Total amount of medium and long-term credit due in more than one year: quarterly average"
            			capture label var prazomedia_o "Weighted average original maturity: quarterly average"
            			capture label var prazomedia_r "Weighted average residual maturity: quarterly average"
            			capture label var valor_prazo1_o "Amount of credit with an original maturity of <= 1 year: quarterly average"
            			capture label var valor_prazo2_o "Amount of credit with an original maturity of > 1 year and <= 5 years: quarterly average"
            			capture label var valor_prazo3_o "Amount of credit with an original maturity of > 5 years and <= 10 years: quarterly average"
            			capture label var valor_prazo4_o "Amount of credit with an original maturity of > 10 years and <= 20 years: quarterly average"
            			capture label var valor_prazo5_o "Amount of credit with an original maturity of > 20 years: quarterly average"
            			capture label var valor_prazo1_r "Amount of credit with a residual maturity of <= 1 year: quarterly average"
            			capture label var valor_prazo2_r "Amount of credit with a residual maturity of > 1 year and <= 5 years: quarterly average"
            			capture label var valor_prazo3_r "Amount of credit with a residual maturity of > 5 years and <= 10 years: quarterly average"
            			capture label var valor_prazo4_r "Amount of credit with a residual maturity of > 10 years and <= 20 years: quarterly average"
            			capture label var valor_prazo5_r "Amount of credit with a residual maturity of > 20 years: quarterly average"
            			capture label var valor_g1 "Secured credit by real collateral mortgaged: quarterly average"
            			capture label var valor_g2 "Secured credit by real collateral not mortgaged: quarterly average"
            			capture label var valor_g3 "Secured credit by financial collateral: quarterly average"
            			capture label var valor_g4 "Secured credit by personal guarantee provided by firm or individual: quarterly average"
            			capture label var valor_g5 "Secured credit by personal guarantee granted by the state or financial institution: quarterly average"
            			capture label var valor_g6 "Secured credit by other guarantees: quarterly average"

            			quietly format quarter %tq
            			quietly format `1' %12.0g
            			quietly capture format %15.2f valor_*
            			quietly capture format %15.2f max_relacao
            			quietly capture format %15.2f nb_relacao
            			quietly capture format %15.2f hhi_relacao
            			quietly capture order `1' quarter


            			label data "CRC Aggregated - quarterly average
            			note:  "Modified by `c(username)' on `c(current_date)'"

        		}

		}

di as error "The aggregation is complete. Please be advised that this ado only applies to the original CRC datasets"

	}

}


end
