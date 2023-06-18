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

reg z_irt_total_el treatment _z_irt_math_bl _z_irt_sci_bl strataFE* if tooktest_el==1, cluster (school_code) 
outreg2 using "ouput/models/table2A.tex", replace nocons keep(treatment)

reg z_scoreindex_el treatment _z_irt_math_bl _z_irt_sci_bl _meanmath_pec_2016 _meansci_pec_2016 _meaneng_pec_2016 _meaneng_pec_2016_mi strataFE* if tooktest_el==1 & took_std==1 , cluster (school_code) 

outreg2 using "ouput/models/table2A.tex",  append keep(treatment) nocons

* ------------------------------------------------------------------------------
**# Panel B
* ------------------------------------------------------------------------------

pdslasso z_irt_total_el treatment (_* strataFE* ), partial(_z_irt_math_bl _z_irt_sci_bl strataFE*) cluster(school_code)
outreg2 using "ouput/models/table2B.tex", replace nocons keep(treatment)

pdslasso z_scoreindex_el treatment (_* strataFE*) if tooktest_el==1 & took_std==1, partial (_z_irt_math_bl _z_irt_sci_bl _meanmath_pec_2016 _meansci_pec_2016 _meaneng_pec_2016 _meaneng_pec_2016_mi strataFE*) cluster(school_code)
outreg2 using "ouput/models/table2B.tex", append nocons keep(treatment)
