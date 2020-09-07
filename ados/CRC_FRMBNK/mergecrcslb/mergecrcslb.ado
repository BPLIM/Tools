* Programmed by Emma Zhao
* version 1.0, 01Sep2020 
* CRC & SLB Merge, apply to CRC data  

capture program drop mergecrcslb
program define mergecrcslb
*set trace on

syntax varlist(min=2 max=2)
version 13
tokenize `varlist'

qui sum `2'

if `r(min)' <468 | `r(max)' >703 { 
	di as error _col(10) "Error: Not applicable. This ado is only valid for the period from January, 1999 to August, 2018."
}


if `r(min)' >=468 & `r(max)' <=703 { 
	
	cap drop _newbina

	qui gen _newbina=. 
	qui replace _newbina = 8493 if `1'==5769 & year(dofm(`2'))<2012
	qui replace _newbina = 9498 if `1'==4911 & year(dofm(`2'))<2008
	qui replace _newbina = 4273 if `1'==9340 & year(dofm(`2'))<2008
	qui replace _newbina = 7825 if `1'==2006 & year(dofm(`2'))>2007
	qui replace _newbina = 9003 if `1'==2006 & year(dofm(`2'))<=2007
	qui replace _newbina = 8627 if `1'==4394 & year(dofm(`2'))>2011
	qui replace _newbina = 8493 if `1'==5606 & year(dofm(`2'))>2012
	qui replace _newbina = 8384 if `1'==697 & `2'>484

	* refer to "Z:\data\Products\SLB\2020_06\ados\Input\FI_A_QCRC_MSLB.dta"

	* banks that do not belong to any group
	qui replace _newbina = `1' if inlist(`1',5546, 8877, 6179, 361, 7516, 5329, 7575, 697, 4273, 8262, 7156, ///
	8372, 5820, 8384, 2348, 8984, 8627, 7453, 6055, 1659, 4322, 495, 6132, 8099, 518, 118, 4488, 6524, 4453, 5340, ///
	3793, 8723, 4394, 8493, 8630, 4557, 514, 9008, 6230, 8507, 5560, 1213, 914, 2469, 6457, 2104, 9003, 5113, 9007, ///
	9609, 1961, 9835, 9704, 9338, 5719, 7233, 624, 912, 5606, 5529, 2184, 2802, 2612, 5928, 7698, 1546, 4334, 6178, ///
	1393, 6760, 7389, 4102, 7310, 5314, 6376, 3442, 3217, 2771, 4318, 8044, 9334, 4033, 918, 7236, 2655, 6907, 3549,  ///
	9052, 2296, 7081, 4763, 8609, 5945, 5385, 3149, 8468, 5775, 9569, 9726, 4772, 6832, 6236, 5769, 4374, 817, 9223,  ///
	5598, 9637, 2552, 4278, 1776, 3541, 4504, 3054, 4107, 8613, 4579, 3728, 8129, 6666, 3904, 4246, 3351, 8213, 6010,  ///
	7435, 1701, 2481, 2735, 2089, 3754, 5134, 2194, 8074, 86, 8691, 5304, 9340, 4242, 4296, 9063, 8442, 9180, 3823,  ///
	4240, 7290, 7185, 7825, 5504, 9867, 2925, 9794, 7878, 4265, 1191, 375, 8807, 8518, 7040, 2559, 8052, 1590, 2774,  ///
	8628, 8344, 9932, 4432, 5295, 408, 9641, 2140, 5670, 2109, 4205, 3328, 8590, 4074, 3467, 8308, 8714, 7264, 4694,  ///
	3856, 1211, 4323, 8246, 5976, 4786, 6758, 3042, 5872, 60, 8861, 4687, 4588, 3514, 4435, 8362, 88, 3778, 5085, 5651,  ///
	7226, 372, 9537, 771, 8687, 5306, 9498)

	* banks that have never changed groups
	qui replace _newbina = 7453 if `1'== 6634
	qui replace _newbina = 8984 if `1'== 5108
	qui replace _newbina = 8384 if `1'== 4440
	qui replace _newbina = 3419 if `1'== 3052
	qui replace _newbina = 7516 if `1'== 9606
	qui replace _newbina = 9609 if `1'== 481
	qui replace _newbina = 6179 if `1'== 1132
	qui replace _newbina = 4273 if `1'== 8770
	qui replace _newbina = 8384 if `1'== 8933
	qui replace _newbina = 8384 if `1'== 6092
	qui replace _newbina = 8384 if `1'== 5867
	qui replace _newbina = 6179 if `1'== 2308
	qui replace _newbina = 6179 if `1'== 7870
	qui replace _newbina = 8384 if `1'== 517
	qui replace _newbina = 6179 if `1'== 5213
	qui replace _newbina = 6179 if `1'== 7263
	qui replace _newbina = 8493 if `1'== 5220
	qui replace _newbina = 8493 if `1'== 8296
	qui replace _newbina = 8493 if `1'== 3915
	qui replace _newbina = 4273 if `1'== 562
	qui replace _newbina = 8984 if `1'== 3798
	qui replace _newbina = 8984 if `1'== 297
	qui replace _newbina = 8384 if `1'== 5917
	qui replace _newbina = 4273 if `1'== 1725
	qui replace _newbina = 7453 if `1'== 880
	qui replace _newbina = 6179 if `1'== 4858
	qui replace _newbina = 7516 if `1'== 6620
	qui replace _newbina = 8984 if `1'== 9661
	qui replace _newbina = 6132 if `1'== 9153
	qui replace _newbina = 7618 if `1'== 7912
	qui replace _newbina = 6179 if `1'== 7342
	qui replace _newbina = 7453 if `1'== 9546
	qui replace _newbina = 4033 if `1'== 3272
	qui replace _newbina = 3052 if `1'== 7050
	qui replace _newbina = 8984 if `1'== 8651
	qui replace _newbina = 8984 if `1'== 5531
	qui replace _newbina = 9498 if `1'== 6984
	qui replace _newbina = 9498 if `1'== 5954
	qui replace _newbina = 9498 if `1'== 8678
	qui replace _newbina = 9498 if `1'== 4871
	qui replace _newbina = 9498 if `1'== 2666
	qui replace _newbina = 9498 if `1'== 1695
	qui replace _newbina = 9498 if `1'== 8552
	qui replace _newbina = 9498 if `1'== 6921
	qui replace _newbina = 9498 if `1'== 6446
	qui replace _newbina = 9498 if `1'== 3546
	qui replace _newbina = 9498 if `1'== 1453
	qui replace _newbina = 9498 if `1'== 9162
	qui replace _newbina = 9498 if `1'== 6958
	qui replace _newbina = 9498 if `1'== 8582
	qui replace _newbina = 9498 if `1'== 1100
	qui replace _newbina = 9498 if `1'== 8027
	qui replace _newbina = 9498 if `1'== 6977
	qui replace _newbina = 9498 if `1'== 5202
	qui replace _newbina = 9498 if `1'== 9207
	qui replace _newbina = 9498 if `1'== 5505
	qui replace _newbina = 9498 if `1'== 5759
	qui replace _newbina = 9498 if `1'== 2626
	qui replace _newbina = 9498 if `1'== 494
	qui replace _newbina = 9498 if `1'== 7094
	qui replace _newbina = 9498 if `1'== 9277
	qui replace _newbina = 9498 if `1'== 1215
	qui replace _newbina = 9498 if `1'== 4550
	qui replace _newbina = 9498 if `1'== 84
	qui replace _newbina = 9498 if `1'== 5466
	qui replace _newbina = 9498 if `1'== 251
	qui replace _newbina = 9498 if `1'== 5107
	qui replace _newbina = 9498 if `1'== 3772
	qui replace _newbina = 9498 if `1'== 6404
	qui replace _newbina = 9498 if `1'== 3868
	qui replace _newbina = 9498 if `1'== 9897
	qui replace _newbina = 9498 if `1'== 9339
	qui replace _newbina = 9498 if `1'== 8900
	qui replace _newbina = 9498 if `1'== 7222
	qui replace _newbina = 9498 if `1'== 3651
	qui replace _newbina = 9498 if `1'== 7830
	qui replace _newbina = 9498 if `1'== 3267
	qui replace _newbina = 9498 if `1'== 9365
	qui replace _newbina = 9498 if `1'== 2181
	qui replace _newbina = 9498 if `1'== 3402
	qui replace _newbina = 9498 if `1'== 6543
	qui replace _newbina = 9498 if `1'== 5815
	qui replace _newbina = 9498 if `1'== 3795
	qui replace _newbina = 9498 if `1'== 8382
	qui replace _newbina = 9498 if `1'== 4510
	qui replace _newbina = 9498 if `1'== 6417
	qui replace _newbina = 9498 if `1'== 1318
	qui replace _newbina = 9498 if `1'== 9248
	qui replace _newbina = 9498 if `1'== 3535
	qui replace _newbina = 9498 if `1'== 3041
	qui replace _newbina = 9498 if `1'== 7309
	qui replace _newbina = 9498 if `1'== 8411
	qui replace _newbina = 9498 if `1'== 4095
	qui replace _newbina = 9498 if `1'== 932
	qui replace _newbina = 9498 if `1'== 6561
	qui replace _newbina = 9498 if `1'== 9576
	qui replace _newbina = 9498 if `1'== 2538
	qui replace _newbina = 9498 if `1'== 4663
	qui replace _newbina = 9498 if `1'== 5450
	qui replace _newbina = 9498 if `1'== 1955
	qui replace _newbina = 9498 if `1'== 1010
	qui replace _newbina = 9498 if `1'== 9474
	qui replace _newbina = 9498 if `1'== 7634
	qui replace _newbina = 9498 if `1'== 3956
	qui replace _newbina = 9498 if `1'== 8654
	qui replace _newbina = 9498 if `1'== 5483
	qui replace _newbina = 9498 if `1'== 7344
	qui replace _newbina = 9498 if `1'== 7993
	qui replace _newbina = 9498 if `1'== 7500
	qui replace _newbina = 9498 if `1'== 9356
	qui replace _newbina = 9498 if `1'== 5795
	qui replace _newbina = 9498 if `1'== 5437
	qui replace _newbina = 9498 if `1'== 8457
	qui replace _newbina = 9498 if `1'== 7807
	qui replace _newbina = 9498 if `1'== 6995
	qui replace _newbina = 9498 if `1'== 502
	qui replace _newbina = 9498 if `1'== 469
	qui replace _newbina = 9498 if `1'== 7328
	qui replace _newbina = 9498 if `1'== 6736
	qui replace _newbina = 9498 if `1'== 1400
	qui replace _newbina = 9498 if `1'== 5740
	qui replace _newbina = 9498 if `1'== 4780
	qui replace _newbina = 9498 if `1'== 7642
	qui replace _newbina = 9498 if `1'== 121
	qui replace _newbina = 9498 if `1'== 873
	qui replace _newbina = 9498 if `1'== 2080
	qui replace _newbina = 9498 if `1'== 5694
	qui replace _newbina = 9498 if `1'== 733
	qui replace _newbina = 9498 if `1'== 2207
	qui replace _newbina = 9498 if `1'== 9450
	qui replace _newbina = 9498 if `1'== 2174
	qui replace _newbina = 9498 if `1'== 7061
	qui replace _newbina = 9498 if `1'== 6632
	qui replace _newbina = 9498 if `1'== 9922
	qui replace _newbina = 9498 if `1'== 2223
	qui replace _newbina = 9498 if `1'== 5850
	qui replace _newbina = 9498 if `1'== 1780
	qui replace _newbina = 9498 if `1'== 7397
	qui replace _newbina = 9498 if `1'== 2992
	qui replace _newbina = 9498 if `1'== 741
	qui replace _newbina = 9498 if `1'== 9650
	qui replace _newbina = 9498 if `1'== 6616
	qui replace _newbina = 9498 if `1'== 4481
	qui replace _newbina = 9498 if `1'== 6342
	qui replace _newbina = 9498 if `1'== 822
	qui replace _newbina = 9498 if `1'== 7709
	qui replace _newbina = 9498 if `1'== 6512

	* banks that have changed groups
	qui replace _newbina = 8462 if (`1'==6851 & `2'<= 590)
	qui replace _newbina = 9180 if (`1'==6851 & `2'> 590)
	qui replace _newbina = 697 if (`1'==7618 & `2'<= 482)
	qui replace _newbina = 7618 if (`1'==7618 & `2'> 482)
	qui replace _newbina = 697 if (`1'==1853 & `2'<= 482)
	qui replace _newbina = 7618 if (`1'==1853 & `2'> 482)
	qui replace _newbina = 3419 if (`1'==3419 & `2'<= 482)
	qui replace _newbina = 8384 if (`1'==3419 & `2'> 482)
	qui replace _newbina = 697 if (`1'==1085 & `2'<= 482)
	qui replace _newbina = 8984 if (`1'==1085 & `2'> 482)
	qui replace _newbina = 7609 if (`1'==7609 & `2'<= 485)
	qui replace _newbina = 7618 if (`1'==7609 & `2'> 485)
	qui replace _newbina = 6179 if (`1'==1076 & `2'<= 668)
	qui replace _newbina = 1076 if (`1'==1076 & `2'> 668)
	qui replace _newbina = 7453 if (`1'==9084 & `2'<= 668)
	qui replace _newbina = 9084 if (`1'==9084 & `2'> 668)
	qui replace _newbina = 9831 if (`1'==9831 & `2'<= 593)
	qui replace _newbina = 7453 if (`1'==9831 & `2'> 593 & `2'<= 662)
	qui replace _newbina = 9831 if (`1'==9831 & `2'> 662)
	qui replace _newbina = 8384 if (`1'==709 & `2'<= 551)
	qui replace _newbina = 709 if (`1'==709 & `2'> 551)
	qui replace _newbina = 3419 if (`1'==7512 & `2'<= 485)
	qui replace _newbina = 8384 if (`1'==7512 & `2'> 485)
	qui replace _newbina = 7867 if (`1'==7867 & `2'<= 485)
	qui replace _newbina = 7618 if (`1'==7867 & `2'> 485)
	qui replace _newbina = 4037 if (`1'==4037 & `2'<= 503)
	qui replace _newbina = 8493 if (`1'==4037 & `2'> 503 & `2'<= 611)
	qui replace _newbina = 4037 if (`1'==4037 & `2'> 611)
	qui replace _newbina = 9079 if (`1'==9079 & `2'<= 500)
	qui replace _newbina = 9498 if (`1'==9079 & `2'> 500)
	qui replace _newbina = 9105 if (`1'==9105 & `2'<= 590)
	qui replace _newbina = 495 if (`1'==9105 & `2'> 590 & `2'<= 620)
	qui replace _newbina = 9105 if (`1'==9105 & `2'> 620)
	qui replace _newbina = 4394 if (`1'==4870 & `2'<= 611)
	qui replace _newbina = 8627 if (`1'==4870 & `2'> 611)

}
        
end
