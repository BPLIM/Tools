
{smcl}
{.-}
help for {cmd:coconuts} {right:()}
{.-}

{title:Title}

coconuts - creates Nomenclature of Territorial Units for Statistics (NUTS) variables for Portuguese municipalities.

{title:Syntax}

{p 8 15}
{cmd:coconuts} {it:municipality} [{help if}], [{it:options}]

{p}

{title:Description}

{p}
According to {browse "http://smi.ine.pt/Conceito/Detalhes/3879":INE (Statistics Portugal)}, the Nomenclature of Territorial Units for Statistics (NUTS) subdivides the economic
territory for statistical purposes. 
This command allows users to allocate Portuguese municipalities to the aforementioned regions, creating a variable for each level. Variables are named as 
nuts#_vxxxx, where # is the regions's level and xxxx is a four digit number (year) identifying the revison. 
There have been several revisions to this classification and the command takes that fact into account. 
Each revision is best suited for a specific time period:


- nuts1986:  05may1986  -  14feb1989 
- nuts1989:  15feb1989  -  14sep1998
- nuts1998:  15sep1998  -  10aug1999
- nuts1999:  11aug1999  -  11jul2001
- nuts2001:  12jul2001  -  04nov2002
- nuts2002:  05nov2002  -  31dec2014
- nuts2013:  01jan2015  -          .



{title:Options}


{p 0 4}{opt versions} displays each revision and the corresponding period. The user does not need to specify a variable when using this option.

{p 0 4}{opt nuts(number)} is the NUTS revision used for allocating municipalities. As seen above, {it:number} is the year of the revision. The following revisions are available:  1986, 1989, 1998, 1999, 2001, 2002, and 2013. The default is 2013.

{p 0 4}{opt levels(numlist)} specifies which regions should be created: 1, 2, and/or 3. The default is 1, 2 and 3.

{p 0 4}{opt keep} creates variable {it:_match_xxxx} that signals if a match was found for {it: municipality}, where xxxx is the four digit number
identifying the revison.

{p 0 4}{opt recode} should be used with some BPLIM data sets (CB, CBHP) because codes of the municipalities in Azores and Madeira differ from Code of the administrative division {browse "http://smi.ine.pt/Conceito/Detalhes/3879":(INE)},
which this program uses by default.

{p 0 4}{opt replace} drops all variables named nuts#_vyyyy, where # is the regions's level and yyyy is the revision specified by the user in 
option {opt nuts}.

{p 0 4}{opt generate(new_var)} creates variable {it: new_var} with recoded values of {it: municipality} as long as the user specifies option {opt recode}.

{p 0 4}{opt tostring} creates a string version of the NUTS variables. This option only applies to level 3 of NUTS2002 and NUTS2013 because not all of the codes 
for these classifications and that level have a numerical representation. Therefore, the user may use this option to get the string version of those codes.
Variables are named as nuts#_vyyyy_str, where # = 3 and yyyy = 2002 or 2013.

{p 0 4}{opt nonuts} skips the allocation of municipalities to NUTS regions when the user specifies options {opt recode} and {opt generate}. This option is 
useful if the user only wishes to recode values of {it: municipality} according to Code of the administrative division.


{title:Examples}

Example 1:
Create variables nuts1_v2013, nuts2_v2013 and nuts3_v2013 using variable concelho.

{p 8 16}{inp:. coconuts concelho}{p_end}


Example 2:
Create variable nuts3_v2002 using variable concelho.

{p 8 16}{inp:. coconuts concelho, nuts(2002) levels(3)}{p_end}


Example 3:
Create variable concelho_new with recoded values for concelho and skip conversion of concelho to NUTS.

{p 8 16}{inp:. coconuts concelho, recode gen(concelho_new) nonuts}{p_end}


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

I appreciate your feedback. Comments are welcome!
