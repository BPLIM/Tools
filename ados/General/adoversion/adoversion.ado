*! version 0.1 26Jul2021
/* Programmed by Gustavo Iglésias
* Dependencies: filelist
* Creates text files with ados and their respective version. One file
* is created per path returned by command adopath. The paths are searched
* in the order that adopath returns. This order may be used to search only 
* specific paths or exclude specific paths*/

program define adoversion

version 13

syntax, [           ///
	OUTpath(string) /// path for text files
	INClude(string) /// search only numlist found in this option 
	EXClude(string) /// exclude numlist found in this option
]

cap which filelist
if _rc {
    di as error "Please install command filelist"
	exit 199
}

* Ados version pattern
local pattern "[0-9][0-9]?\.[0-9]+(\.[0-9]+)?"

local cwd: pwd

di

* Path for text files (default is working dir)
if ("`outpath'" == "") local outpath "`cwd'"

* Error -> include and exclude cannot be combined
if ("`include'" != "" & "`exclude'" != "") {
    di as error `"Options "include" and "exclude" cannot be combined"'
	exit 198
}

* Ado paths names
local adopath = subinstr(`"`c(adopath)'"', ";", " ", 50)
local i = 1
local numlist = ""
foreach path_name in `adopath' {
    local path`i' = `"`path_name'"'
	local numlist = "`numlist'" + " `i'"
	local ++i
}
if ("`include'" != "") local numlist "`include'"
if ("`exclude'" != "") {
    local numlist: list numlist - exclude
}

preserve
	local i = 1
	foreach num in `numlist' {
		if inlist("`path`num''", "BASE", "SITE", "PLUS", "PERSONAL", "OLDPLACE") {
			local pathlow = strlower("`path`num''")
			di as result `"Checking ados in "`c(sysdir_`pathlow')'" [`num']"'
			if "`c(sysdir_`pathlow')'" == "" {
				di as error `"No adopath defined for "`path`num''""'
				di 
			}
			else {
				local path = "`c(sysdir_`pathlow')'"
				set_mata,                    ///
					path("`path'")           ///
					path_name("`path`num''") ///
					outpath("`outpath'")     ///
					pattern("`pattern'")
			}
		}
		else if "`path`num''" == "." {
			di as result `"Checking ados in "`cwd'" [`num']"'
			set_mata,            	 ///
				path("`cwd'")        ///
				path_name("CWD")     ///
				outpath("`outpath'") ///
				pattern("`pattern'")
		}
		else {
			di as result `"Checking ados in "`path`num''" [`num']"'
			set_mata,                ///
				path("`path`num''")  ///
				path_name("MORE`i'") ///
				outpath("`outpath'") ///
				pattern("`pattern'")
			local ++i
		}
	}
restore

end

program define set_mata

/*Sets the mata routine to find the version of the ados
for each path searched*/

syntax, [              ///
	path(string)       /// path for ados
	path_name(string)  /// name of the path for ados (PLUS, PERSONAL, etc.)
	outpath(string)    /// path for text files
	pattern(string)    /// ados version pattern
	lines(int 10)      /// maximum lines searched 
]

get_outfile, outpath("`outpath'") path_name("`path_name'")
local outfile "`r(outfile)'"
qui filelist , dir("`path'") pattern(*.ado) replace
qui count 
if r(N) {
	mata: write_ados_version("`outfile'", "`path'", "`pattern'", `lines')
}
else {
	di as error "No ados found in `path'" 
	di 
}	

end


program define get_outfile, rclass

/*Returns the name of the text file for each path searched*/

syntax,               /// 
	outpath(string)   /// path for text files
	path_name(string) /// name of the path for ados (PLUS, PERSONAL, etc.)

local time = subinstr("`c(current_time)'", ":", "-", 2)
local date: di %tdCCYY-NN-DD date("`c(current_date)'", "DMY")

ret local outfile = "`outpath'/`path_name'_`date'_`time'.txt"


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
	printf(outfile + " created\n\n")
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
    string matrix DIR, FILES, FILESLONG, VERSION, ADOS, SPACE, FINAL_STR
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