*! version 0.3 12Feb2024
* Programmed by Gustavo Iglésias

program define mdata

/*
wrapper for commands mdata_extract, mdata_apply, mdata_combine,
mdata_check, mdata_cmp, mdata_morph, mdata_diff, mdata_stats and mdata_clear
*/

version 16

syntax anything [, *]

local command = trim(`"`1'"')
gettoken command: command, p(",")

if "`command'" == "extract" {
	mdata_extract, `options'
}
else if "`command'" == "apply" {
	mdata_apply, `options'
}
else if "`command'" == "combine" {
	mdata_combine, `options'
}
else if "`command'" == "check" {
	mdata_check, `options'
}
else if "`command'" == "cmp" {
	mdata_cmp, `options'
}
else if "`command'" == "uniform" {
	mdata_uniform, `options'
}
else if "`command'" == "morph" {
	local morph_arg = trim(substr("`anything'", 6, .))
	mdata_morph `morph_arg', `options'
}
else if "`command'" == "diff" {
	mdata_diff, `options'
}
else if "`command'" == "stats" {
	mdata_stats, `options'
}
else if "`command'" == "clear" {
	mdata_clear
}
else {
	di
	di as error `"Possible subcommands for mdata are "extract", "apply", "' ///
	`""combine", "check", "cmp", "morph", "stats", "uniform", "diff" and "clear""'
	exit 198
}


end
