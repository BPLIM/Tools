{smcl}
{* *! version 0.1 29Apr2022}{...}{smcl}
{.-}
help for {cmd:metaxl check} {right:}
{.-}

{title:Title}

{pstd}
{cmd:metaxl check} {hline 1} checks for inconsistencies in metadata

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:metaxl check}
{cmd:} , {opt meta:file(fn)} [{it:options}]

{synoptset 30 tabbed}{...}
{marker table_options}{...}
{synopthdr}
{synoptline}
{syntab :Options}
{p2coldent :* {opt meta:file(fn)}} is name of the Excel file where the 
metadata is stored.
{p_end}
{synopt :{opt check:file(fn [, replace])}} saves the inconsistencies found by the command in the Excel file {it:fn.xlsx}.
{p_end}
{synopt :{opt del:imit(delimiter)}} sets a delimiter for labels in value labels. 
Only the text after the delimiter is considered to find warnings or 
inconsistencies. This option is useful to find duplicated descriptions in 
value labels when the first word of the label is the value (see {help numlabel}).
{p_end}
{synoptline}
{p 4 6 2}
* required{p_end}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}

{pstd}
{opt metaxl check} is a Stata command that verifies the integrity of metadata stored
in an Excel file. The command assumes that the Excel file has the structure of the 
file produced by {help metaxl_extract:metaxl extract}. The program searches for 
possible problems in the metadata, dividing them into warnings and inconsistencies, 
the latter being the most problematic. 

{pstd}
The categorization of problems into warnings and inconsistencies is related to the 
use of {help metaxl_apply:metaxl apply}, which performs an integrity check of 
the metadata before applying it. So an inconsistency is every problem found in the 
Excel file that stops {help metaxl_apply:metaxl apply} from running. On the other 
hand, warnings flag problems in the metadata, but do not halt the execution of 
{help metaxl_apply:metaxl apply}.

{pstd} 
Inconsistencies include duplicated variables in the meta file, missing sheets, and
duplicated labels or duplicated values in value labels. Warnings cover problems such
as duplicated data features, missing variable labels, truncated variable labels, 
missing value labels if there is more than one language defined, as well as problems 
with value labels other than duplicated labels or values. Most of the value label 
problems were based on {help labelbook}, used with option {opt problems}.


{marker stored_results}{...}
{title:Stored results}

{pstd}
{cmd:metaxl check} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 15 19 2: Locals}{p_end}
{synopt:{cmd:r(inconsistencies)}}inconsistencies found{p_end}
{synopt:{cmd:r(warnings)}}warnings found{p_end}
{p2colreset}{...}   


{title:Examples}

{pstd}
Check metadata from file {it:meta_auto.xlsx}.

{p 8 16}{inp:. metaxl check, meta(meta_auto)}{p_end}

{pstd}
Check metadata from file {it:meta_auto.xlsx}. Save the report in {it:checkfile.xlsx}. Consider
the text only after the space (" ") to find problems in value labels.

{p 8 16}{inp:. metaxl check, meta(meta_auto) check(checkfile)} del(" "){p_end}

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
{cmd:gtools} package by Mauricio Bravo{p_end}


{title:Author}

{pstd}
BPLIM, Banco de Portugal, Portugal.

{pstd}
Email: {browse "mailto:bplim@bportugal.pt":bplim@bportugal.pt}

We appreciate your feedback. Comments are welcome!

