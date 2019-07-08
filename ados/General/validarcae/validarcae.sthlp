{smcl}
{.-}
help for {cmd:validarcae} {right:()}
{.-}

{title:Title}

validarcae - validates the Portuguese Classification of Economic Activities (CAE) codes


{title:Syntax}

{p 8 15}
{cmd:validarcae} {it:var}, [{it:options}]

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

Codes from revisions 2, 21 and 3 have 5 digits (at the highest level of disaggregation) and may start with a zero. It may happen that a 0 was lost when converting from string to number, 
so we want to check if codes with a length smaller than 5 can still be valid if we add a 0 to the left. Therefore, _valid_cae_# can take on the following values:

- 0 : missing {it:var};
- i1: valid at i digits only;					(i = 1, 2, 3, 4)
- i2: valid at i + 1 digits (0 + i digits);			(i = 1, 2, 3, 4)
- i3: valid at i digits only or i + 1 digits (0 + i digits);	(i = 1, 2, 3, 4)
- 51: vaid at 5 digits;
- 99: invalid.

Codes from revision 1 have 6 digits (at the highest level of disaggregation) and always start with a number greater than 0, so the possible values for _valid_cae_# are:

- 0 : missing {it:var};
- i1: valid at i digits;					(i = 1, 2, 3, 4, 5, 6)
- 99: invalid.

A tabulation of _valid_cae_# is also presented.


{title:Options}

{p 0 4}{opt rev()} allows the user to specify which CAE Revision should be used. The user may choose between 1, 2 21 and 3. If not specified, the default Revision is 3.

{p 0 4}{opt dropzero} drops the most right zeros from the codes. A zero to the right of a code usually means that the level of aggregation is the same as
					  in the previous level, so if we take out the zero(s), the code should still be a valid CAE.
					  
{p 0 4}{opt cfl} uses the first word of the value label associated with each code for validation.

{p 0 4}{opt getlevels(numlist)} returns (a) variable(s) with validated codes according to different types of aggregation specified by the user. The levels for each Classification,
as well as their names, might be different, and the variables returned reflect those differences. Below we present the levels for each classification and their names:

- CAE Rev. 1 : Division (1); Subdivision (2); Class (3); Group (4); Subgroup (5); Split(6)
- CAE Rev. 2 : Section (1); Subsection (2); Division (3); Group (4); Class (5); Subclass(6)
- CAE Rev. 21: Section (1); Subsection (2); Division (3); Group (4); Class (5); Subclass(6)
- CAE Rev. 3 : Section (1); Division (2); Group (3); Class (4); Subclass(5)


The user may select all the levels (1 2 3 4 5 (6)), which will create 5 or 6 new variables, depending on the Revision. These newly created variables are numerical and have value
labels associated with each code. You can always get the real code (string) from the value label, using {help decode} and {help word}, by extracting the first word of the value label.
Observations for which the code is invalid, missing observations and observations with a length smaller than the length required for conversion to a certain group will be coded
as -99 and have the value label "Unsuccessful Conversion".

{p 0 4}{opt fl} should only be used when {opt getlevels} is specified. It adds a zero to the left of codes where _valid_cae_# is equal to 13, 23, 33 or 43.

{p 0 4}{opt fr} should only be used when {opt getlevels} is specified. It removes the most right zeros from the valid CAE codes. This option should
be specified if {opt dropzero} was set for validation.

{p 0 4}{opt en} should only be used when {opt getlevels} is specified. It sets English as the language for valid CAE codes' value labels. The default is Portuguese.


{title:Examples}

Example 1:
Validate CAE codes according to Classification 3.

{p 8 16}{inp:. validarcae cae}{p_end}

Example 2:
Validate CAE codes (with the most right zeros dropped) according to Classification 1 and create variables rev1_division and rev1_class,
which contain, respectively, codes for CAE Rev.1 Division and Class. 

{p 8 16}{inp:. validarcae cae, rev(1) dropzero getlevels(1 3) fr}{p_end}


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
