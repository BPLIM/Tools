# ADOVERSION: Utility tool that reports the version of every ado found in the paths returned by command `adopath`

`adoversion` is a Stata command that generates a report about ado files currently available to the user and their version. 
The command searches for ados in the paths returned by `adopath`, in the order that they appear, producing a text report
for each of the paths.

## Installation:

To install run the following in Stata:

```
net install adoversion, from("https://github.com/BPLIM/Tools/raw/master/ados/General/adoversion/")
```

## Author

BPLIM team
<br>Banco de Portugal
<br>Email: bplim@bportugal.pt
