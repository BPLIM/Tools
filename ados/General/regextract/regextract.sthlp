{smcl}
{* *! version 0.1 13Jun2023}{...}{smcl}
{.-}
help for {cmd:regextract} {right:}
{.-}

{title:Title}

{pstd}
{cmd:regextract} {hline 1} extracts capture groups from regex patterns



{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:regextract} {help varname:varname}
{cmd:} [, {it:options}]


{marker options}{...}
{title:Options}

{synoptset 20 tabbed}{...}
{marker table_options}{...}
{synopthdr}
{synoptline}
{syntab :Options}
{synopt :{opt reg:ex(pattern)}} is the regular expression pattern with capturing groups. This option is mandatory.
{p_end}
{synopt :{opt gen:erate(stub)}} specifies the name(s) of the variable(s) to be created. This option is mandatory. 
Please note that more than one variable may be created, corresponding to the capture groups specified.
{p_end}
{synopt :{opt replace}} replace all variables with prefix specified in option {opt generate}. This option 
should be used with caution, since it will remove every variable that contains prefix {it:stub}.
{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}

{pstd}
{cmd: regextract} is a Stata wrapper for 
{browse "https://pandas.pydata.org/docs/reference/api/pandas.Series.str.extract.html":pandas string extract method}. The command 
creates a new variable per capturing group in the regex pattern. Missing values are generated for non-matches. 
Capturing groups are delimited by parenthesis, even for one
capturing group. Regex follows Python's defined patterns. 


{title:Examples}

{pstd}
Example 1:
Extract lower characters (a to z) from {opt var} into variable {opt stub}.

{p 8 16}{inp:. regextract var, reg("([a-z]+)") gen(stub)}{p_end}

{pstd}
Example 2:
Extract lower characters (a to z) and digits from {opt var} into variables
 {opt stub1} and {opt stub2}.

{p 8 16}{inp:. regextract var, reg("([a-z]+)(\d+)") gen(stub)}{p_end}


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
This command will only work in Stata version 16 or higher, as it requires Python integration.

{pstd}
Packages in Pyton: {bf:pandas}


{title:Author}

{pstd}
BPLIM, Banco de Portugal, Portugal.

{pstd}
Email: {browse "mailto:bplim@bportugal.pt":bplim@bportugal.pt}

We appreciate your feedback. Comments are welcome!
