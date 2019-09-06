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

The command produces the variable _valid_cae_# with valid and invalid codes for CAE Revision # as specified by the user, where # equals 1, 2, 21 or 3. 

Codes from revision 1 have 6 digits (at the highest level of disaggregation) and always start with a number greater than 0, so the possible values for _valid_cae_# are:

- 0     :   missing {it:var};
- 1     :   valid at 1 digit;
- 10    :   valid at 2 digits;
- 100   :   valid at 3 digits;
- 1000  :   valid at 4 digits;
- 10000 :   valid at 5 digits;
- 100000:   valid at 6 digits;
- 200000:   invalid.

Codes from revisions 2, 21 and 3 have 5 digits (at the highest level of disaggregation) and may start with a zero. It may happen that a 0 was lost when converting from string to number, 
so we want to check if codes with a length smaller than 5 can still be valid if we add a 0 to the left. Therefore, _valid_cae_# can take on the following values:

- 0     :   missing {it:var};
- 2     :   valid at 2 digits (0 + 1 digit);
- 10    :   valid at 2 digits only;
- 20    :   valid at 3 digits (0 + 2 digits);
- 30    :   valid at 2 digits only or 3 digits (0 + 2 digits);
- 100   :   valid at 3 digits only;
- 200   :   valid at 4 digits (0 + 3 digits);
- 300   :   valid at 3 digits only or 4 digits (0 + 3 digits);
- 1000  :   valid at 4 digits only;
- 2000  :   valid at 5 digits (0 + 4 digits);
- 3000  :   valid at 4 digits only or 5 digits (0 + 4 digits);
- 10000 :   valid at 5 digits;
- 200000:   invalid.

A tabulation of _valid_cae_# is also presented.


{title:Options}

{p 0 4}{opt rev()} allows the user to specify which CAE Revision should be used. The user may choose between 1, 2, 21 or 3. If not specified, the default Revision is 3.

{p 0 4}{opt dropzero} performs a recursive validation of invalid codes by dropping the most right zero from the codes. The process stops when one of the following conditions
					  is met for every observation: (i) the code's length is qual to 1; (ii) the last digit of the code is different from 0. This option produces the 
					  variable _zerosdropped, which contains, for each observation, the number of zeros that had to be dropped until one of the aforementioned 
					  conditions was met. The validation codes for these observations are a combination (sum) of the codes presented above, because the code is validated
					  every time a zero is dropped.
										  
{p 0 4}{opt fromlabel} uses the first word of the value label associated with each code for validation. This assumes that the first word of the value label is the code. 
IMPORTANT: always specify this option if you are using BPLIM's datasets.

{p 0 4}{opt getlevels}({it:numlist}[, {opt en} {opt force}]) returns (a) variable(s) with validated codes according to different types of aggregation specified by the user. The levels for each Classification,
as well as their names, might be different, and the variables returned reflect those differences. Below we present the levels for each classification and their names:

- CAE Rev. 1 : Division (1); Subdivision (2); Class (3); Group (4); Subgroup (5); Split(6)
- CAE Rev. 2 : Section (1); Subsection (2); Division (3); Group (4); Class (5); Subclass(6)
- CAE Rev. 21: Section (1); Subsection (2); Division (3); Group (4); Class (5); Subclass(6)
- CAE Rev. 3 : Section (1); Division (2); Group (3); Class (4); Subclass(5)


The user may select all the levels (1 2 3 4 5 (6)), which will create 5 or 6 new variables, depending on the Revision. These newly created variables are numerical and have value
labels associated with each code. You can always get the real code (string) from the value label, using {help decode} and {help word}, by extracting the first word of the value label.
Observations for which the code is invalid, missing observations and observations with a length smaller than the length required for conversion to a certain group will be coded
as -99 and have the value label "Unsuccessful Conversion". Codes with an ambiguous validation, i.e., where _valid_cae_# (for CAE Rev. 2, 21 and 3) is equal to 30, 300, or 3000, 
will not be converted. The same applies for codes with an ambiguous validation using option {opt dropzero}.

{p 4 8}{opt en} sets English as the language for valid CAE codes' value labels. The default is Portuguese.

{p 4 8}{opt force} forces the conversion on observations with an ambiguous validation. This option is only recommended if the user managed to solve the ambiguities for codes 
				   where _valid_cae_# is equal to 30, 300, or 3000. If this is not the case, the newly created codes where such an ambiguity exists might be wrong. Also, keep 
				   in mind that option {opt force} does not work on codes where _valid_cae_# is equal to 30, 300, or 3000 only because option {opt dropzero} was specified.


{p 0 4}{opt keep} creates a variable named _cae_str, which is basically a string version of the variable provided by the user. However, codes may be different from those provided 
				  by the user, depending on two factors: (i) option {opt dropzero} was specified, effectively changing _cae_str for codes where there are no ambiguities; (ii) a 0 
				  was added to the left of codes where _valid_cae_# is equal to 2, 20, 200 or 2000.
				  
				  
				  
{title:Examples}

Example 1:
Validate CAE codes according to Classification 3.

{p 8 16}{inp:. validarcae cae}{p_end}

Example 2:
Validate CAE codes according to Classification 1 and create variables rev1_division and rev1_class with value labels in English.
The new variables contain, respectively, codes for CAE Rev.1 Division and Class. 

{p 8 16}{inp:. validarcae cae, rev(1) getlevels(1 3, en)}{p_end}


{title:Remarks}

Please notice that this software is provided "as is", without warranty of any kind, whether
express, implied, or statutory, including, but not limited to, any warranty of merchantability
or fitness for a particular purpose or any warranty that the contents of the item will be error-free.
In no respect shall the author incur any liability for any damages, including, but limited to,
direct, indirect, special, or consequential damages arising out of, resulting from, or any way
connected to the use of the item, whether or not based upon warranty, contract, tort, or otherwise.


{title:Dependencies}

{cmd:savesome} (version 1.1.0 23Feb2015) by Nicholas Cox


{title:Author}

{p}
BPlim, Banco de Portugal, Portugal.

{p}
Email: {browse "mailto:bplim@bportugal.pt":bplim@bportugal.pt}

I appreciate your feedback. Comments are welcome!
