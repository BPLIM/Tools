*! version 0.1 2Dec2022
/* Programmed by Gustavo Iglésias
* Dependencies: filelist
* Compares ado-files versions
*/

program define adocompare

version 15

syntax,  First(string)  /// path or file produced by command adoversion
	Second(string) [    ///	path or file produced by command adoversion
	SAVE(string) 		/// Excel report 
	FORCE 				/// Drop duplicated ados found in `first` and `second`
	ALL                 /// Include ados with the same version in the report
]

	
local firsexcel "`first'"
local secondexcel "`second'"

cap label drop comparelbl

cap which filelist
if _rc {
    di "{err:Please install command {bf:filelist}}"
	exit 199
}

* Ados version pattern
local pattern "[0-9][0-9]?\.[0-9]+(\.[0-9]+)?"

cap rm "_first.txt"
cap rm "_second.txt"

* Parse save argument
if trim("`save'") == "" {
	local save "adocompare.xlsx"
	cap confirm file "`save'"
	if !_rc {
		di `"{err:File "`save'" already exists. Please specify }"' ///
		`"{err:option {bf:save} to save the file under a different name}"'
		exit 602
	}
}
else {
	gettoken save replacesave: save, p(",")
	local save = trim("`save'")
	local save "`save'.xlsx"
	gettoken lixo replacesave: replacesave, p(",")
	cap confirm file "`save'"
	if !_rc & trim("`replacesave'") != "replace" {
		di `"{err:File "`save'" already exists. Please specify }"' ///
		`"{err:sub-option {bf:replace} to overwrite the existing file}"'
		exit 602
	}
	else {
		cap rm "`save'"
	}
}
* Parse first and second inputs
foreach input in first second {
	parse_input, arg("``input''") name("`input'") ///
		pattern("`pattern'")
	local `input' = `"`r(file)'"'
}

tempfile _merge 

gen_merge_file, first("`first'") second("`second'") outfile(`_merge') `force'

write_report, first("`firsexcel'") second("`secondexcel'") ///
	comp(`_merge') save(`save') `includesame'

cap rm "_first.txt"
cap rm "_second.txt"

di

end


program define write_report

syntax, first(str) second(str) comp(str) save(str) [includesame]

local time = subinstr("`c(current_time)'", ":", "-", 2)
local date: di %tdCCYY-NN-DD date("`c(current_date)'", "DMY")

preserve
	use "`comp'", clear
	cap putexcel save
	quietly {
		putexcel set "`save'", open replace sheet("Summary")
		putexcel A2 = "Date", bold
		putexcel A3 = "Time", bold
		putexcel A4 = "First", bold
		putexcel A5 = "Second", bold
		putexcel B2 = "`date'"
		putexcel B3 = "`time'"
		putexcel B4 = "`first'"
		putexcel B5 = "`second'"	
		putexcel A7 = "Summary", bold
		putexcel A8 = "first only", bold
		putexcel A9 = "second only", bold
		putexcel A10 = "equal version", bold
		putexcel A11 = "different version", bold
		forvalues i = 1/4 {
			count if _compare == `i'
			local j = `i' + 7
			putexcel B`j' = "`r(N)'"
		}
	}
	putexcel save
	forvalues i = 1/4 {
		if (`i' == 3 & "`includesame'" != "includesame") continue
		qui count if _compare == `i'
		if `r(N)' {
			write_sheet_report, save("`save'")	cat(`i')		
		}
	}
restore

end


program define write_sheet_report

syntax, save(str) [cat(int 1)]

preserve
	qui keep if _compare == `cat'
	tempvar strcat
	qui decode _compare, gen(`strcat')
	local stringcat = `strcat'[1]
	drop _compare `strcat'
	if inlist(`cat', 1, 3) {
		keep ado version_first
		rename version_first version
		qui export excel using "`save'", sheet("`stringcat'", replace) first(var)
	}
	if `cat' == 2 {
		keep ado version_second
		rename version_second version
		qui export excel using "`save'", sheet("`stringcat'", replace) first(var)		
	}
	if `cat' == 4 {
		qui export excel using "`save'", sheet("`stringcat'", replace) first(var)		
	}

end


program define gen_merge_file 

syntax, first(str) second(str) outfile(str) [force]

preserve
	tempvar _merge
	foreach path in first second {
		tempfile tmp`path'
		quietly {
			import delimited "``path''", varnames(nonames) rowrange(2) clear
			tempvar NN
			split v1, p("-") gen(stub)
			drop v1
			rename (stub1 stub2) (ado version_`path')
			replace ado = trim(ado)
			replace version_`path' = trim(version_`path')
			drop if missing(ado)
			bysort ado: gen `NN' = _N 
			count if `NN' > 1
			drop `NN'
			if `r(N)' {
				if "`force'" == "force" {
					bysort ado (version_`path'): keep if _n == _N
				}
				else {
					cap rm "_first.txt"
					cap rm "_second.txt"
					noi di "{err:Multiple ados found in file/path. Specify option }" ///
					   "{err:{bf:force} to select only the last version}"
					exit 198	
				}
			}
			compress 
			save "`tmp`path''", replace
		}
	}
	qui use "`tmpfirst'"
	qui merge 1:1 ado using "`tmpsecond'", gen(`_merge') nolabel
	cap label drop _merge 
	rename `_merge' _compare
	qui replace _compare = 3 if _compare == 3 & ///
		(version_first == version_second)
	qui replace _compare = 4 if _compare == 3 & ///
		(version_first != version_second) 
	label define comparelbl 1 "first only" 2 "second only" ///
		3 "equal version" 4 "different version" 
	label values _compare comparelbl
	qui save "`outfile'", replace
restore

end 


program define parse_input, rclass

syntax, arg(str) name(str) [pattern(str)]

if substr(`"`arg'"', -4, .) == ".txt" {
	cap confirm file `"`arg'"'
	local rc = _rc 
	if _rc {
		cap rm "_first.txt"
		cap rm "_second.txt"
		di "{err:File {bf:`arg'} not found}"
		exit 601		
	}
	return local file `"`arg'"'
}
else {
	if inlist("`arg'", "PLUS", "BASE", "PERSONAL", "SITE") {
		local arglower = strlower("`arg'")
		local arg = "`c(sysdir_`arglower')'"
	}
	if "`arg'" == "CWD" {
		local arg: pwd
	}
	mata: st_numscalar("direxists", direxists("`arg'"))
	if !scalar(direxists) {
		cap rm "_first.txt"
		cap rm "_second.txt"
		di "{err:Directory {bf:`arg'} not found}"
		exit 601
	}
	preserve
		set_mata,                   ///
			path("`arg'")           ///
			path_name("_`name'")    ///
			pattern("`pattern'")	
		return local file "_`name'.txt"
	restore
}

end

program define set_mata

/*Sets the mata routine to find the version of the ados
for each path searched*/

syntax, [              ///
	path(string)       /// path for ados
	path_name(string)  /// name of the path for ados 
	pattern(string)    /// ados version pattern
	lines(int 10)      /// maximum lines searched 
]


local outfile "`path_name'.txt"
qui filelist , dir("`path'") pattern(*.ado) replace
qui count 
if r(N) {
	mata: write_ados_version("`outfile'", "`path'", "`pattern'", `lines')
}
else {
	di "{err:No ados found in {bf:`path'}}" 
	exit 198 
}	

end


mata:


string scalar get_version( ///
	string scalar file,    /// ado file
	string scalar pattern, /// ados version pattern
	numeric scalar max     /// maximum lines searched 
)
{	/* Returns the version of an ado based on a regular
    expression. See pattern in the beginning*/
    numeric scalar i
	string scalar str 
	numeric scalar version_num
	str = ""
    fh = fopen(file, "r")
	i = 0
	while (1) {
	    line = strltrim(fget(fh))
		// If fget returns none
		if (line == J(0,0,"")) {
		    version_num = 0
			break
		}
		if (substr(line, 1, 2) == "*!") {
		    str = str + " " + strltrim(substr(line, 3, .))
			version_num = regexm(line, pattern)
			if (version_num == 1) break
		}
		if (i == max) break 
		i++
	}
	fclose(fh)
	if (version_num == 1) {
	    return(regexs(0))
	}
	else {
	    return("")
	}
}


void write_file(           ///
	string scalar outfile, /// text file
	string scalar path,    /// path searched
	string matrix content  /// matrix with contents (ados and version info)
)
{	/* Writes the contents of a string matrix to a text file */
	fh_out = fopen(outfile, "w")
	fput(fh_out, "Ado path: " + path)
	fput(fh_out, "")
	fput(fh_out, "")
	fput(fh_out, "")
	for (i=1; i<=length(content); i++) {
	    if (i == 1)	{
			fput(fh_out, content[i])
		}
		else if (substr(content[i], 1, 1) == substr(content[i-1], 1, 1)) {
		    fput(fh_out, content[i])
		}
		else {
		    // Two blank lines when the first letter changes
			fput(fh_out, "")
			fput(fh_out, "")	
			fput(fh_out, content[i])
		}
	}
	fclose(fh_out)
}


void write_ados_version(    ///
	string scalar outfile,  /// text file
	string scalar path,     /// path searched
	string scalar pattern,  /// ados version pattern
	numeric scalar max      /// maximum lines searched
)
{	/* Creates a string matrix with information about ados
    and their version. This information is collected from a 
	stata dataset created by command `filelist`*/
    numeric scalar i
    string matrix DIR, FILES, FILESLONG, VERSION, ADOS, FINAL_STR
	// Directory matrix
    DIR = st_sdata(.,"dirname")
	// File matrix
	FILES = st_sdata(.,"filename")
	// Create version matrix -> empty
	VERSION = J(length(FILES), 1, "")
	// Matrix with files and full path
	FILESLONG = DIR :+ "/" :+ FILES
	// Fill in version matrix
	for (i=1; i<=length(FILESLONG); i++) {
	    VERSION[i] = get_version(FILESLONG[i], pattern, max)
	}
	// Ados matrix with removed extension
	ADOS = subinstr(FILES, ".ado", "", 1)
	// Matrix created to align ados and version in the text file
	SPACE = (max(strlen(ADOS)) :- strlen(ADOS)) :* " " :+ " - "
	// Output matrix
	FINAL_STR = sort(ADOS + SPACE + VERSION, 1)
	
	write_file(outfile, path, FINAL_STR)
}


end