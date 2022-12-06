{smcl}
{* *! version 0.1 2Aug2021}{...}{smcl}
{.-}
help for {cmd:adoversion} {right:}
{.-}

{title:Title}

{pstd}
{cmd:adoversion} {hline 1} reports the version of every ado found in the paths returned by {help adopath:adopath}

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:adoversion}
, [{it:options}]


{marker options}{...}
{title:Options}

{synoptset 20 tabbed}{...}
{marker table_options}{...}
{synopthdr}
{synoptline}
{syntab :Options}
{synopt :{opt out:path(string)}} path for text files 
{p_end}
{synopt :{opt inc:lude}({it:numlist})} search only paths linked to the numbers found in {it:numlist} and returned by {help adopath:adopath}. Default is to search all paths. 
{p_end}
{synopt :{opt exc:lude}({it:numlist})} exclude paths linked to the numbers found in {it:numlist} and returned by {help adopath:adopath}. Default is to exclude none. 
{p_end}


{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}

{pstd}
{cmd: adoversion} is a Stata command that generates a report about ado files currently available to the user and their version. 
The command searches for ados in the paths returned by {help adopath:adopath}, in the order that they appear. 
This order is important if the user whishes to specify options {opt include} or {opt exclude}.

{pstd}
The command creates a text file per path, which contains the name of the ado files and the corresponding version. 
To report the version of each ado, the command inspects the first ten lines of the file. 
Following Stata convention, only lines that start with "*!" are parsed. 
Moreover, the command assumes {bf:[0-9][0-9]?\.[0-9]+(\.[0-9]+)?} as the pattern for the version of ado files. 


{title:Examples}

{pstd}
Example 1:
Report the version of ados found in every path of the adopath.

{p 8 16}{inp:. adoversion}{p_end}

{pstd}
Example 2:
Report the version of ados found in the first and second paths of the adopath.

{p 8 16}{inp:. adoversion, inc(1 2)}{p_end}

{pstd}
Example 1:
Report the version of ados found in every path except the first of the adopath.

{p 8 16}{inp:. adoversion, exc(1)}{p_end}

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
{cmd:filelist} by Robert Picard {p_end}

{title:Author}

{pstd}
BPLIM, Banco de Portugal, Portugal.

{pstd}
Email: {browse "mailto:bplim@bportugal.pt":bplim@bportugal.pt}

We appreciate your feedback. Comments are welcome!