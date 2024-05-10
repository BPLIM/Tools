*! version 0.1 16Mar2021
* Programmed by Gustavo Iglésias
* Dependencies: gtools

program define metaxl_morph

syntax anything, METAfile(string) [save(string) keep]

if "`save'" != "" {
	gettoken save replacesave: save, p(",")
	local save = trim("`save'")
	local save "`save'.xlsx"
	gettoken lixo replacesave: replacesave, p(",")
	cap confirm file "`save'"
	if !_rc {
		if trim("`replacesave'") != "replace" {
			di as error `"File "`save'" already exists. Please specify "' ///
			`"sub-option "replace" to overwrite the existing file"'
			exit 602			
		}
		else {
			if "`save'" == "`metafile'.xlsx" {
				local save "`metafile'.xlsx"
			}
			else {
				cap rm "`save'"
				qui copy "`metafile'.xlsx" "`save'"			
			}			
		}
	}
	else {
		qui copy "`metafile'.xlsx" "`save'"
	}
}
else {
	local save "`metafile'_new.xlsx"
	cap confirm file "`save'"
	if !_rc {
		di as error `"File "`save'" already exists. Please specify "' ///
		`"option "save" to save the file under a different name"'
		exit 602
	}
	qui copy "`metafile'.xlsx" "`save'"
}

parse_arg `anything'

local sheet_count = `r(sheet_count)'

forvalues i = 1/`sheet_count' {
	check_args, new(`r(new_sheet`i')') old(`r(old_sheets`i')')
	local new_sheet`i' "`r(new_sheet`i')'"
	local old_sheets`i' "`r(old_sheets`i')'"
	local new_sheets = "`new_sheets'" + " `new_sheet`i''"
}

check_existing_sheets, file(`save') sheets(`new_sheets')

forvalues i = 1/`sheet_count' {
	merge_sheets, meta(`save') new(`new_sheet`i'') old(`old_sheets`i'') `keep'
}

end


program define parse_arg, rclass

syntax anything

local right "`anything'"

local case 1
local i 1
while `case' {
	gettoken left right: right, p(")")
	local exp`i' = substr("`left'", 2, .)
	gettoken left right: right, p(")")
	local right = trim("`right'")
	if "`right'" != "" {
		local ++i
	}
	else {
		local case 0
		return local sheet_count `i'
	}
}

forvalues j = 1/`i' {
	gettoken left`j' right`j': exp`j', p("=")
	if trim("`left`j''") != "" {
		return local new_sheet`j' = trim("`left`j''")
	}
	else {
		di
		di as error "Error in argument expression. Expressions should be of" ///
		" the form (vl_name1 = vl_name2 vl_name3 ...), where vl_name# " ///
		"is the name of the sheet and name# is the name of the value label."
		exit 198
	}
	gettoken left`j' right`j': right`j', p("=")
	if trim("`right`j''") != "" {
		return local old_sheets`j' = trim("`right`j''")
	}
	else {
		di 
		di as error "Error in argument expression. Expressions should be of" ///
		" the form (vl_name1 = vl_name2 vl_name3 ...), where vl_name# " ///
		"is the name of the sheet and name# is the name of the value label." 
		exit 198
	}
}

end


program define check_args

syntax, new(string) old(string)

local new = trim("`new'")
local old = trim("`old'")

if substr("`new'", 1, 3) != "vl_" {
	di 
	di as error "`new' is not a valid sheet name. Expressions should be of" ///
	" the form (vl_name1 = vl_name2 vl_name3 ...), where vl_name# " ///
	"is the name of the sheet and name# is the name of the value label." 
	exit 198
}
foreach sheet in `old' {
	if substr("`sheet'", 1, 3) != "vl_" {
		di
		di as error "`sheet' is not a valid sheet name. Expressions should be of" ///
		" the form (vl_name1 = vl_name2 vl_name3 ...), where vl_name# " ///
		"is the name of the sheet and name# is the name of the value label."
		exit 198		
	}
}


end


program define check_existing_sheets

syntax, file(string) sheets(string)

qui import excel using "`file'", describe
foreach sheet in `sheets' {
	forvalues i = 1/`r(N_worksheet)' {
		if "`sheet'" == "`r(worksheet_`i')'" {
			di as error `"worksheet `sheet' already exists"'
			exit 602
		}
	}
}

end


program define merge_sheets

syntax, meta(string) new(string) old(string) [keep]

di
di as text "merging worksheets " as result "`old'"

tempname mergefr
frame create `mergefr'
frame `mergefr' {
	tempfile temp
	foreach sheet in `old' {
		qui import excel using "`meta'", sheet("`sheet'") first clear
		cap drop file*
		cap append using `temp'
		quietly {
			bysort value label: keep if _n == 1
		}
		qui save `temp', replace
	}
	cap keep value label obs 
	if _rc keep value label
	qui export excel using "`meta'", sheet("`new'", replace) first(var)
}

di 
di as text "worksheet " as result "`new'" as text " created"

update_vars_vl, meta(`meta') new(`new') old(`old')

frame drop `mergefr'

if trim("`keep'") == "" {
    di 
	di as text "removing worksheets " as result "`old'"
	mata: delete_sheets("`old'", "`meta'")
}

end


program define update_vars_vl

syntax, meta(string) new(string) old(string)

tempname updatefr
frame create `updatefr'
frame `updatefr' {
	qui import excel using "`meta'", sheet("variables") first clear
	local vl_new = substr("`new'", 4, .)
	foreach sheet in `old' {
		local vl_old = substr("`sheet'", 4, .)
		foreach var of varlist value_label* {
			qui replace `var' = "`vl_new'" if `var' == "`vl_old'"
		}		
	}
	qui export excel using "`meta'", sheet("variables", replace) first(var)
}

frame drop `updatefr'

end


mata:

void delete_sheets(string scalar sheets, string scalar meta)
{	
	class xl scalar book
	book = xl()
	book.load_book(meta)
	sh = tokens(sheets)
	for (i=1; i<=length(sh); i++) {
		book.delete_sheet(sh[i])
	}
	book.close_book()
}

end