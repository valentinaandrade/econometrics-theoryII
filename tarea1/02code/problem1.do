* ------------------------------------------------------------------------------
* AUTHOR: Valentina Andrade
* CREATION: March-2022
* ACTION: Problem set 1 - Problem 1
* ------------------------------------------------------------------------------

set more off 
clear all

* ------------------------------------------------------------------------------
* SET PATH AND LOCALS
* ------------------------------------------------------------------------------

if c(username)=="valentinaandrade" global github"/Users/valentinaandrade/Documents/GitHub/me/econometrics-theoryII/tarea1"

global src 	    "$github/01input/src"
global tmp  	"$github/01input/tmp"
global output   "$github/03output"

* ------------------------------------------------------------------------------
* use data
* ------------------------------------------------------------------------------

use "$src/data_pregunta1", clear

* ------------------------------------------------------------------------------
* (a) program likelihood
* ------------------------------------------------------------------------------
* in R

* ------------------------------------------------------------------------------
* (b) logit and marginal effects
* ------------------------------------------------------------------------------

* 1. Estimate logit in Stata
qui logit municipal cod_nivel i.es_mujer i.prioritario i.alto_rendimiento, rob
* 2. Save logit
esttab using "$output/models/model1.tex", se brackets nonumbers mtitles("Logit model for enroll to public school") plain type nobase unstack replace

* 3. Marginals (in probability) atmeans 
margins, dydx (cod_nivel i.es_mujer i.prioritario i.alto_rendimiento) atmeans post
* 4. Save margins
esttab using "$output/models/marginal1.tex", se brackets nonumbers mtitles("Marginal effects enroll to public school") addnotes("Coefficients estimate by Binary Logit model") plain type nobase unstack replace

* ------------------------------------------------------------------------------
* (c) type_school
* ------------------------------------------------------------------------------

* Label tipo
label define type_school 1 municipalnoPIE 2 municipalPIE 3 subvencionadonoPIE 4 subvencionadoPIE, replace
label value tipo type_school
* Tab
tab tipo

* ------------------------------------------------------------------------------
* (d) multinomial logit and marginal effects
* ------------------------------------------------------------------------------
* 1. Estimate multinomial logit in Stata
qui mlogit tipo cod_nivel i.es_mujer i.prioritario i.alto_rendimiento, rob base(1)
* 2. Save model2 
esttab using "$output/models/model2.tex", se brackets nonumber mtitles("Multinomial logit for enroll by type of schools")  plain type nobase unstack replace

* 3. Margins
margins, dydx (cod_nivel i.es_mujer i.prioritario i.alto_rendimiento) atmeans post
* 4. Save margins
esttab using "$output/models/marginal2.tex", se brackets nonumber mtitles("Marginals Effect of enroll by type of schools") addnotes("Coefficients estimate by a Multinomial Logit") plain type nobase unstack replace


* ------------------------------------------------------------------------------
* (e) conditional logit
* ------------------------------------------------------------------------------
* 1. Long data across alternatives
reshape long distancia p_prioritario simce_lect simce_mate, i(mrun) j(type_school) 
* 222 with 4 possible alternatives, combination = 4*222 = 888
* map from alternatives (type_school) to choice (tipo)

* 2. Dummy choice
* From manual: the outcome or chosen alternative is identified by a value of 1 in depvar, whereas zeros indicate the alternatives that were not chosen. In this case we use 1 as base category
gen choice=0
replace choice=1 if type_school==tipo

* 3. Estimation with McFadden for general conditional logit
* Similar as clogit
qui asclogit choice distancia p_prioritario simce_lect simce_mate, case(mrun) alternatives(type_school) vce(robust) nocons

* 4. Save table
esttab using "$output/models/model3.tex", se brackets nonumber mtitles("Multinomial Conditional Logit of enroll by type of schools") plain type nobase unstack replace

* 5. Marginals
margins, dydx (distancia p_prioritario simce_lect simce_mate) atmeans post

* 6. Save table
esttab using "$output/models/marginal3.tex", se brackets nonumber mtitles("Marginal Effects of enroll by type of schools") addnotes("Coefficients estimate by a Multinomial Conditional Logit") plain type nobase unstack replace

* ------------------------------------------------------------------------------
* (f) mixed logit or alternative conditional logit
* ------------------------------------------------------------------------------
* Xs determined by individual and alternative (mix)

*1. Estimate mixed logit with casevars
* noncons not allowed 
asclogit choice distancia p_prioritario simce_lect simce_mate, case(mrun) alternatives(type_school) casevars(cod_nivel i.es_mujer i.prioritario i.alto_rendimiento) vce(robust)
* 2. Save tab models
esttab using "$output/models/model4.tex", se brackets nonumber mtitles("Multinomial Mixed Logit of enroll by type of schools") plain type nobase unstack replace

* 3. Marginals
margins, dydx (distancia p_prioritario simce_lect simce_mate cod_nivel i.es_mujer i.prioritario i.alto_rendimiento) atmeans post

* 4. Save marginals
esttab using "$output/models/marginal4.tex", se brackets nonumber mtitles("Marginal Effects of enroll by type of schools") addnotes("Coefficients estimate by a Multinomial Mixed Logit") plain type nobase unstack replace
