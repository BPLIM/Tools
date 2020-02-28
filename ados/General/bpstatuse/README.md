# BPSTATUSE: Import series from BPstat Databases

`bpstatuse` is a [Stata](http://www.stata.com/) package that allows users to import over 140,000
statistical series from Banco de Portugal BPstat Database. The package includes two ado-files: `bpstatuse`, the command line version, and `bpstatdlg`, the menu-driven approach that launches a dialog box for the user to select the series.

## Install

`bpstatuse` is not available in SSC. To install run the following in Stata:

net install bpstatuse, from("https://github.com/BPLIM/Tools/raw/master/ados/General/bpstatuse/")

## Dependencies

This package uses Python embedded code which is only available in Stata 16. Furthermore, `bpstatuse` will only work with Pyhton 3.5+.

- ### Third party packages required in Python:

  - pandas
  - requests
  - ttkthemes (only for `bpstatdlg`)

- ### Installation of the required packages:

  - Using Python's **pip** installer (from the Terminal/Command Prompt):

    > *pip install requests*
    >
    > *pip install pandas*
    >
    > *pip install ttkthermes*
    >

   - If you have the Anaconda distribution, you may also use the Anaconda Prompt, typing:

       > *conda install -c anaconda requests* [1]
       >
       > *conda install -c anaconda pandas* [1]
       >
       > *conda install -c gagphil1 ttkthemes*
       >    

[1] These packages come pre-installed with Anaconda, so you probably will not need to use these two lines.



## Author

BPLIM Team
<br>Banco de Portugal
<br>Email: bplim@bportugal.pt
