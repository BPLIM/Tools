*! linkbank v2.0.0
*! Author: Emma Zhao and Ana Isabel Sa
*! Date:04nov2025
*! Description: Link credit data to BBS and SLB data
*! Coverage period: December 1999 to December 2024

capture program drop linkbank
program define linkbank
	version 19
	syntax varlist (min=2 max=2) [if] [in] , [ ///
		BASE(string)                       /// Database to match with
	]

	di
	version 19
	local version_ado "2.0.0"

	tokenize `varlist'

	tempfile temp

	* Get file path
	mata: st_local("file_corresp", findfile("linkbank.dta"))

	* Check data label by loading dataset
	preserve
	quietly use "`file_corresp'", clear
	local file_label : data label
	restore

	* Verify label matches expected version
	if "`file_label'" != "linkbank_auxfile_`version_ado'" {
		display as error "Error: linkbank.dta has incorrect label"
		display as error "Expected: linkbank_auxfile_`version_ado'"
		display as error "Found: `file_label'"
		error 610
	}

	* Options need to be applied
	if "`base'" == "" {
		di as error "must specify base option"
		error 198
	}
	
	* Clean variables created by previous runs of linkbank
	cap drop id_"`base'"
	cap drop note_"`base'"
	cap drop tmp_date 
	cap drop tmp_bina

	* Validates timeid format: only %tm and %td allowed. 
	* Creates a tmp_date of format %tm equals to linkbank_auxfile. Creates tmp_bina

	local varformat: format `2'

	if (`2'< 10000 & `2'> 1000) {
		di as error "Error: Please confirm that you timeid is monthly (%tm) or daily (%td)."
		error 120
	}
	else if substr("`varformat'",1,3)=="%td" | `2'> 10000 {
		qui gen tmp_date = mofd(`2')
	}
	else if substr("`varformat'",1,3)=="%tm" | `2'< 1000  {
		qui gen tmp_date = `2'
	}
	
	gen tmp_bina = `1'
	
	
**************	
	
	*For base==BBS
	if "`base'" == "bbs" {
		qui merge m:1 tmp_bina tmp_date using "`file_corresp'", keep(1 3) keepusing(id_bbs note_bbs) nogen
		drop tmp_date tmp_bina
	}

**************	
	
	*For base==SLB
	if "`base'" == "slb" {
		qui merge m:1 tmp_bina tmp_date using "`file_corresp'", keep(1 3) keepusing(id_slb note_slb) nogen
		drop tmp_date tmp_bina
	}
	
	
	*Final setup
	order `2' `1' id_`base' note_`base'
	
	di as result "------------------------------------------------------------------------------"
	di as result "{bf:Linkbank completed:}"
	di as result ""
	di as result "- Variable {bf:id_`base'} contains the linking ids for `base'."
	di as result "- Variable {bf:note_`base'} provides additional info on id_`base':"
	tab note_`base', missing
	di as result ""
	di as result "* note_`base'=. when bankid=id_`base'"
	di as result ""	
	di as result "------------------------------------------------------------------------------"
end
