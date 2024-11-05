# BPSTAT: Import series from BPstat Databases

`bpstat` is a [Stata](http://www.stata.com/) package that allows users to import over 230,000
statistical series from Banco de Portugal [BPstat](https://bpstat.bportugal.pt/) Database. Users may import series using  `bpstat use`, the command line version, or `bpstat dlg`, the menu-driven approach that launches a dialog box for the user to select the series. The package also contains some tools to help users search for series of interest and collect their metadata.

## Install

`bpstat` is not available in SSC. To install run the following in Stata:

```
net install bpstat, from("https://github.com/BPLIM/Tools/raw/master/ados/General/bpstat/")
```

## Dependencies

This package uses Python embedded code which is only available in Stata 16. Furthermore, `bpstat` will only work with Python 3.6+.

- ### Third party packages required in Python:

  - pandas
  - requests
  - ttkthemes (only for the menu-driven approach)

- ### Installation of the required packages:

  - Using Python's **pip** installer (from the Terminal/Command Prompt):

    > *pip install requests*
    >
    > *pip install pandas*
    >
    > *pip install ttkthemes*
    >

   - If you have the Anaconda distribution, you may also use the Anaconda Prompt, typing:

       > *conda install -c anaconda requests* [1]
       >
       > *conda install -c anaconda pandas* [1]
       >
       > *conda install -c gagphil1 ttkthemes*
       >    

[1] These packages come pre-installed with Anaconda, so you probably will not need to use these two lines.

## Updating

Please make sure `bpstat` is always up to date with the latest available version. In order to do so, run the following command in Stata:

```
net install bpstat, from("https://github.com/BPLIM/Tools/raw/master/ados/General/bpstat/") replace
```

## Author

BPLIM Team
<br>Banco de Portugal
<br>Email: bplim@bportugal.pt
