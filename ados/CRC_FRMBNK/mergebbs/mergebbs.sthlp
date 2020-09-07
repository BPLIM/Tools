
{smcl}
{.-}
help for mergebbs {right:()}
{.-}
 
{title:Title}

mergebbs - Creates linking ids for financial institutions in the Bank Balance Sheet Database (BBS) for the
purpose of merging with the Central Credit Responsibility Database (CRC).


{title:Syntax}

{p 8 15}
{cmd:mergebbs} {it:bankvar} {it:timevar}, [{it:options}]

{p}

{title:Description}

{p} 

This command aims to harmonize bank ids in BBS and CRC, accounting for the situations when asset restructuring 
(shown in BBS) occurs later than credit transfer (shown in CRC) in the events of Mergers and Acquisitions (M&As).

This command needs to be implemented along with the "mergecrc" command. The former is to be implemented on BBS. 
The latter is to be implemented on CRC.
 
Both commands return a variable "_newbina" with which users can use to merge BBS with CRC. 

The generated variable "_newbina" corresponds to the id of the acquiring bank for the unmatched period.


{title:Examples}

Creates linking ids for financial institutions (bina) over time (date), accounting for bank M&As.

{p 8 16}{inp:. mergebbs bina date}{p_end}


{title:Remarks}

Please notice that this software is provided "as is", without warranty of any kind, whether
express, implied, or statutory, including, but not limited to, any warranty of merchantability
or fitness for a particular purpose or any warranty that the contents of the item will be error-free.
In no respect shall the author incur any liability for any damages, including, but limited to, 
direct, indirect, special, or consequential damages arising out of, resulting from, or any way 
connected to the use of the item, whether or not based upon warranty, contract, tort, or otherwise. 


{title:Author}

{p}
Sujiao (Emma) Zhao, BPlim, Banco de Portugal, Portugal.

{p}
Email: {browse "mailto:szhao@bportugal.pt":szhao@bportugal.pt}

I appreciate your feedback. Comments are welcome!

