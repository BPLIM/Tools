*! version 0.1 10Apr2024
* Programmed by Gustavo Iglésias

program define mdata_diff, rclass

	version 16

	syntax, [         ///
		Path(str) 	  ///  Directory with meta files (xlsx)
		PATTERN(str)  ///  Pattern for files - based on strmatch patterns
		SAVE(str)     ///  Excel output file
		REPLACE       ///  Replace Excel file if it exists
		BASEfile(str) ///  Name of the base meta file 
		DIFFonly      ///  Shows only rows with differences
		VERBOSE       ///  Shows the progress of the program 
		CHARS         ///  Include analysis for characteristics
		NOTES         ///  Include analysis for notes
		RECursive     ///  Recursively search for meta files
	]
	
	cap which filelist
	if _rc {
		di "{err:This command requires that {bf:filelist} is installed}"
		error 199
	}
	
	if trim("`save'") == "" local save "metadiff"
	cap confirm file "`save'.xlsx"
	if !_rc & "`replace'" == "" {
		di "{err:File {bf:`save'.xlsx} already exists}"
		exit 602
	}
	else {
		cap rm "`save'.xlsx"
	}

	if ("`path'" == "") local path: pwd

	if ("`pattern'" == "") {
		local pattern "*.xlsx"
	}
	else {
		local pattern = "`pattern'" + ".xlsx"
	}
	
	cap putexcel clear
	
	tempfile indexed_data
	
	index_data, fname(`indexed_data') dir(`path') pattern(`pattern') ///
		base(`basefile') history(`save') `verbose' `recursive'
		
	local files `"`r(files)'"'	
	
	* Diff counter 
	global diffs__ = 0
	put_summary, file(`save'.xlsx)
	
	data_history, index_data(`indexed_data') files(`"`files'"') ///
		history(`save') `verbose'

	vars_history, index_data(`indexed_data') files(`"`files'"') ///
		history(`save') `diffonly' `verbose' `chars' `notes'
	return add
	
	vl_history, index_data(`indexed_data') files(`"`files'"') ///
		history(`save') `diffonly' `verbose'
	return add

	di 
	di `"{text:{bf:`save'.xlsx} saved}"'

end


program define index_data, rclass

	/* Indexes the data by meta file. The indexes generated will be of the form 
	base, f1, f2, ... The base index corresponds to the first file after sorting 
	the files by name. This behavior may be changed by specifying option `base`, 
	changing the base file
	*/

	syntax, fname(str) history(str) dir(str) pattern(str) ///
		[base(str) verbose recursive]
	
		if ("`verbose'" == "verbose") {
			di 
			di "Indexing meta files..."
			di
		}

		if ("`recursive'" != "recursive") local norecursive "norecursive"

		tempname frame 
		cap frame drop `frame'
		frame create `frame'
		frame `frame' {
			qui filelist, dir(`dir') pattern(`pattern') `norecursive'
			local obs = _N
			if (`obs' < 2) {
				di "{err:Not enough files to perform the analysis}"
				exit 198
			}
			qui gen _file = ""
			forvalues i = 1/`obs' {
				if c(os) == "Windows" {
					qui replace _file = dirname[`i'] + "\" ///
						+ filename[`i'] in `i'
				}
				else {
					qui replace _file = dirname[`i'] + "/" ///
						+ filename[`i'] in `i'
				}					
			}
			drop dirname filename fsize
			
			// Create index for files
			if ("`base'" != "") {
				tempvar n
				gen `n' = _n 
				qui replace `n' = `n' + 1
				qui replace `n' = 1 if strpos(_file, "`base'")  // Should this be the default behavior?
				sort `n' _file
				drop `n'
			}
			else {
				sort _file
			}
			qui gen index = "base" in 1
			forvalues i = 2/`obs' {
				local j = `i' - 1
				qui replace index = "f`j'" in `i'
			}
			// return local files 
			qui levelsof _file, local(files)
			return local files  `files'
			
			// Dump info into index sheet
			quietly {
				putexcel set "`history'.xlsx", sheet("Index") open modify
				putexcel A2 = "Meta Files Index", bold
				putexcel A4 = "Index", bold underline
				putexcel B4 = "File", bold underline
				
				forvalues i = 1/`obs' {
					local j = `i' + 4
					putexcel A`j' = index[`i']
					putexcel B`j' = _file[`i']
				}
				putexcel save
				// Save temp data
				save `fname', replace
				clear
			}
		}
		frame drop `frame'

end


program define data_history

	/* Creates report data characteristics. Information is gathered from 
	two worksheets in metafiles, namely data_features_gen and data_features_spec
	. In this worksheet we do not report the differences but the actual values 
	in the metadata file
	*/

	syntax, index_data(str) files(str) history(str) [verbose]
	
		if ("`verbose'" == "verbose") {
			di "Working on data characteristics..."
			di
		}
		
	tempfile tempdata
	tempvar _merge
	tempname dataframe
	frame create `dataframe'
	frame `dataframe' {
		foreach file in `files' {
			cap import excel using "`file'", clear first ///
				sheet("data_features_gen")
			* General characteristics
			if !_rc {
				qui keep if substr(Feature, 1, 4) == "Data" ///
					| substr(Feature, 1, 5) == "Label"
				qui count if substr(Feature, 1, 9) == "Data note"
				local notescount = `r(N)'
				qui drop if substr(Features, 1, 9) == "Data note"
				qui replace Content = "Yes" if !missing(Content) & ///
					substr(Feature, 1, 10) == "Data Label"
				qui count 
				local last = `r(N)' + 1
				qui set obs `last'
				qui replace Features = "Data notes" in `last'
				qui replace Content = "`notescount'" in `last'
				qui gen _file = "`file'"
				qui cap append using `tempdata'
				qui save `tempdata', replace				
			}

			* Specific characteristics
			cap import excel using "`file'", clear first ///
				sheet("data_features_spec")
			if !_rc {
				qui keep if substr(Features, 1, 6) == "Number"
				qui gen _file = "`file'"
				qui cap append using `tempdata'
				qui save `tempdata', replace				
			}
		}
		qui use `tempdata', clear
		* Merge with the indexed data created with `index_data`
		qui merge m:1 _file using `index_data', gen(`_merge')
		drop `_merge'
		keep Content Features _file index
		sort Features _file
		drop _file
		qui compress
		qui reshape wide Content, i(Features) j(index) string
		rename Content* *
		qui ds 
		foreach var in `r(varlist)' {
			qui replace `var' = "." if missing(`var')
		}
		qui export excel using "`history'.xlsx", missing(".") ///
			sheet("Data Characteristics") sheetreplace firstrow(variables)	
	}
	frame drop `dataframe'

end


program define vars_history, rclass

	/* Creates report for variables' worksheet. It compares variables and its 
	labels, values labels, type, etc. for a set of meta files. Uses the indexed 
	data created for each meta file with command `index_data`
	*/

	syntax, index_data(str) files(str) history(str) ///
		[diffonly verbose chars NOTES]

	
	if ("`verbose'" == "verbose") {
		di "{text:Working on variables...}"
		di
	}

	tempfile temp_vars
	tempvar _merge dum 
	tempname vars_frame 
	frame create `vars_frame'
	frame `vars_frame' {
		foreach file in `files' {
			qui import excel using "`file'", clear first ///
				sheet("variables")
			qui gen _file = "`file'"
			qui cap append using `temp_vars'
			qui save `temp_vars', replace
		}
		* Merge with the indexed data created with `index_data`
		qui merge m:1 _file using `index_data', gen(`_merge')
		drop `_merge'
		keep variable label* value_label* type format chars notes index _file
		preserve 
			variables_sheet, history(`history') temp(`temp_vars') ///
				`diffonly' `verbose'
			return add
		restore  
		qui ds
		local vars "`r(varlist)'"
		local vars_exc "variable index _file"
		local vars_chars: list vars - vars_exc
		foreach var in `vars_chars' {
			if ("`var'" == "chars" & "`chars'" != "chars") continue
			if ("`var'" == "notes" & "`notes'" != "notes") continue
			preserve
				variables_chars_sheet, var(`var') history(`history') ///
					temp(`temp_vars') `diffonly' `verbose' 
				return add
			restore
		}
		clear 
	}
	frame drop `vars_frame'

end


program define variables_sheet, rclass

	/* Helper command to save report for variables. This sheet only reports 
	information on whether the variable is present on the metafile or not 
	*/

	syntax, history(str) temp(str) [diffonly verbose]

	tempvar dum 

	keep variable index
	qui gen `dum' = 1
	qui reshape wide `dum', i(variable) j(index) string
	foreach var of varlist `dum'* {
		qui replace `var' = 0 if missing(`var')
	}
	rename `dum'* *
	* Count rows with 1 for every column
	tempvar allones 
	qui gen `allones' = (base == 1) 
	foreach var of varlist f* {
		qui replace `allones' = 0 if `var' != 1
	}
	qui count if !`allones'
	if (`r(N)' == 0 & "`diffonly'" != "diffonly") | (`r(N)') {
		return local variables = `r(N)'
		* Add diffs to summary
		global diffs__ = ${diffs__} + 1
		put_summary, file(`history'.xlsx) worksheet(variables) diffs(`r(N)')
	}
	
	preserve
		drop `allones'
		qui save `temp', replace
	restore
	if ("`diffonly'" == "diffonly") {
		qui drop if `allones'
	}
	drop `allones'

	qui count 
	local obs = `r(N)' 
	
	if `obs' {
		qui export excel using "`history'.xlsx", ///
			sheet("variables") sheetreplace firstrow(variables)	
			
		order *, seq
		order variable
				
		put_legend, file("`history'.xlsx") sheet(variables) varinc(1) ///
			varexc(0) num_lines(`obs') 
	}
	else {
		di "{err:Worsheet {bf:variables} not exported because of}" ///
			"{err:option {bf:diffonly}}"
	}
	

	if ("`verbose'" == "verbose") {
		di "{text:Worksheet {bf:variables}: done}"
	}

end


program define variables_chars_sheet, rclass

	/* Helper command to save report for variables' characteristics, like label, 
	value label, type, etc. Each sheet will report if the characteristic of the 
	variable is equal or different from the base file. It presents the value in 
	the base file. For the rest of the files, a 0 or 1 is displayed signaling 
	that the value is different or equal to the base file. In the case of type 
	and format, the actual values are displayed when they differ from the base 
	file, otherwise the cell will contain the value "same"
	*/

	syntax, var(str) history(str) temp(str) [diffonly verbose]
	
	tempvar _merge

	keep variable `var' index
	qui reshape wide `var', i(variable) j(index) string
	* Merge with info about variables. If some variable does not appear in a 
	* specific meta file, the cell will be missing (.) in the Excel file
	qui merge 1:1 variable using `temp', gen(`_merge')
	drop `_merge'
	local _type: type `var'base
	if substr("`_type'", 1, 3) == "str" {
		qui replace `var'base = "." if base == 0
	}
	else {
		qui replace `var'base = . if base == 0
	}
	* Generate dummy to flag columns that are all equal (for specific rows)
	tempvar nonequal
	qui gen `nonequal' = 0
	if inlist("`var'", "type", "format") {
		foreach index of varlist f* {
			// Do not include variable format
			if regexm("`index'", "^f[0-9]+") {
				* Compare f# meta file with base meta file 
				qui gen _same`index' = "same" 
				qui replace _same`index' = `var'`index' ///
					if `var'`index' != `var'base 
				qui replace _same`index' =  "." if `index' == 0
				* Add 1 to dummy (flag columns that are equal)
				qui replace `nonequal' = `nonequal' + 1 ///
					if `var'`index' != `var'base
				drop `var'`index' `index'
				rename _same`index' `index'	
			}
		}				
	}
	else if inlist("`var'", "chars", "notes") {
		foreach index of varlist f* {
			qui replace `var'`index' = . if `index' == 0
			drop `index'
			* Add 1 to dummy (flag columns that are equal)
			qui replace `nonequal' = `nonequal' + 1 ///
				if `var'`index' != `var'base
			rename `var'`index' `index'
		}			
	}
	else {
		if strpos("`var'", "value_label") {
			* Dummy to flag variables with no value labels
			tempvar _rownonmiss
			qui gen `_rownonmiss' = !missing(`var'base)
		}
		foreach index of varlist f* {
			if strpos("`var'", "value_label") {
				qui replace `_rownonmiss' = `_rownonmiss' + 1 ///
					if !missing(`var'`index')
			}
			qui gen _same`index' = 0
			qui replace _same`index' = 1 if `var'`index' == `var'base 
			qui replace _same`index' = . if `index' == 0
			* Add 1 to dummy (flag columns that are equal)
			qui replace `nonequal' = `nonequal' + 1 ///
				if `var'`index' != `var'base
			drop `var'`index' `index'
			rename _same`index' `index'
		}
		if strpos("`var'", "value_label") {
			* Drop variables with no value labels
			qui drop if `_rownonmiss' == 0
			drop `_rownonmiss'
		}
	}
	qui count if `nonequal' > 0
	if (`r(N)' == 0 & "`diffonly'" != "diffonly") | (`r(N)') {
		return local `var' = `r(N)'
		* Add diffs to summary
		global diffs__ = ${diffs__} + 1
		put_summary, file(`history'.xlsx) worksheet(`var') diffs(`r(N)')
	}
	if ("`diffonly'" == "diffonly") {
		qui drop if `nonequal' == 0
	}
	drop `nonequal'
	
	qui count 
	local obs = `r(N)'
	
	if (`obs' == 0) {
		di "{err:Worsheet {bf:`var'} not exported because of option} " ///
			"{err:{bf:diffonly}}"
	}
	else {
		drop base
		rename `var'base base 
		order *, seq 
		order variable 
		
		* Label variables
		qui ds 
		foreach varchar in `r(varlist)' {
			if "`varchar'" == "base"  {
				if strpos("`var'", "value_label") {
					label var `varchar' "lblname (base)"
				}
				else {
					label var `varchar' "`var' (base)"
				}
			}
			else {
				label var `varchar' "`varchar'"
			}
		}

		qui export excel using "`history'.xlsx", missing(".") ///
			sheet("`var'") sheetreplace firstrow(varl)	
			
		if inlist("`var'", "chars", "notes") { 
			put_legend, file("`history'.xlsx") sheet(`var') varmiss(.) ///
				num_lines(`obs')
		}
		else if inlist("`var'", "type", "format") { 
			put_legend, file("`history'.xlsx") sheet(`var') varmiss(.) ///
				equal(same) num_lines(`obs')
		}
		else {
			put_legend, file("`history'.xlsx") sheet(`var') varmiss(.) ///
				equal(1) diff(0) num_lines(`obs')
		}	
		
	}

		
	if ("`verbose'" == "verbose") {
		di "{text:Worksheet {bf:`var'}: done}"
	}

end


program define vl_history, rclass

	/* Creates report for value labels worksheet. It compares value labels 
	across meta files. For each value label, a sheet is produced with its name, 
	containing all possible values and labels for all meta files. Then columns 
	base, f1, f2, ... will just have a 0 or a 1 flagging whether that particular 
	value and label are present in the meta file. It is possible to have only 
	missing values for an index if the value label does not exist for that 
	particular meta file. Uses the indexed data created for each meta file 
	with command `index_data`
	*/

	syntax, index_data(str) files(str) history(str) [diffonly verbose]
	
	if ("`verbose'" == "verbose") {
		di 
		di "{text:Working on value labels...}"
		di 
	}

	tempfile temp_value_labels
	tempvar _merge
	tempname vl_frame 
	frame create `vl_frame'
	frame `vl_frame' {
		foreach file in `files' {
			* Find value label sheets in metafiles
			qui import excel "`file'", describe
			local sheetcount = `r(N_worksheet)'
			forval i = 1/`sheetcount' {
				local worksheet_`i' = "`r(worksheet_`i')'"
			}
			forval i = 1/`sheetcount' {
				if substr("`worksheet_`i''", 1, 3) == "vl_" {
					* Import data from value label sheets. Every sheet with 
					* value labels for every meta file will be appended to one 
					* file 
					qui import excel using "`file'", clear ///
						first sheet("`worksheet_`i''")
					qui gen _file = "`file'"
					qui gen _vl = "`worksheet_`i''"
					qui cap append using `temp_value_labels'
					qui save `temp_value_labels', replace				
				}
			}
		}
		* Merge with indexed data
		qui merge m:1 _file using `index_data', gen(`_merge')
		drop `_merge'
		keep value label index _file _vl
		qui levelsof index, local(index_levels)
		qui levelsof _vl, local(vl_levels)
		foreach vl_level in `vl_levels' {
			* Work on one value label form multiple metafiles 
			preserve
				vl_report, vl_level(`vl_level') index_levels(`index_levels') ///
					history(`history') `diffonly' `verbose'
				return add
			restore
		}
		clear
	}
	frame drop `vl_frame'
	
end


program define vl_report, rclass

	/* Helper command save report for each value label
	*/

	syntax, vl_level(str) index_levels(str) history(str) [diffonly verbose]

	tempvar dum
	qui keep if _vl == "`vl_level'"	
	drop _file _vl
	qui gen `dum' = 1
	* Flag if a particular value and label are present in the metafiles
	qui reshape wide `dum', i(value label) j(index) string
	rename `dum'* * 
	foreach var in `index_levels' {
		cap confirm var `var'
		if (!_rc) qui replace `var' = 0 if missing(`var')
	}
	foreach index_level in `index_levels' {
		* Make sure that every metafile is in a column. Reshape wide loses that
		* information if the index is not present in the data for a particular 
		* value label
		cap gen `index_level' = .
	}
	order *, seq
	order value label 
	* Count rows with all values equal to one
	tempvar allones 
	qui gen `allones' = (base == 1)
	foreach var of varlist f* {
		qui replace `allones' = 0 if `var' != 1
	}
	qui count if !`allones'
	if (`r(N)' == 0 & "`diffonly'" != "diffonly") | (`r(N)') {
		return local `vl_level' = `r(N)'
		* Add diffs to summary
		global diffs__ = ${diffs__} + 1
		put_summary, file(`history'.xlsx) worksheet(`vl_level') ///
			diffs(`r(N)')
	}
	if ("`diffonly'" == "diffonly") {
		/* Drop columns with all missing values
		foreach var in `index_levels' {
			qui count if !missing(`var')
			if (`r(N)' == 0) qui drop `var'
		}*/
		* Drop if there are no differences
		qui drop if `allones'
	}
	
	drop `allones'
	
	qui count  
	local obs = `r(N)'
	
	* Only export if count is > 0 (diffonly active)
	if `obs' {
		qui export excel using "`history'.xlsx", missing(".")  ///
			sheet("`vl_level'") sheetreplace firstrow(variables)
			
		put_legend, file("`history'.xlsx") sheet(`vl_level') vlmiss(.) ///
				vlinc(1) vlexc(0) num_lines(`obs')
	}
	else {
		di "{err:Worsheet {bf:`vl_level'} not exported because of option}" ///
			"{err: {bf:diffonly}}"
	}
		
	if ("`verbose'" == "verbose") {
		di "{text:Worksheet {bf:`vl_level'}: done}"
	}

end 


program define put_legend

	/* Creates legend for each worksheet present in the analysis
	*/

	syntax, file(str) sheet(str) [varinc(str) varexc(str) vlinc(str) ///
		vlexc(str) diff(str) equal(str) varmiss(str) vlmiss(str)	///
		num_lines(int 0)]
	
	local startline = `num_lines' + 4
	quietly {
		putexcel set "`file'", sheet("`sheet'") open modify
		putexcel A`startline' = "Legend", bold underline
		

		if ("`varexc'" != "") {
			local ++startline
			putexcel A`startline' = "`varexc'"
			putexcel B`startline' = "Variable not in metafile"
		}
		if ("`varinc'" != "") {
			local ++startline
			putexcel A`startline' = "`varinc'"
			putexcel B`startline' = "Variable in metafile"
		}
		if ("`vlexc'" != "") {
			local ++startline
			putexcel A`startline' = "`vlexc'"
			putexcel B`startline' = "Value label not in metafile"
		}
		if ("`vlinc'" != "") {
			local ++startline
			putexcel A`startline' = "`vlinc'"
			putexcel B`startline' = "Value label in metafile"
		}
		if ("`diff'" != "") {
			local ++startline
			putexcel A`startline' = "`diff'"
			putexcel B`startline' = "Different from base"
		}
		if ("`equal'" != "") {
			local ++startline
			putexcel A`startline' = "`equal'"
			putexcel B`startline' = "Equal to base"
		}
		if ("`varmiss'" != "") {
			local ++startline
			putexcel A`startline' = "`varmiss'"
			putexcel B`startline' = "Variable missing"
		}
		if ("`vlmiss'" != "") {
			local ++startline
			putexcel A`startline' = "`vlmiss'"
			putexcel B`startline' = "lblname missing"
		}
		putexcel save
	}

end


program define put_summary

	/* Creates summary with the number of differences for each worksheet in 
	the metafiles analysed
	*/

	syntax, file(str) [worksheet(str) diffs(int 0)]
	
	local startline = `num_lines' + 4
	quietly {
		putexcel set "`file'", sheet("Summary") open modify
		if ${diffs__} == 0 {
			putexcel A2 = "Differences Summary", bold
			putexcel A4 = "Worksheet", bold underline
			putexcel B4 = "Count", bold underline	
		}
		else {
			local cellnum = 4 + ${diffs__}
			putexcel A`cellnum' = "`worksheet'"
			putexcel B`cellnum' = `diffs'
		}
		
		putexcel save
	}

end


