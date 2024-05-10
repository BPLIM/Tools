*! version 0.1 12Feb2024
* Programmed by Gustavo Iglésias

program define metaxl_stats

	version 16

	syntax, [                    ///
	    METAfile(str)            ///
		EXCludevars(varlist)     ///
		NOFreq(varlist)          ///
		TIMEvar(varname numeric) ///
		PANELvars(varlist)       ///
		SAVE(str)                ///
		STATS(str)               ///
	    REPLACEstats             ///
	] 
	
	if "`panelvars'" != "" {
		if "`timevar'" == "" {
			di "{err:You must set a time variable (option {bf:timevar}) when using option {bf:panelvars}}"
			exit 198
		}
		else {
			qui gunique `panelvars' `timevar'
			if r(unique) != r(N) {
				di "{err:Repeated {bf:`timevar'} inside {bf:`panelvars'}}"
				exit 451
			}
		}
	}

	* Error if save file already exists
	if (`"`save'"' != "") {
		gettoken savefile replacesave: save, p(",")
		local savefile = trim("`savefile'")
		//local savefile "`savefile'.xlsx"
		gettoken lixo replacesave: replacesave, p(",")
		cap confirm file "`savefile'.xlsx"
		if !_rc & trim("`replacesave'") != "replace" {
			di `"{err:File {bf:`savefile'.xlsx} already exists. Please specify }"' ///
			`"{err:sub-option {bf:replace} to overwrite the existing file}"'
			exit 602
		}
		else {
			cap rm "`savefile'.xlsx"
		}
	}
	* If metafile is empty...
	if (`"`metafile'"' == "") {
		* If save is empty -> error
		if `"`save'"' == "" {
			di "{err:Option {bf:save} must be set if option {bf:metafile} is empty}"
			exit 198	
		}
		* Else -> create metadata file to add the statistics
		else {
			metaxl extract, meta(`savefile')
			local savefile "`savefile'.xlsx"
		}
	}
	* If the metafile is not empty...
	else {
		* Confirm that the file exists
		confirm file `"`metafile'.xlsx"'
		* If save is set, we are going save the meta file with stats under a different name 
		if `"`save'"' != "" {
			copy `"`metafile'.xlsx"' `"`savefile'.xlsx"'
			local savefile "`savefile'.xlsx"
		} 
		* Else, add stats to the existing meta data file 
		else {
			local savefile "`metafile'.xlsx"
		}
	}
	
	* Select which statistics to export
	if "`stats'" != "" {
		parse_stats, stats(`stats')
		local stats "`r(stats_list)'"
	}
	else {
		local stats "mean sd p5 p50 p95"
	}
	* Add shares and time stats
	if ("`timevar'" == "") {
		local stats_all `stats' sharezeros shareneg sharemiss
	}
	else if ("`timevar'" != "" & "`panelvars'" == "") {
		local stats_all `stats' sharezeros shareneg sharemiss datemin datemax
	}
	else {
		local stats_all `stats' sharezeros shareneg sharemiss shareinv datemin datemax
	}
	

	get_meta, meta(`savefile') exc(`excludevars') no("`nofreq'")
	if ("`r(filename)'" != "${S_FN}") {
		di 
		di "{err:File in memory does not match metadata info}"
		di "{text:File in meta data: {bf:`r(filename)'}}"
		di "{text:File in memory: {bf:${S_FN}}}"
		di 
	}
	local vars "`r(variables)'"
	foreach var in `vars' {
		if ("`r(`var'_vl)'" != "") {
			local `var'_vl = "`r(`var'_vl)'"
		}
	}
	tempname framestats
	qui frame create `framestats' 
	frame `framestats' {
		qui {
			import excel "`savefile'", sheet("variables") firstrow clear
			foreach stat in `stats_all' {
				if inlist("`stat'", "datemin", "datemax") {
					cap gen long `stat' = .
				}
				else {
					cap gen double `stat' = .
				}
				if _rc {
					if ("`replacestats'" != "replacestats") {
						noi di "{err:Variable {bf:`stat'} already defined in }" ///
							"{err:worksheet {bf:variables} [{bf:`savefile'}]}"
						exit 110
					}
					else {
						drop `stat'
						if inlist("`stat'", "datemin", "datemax") {
							gen long `stat' = .
						}
						else {
							gen double `stat' = .
						}
					}
				}
			} 
		}
	}

	* Add stats
	foreach var in `vars' {
		cap confirm var `var' 
		if _rc {
			di 
			di "{err:Variable {bf:`var'} from metafile not found. Skipping...}"
		}
		else {
			if (substr("`:type `var''", 1, 3) == "str") {
				di 
				di "{err:Skipping string variable {bf:`var'}}"
			}
			else {
				di
				di "{text:Working on variable {bf:`var'}}"
				di 
				qui sum `var', detail
				* Statistics
				foreach stat in `stats' {
					local `stat' = r(`stat')
				}
				di "`stats'...done"
				* Share of zeros
				qui count if `var' == 0
				local sharezeros = `r(N)' / _N
				di "Share of zeros...done"
				* Share of negatives
				qui count if `var' < 0
				local shareneg = `r(N)' / _N
				di "Share of negatives...done"
				* Share of missing
				qui count if missing(`var')
				local sharemiss = `r(N)' / _N
				di "Share of missing...done"
				if ("`timevar'" != "") {
					* Min and Max dates
					qui sum `timevar' if !missing(`var')	
					local datemin = `r(min)'
					local datemax = `r(max)'
					di "Min and max dates...done"
					if ("`panelvars'" != "") {
						* Share of invariant
						tempvar var_max diff
						quietly {
							bysort `panelvars' (`timevar'): egen `var_max' = max(`var')
						}
						qui gen `diff' = ((`var_max' - `var') > 0) * (!missing(`var'))
						qui count if `diff' == 0
						local shareinv = `r(N)' / _N
						drop `var_max' `diff'
						di "Share of time invariant...done"	
					}
				}
				* Dump into stats frame
				frame `framestats' {
					foreach stat in `stats_all' {
						qui replace `stat' = ``stat'' if variable == "`var'"
					}					
				}
				* Add shares for categorical variables 
				if ("``var'_vl'" != "" & "`nofreq'" != "_all") {
					add_probs, meta(`savefile') var(`var') vl(``var'_vl') ///
						sharemiss(`sharemiss') `replacestats'
				}
			}
		}
	}
	
	frame `framestats' {
		qui export excel using "`savefile'", sheet("variables", replace) keepcellfmt first(var)
		di 
		di "{text:Stats and shares added to variables in {res:`savefile'}}"
	}
	
	frame drop `framestats'
end


program define add_probs

	syntax, METAfile(str) var(str) vl(str) [sharemiss(real 0) replacestats]
	
	tempname frameprob
	frame create `frameprob'
	
	* generate probabilities
	qui tab `var', matcell(prob) matrow(value)
	mat prob = prob / _N
	mat prob = value, prob

	local rows = rowsof(prob)
	frame `frameprob' {	
		qui import excel "`metafile'", sheet("vl_`vl'") firstrow clear
		cap gen double freq_`var' = .
		if _rc {
			if ("`replacestats'" != "replacestats") {
				di 
				di "{err:Variable {bf:freq_`var'} already defined in worksheet {bf:vl_`vl'}}" ///
					"{err: [{bf:`metafile'}]}"
				exit 110
			}
			else {
				drop freq_`var'
				qui gen double freq_`var' = .
			}
		}
		forvalues i = 1/`rows' {
			local value = prob[`i', 1]
			local prob = prob[`i', 2]
			qui replace freq_`var' = `prob' if value == `value'
		}
		qui replace freq_`var' = 0 if missing(freq_`var')
		* Scale probabilities 
		if (`sharemiss' > 0) {
			qui replace freq_`var' = freq_`var' / (1 - `sharemiss')
		}
		qui export excel using "`metafile'", sheet("vl_`vl'", replace) keepcellfmt first(var)
	}
	
	frame drop `frameprob'
	
	di 
	di "{text:Add categories' shares to worksheet {res:vl_`vl'}}"
	

end


program define get_meta, rclass

	syntax, METAfile(str) [EXCludevars(str) NOfreq(str)]
	
	preserve
	
		qui import excel "`metafile'", sheet("variables") allstring firstrow clear
		
		qui count
		forvalues i = 1/`r(N)' {
			local var = variable[`i']
			local variables = "`variables'" + " `var'"
			foreach col of varlist value_label* {
				local `var'_vl = trim(`col'[`i'])
				if ("``var'_vl'" != "") continue, break
			}
		}
		local variables = trim("`variables'")
		local variables: list variables - excludevars
		foreach var in `variables' {
			if ("`nofreq'" != "") {
			    if ("``var'_vl'" != "") {
					innoprobs `var', noprobs(`nofreq')
					if (!`r(in)') return local `var'_vl = "``var'_vl'"
				}
			}
			else {
				return local `var'_vl = "``var'_vl'"
			}
		}
		
		return local variables = "`variables'"
		
		qui import excel "`metafile'", sheet("data_features_gen") allstring firstrow clear
		
		return local filename = Content[1]

	restore

end


program define innoprobs, rclass

	syntax name, NOprobs(str) 

	local in 0 
	
	foreach var in `noprobs' {
		if ("`namelist'" == "`var'") {
			local in 1
			continue, break
		}
	}
	
	return local in = `in'

end


program define parse_stats, rclass

	syntax, stats(str)
	
	local stats_list N sum_w mean Var sd skewness kurtosis sum min max ///
		p1 p5 p10 p25 p50 p75 p90 p95 p99
		
	if trim("`stats'") == "_all" {
		return local stats_list `stats_list'
	}
	else {
		local stats: list uniq stats
		local common: list stats & stats_list
		local not_found: list stats - common
		if trim("`not_found'") != "" {
			di 
			di "{err:Warning: statistics {bf:`not_found'} not available}"
		}
		return local stats_list `common'
	}

end
