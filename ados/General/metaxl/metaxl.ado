*! version 0.4 29Aug2024
* Programmed by Gustavo Iglésias

program define metaxl

/*
wrapper for commands metaxl_extract, metaxl_apply, metaxl_combine,
metaxl_check, metaxl_cmp, metaxl_morph, metaxl_diff, metaxl_stats and metaxl_clear
*/

version 16

syntax anything [, *]

* Check dependencies 
foreach package in gtools filelist {
	cap which `package'
	local rc = _rc
	if _rc {
		di "{err:This tool requires packages {bf:gtools} and {bf:filelist}. }" ///
		"{err:{bf:`package'} is not installed in your system}"
		exit `rc'
	}
}

local command = trim(`"`1'"')
gettoken command: command, p(",")

if "`command'" == "extract" {
	metaxl_extract, `options'
}
else if "`command'" == "apply" {
	metaxl_apply, `options'
}
else if "`command'" == "combine" {
	metaxl_combine, `options'
}
else if "`command'" == "check" {
	metaxl_check, `options'
}
else if "`command'" == "cmp" {
	metaxl_cmp, `options'
}
else if "`command'" == "uniform" {
	metaxl_uniform, `options'
}
else if "`command'" == "morph" {
	local morph_arg = trim(substr("`anything'", 6, .))
	metaxl_morph `morph_arg', `options'
}
else if "`command'" == "diff" {
	metaxl_diff, `options'
}
else if "`command'" == "stats" {
	metaxl_stats, `options'
}
else if "`command'" == "clear" {
	metaxl_clear, `options'
}
else {
	di
	di as error `"Possible subcommands for metaxl are "extract", "apply", "' ///
	`""combine", "check", "cmp", "morph", "stats", "uniform", "diff" and "clear""'
	exit 198
}


end
