* Programmed by Emma Zhao
* version 1.0, 20Mar2023
* CRC, BBS, SLB & QP Merge, apply to CRC data

capture program drop linkbank
program define linkbank
*set trace on

syntax varlist (min=2 max=2) [if] [in] , [ ///
	BASE(string)                       /// Database to match with
	METhod(string)                     /// Matching method
	replace                            /// Replace the old id with the new id
	GENerate(name)                     /// Creates the new id
	KEEPIndicator                      /// Keep the matching indicator for matching
	ADD(name)                          /// Add banking group infos, and bank event infos
]

di
version 15
tokenize `varlist'

tempfile temp
tempvar date_m year maxdate


* Get file path
mata: st_local("file_corresp", findfile("bplimlink_bnk.dta"))


* Options need to be applied
if "`base'" == "" {
	di as error "must specify base option"
	error 198
}

if "`replace'" == "" & "`generate'" == "" {
	di as error "must specify either replace or generate option"
	error 198
}

local varformat: format `2'

if (`2'< 10000 & `2'> 1000) {

	di as error "Error: Please confirm that you have a monthly or daily dataset."
	error 120

}
else if substr("`varformat'",1,3)=="%td" | `2'> 10000 {
	qui gen `date_m' = mofd(`2')

}
else if substr("`varformat'",1,3)=="%tm" | `2'< 1000  {
	qui gen `date_m' = `2'

}

cap drop date
rename `date_m' date

cap drop indicator
cap drop grupo
cap drop tipo_filiacao
cap drop event_type
cap drop type_participant
cap drop _merge

qui merge m:1 `1' date using "`file_corresp'", keep(1 3)

if "`base'" == "BBS" {


	if "`method'" == "Both" | "`method'" == ""  {

		if "`replace'" != "" & "`generate'" == "" {
			qui replace `1' = maininst if maininst!=.
		}

		else if "`replace'" == "" & "`generate'" != "" {
			qui gen double `generate'=`1'
			qui replace `generate' = maininst if maininst!=.
			qui label var `generate' "New ID"
		}

	}

	else if "`method'" == "MA" {

		if "`replace'" != "" & "`generate'" == "" {
			qui replace `1' = maininst if maininst!=. & indicator==1
		}

		else if "`replace'" == "" & "`generate'" != "" {
			qui gen double `generate'=`1'
			qui replace `generate' = maininst if maininst!=. & indicator==1
			qui label var `generate' "New ID"
		}

	}

	else if "`method'" == "group" {

		if "`replace'" != "" & "`generate'" == "" {
			qui replace `1' = maininst if maininst!=. & indicator==4
		}

		else if "`replace'" == "" & "`generate'" != "" {
			qui gen double `generate'=`1'
			qui replace `generate' = maininst if maininst!=. & indicator==4
			qui label var `generate' "New ID"
		}

	}


	if "`keepindicator'" == "" {
		drop indicator maininst indicator_slb maininst_slb
	}

	else if "`keepindicator'" != "" {
		drop maininst indicator_slb maininst_slb
		qui replace indicator = 99 if _m==1
		qui label var indicator "Matching indicator"
	}

}


if "`base'" == "SLB" {


	if "`method'" == "Both" | "`method'" == "" {

		if "`replace'" != "" & "`generate'" == "" {
			qui replace `1' = maininst_slb if maininst_slb!=.
		}

		else if "`replace'" == "" & "`generate'" != "" {
			qui gen double `generate'=`1'
			qui replace `generate' = maininst_slb if maininst_slb!=.
			qui label var `generate' "New ID"
		}

	}

	else if "`method'" == "MA" {

		if "`replace'" != "" & "`generate'" == "" {
			qui replace `1' = maininst_slb if maininst_slb!=. & indicator_slb==1
		}

		else if "`replace'" == "" & "`generate'" != "" {
			qui gen double `generate'=`1'
			qui replace `generate' = maininst_slb if maininst_slb!=. & indicator_slb==1
			qui label var `generate' "New ID"
		}

	}

	else if "`method'" == "group" {

		if "`replace'" != "" & "`generate'" == "" {
			qui replace `1' = maininst_slb if maininst_slb!=. & indicator_slb==4
		}

		else if "`replace'" == "" & "`generate'" != "" {
			qui gen double `generate'=`1'
			qui replace `generate' = maininst_slb if maininst_slb!=. & indicator_slb==4
			qui label var `generate' "New ID"
		}

	}

	if "`keepindicator'" == "" {
		qui drop indicator maininst indicator_slb maininst_slb
	}

	else if "`keepindicator'" != "" {
		qui drop indicator maininst maininst_slb
		qui replace indicator_slb = 99 if _m==1
		qui rename indicator_slb indicator
		qui label var indicator "Matching indicator"
	}

}

drop _m

if "`add'" == "" {
	qui drop tipo grupo tipo_filiacao event_type type_participant
}
else if "`add'" == "all" {
	qui label var grupo "banking group"
	qui label var tipo_filiacao "Type of affiliation"
	qui label var event_type "Event type"
	qui label var type_participant "Event counterparty"
}
else if "`add'" == "group" {
	qui drop tipo event_type type_participant
	qui label var grupo "banking group"
	qui label var tipo_filiacao "Type of affiliation"
}
else if "`add'" == "event" {
	qui drop tipo grupo tipo_filiacao
	qui label var event_type "Event type"
	qui label var type_participant "Event counterparty"
}

else if "`add'" != "" & "`add'" != "all" & "`add'" != "group" & "`add'" != "event" {
	qui drop tipo grupo tipo_filiacao event_type type_participant
	di as error  "Option not available"
	error 197

}

order `varlist'
format `2' `varformat'

end
