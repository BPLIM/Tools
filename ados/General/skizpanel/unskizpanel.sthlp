{smcl}
{* *! version 0.1 09Feb24}{...}{smcl}
{.-}
help for {cmd:unskizpanel} {right:}
{.-}

{title:Title}

{pstd}
{cmd:unskizpanel} {hline 1} expands a previously "skizzed" panel of data.

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:unskizpanel}
{cmd:} {it:panelvar} {it:timevar} [, {it:options}]

{marker description}{...}
{title:Description}

{pstd}
{opt unskizpanel} is a Stata command that expands the observations of a panel dataset that was previously "skizzed", returning to the original data set.

{pstd}
Note that if the "skizzed" panel was created with the option {bf:nogaps} or the option {bf:variables} with the suboption {it: keepvars} then {cmd: unskizpanel} will not be allowed. 
You can expand a "skizzed" dataset created with the option {bf:nogaps} by specifying the option {bf:fillgaps}. Be warned that in this case the "unskizzed" data will differ from the original data.  

{marker options}{...}
{title:Options}

{synoptset 30 tabbed}{...}
{marker table_options}{...}
{synopthdr}
{synoptline}
{synopt:{opt countvar}}determines the name of the countvar. If this option is not specified, the command assumes that the name of the {opt countvar} is {it:_nrep}.
{p_end}
{synopt:{opt missvar}}determines the name of the missvar. If this option is not specified, the command assumes that the name of the {opt missvar} is {it:_nmiss}.
{p_end}
{synopt:{ul:{opt fillg}}{opt aps}}fill the gaps in the original data. By default, the "unskiz" expands the observations according to the value of {it:countvar}. 
The option {bf:fillgaps} determines that the "unskiz" be done according to the sum of {it:countvar} and {it:missvar}, thus filling all existing gaps. 
This option is only allowed in a panel "skizzed" with the option {bf:nogaps} and will not recover the original data.
{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker examples}{...}
{title:Examples}

{ul:Example 1:} 

{tab}{input:    id      date           name         brand         _nrep}
{tab}{hline 60}
{tab}{sf:    105     01/01/2023     banana       brand a       3}
{tab}{hline 60}
{tab}{sf:    105     11/01/2023     banana       brand a       2}
{tab}{hline 60}
{tab}{sf:    106     01/01/2023     apple        brand b       2}
{tab}{hline 60}

{pstd}
Unsquiz a panel.

{p 8 16}{inp:. unskizpanel id date}{p_end}   
{tab}{input:    id      date           name         brand}
{tab}{hline 49}
{tab}{sf:    105     01/01/2023     banana       brand a}
{tab}{hline 49}
{tab}{sf:    105     02/01/2023     banana       brand a}
{tab}{hline 49}
{tab}{sf:    105     03/01/2023     banana       brand a}
{tab}{hline 49}
{tab}{sf:    105     11/01/2023     banana       brand a}
{tab}{hline 49}
{tab}{sf:    105     12/01/2023     banana       brand a}
{tab}{hline 49}
{tab}{sf:    106     01/01/2023     apple        brand b}
{tab}{hline 49}
{tab}{sf:    106     02/01/2023     apple        brand b}
{tab}{hline 49}

{ul:Example 2:} 
 
{tab}{input:    id      date           name         brand          _nrep     _miss}
{tab}{hline 71}
{tab}{sf:    105     01/01/2023     banana       brand a        5         7}
{tab}{hline 71}
{tab}{sf:    106     01/01/2023     apple        brand b        2         0}
{tab}{hline 71}

{pstd}
Unsquiz a panel filling in the gaps in the original data.

{p 8 16}{inp:. unskizpanel id date _nrep, fillgaps}{p_end}   
{tab}{input:    id      date           name           brand       _nmiss}
{tab}{hline 61}
{tab}{sf:    105     01/01/2023     banana       brand a       7}
{tab}{hline 61}
{tab}{sf:    105     02/01/2023     banana       brand a       7}
{tab}{hline 61}
{tab}{sf:    105     03/01/2023     banana       brand a       7}
{tab}{hline 61}
{tab}{sf:    105     04/01/2023     banana       brand a       7}
{tab}{hline 61}
{tab}{sf:    105     05/01/2023     banana       brand a       7}
{tab}{hline 61}
{tab}{sf:    105     06/01/2023     banana       brand a       7}
{tab}{hline 61}
{tab}{sf:    105     07/01/2023     banana       brand a       7}
{tab}{hline 61}
{tab}{sf:    105     08/01/2023     banana       brand a       7}
{tab}{hline 61}
{tab}{sf:    105     09/01/2023     banana       brand a       7}
{tab}{hline 61}
{tab}{sf:    105     10/01/2023     banana       brand a       7}
{tab}{hline 61}
{tab}{sf:    105     11/01/2023     banana       brand a       7}
{tab}{hline 61}
{tab}{sf:    105     12/01/2023     banana       brand a       7}
{tab}{hline 61}
{tab}{sf:    106     01/01/2023     apple        brand b       0}
{tab}{hline 61}
{tab}{sf:    106     02/01/2023     apple        brand b       0}
{tab}{hline 61}

{marker remarks}{...}
{title:Remarks}

{pstd}
Please notice that this software is provided "as is", without warranty of any kind, whether
express, implied, or statutory, including, but not limited to, any warranty of merchantability
or fitness for a particular purpose or any warranty that the contents of the item will be error-free.
In no respect shall the author incur any liability for any damages, including, but limited to,
direct, indirect, special, or consequential damages arising out of, resulting from, or any way
connected to the use of the item, whether or not based upon warranty, contract, tort, or otherwise.

{title:Author}

{pstd}
BPLIM, Banco de Portugal, Portugal.

{pstd}
Email: {browse "mailto:bplim@bportugal.pt":bplim@bportugal.pt}

We appreciate your feedback. Comments are welcome!