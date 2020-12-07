*! version 0.3 04Nov2020
* Programmed by Gustavo Iglésias
* Dependencies: Python 3 (requests and pandas)

program define bpstat

/*
wrapper for commands bpstatuse, bpstatdlg, bpstatsearch,
bpstatdescribe and bpstatbrowse
*/

version 16

syntax anything [, *]

local command = trim(`"`1'"')
gettoken command: command, p(",")

if "`command'" == "use" {
	bpstatuse, `options'
}
else if "`command'" == "browse" {
	bpstatbrowse, `options'
}
else if "`command'" == "describe" {
	bpstatdescribe, `options'
}
else if "`command'" == "search" {
	bpstatsearch, `options'
}
else if "`command'" == "dlg" {
	if `"`options'"' == "" {
		bpstatdlg
	}
	else {
		bpstatdlg, `options'
	}
}
else {
	di as error `"Possible subcommands for bpstat are "use", "dlg", "search", "describe" and "browse""'
	exit 198
}


end
