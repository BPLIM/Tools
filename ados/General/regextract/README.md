# REGEXTRACT: Extract capture groups from regex patterns

`regextract` is a [Stata](http://www.stata.com/) wrapper for 
[pandas string extract method](https://pandas.pydata.org/docs/reference/api/pandas.Series.str.extract.html)

## Install

`regextract` is not available in SSC. To install run the following in Stata:

```
net install regextract, from("https://github.com/BPLIM/Tools/raw/master/ados/General/regextract/")
```

## Dependencies

This package uses Python embedded code which is only available in Stata 16. Furthermore, `regextract` will only work with Python 3.6+.

- ### Third party packages required in Python:

  - pandas


## Author

BPLIM Team
<br>Banco de Portugal
<br>Email: bplim@bportugal.pt
