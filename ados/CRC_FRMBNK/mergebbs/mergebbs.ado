* Programmed by Emma Zhao
* version 2.0, 1July2019  
* CRC & BBS Merge, apply to BBS data 


capture program drop mergebbs
program define mergebbs
*set trace on

syntax varlist(min=2 max=2)
version 13
tokenize `varlist'

cap drop _newbina

qui gen _newbina=`1'	

* joint BBS & CRC
qui replace _newbina = 4273 if (`1'==5329 & `2'>=491)

* delayed asset transfer in BBS
qui replace _newbina = 8384 if (`1'==4557 & `2'>=488)
qui replace _newbina = 495 if (`1'==2104 & `2'>=551)

								
end
