{smcl}
{* *! version 0.5 5Nov2021}{...}{smcl}
{.-}
help for {cmd:coconuts} {right:()}
{.-}

{title:Title}

{p 8 15}
{cmd:coconuts} {hline 1} creates Nomenclature of Territorial Units for Statistics (NUTS) variables for Portuguese municipalities.

{title:Syntax}

{p 8 15}
{cmd:coconuts}  [{help if}], [{it:options}]

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:coconuts}
{cmd:} [{help varname:varname}] [{help if}], [{it:options}]

where {it:varname} is either a string or numeric variable containing municipalities' codes


{marker options}{...}
{title:Options}

{synoptset 20 tabbed}{...}
{marker table_options}{...}
{synopthdr}
{synoptline}
{syntab :Options}

{synopt :{opt versions}} displays each revision and the corresponding period. The user 
does not need to specify a variable when using this option.{p_end}

{synopt :{opt nuts(number)}} is the NUTS revision used for allocating municipalities. As 
seen above, {it:number} is the year of the revision. The following revisions are 
available:  1986, 1989, 1998, 1999, 2001, 2002, and 2013. The default is 2013.{p_end}

{synopt :{opt levels(numlist)}} specifies which regions should be created: 1, 2, 
and/or 3. The default is 1, 2 and 3.{p_end}

{synopt :{opt keep}} creates variable {it:_match_xxxx} that signals if a match was 
found for {it: municipality}, where xxxx is the four digit number identifying the revison.{p_end}

{synopt :{opt rec:ode}} should be used with some BPLIM data sets (CB, CBHP) because 
codes of the municipalities in Azores and Madeira differ from Code of the administrative 
division {browse "http://smi.ine.pt/Conceito/Detalhes/3879":(INE)}, which this program 
uses by default.{p_end}

{synopt :{opt replace}} drops all variables named nuts#_vyyyy, where # is the 
regions's level and yyyy is the revision specified by the user in option {opt nuts}.{p_end}

{synopt :{opt gen:erate(new_var)}} creates variable {it: new_var} with recoded 
values of {it: municipality} as long as the user specifies option {opt recode}.{p_end}

{synopt :{opt tostring}} creates a string version of the NUTS variables. 
This option only applies to level 3 of NUTS2002 and NUTS2013 because not all of the 
codes for these classifications and that level have a numerical representation. 
Therefore, the user may use this option to get the string version of those codes. 
Variables are named as nuts#_vyyyy_str, where # = 3 and yyyy = 2002 or 2013.{p_end}

{synopt :{opt no:nuts}} skips the allocation of municipalities to NUTS regions when the 
user specifies options {opt recode} and {opt generate}. This option is useful 
if the user only wishes to recode values of {it: municipality} according to 
Code of the administrative division.{p_end}

{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}

{pstd}
According to {browse "http://smi.ine.pt/Conceito/Detalhes/3879":INE (Statistics Portugal)}, the Nomenclature of Territorial Units for Statistics (NUTS) subdivides the economic
territory for statistical purposes. 
This command allows users to allocate Portuguese municipalities to the aforementioned regions, creating a variable for each level. Variables are named as 
nuts#_vxxxx, where # is the regions's level and xxxx is a four digit number (year) identifying the revison. 
There have been several revisions to this classification and the command takes that fact into account. 
Each revision is best suited for a specific time period:

{pstd}
{space 4}nuts1986:  05may1986  -  14feb1989:{p_end}
{pstd}
{space 4}nuts1989:  15feb1989  -  14sep1998;{p_end}
{pstd}
{space 4}nuts1998:  15sep1998  -  10aug1999;{p_end}
{pstd}
{space 4}nuts1999:  11aug1999  -  11jul2001;{p_end}
{pstd}
{space 4}nuts2001:  12jul2001  -  04nov2002;{p_end}
{pstd}
{space 4}nuts2002:  05nov2002  -  31dec2014;{p_end}
{pstd}
{space 4}nuts2013:  01jan2015  - {space 9}.{p_end}


{title:Examples}

{pstd}
Example 1:
Create variables nuts1_v2013, nuts2_v2013 and nuts3_v2013 using variable concelho.

{p 8 16}{inp:. coconuts concelho}{p_end}

{pstd}
Example 2:
Create variable nuts3_v2002 using variable concelho.

{p 8 16}{inp:. coconuts concelho, nuts(2002) levels(3)}{p_end}

{pstd}
Example 3:
Create variable concelho_new with recoded values for concelho and skip conversion of concelho to NUTS.

{p 8 16}{inp:. coconuts concelho, recode gen(concelho_new) nonuts}{p_end}


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

We appreciate your feedback. Comments are welcome!
