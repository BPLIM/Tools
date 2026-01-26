*! version 0.2 12Nov2025
* Programmed by Paulo Guimaraes
* Changed by Gustavo Iglésias (remove chars from dta)

program define metaxl_clear

syntax, [force]


if "`force'" == "force" {
	clear_metadata
}
else {
	capture window stopbox rusure ///
		"Are you sure you want to clear all the metadata?"
	if !_rc {
		clear_metadata
	}
}

end


program define clear_metadata

* drop labels
label data ""
label drop _all
_strip_labels _all
* drop chars
foreach var of varlist * {
	label var `var' ""
	local charvar: char  `var'[ ]
	foreach j of local charvar {
		char `var'[`j']
	}
}
* drop notes
qui notes drop _all
* drop languages
qui label language
local langs `r(languages)'
foreach j of local langs {
	if "`j'"!="default" {
		label language `j', delete
	}
}
* delete sorted by
tempvar dum
gen long `dum'=_N
sort `dum'
drop `dum'
* reset format 
qui metaxl_setdefaultfmt *	

local chardta: char  _dta[ ]
foreach j of local chardta {
	char _dta[`j']
}

end
