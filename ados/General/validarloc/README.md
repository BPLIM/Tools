# VALIDARLOC: Utility tool to deal with Portuguese administrative division codes

There have been several changes of the Portuguese administrative division (districts, municipalities and parishes).
`validarloc` verifies if the administrative codes are valid. Moreover, it also allows the user to get different types of aggregations for valid codes according to a specific reference date.

## Installation:

To install run the following in Stata:

```stata
net install validarloc, from("https://github.com/BPLIM/Tools/raw/master/ados/General/validarloc")
```

## Files 

The command uses the ancillary file "versoes.dta" to validate codes. This file is installed in your adopath (PLUS) when you run the previous command in Stata.

## Author

BPLIM team
<br>Banco de Portugal
<br>Email: bplim@bportugal.pt