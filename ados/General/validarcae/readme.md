# VALIDARCAE: Checks whether a Portuguese Classification of Economic Activities (CAE) code is valid

There have been several revisions of the Portuguese Economic Activities Classification, namely Revision 1, 2, 2.1 and 3.
`validarcae` verifies if a CAE code is valid under any of the aformentioned revisions. Please keep in mind that one code might be valid 
according to several revisions.

## Installation:

To install run the following in Stata:

net install validarcae, from("https://github.com/BPLIM/Tools/raw/master/ados/General/validarcae")

## Files 

The command uses the auxiliary file caecodes.txt to validate CAE codes. This file is installed in your adopath (PLUS) when you run the previous command in Stata.

## Author

BPLIM team
<br>Banco de Portugal
<br>Email: bplim@bportugal.pt
