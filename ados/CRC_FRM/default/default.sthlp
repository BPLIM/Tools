
{smcl}
{.-}
help for {cmd:default} {right:()}
{.-}
 
{title:Title}

default - Computes default event.

{title:Syntax}

{p 8 15}
{cmd:default} {it:panelvar} {it:timevar} {it:overduevar} {it:benchmarkvar}, [{it:options}]

{p}

{title:Description}

{p} 
This command computes default events based on a panel dataset. The overdue credit level and the benchmark credit need to be specified.

{p} 

The command returns a variable "_flag" with the following values:
 0 - No credit is past due;
 1 - Overdue credit below the threshold;
 2 - Overdue credit above the threshold.
 
{p}
 
The default event "_default" is flagged out with the following values:
 0 - No default occurred;
 1 - Default.
 
{p}
 
The first default event "_fdefault" is flagged out with the following value:
 1 - Occurrence of the first default for a debtor.
 
 
{title:Options}

General Options

{p 0 4}{cmd: THRESHOLD} a pre-determined threshold of overdue credit ratio, 0.025 by default. 

{p 0 4}{cmd: RUNS} a sequence/run of consecutive threshold hits for the same individual, 3 by default.

{p 0 4}{cmd: IGNOREGAP} allow gaps in the data when counting runs.


{title:Examples}

Define default using the overdue credit threshold of 0.03 and the minimum run of 3 periods in which overdue credit is the total overdue credit level dividing by the total effective credit.

{p 8 16}{inp:. default BPLim_IDsearch date valor_vencido valor_efectivo, thr(0.03) run(3)}{p_end}

{title:Reference}

António Antunes, Homero Gonçalves, and Pedro Prego, 2016. Firm default probabilities revisited. Banco de Portugal Economic Paper Series.


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

