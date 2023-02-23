# STANDARDIZETEXT: Normalize Unicode string variables

`standardizetext` is a [Stata](http://www.stata.com/) command that normalizes text, by returning the normal form of a Unicode string variable. It also removes 
special characters and stop words if specified by the user.

## Install

`standardizetext` is not available in SSC. To install run the following in Stata:

```
net install standardizetext, from("https://github.com/BPLIM/Tools/raw/master/ados/General/standardizetext/")
```

## Dependencies

This package uses Python embedded code which is only available in Stata 16. Furthermore, `standardizetext` will only work with Python 3.5+.


## Author

BPLIM Team
<br>Banco de Portugal
<br>Email: bplim@bportugal.pt
