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

use "$src/data_pregunta1"

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
esttab using "$output/models/model1.tex", se wide nonumbers mtitles("Logit model for enroll to public school") replace

* 3. Marginals (in probability) atmeans 
eststo model1: margins, dydx (cod_nivel i.es_mujer i.prioritario i.alto_rendimiento) atmeans post
* 4. Save margins
esttab using "$output/models/marginal1.tex", se wide nonumbers mtitles("Marginal effects enroll to public school") replace

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
esttab using "$output/models/model2.tex", se nonumber mtitles("Enroll by type of schools") replace

* 3. Margins
eststo model2: margins, dydx (cod_nivel i.es_mujer i.prioritario i.alto_rendimiento) atmeans post
* 4. Save margins
esttab using "$output/models/marginal2.tex", se wide nonumber mtitles("Enroll by type of schools") replace


*Efectos Marginales


mlogit tipo cod_nivel i.es_mujer i.prioritario i.alto_rendimiento, rob base(1)
eststo m1ml: margins, dydx (cod_nivel i.es_mujer i.prioritario i.alto_rendimiento) predict(outcome(1)) atmeans post

mlogit tipo cod_nivel i.es_mujer i.prioritario i.alto_rendimiento, rob base(1)
eststo m2ml: margins, dydx (cod_nivel i.es_mujer i.prioritario i.alto_rendimiento) predict(outcome(2)) atmeans post


mlogit tipo cod_nivel i.es_mujer i.prioritario i.alto_rendimiento, rob base(1)
eststo m3ml: margins, dydx (cod_nivel i.es_mujer i.prioritario i.alto_rendimiento) predict(outcome(3)) atmeans post


mlogit tipo cod_nivel i.es_mujer i.prioritario i.alto_rendimiento, rob base(1)
eststo m4ml: margins, dydx (cod_nivel i.es_mujer i.prioritario i.alto_rendimiento) predict(outcome(4)) atmeans post

esttab using margins2.tex, se nonumbers mtitles("Efecto Marginal en el MLogit") replace



//*(e) Regresores que varían entre opciones

////////////////////////////////////////////////////////////////////////////////
reshape long distancia p_prioritario simce_lect simce_mate, i(mrun) j(TipoColegio) //Necesario para implementar el asclogit 

gen Elección=0

replace Elección=1 if TipoColegio==tipo
////////////////////////////////////////////////////////////////////////////////


//Estimación de coeficientes
eststo clear
eststo asclogit1: asclogit Elección distancia p_prioritario simce_lect simce_mate, nocons case(mrun) alternatives(TipoColegio) r //Siempre calculando los errores estándar con estimadores robustos a heterocedasticidad
esttab using asclogit1.tex, se nonumbers replace




//Estimación de efectos marginales


asclogit Elección distancia p_prioritario simce_lect simce_mate, nocons case(mrun) alternatives(TipoColegio) r

estat mfx





//*(f) Regresores que varían entre opciones (e individuos) y regresores que varían solo para individuos.

eststo clear
eststo asclogit2: asclogit Elección distancia p_prioritario simce_lect simce_mate, case(mrun) alternatives(TipoColegio) casevars(cod_nivel i.es_mujer i.prioritario i.alto_rendimiento) r
esttab using asclogit2.tex, se nonumbers replace

estat mfx
