{smcl}
{* *! version 0.2 23Feb2023}{...}{smcl}
{.-}
help for {cmd:standardizetext} {right:}
{.-}

{title:Title}

{pstd}
{cmd:standardizetext} {hline 1} normalize Unicode string variables


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:standardizetext} {help varname:varname}
{cmd:} [, {it:options}]


{marker options}{...}
{title:Options}

{synoptset 20 tabbed}{...}
{marker table_options}{...}
{synopthdr}
{synoptline}
{syntab :Options}
{synopt :{opt gen:erate(newvar)}} specifies the name of the variable to be created. This option is mandatory.
{p_end}
{synopt :{opt enc:oding}(str)} is the encoding of {help varname:varname}. Defaults to "utf-8".
{p_end}
{synopt :{opt spec:ialchars}} removes special characters like "\t", "#", and "$". 
{p_end}
{synopt :{opt up:pper}} same as {help strupper(): strupper}. 
{p_end}
{synopt :{opt lo:wer}} same as {help strlower(): strlower}. 
{p_end}
{synopt :{opt stop:words}(str)} eliminates stop words provided by the user. 
This argument should be enclosed in double quotes and the words to eliminate 
must be separated by whitespace. 
{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}

{pstd}
{cmd: standardizetext} is a Stata command that generates a new 
variable with only ascii characters. It also removes 
special characters using option {opt specialchars} and stop words 
specified by the user.


{title:Examples}

{pstd}
Example 1:
Replace non-ascii characters by ascii characters in variable {opt var}.

{p 8 16}{inp:. standardizetext var, gen(ascii_var)}{p_end}

{pstd}
Example 2:
Replace non-ascii characters by ascii characters in variable {opt var}. 
Remove special characters.

{p 8 16}{inp:. standardizetext var, gen(ascii_var) spec}{p_end}


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

{title:Author}

{pstd}
BPLIM, Banco de Portugal, Portugal.

{pstd}
Email: {browse "mailto:bplim@bportugal.pt":bplim@bportugal.pt}

We appreciate your feedback. Comments are welcome!