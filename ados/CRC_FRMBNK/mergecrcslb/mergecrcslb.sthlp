
{smcl}
{.-}
help for {cmd:mergecrcslb} {right:()}
{.-}
 
{title:Title}

mergecrcslb - Creates linking ids for financial institutions in Central Credit Register (CRC) 
for the purpose of merging with Long Series of the Portuguese Banking Sector (SLB).


{title:Syntax}

{p 8 15}
{cmd:mergecrcslb} {it:bankvar} {it:timevar}

{p}

{title:Description}

{p} 

This command aims to harmonize bank ids in CRC and SLB, given that SLB reports consolidated 
information while CRC reports individual-level information.

This command needs to be implemented on monthly CRC bank-firm level data or exposure level data 
and is only valid for the period from January, 1999 to August, 2018. BPLIM's anonymized bank id 
(i.e., bina) needs to be present in the dataset. Running the command will return a variable 
"_newbina" with which users can use to merge CRC with SLB. The generated variable "_newbina" 
corresponds to the id of the consolidated bank as present in SLB.


{title:Examples}

Creates linking ids between CRC and SLB for financial institutions (bina) over time (date)

{p 8 16}{inp:. mergecrcslb bina date}{p_end}


{title:Remarks}

Please notice that this software is provided "as is", without warranty of any kind, whether
express, implied, or statutory, including, but not limited to, any warranty of merchantability
or fitness for a particular purpose or any warranty that the contents of the item will be error-free.
In no respect shall the author incur any liability for any damages, including, but limited to, 
direct, indirect, special, or consequential damages arising out of, resulting from, or any way 
connected to the use of the item, whether or not based upon warranty, contract, tort, or otherwise. 


{title:Author}

{p}
Sujiao (Emma) Zhao, BPLIM, Banco de Portugal, Portugal.

{p}
Email: {browse "mailto:szhao@bportugal.pt":szhao@bportugal.pt}

I appreciate your feedback. Comments are welcome!

