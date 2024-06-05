# VALIDARCPP: Utility tool to deal with codes from the Portuguese Classification of Occupations (CPP) / National Classification of Occupations (CNP)

There have been several revisions of the Portuguese Classification of Occupations (CPP) / National Classification of Occupations (CNP) - 1980, 1994 and 2010.
`validarcpp` verifies if a CPP/CNP code is valid under one of the aforementioned revisions, as specified by the user. Moreover, it also allows for the user to get different types of aggregations for valid codes according to each revision.

## Installation:

To install run the following in Stata:

```
net install validarcpp, from("https://github.com/BPLIM/Tools/raw/master/ados/General/validarcpp/")
```

## Files 

The command uses the ancillary files "cpp.csv" and "cpp_final.csv". These files are installed in your adopath (PLUS) when you run the previous command in Stata.

## Author

BPLIM team
<br>Banco de Portugal
<br>Email: bplim@bportugal.pt
