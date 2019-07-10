*! version 1.2 18Dec2018
* Programmed by Marta Silva
//Program to calculate the economic and financial indicators available in the harmonized panel of Central de Balanços
//Marta Silva
//Version 1.2 (18 December 2018)

program define cbhp_addindic
syntax newvarlist (min=1) [if] [in] , [ ///
SAVE(string)  /// save the calculated indicators in a separate dataset
]

*if newvarlist=all    /// to select all the indicators available in the harmonized panel

local newvarlist `varlist'
tokenize `newvarlist'


if "`newvarlist'"=="all" {
local newvarlist "R001 R002 R003 R006 R007 R009 R023 R034 R036 R040 R041 R050 R056 R150 R152 R155 R156 R157 R158 R159 R160 R161"
}

foreach l of local newvarlist {
if ("`l'"!="R001" & "`l'"!="R002" & "`l'"!="R003" & "`l'"!="R006" & "`l'"!="R007" & "`l'"!="R009" & "`l'"!="R023" & "`l'"!="R034" & "`l'"!="R036" & "`l'"!="R040" & "`l'"!="R041" & "`l'"!="R050" & "`l'"!="R056" & "`l'"!="R150" & "`l'"!="R152" & "`l'"!="R155" & "`l'"!="R156" & "`l'"!="R157" & "`l'"!="R158" & "`l'"!="R159" & "`l'"!="R160" & "`l'"!="R161") {
di as err "Error: variable `l' is not available"
}
}

di _newline(1)

quietly label language
local lg="`r(language)'"

quietly ds
local varlist1 `r(varlist)'



foreach l of local newvarlist {
if ("`l'"=="R001") {
//R001
quietly capture confirm variable B029 B089
if !_rc {
quietly gen double R001=(B029/B089)

quietly count if B089==0
if r(N)>0 {
display "R001: `r(N)' observations with B089=0 replaced by missing value(s)"
}
quietly count if B089<0
if r(N)>0 {
display "R001: `r(N)' observations with B089<0 replaced by missing value(s)"
}
quietly count if abs(B029/B089)>100
if r(N)>0 {
display "R001: `r(N)' observations with ABS(B029/B089)>100 replaced by missing value(s)"
}

quietly replace R001=. if (B089<=0 | abs(B029/B089)>100)
quietly replace R001=0 if B029==0 & !(B089<=0 | abs(B029/B089)>100)

quietly label language pt
quietly label variable R001 "Liquidez geral"
quietly label language en 
quietly label variable R001 "Current ratio"
quietly label language `lg'
}
else {
di as err "Error: variable B029 and/or B089 not found"
}
}



if ("`l'"=="R002") {
//R002
di _newline(1)
quietly capture confirm variable B029 B032 B089
if !_rc {
quietly gen double R002=((B029-B032)/B089)

quietly count if B089==0
if r(N)>0 {
display "R002: `r(N)' observations with B089=0 replaced by missing value(s)"
}
quietly count if B089<0
if r(N)>0 {
display "R002: `r(N)' observations with B089<0 replaced by missing value(s)"
}
quietly count if abs((B029-B032)/B089)>100
if r(N)>0 {
display "R002: `r(N)' observations with ABS((B029-B032)/B089)>100 replaced by missing value(s)"
}

quietly replace R002=. if (B089<=0 | abs((B029-B032)/B089)>100)
quietly replace R002=0 if ((B029-B032)==0) & !(B089<=0 | abs((B029-B032)/B089)>100)

quietly label language pt
quietly label variable R002 "Liquidez reduzida"
quietly label language en 
quietly label variable R002 "Quick ratio"
quietly label language `lg'
}
else {
di as err "Error: variable B029 and/or B032 and/or B089 not found"
}
}



if ("`l'"=="R003") {
di _newline(1)
//R003
quietly capture confirm variable B061 B001
if !_rc {
quietly gen double R003=(B061/B001)

quietly count if B001==0
if r(N)>0 {
display "R003: `r(N)' observations with B001=0 replaced by missing value(s)"
}
quietly count if B001<0
if r(N)>0 {
display "R003: `r(N)' observations with B001<0 replaced by missing value(s)"
}
quietly count if abs(B061/B001)>100
if r(N)>0 {
display "R003: `r(N)' observations with ABS(B061/B001)>100 replaced by missing value(s)"
}


quietly replace R003=. if (B001<=0 | abs(B061/B001)>100)
quietly replace R003=0 if B061==0 & !(B001<=0 | abs(B061/B001)>100)

quietly label language pt
quietly label variable R003 "Autonomia financeira - QS"
quietly label language en 
quietly label variable R003 "Capital ratio - QS"
quietly label language `lg'
}
else {
di as err "Error: variable B061 and/or B001 not found"
}
}


if ("`l'"=="R006") {
di _newline(1)
//R006
quietly capture confirm variable B001 B061
if !_rc {
quietly gen double R006=(B001/B061)

quietly count if B061==0
if r(N)>0 {
display "R006: `r(N)' observations with B061=0 replaced by missing value(s)"
}
quietly count if B061<0
if r(N)>0 {
display "R006: `r(N)' observations with B061<0 replaced by missing value(s)"
}
quietly count if abs(B001/B061)>100
if r(N)>0 {
display "R006: `r(N)' observations with ABS(B001/B061)>100 replaced by missing value(s)"
}

quietly replace R006=. if (B061<=0 | abs(B001/B061)>100)
quietly replace R006=0 if B001==0 & !(B061<=0 | abs(B001/B061)>100)

quietly label language pt
quietly label variable R006 "Taxa de endividamento"
quietly label language en 
quietly label variable R006 "Assets to equity ratio"
quietly label language `lg'
}
else {
di as err "Error: variable B061 and/or B001 not found"
}
}


if ("`l'"=="R007") {
di _newline(1)
//R007
quietly capture confirm variable B061 B080
if !_rc {
quietly gen double R007=(B061/B080)

quietly count if B080==0
if r(N)>0 {
display "R007: `r(N)' observations with B080=0 replaced by missing value(s)"
}
quietly count if B080<0
if r(N)>0 {
display "R007: `r(N)' observations with B080<0 replaced by missing value(s)"
}
quietly count if abs(B061/B080)>100
if r(N)>0 {
display "R007: `r(N)' observations with ABS(B061/B080)>100 replaced by missing value(s)"
}

quietly replace R007=. if (B080<=0 | abs(B061/B080)>100)
quietly replace R007=0 if B061==0 & !(B080<=0 | abs(B061/B080)>100)

quietly label language pt
quietly label variable R007 "Solvabilidade - QS"
quietly label language en 
quietly label variable R007 "Solvency ratio - QS"
quietly label language `lg'
}
else {
di as err "Error: variable B061 and/or B080 not found"
}
}

if ("`l'"=="R009") {
di _newline(1)
//R009
quietly capture confirm variable B061 B081 B004
if !_rc {
quietly gen double R009=((B061+B081)/B004)

quietly count if B004==0
if r(N)>0 {
display "R009: `r(N)' observations with B004=0 replaced by missing value(s)"
}
quietly count if B004<0
if r(N)>0 {
display "R009: `r(N)' observations with B004<0 replaced by missing value(s)"
}
quietly count if abs((B061+B081)/B004)>100
if r(N)>0 {
display "R009: `r(N)' observations with ABS((B061+B081)/B004)>100 replaced by missing value(s)"
}

quietly replace R009=. if (B004<=0 | abs((B061+B081)/B004)>100)
quietly replace R009=0 if (B061+B081)==0 & !(B004<=0 | abs((B061+B081)/B004)>100)

quietly label language pt
quietly label variable R009 "Cobertura dos activos não correntes"
quietly label language en 
quietly label variable R009 "Non-current assets coverage ratio"
quietly label language `lg'
}
else {
di as err "Error: variable B061 and/or B081 and/or B004 not found"
}
}


if ("`l'"=="R023") {
di _newline(1)
//R023
quietly capture confirm variable D086 D085
if !_rc {
quietly gen double R023=(D086/D085)

quietly count if D085==0
if r(N)>0 {
display "R023: `r(N)' observations with D085=0 replaced by missing value(s)"
}
quietly count if D085<0
if r(N)>0 {
display "R023: `r(N)' observations with D085<0 replaced by missing value(s)"
}
quietly count if abs(D086/D085)>100
if r(N)>0 {
display "R023: `r(N)' observations with ABS(D086/D085)>100 replaced by missing value(s)"
}

quietly replace R023=. if (D085<=0 | abs(D086/D085)>100)
quietly replace R023=0 if (D086==0) & !(D085<=0 | abs(D086/D085)>100)

quietly label language pt
quietly label variable R023 "Efeito dos juros suportados"
quietly label language en 
quietly label variable R023 "Financial Cost Effect"
quietly label language `lg'
}
else {
di as err "Error: variable D086 and/or D085 not found"
}
}


if ("`l'"=="R034") {
di _newline(1)
//R034
quietly capture confirm variable D082 D001
if !_rc {
quietly gen double R034=(D082/D001)

quietly count if D001==0
if r(N)>0 {
display "R034: `r(N)' observations with D001=0 replaced by missing value(s)"
}
quietly count if D001<0
if r(N)>0 {
display "R034: `r(N)' observations with D001<0 replaced by missing value(s)"
}
quietly count if abs(D082/D001)>100
if r(N)>0 {
display "R034: `r(N)' observations with ABS(D082/D001)>100 replaced by missing value(s)"
}

quietly replace R034=. if (D001<=0 | abs(D082/D001)>100)
quietly replace R034=0 if D082==0 & !(D001<=0 | abs(D082/D001)>100)

quietly label language pt
quietly label variable R034 "Rendibilidade económica das vendas (RE /VN)"
quietly label language en 
quietly label variable R034 "Return on sales"
quietly label language `lg'
}
else {
di as err "Error: variable D082 and/or D001 not found"
}
}


if ("`l'"=="R036") {
di _newline(1)
//R036
quietly capture confirm variable D084 B001
if !_rc {
quietly gen double R036=(D084/B001)

quietly count if B001==0
if r(N)>0 {
display "R036: `r(N)' observations with B001=0 replaced by missing value(s)"
}
quietly count if B001<0
if r(N)>0 {
display "R036: `r(N)' observations with B001<0 replaced by missing value(s)"
}
quietly count if abs(D084/B001)>100
if r(N)>0 {
display "R036: `r(N)' observations with ABS(D084/B001)>100 replaced by missing value(s)"
}

quietly replace R036=. if (B001<=0 | abs(D084/B001)>100)
quietly replace R036=0 if D084==0 & !(B001<=0 | abs(D084/B001)>100)

quietly label language pt
quietly label variable R036 "Rendibilidade do activo - QS"
quietly label language en 
quietly label variable R036 "Return on assets - QS"
quietly label language `lg'
}
else {
di as err "Error: variable D084 and/or B001 not found"
}
}


if ("`l'"=="R040") {
di _newline(1)
//R040
quietly capture confirm variable D084 D001
if !_rc {
quietly gen double R040=(D084/D001)

quietly count if D001==0
if r(N)>0 {
display "R040: `r(N)' observations with D001=0 replaced by missing value(s)"
}
quietly count if D001<0
if r(N)>0 {
display "R040: `r(N)' observations with D001<0 replaced by missing value(s)"
}
quietly count if abs(D084/D001)>100
if r(N)>0 {
display "R040: `r(N)' observations with ABS(D084/D001)>100 replaced by missing value(s)"
}

quietly replace R040=. if (D001<=0 | abs(D084/D001)>100)
quietly replace R040=0 if D084==0 & !(D001<=0 | abs(D084/D001)>100)

quietly label language pt
quietly label variable R040 "EBITDA em percentagem do Volume de negócios"
quietly label language en 
quietly label variable R040 "EBITDA over Turnover"
quietly label language `lg'
}
else {
di as err "Error: variable D084 and/or D001 not found"
}
}


if ("`l'"=="R041") {
di _newline(1)
//R041
quietly capture confirm variable D001 D025 D026 D086
if !_rc {
quietly gen double R041=((D001-D025-D026)/D086)

quietly count if D086==0
if r(N)>0 {
display "R041: `r(N)' observations with D086=0 replaced by missing value(s)"
}
quietly count if D086<0
if r(N)>0 {
display "R041: `r(N)' observations with D086<0 replaced by missing value(s)"
}
quietly count if (D001-D025-D026)<0
if r(N)>0 {
display "R041: `r(N)' observations with (D001-D025-D026)<0 replaced by missing value(s)"
}
quietly count if abs((D001-D025-D026)/D086)>100
if r(N)>0 {
display "R041: `r(N)' observations with ABS((D001-D025-D026)/D086)>100 replaced by missing value(s)"
}

quietly replace R041=. if (D086<=0 | (D001-D025-D026)<0 | abs((D001-D025-D026)/D086)>100)
quietly replace R041=0 if (D001-D025-D026)==0 & !(D086<=0 | (D001-D025-D026)<0 | abs((D001-D025-D026)/D086)>100)

quietly label language pt
quietly label variable R041 "Grau de alavancagem combinada"
quietly label language en 
quietly label variable R041 "Degree of combined leverage"
quietly label language `lg'
}
else {
di as err "Error: variable D001 and/or D025 and/or D026 and/or D086 not found"
}
}


if ("`l'"=="R050") {
di _newline(1)
//R050
quietly capture confirm variable D001 B001
if !_rc {
quietly gen double R050=(D001/B001)

quietly count if B001==0
if r(N)>0 {
display "R050: `r(N)' observations with B001=0 replaced by missing value(s)"
}
quietly count if B001<0
if r(N)>0 {
display "R050: `r(N)' observations with B001<0 replaced by missing value(s)"
}
quietly count if abs(D001/B001)>100
if r(N)>0 {
display "R050: `r(N)' observations with ABS(D001/B001)>100 replaced by missing value(s)"
}

quietly replace R050=. if (B001<=0 | abs(D001/B001)>100)
quietly replace R050=0 if D001==0 & !(B001<=0 | abs(D001/B001)>100)

quietly label language pt
quietly label variable R050 "Rotação do activo (nº vezes) - QS"
quietly label language en 
quietly label variable R050 "Asset turnover (times) - QS"
quietly label language `lg'
}
else {
di as err "Error: variable D001 and/or B001 not found"
}
}


if ("`l'"=="R056") {
di _newline(1)
//R056
quietly capture confirm variable B005 D029
if !_rc {
quietly gen double R056=(B005/D029)

quietly count if D029==0
if r(N)>0 {
display "R056: `r(N)' observations with D029=0 replaced by missing value(s)"
}
quietly count if D029<0
if r(N)>0 {
display "R056: `r(N)' observations with D029<0 replaced by missing value(s)"
}
quietly count if B005<0
if r(N)>0 {
display "R056: `r(N)' observations with B005<0 replaced by missing value(s)"
}
quietly count if abs(B005/D029)>100
if r(N)>0 {
display "R056: `r(N)' observations with ABS(B005/D029)>100 replaced by missing value(s)"
}

quietly replace R056=. if (D029<=0 | B005<0 | abs(B005/D029)>100)
quietly replace R056=0 if B005==0 & !(D029<=0 | B005<0 | abs(B005/D029)>100)

quietly label language pt
quietly label variable R056 "Coeficiente Capital/Gastos com o pessoal (euros)"
quietly label language en 
quietly label variable R056 "Coefficient Fixed non-financial assets over employee expenses"
quietly label language `lg'
}
else {
di as err "Error: variable B005 and/or D029 not found"
}
}


if ("`l'"=="R150") {
di _newline(1)
//R150
quietly capture confirm variable D001 B001
if !_rc {
quietly gen double R150=(D001/B001)

quietly count if B001==0
if r(N)>0 {
display "R150: `r(N)' observations with B001=0 replaced by missing value(s)"
}
quietly count if B001<0
if r(N)>0 {
display "R150: `r(N)' observations with B001<0 replaced by missing value(s)"
}
quietly count if abs(D001/B001)>100
if r(N)>0 {
display "R150: `r(N)' observations with ABS(D001/B001)>100 replaced by missing value(s)"
}

quietly replace R150=. if (B001<=0 | abs(D001/B001)>100)
quietly replace R150=0 if D001==0 & !(B001<=0 | abs(D001/B001)>100)

quietly label language pt
quietly label variable R150 "Volume de negócios / Total do ativo"
quietly label language en 
quietly label variable R150 "Asset turnover ratio"
quietly label language `lg'
}
else {
di as err "Error: variable D001 and/or B001 not found"
}
}


if ("`l'"=="R152") {
di _newline(1)
//R152
quietly capture confirm variable D086 B061
if !_rc {
quietly gen double R152=(D086/B061)

quietly count if B061==0
if r(N)>0 {
display "R152: `r(N)' observations with B061=0 replaced by missing value(s)"
}
quietly count if B061<0
if r(N)>0 {
display "R152: `r(N)' observations with B061<0 replaced by missing value(s)"
}
quietly count if abs(D086/B061)>100
if r(N)>0 {
display "R152: `r(N)' observations with ABS(D086/B061)>100 replaced by missing value(s)"
}

quietly replace R152=. if (B061<=0 | abs(D086/B061)>100)
quietly replace R152=0 if D086==0 & !(B061<=0 | abs(D086/B061)>100)

quietly label language pt
quietly label variable R152 "Resultado antes de impostos / Capital próprio"
quietly label language en 
quietly label variable R152 "Profit or loss of the year before taxes (EBT) / Equity"
quietly label language `lg'
}
else {
di as err "Error: variable D086 and/or B061 not found"
}
}


if ("`l'"=="R155") {
di _newline(1)
//R155
quietly capture confirm variable D086 D001
if !_rc {
quietly gen double R155=(D086/D001)

quietly count if D001==0
if r(N)>0 {
display "R155: `r(N)' observations with D001=0 replaced by missing value(s)"
}
quietly count if D001<0
if r(N)>0 {
display "R155: `r(N)' observations with D001<0 replaced by missing value(s)"
}
quietly count if abs(D086/D001)>100
if r(N)>0 {
display "R155: `r(N)' observations with ABS(D086/D001)>100 replaced by missing value(s)"
}

quietly replace R155=. if (D001<=0 | abs(D086/D001)>100)
quietly replace R155=0 if D086==0 & !(D001<=0 | abs(D086/D001)>100)

quietly label language pt
quietly label variable R155 "Resultado antes de impostos / Volume de negócios"
quietly label language en 
quietly label variable R155 "Profit or loss of the year before taxes (EBT) / Net turnover"
quietly label language `lg'
}
else {
di as err "Error: variable D086 and/or D001 not found"
}
}


if ("`l'"=="R156") {
di _newline(1)
//R156
quietly capture confirm variable B061 B001
if !_rc {
quietly gen double R156=(B061/B001)

quietly count if B001==0
if r(N)>0 {
display "R156: `r(N)' observations with B001=0 replaced by missing value(s)"
}
quietly count if B001<0
if r(N)>0 {
display "R156: `r(N)' observations with B001<0 replaced by missing value(s)"
}
quietly count if abs(B061/B001)>100
if r(N)>0 {
display "R156: `r(N)' observations with ABS(B061/B001)>100 replaced by missing value(s)"
}

quietly replace R156=. if (B001<=0 | abs(B061/B001)>100)
quietly replace R156=0 if B061==0 & !(B001<=0 | abs(B061/B001)>100)

quietly label language pt
quietly label variable R156 "Capital próprio / Total do ativo"
quietly label language en 
quietly label variable R156 "Equity / Total assets"
quietly label language `lg'
}
else {
di as err "Error: variable B061 and/or B001 not found"
}
}


if ("`l'"=="R157") {
di _newline(1)
//R157
quietly capture confirm variable B093 B001
if !_rc {
quietly gen double R157=(B093/B001)

quietly count if B001==0
if r(N)>0 {
display "R157: `r(N)' observations with B001=0 replaced by missing value(s)"
}
quietly count if B001<0
if r(N)>0 {
display "R157: `r(N)' observations with B001<0 replaced by missing value(s)"
}
quietly count if abs(B093/B001)>100
if r(N)>0 {
display "R157: `r(N)' observations with ABS(B093/B001)>100 replaced by missing value(s)"
}

quietly replace R157=. if (B001<=0 | abs(B093/B001)>100)
quietly replace R157=0 if B093==0 & !(B001<=0 | abs(B093/B001)>100)

quietly label language pt
quietly label variable R157 "Fornecedores / Total do ativo"
quietly label language en 
quietly label variable R157 "Trade payables / Total assets"
quietly label language `lg'
}
else {
di as err "Error: variable B093 and/or B001 not found"
}
}


if ("`l'"=="R158") {
di _newline(1)
//R158
quietly capture confirm variable D021 D001
if !_rc {
quietly gen double R158=(D021/D001)

quietly count if D001==0
if r(N)>0 {
display "R158: `r(N)' observations with D001=0 replaced by missing value(s)"
}
quietly count if D001<0
if r(N)>0 {
display "R158: `r(N)' observations with D001<0 replaced by missing value(s)"
}
quietly count if abs(D021/D001)>100
if r(N)>0 {
display "R158: `r(N)' observations with ABS(D021/D001)>100 replaced by missing value(s)"
}

quietly replace R158=. if (D001<=0 | abs(D021/D001)>100)
quietly replace R158=0 if D021==0 & !(D001<=0 | abs(D021/D001)>100)

quietly label language pt
quietly label variable R158 "Total de rendimentos / Volume de negócios"
quietly label language en 
quietly label variable R158 "Total income / Net turnover"
quietly label language `lg'
}
else {
di as err "Error: variable D021 and/or D001 not found"
}
}


if ("`l'"=="R159") {
di _newline(1)
//R159
quietly capture confirm variable D062 D001
if !_rc {
quietly gen double R159=(D062/D001)

quietly count if D001==0
if r(N)>0 {
display "R159: `r(N)' observations with D001=0 replaced by missing value(s)"
}
quietly count if D001<0
if r(N)>0 {
display "R159: `r(N)' observations with D001<0 replaced by missing value(s)"
}
quietly count if abs(D062/D001)>100
if r(N)>0 {
display "R159: `r(N)' observations with ABS(D062/D001)>100 replaced by missing value(s)"
}

quietly replace R159=. if ((D001<=0) | (abs(D062/D001)>100))
quietly replace R159=0 if (D062==0) & !((D001<=0) | (abs(D062/D001)>100))

quietly label language pt
quietly label variable R159 "Total de gastos / Volume de negócios"
quietly label language en 
quietly label variable R159 "Total expenses / Net turnover"
quietly label language `lg'
}
else {
di as err "Error: variable D062 and/or D001 not found"
}
}


if ("`l'"=="R160") {
di _newline(1)
//R160
quietly capture confirm variable B025 B001
if !_rc {
quietly gen double R160=(B025/B001)

quietly count if B001==0
if r(N)>0 {
display "R160: `r(N)' observations with B001=0 replaced by missing value(s)"
}
quietly count if B001<0
if r(N)>0 {
display "R160: `r(N)' observations with B001<0 replaced by missing value(s)"
}
quietly count if B025<0
if r(N)>0 {
display "R160: `r(N)' observations with B025<0 replaced by missing value(s)"
}
quietly count if abs(B025/B001)>100
if r(N)>0 {
display "R160: `r(N)' observations with ABS(B025/B001)>100 replaced by missing value(s)"
}

quietly replace R160=. if (B001<=0 | B025<0 | abs(B025/B001)>100)
quietly replace R160=0 if B025==0 & !(B001<=0 | B025<0 | abs(B025/B001)>100)

quietly label language pt
quietly label variable R160 "Investimentos financeiros / Total do ativo"
quietly label language en 
quietly label variable R160 "Financial fixed assets / Total assets"
quietly label language `lg'
}
else {
di as err "Error: variable B025 and/or B001 not found"
}
}


if ("`l'"=="R161") {
di _newline(1)
//R161
quietly capture confirm variable B041 B001
if !_rc {
quietly gen double R161=(B041/B001)

quietly count if B001==0
if r(N)>0 {
display "R161: `r(N)' observations with B001=0 replaced by missing value(s)"
}
quietly count if B001<0
if r(N)>0 {
display "R161: `r(N)' observations with B001<0 replaced by missing value(s)"
}
quietly count if abs(B041/B001)>100
if r(N)>0 {
display "R161: `r(N)' observations with ABS(B041/B001)>100 replaced by missing value(s)"
}

quietly replace R161=. if (B001<=0 | abs(B041/B001)>100)
quietly replace R161=0 if B041==0 & !(B001<=0 | abs(B041/B001)>100)

quietly label language pt
quietly label variable R161 "Clientes / Total do ativo"
quietly label language en 
quietly label variable R161 "Trade receivables / Total assets"
quietly label language `lg'
}
else {
di as err "Error: variable B041 and/or B001 not found"
}
}
}

di _newline(1)

if `"`save'"'!="" {
preserve 
quietly ds
local varlist2 `r(varlist)'
local vars : list varlist2 - varlist1
keep tina ano `vars'
save `"`save'"', replace
restore
drop `vars'
}

end
