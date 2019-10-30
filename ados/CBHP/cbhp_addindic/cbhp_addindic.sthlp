
{smcl}
{.-}
help for {cmd:cbhp_addindic} {right:()}
{.-}

{title:Title}

cbhp_addindic - Computes a set of indicators available in the Harmonized Panel of Central Balance Sheet Database.

{title:Syntax}

{p 8 15}
{cmd:cbhp_addindic} {it:indicator(s)} [{help if}] [{help in}], [{it:options}]

{p}

{title:Description}

{p}
This command calculates a set of economic and financial indicators for non-financial corporations. The indicators available are:

R001 - Current ratio;

R002 - Quick ratio;

R003 - Capital ratio - QS;

R006 - Assets to equity ratio;

R007 - Solvency ratio - QS;

R009 - Non-current assets coverage ratio;

R023 - Financial Cost Effect;

R034 - Return on sales;

R036 - Return on assets - QS;

R040 - EBITDA over Turnover;

R041 - Degree of combined leverage;

R050 - Asset turnover (times) - QS;

R056 - Coefficient Fixed non-financial assets over employee expenses;

R150 - Asset turnover ratio;

R152 - Profit or loss of the year before taxes (EBT) / Equity;

R155 - Profit or loss of the year before taxes (EBT) / Net turnover;

R156 - Equity / Total assets;

R157 - Trade payables / Total assets;

R158 - Total income / Net turnover;

R159 - Total expenses / Net turnover;

R160 - Financial fixed assets / Total assets;

R161 - Trade receivables / Total assets.

The command is implemented for the original dataset of the Central Balance Sheet Harmonized Panel made available by BPLIM (CBHP_A_YFRM_yyyyYYYY_eeee_CONTAS_V01.dta).

{title:Options}

General Options

{p 0 4}{opt save(filename)} saves all the indicators calculated in a data set named {it:filename} in the current working directory.


{title:Examples}

Example 1:
Calculation of the indicator R001 (Current ratio)

{p 8 16}{inp:. cbhp_addindic R001}{p_end}

Example2:
Calculation of all indicators available in the harmonized panel of Central Balance Sheet Database

{p 8 16}{inp:. cbhp_addindic all}{p_end}

Example3:
Calculation of all indicators and save in a separate dataset
{p 8 16}{inp:. cbhp_addindic all, save({it:filename})}{p_end}


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

I appreciate your feedback. Comments are welcome!
