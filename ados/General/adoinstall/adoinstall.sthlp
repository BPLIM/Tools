{smcl}
{* *! version 0.1 9Dec2021}{...}{smcl}
{.-}
help for {cmd:adoinstall} {right:}
{.-}

{title:Title}

{pstd}
{cmd:adoinstall} {hline 1} installs Stata packages in a specified path

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:adoinstall}
{cmd:} {it:pkgname}, [{it:options}]

{marker options}{...}
{title:Options}

{synoptset 20 tabbed}{...}
{marker table_options}{...}
{synopthdr}
{synoptline}
{syntab :Options}
{synopt :{opt to(path)}} the path where the package will be placed. 
This option is mandatory.{p_end}
{synopt :{opt all}} same as {opt all} in {help ssc install} 
and {help net install}.{p_end}
{synopt :{opt replace}} same as {opt replace} in  {help ssc install} 
and {help net install}.{p_end}
{synopt :{opt force}} same as {opt force} in {help net install}.{p_end}
{synopt :{opt from(url)}} same as {opt from} in {help net install}. 
If the user does not specify this option, then {help ssc install} 
is used.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}

{pstd}
{cmd: adoinstall} is a wrapper around {help ssc install} and {help net install} 
to allow installation of Stata packages in a specified path. 
The command should be used to install user-written commands to 
a path other than the default PLUS directory.


{title:Examples}

{pstd}
Example 1:
Install package {it:ftools} from SSC and place it in "c:/mydir/myados".

{p 8 16}{inp:. adoinstall ftools, to(c:/mydir/myados)}{p_end}

{pstd}
Example 2:
Install package {it:bpstat} from Github and place it in "c:/mydir/myados".

{p 8 16}{inp:. adoinstall bpsat, to(c:/mydir/myados) from("https://github.com/BPLIM/Tools/raw/master/ados/General/bpstat/")}{p_end}


{title:Remarks}

{pstd}
Please notice that this software is provided "as is", without warranty of any kind, whether
express, implied, or statutory, including, but not limited to, any warranty of merchantability
or fitness for a particular purpose or any warranty that the contents of the item will be error-free.
In no respect shall the author incur any liability for any damages, including, but limited to,
direct, indirect, special, or consequential damages arising out of, resulting from, or any way
connected to the use of the item, whether or not based upon warranty, contract, tort, or otherwise.


{title:Author}

{pstd}
BPLIM, Banco de Portugal, Portugal.

{pstd}
Email: {browse "mailto:bplim@bportugal.pt":bplim@bportugal.pt}

I appreciate your feedback. Comments are welcome!
