{smcl}
{* *! version 2.0.0 October 2025}{...}
{vieweralsosee "" "--"}{...}
{viewerjumpto "Syntax" "linkbank##syntax"}{...}
{viewerjumpto "Description" "linkbank##description"}{...}
{viewerjumpto "Options" "linkbank##options"}{...}
{viewerjumpto "Results" "linkbank##results"}{...}
{viewerjumpto "Examples" "linkbank##examples"}{...}
{viewerjumpto "Remarks" "linkbank##remarks"}{...}
{viewerjumpto "Author" "linkbank##author"}{...}
{.-}
help for {cmd:linkbank} {right:}
{.-}

{title:Title}

{pstd}
{cmd:linkbank} {hline 1} Creates linking IDs for financial institutions in Central Credit Register (CRC) and related datasets for 
merging with Bank Balance Sheet (BBS) or Historical Series of the Portuguese Banking Sector (SLB)


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:linkbank}
{it:bankid} {it:timeid}{cmd:,} {opt base(string)}

{synoptset 25 tabbed}{...}
{marker table_options}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{p2coldent:* {opt base(string)}}specifies the dataset to link with; options are {cmd:bbs} or {cmd:slb}{p_end}
{synoptline}
{p 4 6 2}
* required{p_end}
{p2colreset}{...}
{p 4 6 2}

{pstd}
where {it:bankid} is the variable containing the financial institution identifier (e.g., {it:bina}) and {it:timeid} is the time variable (e.g., {it:date}).


{marker description}{...}
{title:Description}

{pstd}
{cmd:linkbank} is a tool developed by BPLIM to accurately match individual entity records from datasets based on Central 
Credit Register data (such as CRC and HCRC) with datasets that use different units of analysis, such as SLB (banking 
groups or stand-alone institutions) or BBS (stand-alone institutions). Its main objectives are:

{phang2}
1) Ensure consistent linking across datasets with different units of observation

{phang2}
2) Clarify the scope differences between datasets

{pstd}
The command works by merging your data with a crosswalk table maintained by BPLIM that tracks institutional relationships 
over time, including mergers, acquisitions, and changes in group structure. The matching is time-aware, meaning it correctly 
handles cases where an institution's status or group membership changes over time.

{pstd}
It should be applied to the dataset with the most granular information (i.e., CRC-like datasets). It supports 
linking from December 1999 onward and is updated annually to extend coverage. To verify that your version includes the 
period you need, type {cmd:which linkbank}.

{pstd}
It adds two new variables to your dataset: {cmd:id_}{it:`base'} and {cmd:note_}{it:`base'}, while keeping the original {it:bankid}
unchanged. All observations from your original dataset are preserved. 

{pstd}
It does not clear previous results from other bases, so you can add both SLB and BBS IDs to the same dataset 
by running the command twice with different {opt base()} options. For more details, consult the user guide for {cmd:linkbank}.


{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opt base(string)} specifies the dataset to link with. This option is required. Available options are:

{phang2}
{cmd:bbs} - Link with Bank Balance Sheet data (available from December 2014 onward)

{phang2}
{cmd:slb} - Link with Historical Series of the Portuguese Banking Sector


{marker results}{...}
{title:Results}

{pstd}
The command creates two variables:

{phang2}
{cmd:id_}{it:`base'} - The corresponding identifier in the target dataset (e.g., {cmd:id_bbs} or {cmd:id_slb})

{phang2}
{cmd:note_}{it:`base'} - Contextual information explaining the match (e.g., {cmd:note_bbs} or {cmd:note_slb})

{pstd}
It preserves all observations from your original dataset. Observations that cannot be matched to the target 
dataset will have missing values for {cmd:id_}{it:`base'}, with {cmd:note_}{it:`base'} explaining why no match was found. For complete 
explanations of all possible notes, consult the {cmd:linkbank} user guide.


{marker examples}{...}
{title:Examples}

{pstd}
Add the corresponding BBS ID and explanation for financial institutions ({it:bina}) over time ({it:date}):

{p 8 16}{inp:. linkbank bina date, base(bbs)}{p_end}

{pstd}
This adds variables {cmd:id_bbs} and {cmd:note_bbs} to your dataset.

{pstd}
Add the corresponding SLB ID and explanation:

{p 8 16}{inp:. linkbank bina date, base(slb)}{p_end}

{pstd}
This adds variables {cmd:id_slb} and {cmd:note_slb}. 


{marker remarks}{...}
{title:Remarks}

{pstd}
Please note that this software is provided "as is", without warranty of any kind, whether express, implied, or
statutory, including, but not limited to, any warranty of merchantability or fitness for a particular purpose, or
any warranty that the contents will be error-free. In no respect shall the author incur any liability
for any damages, including, but not limited to, direct, indirect, special, or consequential damages arising out of, 
resulting from, or in any way connected to the use of this software, whether or not based upon warranty, contract, tort, 
or otherwise.


{marker author}{...}
{title:Author}

{pstd}
Sujiao (Emma) Zhao

{pstd}
Ana Isabel Sá, BPLIM, Banco de Portugal, Portugal

{title:Contact}

{pstd}
Ana Isabel Sá, BPLIM, Banco de Portugal, Portugal

{pstd}
Email: {browse "mailto:aisa@bportugal.pt":aisa@bportugal.pt}

{pstd}
We appreciate your feedback. Comments are welcome!