////////////////////////////////////////////////////////////////////////////////
/*							    	TABLE A19								  */
////////////////////////////////////////////////////////////////////////////////

clear
set more off, permanently

// ---------------------------------------------------------------------------//
// 		        		  			Panel							       	  //	
// ---------------------------------------------------------------------------//

clear 
use "$DATA"

cap erase Results/HE_p1_v2.tex
cap erase Results/HE_p1_v2.txt
foreach x in area climclip soilclip avgclip average_cereals agri yr_sch xconst polity_corr {
clear
use "$DATA"
gen HE=.
gen pop=.
sort country year
by country: replace yr_sch=yr_sch[_n+1] if missing(yr_sch)
by country: replace agri=agri[_n+2] if missing(agri)
bys country: replace ETHDOM = ETHDOM[_n+2] if year==1940
replace avpolity506070 = avpolity506070[_n+1] if year==1940
replace area = area/1000000

// Baseline Reg
qui generate forty_`x' = `x' if year==1940 
bys country: egen constant_`x' = max(forty_`x')
gen junk1 = constant_`x'*logmaddpop
gen junk2 = constant_`x'*compsjmhatit

qui xtivreg2 propconflictCOW2 yr1940- yr1980 (logmaddpop junk1 = compsjmhatit junk2) if year>1930 & year<1990 ,fe cluster(ctrycluster)
qui generate samplepanel_`x' = e(sample)

// Means over the sample
egen pop_`x' = mean(logmaddpop) if samplepanel_`x'==1
egen xbar_`x' = mean(constant_`x') if samplepanel_`x'==1

// Final variables
generate fv_pop_`x' = logmaddpop - pop_`x'
generate fv_`x' = constant_`x' - xbar_`x'

// Interactions
generate endo_`x' = fv_pop_`x' * fv_`x'
generate exo_`x' = compsjmhatit * fv_`x'

label var pop "log of population"
label var HE "log of population $\times$ variable" 
replace pop = fv_pop_`x'
replace HE = endo_`x'

xtivreg2 propconflictCOW2 yr1940- yr1980 fv_`x' (pop HE  = compsjmhatit exo_`x' ) if year>1930 & year<1990,fe cluster(ctrycluster)
outreg2 using Results/HE_p1_v2.tex, keep(pop HE) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("`x'") append nocons label noaster
drop junk1 junk2
}
cap erase Results/HE_p1_v2.txt
