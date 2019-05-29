
{smcl}
{.-}
help for {cmd:aggregate} {right:()}
{.-}
 
{title:Title}

aggregate - calculate aggregates by period (year or quarter) for the CRC datasets.

{title:Syntax}

{p 8 15}
{cmd:aggregate} {it:panelvar} {it:timevar}, [{it:options}]

{p}

{title:Description}

{p} 
This command computes aggregated values of credit and bank relationship. The ado should only be applied to the original CRC datasets prepared by BPLim.
 
 
{title:Options}

General Options

{p 0 4}{cmd: YEAR} aggregation by year. 

{p 0 4}{cmd: QUARTER} aggregation by quarter.

{p 0 4}{cmd: AVG} period average.

{p 0 4}{cmd: END} period end.

{p 0 4}{cmd: NOCHECK} ignore the difference between the current dataset and the original dataset prepared by BPLim.


{title:Examples}

Calculate year-end (December) value.

{p}

{p 8 16}{inp:. aggregate tina date, year end}{p_end}

{p}

Calculate quarter-end value.

{p}

{p 8 16}{inp:. aggregate tina date, quarter end}{p_end}

{p}

Calculate yearly average value.

{p}

{p 8 16}{inp:. aggregate tina date, year avg}{p_end}

{p}


Calculate quarterly average value.

{p}

{p 8 16}{inp:. aggregate tina date, quarter avg}{p_end}

{p}


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

