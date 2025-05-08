*! 0.2 20Feb2024
* Programmed by Gustavo Iglésias
* Dependencies: 
*	charlist
*   jarowinkler
*   labmask


program define validarcpp, sortpreserve

syntax varname [if], [ ///
	Class(int 2010) solve(str) getlevels(str) ///
	SIMilarity(str) fromlabel keep ///
]

if !inlist(`class', 1980, 1994, 2010) {
	di as error `"`class' is not a valid argument for option "class"."' ///
		" Possible values are 1980, 1994 and 2010"
	exit 198
}

foreach command in charlist labmask {
	cap which `command'
	if _rc {
		di as error "Please install `command' in order to use this command"
		exit _rc
	}
}

if ("`solve'" != "") {
	cap which jarowinkler
	if _rc {
		di "{err:Option {bf:solve} requires command {bf:jarowinkler}}"
		exit 111
	}
}

if ("`similarity'" != "") {
	cap which jarowinkler
	if _rc {
		di "{err:Option {bf:similarity} requires command {bf:jarowinkler}}"
		exit 111
	}
}



global cpp__ "`varlist'"
global class__ `class'
cap drop __cpp__
cap drop __level__*
cap drop _valid_cpp_`class'

if "`fromlabel'" == "fromlabel" {
	qui decode `varlist', gen(__cpp__)
	qui replace __cpp__ = word(__cpp__, 1)
	qui charlist __cpp__
	if (strpos("`r(chars)'", ".") | strpos("`r(chars)'", "-")) {
		local has_punct 1
	}
	else {
		local has_punct 0
	}
}
else if substr("`: type `varlist''", 1, 3) == "str" {
	qui clonevar __cpp__ = `varlist'
	qui charlist __cpp__
	if (strpos("`r(chars)'", ".") | strpos("`r(chars)'", "-")) {
		local has_punct 1
	}
	else {
		local has_punct 0
	}
} 
else {
	qui tostring `varlist', gen(__cpp__)
	local has_punct 0
}

di 
di as text "Variable " as result "`varlist'" as text " is " ///
	as result "`: type `varlist''"
di 
if `class' == 2010 {
	di as text "Checking compatibility with " as result "CPP/`class'"
}
else {
	di as text "Checking compatibility with " as result "CNP/`class'"
}

tempfile temp

preserve
	read_master, fout(`temp') has_punct(`has_punct') class(`class')
restore

if `has_punct' {
	validate_p __cpp__, master(`temp') class(`class')
} 
else {
	if "`solve'" != "" {
		parse_solve, solve(`solve')
		local solvevar "`r(solvevar)'"
		local solveth `r(solveth)'
		local _solved "`r(_solved)'"
		local eng "`r(eng)'"
		if ("`eng'" == "eng" & inlist(`class', 1980, 1994)) {
			di as error `"Sub-option "en" may only be specified with class 2010"'
			exit 198
		}
		validate_np __cpp__, master(`temp') class(`class') ///
			solvevar(`solvevar') th(`solveth') `eng'
		qui replace __cpp__ = "0" + __cpp__ if /// 
				inlist(_valid_cpp_`class', 11, 21, 31, 41, 51)				
	}
	else {
		validate_np __cpp__, master(`temp') class(`class')
		qui replace __cpp__ = "0" + __cpp__ if /// 
			inlist(_valid_cpp_`class', 11, 21, 31, 41, 51)
	}
}

if trim("`similarity'") != "" {
	tempvar valid_cpp
	qui clonevar `valid_cpp' = __cpp__
	
	if `has_punct' {
		validate_desc `valid_cpp' if _valid_cpp_`class' > 0, ///
			varg(`similarity') has_punct(`has_punct')		
	}
	else {
		qui replace `valid_cpp' = "0" + `valid_cpp' if ///
			inlist(_valid_cpp_`class', 11, 21, 31, 41, 51)
		validate_desc `valid_cpp' if ///
			inlist(_valid_cpp_`class', 1, 11, 2, 21, 3, 31, 4, 41, 5), ///
			varg(`similarity') has_punct(`has_punct')	
	}

		
	cap drop `valid_cpp'
}


if "`getlevels'" != "" {
	cap which labmask
	if _rc {
		di as error "Option getlevels requires command labmask"
		exit _rc
	}
	getlevelsparser, getlevels(`getlevels')
	local levels = "`r(levels)'"
	local en = "`r(en)'"
	local force = "`r(force)'"
	getlevels __cpp__, levels(`levels') has_punct(`has_punct') ///
		`en' `force' 
	qui count if inlist(_valid_cpp_`class', 12, 22, 32, 42, 52)
	if `r(N)' {
		di 
		di as result "`r(N)' " as text "codes not converted due to " ///
			"ambiguities"
	}
}

if "`keep'" != "keep" {
	cap drop __cpp__
}

cap drop __level__*	

end


program define read_master

/*
Read master file to merge with cpp codes
*/

syntax, fout(string) [has_punct(int 0) class(int 2010)]

tempname cpp des level 

mata: st_local("cppfile", findfile("cpp.csv"))

qui import delimited "`cppfile'", encoding(UTF-8) clear 

drop des*
	
qui keep if class == `class'
drop class

/*
if !`has_punct' {
	qui charlist code
	while (strpos("`r(chars)'", ".") | strpos("`r(chars)'", "-")) {
		qui replace code = subinstr(code, ".", "", 1)
		qui replace code = subinstr(code, "-", "", 1)
		qui charlist code
	}
}*/

if `has_punct' {
	drop code_np
	rename (code level) (__cpp__ __level__)
}
else {
	drop code
	rename (code_np level) (__cpp__ __level__)	
}

qui save `fout', replace

end 


program define validate_desc

syntax varname(str) [if], varg(str) [has_punct(int 0)] 


parse_sim, sim(`varg')
local simvar "`r(simvar)'"
local simlg "`r(simlg)'"
confirm string var `simvar'
if ("`simlg'" == "en" & inlist(${class__}, 1980, 1994)) {
	di 
	di as error `"Sub-option "en" may only be specified with class 2010"'
	exit 198
}

di 
di "{text:Calculating Jaro-Winkler similarity between {bf:`simvar'}} " ///
   "{text:and official labels}"


if `has_punct' {
	local fvar "code"
}
else {
	local fvar "code_np"
}

tempfile temp

mata: st_local("cppfile", findfile("cpp.csv"))

preserve 
	qui import delimited "`cppfile'", encoding(UTF-8) clear 
	qui keep if class == ${class__}
	qui save `temp', replace
restore

if "`eng'" == "eng" {
	jw_sim `varlist' `if', ///
		vardesc(`simvar') file(`temp') vars(`fvar' des_en) 
}
else {
	jw_sim `varlist' `if', ///
		vardesc(`simvar') file(`temp') vars(`fvar' des_pt) 
}


end


program define parse_sim, rclass 

syntax, sim(string)

gettoken simvar simopt: sim, p(",")
gettoken lixo simopt: simopt, p(",")
local simopt = trim("`simopt'")
confirm var `simvar'
return local simvar `simvar'
if "`simopt'" == "en" {
	return local simlg "en"
}
else {
	return local simlg "pt"
}

end


program define validate_p

/*
Validate cpp codes with punctuation. This validation is simpler, because
there are no ambiguities
*/

syntax varname, master(string) [class(int 2010)]

tempvar _merge
cap label drop vlvalid

qui merge m:1 `varlist' using "`master'", gen(`_merge')
qui drop if `_merge' == 2
qui gen _valid_cpp_`class' = 0 if `_merge' == 1
forvalues i = 1/5 {
	qui replace _valid_cpp_`class' = `i' if __level__ == `i' & `_merge' == 3
}
qui replace _valid_cpp_`class' = -99 if missing(${cpp__})
* Label values  
label define vlvalid 0 "0 Invalid"
label define vlvalid -99 "-99 Missing", add
forvalues i = 1/5 {
	label define vlvalid `i' "`i' Valid - Level `i'", add
}
label values _valid_cpp_`class' vlvalid
tab _valid_cpp_`class'

end


program define validate_np

/*
Validate cpp codes without punctuation. This validation is more complex, since
we must take into account cases where codes might be valid with or without leading
zeros
*/

syntax varname, master(string) [class(int 2010) solvevar(str) th(real 0.7) eng]

tempvar _m1 _m2 temp
cap label drop vlvalid

qui clonevar `temp' = `varlist'
* merge on the original code
qui merge m:1 `varlist' using "`master'", gen(`_m1')		
qui drop if `_m1' == 2
rename __level__ __level__1
qui replace `varlist' = "0" + `varlist'
* merge on the code preceeded by a 0
qui merge m:1 `varlist' using "`master'", gen(`_m2') 				
qui drop if `_m2' == 2
rename __level__ __level__2
* Validate 
qui gen byte _valid_cpp_`class' = 0 if (`_m1' == 1 & `_m2' == 1)
forvalues i = 1/5 {
    local j = `i' + 1
	* Valid at i digits only
	qui replace _valid_cpp_`class' = `i' if (`_m1' == 3 & `_m2' == 1) ///
		& __level__1 == `i'
	* Valid at i + 1 digits (0 + i digits)
	qui replace _valid_cpp_`class' = `i'1 if (`_m1' == 1 & `_m2' == 3) ///
		& __level__2 == `j'
	* Valid at i digits only or i + 1 digits (0 + i digits)
	qui replace _valid_cpp_`class' = `i'2 if (`_m1' == 3 & `_m2' == 3) ///
		& __level__1 == `i' & __level__2 == `j'
}
qui replace `varlist' = substr(`varlist', 2, .)
* Solve ambiguities 
if trim("`solvevar'") != "" {
	qui count if inlist(_valid_cpp_`class', 12, 22, 32, 42, 52)
	if `r(N)' {
		solve_valid `varlist' if inlist(_valid_cpp_`class', 12, 22, 32, 42, 52), ///
			solvevar(`solvevar') valid(_valid_cpp_`class') th(`th') `eng'		
	}
	else {
		di 
		di "No ambiguities to solve"
	}

}	
qui replace _valid_cpp_`class' = -99 if missing(${cpp__})
* Label values 
label define vlvalid 0 "0 Invalid"
label define vlvalid -99 "-99 Missing", add
forvalues i = 1/5 {
	local j = `i' + 1
	label define vlvalid `i' "`i' Valid - Level `i'", add
	label define vlvalid `i'1 "`i'1 Valid - Level `j' (0 + code)", add
	label define vlvalid `i'2 ///
		"`i'2 Valid - Level `i' | Level `j' (0 + code)", add
}

label values _valid_cpp_`class' vlvalid
tab _valid_cpp_`class'

qui drop `_m1' `_m2'
drop `varlist'
rename `temp' `varlist'

end


program define parse_solve, rclass

syntax, solve(string)

gettoken solvevar solveopt: solve, p(",")
gettoken lixo solveopt: solveopt, p(",")
local solveopt = trim("`solveopt'")
confirm string var `solvevar'
if "`solveopt'" == "" {
	local solveth 0.7
}
else {
	if strpos("`solveopt'", "en") {
		local eng "eng"
		local solveth = trim(subinstr("`solveopt'", "en", "", 1))
		if "`solveth'" == "" {
			local solveth 0.7
		}
	}
	else {
		local solveopt = trim("`solveopt'")
		local solveth `solveopt'
	}
}
if `solveth' > 1 | `solveth' < 0 {
	di as error "Threshold for solving ambiguities must be between 0 and 1"
	exit 198
}
local _solved "_solv"

return local solvevar `solvevar'
return local solveth `solveth'
return local _solved `_solved'
return local eng `eng'

end


program define solve_valid

syntax varlist [if], valid(str) solvevar(str) [th(real 0.7) eng]

tempfile temp

mata: st_local("cppfile", findfile("cpp.csv"))

preserve 
	qui import delimited "`cppfile'", encoding(UTF-8) clear 
	qui keep if class == ${class__}
	qui save `temp', replace
restore


if "`eng'" == "eng" {
	cpp_solve `varlist' `if', ///
		vardesc(`solvevar') file(`temp') vars(code_np des_en) th(`th')		
}
else {
	cpp_solve `varlist' `if', ///
		vardesc(`solvevar') file(`temp') vars(code_np des_pt) th(`th')		
}

qui replace `varlist' = _sug_code `if' & _solved == 1
qui drop _sug_code
forvalues i = 1/5 {
	qui replace `valid' = `i' if `valid' == `i'2 & ///
		substr(`varlist', 1, 1) != "0" & _solved == 1
	qui replace `valid' = `i'1 if `valid' == `i'2 & ///
		substr(`varlist', 1, 1) == "0" & _solved == 1
}

qui count if _solved == 1
di 
di as result "`r(N)'" as text " ambiguities solved using variable " ///
	as result "`solvevar'" as text " and threshold " as result "`th'"

qui count if inlist(_solved, 0, 1)
if `r(N)' {
	tab _solved 
}

end


program define cpp_solve

syntax varname [if], vardesc(string) file(string) vars(string) [th(real 0.7)]


local ifnot = "!(" + trim(substr(trim("`if'"), 3, .)) + ")"


tempvar code desc code0 des des0 _merge d d0 pdis len0 len1 len dis
tempvar NN0 NN1 nn
tempfile tempf 
quietly {
    bysort `varlist': gen `NN0' = _N
	bysort `varlist' `vardesc': gen `NN1' = _N 
	bysort `varlist' `vardesc': gen `nn' = _n
}
cap assert `NN0' == `NN1'
if _rc {
    di 
	di as result "Warning: `vardesc'" as text " not constant within groups of" ///
		as result " ${cpp__}"
}
drop `NN0' `NN1'

cap drop _sug_code
cap drop _solved
cap label drop solvedlbl

qui clonevar `code' = `varlist'
qui clonevar `desc' = `vardesc'
qui replace `desc' = trim(ustrlower(`desc'))
qui gen `code0' = "0" + `code'

preserve
	qui use "`file'", clear
	keep `vars'
	rename (`vars') (`code' `des')
	qui replace `des' = trim(ustrlower(`des'))
	qui save `tempf', replace
restore

qui merge m:1 `code' using `tempf', gen(`_merge')
qui drop if `_merge' == 2
drop `_merge'

preserve
	qui use "`file'", clear
	keep `vars'
	rename (`vars') (`code0' `des0')
	qui replace `des0' = trim(ustrlower(`des0'))
	qui save `tempf', replace
restore

qui merge m:1 `code0' using `tempf', gen(`_merge')
qui drop if `_merge' == 2
drop `_merge'

quietly {
	jarowinkler `desc' `des', gen(`d')
	replace `d' = . if `ifnot' | `nn' != 1
	bysort `varlist' `vardesc' (`d'): replace `d' = `d'[1]
	jarowinkler `desc' `des0', gen(`d0')
	replace `d0' = . if `ifnot' | `nn' != 1
	bysort `varlist' `vardesc' (`d0'): replace `d0' = `d0'[1]
}
drop `nn'

* Keep the best match
qui replace `code' = cond(`d' > `d0', `code', `code0')
qui replace `des' = cond(`d' > `d0', `des', `des0')
qui gen `dis' = cond(`d' > `d0', `d', `d0')
drop `code0' `des0' `d' `d0'

rename `code' _sug_code

drop `desc'

qui replace _sug_code = "" if `dis' < `th' | `ifnot'
qui gen _solved = 1
qui replace _solved = 0 if `dis' < `th'
qui replace _solved = . if `ifnot'
label define solvedlbl 0 "0 unsolved for threshold = `th'" 1 "1 solved"
label values _solved solvedlbl

qui compress _sug_code

end


program define jw_sim

syntax varname [if/], vardesc(string) file(string) vars(string)

tempvar vardec code desc des _merge d nn NN0 NN1

tempfile tempf 
quietly {
    bysort `varlist': gen `NN0' = _N
	bysort `varlist' `vardesc': gen `NN1' = _N 
	bysort `varlist' `vardesc': gen `nn' = _n
}
cap assert `NN0' == `NN1'
if _rc {
    di 
	di as result "Warning: `vardesc'" as text " not constant within groups of" ///
		as result " ${cpp__}"
}

drop `NN0' `NN1'

cap drop _jwsim_class_${class__}  

qui clonevar `code' = `varlist'
qui clonevar `desc' = `vardesc'
qui replace `desc' = trim(ustrlower(`desc'))

preserve
	qui use "`file'", clear
	keep `vars'
	rename (`vars') (`code' `des')
	qui replace `des' = trim(ustrlower(`des'))
	qui save `tempf', replace
restore

qui merge m:1 `code' using `tempf', gen(`_merge')
qui drop if `_merge' == 2
drop `_merge'

quietly {
	jarowinkler `desc' `des', gen(`d')
	replace `d' = .  if `nn' != 1
	bysort `varlist' `vardesc' (`d'): replace `d' = `d'[1]
}
drop `nn' `code' `desc'

qui rename `d' _jwsim_class_${class__}
qui replace _jwsim_class_${class__} = . if !(`if')


end


program define getlevelsparser, rclass

syntax, getlevels(string)

local pos = strpos(`"`getlevels'"',",")
if `pos' == 0 {
	return local levels = `"`getlevels'"'
	return local force = ""
	return local en = ""
}
else {
	local first = substr(`"`getlevels'"',1,`pos'-1)
	return local levels = `"`first'"'
	local second = substr(`"`getlevels'"',`pos'+1,.)
	if strpos(`"`second'"',"en") {
		return local en = "en"
	}
	else {
		return local en = ""
	}
	if strpos(`"`second'"',"force") {
		return local force = "force"
	}
	else {
		return local force = ""
	}
}

end


program define getlevels

syntax varname, levels(str) [has_punct(int 0) en force]

tempfile templevels
tempvar _merge

checklevels, levels(`levels')

if inlist(${class__}, 1980, 1994) & "`en'" == "en" {
	di 
	di as result "Warning: " as text "sub-option " as result "en" ///
		as text " may only be specified with class 2010. Value labels set" ///
		" to Portuguese"

}

preserve
	create_merge_file `varlist', fout(`templevels') levels(`levels') ///
		has_punct(`has_punct') `en'
restore
	

qui merge m:1 `varlist' using `templevels', gen(`_merge')
qui drop if `_merge' == 2
drop `_merge'
if "`force'" != "force" {
	foreach lev in `levels' {
		if ${class__} == 2010 {
			qui replace cpp2010_level`lev' = . if ///
				inlist(_valid_cpp_${class__}, 12, 22, 32, 42, 52)
		}
		else {
			qui replace cnp${class__}_level`lev' = . if ///
				inlist(_valid_cpp_${class__}, 12, 22, 32, 42, 52)
		}		
	}
}

label_vars, levels(`levels') `en'

end


program define label_vars

syntax, levels(str) [en]

local vv = cond(inlist(${class__}, 1980, 1994), "cnp", "cpp")
local VV = strupper("`vv'")
local major_group = cond("`en'" == "en", "Major Group", "Grande Grupo")
local sub_major_group = cond("`en'" == "en", "Sub-Major Group", "Sub-Grande Grupo")
local minor_group = cond("`en'" == "en", "Minor Group", "Sub-Grupo")
local unit_group = cond("`en'" == "en", "Unit Group", "Grupo Base")
local occupation = cond("`en'" == "en", "Occupation", "Profissão")


foreach lev in `levels' {
	if `lev' == 1 {
		label var `vv'${class__}_level`lev' ///
			"`VV' ${class__} - `major_group'"
	}
	else if `lev' == 2 {
		if ${class__} == 1980 {
			label var `vv'${class__}_level`lev' ///
				"`VV' ${class__} - `minor_group'"				
		}
		else {
			label var `vv'${class__}_level`lev' ///
				"`VV' ${class__} - `sub_major_group'"
		}
	}
	else if `lev' == 3 {
		if ${class__} == 1980 {
			label var `vv'${class__}_level`lev' ///
				"`VV' ${class__} - `unit_group'"				
		}
		else {
			label var `vv'${class__}_level`lev' ///
				"`VV' ${class__} - `minor_group'"
		}
	}
	else if `lev' == 4 {
		if ${class__} == 1980 {
			label var `vv'${class__}_level`lev' ///
				"`VV' ${class__} - `occupation'"				
		}
		else {
			label var `vv'${class__}_level`lev' ///
				"`VV' ${class__} - `unit_group'"
		}
	}
	else {
		label var `vv'${class__}_level`lev' ///
			"`VV' ${class__} - `occupation'"
	}
}	

end 


program define create_merge_file

syntax varname, fout(str) levels(str) [has_punct(int 0) en]

local merge_var = cond(`has_punct', "code", "code_np")

local vars_to_keep "`varlist'"
foreach lev in `levels' {
	local vars_to_keep = "`vars_to_keep'" + " level`lev'"
}

mata: st_local("cpplevels", findfile("cpp_final.csv"))

qui import delimited "`cpplevels'", encoding(UTF-8) clear
qui keep if class == ${class__}
rename `merge_var' `varlist'
foreach lev in `levels' {
	tempname lbl`lev'
	preserve
		cap label drop lbllevel`lev'
		if ("`en'" == "en" & ${class__} == 2010) {
			keep level`lev' desen`lev'
			quietly {
				bysort level`lev' desen`lev': keep if _n == 1
			}
			qui labmask level`lev', val(desen`lev') lbl(lbllevel`lev')
			drop desen`lev'
			qui label save lbllevel`lev' using `lbl`lev''
		}
		else {
			keep level`lev' despt`lev'
			quietly {
				bysort level`lev' despt`lev': keep if _n == 1
			}
			qui labmask level`lev', val(despt`lev') lbl(lbllevel`lev')
			drop despt`lev'		
			qui label save lbllevel`lev' using `lbl`lev''
		}
	restore
	run `lbl`lev''.do 
	cap rm `lbl`lev''.do
	label values level`lev' lbllevel`lev'
}
keep `vars_to_keep'
if ${class__} == 2010 {
	rename level* cpp2010_level*
}
else {
	rename level* cnp${class__}_level*
}
qui save `fout', replace



end


program define checklevels

syntax, levels(str)

if trim("`levels'") == "" {
	di as error `"Option "getlevels" wrongly specified"'
	exit 198
}
local levelscount: word count `levels'
if ${class__} == 1980 {
	if `levelscount' > 4 {
		di as error "CNP/1980 only admits 4 levels"
		error 198
	}
	foreach item in `levels' {
		if !inlist(`item', 1, 2, 3, 4) {
			di as error "CNP/1980 only admits 4 values for levels: " ///
				"1, 2, 3 and 4"
			error 198			
		}
	}
}
else {
	local rev = cond(${class__} == 1994, "CNP/1994", "CPP/2010")
	if `levelscount' > 5 {
		di as error "`rev' only admits 5 levels"
		error 198
	}
	foreach item in `levels' {
		if !inlist(`item', 1, 2, 3, 4, 5) {
			di as error "`rev' only admits 5 values for levels: " ///
				"1, 2, 3, 4 and 5"
			error 198			
		}
	}
}

end
