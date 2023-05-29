* ------------------------------------------------------------------------------
* AUTHOR: Valentina Andrade
* CREATION: May-2022
* ACTION: Problem set 3 - Problem 2
* ------------------------------------------------------------------------------

set more off 
clear all
eststo clear
* ------------------------------------------------------------------------------
* SET PATH AND LOCALS
* ------------------------------------------------------------------------------

if c(username)=="valentinaandrade" global github"/Users/valentinaandrade/Documents/GitHub/me/econometrics-theoryII/tarea3"

global src 	    "$github/01input/src"
global tmp  	"$github/01input/tmp"
global output   "$github/03output"

* ------------------------------------------------------------------------------
**# packages
* ------------------------------------------------------------------------------

*ssc install nnmatch 
*net install st0632.pkg


* ------------------------------------------------------------------------------
**# Figures 
* ------------------------------------------------------------------------------
use "$src/20080229_national_data.dta", clear
* Figure 1
gen lnall=ln(all_tot)
gen lnflupneu=ln(influenza_pneumonia_total)
gen lnmmr=ln(mmr)
gen lnscarfever=ln(scarlet_fever_tot)
gen lnmenin = ln(meningitis_total)
gen lntb=ln(tuberculosis_total)
gen lnheart=ln(heart_total)
gen lncancer=ln(cancer_total)
gen lndiab=ln(diabetes_total)


* Figure 0 (for part (a))
foreach var of varlist lnmmr lnflupneu lnscarfever lnmenin {
local i = `i' + 1
twoway connected `var' lntb year, sort tline(1937) tlabel(1920 1925 1930 1935 1940 1945 1950)  legend(order(1 "`var'" 2 "tuberculosis" )) name(jar`i', replace)
local jar  `jar'  jar`i' 
}

graph combine `jar'
graph export "$output/figures/figure0.png"
graph close


* Figure 1

twoway connected lnall year, sort tline(1937) tlabel(1920 1925 1930 1935 1940 1945 1950) ytitle("Log mortality rate") xtitle("")
graph export "$output/figures/figure1.png"
graph close

* Figure 2

foreach var of varlist lnmmr lnflupneu lnscarfever lnmenin{
local j = `j' + 1
twoway connected `var' year, sort tline(1937) tlabel(1920 1925 1930 1935 1940 1945 1950) ytitle("Log mortality rate") xtitle("") name(ja`j', replace)
local ja  `ja'  ja`j' 
}

graph combine `ja'
graph export "$output/figures/figure2.png"
graph close

* Figure 3

twoway connected lntb year, sort tline(1937) tlabel(1920 1925 1930 1935 1940 1945 1950) ytitle("Log mortality rate") xtitle("")
graph export "$output/figures/figure3.png"

* Figure 4
twoway connected lncancer lnheart year, sort tline(1937) tlabel(1920 1925 1930 1935 1940 1945 1950) || connected lndiab year if year < 1949, sort yaxis(2) ytitle("Diabetes", axis(2)) yscale(range(3 3.4) axis(2)) legend(ring(0) position(10)) legend(order(1 "Cancer" 2 "Heart" 3 "Diabetes")) xtitle("")
graph export "$output/figures/figure4.png"

* ------------------------------------------------------------------------------
**# Table 2: Testing for year of trend break in national mortality series
* ------------------------------------------------------------------------------

use "$src/20080229_national_data.dta", clear

keep if year>=1920 & year<=1950

** / Take log of mortality rates */

gen lnall=ln(all_tot)
gen lnflupneu=ln(influenza_pneumonia_total)
gen lnmmr=ln(mmr)
gen lnscarfever=ln(scarlet_fever_tot)
gen lntb=ln(tuberculosis_total)


** / QLR Test - Table 2 Results */


cap prog drop breaks
prog breaks
  args var
	cap drop break 
	cap drop sig 
	cap drop fstat 
	cap drop maxf
	
gen sig=.
gen fstat=.
tsset year

*test break
local i=33
while `i'<=42 {
cap drop y19`i' 
qui gen y19`i'=(year>=19`i')
qui newey d.`var' y19`i', lag(2)
qui replace fstat=e(F) if year==19`i'
qui test y19`i' 
qui replace sig=r(p) if year==19`i'
local i=`i' +1
}
qui egen maxf=max(fstat) 
qui gen break=year if fstat==maxf
list `var' year break fstat sig if break!=.

end
breaks lnall
breaks lnmmr
breaks lnflupneu
breaks lnscarfever
breaks lntb

* Tabla exportada a mano (table2.tex)

* ------------------------------------------------------------------------------
**# Table 3: Effect of sulfa drugs using national-level time series by disease, 1925-1943
* ------------------------------------------------------------------------------


use "$src/20080229_national_data.dta", clear

drop if year<1925|year>1943

**/ Take log of mortality rates */

gen lnall=ln(all_tot)
gen lnflupneu=ln(influenza_pneumonia_total)
gen lnmmr=ln(mmr)
gen lnscarfever=ln(scarlet_fever_tot)
gen lntb=ln(tuberculosis_total)

sort year
tsset year
gen post37=(year>1936)
gen year_c=(year-1937)
gen post37Xyear_c=post37*year_c

* Table 3 Results 

newey lnall post37 year_c, lag(2)
estimates store a1
newey lnall post37 year_c post37Xyear_c, lag(2)
estimates store a2
newey lnmmr post37 year_c, lag(2)
estimates store a3
newey lnmmr post37 year_c post37Xyear_c, lag(2)
estimates store a4
newey lnflupneu post37 year_c, lag(2)
estimates store a5
newey lnflupneu post37 year_c post37Xyear_c, lag(2)
estimates store a6
newey lnscarfever post37 year_c, lag(2)
estimates store a7
newey lnscarfever post37 year_c post37Xyear_c, lag(2)
estimates store a8
newey lntb post37 year_c, lag(2)
estimates store a9
newey lntb post37 year_c post37Xyear_c, lag(2)
estimates store a10
esttab a* using "$output/models/table3.tex", keep(post37 post37Xyear_c) plain type nobase unstack noomitted label booktabs lines star(* 0.10 ** 0.05 *** 0.01) cells(b(star fmt(%9.3f))) replace


* ------------------------------------------------------------------------------
**# Table 4: Effect of sulfa drugs on mortality for "treated" dieases, 1937-1943
* ------------------------------------------------------------------------------
* Uses national (Panel A) and state (Panels B and C) data

* Panel A (national-level) results 

use "$src/20080229_national_data.dta", clear
drop if year<1925|year>1943
* Reshape data
rename mmr d1
rename influenza_pneumonia_total d2
rename scarlet_fever_tot d3
rename tuberculosis_total d4
reshape long d, i(year) j(disease) 
label define disease 1"mmr" 2"influ_pneumonia" 3"scarfever" 4"tb"  
label values disease disease
rename d m_rate
gen lnm_rate=ln(m_rate)
gen treated=(disease==1|disease==2|disease==3)
gen post37=(year>=1937)
gen year_c=(year-1937)
gen treatedXyear_c=treated*year_c
gen treatedXpost37=treated*post37
gen treatedXyear_cXpost37=treated*year_c*post37

reg lnm_rate treatedXpost37 treatedXyear_c treated year_c post37 if disease==1|disease==4, r
estimates store a1
reg lnm_rate treatedXyear_cXpost37 treatedXyear_c treatedXpost37 treated year_c post37 if disease==1|disease==4, r
estimates store a2
reg lnm_rate treatedXpost37 treatedXyear_c treated year_c post37 if disease==2|disease==4, r
estimates store a3
reg lnm_rate treatedXyear_cXpost37 treatedXyear_c treatedXpost37 treated year_c post37  if disease==2|disease==4, r
estimates store a4
reg lnm_rate treatedXpost37 treatedXyear_c treated year_c post37  if disease==3|disease==4, r
estimates store a5
reg lnm_rate treatedXyear_cXpost37 treatedXyear_c treatedXpost37 treated year_c post37 if disease==3|disease==4, r
estimates store a6
esttab a* using "$output/models/table4A.tex", keep(treatedXpost37 treatedXyear_cXpost37) plain type nobase unstack noomitted label booktabs lines star(* 0.10 ** 0.05 *** 0.01) cells(b(star fmt(%9.3f)))  replace

 

* Panel B (state-level) results 

use "$src/20080229_state_data.dta", clear
drop if (year<1925|year>1943)
keep state year mmr infl_pneumonia_rate scarfever_rate tb_rate 
rename mmr d1
rename infl_pneumonia_rate d2
rename scarfever_rate d3
rename tb_rate d4
reshape long d, i(state year) j(disease) 
label define disease 1"mmr" 2"influ_pneumonia" 3"scarfever" 4"tb"
label values disease disease
rename d m_rate
gen lnm_rate=ln(m_rate)
ta disease, gen(dis)
gen treated=(disease<4)
gen post37=(year>=1937)
gen treatedXpost37=treated*post37
gen year_c=(year-1937)
gen treatedXyear_c=treated*year_c
gen treatedXyear_cXpost37=treated*year_c*post37
egen statepost=group(state post37)
xi i.statepost*year
egen diseaseyear=group(disease year)

xi: areg lnm_rate treatedXyear_c treatedXpost37 treated year_c if disease==1|disease==4, absorb(statepost)  cluster(diseaseyear)
estimates store a1
xi: reg lnm_rate treatedXyear_cXpost37 treatedXyear_c treatedXpost37 treated  i.statepost*year if disease==1|disease==4, cluster(diseaseyear)
estimates store a2
xi: areg lnm_rate  treatedXyear_c treatedXpost37 treated year_c if disease==2|disease==4, absorb(statepost) cluster(diseaseyear)
estimates store a3
xi: reg lnm_rate treatedXyear_cXpost37 treatedXyear_c treatedXpost37 treated  i.statepost*year if disease==2|disease==4, cluster(diseaseyear)
estimates store a4
xi: areg lnm_rate treatedXyear_c treatedXpost37 treated year_c if disease==3|disease==4, absorb(statepost) cluster(diseaseyear)
estimates store a5
xi: reg lnm_rate treatedXyear_c treatedXyear_cXpost37 treatedXyear_c treatedXpost37 treated i.statepost*year if disease==3|disease==4, cluster(diseaseyear)
estimates store a6
esttab a* using "$output/models/table4B.tex", keep(treatedXpost37 treatedXyear_cXpost37) plain type nobase unstack noomitted label booktabs lines star(* 0.10 ** 0.05 *** 0.01) cells(b(star fmt(%9.3f))) replace



* For Panel C (state-level) Results, use above code for Table 4, Panel B, but exclude years 1935-1937 

use "$src/20080229_state_data.dta", clear
drop if (year<1925|year>1943)
drop if (year == 1935 | year == 1936 | year == 1937)
keep state year mmr infl_pneumonia_rate scarfever_rate tb_rate 
rename mmr d1
rename infl_pneumonia_rate d2
rename scarfever_rate d3
rename tb_rate d4
reshape long d, i(state year) j(disease) 
label define disease 1"mmr" 2"influ_pneumonia" 3"scarfever" 4"tb"
label values disease disease
rename d m_rate
gen lnm_rate=ln(m_rate)
ta disease, gen(dis)
gen treated=(disease<4)
gen post37=(year>=1937)
gen treatedXpost37=treated*post37
gen year_c=(year-1937)
gen treatedXyear_c=treated*year_c
gen treatedXyear_cXpost37=treated*year_c*post37
egen statepost=group(state post37)
xi i.statepost*year
egen diseaseyear=group(disease year)

xi: areg lnm_rate treatedXyear_c treatedXpost37 treated year_c if disease==1|disease==4, absorb(statepost)  cluster(diseaseyear)
estimates store a1
xi: reg lnm_rate treatedXyear_cXpost37 treatedXyear_c treatedXpost37 treated  i.statepost*year if disease==1|disease==4, cluster(diseaseyear)
estimates store a2
xi: areg lnm_rate  treatedXyear_c treatedXpost37 treated year_c if disease==2|disease==4, absorb(statepost) cluster(diseaseyear)
estimates store a3
xi: reg lnm_rate treatedXyear_cXpost37 treatedXyear_c treatedXpost37 treated  i.statepost*year if disease==2|disease==4, cluster(diseaseyear)
estimates store a4
xi: areg lnm_rate treatedXyear_c treatedXpost37 treated year_c if disease==3|disease==4, absorb(statepost) cluster(diseaseyear)
estimates store a5
xi: reg lnm_rate treatedXyear_c treatedXyear_cXpost37 treatedXyear_c treatedXpost37 treated i.statepost*year if disease==3|disease==4, cluster(diseaseyear)
estimates store a6

esttab a* using "$output/models/table4C.tex", keep(treatedXpost37 treatedXyear_cXpost37) plain type nobase unstack noomitted label booktabs lines star(* 0.10 ** 0.05 *** 0.01) cells(b(star fmt(%9.3f))) replace


* ------------------------------------------------------------------------------
**# Table 6:  Racial differences in the effect of sulfa drugs on mortality, 1937-43 
* ------------------------------------------------------------------------------

use "$src/20080229_state_race_data.dta", clear
keep state statenum year race mmr flupneu_rate sf_rate tb_rate
rename mmr d1
rename flupneu_rate d2
rename sf_rate d3
rename tb_rate d4
reshape long d, i(statenum year race) j(disease) 
label define disease 1"mmr" 2"influ_pneumonia" 3"scarlet_fever" 4"tb" 
label values disease disease
rename d m_rate
gen lnm_rate=ln(m_rate)
gen treated=(disease<4)
drop if year<1925|year>1943
gen post37=(year>=1937)
gen black=(race=="other")
gen year_c=year-1937
gen treatedXyear_c=treated*year_c
gen treatedXpost37=treated*post37
gen treatedXblack=treated*black
gen treatedXyear_cXpost37=treated*year_c*post37
gen treatedXyear_cXblack=treated*year_c*black
gen treatedXyear_cXpost37Xblack=treated*year_c*post37*black
gen treatedXpost37Xblack=treated*post37*black
gen year_cXblack=year_c*black
gen year_cXpost37=year_c*post37
gen blackXyear_cXpost37=black*year*post37
egen statepost = group (state post37)
egen blackstatepost = group(black statepost)
xi i.statepost*year
egen diseaseyear=group(disease year)

*/ Flag states to drop in scarlet fever model due to several state/year observations with zero mortality for blacks */
gen dropstate=(disease==3&(statenum==3|statenum==7|statenum==8|statenum==16|statenum==38|statenum==46))

* Panel A results - Whites only 

xi: areg lnm_rate treatedXyear_c treatedXpost37 treated year_c if race=="white"  & (disease==1|disease==4), absorb(statepost) cluster(diseaseyear)
estimates store a1
xi: reg lnm_rate treatedXyear_cXpost37 treatedXyear_c treatedXpost37 treated i.statepost*year  if race=="white" & (disease==1|disease==4), cluster(diseaseyear)
estimates store a2
xi: areg lnm_rate treatedXyear_c treatedXpost37 treated year_c if race=="white" & (disease==2|disease==4), absorb(statepost) cluster(diseaseyear)
estimates store a3
xi: reg lnm_rate treatedXyear_cXpost37 treatedXyear_c treatedXpost37 treated i.statepost*year  if race=="white" & (disease==2|disease==4), cluster(diseaseyear)
estimates store a4
xi: areg lnm_rate treatedXyear_c treatedXpost37 treated year_c if race=="white" & dropstate==0&(disease==3|disease==4), absorb(statepost) cluster(diseaseyear)
estimates store a5
xi: reg lnm_rate treatedXyear_cXpost37 treatedXyear_c treatedXpost37 treated i.statepost*year  if race=="white" & dropstate==0 & (disease==3|disease==4), cluster(diseaseyear)
estimates store a6
esttab a* using "$output/models/table6A.tex",keep(treatedXpost37 treatedXyear_cXpost37)  plain type nobase unstack noomitted label booktabs lines star(* 0.10 ** 0.05 *** 0.01) cells(b(star fmt(%9.3f)))  replace


* Panel B results - Blacks only

xi: areg lnm_rate treatedXyear_c treatedXpost37 treated year_c if race=="other" & (disease==1|disease==4), absorb(statepost)  cluster(diseaseyear)
estimates store a1
xi: reg lnm_rate treatedXyear_cXpost37 treatedXyear_c treatedXpost37 treated i.statepost*year if race=="other" & (disease==1|disease==4), cluster(diseaseyear)
estimates store a2
xi: areg lnm_rate treatedXyear_c treatedXpost37 treated year_c if race=="other" & (disease==2|disease==4), absorb(statepost)  cluster(diseaseyear)
estimates store a3
xi: reg lnm_rate treatedXyear_cXpost37 treatedXyear_c treatedXpost37 treated i.statepost*year if race=="other" & (disease==2|disease==4),  cluster(diseaseyear)
estimates store a4
xi: areg lnm_rate treatedXyear_c treatedXpost37 treated year_c if race=="other"& dropstate==0 & (disease==3|disease==4), absorb(statepost) cluster(diseaseyear)
estimates store a5
xi: reg lnm_rate treatedXyear_cXpost37 treatedXyear_c treatedXpost37 treated i.statepost*year if race=="other" & dropstate==0& (disease==3|disease==4),  cluster(diseaseyear)
estimates store a6
esttab a* using "$output/models/table6B.tex", keep(treatedXpost37 treatedXyear_cXpost37) plain type nobase unstack noomitted label booktabs lines star(* 0.10 ** 0.05 *** 0.01)  cells(b(star fmt(%9.3f))) replace




* Panel C results - Fully interacted models 

areg lnm_rate treatedXyear_cXblack treatedXpost37Xblack treatedXblack treatedXpost37 year_cXblack treatedXyear_c treated year_c ///
if disease==1|disease==4, absorb(blackstatepost)  cluster(diseaseyear)
estimates store a1
xi: reg lnm_rate treatedXyear_cXpost37Xblack treatedXyear_cXblack treatedXpost37Xblack treatedXblack blackXyear_cXpost37 treatedXyear_cXpost37 ///
treatedXpost37 treatedXyear_c treated i.blackstatepost*year if disease==1|disease==4, cluster(diseaseyear)
estimates store a2
areg lnm_rate treatedXyear_cXblack treatedXpost37Xblack treatedXblack treatedXpost37 year_cXblack treatedXyear_c treated year_c ///
if disease==2|disease==4, absorb(blackstatepost)  cluster(diseaseyear)
estimates store a3
xi: reg lnm_rate treatedXyear_cXpost37Xblack treatedXyear_cXblack treatedXpost37Xblack treatedXblack blackXyear_cXpost37 treatedXyear_cXpost37 ///
treatedXpost37 treatedXyear_c treated i.blackstatepost*year if disease==2|disease==4,  cluster(diseaseyear)
estimates store a4
xi: areg lnm_rate treatedXyear_cXblack treatedXpost37Xblack treatedXblack treatedXpost37 year_cXblack treatedXyear_c treated year_c ///
if (disease==3|disease==4) & dropstate==0 , absorb(blackstatepost)  cluster(diseaseyear)
estimates store a5
xi: reg lnm_rate treatedXyear_cXpost37Xblack treatedXyear_cXblack treatedXpost37Xblack treatedXblack blackXyear_cXpost37 treatedXyear_cXpost37 ///
treatedXpost37 treatedXyear_c treated i.blackstatepost*year if (disease==3|disease==4 ) & dropstate==0 ,  cluster(diseaseyear)
estimates store a6
esttab a* using "$output/models/table6C.tex", keep(treatedXpost37Xblack treatedXyear_cXpost37Xblack) plain type nobase unstack noomitted label booktabs lines star(* 0.10 ** 0.05 *** 0.01) cells(b(star fmt(%9.3f)))  replace


