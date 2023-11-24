{smcl}
{* *! version 0.2 8Nov2023}{...}{smcl}
{.-}
help for {cmd:mdata apply} {right:}
{.-}

{title:Title}

{pstd}
{cmd:mdata apply} {hline 1} applies metadata to data in memory

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:mdata apply}
{cmd:} , [{it:options}]

{synoptset 30 tabbed}{...}
{marker table_options}{...}
{synopthdr}
{synoptline}
{syntab :Options}
{synopt :{opt meta:file}} is name of the Excel file where the metadata is stored.
 This option is mandatory.
{p_end}
{synopt :{opt do:file}} saves a do-file with all the code used to apply the metadata.
{p_end}
{synopt :{opt chars}} applies information about variables and data {help char:characteristics}. 
The default behavior is to not apply characteristics to variables and data.
{p_end}
{synopt :{opt notes}} applies information about variables and data {help notes:notes}. 
The default behavior is to not apply notes to variables and data.
{p_end}
{synopt :{opt trunc:ate}} truncates variables and value labels names if their length is larger than 25 and 27 characters, respectively.
{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}

{pstd}
{opt mdata apply} is a Stata command that applies metadata stored in an Excel file
to data in memory. The command assumes that the Excel file has the structure of the 
file produced by {help mdata_extract:mdata extract}. Moreover, the command will 
only apply the metadata after checking its integrity (see {help mdata_check:mdata check}). 

{pstd}
Please note that all previous metadata is removed once you run the command (see {help mdata_clear:mdata clear}). It is
also worth mentioning that some of the metadata might no be applied to your data. This 
includes metadata generated automatically by Stata and usually concerns characteristics
that start with "_". So we suggest that users do not define charcateristics that follow that pattern.

{title:Examples}

{pstd}
Apply metadata from file {it:meta_auto.xlsx} to data in memory.

{p 8 16}{inp:. mdata apply, meta(metafile)}{p_end}

{pstd}
Apply metadata from file {it:meta_auto.xlsx} to data in memory. Save the code 
used to apply the metadata in {it:apply.do}

{p 8 16}{inp:. mdata apply, meta(metafile) do(apply)}{p_end}

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

