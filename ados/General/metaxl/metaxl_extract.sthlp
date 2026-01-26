{smcl}
{* *! version 0.2 8Nov2023}{...}{smcl}
{.-}
help for {cmd:metaxl extract} {right:}
{.-}

{title:Title}

{pstd}
{cmd:metaxl extract} {hline 1} extracts metadata from data in memory

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:metaxl extract}
{cmd:} [, {it:options}]

{synoptset 30 tabbed}{...}
{marker table_options}{...}
{synopthdr}
{synoptline}
{syntab :Options}
{synopt :{opt meta:file(fn)}} sets the name of the Excel file where the metadata is saved. The 
user should not provide the file extension. Defaults to {it:metafile.xlsx}.
{p_end}
{synopt :{opt chars}} extracts information about variables and data {help char:characteristics}. 
The default behavior is to not extract variables and data characteristics.
{p_end}
{synopt :{opt notes}} extracts information about data {help notes:notes}. 
The default behavior is to not extract variables and data notes.
{p_end}
{synopt :{opt trunc:ate}} truncates variables and value labels names if their length is 
larger than 25 characters. This may become a problem because 
the name of worksheets in Excel cannot exceed 30 characters.
{p_end}
{synopt :{opt replace}} replaces the meta file if it exists.
{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}

{pstd}
{opt metaxl extract} is a Stata command that exports metadata from data in memory
to an Excel file. This file is organized in sheets. 

{pstd}
The three first sheets are always exported, independently of the data set in memory.
The sheet {opt data_features_gen} contains general information about the 
data set, namely file name, data label, variables used to sort the data, label 
languages defined, notes and characteristics. The second sheet, {opt data_features_spec}, 
displays information on number of observations, number of variables, data set size, 
data signature and date of last change. A third sheet named {opt variables} presents 
a table with information for each variable, namely variable name, label (for every
defined language), value labels (if they exist), type, format, notes and characteristics.

{pstd}
If the data set has characteristics, notes or value labels defined, then there will 
be an additional sheet for each of them. There is one sheet per value label, note and 
characteristic. For value labels, the name of the sheet is {opt vl}_{it:name}, where {it:name}
is the name of the value label. For notes and characteristics, the name of the sheet is
{opt char/note}_{it:var}, where {it:var} is the name of the variable to which the note or 
characteristic applies.

{title:Examples}

{pstd}
Extract metadata from the {it:auto} data set and save it in {it:meta_auto.xlsx}.

{p 8 16}{inp:. metaxl extract, meta(meta_auto)}{p_end}

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

