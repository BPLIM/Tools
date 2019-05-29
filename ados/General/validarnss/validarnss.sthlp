
{smcl}
{.-}
help for {cmd:validarnss} {right:()}
{.-}
 
{title:Title}

validarnss - validates the social security number(nss)

{title:Syntax}

{p 8 15}
{cmd:validarnss} {it:var}

{p}

{title:Description}

{p} 
This command validates the social security number, returning a variable _valid with the following values:

- 0 for valid observations;
- 1, 2 and 3 for invalid observations that are subdivided in three categories:
	- first digit invalid (1)
	- length is not 11 (2)
	- check digit invalid (3)


{title:Examples}

{p 8 16}{inp:. validarnss nssn}{p_end}


{title:Remarks}

Please notice that this software is provided "as is", without warranty of any kind, whether
express, implied, or statutory, including, but not limited to, any warranty of merchantability
or fitness for a particular purpose or any warranty that the contents of the item will be error-free.
In no respect shall the author incur any liability for any damages, including, but limited to, 
direct, indirect, special, or consequential damages arising out of, resulting from, or any way 
connected to the use of the item, whether or not based upon warranty, contract, tort, or otherwise. 


{title:Author}

{p}
Paulo Guimarães, BPlim, Banco de Portugal, Portugal.

{p}
Email: {browse "mailto:pguimaraes2001@gmail.com":pguimaraes2001@gmail.com}

I appreciate your feedback. Comments are welcome!

