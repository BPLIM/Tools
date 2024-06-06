{smcl}
{* *! version 1.0 5Jun2024}{...}{smcl}
{.-}
help for {cmd:validarcae} {right:}
{.-}

{title:Title}

{pstd}
{cmd:validarcae} {hline 1} provides several functionalities for dealing with
codes from the Portuguese Classification of Economic Activities (CAE)

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:validarcae}
{cmd:} {help varname:varname} [{help if}], [{it:options}]

where {it:varname} is either a string or numeric variable containing CAE codes

{marker options}{...}
{title:Options}

{synoptset 32 tabbed}{...}
{marker table_options}{...}
{synopthdr}
{synoptline}
{syntab :Options}
{synopt :{opt rev(#)}} allows the user to specify which CAE Revision to use.
The user may choose between 1, 2, 21, or 3. If the option is not specified it defaults
to Revision 3.
{p_end}

{synopt :{opt getlevels}({it:numlist}[, {opt en} {opt force}])} returns (a) variable(s)
with the same or higher aggregation level for validated codes. 
The levels, as well as their designations,
differ according to CAE revisions and the variables returned reflect those differences.
Below we present the levels for each CAE revision and their designations:{break}{space 5}{break}
{hline 1} CAE Rev. 1 : Division (1); Subdivision (2); Class (3); Group (4); Subgroup (5); Split(6){break}
{hline 1} CAE Rev. 2 : Section (1); Subsection (2); Division (3); Group (4); Class (5); Subclass(6){break}
{hline 1} CAE Rev. 21: Section (1); Subsection (2); Division (3); Group (4); Class (5); Subclass(6){break}
{hline 1} CAE Rev. 3 : Section (1); Division (2); Group (3); Class (4); Subclass(5){break}{space 5}{break}
The user may select all the levels (1 2 3 4 5 (6)), which will create 5 (6) new variables, depending
on the CAE revision. These newly created variables are numerical and have value labels associated with
each code.{break}
The value label always includes the original code plus the official description. You can
extract the original code (string) from the value label with the option {opt keep}.{break}
Observations for which the code is invalid, missing observations, and observations
 with a length smaller than the length required for conversion will be coded
as -99 with the value label "Invalid Conversion". Codes with an ambiguous validation
will be coded as -98 with the value label "Ambiguous validation, not able to convert".{break}{space 5}{break}
{opt en} sets English as the language to use for the description of CAE codes included in the value labels.
The default is Portuguese.{break}{space 5}{break}
{opt force} forces the conversion on observations with an ambiguous validation by ignoring the
possibility of leading zeros. {opt force} will not work if the ambiguity is generated
because option {opt dropzero} was specified.
{p_end}

{synopt :{opt solve}({it:var}[, {opt th} {opt en}])} this option can
be used if the user has a string variable with the description of 
CAE codes. Ambiguous cases are solved
by comparing the description provided by the user with
the official description. The option uses {help jarowinkler:jarowinkler} to
select the codes with the closest string distance - the metric is scaled 
between 0 (not similar at all) and 1 (exact match).
This option creates variable {opt _solved} taking value one if the ambiguity
was solved using the description of the code and zero otherwise.
{break}{space 5}{break}
{opt th} is the minimum Jaro-Winkler similarity score allowed to solve ambiguities.
The default is 0.7. If the Jaro-Winkler similarity score between strings is smaller
than this value, the ambiguity will not be solved.{break}{space 5}{break}
{opt en} sets English as the language of the description in the variable provided.
The default is Portuguese.
{p_end}

{synopt :{opt sim:ilarity}({it:var}[, {opt en}])} computes the Jaro-Winkler similarity metric 
between a string variable with the description of CAE codes and the official description, 
using {help jarowinkler:jarowinkler} - the metric is scaled 
between 0 (not similar at all) and 1 (exact match). 
This option creates variable {opt _jwsim_rev_#}, where # is the Revision number.
{break}{space 5}{break}
{opt en} sets English as the language of the description in the variable provided.
The default is Portuguese.
{p_end}

{synopt :{opt keep}} creates a variable named {opt _cae_str}, which is basically
a string version of the variable provided by the user. However, codes may be
different from those provided by the user, depending on two factors:{break}{space 5}{break}
(i) option {opt dropzero} was specified, effectively changing {opt _cae_str} for
codes where there are no ambiguities;{break}
(ii) a 0 was added to the left of codes where _valid_cae_# is equal to 2, 20, 200 or 2000.{p_end}

{synopt :{opt fromlabel}} this option should be used if the variable has value labels and those labels
follow the convention of having the code as the first word. In this case the command validates the codes
that are extracted from the value labels.{break}
{opt IMPORTANT}: BPLIM datasets always follow this convention for value labels.
{p_end}

{synopt :{opt dropzero}} in some datasets CAE variables mix codes with different levels of aggregation
where codes for higher levels of aggregation are right padded with zeros (and thus are invalid).
This option performs a validation of invalid codes by recursively dropping the rightmost zero from the codes.
The process stops when one of the following conditions is met for every observation:{break}{space 5}{break}
(i) the code's length is equal to 1;{break}
(ii) the last digit of the code is different from 0.{break}{space 5}{break}
The option produces the variable {opt _zerosdropped}, which contains,
for each observation, the number of zeros that had to be dropped until
one of the aforementioned conditions was met.{break}
The validation codes for these observations are a combination (sum)
of the codes presented below,
because the code is validated every time a zero is dropped.
{p_end}

{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}

{pstd}
{cmd: validarcae} is a Stata command that provides several functionalities for
dealing with codes from the Portuguese Classification of Economic Activities (CAE).
The command validates existing codes and descriptions, identifies possible ambiguities,
aggregates codes to higher levels, and provides the official code description in portuguese
and english. The command works with all revisions of the CAE:

{pstd}
{hline 1}  CAE Revision 1{space 1}:    1973 - 1993{p_end}
{pstd}
{hline 1}  CAE Revision 2{space 1}:    1994 - 2002{p_end}
{pstd}
{hline 1}  CAE Revision 21:   2003 - 2007{p_end}
{pstd}
{hline 1}  CAE Revision 3{space 1}:    2008 - ...{p_end}

{pstd}
{opt Note}: the time interval represents the official dates in which a revision
came into force.

{pstd}
The command produces the variable {opt _valid_cae_#} signaling valid and invalid codes
for CAE Revision # as specified by the user, where # equals 1, 2, 21 or 3.
Codes from revision 1 have 6 digits (at the highest level of disaggregation) and
always start with a number greater than 0, so the possible values for
{opt _valid_cae_#} are:

{pstd}
{hline 1} 0{space 5}:   missing {it:obs};{p_end}
{pstd}
{hline 1} 1{space 5}:   valid at 1 digit;{p_end}
{pstd}
{hline 1} 10{space 4}:   valid at 2 digits;{p_end}
{pstd}
{hline 1} 100{space 3}:   valid at 3 digits;{p_end}
{pstd}
{hline 1} 1000{space 2}:   valid at 4 digits;{p_end}
{pstd}
{hline 1} 10000{space 1}:   valid at 5 digits;{p_end}
{pstd}
{hline 1} 100000:   valid at 6 digits;{p_end}
{pstd}
{hline 1} 200000:   invalid code.{p_end}

{pstd}
Codes from revisions 2, 21 and 3 have 5 digits (at the highest level of
disaggregation) and may start with a zero. Zeros on the left are sometimes
inadvertently lost (for example if the codes are converted to numeric format),
so we check if codes with a length smaller than 5 will still be valid
if a 0 is added to the left. Therefore, {opt _valid_cae_#} can take on the
following values:

{pstd}
{hline 1} 0{space 5}:   missing {it:obs};{p_end}
{pstd}
{hline 1} 2{space 5}:   valid at 2 digits (0 + 1 digit);{p_end}
{pstd}
{hline 1} 10{space 4}:   valid at 2 digits only;{p_end}
{pstd}
{hline 1} 20{space 4}:   valid at 3 digits (0 + 2 digits);{p_end}
{pstd}
{hline 1} 30{space 4}:   valid at 2 digits only or 3 digits (0 + 2 digits);{p_end}
{pstd}
{hline 1} 100{space 3}:   valid at 3 digits only;{p_end}
{pstd}
{hline 1} 200{space 3}:   valid at 4 digits (0 + 3 digits);{p_end}
{pstd}
{hline 1} 300{space 3}:   valid at 3 digits only or 4 digits (0 + 3 digits);{p_end}
{pstd}
{hline 1} 1000{space 2}:   valid at 4 digits only;{p_end}
{pstd}
{hline 1} 2000{space 2}:   valid at 5 digits (0 + 4 digits);{p_end}
{pstd}
{hline 1} 3000{space 2}:   valid at 4 digits only or 5 digits (0 + 4 digits);{p_end}
{pstd}
{hline 1} 10000{space 1}:   valid at 5 digits;{p_end}
{pstd}
{hline 1} 200000:   invalid code.{p_end}

{pstd}
Upon conclusion of the command a tabulation of {opt _valid_cae_#} is presented.

{title:Examples}

Example 1:
Validate CAE codes according to CAE Revision 3.

{p 8 16}{inp:. validarcae cae}{p_end}

Example 2:
Validate CAE codes according to CAE Revision 1 and create variables {opt rev1_division} and
{opt rev1_class} with value labels in English.
The new variables contain, respectively, codes for CAE Rev.1 Division and Class.

{p 8 16}{inp:. validarcae cae, rev(1) getlevels(1 3, en)}{p_end}

Example 3:
Validate CAE codes according to CAE Revision 3 and use variable {opt cae_desc} 
to solve ambiguous codes. Variable {opt cae_desc} contains the Portuguese 
description of the CAE codes.

{p 8 16}{inp:. validarcae cae, solve(cae_desc)}{p_end}

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
{cmd:savesome} by Nicholas Cox {p_end}
{pstd}
{cmd:ustrdist} by Michael Barker and Felix Pöge (for option {opt solve}){p_end}

{title:Author}

{pstd}
BPLIM, Banco de Portugal, Portugal.

{pstd}
Email: {browse "mailto:bplim@bportugal.pt":bplim@bportugal.pt}

We appreciate your feedback. Comments are welcome!
