*! version 0.2 18December2020
* Programmed by Marta Silva

program define ireepanel

syntax, [ ///
EDITION(string) /// chose the editions to be added (152020,162020,...)
TYPE(string) /// it may be long or wide
SAVE(string)  ///name of the dataset to save
MPATH(string) ///main path where the data is stored
]

//define options and error messages
*edition
local a `: word count `edition''
if (`a'==1 & "`edition'"!="all") {
    display as error "Please define at least two extractions"
    error 198
}

if ("`edition'"=="all" | "`edition'"=="") {
    local edition="152020 162020 172020 182020 192020 202020 212020 222020 232020 242020"
}

*mpath: save current working directory and use it as the default
local dir : pwd

if "`mpath'"=="" {
   local mpath="`dir'"
}

*type
local k `: word count `type''

if "`type'"=="" {
	local type="long"
}

if ("`type'"!="wide" & "`type'"!="long") | `k'>1 {
    display as error "Please define the type of the panel: long or wide"
    error 198
}

//confirm that the data being used is the original data provided by BPLIM
local j = 0
foreach l of local edition {
  if `l'==242020 {
    quietly use "`mpath'/IREE_A_WFRM_`l'_NOV20_V01.dta", clear
  }
  else {
    quietly use "`mpath'/IREE_A_WFRM_`l'_JUL20_V01.dta", clear
  }
	quietly datasignature report
	local dtsig`l'="`r(origdatasignature)'"

	if "`l'"=="152020" & ("`dtsig`l''"!="5010:35(40664):1987644065:286474080" | substr("`r(fulldatasignature)'",1,7)!="5010:35" | "`r(varsadded)'"!="tina" | "`r(varsdropped)'"!="nipc") {
		local ++j
	}

	if "`l'"=="162020" & ("`dtsig`l''"!="5973:37(79181):3030940395:112268710" | substr("`r(fulldatasignature)'",1,7)!="5973:37" | "`r(varsadded)'"!="tina" | "`r(varsdropped)'"!="nipc") {
		local ++j
	}

	if "`l'"=="172020" & ("`dtsig`l''"!="5928:37(79181):2118144523:3085521122" | substr("`r(fulldatasignature)'",1,7)!="5928:37"  | "`r(varsadded)'"!="tina" | "`r(varsdropped)'"!="nipc") {
		local ++j
	}

	if "`l'"=="182020" & ("`dtsig`l''"!="5571:38(70940):11244:4036597814" | substr("`r(fulldatasignature)'",1,7)!="5571:38" | "`r(varsadded)'"!="tina" | "`r(varsdropped)'"!="nipc") {
		local ++j
	}

	if "`l'"=="192020" & ("`dtsig`l''"!="5628:44(100625):4097690455:1176138779" | substr("`r(fulldatasignature)'",1,7)!="5628:44" | "`r(varsadded)'"!="tina" | "`r(varsdropped)'"!="nipc") {
		local ++j
	}

	if "`l'"=="202020" & ("`dtsig`l''"!="5424:44(100625):3415561870:7675238" | substr("`r(fulldatasignature)'",1,7)!="5424:44" | "`r(varsadded)'"!="tina" | "`r(varsdropped)'"!="nipc") {
		local ++j
	}

	if "`l'"=="212020" & ("`dtsig`l''"!="5785:43(20702):1021151493:1507219961" | substr("`r(fulldatasignature)'",1,7)!="5785:43" | "`r(varsadded)'"!="tina" | "`r(varsdropped)'"!="nipc") {
		local ++j
	}

	if "`l'"=="222020" & ("`dtsig`l''"!="4920:35(77759):2884475362:1885851377" | substr("`r(fulldatasignature)'",1,7)!="4920:35"| "`r(varsadded)'"!="tina" | "`r(varsdropped)'"!="nipc") {
		local ++j
	}

	if "`l'"=="232020" & ("`dtsig`l''"!="4850:35(58582):914013410:622325299" | substr("`r(fulldatasignature)'",1,7)!="4850:35" | "`r(varsadded)'"!="tina" | "`r(varsdropped)'"!="nipc") {
		local ++j
	}

  if "`l'"=="242020" & ("`dtsig`l''"!="5837:51(59779):2200677971:2181079079" | substr("`r(fulldatasignature)'",1,7)!="5837:51" | "`r(varsadded)'"!="tina" | "`r(varsdropped)'"!="nipc") {
    local ++j
    }

if `j'>0 {
	di as error "`j' file(s) do not correspond to the original version provided by BPLIM. Please use the original files."
	error 198
}
}

di as text _newline "Starting to append the selected files..." _newline

quietly {
*Identify variables in a given edition to replace by .a
foreach l of local edition {
  if `l'==242020 {
    use "`mpath'/IREE_A_WFRM_`l'_NOV20_V01.dta", clear
  }
  else {
    use "`mpath'/IREE_A_WFRM_`l'_JUL20_V01.dta", clear
  }
  ds
	local var_count: word count `r(varlist)'
	clear
	set obs `var_count'
	gen COD = ""
	local i = 1
	foreach var in `r(varlist)' {
		replace COD = "`var'" in `i'
		local ++i
	}
  gen period=real(substr("`l'",1,2))
	capture cd `dir'
	tempfile edt`l'
	save `edt`l'', replace
}

*Save value labels
clear
foreach l of local edition {
	append using `edt`l''
}

bysort COD (period): keep if _n==_N
tempfile temp
save `temp'

levelsof period, local(dta)

foreach v of local dta {
    use `temp', clear
	keep if period==`v'
	levelsof COD, local(vars`v')
	local vars_`v'=subinstr(`vars`v'',char(34),"",.)
  if `v'==24 {
    use "`mpath'/IREE_A_WFRM_`v'2020_NOV20_V01.dta", clear
  }
  else {
    use "`mpath'/IREE_A_WFRM_`v'2020_JUL20_V01.dta", clear
  }
	capture cd `dir'
	label language pt
	tempname temp`v'_pt
	descsave "`vars_`v''", dofile(`temp`v'_pt'.do, replace)  dontdo(type format)
	label language en
	tempname temp`v'_en
	descsave "`vars_`v''", dofile(`temp`v'_en'.do, replace)  dontdo(type format)
	}

clear

*append selected data
foreach l of local edition {
  if `l'<=232020 {
    append using "`mpath'/IREE_A_WFRM_`l'_JUL20_V01.dta"
  }
  if `l'==242020 {
    append using "`mpath'/IREE_A_WFRM_`l'_NOV20_V01.dta"
  }
}

unab varlist: _all

* Recode missing values to .a
foreach l of local edition {
    local period=substr("`l'",1,2)
	preserve
	use `edt`l'', clear
	levelsof COD, local(levels)
	restore
	local varlist`l': list varlist - levels
	foreach var of local varlist`l' {
		replace `var' = .a if `var'==. & p_infra_cod==`period'
	}
}


*Apply value labels
foreach v of local dta {
    capture cd `dir'
    label language pt
	do `temp`v'_pt'
	capture rm `temp`v'_pt'.do
	label language en
	do `temp`v'_en'
	capture rm `temp`v'_en'.do
}

notes drop _all

*Apply variable labels
capture capture label language pt
capture label variable ano "Ano de referência"
capture label variable p_infra_cod "Código da ocorrência (semana 15,16,…)"
capture label variable tina "Número de Identificação Fiscal Anonimizado"
capture label variable BC015 "Ocorreu facto relevante"
capture label variable BC020 "Data associada ao facto relevante"
capture label variable V1010 "Situação que melhor descreve a empresa"
capture label variable V2010 "Impacto do COVID-19 no volume de negócios"
capture label variable V2A10 "Diversificação/modificação da produção devido à pandemia COVID"
capture label variable V2A20 "Alteração/reforço canais de distribuição (online, takeaway…) devido COVID"
capture label variable V2110 "Estimativa para a redução no volume de negócios da empresa"
capture label variable V2120 "Estimativa para o aumento no volume de negócios da empresa"
capture label variable V3110 "Impacto das restrições do estado de emergência para a redução do VVN"
capture label variable V3120 "Impacto da falta imprevista de funcionários para a redução do VVN"
capture label variable V3130 "Impacto de problemas na cadeia de fornecimento para a redução do VVN"
capture label variable V3140 "Impacto da ausência de encomendas/clientes para a redução do VVN"
capture label variable V3210 "Impacto restrições estado emergência para encerramento definitivo da empresa"
capture label variable V3220 "Impacto da falta imprevista funcionários p/ encerramento definitivo da empresa"
capture label variable V3230 "Impacto de problemas cadeia fornecimento para encerramento definitivo da empresa"
capture label variable V3240 "Impacto da ausência encomendas/clientes para encerramento definitivo da empresa"
capture label variable V4010 "Impacto da pandemia no NPS efetivamente a trabalhar na empresa"
capture label variable V4110 "Estimativa para a redução no número de pessoas ao serviço"
capture label variable V4120 "Estimativa para o aumento no número de pessoas ao serviço"
capture label variable V5010 "Situação mais relevante para a redução do NPS efetivamente a trabalhar"
capture label variable V5A110 "Relevância do layoff simplificado para redução do NPS efetivamente a trabalhar"
capture label variable V5A120 "Relevância do despedimento contratos sem termo para redução do NPS a trabalhar"
capture label variable V5A130 "Relevância da não renovação contratos a prazo para redução NPS a trabalhar"
capture label variable V5A140 "Relevância de faltas para a redução do NPS efetivamente a trabalhar"
capture label variable V5A150 "Relevância de outras situações para redução do NPS efetivamente a trabalhar"
capture label variable V5B010 "% de pessoas em teletrabalho relativamente ao NPS efetivamente a trabalhar"
capture label variable V6010 "Utilização da moratória ao pagamento de juros e capital de créditos existentes"
capture label variable V6020 "Utilização de novos créditos com juros bonificados ou garantias do Estado"
capture label variable V6030 "Utilização da suspensão do pagamento de obrigações fiscais e contributivas"
capture label variable V6040 "Utilização de outras medidas apresentadas pelo Governo devido à COVID-19"
capture label variable V7010 "Tempo de permanência em atividade sem medidas adicionais de apoio à liquidez"
capture label variable V8010 "Devido ao COVID-19, aumentou o recurso ao crédito bancário ou de outro tipo?"
capture label variable V8110 "Condições em que empresa acedeu ao crédito de instituições financeiras"
capture label variable V8120 "Condições em que empresa acedeu ao crédito de fornecedores"
capture label variable V8190 "Condições em que empresa acedeu a outro tipo de crédito"
capture label variable V8210 "Razão pela qual não aumentou o crédito"
capture label variable V9010 "Expectativa para preços praticados pela empresa"
capture label variable V10010 "Relevância da disponibilidade de material de proteção individual"
capture label variable V10020 "Relevância das restrições no espaço físico"
capture label variable V10030 "Relevância dos custos elevados"
capture label variable V10040 "Relevância da falta de informação sobre os requisitos necessários"
capture label variable V10050 "Relevância da inexistência de capacidade técnica em higiene/seguran no trabalho"
capture label variable V4020 "Evolução do volume de negócios da empresa no período de referência"
capture label variable V5110 "Impacto da evolução das medidas de contenção no volume de negócios"
capture label variable V5120 "Impacto das variações nas encomendas/clientes no volume de negócios"
capture label variable V5130 "Impacto de alterações na cadeia de fornecimentos no volume de negócios"
capture label variable V5140 "Impacto das variações no pessoal ao serviço da empresa no volume de negócios"
capture label variable V5B020 "% de pessoas a trabalhar com presença alternada relativamente ao NPS a trabalhar"
capture label variable V7020 "Evolução do NPS efetivamente a trabalhar no período de referência"
capture label variable V8150 "Impacto da alteração no nº pessoas em layoff para evolução do NPS a trabalhar"
capture label variable V8160 "Impacto da variação no nº contratos sem termo para evolução do NPS a trabalhar"
capture label variable V8170 "Impacto da variação no nº contratos a prazo para a evolução do NPS a trabalhar"
capture label variable V8180 "Impacto da variação dos dias de faltas para a evolução do NPS a trabalhar"
capture label variable V11010 "Tenciona reforçar o investimento em tecnologias de informação"
capture label variable V11020 "Tenciona aumentar o recurso ao teletrabalho"
capture label variable V11030 "Tenciona alterar as cadeias de fornecimento"
capture label variable V11040 "Tenciona aumentar os stocks de produtos necessários à atividade"
capture label variable V11050 "Tenciona redirecionar os mercados alvo"
capture label variable V11060 "Tenciona alterar a gama de produtos vendidos/serviços prestados"
capture label variable V11070 "Tenciona mudar a atividade principal da empresa"
capture label variable V3A110 "Tempo necessário para que o volume de negócios volte ao nível normal"
capture label variable V6110 "Importância do layoff simplificado para a liquidez"
capture label variable V6120 "Importância da moratória ao pagamento de juros e capital para a liquidez"
capture label variable V6130 "Importância de créditos c/ juros bonificados ou garantias Estado para liquidez"
capture label variable V6140 "Importância da suspensão pagamento obrigações fiscais/contrib para liquidez"
capture label variable V8020 "Evolução do total de pessoas empregadas desde o início da pandemia"
capture label variable V8220 "Estimativa para a diminuição do NPS desde 11 Março até 1ª quinzena de julho"
capture label variable V8230 "Estimativa para o aumento do NPS desde 11 Março até 1ª quinzena de julho"
capture label variable V9020 "A sua empresa recorreu ao regime de layoff simplificado?"
capture label variable V10110 "Como estima que teria variado o NPS sem recurso ao layoff simplificado?"
capture label variable V10120 "Estimativa para a diminuição do NPS sem recurso ao layoff simplificado"
capture label variable V11110 "Opção que pretende seguir em Agosto face às alterações layoff simplificado"
capture label variable V12010 "Expectativa para a evolução dos postos de trabalho até ao final do ano"
capture label variable V1001 "Impacto das novas medidas de contenção anunciadas no volume de negócios"
capture label variable V1002 "Impacto das variações nas encomendas/clientes no volume de negócios"
capture label variable V1003 "Impacto das alterações na cadeia de fornecimentos no volume de negócios"
capture label variable V1004 "Impacto das variações no pessoal ao serviço da empresa no volume de negócios"
capture label variable V2000 "Evolução do ambiente concorrencial no mercado onde opera"
capture label variable V3001 "Alterou ou tenciona alterar as cadeias de fornecimento"
capture label variable V3002 "Aumentou ou tenciona aumentar os stocks de produtos necessários à atividade"
capture label variable V3003 "Diminuiu ou tenciona diminuir os stocks de produtos necessários à atividade"
capture label variable V3004 "Redirecionou ou tenciona redirecionar os mercados alvo"
capture label variable V3005 "Alterou ou tenciona alterar a gama de produtos vendidos/serviços prestados"
capture label variable V4001 "Importância do apoio à retoma progressiva/layoff simplificado para a liquidez"
capture label variable V4002 "Importância incentivo extraordinário normalização ativid. econ. p/liquidez"
capture label variable V4003 "Importância da moratória ao pagamento de juros e capital para a liquidez"
capture label variable V4004 "Importância acesso a créditos c/ juros bonificados/garantias Estado p/liquidez"
capture label variable V4005 "Importância suspensão pagamento obrigações fiscais/contributivas p/ liquidez"
capture label variable V5001 "Expectativa para o número de postos de trabalho no final de 2020"
capture label variable V5002 "Expectativa para o número de postos de trabalho no final de 2021"
capture label variable V5005 "Estimativa para a redução dos postos de trabalho no final de 2020"
capture label variable V5006 "Estimativa para a o aumento dos postos de trabalho no final de 2020"
capture label variable V6001 "Implementação permanente do uso mais intensivo do teletrabalho"
capture label variable V6002 "Implementação permanente de horários de trabalho mais flexíveis"
capture label variable V6003 "Implementação permanente da reorganização das equipas de trabalho"
capture label variable V6004 "Diminuição permanente do número de viagens de negócios"
capture label variable V7000 "Tenciona concorrer aos fundos associados ao Plano de Recuperação e Resiliência"
capture label variable V7001 "Aplicação dos fundos na digitalização dos processos produtivos"
capture label variable V7002 "Aplicação dos fundos na capacitação dos trabalhadores para a digitalização"
capture label variable V7003 "Aplicação dos fundos na redução das emissões/aumento da eficiência energética"
capture label variable V7004 "Aplicação dos fundos em investigação e desenvolvimento"
capture label variable V7005 "Aplicação dos fundos na capitalização da empresa e resiliência financeira"
capture label variable V7006 "Aplicação dos fundos do Plano de Recuperação e Resiliência noutra área"
capture label variable V8001 "Preocupação com agravamento adicional ou prolongamento das medidas contenção"
capture label variable V8002 "Preocupação com redução de procura mesmo com controlo situação sanitária"
capture label variable V8003 "Preocupação com o fim das medidas excecionais de apoio às empresas em 2021"
capture label variable V8004 "Preocupação com evolução adversa da situação de liquidez/ financeira"
capture label variable V8005 "Preocupação c/ desenvolv. internacionais desfavoráveis p/ cadeias de fornec."
capture label variable V9000 "Tempo estimado de subsistência da empresa"
capture label variable V9001 "Número de meses que a empresa conseguirá subsistir"
capture label variable V10001 "Importância do layoff simplificado"
capture label variable V10002 "Importância da moratória ao pagamento de juros/capital de créditos existentes"
capture label variable V10003 "Importância do acesso novos créditos c/ juros bonificados ou garantias Estado"
capture label variable V10004 "Importância da suspensão do pagamento de obrigações fiscais e contributivas"
capture label variable V11000 "Tempo estimado para que a atividade da empresa volte ao normal"
capture label variable V11001 "Número de meses para que a atividade da empresa volte ao normal"
capture label variable AGDIM "Dimensão da empresa (com dados da amostra)"
capture label variable AGCAE "Setores de atividade económica (com dados da amostra)"
capture label variable P_EXPORT "Perfil exportador"


capture label language en

capture label variable ano "Reference year"
capture label variable p_infra_cod "Code of the survey's edition (week 15,16,…)"
capture label variable tina "Tax Identificação Number Anonymized"
capture label variable BC015 "Relevant event"
capture label variable BC020 "Date of the relevant event"
capture label variable V1010 "Situation of the enterprise"
capture label variable V2010 "Impact of COVID-19 on turnover"
capture label variable V2A10 "Diversification/modification of production due to the pandemic"
capture label variable V2A20 "Change/reinforce distribution channels (online, takeaway,…) due to the pandemic"
capture label variable V2110 "Estimate of the reduction in turnover"
capture label variable V2120 "Estimate of the increase in turnover"
capture label variable V3110 "Impact of the restrictions in the emergency state on the reduction in turnover"
capture label variable V3120 "Impact of the unexpected shortage of staff on the reduction in turnover"
capture label variable V3130 "Impact of the supply chain problems on the reduction in turnover"
capture label variable V3140 "Impact of the absence of orders/clients on the reduction in turnover"
capture label variable V3210 "Impact of the restrictions in the context of the emergency state on firm closure"
capture label variable V3220 "Impact of the unexpected shortage of staff on the firm closure"
capture label variable V3230 "Impact of the supply chain problems on the firm closure"
capture label variable V3240 "Impact of the absence of orders/clients on the firm closure"
capture label variable V4010 "Impact of COVID-19 on persons employed effectively working"
capture label variable V4110 "Estimate of the reduction in the number of employees"
capture label variable V4120 "Estimate of the increase in the number of employees"
capture label variable V5010 "Most relevant situation for the reduction of persons employed effectively working"
capture label variable V5A110 "Importance of the simplified layoff to the reduction of n. employees working"
capture label variable V5A120 "Importance of dismissal of OEC to the reduction of employees effectively working"
capture label variable V5A130 "Importance of the non-renewal of FTC to the reduction of n. employees working"
capture label variable V5A140 "Importance of the absences to explain the reduction of employees working"
capture label variable V5A150 "Importance of other situations to the reduction of n. employees effectively working"
capture label variable V5B010 "Share of persons employed effectively working in remote working"
capture label variable V6010 "Use of the moratorium for the payment of interests and principal on existing loans"
capture label variable V6020 "Use of the access to new loans with low-interest or State guarantees"
capture label variable V6030 "Use of the suspension of the payment of tax and contributory obligations"
capture label variable V6040 "Use of other measures presented by the Government due to COVID-19"
capture label variable V7010 "How long can remain in activity without additional liquidity support measures"
capture label variable V8010 "Did the firm recourse to additional credit due to the COVID-19 pandemic?"
capture label variable V8110 "Conditions of the financial institutions credit"
capture label variable V8120 "Conditions of the supplier credit"
capture label variable V8190 "Conditions of the other type of credit"
capture label variable V8210 "Reason for not using additional credit"
capture label variable V9010 "Expectation for the prices charged by the enterprise"
capture label variable AGDIM "Size-class of the enterprise (sample data)"
capture label variable AGCAE "Sector of economic activity (sample data)"
capture label variable P_EXPORT "Exporting profile"
capture label variable V10010 "Importance of the availability of individual protection material"
capture label variable V10020 "Importance of the restrictions on physical space"
capture label variable V10030 "Importance of the high costs"
capture label variable V10040 "Importance of the lack of information on necessary requirements"
capture label variable V10050 "Importance of the lack of technical skills in hygiene and safety at work"
capture label variable V4020 "Evolution of turnover in the reference period"
capture label variable V5110 "Impact of the evolution of the containment measures for turnover"
capture label variable V5120 "Impact of the variations in orders/customers for turnover"
capture label variable V5130 "Impact of the changes in supply chain for turnover"
capture label variable V5140 "Impact of variations in the enterprise's staff for turnover"
capture label variable V5B020 "Share of persons employed effectively working with alternate presence"
capture label variable V7020 "Evolution in number of persons employed effectively working in the refer. period"
capture label variable V8150 "Impact of the variation in employees in layoff for the evolution of employees working"
capture label variable V8160 "Impact of the variation in OEC for the evolution of employees effectively working"
capture label variable V8170 "Impact of the variation in FTC for the evolution of employees effectively working"
capture label variable V8180 "Impact of the variation in absences for the evolution of employees effectively working"
capture label variable V11010 "Intention to reinforce the investment in information technology"
capture label variable V11020 "Intention to increase the use of remote working"
capture label variable V11030 "Intention to change supply chains"
capture label variable V11040 "Intention to increase the stocks of needed products for the activity"
capture label variable V11050 "Intention to redirect target markets"
capture label variable V11060 "Intention to change the range of products sold/services provided"
capture label variable V11070 "Intention to change the main activity of the enterprise"
capture label variable V3A110 "Time needed for turnover to return to normal level"
capture label variable V6110 "Importance of the simplified layoff for liquidity"
capture label variable V6120 "Importance of moratorium for interests/principal payment on loans for liquidity"
capture label variable V6130 "Importance of the access to low-interest loans or State guarantees for liquidity"
capture label variable V6140 "Importance of the suspension of tax and contributory obligations for liquidity"
capture label variable V8020 "Evolution of the number of employees since the beginning of the pandemic"
capture label variable V8220 "Estimate for the decrease in NPS since March 11 to the 1st fortnight of July"
capture label variable V8230 "Estimate for the increase in NPS since March 11 to the 1st fortnight of July"
capture label variable V9020 "Did the firm benefit from the simplified layoff?"
capture label variable V10110 "How would the number of employees have changed without the simplified layoff?"
capture label variable V10120 "Estimate for the decrease in the NPS without the use of the simplified layoff"
capture label variable V11110 "Option to take in August given the changes to the simplified layoff measure"
capture label variable V12010 "Expected change in the number of jobs until the end of the year"
capture label variable V1001 "Impact of the new containment measures announced on turnover"
capture label variable V1002 "Impact of the variations in orders/customers on turnover"
capture label variable V1003 "Impact of the changes in the supply chain on turnover"
capture label variable V1004 "Impact of the variations in persons employed by the enterprise on turnover"
capture label variable V2000 "Evolution of the competitive environment in the market where the firm operates"
capture label variable V3001 "Changed or intends to change supply chains"
capture label variable V3002 "Increased or intends to increase the stocks of products needed for the activity"
capture label variable V3003 "Decreased or intends to decrease the stocks of products needed for the activity"
capture label variable V3004 "Redirected or intends to redirect target markets"
capture label variable V3005 "Changed or intends to change the range of products sold/services provided"
capture label variable V4001 "Relevance of the support for progressive resumption/simplified layoff for liquidity"
capture label variable V4002 "Relevance of the extraordinary incentive to normalize econ. activity for liquidity"
capture label variable V4003 "Relevance of the moratorium on payment of interest and capital for liquidity"
capture label variable V4004 "Relevance of new loans with low-interest or State guarantees for liquidity"
capture label variable V4005 "Relevance of the suspension of tax and contributory obligations for liquidity"
capture label variable V5001 "Expectation for the number of jobs in the enterprise at the end of 2020"
capture label variable V5002 "Expectation for the number of jobs in the enterprise at the end of 2021"
capture label variable V5005 "Estimate for the reduction of jobs in the enterprise at the end of 2020"
capture label variable V5006 "Estimate for the increase of jobs in the enterprise at the end of 2020"
capture label variable V6001 "Permanent implementation of the more intensive use of remote working"
capture label variable V6002 "Permanent implementation of more flexible working hours"
capture label variable V6003 "Permanent implementation of the reorganization of work teams"
capture label variable V6004 "Permanent decrease in the number of business trips"
capture label variable V7000 "Do you intend to compete for funds of the Recovery and Resilience Plan?"
capture label variable V7001 "Intention to invest the funds in the digitization of production processes"
capture label variable V7002 "Intention to invest the funds in the training of workers for digitization"
capture label variable V7003 "Intention to invest the funds in reducing emissions/increasing energy efficiency"
capture label variable V7004 "Intention to invest the funds in research and development"
capture label variable V7005 "Intention to invest the funds in company capitalization and financial resilience"
capture label variable V7006 "Intention to invest the funds of the Recovery and Resilience Plan in other area"
capture label variable V8001 "Concern about the worsening/prolongation of the pandemic containment measures"
capture label variable V8002 "Concern about the demand reduction even with the control of the health situation"
capture label variable V8003 "Concern about the end of exceptional business support measures in 2021"
capture label variable V8004 "Concern about the adverse evolution of the firm's liquidity/financial situation"
capture label variable V8005 "Concern about unfavorable international developments with impact on supply chains"
capture label variable V9000 "How long do you estimate the enterprise will be able to survive?"
capture label variable V9001 "Number of months that the enterprise will be able to survive"
capture label variable V10001 "Importance of the simplified layoff"
capture label variable V10002 "Importance of the moratorium on payment of interest/capital on existing credits"
capture label variable V10003 "Importance of the access to new loans with low-interest or State guarantees"
capture label variable V10004 "Importance of the suspension of payment of tax and contributory obligations"
capture label variable V11000 "How long do you expect the activity of the enterprise to return to normal? "
capture label variable V11001 "Number of months needed for the firm's activity to return to normal"

capture label language pt
}


*Display warning message when appending weekly data with fortnightly data
quietly sum p_infra_cod
if (`r(min)'<19 & `r(max)'>=19) {
	di in red _newline  "NOTICE: The reference period changes from a week to a fortnight from Edition 19 to Edition 23" _newline
}

if (`r(min)'<24 & `r(max)'>=24) {
	di in red _newline  "NOTICE: The reference period changes to a month in Edition 24" _newline
}

*save files
if "`type'"=="long" {
	sort tina p_infra_cod
   	if "`save'"!="" {
        quietly compress
        aorder
        order tina p_infra_cod

		capture cd `dir'
		quietly save "`save'", replace

		di as text _newline "File `save' was saved in the `type' format. To display labels in English please type: label language en" _newline
		tab p_infra_cod, miss
	}
	else {
		di as text _newline "The data was successfully appended in the `type' format. To display labels in English please type: label language en" _newline
		tab p_infra_cod, miss
	}
}


if "`type'"=="wide" {
  	unab varlistf : _all
	unab exclude : tina p_infra_cod
	local varlistf : list varlistf - exclude

	greshape wide `varlistf', i(tina) keys(p_infra_cod)

	sort tina

	if "`save'"!="" {
        quietly compress
        order tina

		capture cd `dir'
		quietly save "`save'", replace

		di as text _newline "File `save' was saved in the `type' format. To display labels in English please type: label language en" _newline
	}
	else {
		di as text _newline "The data was successfully appended in the `type' format. To display labels in English please type: label language en" _newline
	}
}

end
