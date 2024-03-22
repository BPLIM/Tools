{smcl}
{* *! version 0.1 2Mar2021}{...}{smcl}
{.-}
help for {cmd:mdata combine} {right:}
{.-}

{title:Title}

{pstd}
{cmd:mdata combine} {hline 1} combines metadata files

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:mdata combine}
{cmd:} , {opt f1(fn)} {opt f2(fn)} [{it:options}]

{synoptset 30 tabbed}{...}
{marker table_options}{...}
{synopthdr}
{synoptline}
{syntab :Options}
{p2coldent :* {opt f1(fn)}} is the name of the first Excel file where the 
metadata is stored.
{p_end}
{p2coldent :* {opt f2(fn)}} is name of the second Excel file where the 
metadata is stored.
{p_end}
{synopt :{opt meta:file(fn [, replace])}} saves the combined metadata in the Excel file {it:fn.xlsx}.
Defaults to {it:metafile.xlsx}.
{p_end}
{synoptline}
{p 4 6 2}
* required{p_end}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}

{pstd}
{opt mdata combine} is a Stata command that combines metadata found in two Excel files. 
The command assumes that both Excel files have the structure of the file produced by 
{help mdata_extract:mdata extract}.

{pstd}
The program combines metadata in sheets with the same name found in both files, 
eliminating duplicated information. metadata that only appears in one file for 
namesake sheets are flagged in the generated {opt metafile}. Any row in this 
condition will have a value of {opt f1} or {opt f2} in column file#, that indicates 
that the information only appears in file {opt f1} or file {opt f2}, respectively.

{pstd}
There are cases where more than one column of the type file# may exist. Imagine that 
you are combining a file which has already been combined. Sheets in that meta file 
already contain a column {it:file1} indentifying the origin of non-common metadata. 
So the resulting meta file of the current combination will include a column {it:file2}.


{title:Examples}

{pstd}
Combine metadata from files {it:meta_auto1.xlsx} and {it:meta_auto2.xlsx}. Save the combined metadata in {it:meta_comb.xlsx}

{p 8 16}{inp:. mdata combine, f1(meta_auto1) f2(meta_auto2) meta(meta_comb)}{p_end}


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

