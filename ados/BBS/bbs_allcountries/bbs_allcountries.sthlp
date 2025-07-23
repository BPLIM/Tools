
{smcl}
{.-}
help for {cmd:bbs_allcountries} {right:()}
{.-}

{title:Title}

bbs_allcountries - Calculates the total value of balance sheet items across all countries in the 
Monetary Financial Institutions Balance Sheet Database (BBS)

.

{title:Syntax}

{p 8 15}
{cmd:bbs_allcountries} 
{cmd:} {help varlist:varlist}

where {it:varlist} is the list of variables considered in the aggregation criteria

{p}

{title:Description}

{p}

This command calculates the total value of balance sheet items for all countries, following the 
aggregation criteria defined by the user in {it:varlist}.

The command is implemented for the Monetary Financial Institutions Balance Sheet Database (BBS) 
extractions up to JUN22 (included) made available by BPLIM (BBS_A_MBNK_mmmyyyyMMMYYYY_eeeee_ASSET_Vxx.dta
and BBS_A_MBNK_mmmyyyyMMMYYYY_eeeee_LIAB_Vxx.dta). The command is valid for both the harmonized 
(SEP1997MMMYYYY) and the non-harmonized (DEC2014MMMYYYY) datasets. Make sure you do not delete the original datalabel. 

The rules followed in the command are:

- Country aggregation rule: country==TP-UM | country==UM-PT | country==PRT | missing(country)
- Total assets calculation in the harmonized BBS: excludes the financial instrument "90 Units", to prevent 
double counting. It requires that the variable instrument_asset is in the dataset, even if the aggregation 
is not performed by instrument_asset. 

Please refer to the manual for details.


{title:Examples}

Example 1:
Aggregated value by bina and date

{p 8 16}{inp:. bbs_allcountries bina date}{p_end}


Example 2:
Aggregated value by bina, date, instrument_asset, and counterparty_asset

{p 8 16}{inp:. bbs_allcountries bina date instrument_asset counterparty_asset}{p_end}


{title:Remarks}

Please notice that this software is provided "as is", without warranty of any kind, whether
express, implied, or statutory, including, but not limited to, any warranty of merchantability
or fitness for a particular purpose or any warranty that the contents of the item will be error-free.
In no respect shall the author incur any liability for any damages, including, but limited to,
direct, indirect, special, or consequential damages arising out of, resulting from, or any way
connected to the use of the item, whether or not based upon warranty, contract, tort, or otherwise.


{title:Author}

{p}
BPLIM, Banco de Portugal, Portugal.

{p}
Email: {browse "mailto:bplim@bportugal.pt":bplim@bportugal.pt}

We appreciate your feedback. Comments are welcome!