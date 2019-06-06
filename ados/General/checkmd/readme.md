# CHECKMD: Verifies and reports multiple logical conditions in an html file

`checkmd` is a [Stata](http://www.stata.com/) tool that verifies logical conditions within a dataset or between datasets. These conditions are provided by the user in a csv file. The command produces two html files, one that presents detailed information about each check
and other that contains the summary for all checks performed. Instructions on how to structure the csv file can be found in the help file.

## Install:

`checkmd` is not in SSC. To install run the following in Stata:

net install checkmd, from("https://github.com/BPLIM/Tools/raw/master/ados/General/checkmd")

## Author

BPLIM team
<br>Banco de Portugal
<br>Email: bplim@bportugal.pt
