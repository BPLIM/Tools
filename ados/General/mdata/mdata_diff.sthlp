{smcl}
{* *! version 0.1 21Feb2024}{...}{smcl}
{.-}
help for {cmd:mdata diff} {right:}
{.-}

{title:Title}

{pstd}
{cmd:mdata diff} {hline 1} flags differences in metadata files

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:mdata diff}
{cmd:} [, {it:options}]

{synoptset 30 tabbed}{...}
{marker table_options}{...}
{synopthdr}
{synoptline}
{syntab :Options}
{synopt :{opt P:ath(dir)}} is the directory with the metafiles. 
Defaults to the current working directory.
{p_end}
{synopt :{opt pattern(pat)}} sets the pattern of file names in {opt path} 
that are included in the analysis. The pattern is based on {help strmatch:strmatch} and 
defaults to {it:*.xlsx}. The user should not provide the extension of the file
because only {it:*.xlsx} files are allowed.
{p_end}
{synopt :{opt save(filename)}} sets the name of the Excel file where the analysis is saved. The user should not provide the file extension. Defaults to {it:metadiff.xlsx}.
{p_end}
{synopt :{opt replace}} overwrites existing Excel file.
{p_end}
{synopt :{opt base:file(filename)}} sets {it:filename} as the base for comparison 
between meta files. Defauts to the first in the list of sorted files' names. 
{p_end}
{synopt :{opt diff:only}} does not display rows where values are equal across 
metafiles.
{p_end}
{synopt :{opt verbose}} displays information about the progress of the analysis.
{p_end}
{synopt :{opt chars}} Include analysis for variables' characteristics. Default 
is to not include. 
{p_end}
{synopt :{opt notes}} Include analysis for variables' notes. Default 
is to not include. 
{p_end}
{synopt :{opt rec:ursive}} recursively searchs directories for files that match 
the pattern to include in the analysis.
{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}

{pstd}
{opt mdata diff} is a Stata command that performs a consistency 
check between metadata saved in multiple Excel files. 
The command assumes that the Excel files have the 
structure of the file produced by 
{help mdata_extract:mdata extract}. 
The command flags differences in metadata under 
the assumption that information should be consistent 
across metadata files. Consistent here 
means that metadata in every file should be equal to 
that which appears in the {opt basefile}. The metadata for all the 
remaining files is compared to the one in {opt basefile} and flagged if 
it is different.

{pstd}
The command saves the consistency analysis in an Excel file, with worksheets for: 


{space 8}{hline 1}{space 1} data characteristics (the values and not the differences)
{space 8}{hline 1}{space 1} variables (if they appear in metadata files or not)
{space 8}{hline 1}{space 1} variables' labels, type, format, etc. (if they are different from the base file)
{space 8}{hline 1}{space 1} value labels (checks if every value and label defined are present in metadata files)

{pstd}
The Excel file includes a worksheet with the files' indexes - {it:base} for the first file 
(which may be changed using option {opt basefile}) and f1, f2, f3, etc. for the remaining files. This 
index is used in the other worksheets. A worksheet with the count of differences for every worksheet 
is also displayed.


{title:Examples}

{pstd}
Analyse the differences between metafiles in the directory {it:metadir}. Save the analysis to {it:metadiff.xlsx}

{p 8 16}{inp:. mdata diff, path(metadir)}{p_end}

{pstd}
Analyse the differences between metafiles in the directory {it:metadir}. Save the analysis to {it:metadiff.xlsx}. Change the base file to be {it:meta02.xlsx}

{p 8 16}{inp:. mdata diff, path(metadir) basefile(meta02.xlsx)}{p_end}

{pstd}
Analyse the differences between metafiles in the directory {it:metadir}. Save the analysis to {it:metadiff.xlsx}, replacing the file if it already exists and showing 
only values that are different across metafiles. 

{p 8 16}{inp:. mdata diff, path(metadir) save(metadiff, replace) diffonly}{p_end}

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
{cmd:filelist} command by Robert Picard{p_end}


{title:Author}

{pstd}
BPLIM, Banco de Portugal, Portugal.

{pstd}
Email: {browse "mailto:bplim@bportugal.pt":bplim@bportugal.pt}

We appreciate your feedback. Comments are welcome!
