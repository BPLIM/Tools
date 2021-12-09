*! version 0.1 5Aug2020
* Programmed by Gustavo Iglésias

program define adoinstall

version 13

syntax namelist(min=1 max=1), to(string) [FRom(string) REPLACE ALL FORCE]

local pkgname "`namelist'"
local oldplus "`c(sysdir_plus)'"

* Change PLUS adopath
sysdir set PLUS `"`to'"'

* SSC installation is assumed if option FROM is empty
if "`from'" == "" {
	cap noi ssc install `pkgname', `all' `replace' 
	local rc = _rc
	if _rc {
		* Reset PLUS adopath in case of error
		sysdir set PLUS `"`oldplus'"'
		exit `rc'
	}
}
else {
	cap noi net install `pkgname', from(`from') `all' `replace' `force'
	local rc = _rc
	if _rc {
		* Reset PLUS adopath in case of error
		sysdir set PLUS `"`oldplus'"'
		exit `rc'
	}
}

* Reset PLUS adopath
sysdir set PLUS `"`oldplus'"'

end

