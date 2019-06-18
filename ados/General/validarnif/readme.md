# VALIDARNIF: Checks whether a Portuguese Fiscal Identification Number (NIF/NIPC) is valid

Portuguese Tax Identification Numbers (NIFs/NIPC) always have nine digits and the last one is a control digit. More information can be found [here](https://pt.wikipedia.org/wiki/N%C3%BAmero_de_identifica%C3%A7%C3%A3o_fiscal) (in portuguese).
`validarnif` validates the NIF/NIPC and creates a variable *_valid* with we following codes:

0 - for valid observations;
1 - first digit invalid
2 - less than 9 digits
3 - check digit invalid
4 - missing var
5 - non-numeric type

## Installation:

To install run the following in Stata:

net install validarnif, from("https://github.com/BPLIM/Tools/raw/master/ados/General/validarnif")

## Author

BPLIM team
<br>Banco de Portugal
<br>Email: bplim@bportugal.pt
