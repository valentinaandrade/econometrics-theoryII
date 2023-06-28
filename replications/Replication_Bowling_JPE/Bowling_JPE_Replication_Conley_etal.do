clear all
global folder "C:\Users\Nico Voigtländer\Dropbox\dark side social capital\Replication"

cd "$folder"
use Dataset_Bowling_Replication_JPE.dta, clear


********************************************* Generate variables ****************************************************
quietly{
*Log entry rates:
gen lnNSentry_total=ln(1+NSentry_total)
label var lnNSentry_total "log total (Falter) Party entries 1925-01/33"
gen lnNSentry_FU_total=ln(1+NSentry_FU_total)
label var lnNSentry_total "log total (Falter-corrected) Party entries 1925-01/33"
gen lnclubs_all = ln(clubs_all)

*Population:
gen pop2 = (pop25/1000)^2
gen pop3 = (pop25/1000)^3
gen lnpop25=ln(pop25)
label var pop2 "(pop'25)^2"
label var pop3 "(pop'25)^3"
label var lnpop25 "ln(pop) in 1925"

*Dummies for size quintiles
xtile pop25_quintiles = pop25, nq(5)
tab  pop25_quintiles, gen(d_pop_quintile)

*Population density:
gen lnpop_density=ln(pop_density)
gen dummy_maps=1 if area_source =="Maps"
recode dummy_maps .=0
gen i_popden_maps = lnpop_density*dummy_maps

*Government stability 
pca govt_longest_perc party_longest_perc weimar_coalition_perc
predict govt_stability, score

xtile govt_stability_AM = govt_stability if landweimar!="Preußen", nq(2)
replace govt_stability_AM= govt_stability_AM-1 if landweimar!="Preußen"
replace govt_stability_AM= 0 if landweimar=="Preußen"

*Principal Component for IV analysis
pca turnmembers_pc singersfest_members_pc
predict IV_pca
label var IV_pca "First Principal Component of turnmembers_pc singersfest_members_pc"

}
*

**NOTE: You will need to copy atz.ado from the replication package to your Stata ado folder.

//////////////////////// Conley Hanson Rossi analysis ///////////////////////////////////////////


/////////////////////////////// Figure A.11 ////////////////////////////////////

set obs 501

* Generating the place holders for the lower and upper bound
gen lb = .
label variable lb "Lower Bound"
gen ub = .
label variable ub "Upper Bound"

* Generating the modifying variable (for the graph); REPLACE _n > by the 
* highest delta (careful about divisions after the generation line)
gen delta2 = (_n-1)/1000
replace delta2 = . if delta2 > 0.3

* Generating the values of delta to be looped over
local delta = 0
local count = 1

* REPLACE delta <= 1 by the highest delta
while `delta' <= 0.3 {

quietly{
	* Creating the matrix
	matrix omega_eta = J(17,17,0) //note: adjust this number to control variables + 2 
	matrix mu_eta = J(17,1,0) //note: adjust this number to control variables + 2 

	matrix omega_eta[1,1] = (`delta'/sqrt(12))^2
	matrix mu_eta[1,1] = `delta'/2

	* Display delta (to know where in loop we are)
	noi: di "Delta is equal to " `delta' "     (running from 0 to 0.3)"

	* Estimating the bounds -- using baseline spec from Table 11, col 3 in the paper
	local controls_socioecon "share_jew25 unemp33 in_welfare_per1000 war_per1000 sozialrentner_per1000 logtaxpers logtaxprop"
	local controls_political "hitler_speech_per1000 DNVP_votes_avg DVP_votes_avg SPD_votes_avg KPD_votes_avg" 
	ltz omega_eta mu_eta pcNSentry_std (clubs_all_pc lnpop25 share_cath25 bcollar25 `controls_political' `controls_socioecon' = IV_pca lnpop25 share_cath25 bcollar25 `controls_political' `controls_socioecon'), level(.90) robust

	* Extract the upper and lower bounds and save them in the place holder
	replace lb = ltemp[1,1] in `count'
	replace ub = utemp[1,1] in `count'

	* Continuing the loop
	local count=`count'+1
	local delta=`delta'+ 0.001
	}
}

* Finding where the lower bound crosses 0
gen dummy = 0
replace dummy = 1 if lb < 0
gen ddummy = dummy - dummy[_n-1]
gen temp = delta2 if ddummy == 1
sum temp
local thresholdgraph: display %5.4f `r(mean)'
display `thresholdgraph'

drop dummy ddummy temp


* Generating Figure A.11
twoway (line lb delta2, lcolor(dkgreen) lwidth(medthick) lpattern(solid)) (line ub delta2, lcolor(navy) lwidth(medthick) lpattern(dash)), yline(0, lwidth(thin) lpattern(solid) ///
	lcolor(black)) legend(ring(0) position(3)) xtitle(delta, size(medlarge)) scheme(s1color) //note("With standard controls." "Threshold for delta where 0 is crossed: `thresholdgraph'")

* Droping the variables
drop lb ub delta2




