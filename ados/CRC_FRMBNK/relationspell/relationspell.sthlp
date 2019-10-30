
{smcl}
{.-}
help for {cmd:relationspell} {right:()}
{.-}
 
{title:Title}

relationspell - Computes relationship spells.

{title:Syntax}

{p 8 15}
{cmd:relationspell} {it:panelvar1} {it:panelvar2} {it:timevar}, [{it:options}]

{p}

{title:Description}

{p} 
This command constructs relationship spells for two panel variables. A time variable should also be specified. 

{p} 

The command returns the following variables:

_relation denotes a relationship;
_spell denotes the relationship spell order;
_mindate_spell denotes the start of a relationship spell;
_maxdate_spell denotes the end of a relationship spell;
_len_spell denotes the length of a relationship spell;
_mindate denotes the start of a bank-firm relationship;
_maxdate denotes the end of a bank-firm relationship;
_len_all denotes the length of relationship;
_len_act denotes the length of active relationship;
_len_inact denotes the length of inactive relationship;
_relation_valid denotes the status of a relationship spell with the following values: 0 - Discontinued; 1 - Valid.

 
{title:Options}

General Options

{p 0 4}{cmd: STARTYR} start year, 1980 by default. 

{p 0 4}{cmd: FINYEAR} end year, 2015 by default.

{p 0 4}{cmd: FREQUENCY} data frequency with the options of daily, monthly and annual (1, 2, and 3, respectively). The default option is monthly (denoted by 2).

{p 0 4}{cmd: GAPS} max gaps allowed in a relationship, 0 by default.

{title:Examples}

Example 1:

Constructs bank-firm relationship spells from 1985 to 2015 for a month dataset.

{p 8 16}{inp:. relationspell bank firm date}{p_end}

Example 2:

Constructs bank-firm relationship spells from 1985 to 1990 for a daily dataset.

{p 8 16}{inp:. relationspell bank firm date, startyr(1985) finyear(1990) frequency(1)}{p_end}


{title:Dependencies}

The command requires installation of package {cmd:tsspell} by Nicholas J. Cox. The module can be installed 
from within Stata by typing "ssc install tsspell". 


{title:Remarks}

Please notice that this software is provided "as is", without warranty of any kind, whether
express, implied, or statutory, including, but not limited to, any warranty of merchantability
or fitness for a particular purpose or any warranty that the contents of the item will be error-free.
In no respect shall the author incur any liability for any damages, including, but limited to, 
direct, indirect, special, or consequential damages arising out of, resulting from, or any way 
connected to the use of the item, whether or not based upon warranty, contract, tort, or otherwise. 

{title:Author}

{p}
BPLIM team, Banco de Portugal, Portugal.

{p}
Email: {browse "mailto:bplim@bportugal.pt":bplim@bportugal.pt}

I appreciate your feedback. Comments are welcome!

