
{smcl}
{.-}
help for {cmd:linkbank} {right:()}
{.-}

{title:Title}

linkbank - Creates linking ids for financial institutions in Central Credit Register (CRC) for the purpose of merging with Bank Balance Sheet (BBS)
or Historical Series of the Portuguese Banking Sector (SLB).


{title:Syntax}

{p 8 15}
{cmd:linkbank} {it:bankid} {it:timeid}, [{it:options}]

{p}

{title:Description}

{p}

This command aims to harmonize bank ids in CRC
{space 4}1) with BBS, given that CRC reports includes all credit-granting institutions while BBS only includes monetary financial institutions;
{space 4}2) or with SLB given that SLB reports consolidated information while CRC reports individual-level information.

{title:Option}
{p 0 4}

{cmd: base} specifies the database to link with (BBS or SLB)

{cmd: method} specifies the linking method

{p 8 16}

{space 4}group: For the non-monetary financial institutions that are not present in BBS or SLB, this option allows to assign ids of the parent banks.

{space 4}MA: In the events of Mergers and Acquisitions (M&As) credit transfer (shown in CRC) may occur later than asset restructuring (shown in BBS and SLB).
{space 8}This option allows to assign the id of the acquiring bank if the acquired bank continues to report credits in CRC while stops to be reported
{space 8}in BBS/SLB.

{space 4}Both: This is the default option, allowing to assign ids considering both situations.


{p 0 4}

{cmd: replace} replace the bank id with the new linking bank id that users can use to merge CRC with BBS/SLB

{cmd: generate} creates a variable {it: new_var} with the new linking bank id that users can use to merge CRC with BBS/SLB

{cmd: keepindicator} indicates the situations in which the new linking bank id is assigned

{cmd: add} includes further information on the institutions

{space 4}group: indicates the banking group to which a financial institution belongs and the type of affiliation.

{space 4}event: indicates banking events - Mergers and Acquisitions (M&As), sales, and resolutions, and the type of counterparties.

{space 4}all: includes all information.



{title:Examples}

{pstd}
Example 1:

{space 4}Replace the bank id with the linking id for financial institutions (bina) over time (date), accounting for bank M&As

{p 8 16}{inp:. linkbank bina date, base(BBS) method(MA) replace}{p_end}

{pstd}
Example 2:

{space 4}Creates a new linking id ({it:newid}) between CRC and SLB and indicating the linking type for financial institutions (bina)over time (date),
{space 4}accounting for bank M&As and banking groups. In the case of bank M&As, specifies the event and the counterparty types.

{p 8 16}{inp:. linkbank bina date, base(SLB) gen(newid) method(both) keepind add(event)}{p_end}



{title:Remarks}

Please notice that this software is provided "as is", without warranty of any kind, whether express, implied, or statutory, including, but not limited
to, any warranty of merchantability or fitness for a particular purpose or any warranty that the contents of the item will be error-free.
In no respect shall the author incur any liability for any damages, including, but limited to, direct, indirect, special, or consequential damages
arising out of, resulting from, or any way connected to the use of the item, whether or not based upon warranty, contract, tort, or otherwise.


{title:Author}

{p}
Sujiao (Emma) Zhao, BPLIM, Banco de Portugal, Portugal.

{p}
Email: {browse "mailto:szhao@bportugal.pt":szhao@bportugal.pt}

I appreciate your feedback. Comments are welcome!
