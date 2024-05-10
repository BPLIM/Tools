{smcl}
{* *! version 0.2 1Jun2023}{...}
{title:Title}

{p2colset 5 18 23 2}{...}
{p2col :{cmd:metaxl} {hline 2}}Manage metadata.{p_end}
{p2colreset}{...}

{pstd}
{opt metaxl} is a suite of tools to help users handling metadata. The following
tools are available (each tool is a subcommand of {opt metaxl}):

{p 8 17 2}
{help metaxl_extract:extract} extracts metadata from data in memory. {p_end}

{p 8 17 2}
{help metaxl_apply:apply} applies metadata to data in memory. {p_end}

{p 8 17 2}
{help metaxl_check:check} checks for inconsistencies in metadata. {p_end}

{p 8 17 2}
{help metaxl_cmp:cmp} compares metadata files. {p_end}

{p 8 17 2}
{help metaxl_combine:combine} combines metadata files. {p_end}

{p 8 17 2}
{help metaxl_morph:morph} transforms metadata files to eliminate redundant information. {p_end}

{p 8 17 2}
{help metaxl_uniform:uniform} harmonizes information in metadata files. {p_end}

{p 8 17 2}
{help metaxl_diff:diff} flags differences in metadata files. {p_end}

{p 8 17 2}
{help metaxl_stats:stats} extracts statistics and metadata from data in memory. {p_end}

{p 8 17 2}
{opt clear} removes all metadata from data in memory. {p_end}


{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:metaxl}
{cmd:} {it:subcommand} [, {it:options}]


{marker description}{...}
{title:Description}

{pstd}
{opt metaxl} is a Stata package that provides a set of tools to help users handling 
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
{pstd}
{cmd:filelist} package by Robert Picard{p_end}


{title:Author}

{pstd}
BPLIM, Banco de Portugal, Portugal.

{pstd}
Email: {browse "mailto:bplim@bportugal.pt":bplim@bportugal.pt}

We appreciate your feedback. Comments are welcome!
