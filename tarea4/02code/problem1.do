* ------------------------------------------------------------------------------
* AUTHOR: Valentina Andrade
* CREATION: March-2022
* ACTION: Problem set 1 - Problem 4
* ------------------------------------------------------------------------------

set more off 
clear all
eststo clear
* ------------------------------------------------------------------------------
* SET PATH AND LOCALS
* ------------------------------------------------------------------------------

if c(username)=="valentinaandrade" global github"/Users/valentinaandrade/Documents/GitHub/me/econometrics-theoryII/tarea4"

global src 	    "$github/01input/src"
global tmp  	"$github/01input/tmp"
global output   "$github/03output"

* ------------------------------------------------------------------------------
**# use data
* ------------------------------------------------------------------------------

use "$src/Pregunta_1", clear


* ------------------------------------------------------------------------------
**# packages
* ------------------------------------------------------------------------------

ssc install lassopack
ssc install pdslasso

* ------------------------------------------------------------------------------
**# Table 2
* ------------------------------------------------------------------------------

* ------------------------------------------------------------------------------
**# Panel A
* ------------------------------------------------------------------------------
*Controls by handpicked

eststo z_irt_total_el: reg z_irt_total_el treatment _z_irt_math_bl _z_irt_sci_bl strataFE* if tooktest_el==1, cluster (school_code) 

eststo z_scoreindex_el: reg z_scoreindex_el treatment _z_irt_math_bl _z_irt_sci_bl _meanmath_pec_2016 _meansci_pec_2016 _meaneng_pec_2016 _meaneng_pec_2016_mi strataFE* if tooktest_el==1 & took_std==1 , cluster (school_code) 

esttab z* using "$output/models/table2A.tex", keep(treatment) se brackets nonumbers plain type nobase unstack noomitted label booktabs lines star(* 0.10 ** 0.05 *** 0.01) cells(b(star fmt(%9.3f)) se)  r2 replace

* ------------------------------------------------------------------------------
**# Panel B
* ------------------------------------------------------------------------------
eststo clear

eststo z_irt_total_el: pdslasso z_irt_total_el treatment (_* strataFE* ), partial(_z_irt_math_bl _z_irt_sci_bl strataFE*) cluster(school_code)

eststo z_scoreindex_el: pdslasso z_scoreindex_el treatment (_* strataFE*) if tooktest_el==1 & took_std==1, partial (_z_irt_math_bl _z_irt_sci_bl _meanmath_pec_2016 _meansci_pec_2016 _meaneng_pec_2016 _meaneng_pec_2016_mi strataFE*) cluster(school_code)

esttab z* using "$output/models/table2B.tex", keep(treatment ) se brackets nonumbers plain type nobase unstack noomitted label booktabs lines star(* 0.10 ** 0.05 *** 0.01) cells(b(star fmt(%9.3f)) se) r2 replace
