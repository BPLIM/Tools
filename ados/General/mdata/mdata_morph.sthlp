{smcl}
{* *! version 0.1 2Mar2021}{...}{smcl}
{.-}
help for {cmd:mdata morph} {right:}
{.-}

{title:Title}

{pstd}
{cmd:mdata morph} {hline 1} transforms a metadata file to eliminate redundant information

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:mdata morph}
{cmd:} ({it:vl_lab1 = vl_lab2 vl_lab3 ...}) [({it:vl_lab7 = vl_lab5 vl_lab6 ...}) ...], [{it:options}]

{synoptset 30 tabbed}{...}
{marker table_options}{...}
{synopthdr}
{synoptline}
{syntab :Options}
{synopt :{opt meta:file(fn)}} is name of the Excel file where the metadata is stored.
 This option is mandatory.
{p_end}
{synopt :{opt save(fn [, replace])}} saves the transformed metadata in the Excel file {it:fn.xlsx}.
Defaults to {opt <option metafile>}{it:_new}{opt .xlsx}.
{p_end}
{synopt :{opt keep}} keeps old sheets that were morphed into new sheets.
{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}

{pstd}
{opt mdata morph} is a Stata command that transforms a metadata file by removing 
redundant information. The command assumes that the Excel file has the structure of 
the file produced by {help mdata_extract:mdata extract}.

{pstd}
The programs acts only on value labels, merging sheets specified by the user into a new
sheet. This could be important if the metadata file contains different value label sheets 
with potentially redundant information. Think about two value labels, {it: educ_emp} and 
{it: educ_man}, which stand for employee and manager's level of education, respectively.
If the two value labels concern the general education level, one could eliminate these two 
value label sheets and create a new one - {it: educ} for example - that applies to both
situations. 

{pstd}
It is worth noting that once we generate a new value label sheet that is the result 
of merging other sheets, the sheet {it: variables} (see {help mdata_extract:mdata extract}) 
also changes, so as to reflect the changes made to the value label that applies to one 
or more variables.


{title:Examples}

{pstd}
Morph sheets {it:vl_lab1} and {it:vl_lab2} from file {it:meta.xlsx} into sheet 
{it:vl_lab3}. Save the new metadata in {it:morph.xlsx}

{p 8 16}{inp:. mdata morph (vl_lab1 = vl_lab2 vl_lab3), meta(meta) save(morph)}{p_end}

{pstd}
Morph sheets {it:vl_lab1} and {it:vl_lab2} and {it:vl_lab4} and {it:vl_lab5} from 
file {it:meta.xlsx} into sheets {it:vl_lab3} and {it:vl_lab6}. Save the new meta 
data in {it:meta_new.xlsx}

{p 8 16}{inp:. mdata morph (vl_lab3 = vl_lab1 vl_lab2) (vl_lab6 = vl_lab4 vl_lab5), meta(meta)}{p_end}

{pstd}
{opt Warning}: please note that in these examples {it:vl_lab#} stands for the name of
Excel sheet where the value label data is stored and {it:lab#} is the name of the value 
label. Users must always use this syntax, since it is assumed that the metadata file follows
the structure of the file exported by {help mdata_extract:mdata extract}. Also, users 
should not use one of the old worksheet's name for the new sheet.

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

