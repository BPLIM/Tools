{smcl}
{* *! version 0.1 16Apr2021}{...}{smcl}
{.-}
help for {cmd:metaxl cmp} {right:}
{.-}

{title:Title}

{pstd}
{cmd:metaxl cmp} {hline 1} compares metadata files

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:metaxl cmp}
{cmd:} , {opt f1(fn)} {opt f2(fn)} [{it:options}]

{synoptset 30 tabbed}{...}
{marker table_options}{...}
{synopthdr}
{synoptline}
{syntab :Options}
{p2coldent :* {opt f1(fn)}} is the name of the first Excel file where the metadata is stored.
{p_end}
{p2coldent :* {opt f2(fn)}} is name of the second Excel file where the metadata is stored.
{p_end}
{synopt :{opt export(fn)}} saves the inconsitencies found by the command in the Excel file {it:fn.xlsx}.
Defaults to {it:metacmp.xlsx}.
{p_end}
{synopt :{opt replace}} replaces the exported  Excel file if it exists.
{p_end}
{synoptline}
{p 4 6 2}
* required{p_end}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}

{pstd}
{opt metaxl cmp} is a Stata command that compares metadata found in two Excel files. 
The command assumes that both Excel files have the structure of the file produced by 
{help metaxl_extract:metaxl extract}.

{pstd}
The program compares both meta files under the assumption that the files should be 
identical (the exception being data features) so any difference between them is 
labeled as an inconsistency. It searches for inconsistencies in variables, characteristics,
 notes and value labels. If any inconsistency is found, a report is produced.


{marker stored_results}{...}
{title:Stored results}

{pstd}
{cmd:metaxl cmp} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 15 19 2: Locals}{p_end}
{synopt:{cmd:r(inconsistencies)}}Number of inconsistencies found{p_end}
{p2colreset}{...}   


{title:Examples}

{pstd}
Compare metadata from files {it:meta_auto1.xlsx} and {it:meta_auto2.xlsx}. Save the report in {it:comp.xlsx}

{p 8 16}{inp:. metaxl cmp, new(meta_auto1) old(meta_auto2) export(comp)}{p_end}


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

