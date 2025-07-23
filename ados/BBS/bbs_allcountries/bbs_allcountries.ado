*! version 1.0 21Jul2025
* Programmed by Ana Isabel Sá
//Program to calculate the total value of balance sheet items across all countries in the Monetary Financial Institutions Balance Sheet Database (BBS)
//Only for extractions up to JUN22
//Ana Isabel Sá
//Version 1.0 (21Jul2025)

cap program drop bbs_allcountries
program define bbs_allcountries
syntax varlist (min=1)
	di " "
	di "***********************************************************************"
	di "Compute aggregate balance sheet items value for all countries"
	di "***********************************************************************"
	di " "
	
	// Check if the file name contains "JUN23"
	local filename: data label
	if "`filename'"==""{
		di as error "Data label not found. Please use the original datalabel."
		exit 198
	}
	
	if strpos("`filename'", "JUN23") {
		di as error "This program is not valid for JUN23 extraction. Please use the JUN22 extraction."
		exit 198
	}
	
	if strpos("`filename'", "JUN24") {
		di as error "This program is not valid for JUN24 extraction. Please use the JUN22 extraction."
		exit 198
	}
	
	if strpos("`filename'", "SEP1997") {
		di "Notes:"
		di "1. You are using the harmonized BBS dataset, which starts in September 1997. Please note that the instrument codes follow the classification valid until December 2014."
		di "2. Instrument ""999 Residual - Assets minus Liabilities"" guarantees the Accounting Identity (A = L + E) and is reported in the asset file with missing country."
	}
	
	if strpos("`filename'", "SEP1997") & strpos("`filename'", "ASSET"){
		di "3. The program automatically excludes the financial instrument ""90 Units"" when computing total assets, as it is already included in ""80 Equity Securities"". This prevents double counting and requires that the variable instrument_asset is in the dataset, even if the aggregation is not performed by instrument_asset. Please refer to the manual for details."
		di " "
	}
	
	if strpos("`filename'", "DEC2014") {
		di "Notes:"
		di "1. You are using the BBS dataset that starts in December 2014. Please note that the instrument codes follow the classification valid from December 2014 onwards."
		di "2. Instrument ""999 Residual - Assets minus Liabilities"" guarantees the Accounting Identity (A = L + E) and is reported in the asset file with missing country."
		di " "
	}
			
	di "Country aggregation rule: country==TP-UM | country==UM-PT | country==PRT | missing(country)"

	preserve
		
	// Clean varlist if value or country are included
	local cleanlist

	foreach var of local varlist {
		if inlist("`var'", "value", "country") == 0 {
			local cleanlist `cleanlist' `var'
		}
	}
	
	if "`varlist'" != "`cleanlist'" {
		di "There is no need to include value and country in vars."
	}
		
	local varlist `cleanlist'
	
	foreach l of local varlist {
		if ("`l'"!="date" & "`l'"!="bina" & "`l'"!="instrument_liab" & "`l'"!="counterparty_liab" & "`l'"!="instrument_asset" & "`l'"!="counterparty_asset" &"`l'"!="inst_type") {
			di as err "Error: variable `l' is not available in the original dataset."
			exit 101
		}
	}
	
	// Define list of required variables- If harmonized BBS - ASSET, then instrument_asset is mandatory to correct for double counting
	if strpos("`filename'", "ASSET") & strpos("`filename'", "SEP1997") {
		local required_vars `varlist' value country instrument_asset
	} 
	else {
		local required_vars `varlist' value country 
	}
	
	// Validate if all required variables are in the dataset
	local missing_vars

	qui foreach var of local required_vars {
		capture confirm variable `var'
		if _rc {
			local missing_vars "`missing_vars' `var'" 
		}
	}
		
	qui if "`missing_vars'" != "" {
		di as error "Missing required variable(s):`missing_vars'."
		exit 111
	}
	
	// Drop instrument_asset==90 to avoid double counting in harmonized BBS- ASSET
	if strpos("`varlist'", "instrument_asset")==0 & (strpos("`filename'", "SEP1997")>0 & strpos("`filename'", "ASSET")>0){
		drop if instrument_asset==90 
		di " "
		di "Financial instrument ""90 Units"" was excluded to avoid double counting (it is already included in ""80 Equity Securities""). Please refer to the manual for details."
	}
		
	// Keep only required variables 
	keep `required_vars'
	
	restore
		
	// Create aggregation flag	
	tempvar temp
	qui gen `temp'=1 if country=="TP-UM" | country=="UM-PT" | country=="PRT" | missing(country)
	qui replace `temp'=0 if missing(`temp')

	// Filter data
	qui keep if `temp'==1
	qui drop `temp'

	// Compute aggregated balance sheet item value
	qui collapse (sum) value, by("`varlist'")
	qui label variable value "value"
	
	
end
