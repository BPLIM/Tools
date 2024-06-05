{smcl}
{* *! version 0.1 3Sep2021}{...}{smcl}
{.-}
help for {cmd:validarcpp} {right:}
{.-}

{title:Title}

{pstd}
{cmd:validarcpp} {hline 1} provides several functionalities for dealing with
codes from the Portuguese Classification of Occupations (CPP) / National 
Classification of Occupations (CNP)

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:validarcpp}
{cmd:} {help varname:varname}, [{it:options}]

where {it:varname} is either a string or numeric variable containing CPP/CNP codes

{marker options}{...}
{title:Options}

{synoptset 32 tabbed}{...}
{marker table_options}{...}
{synopthdr}
{synoptline}
{syntab :Options}
{synopt :{opt c:lass(#)}} allows the user to specify which CPP/CNP Classification to use.
The user may choose between 1980, 1994, or 2010. If the option is not specified it defaults
to the 2010 Classification.
{p_end}

{synopt :{opt getlevels}({it:numlist}[, {opt en} {opt force}])} returns (a) variable(s)
with the same or higher aggregation level for validated codes. 
The levels, as well as their designations,
differ according to CPP/CNP classifications and the variables returned reflect those differences.
The levels for each CPP/CNP classification and their designations are presented below:{break}{space 5}{break}
{hline 1} CNP 1980 : Major Group (1); Minor Group (2); Unit Group (3); Occupation (4){break}
{hline 1} CNP 1994 / CPP 2010 : Major Group (1); Sub-Major Group (2); Minor Group (3); Unit Group (4); Occupation (5){break}{space 5}{break}
The user may select all the levels (1 2 3 4 (5)), which will create 4 (5) new variables, depending
on the CPP/CNP classification. These newly created variables are numerical and have value labels associated with
each code.{break}
The value label always includes the original code plus the official description. You can
extract the original code (string) from the value label.
{break}{space 5}{break}
{opt en} sets English as the language to use for the description of CPP/CNP codes included in the value labels and for variable labels.
May only be used with {opt class} 2010. The default is Portuguese.{break}{space 5}{break}
{opt force} forces the conversion of observations with an ambiguous validation by ignoring the
possibility of leading zeros.
{p_end}

{synopt :{opt solve}({it:var}[, {opt th} {opt en}])} this option can
be used if the user has a string variable with the description of
the CPP/CNP codes. Ambiguous cases are solved
by comparing the description provided by the user with
the official description. The option uses {help jarowinkler:jarowinkler} 
to select the codes with the closest string 
distance - the metric is scaled between 0 
(not similar at all) and 1 (exact match). 
This option creates variable {opt _solved} taking value one if the ambiguity
was solved using the description of the code and zero otherwise.
{break}{space 5}{break}
{opt th} is the minimum Jaro-Winkler similarity score 
allowed to solve ambiguities.  The default is 0.7. 
If the Jaro-Winkler similarity score between strings 
is smaller than this value, the ambiguity will 
not be solved.{break}{space 5}{break}
{opt en} sets English as the language of the description in the variable provided.
May only be used with {opt class} 2010. The default is Portuguese. 
{p_end}

{synopt :{opt sim:ilarity}({it:var}[, {opt en}])} computes the Jaro-Winkler similarity metric 
between a string variable with the description of CNP/CPP codes and the official description 
using {help jarowinkler:jarowinkler} - the metric is scaled 
between 0 (not similar at all) and 1 (exact match). 
This option creates variable {opt _jwsim_class_#}, where # is the Classification 
number.
{break}{space 5}{break}
{opt en} sets English as the language of the description in the variable provided.
May only be used with {opt class} 2010. The default is Portuguese.
{p_end}

{synopt :{opt keep}} creates a variable named {opt __cpp__}, which is basically
a string version of the variable provided by the user. However, codes may be
different from those provided by the user if a 0 was added to the left of codes where _valid_cpp_# is equal to 11, 21, 31, 41 or 51.{p_end}

{synopt :{opt fromlabel}} this option can be used if the variable has value labels and those labels
follow the convention of having the code as the first word. In this case the command validates the codes
that are extracted from the value labels.{break}
{opt IMPORTANT}: BPLIM datasets usually follow this convention for value labels.
{p_end}

{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}

{pstd}
{cmd: validarcpp} is a Stata command that provides several functionalities for
dealing with codes from the Portuguese Classification of Occupations (CPP) / National 
Classification of Occupations (CNP).
The command validates existing codes and descriptions, identifies possible ambiguities,
aggregates codes to higher levels, and provides the official code description in Portuguese
and English. The command works with the following classifications 
of CPP/CNP (each classification follows a particular International Standard Classification of Occupations (ISCO) standard):

{pstd}
{hline 1}  CNP/1980:    1980 - 1995{space 1}(ISCO-1968){p_end}
{pstd}
{hline 1}  CNP/1994:    1995 - 2010{space 1}(ISCO-1988){p_end}
{pstd}
{hline 1}  CPP/2010:   2011 - ...{space 2}(ISCO-2008){p_end}

{pstd}
{opt Note}: the time interval represents the official dates in which a classification
was adopted.

{pstd}
The command produces the variable {opt _valid_cpp_#} signaling valid and invalid codes
for CPP/CNP Classification # as specified by the user, where # equals 1980, 1994 or 2010.
Two situations may arise when performing the validation. Original codes have punctuation, but are usually presented without it. Notwithstanding, the command contemplates this possibility. 
In the first case, _valid_cpp_# can take on the following values, each pertaining to a different level of aggregation:

{pstd}
{hline 1} -99:   missing {it:obs};{p_end}
{pstd}
{hline 1} 0{space 2}:   invalid;{p_end}
{pstd}
{hline 1} 1{space 2}:   valid - level 1;{p_end}
{pstd}
{hline 1} 2{space 2}:   valid - level 2;{p_end}
{pstd}
{hline 1} 3{space 2}:   valid - level 3;{p_end}
{pstd}
{hline 1} 4{space 2}:   valid - level 4;{p_end}
{pstd}
{hline 1} 5{space 2}:   valid - level 5;{p_end}

{pstd}
{opt Note}: _valid_cpp_# can only take value 5 for classifications 1994 and 2010 (see option {opt getlevels}).

{pstd}
However, the more common case is that codes are presented without punctuation, either being of type string or numeric.
These codes contain only digits and may start with a zero. Zeros on the left are sometimes
inadvertently lost (for example if the codes are converted to numeric format),
so we check if codes for levels of aggregation lower than 5 will still be valid
if a 0 is added to the left. Therefore, {opt _valid_cpp_#} can take on the
following values:

{pstd}
{hline 1} -99:   missing {it:obs};{p_end}
{pstd}
{hline 1} 0{space 2}:   invalid;{p_end}
{pstd}
{hline 1} 1{space 2}:   valid - level 1;{p_end}
{pstd}
{hline 1} 11{space 1}:   valid - level 2 (0 + code);{p_end}
{pstd}
{hline 1} 12{space 1}:   valid - level 1 | level 2 (0 + code);{p_end}
{pstd}
{hline 1} 2{space 2}:   valid - level 2;{p_end}
{pstd}
{hline 1} 21{space 1}:   valid - level 3 (0 + code);{p_end}
{pstd}
{hline 1} 22{space 1}:   valid - level 2 | level 3 (0 + code);{p_end}
{pstd}
{hline 1} 3{space 2}:   valid - level 3;{p_end}
{pstd}
{hline 1} 31{space 1}:   valid - level 4 (0 + code);{p_end}
{pstd}
{hline 1} 32{space 1}:   valid - level 3 | level 4 (0 + code);{p_end}
{pstd}
{hline 1} 4{space 2}:   valid - level 4;{p_end}
{pstd}
{hline 1} 41{space 1}:   valid - level 5 (0 + code);{p_end}
{pstd}
{hline 1} 42{space 1}:   valid - level 4 | level 5 (0 + code);{p_end}
{pstd}
{hline 1} 5{space 2}:   valid - level 5;{p_end}

{pstd}
{opt Note}: two digit values ending in "2" represent ambiguous cases (see option {opt solve}).

{pstd}
Upon conclusion of the command a tabulation of {opt _valid_cpp_#} is presented.

{title:Examples}

{pstd}
Example 1:
Validate CPP/2010 codes.

{p 8 16}{inp:. validarcpp cpp}{p_end}

{pstd}
Example 2:
Validate CNP/1994 codes and create variables {opt cpp1994_level1} and
{opt cpp1994_level2} with value labels in Portuguese.
The new variables contain, respectively, codes for CNP/1994 Major Group and Sub-Major Group.

{p 8 16}{inp:. validarcpp cpp, class(1994) getlevels(1 2)}{p_end}

{pstd}
Example 3:
Validate CPP/2010 codes and use variable {opt cpp_desc} 
to solve ambiguous codes. Variable {opt cpp_desc} contains the Portuguese 
description of the CPP/2010 codes.

{p 8 16}{inp:. validarcpp cpp, solve(cpp_desc)}{p_end}

{pstd}
Example 4:
Validate CPP/2010 codes' descriptives stored in variable {opt cpp_desc}, using 0.1 as the maximum relative distance between strings. 

{p 8 16}{inp:. validarcpp cpp, validatedesc(cpp_desc, 0.1)}{p_end}

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
{cmd:charlist} by Nicholas Cox {p_end}
{pstd}
{cmd:labmask} by Nicholas Cox (for option {opt getlevels}){p_end}
{pstd}
{cmd:ustrdist} by Michael Barker and Felix Pöge (for options {opt solve} and {opt validatedesc}){p_end}

{title:Author}

{pstd}
BPLIM, Banco de Portugal, Portugal.

{pstd}
Email: {browse "mailto:bplim@bportugal.pt":bplim@bportugal.pt}

We appreciate your feedback. Comments are welcome!
