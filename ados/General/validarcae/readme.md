# VALIDARCAE: Utility tool to deal with Portuguese Classification of Economic Activities (CAE) codes

There have been several revisions of the Portuguese Economic Activities Classification, namely Revision 1, 2, 2.1 and 3.
`validarcae` verifies if a CAE code is valid under one of the aformentioned revisions, as specified by the user. Moreover, it also allows for the user to get different types of aggregations for valid codes according to each revision.

## Installation:

To install run the following in Stata:

net install validarcae, from("https://github.com/BPLIM/Tools/raw/master/ados/General/validarcae")

## Files 

The command uses the ancillary file "caecodes.txt" to validate CAE codes. This file is installed in your adopath (PLUS) when you run the previous command in Stata.

## Author

BPLIM team
<br>Banco de Portugal
<br>Email: bplim@bportugal.pt
