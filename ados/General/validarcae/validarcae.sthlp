{smcl}
{.-}
help for {cmd:validarcae} {right:()}
{.-}

{title:Title}

validarcae - validates the Portuguese Classification of Economic Activities (CAE) codes


{title:Syntax}

{p 8 15}
{cmd:validarcae} {it:var} [{help if}], [{it:options}]

{p}

{title:Description}

{p}
This command validates the Portuguese Classification of Economic Activities (CAE) codes. There have been several revisions of the Portuguese Economic Activities Classification, 
for which the command takes into account:

-  CAE Revision 1   : 1973 - 1993
-  CAE Revision 2   : 1994 - 2002
-  CAE Revision 21  : 2003 - 2007
-  CAE Revision 3   : 2008 - ...

Note: the time interval represents the official dates in which a revision came into force, but BPLIM data might not follow the same timeline.

The command produces a table, which contains the share of observations for valid and invalid codes by CAE Revision # as specified by the user, where # equals 1, 2, 21, 3.
Please note that codes might be valid for more than one Revision. Therefore, the sum of valid codes by Revision may be greater than the number of global valid codes.
The command also presents tabulations which show the validity of the economic activity codes according to CAE Revision # and can take on the following values:

- 0 for invalid codes;
- 1 for valid codes at 2 digits;
- 2 for valid codes at 3 digits;
- 3 for valid codes at 4 digits;
- 4 for valid codes at 5 digits;
- 5 for valid codes at 6 digits (this level only applies to Revision 1).


{title:Options}

{p 0 4}{opt rev()} allows the user to specify which CAE Revision should be used. The user may specify up to four revisions: 1, 2 21 and 3. If not specified, the default Revision is 3.

{p 0 4}{opt excel()} xlsx file with all possible CAE codes for each Revision.

{p 0 4}{opt tvar(var)} creates frequency table by var.

{p 0 4}{opt freq} produces relative frequencies in the table with valid and invalid CAE codes. The frequencies are calculated relative to all observations (Obs) or all observations by timevar in case the timevar is specified.

{p 0 4}{opt keep} creates variables _valid_cae and _valid_cae#, where # equals CAE Revision 1, 2, 21 and/or 3.


Note: BPLIM provides the excel file with available CAE codes. This file should be in the current working directory if the user does not want to specify option {opt excel}.


{title:Examples}

Example 1:
Validate CAE codes according to Classification 3. Create variables _valid_cae and _valid_cae3.

{p 8 16}{inp:. validarcae cae, keep}{p_end}

Example 2:
Validate CAE codes according to Classifications 1, 2, 2.1 and 3 for a panel, presenting relative frequencies in table with valid and invalid codes. 

{p 8 16}{inp:. validarcae cae, rev(1 2 21 3) tvar(ano) freq}{p_end}


{title:Remarks}

Please notice that this software is provided "as is", without warranty of any kind, whether
express, implied, or statutory, including, but not limited to, any warranty of merchantability
or fitness for a particular purpose or any warranty that the contents of the item will be error-free.
In no respect shall the author incur any liability for any damages, including, but limited to,
direct, indirect, special, or consequential damages arising out of, resulting from, or any way
connected to the use of the item, whether or not based upon warranty, contract, tort, or otherwise.


{title:Dependencies}

{cmd:package matrixtools} by Niels Henrik Bruun



{title:Author}

{p}
BPlim, Banco de Portugal, Portugal.

{p}
Email: {browse "mailto:bplim@bportugal.pt":bplim@bportugal.pt}

I appreciate your feedback. Comments are welcome!
