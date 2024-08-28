{smcl}
{* *! version 0.1 28Aug2024}{...}{smcl}
{.-}
help for {cmd:metaxl clear} {right:}
{.-}

{title:Title}

{pstd}
{cmd:metaxl clear} {hline 1} removes all metadata from data in memory

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:metaxl clear}
{cmd:} , [{it:options}]

{synoptset 20 tabbed}{...}
{marker table_options}{...}
{synopthdr}
{synoptline}
{syntab :Options}
{synopt :{opt force}} removes all metadata without asking confirmation from 
the user.
{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}

{pstd}
{opt metaxl clear} is a Stata command that removes all metadata from data in 
memory (labels, value labels, characteristics, etc.). Considering its negative 
effects if used by mistake, the command asks the user for confirmation in order 
to proceed with the deletion of all the metadata. Specifying option {opt force} 
changes this behavior.


{title:Examples}

{pstd}
Remove all metadata without confirmation by the user.

{p 8 16}{inp:. metaxl clear, force}{p_end}


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

