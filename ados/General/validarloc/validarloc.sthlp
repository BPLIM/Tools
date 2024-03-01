{smcl}
{* *! version 0.1 23Feb2024}{...}{smcl}
{.-}
help for {cmd:validarloc} {right:}
{.-}

{title:Title}

{pstd}
{cmd:validarloc} {hline 1} provides several functionalities for dealing with
official codes from Portugal's administrative division

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:validarloc}
{cmd:} {help varname:varname} [{help if}], [{it:options}]

where {it:varname} is a variable containing administrative division codes

{marker options}{...}
{title:Options}

{synoptset 32 tabbed}{...}
{marker table_options}{...}
{synopthdr}
{synoptline}
{syntab :Options}
{synopt :{opt ref:date(referencedate)}} sets a reference date to validate codes. 
The date provided should be a string in "DMY" format (see {help date}).
{p_end}

{synopt :{opt getlevels}({it:numlist}[, {opt num}])} returns (a) variable(s)
with the same or higher aggregation level for validated codes. The levels and 
their designations differ according to the reference date provided. The  
user must set a reference date (option {opt refdate}). The option returns 
two variables per level, the code and the code description.
{break}{space 5}{break}
{opt num} converts the two returned string variables into a numeric variable 
with value labels. Since parishes' codes may contain letters, there is a conversion 
from letters to numbers in these administrative divisions.
{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}

{pstd}
{cmd: validarloc} is a Stata command that provides several functionalities to
deal with official codes from Portugal's administrative division. The division 
comprises districts (distritos), municipalities (concelhos) and parishes 
(freguesias).

{pstd}
The command validates codes from districts, municipalities and parishes, 
returning three variables, one with information about the codes' 
validity - {it:_valid_loc}, and the other two with details about codes' 
time span validity - {it:_valid_from} and {it:_valid_to}. If a reference date 
is provided (option {opt refdate}), then the command will check the codes' 
validity based on that date, possibly changing the outcome of variable 
{it:_valid_loc}.

{pstd}
The option {opt getlevels} allows users to obtain, for valid codes, official 
codes at a higher (or same) level of aggregation. The aggregation provided will 
be contingent on the reference date, since the administrative division changes 
over time. There are three levels available - districts (1), municipalities (2) 
and parishes (3).


{title:Examples}

{pstd}
Example 1:
Validate codes in variable {it:freguesia}.

{p 8 16}{inp:. validarloc freguesia}{p_end}

{pstd}
Example 2:
Validate codes in variable {it:freguesia}, checking if codes are 
valid for a specific reference date.

{p 8 16}{inp:. validarloc freguesia, refdate(24-12-2023)}{p_end}

{pstd}
Example 3:
Same as Example 2, but additionally get the numeric variables district and 
municipality for valid codes.

{p 8 16}{inp:. validarloc freguesia, refdate(24-12-2023) getlevels(1 2, num)}{p_end}

{pstd}
Example 4:
Same as Example 2, but additionally get the official codes and descriptions for 
valid parishes.

{p 8 16}{inp:. validarloc freguesia, refdate(24-12-2023) getlevels(3)}{p_end}

{title:Remarks}

{pstd}
Please notice that this software is provided "as is", without warranty of any kind, whether
express, implied, or statutory, including, but not limited to, any warranty of merchantability
or fitness for a particular purpose or any warranty that the contents of the item will be error-free.
In no respect shall the author incur any liability for any damages, including, but limited to,
direct, indirect, special, or consequential damages arising out of, resulting from, or any way
connected to the use of the item, whether or not based upon warranty, contract, tort, or otherwise.


{title:Dependencies}

{pstd}
{cmd:labmask} by Nicholas Cox {p_end}

{title:Author}

{pstd}
BPLIM, Banco de Portugal, Portugal.

{pstd}
Email: {browse "mailto:bplim@bportugal.pt":bplim@bportugal.pt}

We appreciate your feedback. Comments are welcome!
