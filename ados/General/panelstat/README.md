# PANELSTAT: Descriptive statistics for panel data sets

`panelstat` is a [Stata](http://www.stata.com/) tool to explore unbalanced panel data sets. The software was developed to explore in detail a panel data set. The options that were added reflect particular needs felt by the restricted group of users at BPLIM - the microdata laboratory at the Banco de Portugal - who use it on a regular basis. No attention has been given to formatting of outputs.

## Install

`panelstat` is not in SSC. To install run the following in Stata:

net install panelstat, from("https://github.com/BPLIM/Tools/raw/master/ados/General/panelstat/")

## User guide

The file `panelstat_UG.html` contains a small user guide. This file was written using the Stata markdown due to German Rodriguez and compiled with [`markstat`](https://data.princeton.edu/stata/markdown).
The source file is `panelstat_UG.stmd`. After installing the `markstat` ado file type:
```
markstat using panelstat_UG.stmd
```
to create an html version of the user guide (*panelstat_UG.html*).

## Author

BPLIM Team
<br>Banco de Portugal
<br>Email: bplim@bportugal.pt

