*! version 1.2 27Apr2020
* Programmed by Gustavo Iglésias
* Dependencies:
* markstat (version 2.2.0 7may2018)
* package matrixtools
* package gtools

program define checkmd

syntax [if] [, 			///
	csv_file(string)	/// file with checks
	out_path(string)	/// path where the reports are saved
	id(string)			///	identifier for rows
	linesize(int 255)	///	linesize for html
	listinc				/// lists inconsistent values in the html file
	save_obs(int -1)	/// saves inconsistent values to a dataset
	mpz(string)			/// default report for variables
	inc_only			/// only displays checks with inconsistencies in the html
	keepmd				/// keeps .stmd files 
	addvars(string)		///	adds variables to dataset with inconsistencies 
	tvar(string)		/// adds time dimension to the summary of inconsistencies
	verbose				///	shows the progress of the program
]

version 15


local commands "gtools markstat matprint"
foreach com in `commands' {
	cap which `com'
	if _rc {
		di "{err:command {bf:`com'} is unrecognized}"
		exit 199
	}
}

foreach var in `addvars' {
	confirm variable `var'
}

local cwd: pwd

preserve
	// Keeping observations that verify if condition
	if "`if'" != "" {
		global if_condition = "`if'"
		quietly keep `if'
	}
	
	checkmd_call, csv_file(`csv_file') out_path(`out_path') id(`id') linesize(`linesize') ///
				  `listinc' save_obs(`save_obs') mpz(`mpz') `inc_only' `keepmd' ///
				  addvars(`addvars') tvar(`tvar') `verbose'

restore

qui cd "`cwd'"

end


program define checkmd_call

syntax [, csv_file(string) out_path(string) id(string) linesize(int 255) /// 
		  listinc save_obs(int -1) mpz(string) inc_only keepmd /// 
		  addvars(string) tvar(string) verbose]


************************************* verbose ********************************************
if "`verbose'" == "verbose" {
	di ""
	di "------------------------ begin checkmd.ado ----------------------------"
}
******************************************************************************************

capture label language en


// Global with the name of the dta_file without the path and .dta
local dta_file = subinstr("${S_FN}","\","/",100)
local dta_file = subinstr("`dta_file'",".dta","",1)
local len = length("`dta_file'")
loca pos = strrpos("`dta_file'","/")
global dta_file = substr("`dta_file'",`pos'+1,`len'-`pos')


// Creating local csv_file
if "`csv_file'" != "" {
	// Substituting \ for / in the paths
	local csv_file = subinstr("`csv_file'","\","/",100)
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
		di "{err:File {bf:${dta_file}.csv} not found in the current working directory. No checks" ///
			" will be performed}" 
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
		di "Program checkmd_vdata"
	}
	******************************************************************************************	
	
	preserve
		checkmd_vdata, file1("`csv_file'") `verbose'
		if `r(data_error)' == 1 error 1
	restore

	// Creating globals listinc to use as parameters in checkmd_check

	************************************* verbose ********************************************	
	if "`verbose'" == "verbose" {
		di ""
		di "Creating globals listinc to use as parameter in checkmd_check"
	}
	******************************************************************************************
	
	if "`listinc'" == "listinc" {
		global listinc = 1
	}
	else {
		global listinc = 0
	}

	// Creating globals date and time that will serve to identify the folder inside the folder 
	// report_dataset.

	************************************* verbose ********************************************	
	if "`verbose'" == "verbose" {
		di ""
		di "Creating globals date and time that will serve to identify the folder inside the " ///
			"folder report_dataset"
	}
	******************************************************************************************

	global c_date = subinstr("`c(current_date)'"," ","_",20)
	global c_time = subinstr("`c(current_time)'",":","-",20)
	global id "`id'"

	capture file close myfile

	// Creating locals with the number of checks and the number of lines with stata code used to 
	// generate variables for a particular dataset

	************************************* verbose ********************************************	
	if "`verbose'" == "verbose" {
		di ""
		di "Creating locals with the number of checks and the number of lines with stata code" ///
			" used to generate variables for a particular dataset"
	}
	******************************************************************************************

	preserve
		quietly import delimited "`csv_file'", delimiter(",") varnames(1) stringcols(_all) clear
		quietly count if active == "1" 
		local check_count = r(N)
		quietly count if active == "2" 
		local gen_count = r(N)
	restore

	// Creating global with path for output files. If the user does not specify this option, ///
	// the global will be the current working directory

	************************************* verbose ********************************************	
	if "`verbose'" == "verbose" {
		di ""
		di "Creating global with path for output files. If the user does not specify this " /// 
			"option, the global will be the current working directory"
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
	}
	quietly cd "${c_date}"
	capture mkdir output_files
	quietly cd "output_files"

	// Program checkmd_fwrite
	
	************************************* verbose ********************************************	
	if "`verbose'" == "verbose" {
		di ""
		di "Program checkmd_fwrite"
	}
	******************************************************************************************	

	checkmd_fwrite, csv_file("`csv_file'") check_count(`check_count') gen_count(`gen_count') /// 
				linesize(`linesize') save_obs(`save_obs') mpz(`mpz') `inc_only' `keepmd' /// 
				addvars(`addvars') tvar(`tvar') `verbose'

}
else {
	// Program checkmd_fwrite

	************************************* verbose ********************************************	
	if "`verbose'" == "verbose" {
		di ""
		di "Program checkmd_fwrite"
	}
	******************************************************************************************	
	
	checkmd_fwrite, mpz(`mpz') `verbose' tvar(`tvar')
}

clear
cap erase "${out_path}/Reports/report_${dta_file}/${c_date}/summary.dta"
cap erase "${out_path}/temp_file.dta"
cap rm "${out_path}/Reports/report_${dta_file}/${c_date}/summary.dta"
cap rm "${out_path}/temp_file.dta"
macro drop _all

************************************* verbose ********************************************
if "`verbose'" == "verbose" {
	di ""
	di "------------------------ end checkmd.ado ------------------------------"
}
******************************************************************************************



end
