# COCONUTS: Utility tool to create Nomenclature of Territorial Units for Statistics (NUTS) variables for Portuguese municipalities

According to [INE (Statistics Portugal)](http://smi.ine.pt/Conceito/Detalhes/3879), the Nomenclature of Territorial Units for Statistics (NUTS) subdivides the economic
territory for statistical purposes. This command allows users to allocate Portuguese municipalities to the aforementioned regions, creating a variable for each level. 
There have been several revisions to this classification and the command takes that fact into account.


## Installation:

To install run the following in Stata:

```
net install coconuts, from("https://github.com/BPLIM/Tools/raw/master/ados/General/coconuts")
```

## Files 

The command uses the ancillary file "coconuts_final.dta" to allocate the municipalities to NUTS. This file is installed in your adopath (PLUS) when you run the previous command in Stata.

## Author

BPLIM team
<br>Banco de Portugal
<br>Email: bplim@bportugal.pt
