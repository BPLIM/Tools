*! version 1.0 14Dec2018
* Programmed by Gustavo Iglésias
* Dependencies:
* markstat (version 2.2.0 7may2018)
* package matrixtools

program define checkmd

syntax [if] [, csv_file(string) out_path(string) id(string) linesize(int 255) internal save_obs(int 50) mpz(string) inc_only merge(string) keepmd tvar(string) verbose]

version 15

preserve

	// Keeping observations that verify if condition

	if "`if'" != "" {
		global if_condition = "`if'"
		quietly keep `if'
	}
	
	checkmd_call, csv_file(`csv_file') out_path(`out_path') id(`id') linesize(`linesize') `internal' save_obs(`save_obs') mpz(`mpz') `inc_only' merge(`merge') `keepmd' tvar(`tvar') `verbose'

restore

end

program define checkmd_call

syntax [, csv_file(string) out_path(string) id(string) linesize(int 255) internal save_obs(int 50) mpz(string) inc_only merge(string) keepmd tvar(string) verbose]

// Options csv_file tell the program to perform checks as specified by the document
// Option id: when the user doesn´t specify an id, one is created inside the program (_n)
// Option out_path: if not specified, folders and files (.dta, .html, .smcl and .stmd) will be saved in the current working directory
// Option linesize sets line size in stata. The default value is 50
// Option internal specifies a person's type of access when viewing these reports. If internal is missing, the list of inconsistencies won't be displayed and the data with inconsistencies
// will not be saved
// Option save_obs specifies the number of inconsistencies to be saved. The default value is 100. This option is only allowed when option internal is active
// Option mpz creates a matrix with missing values, positive values and zeros and observations for which value labels are missing. If absent, the default matrix will contain all 
// variables in the dataset. If you want this option to be inactive, input nompz
// If option inc_only is active, the hmtl files will only display checks with inconsistent values
// verbose: shows the progress of the program 


************************************* verbose ********************************************
if "`verbose'" == "verbose" {
	di ""
	di "------------------------ begin checkmd.ado ----------------------------"
}
******************************************************************************************



// Checking if option internal is specified when the user chose option save_obs

************************************* verbose ********************************************
if "`verbose'" == "verbose" {
	di ""
	di "Checking if option internal is specified when the user chose option save_obs"
}
******************************************************************************************

if "`save_obs'" != "" & "`internal'" != "internal" {
	di as error "Option save_obs requires option internal to be active as well"
	error 1
}
else {
************************************* verbose ********************************************
	if "`verbose'" == "verbose" {
		di ""
		di "No errors to report"
	}
******************************************************************************************
}


capture quietly label language en

if `"`merge'"' != "" {

	// local with the name of the dta_file1 without the path and .dta

	local dta_file1 = subinstr("${S_FN}","\","/",100)
	local dta_file1 = subinstr("`dta_file1'",".dta","",1)
	local len = length("`dta_file1'")
	loca pos = strrpos("`dta_file1'","/")
	global dta_file1 = substr("`dta_file1'",`pos'+1,`len'-`pos')

	
	// Creating tempfile

	tempfile temp
	quietly save `temp'
	quietly use `temp', clear
	

	// Creating global merge_is_active to tell file_write to write some additional information
	
	global merge_is_active = 1


	// Program readmstr (returns information about the merge)
	
	************************************* verbose ********************************************
	if "`verbose'" == "verbose" {
		di ""
		di "Program readmstr"
		di ""
	}
	******************************************************************************************
	
	readmstr, merge(`merge') `verbose'
	
	
	// local with the name of the dta_file2 without the path
		
	local dta_file2 = subinstr("`r(file)'","\","/",100)
	local dta_file2 = subinstr("`dta_file2'",".dta","",1)
	local len = length("`dta_file2'")
	loca pos = strrpos("`dta_file2'","/")
	if regexm("`dta_file2'","/") == 1 {
		global dta_file2 = substr("`dta_file2'",`pos'+1,`len'-`pos')
	}
	else {
		global dta_file2 = "`dta_file2'"
	}

	

	
	// Creating global dta_file
	
	global dta_file = "${dta_file1}_vs_${dta_file2}"

	
	// Creating locals from returned locals by the program readmstr
	
	local fileo = "`r(file)'"
	local keyo = "`r(key)'"
	local d1_keep = "`r(keep1)'"
	local d2_keep = "`r(keep2)'"
	local typeo = "`r(type)'"
	local obso = "`r(obs_keep)'"
	
	
	// Keeping variables from the first dataset if specified by the user
	
	************************************* verbose ********************************************
	if "`verbose'" == "verbose" {
		di ""
		di "Keeping variables from the first dataset if specified by the user"
	}
	******************************************************************************************
	
	if "`d1_keep'" != "none" {
		/*foreach var in `d1_keep' {
			local d1_`var' = "d1_" + "`var'"
			local d1_keepn = "`d1_keepn'" + " `d1_`var''"
			di "`d1_keepn'"
		}*/
		keep `d1_keep' `keyo'
		if "`verbose'" == "verbose" {
			di
			di "keep `d1_keep' `keyo'"
		}
	}

	
	// Renaming variables from the first dataset (except key varibles)

	************************************* verbose ********************************************
	if "`verbose'" == "verbose" {
		di ""
		di "Renaming variables from the first dataset (except key varibles)"
	}
	******************************************************************************************
	
	quietly ds
	foreach item in `r(varlist)' {
		if regexm("`keyo'","`item'") == 0 {
			rename `item' d1_`item'
			if "`verbose'" == "verbose" {
				di ""
				di "rename `item' d1_`item'"
			}
		}
	}
	

	
	// Merge dataset 1 and dataset 2

	************************************* verbose ********************************************
	if "`verbose'" == "verbose" {
		di ""
		di "Merging dataset 1 and dataset 2"
	}
	******************************************************************************************
	
	
	if "`d2_keep'" != "none" {
		merge `typeo' `keyo' using "`fileo'", keepusing(`d2_keep')
		if "`verbose'" == "verbose" {
			di ""
			di `"merge `typeo' `keyo' using "`fileo'", keepusing(`d2_keep')"'
		}
	}
	else {
		merge `typeo' `keyo' using "`fileo'"
		if "`verbose'" == "verbose" {
			di ""
			di `"merge `typeo' `keyo' using "`fileo'""'
		}
	}
	
	
	// Renaming variables from the second dataset (except key varibles and _merge)

	************************************* verbose ********************************************
	if "`verbose'" == "verbose" {
		di ""
		di "Renaming variables from the second dataset (except key varibles and _merge)"
	}
	******************************************************************************************
	
	quietly ds
	foreach item in `r(varlist)' {
			if regexm("`item'","d1")==0 & regexm("`keyo'","`item'") == 0 & "`item'" != "_merge" {
				rename `item' d2_`item'
				if "`verbose'" == "verbose" {
					di ""
					di "rename `item' d2_`item'"
				}
			}
	}

		
	// Keeping observations if specified by the user
	
	if "`obso'" != "none" {
	
		************************************* verbose ********************************************
		if "`verbose'" == "verbose" {
			di ""
			di "Keeping observations if specified by the user"
		}
		******************************************************************************************
		local wcount: word count `obso'
		if `wcount' == 1 {
			local first: word 1 of `obso'
			keep if _merge == `first'
			if "`verbose'" == "verbose" {
				di ""
				di "keep if _merge == `first'"
			}
		}
		else if `wcount' == 2 {
			local first: word 1 of `obso'
			local second: word 2 of `obso'
			keep if _merge == `first' & _merge == `second'
			if "`verbose'" == "verbose" {
				di ""
				di "keep if _merge == `first' & _merge == `second'"
			}
		}

	}
	
	quietly drop _merge

}
else {

	global merge_is_active = 0

	// Global with the name of the dta_file without the path and .dta

	local dta_file = subinstr("${S_FN}","\","/",100)
	local dta_file = subinstr("`dta_file'",".dta","",1)
	local len = length("`dta_file'")
	loca pos = strrpos("`dta_file'","/")
	global dta_file = substr("`dta_file'",`pos'+1,`len'-`pos')
}

// Creating local csv_file

if "`csv_file'" != "" {

	// Substituting \ for / in the paths

	local csv_file = subinstr("`csv_file'","\","/",100)
	
	// Checking if excel_file has the extension .xlsx or .xls 
/*
	************************************* verbose ********************************************
	if "`verbose'" == "verbose" {
		di ""
		di "Checking if excel_file has the extension .xlsx or .xls"
	}
	******************************************************************************************
	
	if regexm("`excel_file'",".xlsx") == 0 & regexm("`excel_file'",".xls") == 0 {
		di as error "Please provide the extension to your excel file(xls or xlsx)"
		error 1
	}
	confirm file "`excel_file'"
	*/
}
else {
	local path_csv: pwd
	local path_csv_new = subinstr("`path_csv'","\","/",100)	
	capture confirm file "${dta_file}.csv"
	local fe1 = _rc

	
	************************************* verbose ********************************************
	if "`verbose'" == "verbose" {
		di ""
		di "Looking for CSV file ${dta_file} in the current working dir"
	}
	******************************************************************************************
	
	if `fe1' == 0 {
		local csv_file "`path_csv_new'/${dta_file}.csv"
		if "`verbose'" == "verbose" {
			di ""
			di "CSV file found"
		}
	}
	else {
		di ""
		di as error "A CSV file named ${dta_file} was not found in the current working directory. No checks will be performed" 
		di ""
		di ""
		local csv_file 
	}

	
}




if "`csv_file'" != "" {


	// Program to validate the data in the csv file

	************************************* verbose ********************************************	
	if "`verbose'" == "verbose" {
		di ""
		di "Program valid_data"
	}
	******************************************************************************************	
	
	preserve
		valid_data, file1("`csv_file'") `verbose'

		if `r(data_error)' == 1 {
			error 1
		}
	restore

	// Creating globals internal and save to use as parameters in check_prog1

	************************************* verbose ********************************************	
	if "`verbose'" == "verbose" {
		di ""
		di "Creating globals internal to use as parameter in check_prog1"
	}
	******************************************************************************************
	
	if "`internal'" == "internal" {
		global internal = 1
	}
	else {
		global internal = 0
	}


	// Creating globals date and time that will serve to identify the folder inside the folder report_dataset.

	************************************* verbose ********************************************	
	if "`verbose'" == "verbose" {
		di ""
		di "Creating globals date and time that will serve to identify the folder inside the folder report_dataset"
	}
	******************************************************************************************

	global c_date = subinstr("`c(current_date)'"," ","_",20)
	global c_time = subinstr("`c(current_time)'",":","-",20)
	global id "`id'"

	capture file close myfile

	// Creating locals with the number of checks and the number of lines with stata code used to generate variables for a particular dataset

	************************************* verbose ********************************************	
	if "`verbose'" == "verbose" {
		di ""
		di "Creating locals with the number of checks and the number of lines with stata code used to generate variables for a particular dataset"
	}
	******************************************************************************************

	preserve
		quietly import delimited "`csv_file'", delimiter(",") varnames(1) stringcols(_all) clear
		//import excel using "`excel_file'", firstrow allstring clear 
		quietly count if active == "1" 
		local check_count = r(N)
		quietly count if active == "2" 
		local gen_count = r(N)
	restore


	// Creating global with path for output files. If the user does not specify this option, the global will be the current working directory

	************************************* verbose ********************************************	
	if "`verbose'" == "verbose" {
		di ""
		di "Creating global with path for output files. If the user does not specify this option, the global will be the current working directory"
	}
	******************************************************************************************

	if "`out_path'" != "" {
		global out_path "`out_path'"
		quietly cd "${out_path}"
	}
	else {
		local path: pwd
		local path_new = subinstr("`path'","\","/",100)
		global out_path "`path_new'"
	}

	// Creating folders to save the html files and datasets with inconsistent values
	
	************************************* verbose ********************************************	
	if "`verbose'" == "verbose" {
		di ""
		di "Creating folders to save the html files and datasets with inconsistent values"
	}
	******************************************************************************************

	capture mkdir Reports
	quietly cd "Reports"
	capture mkdir "report_${dta_file}"
	quietly cd "report_${dta_file}"
	capture mkdir "${c_date}"
	if _rc != 0 {
		di as error "Folder ${c_date} already exists"
		*error 1
	}
	quietly cd "${c_date}"
	capture mkdir output_files
	quietly cd "output_files"


	// Program file_write
	
	************************************* verbose ********************************************	
	if "`verbose'" == "verbose" {
		di ""
		di "Program file_write"
	}
	******************************************************************************************	

	file_write, csv_file("`csv_file'") check_count(`check_count') gen_count(`gen_count') linesize(`linesize') save_obs(`save_obs') mpz(`mpz') `inc_only' `keepmd' tvar(`tvar') `verbose'

}
else {
	// Program file_write

	************************************* verbose ********************************************	
	if "`verbose'" == "verbose" {
		di ""
		di "Program file_write"
	}
	******************************************************************************************	
	
	file_write, mpz(`mpz') `verbose' tvar(`tvar')
}


macro drop _all

************************************* verbose ********************************************
if "`verbose'" == "verbose" {
	di ""
	di "------------------------ end checkmd.ado ------------------------------"
}
******************************************************************************************



end
