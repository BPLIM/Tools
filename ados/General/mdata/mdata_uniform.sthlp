{smcl}
{* *! version 0.1 16Apr2024}{...}{smcl}
{.-}
help for {cmd:mdata uniform} {right:}
{.-}

{title:Title}

{pstd}
{cmd:mdata uniform} {hline 1} harmonizes information in metadata files

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:mdata uniform}
{cmd:} , {opt meta:file(fn)} [{it:options}]

{synoptset 30 tabbed}{...}
{marker table_options}{...}
{synopthdr}
{synoptline}
{syntab :Options}
{p2coldent :* {opt meta:file(fn)}} is the name of the Excel file where 
the metadata is stored.
{p_end}
{synopt :{opt sh:eets(worksheets)}} specify the worksheets that should be 
harmonized. The default is all.
{p_end}
{synopt :{opt new:file(fn)}} saves the harmonized metadata in the Excel file {it:fn.xlsx}.
Defaults to {opt <option metafile>}{it:_new}{opt .xlsx}.
{p_end}
{synopt :{opt replace}} replaces the harmonized meta file if it exists.
{p_end}
{synoptline}
{p 4 6 2}
* required{p_end}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}

{pstd}
{opt mdata uniform} is a Stata command that harmonizes metadata stored in an Excel file. 
The command assumes that the Excel file has the structure of the file produced by 
{help mdata_extract:mdata extract}.

{pstd}
The programs acts only on value labels, meaning that it only harmonizes sheets that 
start with {it:vl_}. The command is particularly useful for metadata files generated 
by {help mdata_combine:mdata combine}, recoding values that have the same code 
in value labels according to their label.


{title:Examples}

{pstd}
Harmonize all value label sheets in metadata file {it:meta.xlsx}. Save the new 
metadata in {it:meta_new.xlsx}

{p 8 16}{inp:. mdata uniform, meta(meta)}{p_end}

{pstd}
Harmonize value label sheets {it:vl_lab1} and {it:vl_lab2} in metadata file 
{it:meta.xlsx}. Save the new metadata in {it:unif.xlsx}

{p 8 16}{inp:. mdata uniform, meta(meta) sh(vl_lab1 vl_lab2) new(unif)}{p_end}

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
{cmd:bpencode} package by BPLIM{p_end}

{title:Author}

{pstd}
BPLIM, Banco de Portugal, Portugal.

{pstd}
Email: {browse "mailto:bplim@bportugal.pt":bplim@bportugal.pt}

We appreciate your feedback. Comments are welcome!

