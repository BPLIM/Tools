{smcl}
{* *! version 0.1 12Mar2021}{...}{smcl}
{.-}
help for {cmd:bpencode} {right:}
{.-}

{title:Title}

{pstd}
{cmd:bpencode} {hline 1} Encode into numeric using a variable or an Excel
file

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:bpencode} {help varname:varname}
{cmd:} [, {it:options}]

{synoptset 30 tabbed}{...}
{marker table_options}{...}
{synopthdr}
{synoptline}
{syntab :Options}
{synopt :{opt vl(varname)}} is the variable used to label encoded values.
{p_end}
{synopt :{opt gen:erate(newvar)}} specifies the name of the variable to be created. Defaults to {it: _enc_varname}
{p_end}
{synopt :{opt vlname}} sets the name of the value label. Defaults to {opt vl}.
{p_end}
{synopt :{opt meta:file}} uses an Excel file to encode variables and label its values (see {help mdata_extract:mdata extract}). 
{p_end}
{synopt :{opt vlsheet}} is the worksheet that contains value labels. 
{p_end}
{synopt :{opt dropzeros}} removes trailing zeros from codes in labels. 
{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}

{pstd}
{opt bpencode} creates a new variable based on the variable {help varname:varname}. 
A variable may be used to create a value label for the new encoded variable. Users may
also specify an Excel file to create and label the new variable. Unlike {help encode:encode}, 
it's possible to use this command with a numeric variable in order to label its values.

{pstd}
If the variable is numeric, using this command will only serve to clone the variable. In
this case, the command is only useful to label variable's values using other variable from 
the data set or an excel file. 

{pstd}
For the string type, variables may contain only numbers, only letters or both. In the 
first case, the command does the same as running {help real:real}; In case the variable 
only contains letters, values will be sorted and a numeric code is generated for each 
level of the variable. When the variable contains values with numbers and letters (this 
includes variables featuring rows with just letters and rows with just numbers), the encoding is 
a mixture of the two previous cases: rows with digits only preserve their value, while rows 
that contain only letters or letters and numbers are encoded according to the second case. In order 
to guarantee that there are no overlapping values, the latter type rows are assigned values 
that are larger than the maximum value for only digits rows.

{pstd} 
The user may specify a variable from the data set in option {opt vl} that serves as 
a value label for the encoded variable. In doing so, the value label created will be
of the form {it:# desc}, where {it:#} is the value of the original variable and {it:desc} 
is the value of the variable used in option {opt vl}.

{pstd}
It's also possible to use an Excel file to encode and label a variable. To use this 
option, the Excel worksheet should contain two columns - {it:value} and {it:label}, and 
the labels should be of the form {it:# desc}.


{title:Examples}

{pstd}
Example 1: Label variable {it:x}, generating variable {it:xnew} and using variable {it:xlab} to
create value label {it:xvl}.

{p 8 16}{inp:. set obs 3}{p_end}
{p 8 16}{inp:. gen x = 1 in 1}{p_end}
{p 8 16}{inp:. replace x = 2 in 2}{p_end}
{p 8 16}{inp:. replace x = 3 in 3}{p_end}
{p 8 16}{inp:. gen xlab = "one" in 1}{p_end}
{p 8 16}{inp:. replace xlab = "two" in 2}{p_end}
{p 8 16}{inp:. replace xlab = "three" in 3}{p_end}
{p 8 16}{inp:. bpencode x, gen(xnew) vl(xlab) vlname(xvl)}{p_end}


{pstd}
Example 2: Encode string variable {it:x}, generating variable {it:xnew} and using variable {it:xlab} to
create value label {it:xvl}.

{p 8 16}{inp:. set obs 3}{p_end}
{p 8 16}{inp:. gen x = "01" in 1}{p_end}
{p 8 16}{inp:. replace x = "02" in 2}{p_end}
{p 8 16}{inp:. replace x = "0X" in 3}{p_end}
{p 8 16}{inp:. gen xlab = "one" in 1}{p_end}
{p 8 16}{inp:. replace xlab = "two" in 2}{p_end}
{p 8 16}{inp:. replace xlab = "xvalue" in 3}{p_end}
{p 8 16}{inp:. bpencode x, gen(xnew) vl(xlab) vlname(xvl)}{p_end}

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

