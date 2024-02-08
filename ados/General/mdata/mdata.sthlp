{smcl}
{* *! version 0.1 26Feb2021}{...}
{title:Title}

{p2colset 5 18 23 2}{...}
{p2col :{cmd:mdata} {hline 2}}Manage metadata.{p_end}
{p2colreset}{...}

{pstd}
{opt mdata} is a suite of tools to help users handling metadata. The following
tools are available (each tool is a subcommand of {opt mdata}):

{p 8 17 2}
{help mdata_extract:extract} extracts metadata from data in memory. {p_end}

{p 8 17 2}
{help mdata_apply:apply} applies metadata to data in memory. {p_end}

{p 8 17 2}
{help mdata_check:check} checks for inconsistencies in metadata. {p_end}

{p 8 17 2}
{help mdata_cmp:cmp} compares metadata files. {p_end}

{p 8 17 2}
{help mdata_combine:combine} combines metadata files. {p_end}

{p 8 17 2}
{help mdata_morph:morph} transforms metadata files to eliminate redundant information. {p_end}

{p 8 17 2}
{help mdata_uniform:uniform} harmonizes information in metadata files. {p_end}

{p 8 17 2}
{opt clear} removes all metadata from data in memory. {p_end}


{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:mdata}
{cmd:} {it:subcommand} [, {it:options}]


{marker description}{...}
{title:Description}

{pstd}
{opt mdata} is a Stata package that provides a set of tools to help users handling 
metadata. Almost every subcommand of this package uses an Excel file to store or 
retrieve metadata.

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
{pstd}
{cmd:bpencode} package by BPLIM{p_end}


{title:Author}

{pstd}
BPLIM, Banco de Portugal, Portugal.

{pstd}
Email: {browse "mailto:bplim@bportugal.pt":bplim@bportugal.pt}

We appreciate your feedback. Comments are welcome!
