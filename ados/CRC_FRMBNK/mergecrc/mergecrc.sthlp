
{smcl}
{.-}
help for {cmd:mergecrc} {right:()}
{.-}
 
{title:Title}

mergecrc - Creates linking ids for financial institutions in Central Credit Register (CRC) for the
purpose of merging with Bank Balance Sheet (BBS).


{title:Syntax}

{p 8 15}
{cmd:mergecrc} {it:bankvar} {it:timevar}, [{it:options}]

{p}

{title:Description}

{p} 

This command aims to harmonize bank ids in CRC and BBS, given that in the events of Mergers and 
Acquisitions (M&As) credit transfer (shown in CRC) may occur later than asset restructuring 
(shown in BBS).

For the financial institutions that are not present in BBS, this command also provides an option 
to aggregate the credits at their parent bank level.


This command needs to be implemented along with the "mergebbs" command. The former is to be 
implemented on CRC. The latter is to be implemented on BBS.
 
Both commands return a variable "_newbina" with which users can use to merge CRC with BBS. 

The generated variable "_newbina" corresponds to the id of the acquiring bank for the unmatched 
period (for M&As) or the id of the parent bank for the unmatched institution.

 
{title:Option}
{p 0 4}

{cmd: group} aggregates credit at the parent bank level. In this case, the generated variable
 "_newbina" corresponds to the id of the parent bank.

{p}

This option will not be implemented by default and can only be applied to institutions who are
not present in BBS, but whose parent banks are. 


{title:Examples}

Creates linking ids for financial institutions (bina) over time (date), accounting for bank 
M&As and banking groups

{p 8 16}{inp:. mergecrc bina date, group}{p_end}


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

