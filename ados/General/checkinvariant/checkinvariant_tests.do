cap program drop checkinvariant
qui do checkinvariant.ado

set varabbrev off

clear
set obs 10000

gen id = floor((_n-1)/5)+1

gen invariantnumber = 2* (mod(id,5)+1)
gen   variantnumber = runiform()
gen invariantnumbermissing = invariantnumber if mod(_n,3)
gen   variantnumbermissing  =  variantnumber if mod(_n,4)

gen invariantstring = "bla" * (mod(id,9)+1)
gen   variantstring = "bla" * (mod(_n,4)+1)
gen invariantstringmissing = invariantstring if mod(_n,3)
gen   variantstringmissing  =  variantstring if mod(_n,4)

* Standard tests
checkinvariant _all, by(id) verbose
assert r(invariantvarlist) == "invariantnumber invariantstring"
assert   r(variantvarlist) == "variantnumber invariantnumbermissing variantnumbermissing variantstring invariantstringmissing variantstringmissing"

checkinvariant _all, by(id) verbose allowmissing
assert r(invariantvarlist) == "invariantnumber invariantnumbermissing invariantstring invariantstringmissing"
assert   r(variantvarlist) == "variantnumber variantnumbermissing variantstring variantstringmissing"

* Testing when always missing
gen alwaysmissnumber = .
gen alwaysmissstring = ""

checkinvariant alwaysmiss*, by(id) verbose
assert r(invariantvarlist) == "alwaysmissnumber alwaysmissstring"
assert r(numvariant) == 0
checkinvariant alwaysmiss*, by(id) verbose allowmissing
assert r(invariantvarlist) == "alwaysmissnumber alwaysmissstring"
assert r(numvariant) == 0

preserve
* Testing the fill option
checkinvariant *miss*, by(id) verbose allowmissing fill
assert r(numfilled) == 2
assert r(numvariant) == 2
assert r(numinvariant) == 2

checkinvariant invariantnumbermissing invariantstringmissing, by(id)
assert r(numvariant) == 0
assert mi(variantnumbermissing) if !mod(_n,4)
assert mi(variantnumbermissing) if !mod(_n,4)
restore

* Testing the keep and drop options
* In this test, they are mirrors of each others as there are no additional not called variables
preserve
checkinvariant _all, by(id) keepinvariant
confirm variable 		id invariantnumber invariantstring alwaysmissnumber alwaysmissstring
confirm new variable 	variantnumber invariantnumbermissing variantnumbermissing variantstring invariantstringmissing variantstringmissing
restore

preserve
checkinvariant _all, by(id) keepvariant
confirm variable 		id variantnumber invariantnumbermissing variantnumbermissing variantstring invariantstringmissing variantstringmissing
confirm new variable 	invariantnumber invariantstring alwaysmissnumber alwaysmissstring
restore

preserve
checkinvariant _all, by(id) dropvariant
confirm variable 		id invariantnumber invariantstring alwaysmissnumber alwaysmissstring
confirm new variable 	variantnumber invariantnumbermissing variantnumbermissing variantstring invariantstringmissing variantstringmissing
restore

preserve
checkinvariant _all, by(id) dropinvariant
confirm variable 		id variantnumber invariantnumbermissing variantnumbermissing variantstring invariantstringmissing variantstringmissing
confirm new variable 	invariantnumber invariantstring alwaysmissnumber alwaysmissstring
restore

* allowmissing
preserve
checkinvariant _all, by(id) allowmissing fill keepinvariant
confirm variable 		id invariantnumber invariantstring alwaysmissnumber alwaysmissstring invariantnumbermissing invariantstringmissing
confirm new variable 	variantnumber  variantnumbermissing variantstring variantstringmissing
restore

preserve
checkinvariant _all, by(id) allowmissing fill keepvariant
confirm variable 		id variantnumber  variantnumbermissing variantstring variantstringmissing
confirm new variable 	invariantnumber invariantnumbermissing  invariantstringmissing invariantstring alwaysmissnumber alwaysmissstring
restore

preserve
checkinvariant _all, by(id) allowmissing fill dropvariant
confirm variable 		id invariantnumber invariantstring alwaysmissnumber alwaysmissstring invariantnumbermissing invariantstringmissing
confirm new variable 	variantnumber variantnumbermissing variantstring variantstringmissing
restore

preserve
checkinvariant _all, by(id) allowmissing fill dropinvariant
confirm variable 		id variantnumber  variantnumbermissing variantstring variantstringmissing
confirm new variable 	invariantnumber invariantnumbermissing  invariantstringmissing invariantstring alwaysmissnumber alwaysmissstring
restore

* Testing for keep and drop when not all variables are called
preserve
checkinvariant *number*, by(id) keepinvariant
confirm variable id invariantnumber alwaysmissnumber
confirm new variable variantnumber invariantnumbermissing variantnumbermissing invariantstring variantstring invariantstringmissing variantstringmissing alwaysmissstring
restore

preserve
checkinvariant *number*, by(id) keepinvariant allowmissing
confirm variable id invariantnumber alwaysmissnumber invariantnumbermissing
confirm new variable variantnumber variantnumbermissing invariantstring variantstring invariantstringmissing variantstringmissing alwaysmissstring
restore

preserve
checkinvariant *number*, by(id) dropinvariant
confirm variable id variantnumber invariantnumbermissing variantnumbermissing invariantstring variantstring invariantstringmissing variantstringmissing alwaysmissstring
confirm new variable invariantnumber alwaysmissnumber
restore

preserve
checkinvariant *number*, by(id) dropinvariant allowmissing
confirm variable id variantnumber variantnumbermissing invariantstring variantstring invariantstringmissing variantstringmissing alwaysmissstring
confirm new variable invariantnumber alwaysmissnumber invariantnumbermissing
restore

preserve
checkinvariant *number*, by(id) keepvariant
confirm variable id variantnumber invariantnumbermissing variantnumbermissing
confirm new variable invariantnumber alwaysmissnumber invariantstring variantstring invariantstringmissing variantstringmissing alwaysmissstring

restore
preserve
checkinvariant *number*, by(id) keepvariant allowmissing
confirm variable id variantnumber  variantnumbermissing
confirm new variable invariantnumber alwaysmissnumber invariantnumbermissing invariantstring variantstring invariantstringmissing variantstringmissing alwaysmissstring
restore

preserve
checkinvariant *number*, by(id) dropvariant
confirm variable id  invariantnumber alwaysmissnumber  invariantstring variantstring invariantstringmissing variantstringmissing alwaysmissstring
confirm new variable  variantnumber  invariantnumbermissing variantnumbermissing
restore

preserve
checkinvariant *number*, by(id) dropvariant allowmissing
confirm variable id  invariantnumber alwaysmissnumber  invariantnumbermissing invariantstring variantstring invariantstringmissing variantstringmissing alwaysmissstring
confirm new variable  variantnumber  variantnumbermissing  
restore
