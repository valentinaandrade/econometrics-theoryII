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

use "$src/AEJMicro-2009-0153_data", clear

* ------------------------------------------------------------------------------
* (b) tabla 5 + APE o PAE
* ------------------------------------------------------------------------------
* 1. Model 5 - No robust
qui eststo m5: probit  change_or_exit complaints firm_age emp_size ad_spend_k  chicago comp_sq age_sq emp_sq ad_sq


* 2. Marginals (in probability) atmeans PEA
qui eststo m51: margins, dydx (complaints firm_age emp_size ad_spend_k  chicago comp_sq age_sq emp_sq ad_sq) atmeans post

* 3. Marginals (in probability) atmeans APE
estimate restore m5
qui eststo m52: margins, dydx (complaints firm_age emp_size ad_spend_k  chicago comp_sq age_sq emp_sq ad_sq) post

* 4. Save all
esttab m5 m51 m52 using "$output/models/model5.tex", se brackets nonumbers mtitle("Probit" "PEA", "APE") titles("Probit model for change or exit name firm") addnotes(" Marginal effects estimate by Binary Probit model") plain type nobase unstack replace


* ------------------------------------------------------------------------------
* (c) tabla 6
* ------------------------------------------------------------------------------

* 1.Model multinomial

* col 1
qui eststo m61: mprobit decision complaints firm_age emp_size ad_spend_k chicago comp_sq age_sq emp_sq ad_sq, base(0)

* col 2
qui eststo m62: mprobit decision complaints firm_age  emp_size ad_spend_k chicago comp_sq age_sq emp_sq ad_sq comp_chicago age_chicago comp_ad age_ad comp_emp age_emp, base(0)

* col 3
qui eststo m63: mprobit decision complaints firm_age emp_size ad_spend_k chicago  comp_sq age_sq emp_sq ad_sq comp_chicago  age_chicago comp_ad age_ad comp_emp age_emp  ad_chicago comp_ad_chicago age_ad_chicago, base(0)



* ------------------------------------------------------------------------------
* (d) tabla 5 y 6 - logit
* ------------------------------------------------------------------------------

* ------------------------------------------------------------------------------
* (e) tabla 7 y 8
* ------------------------------------------------------------------------------
