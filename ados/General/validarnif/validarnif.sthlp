
{smcl}
{.-}
help for {cmd:validarnif} {right:()}
{.-}
 
{title:Title}

validarnif - validates the tax identification number (nipc/nif)

{title:Syntax}

{p 8 15}
{cmd:validarnif} {it:var} , [{it:options}]

{p}

{title:Description}

{p} 
This command validates the tax identification number of firms operating in Portugal, returning a variable {it:_valid} with the following values:

0 - for valid observations;
1 - first digit invalid
2 - less than 9 digits
3 - check digit invalid
4 - missing {it:var}
5 - non-numeric type

Note: non-numeric type only applies when the variable is a string.

{title:Options}

{p 0 4}{opt force} creates a numeric variable {it:var_n} when the argument type is string.

{title:Examples}

{p 8 16}{inp:. validarnif nipc}{p_end}

{title:Remarks}

Please notice that this software is provided "as is", without warranty of any kind, whether
express, implied, or statutory, including, but not limited to, any warranty of merchantability
or fitness for a particular purpose or any warranty that the contents of the item will be error-free.
In no respect shall the author incur any liability for any damages, including, but limited to, 
direct, indirect, special, or consequential damages arising out of, resulting from, or any way 
connected to the use of the item, whether or not based upon warranty, contract, tort, or otherwise. 


{title:Author}

{p}
BPLIM, Banco de Portugal, Portugal.

{p}
Email: {browse "mailto:bplim@bportugal.pt":bplim@bportugal.pt}

We appreciate your feedback. Comments are welcome!

