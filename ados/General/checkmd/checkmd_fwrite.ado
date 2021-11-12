* Program checkmd_fwrite

/* This program generates two html documents: one (html file 1) presents information on 
some logical condition tested by the program checkmd_check, displaying a tabulation 
of observations that verify that condition and a list of values with the most significant 
inconsistent values; the other (html file 2) provides a summary of inconsistencies for 
each check performed in a dataset. All the options are provided by the program checkmd
If option csv_file is empty, the output will be the matrix mpz (if "nompz" is not specified) */

program define checkmd_fwrite

syntax [, csv_file(string) mpz(string) check_count(int 0) ///
		  gen_count(int 0) linesize(int 150) save_obs(int -1) ///
		  addvars(string) tvar(string) inc_only keepmd verbose] 

************************************* verbose ********************************************
if "`verbose'" == "verbose" {
	di ""
	di "------------------------ begin checkmd_fwrite.ado ----------------------------"
}
******************************************************************************************

capture file close myfile

local c_date = subinstr("${c_date}","_"," ",20)
local c_time = subinstr("${c_time}","-",":",20)

// Characters used in this program to deal with stata's limitations regarding strings and macro expansion:* 

// ` !    
// ' ?
// " §

// These characters will then be replaced using filefilter

// * This step was necessary because we had to use the filewrite command in order to write markdown code inside stata code

************************************* verbose ********************************************
if "`verbose'" == "verbose" {
	di ""
	di "Characters used in this program to deal with stata's limitations regarding strings and macro expansion:* "
	di ""
	di "! = `"
	di "? = '"
	di `"" = §"'
	di ""
	di "These characters will be replaced later using filefilter"
	di ""
	di "* This step was necessary because we had to use the filewrite command in order to write markdown code inside stata code"
}
******************************************************************************************

if "`csv_file'" != "" {

	*******************
	*** hmtl file 1 ***
	*******************
	
	************************************* verbose ********************************************
	if "`verbose'" == "verbose" {
		di ""
		di "Creating html file 1 (report_datasetname)"
	}
	******************************************************************************************
	
	file open  myfile using "write.stmd", write text replace
	
	file write myfile "<meta charset=§utf-8§/>" _n
	file write myfile _n
	file write myfile "# <span style=§color:black§>**Checks**</span>" _n
	file write myfile _n
	file write myfile _n
	file write myfile "### Dataset: ${dta_file}" _n
	file write myfile _n
	if "${if_condition}" ~= "" {
		file write myfile "### [Condition: !s §${if_condition}§!]" _n
	}	
	file write myfile _n
	file write myfile "#### Date: `c_date'"_n
	file write myfile "#### Time: `c_time'"_n
	file write myfile _n
	file write myfile _n
	file write myfile "!!!s/" _n
	file write myfile _n
	file write myfile "// check_feed" _n
	file write myfile _n
	file write myfile "program drop _all" _n
	file write myfile _n
	file write myfile _n

	if "`mpz'" != "nompz" {
		file write myfile "checkmd_mpz, varlist(`mpz')`verbose'"  _n
		************************************* verbose ********************************************
		if "`verbose'" == "verbose" {
			di ""
			di "Program checkmd_mpz"
		}
		******************************************************************************************
		file write myfile "!!!" _n
		file write myfile "### <span style=§color:green§>**Missing values, positive values, zeros and missing value labels**</span>" _n
		file write myfile "!!!s/" _n
		file write myfile "di §§"  _n
		file write myfile "di §§"  _n
		file write myfile "matprint r(mpz), decimals(0,0,0) style(md)"  _n
		file write myfile "di §§"  _n
		file write myfile "di § N: !r(obs)?§"  _n
	}

	// generating observation's id if not specified by the user in the program check_consistency
	
	************************************* verbose ********************************************
	if "`verbose'" == "verbose" {
		di ""
		di "generating observation's id if not specified by the user in the program check_consistency"
	}
	******************************************************************************************

	file write myfile "if §${id}§ == §§ {"  _n
	file write myfile "gen id = _n" _n
	file write myfile "global id §id§" _n
	file write myfile "}" _n
	file write myfile "else {" _n
	file write myfile "global id §${id}§" _n
	file write myfile "}" _n

	// Running checkmd_extinf to get information provided by the csv file regarding checks and code used to variables 
	
	************************************* verbose ********************************************
	if "`verbose'" == "verbose" {
		di ""
		di "Program checkmd_extinf"
	}
	******************************************************************************************

	file write myfile "preserve" _n
	file write myfile "checkmd_extinf, file(§`csv_file'§) `verbose'" _n
	file write myfile _n
	file write myfile _n

	// generating locals with information for each check
	
	************************************* verbose ********************************************
	if "`verbose'" == "verbose" {
		di ""
		di "Generating locals with information for each check"
	}
	******************************************************************************************

	forvalue i=1/`check_count' {
		file write myfile "// locals for observation `i'" _n
		file write myfile "capture local id_`i' = §!r(id_`i')?§" _n
		file write myfile "local title_`i' = §!r(title_`i')?§" _n
		file write myfile "local cond_`i' = !§!r(cond_`i')?§?" _n
		file write myfile "capture local misstozero_`i' = §!r(misstozero_`i')?§" _n
		file write myfile "capture local ignoremiss_`i' = §!r(ignoremiss_`i')?§" _n
		file write myfile "capture local ignorerow_`i' = !§!r(ignorerow_`i')?§?" _n
		file write myfile "capture local delta_`i' = real(§!r(delta_`i')?§)" _n
		file write myfile "capture local list_val_`i' = real(§!r(list_val_`i')?§)" _n
		file write myfile _n
		file write myfile _n
	}

	// generating stata code as specified by the user in the csv file
	
	************************************* verbose ********************************************
	if "`verbose'" == "verbose" {
		di ""
		di "Generating stata code as specified by the user in the csv file"
	}
	******************************************************************************************

	forvalue i = 1/`gen_count' {
		file write myfile "local gen_`i' = §!r(gen_`i')?§" _n
		file write myfile _n
	}

	file write myfile "restore" _n	
	file write myfile _n

	forvalue i = 1/`gen_count' {
		file write myfile "quietly !gen_`i'?" _n
		file write myfile _n
	}

	file write myfile "!!!" _n

	// Running the program checkmd_check for each check

	************************************* verbose ********************************************
	if "`verbose'" == "verbose" {
		di ""
		di "Running the program checkmd_check for each check"
	}
	******************************************************************************************
	
	if "`tvar'" != "" {
		quietly glevelsof(`tvar'), local(tvar_levels)
		local tvar_levels_count: word count `tvar_levels'
	}

	forvalues i = 1/`check_count' {
		file write myfile "!!!s/" _n
		file write myfile "	local check_`i' = §checkmd_check, § + §id(!id_`i'?) § +"
		file write myfile " !§check(!cond_`i'?) §? + §!misstozero_`i'? § + §delta(!delta_`i'?) § +"
		file write myfile " !§title(!title_`i'?) §? +  §list_val(!list_val_`i'?) § +"
		file write myfile " §save_obs(`save_obs')§ + § addvars(`addvars')§ + § tvar(`tvar')§ +"
		file write myfile " § `verbose' § + §!ignoremiss_`i'? § + !§ignore(!ignorerow_`i'?) §?" _n
		file write myfile "	!check_`i'?" _n
		file write myfile "	capture local error_`i' = !r(error)?" _n
		file write myfile "	capture local gen_error_`i' = !r(gen_error)?" _n	
		file write myfile "	capture local asrt_`i' = !r(asrt)?" _n	
		file write myfile "	capture local tot_`i' = !r(tot)?" _n
		file write myfile "	capture local inc_`i' = !r(inc)?" _n
		if "`tvar'" ~= "" {
		file write myfile "	quietly foreach item in `tvar_levels' {" _n
		file write myfile "	quietly local tot_`i'_!item? = r(tot_!item?)" _n
		file write myfile "	if !asrt_`i'? == 0 {" _n
		file write myfile "	quietly capture local inc_`i'_!item? = 0" _n
		file write myfile "	}" _n
		file write myfile "	else if !asrt_`i'? == 9 {" _n
		file write myfile "	quietly capture local inc_`i'_!item? = !r(inc_!item?)?" _n
		file write myfile "	}" _n
		file write myfile "	else if !asrt_`i'? == 111 {" _n
		file write myfile "	quietly capture local inc_`i'_!item? = ." _n
		file write myfile "	}" _n
		file write myfile "	}" _n
		}
		file write myfile "	capture local list_valn_`i' = !r(list_valn)?" _n
		file write myfile "	if _rc > 0 {" _n
		file write myfile "	quietly local list_valn_`i' = 0" _n
		file write myfile "	}" _n
		file write myfile "	capture local count_list_`i' = !r(count_list)?" _n
		file write myfile "	if _rc > 0 {" _n
		file write myfile "	quietly local count_list_`i' = 0" _n
		file write myfile "	}" _n	
		file write myfile "	capture matrix X_`i' = r(X)" _n		
		file write myfile "	if !error_`i'? == 1 | !gen_error_`i'? == 1 {" _n
		file write myfile "	quietly local title_red_`i' = §[!id_`i'?] !title_`i'?§" _n
		file write myfile "	}" _n
		file write myfile "	else {" _n
		file write myfile "	if !asrt_`i'? > 0 {" _n
		file write myfile "	quietly local title_red_`i' = §[!id_`i'?] !title_`i'?§" _n
		file write myfile "	}" _n
		file write myfile "	else if !asrt_`i'? == 0 & §`inc_only'§ == §inc_only§ {" _n
		file write myfile "	quietly local title_blue_`i' " _n
		file write myfile "	}" _n
		file write myfile "	else if !asrt_`i'? == 0 & §`inc_only'§ ~= §inc_only§ {" _n
		file write myfile "	quietly local title_blue_`i' = §[!id_`i'?] !title_`i'?§ " _n
		file write myfile "	}" _n
		file write myfile "	}" _n
		file write myfile "!!!"	_n
		file write myfile _n

		// Markdown title for the check. It will be red if any inconsistency is found and blue otherwise 
		
		************************************* verbose ********************************************
		if "`verbose'" == "verbose" {
			di ""
			di "Creating markdown title for the check. It will be red if any inconsistency is found and blue otherwise"
		}
		******************************************************************************************

		file write myfile "!!!s/"	_n
		file write myfile "	if !gen_error_`i'? == 0 & !error_`i'? == 0 & §`inc_only'§ == §inc_only§ & !asrt_`i'? == 0 {"_n
		file write myfile "	quietly local cap §capture §" _n
		file write myfile "	}" _n
		file write myfile "	else {" _n
		file write myfile "	quietly local cap" _n
		file write myfile "	}" _n
		file write myfile "!!!"	_n

		file write myfile "#### <span style=§color:blue§>!s §!title_blue_`i'?§!</span>" _n
		file write myfile "#### <span style=§color:red§>!s §!title_red_`i'?§!</span>" _n
		file write myfile _n

		file write myfile "!!!s/" _n
		file write myfile _n
		file write myfile "	* Check `i'" _n
		file write myfile _n

		file write myfile "	if !error_`i'? == 1 {" _n
		file write myfile "	!cap? di §One or more variables have not been found on the dataset§" _n
		file write myfile "	}" _n
		file write myfile "	else if !gen_error_`i'? == 1 {" _n
		file write myfile "	!cap? di as error §[Error: csv file] error in variable cond for !id_`i'? §" _n
		file write myfile "	}" _n
		file write myfile "	else {" _n
		file write myfile "	!cap? di !§Condition: !cond_`i'?§?" _n
		file write myfile _n
		file write myfile "	di" _n
		file write myfile "	di" _n
		file write myfile "	if !asrt_`i'? == 0 {" _n
		file write myfile "	!cap? di §No inconsistencies found§" _n
		file write myfile "	if §!ignoremiss_`i'?§ == §ignoremissing§ {" _n
		file write myfile "	!cap? di" _n
		file write myfile "	!cap? di §Note: rows with missing values ignored§" _n
		file write myfile "	}" _n
		file write myfile "	if !§!ignorerow_`i'?§? ~= §§ {" _n
		file write myfile "	!cap? di" _n
		file write myfile "	!cap? di !§Note: rows ignored where !ignorerow_`i'?§?" _n
		file write myfile "	}" _n
		file write myfile "	}" _n
		file write myfile "	else if !inc_`i'? > 0  & !inc_`i'? < !tot_`i'? {" _n
		file write myfile "	!cap? di §Tabulation:§" _n
		file write myfile "	!cap? di" _n
		file write myfile "	!cap? matprint X_`i', decimals(0,2,2)" _n 
		file write myfile "	!cap? di" _n
		file write myfile "	if ${listinc} == 1 & !list_valn_`i'? > 0 {" _n
		file write myfile "	preserve" _n
		file write myfile "	di" _n
		file write myfile "	di §List of the !count_list_`i'? largest inconsistent values§" _n
		file write myfile "	quietly use §${out_path}/temp_file.dta§, clear" _n
		file write myfile "	di" _n
		file write myfile "	list, abbreviate(15) noobs" _n
		file write myfile "	di" _n
		file write myfile "	restore" _n
		file write myfile "	capture rm §${out_path}/temp_file.dta§" _n
		file write myfile "	}" _n
		file write myfile "	if §!ignoremiss_`i'?§ == §ignoremissing§ {" _n
		file write myfile "	!cap? di §Note: rows with missing values ignored§" _n
		file write myfile "	}" _n
		file write myfile "	if !§!ignorerow_`i'?§? ~= §§ {" _n
		file write myfile "	!cap? di" _n
		file write myfile "	!cap? di !§Note: rows ignored where !ignorerow_`i'?§?" _n
		file write myfile "	}" _n
		file write myfile "	}" _n
		file write myfile "	else if !inc_`i'? == !tot_`i'? {" _n
		file write myfile "	di §All observations are inconsistent§" _n
		file write myfile "	di" _n
		file write myfile "	if ${listinc} == 1 & !list_val_`i'? > 0 {" _n
		file write myfile "	preserve" _n
		file write myfile "	di §List of the !count_list_`i'? largest inconsistent values§" _n
		file write myfile "	quietly use §${out_path}/temp_file.dta§, clear" _n
		file write myfile "	di" _n
		file write myfile "	list, abbreviate(15) noobs" _n
		file write myfile "	di" _n
		file write myfile "	restore" _n
		file write myfile "	capture rm §${out_path}/temp_file.dta§" _n
		file write myfile "	}" _n
		file write myfile "	if §!ignoremiss_`i'?§ == §ignoremissing§ {" _n
		file write myfile "	!cap? di §Note: rows with missing values ignored§" _n
		file write myfile "	}" _n
		file write myfile "	if !§!ignorerow_`i'?§? ~= §§ {" _n
		file write myfile "	!cap? di" _n
		file write myfile "	!cap? di !§Note: rows ignored where !ignorerow_`i'?§?" _n
		file write myfile "	}" _n
		file write myfile "	}" _n	
		file write myfile "	}" _n
		file write myfile "!!!"	_n
		file write myfile _n
		file write myfile _n
		
	}

	// dataset with summary
	
	************************************* verbose ********************************************
	if "`verbose'" == "verbose" {
		di ""
		di "Creating dataset with summary"
	}
	******************************************************************************************
	
	// tvar 
	
	if "`tvar'" ~= "" {
	
	file write myfile "!!!s/" _n	
	file write myfile "	preserve" _n	
	file write myfile "	clear" _n	
	file write myfile "	quietly local levcount: word count `tvar_levels'" _n
	file write myfile "	quietly local new_check_count = `check_count'*!levcount?" _n
	file write myfile "	quietly set obs !new_check_count?" _n	
	file write myfile "	quietly gen Check_id = §§" _n
	file write myfile "	quietly gen Check_title = §§" _n	
	file write myfile "	quietly gen `tvar' = ." _n																	
	file write myfile "	quietly gen Inconsistencies = ." _n	
	file write myfile "	quietly gen Observations = ." _n
	file write myfile "	quietly local j = 1" _n
	file write myfile "	quietly forvalue i = 1/`check_count' {" _n
	file write myfile "	quietly foreach item in `tvar_levels' {" _n
	file write myfile "	quietly replace Check_id = §!id_!i??§ in !j?" _n
	file write myfile "	quietly replace Check_title = §!title_!i??§ in !j?" _n
	file write myfile "	quietly replace `tvar' = !item? in !j?" _n
	file write myfile "	if !error_!i?? == 0 & !gen_error_!i?? == 0 & !asrt_!i?? == 0 {" _n
	file write myfile "	quietly replace Inconsistencies = 0 in !j?" _n
	file write myfile "	quietly replace Observations = !tot_!i?_!item?? in !j?" _n	
	file write myfile "	quietly local j = !j? + 1" _n	
	file write myfile "	}" _n
	file write myfile "	else if !error_!i?? == 0 & !gen_error_!i?? == 0 & !asrt_!i?? == 9 {" _n
	file write myfile "	quietly replace Inconsistencies = !inc_!i?_!item?? in !j?" _n
	file write myfile "	quietly replace Observations = !tot_!i?_!item?? in !j?" _n
	file write myfile "	quietly local j = !j? + 1" _n
	file write myfile "	}" _n
	file write myfile "	else {" _n
	file write myfile "	quietly replace Inconsistencies = . in !j?" _n		
	file write myfile "	quietly replace Observations = . in !j?" _n	
	file write myfile "	local j = !j? + 1" _n
	file write myfile "	}" _n
	file write myfile "	}" _n
	file write myfile "	}" _n
	file write myfile "	if §`inc_only'§ == §inc_only§ {" _n
	file write myfile "	quietly drop if Inconsistencies == 0" _n
	file write myfile "	}" _n
	file write myfile "	note: Summary: ${dta_file} ${c_date} ${c_time}" _n
	file write myfile "	quietly save §${out_path}/Reports/report_${dta_file}/${c_date}/summary§, replace" _n
	file write myfile "	restore" _n		
	file write myfile "!!!" _n
	}
	
	file write myfile _n
	
	else {
	
	// no tvar
	file write myfile "!!!s/" _n
	file write myfile "	preserve" _n	
	file write myfile "	clear" _n	
	file write myfile "	quietly set obs `check_count'" _n	
	file write myfile "	quietly gen Check_id = §!id_1?§ in 1" _n
	file write myfile "	quietly gen Check_title = §!title_1?§ in 1" _n	
	file write myfile "	if !error_1? == 0  & !gen_error_1? == 0 & !asrt_1? == 0 {" _n
	file write myfile "	quietly gen Inconsistencies = 0 in 1" _n	
	file write myfile "	quietly gen Observations = !tot_1? in 1" _n	
	file write myfile "	}" _n
	file write myfile "	else if !error_1? == 0  & !gen_error_1? == 0 & !asrt_1? == 9 {" _n
	file write myfile "	quietly gen Inconsistencies = !inc_1? in 1" _n	
	file write myfile "	quietly gen Observations = !tot_1? in 1" _n	
	file write myfile "	}" _n
	file write myfile "	else {" _n
	file write myfile "	quietly gen Inconsistencies = . in 1" _n	
	file write myfile "	quietly gen Observations = . in 1" _n	
	file write myfile "	}" _n
	file write myfile "	quietly forvalue i = 2/`check_count' {" _n	
	file write myfile "	quietly replace Check_id = §!id_!i??§ in !i?" _n
	file write myfile "	quietly replace Check_title = §!title_!i??§ in !i?" _n	
	file write myfile "	if !error_!i?? == 0 & !gen_error_!i?? == 0 & !asrt_!i?? == 0 {" _n
	file write myfile "	quietly replace Inconsistencies = 0 in !i?" _n
	file write myfile "	quietly replace Observations = !tot_!i?? in !i?" _n	
	file write myfile "	}" _n
	file write myfile "	else if !error_!i?? == 0 & !gen_error_!i?? == 0 & !asrt_!i?? == 9 {" _n
	file write myfile "	quietly replace Inconsistencies = !inc_!i?? in !i?" _n
	file write myfile "	quietly replace Observations = !tot_!i?? in !i?" _n	
	file write myfile "	}" _n
	file write myfile "	else {" _n
	file write myfile "	quietly replace Inconsistencies = . in !i?" _n		
	file write myfile "	quietly replace Observations = . in !i?" _n		
	file write myfile "	}" _n
	file write myfile "	}" _n
	file write myfile "	if §`inc_only'§ == §inc_only§ {" _n
	file write myfile "	quietly drop if Inconsistencies == 0" _n
	file write myfile "	}" _n
	file write myfile "	note: Summary: ${dta_file} ${c_date} ${c_time}" _n
	file write myfile "	quietly save §${out_path}/Reports/report_${dta_file}/${c_date}/summary§, replace" _n
	file write myfile "	restore" _n	
	file write myfile "!!!" _n

	}
	
	file close myfile

	// replacing !,? and § in the stmd file

	************************************* verbose ********************************************
	if "`verbose'" == "verbose" {
		di ""
		di "replacing !,? and § in the stmd file"
	}
	******************************************************************************************

	filefilter write.stmd write1.stmd, from(!) to(\LQ) replace
	filefilter write1.stmd write2.stmd, from(?) to(\RQ) replace
	filefilter write2.stmd "report_${dta_file}.stmd", from(§) to(\Q) replace

	// removing files used to generate the final stmd document

	************************************* verbose ********************************************
	if "`verbose'" == "verbose" {
		di ""
		di "removing files used to generate the final stmd document"
	}
	******************************************************************************************

	capture rm write.stmd
	capture rm write1.stmd
	capture rm write2.stmd

	
	************************************* verbose ********************************************
	if "`verbose'" == "verbose" {
		di ""
		di "Using command markstat to creat html file 1"
	}
	******************************************************************************************

	markstat using "report_${dta_file}.stmd"

	capture rm "report_${dta_file}.smcl"
	if "`keepmd'" != "keepmd" {
		capture rm "report_${dta_file}.stmd"
	}



	*******************
	*** hmtl file 2 ***
	*******************

	************************************* verbose ********************************************
	if "`verbose'" == "verbose" {
		di ""
		di "Creating html file 2 (summary)"
	}
	******************************************************************************************

	file open myfile using "write_sum.stmd", write text replace
	
	file write myfile "<meta charset=§utf-8§/>" _n
	file write myfile _n
	file write myfile "# <span style=§color:black§>**Summary**</span>" _n
	file write myfile _n
	file write myfile _n
	file write myfile "### Dataset: ${dta_file}"_n
	file write myfile _n
	file write myfile "#### Date: `c_date'"_n
	file write myfile "#### Time: `c_time'"_n
	file write myfile _n
	file write myfile _n
	file write myfile _n		
	file write myfile "!!!s/" _n
	file write myfile "	quietly use §${out_path}/Reports/report_${dta_file}/${c_date}/summary§, clear" _n
	file write myfile "	set linesize `linesize'" _n
	file write myfile "	tempvar lencheck" _n
	file write myfile "	quietly gen !lencheck? = length(Check_id)" _n
	file write myfile "	quietly sort !lencheck? Check_id `tvar'" _n
	file write myfile "	drop !lencheck?" _n
	file write myfile "	quietly order Check_id `tvar' Check_title" _n
	if "`tvar'" ~= "" {
		file write myfile "	list, string(130) abbreviate(15) separator(`tvar_levels_count')" _n
	}
	else {
		file write myfile "	list, string(130) abbreviate(15)" _n
	}
	file write myfile "!!!" _n
	file close myfile
	

	// replacing !,? and § in the stmd file
	
	************************************* verbose ********************************************
	if "`verbose'" == "verbose" {
		di ""
		di "replacing !,? and § in the stmd file"
	}
	******************************************************************************************

	filefilter write_sum.stmd write_sum1.stmd, from(!) to(\LQ) replace
	filefilter write_sum1.stmd write_sum2.stmd, from(?) to(\RQ) replace
	filefilter write_sum2.stmd "summary_${dta_file}.stmd", from(§) to(\Q) replace

	// removing files used to generate the final stmd document
	
	************************************* verbose ********************************************
	if "`verbose'" == "verbose" {
		di ""
		di "removing files used to generate the final stmd document"
	}
	******************************************************************************************

	rm write_sum.stmd
	rm write_sum1.stmd
	rm write_sum2.stmd
	
	************************************* verbose ********************************************
	if "`verbose'" == "verbose" {
		di ""
		di "Using command markstat to create html file 2"
	}
	******************************************************************************************
	
	markstat using "summary_${dta_file}.stmd"
	capture rm "summary_${dta_file}.smcl"
	if "`keepmd'" != "keepmd" {
		capture rm "summary_${dta_file}.stmd"
	}
	
}
else {
	if "`mpz'" != "nompz" {
		************************************* verbose ********************************************
		if "`verbose'" == "verbose" {
			di ""
			di "Program checkmd_mpz"
			di ""
		}
		******************************************************************************************
		checkmd_mpz, varlist(`mpz')
		di as text "** Missing values, positive values, zeros and missing value labels**"
		di ""
		matprint r(mpz), decimals(0,0,0)
		di
		di "N: `r(obs)'"
	}
}

************************************* verbose ********************************************
if "`verbose'" == "verbose" {
	di ""
	di "------------------------ end checkmd_fwrite.ado ------------------------------"
}
******************************************************************************************

end
