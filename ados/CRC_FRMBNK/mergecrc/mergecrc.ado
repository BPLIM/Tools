* Programmed by Emma Zhao
* version 2.0, 1July2019 
* CRC & BBS Merge, apply to CRC data  
* options: for institutions that are not reported in bbs, aggregate the credit at the group level so later they can be merged with bbs


capture program drop mergecrc
program define mergecrc
*set trace on

syntax varlist(min=2 max=2) [, GROUP]
version 13
tokenize `varlist'

cap drop _newbina

qui gen _newbina=`1'	

* delayed credit transfer in CRC
qui replace _newbina = 6179 if (`1'==1132 & `2'>=551)
qui replace _newbina = 6179 if (`1'==5213 & `2'>=678)
qui replace _newbina = 7618 if (`1'==7453 & `2'>=671)			
qui replace _newbina = 6583 if (`1'==7912 & `2'<=539)		
qui replace _newbina = 7618 if (`1'==7912 & `2'>539)	
qui replace _newbina = 6583 if (`1'==7618 & `2'<=539)	
qui replace _newbina = 9719 if (`1'==7156 & `2'>=516)	
qui replace _newbina = 8384 if (`1'==697 & `2'>=491)			
qui replace _newbina = 8384 if (`1'==4440 & `2'>=486)		
qui replace _newbina = 8384 if (`1'==3052 & `2'>=486)	
qui replace _newbina = 8384 if (`1'==8933 & `2'>=533)	
qui replace _newbina = 8384 if (`1'==6092 & `2'>=539)		
qui replace _newbina = 8384 if (`1'==7512 & `2'>=491)
qui replace _newbina = 8984 if (`1'==5108 & `2'>=499)
qui replace _newbina = 8493 if (`1'==5606 & `2'>=640)	
qui replace _newbina = 9180 if (`1'==6851 & `2'>=600)	
qui replace _newbina = 9498 if (`1'==9079 & `2'>499)	
qui replace _newbina = 9498 if (`1'==9079 & `2'<464)

qui replace _newbina = 1501 if (`1'==9180 & `2'<521)
qui replace _newbina = 6179 if (`1'==7263 & `2'>677)

* joint BBS & CRC
qui replace _newbina = 4273 if (`1'==5329 & `2'>=488)


if "`group'"=="group" {
* group
qui replace _newbina =517 if `1'==3217
qui replace _newbina =8384 if `1'==5917
qui replace _newbina =6179 if `1'==4858
qui replace _newbina =7516 if `1'==6620
qui replace _newbina =8984 if `1'==9661
qui replace _newbina =8984 if `1'==8651
qui replace _newbina =8984 if `1'==5531
qui replace _newbina = 301 if (`1'==5769 & `2'<587)
qui replace _newbina = 8493 if (`1'==5769 & `2'>=587 & `2'<668)
qui replace _newbina = 8673 if (`1'==5769 & `2'>=668)
qui replace _newbina =9498 if `1'==4871
qui replace _newbina =9498 if `1'==7094
qui replace _newbina =9498 if `1'==1318
qui replace _newbina =9498 if `1'==1590
qui replace _newbina =9498 if `1'==494
qui replace _newbina =9498 if `1'==6404
qui replace _newbina =9498 if `1'==9339
qui replace _newbina =9498 if `1'==7830
qui replace _newbina =9498 if `1'==6417
qui replace _newbina =9498 if `1'==7309
qui replace _newbina =9498 if `1'==4663
qui replace _newbina =9498 if `1'==8382
qui replace _newbina =9498 if `1'==7061
qui replace _newbina =9498 if `1'==822
qui replace _newbina =9498 if `1'==6958
qui replace _newbina =9498 if `1'==8027
qui replace _newbina =9498 if `1'==2626
qui replace _newbina =9498 if `1'==5107
qui replace _newbina =9498 if `1'==3772
qui replace _newbina =9498 if `1'==3795
qui replace _newbina =9498 if `1'==4095
qui replace _newbina =9498 if `1'==6561
qui replace _newbina =9498 if `1'==8654
qui replace _newbina =9498 if `1'==7807
qui replace _newbina =9498 if `1'==6736
qui replace _newbina =9498 if `1'==1400
qui replace _newbina =9498 if `1'==5740
qui replace _newbina =9498 if `1'==121
qui replace _newbina =9498 if `1'==5694
qui replace _newbina =9498 if `1'==2992
qui replace _newbina =9498 if `1'==741

qui replace _newbina =9498 if `1'==6984
qui replace _newbina =9498 if `1'==5954
qui replace _newbina =9498 if `1'==8678
qui replace _newbina =9498 if `1'==4265
qui replace _newbina =9498 if `1'==1191
qui replace _newbina =9498 if `1'==2666
qui replace _newbina =9498 if `1'==1695
qui replace _newbina =9498 if `1'==375
qui replace _newbina =9498 if `1'==8552
qui replace _newbina =9498 if `1'==6921
qui replace _newbina =9498 if `1'==8807
qui replace _newbina =9498 if `1'==6446
qui replace _newbina =9498 if `1'==3546
qui replace _newbina =9498 if `1'==8518
qui replace _newbina =9498 if `1'==7040
qui replace _newbina =9498 if `1'==1453
qui replace _newbina =9498 if `1'==9162
qui replace _newbina =9498 if `1'==8582
qui replace _newbina =9498 if `1'==1100
qui replace _newbina =9498 if `1'==2559
qui replace _newbina =9498 if `1'==6977
qui replace _newbina =9498 if `1'==5202
qui replace _newbina =9498 if `1'==8052
qui replace _newbina =9498 if `1'==9207
qui replace _newbina =9498 if `1'==2774
qui replace _newbina =9498 if `1'==5505
qui replace _newbina =9498 if `1'==8628
qui replace _newbina =9498 if `1'==5759
qui replace _newbina =9498 if `1'==9277
qui replace _newbina =9498 if `1'==1215
qui replace _newbina =9498 if `1'==4550
qui replace _newbina =9498 if `1'==84
qui replace _newbina =9498 if `1'==5466
qui replace _newbina =9498 if `1'==251
qui replace _newbina =9498 if `1'==3868
qui replace _newbina =9498 if `1'==8344
qui replace _newbina =9498 if `1'==9897
qui replace _newbina =9498 if `1'==8900
qui replace _newbina =9498 if `1'==9932
qui replace _newbina =9498 if `1'==4432
qui replace _newbina =9498 if `1'==7222
qui replace _newbina =9498 if `1'==3651
qui replace _newbina =9498 if `1'==5295
qui replace _newbina =9498 if `1'==3267
qui replace _newbina =9498 if `1'==9365
qui replace _newbina =9498 if `1'==2181
qui replace _newbina =9498 if `1'==408
qui replace _newbina =9498 if `1'==3402
qui replace _newbina =9498 if `1'==1065
qui replace _newbina =9498 if `1'==6543
qui replace _newbina =9498 if `1'==9641
qui replace _newbina =9498 if `1'==5815
qui replace _newbina =9498 if `1'==2140
qui replace _newbina =9498 if `1'==4510
qui replace _newbina =9498 if `1'==9248
qui replace _newbina =9498 if `1'==3535
qui replace _newbina =9498 if `1'==3041
qui replace _newbina =9498 if `1'==5670
qui replace _newbina =9498 if `1'==2109
qui replace _newbina =9498 if `1'==8411
qui replace _newbina =9498 if `1'==932
qui replace _newbina =9498 if `1'==4205
qui replace _newbina =9498 if `1'==3328
qui replace _newbina =9498 if `1'==9576
qui replace _newbina =9498 if `1'==8590
qui replace _newbina =9498 if `1'==2538
qui replace _newbina =9498 if `1'==4074
qui replace _newbina =9498 if `1'==3467
qui replace _newbina =9498 if `1'==8308
qui replace _newbina =9498 if `1'==5450
qui replace _newbina =9498 if `1'==1955
qui replace _newbina =9498 if `1'==8714
qui replace _newbina =9498 if `1'==1010
qui replace _newbina =9498 if `1'==9474
qui replace _newbina =9498 if `1'==7634
qui replace _newbina =9498 if `1'==3956
qui replace _newbina =9498 if `1'==5483
qui replace _newbina =9498 if `1'==7344
qui replace _newbina =9498 if `1'==7993
qui replace _newbina =9498 if `1'==7500
qui replace _newbina =9498 if `1'==9356
qui replace _newbina =9498 if `1'==5795
qui replace _newbina =9498 if `1'==858
qui replace _newbina =9498 if `1'==5437
qui replace _newbina =9498 if `1'==8457
qui replace _newbina =9498 if `1'==3856
qui replace _newbina =9498 if `1'==6995
qui replace _newbina =9498 if `1'==502
qui replace _newbina =9498 if `1'==4323
qui replace _newbina =9498 if `1'==469
qui replace _newbina =9498 if `1'==7328
qui replace _newbina =9498 if `1'==8246
qui replace _newbina =9498 if `1'==4780
qui replace _newbina =9498 if `1'==5976
qui replace _newbina =9498 if `1'==7642
qui replace _newbina =9498 if `1'==4786
qui replace _newbina =9498 if `1'==6758
qui replace _newbina =9498 if `1'==3042
qui replace _newbina =9498 if `1'==873
qui replace _newbina =9498 if `1'==2080
qui replace _newbina =9498 if `1'==733
qui replace _newbina =9498 if `1'==2207
qui replace _newbina =9498 if `1'==9450
qui replace _newbina =9498 if `1'==2174
qui replace _newbina =9498 if `1'==6632
qui replace _newbina =9498 if `1'==9922
qui replace _newbina =9498 if `1'==5872
qui replace _newbina =9498 if `1'==60
qui replace _newbina =9498 if `1'==2223
qui replace _newbina =9498 if `1'==5850
qui replace _newbina =9498 if `1'==1780
qui replace _newbina =9498 if `1'==7397
qui replace _newbina =9498 if `1'==8861
qui replace _newbina =9498 if `1'==4687
qui replace _newbina =9498 if `1'==9650
qui replace _newbina =9498 if `1'==4588
qui replace _newbina =9498 if `1'==3514
qui replace _newbina =9498 if `1'==4435
qui replace _newbina =9498 if `1'==8362
qui replace _newbina =9498 if `1'==8028
qui replace _newbina =9498 if `1'==6616
qui replace _newbina =9498 if `1'==4481
qui replace _newbina =9498 if `1'==6342
qui replace _newbina =9498 if `1'==88
qui replace _newbina =9498 if `1'==3778
qui replace _newbina =9498 if `1'==7709
qui replace _newbina =9498 if `1'==6512

}

								
end
