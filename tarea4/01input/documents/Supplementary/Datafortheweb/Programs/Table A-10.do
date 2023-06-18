////////////////////////////////////////////////////////////////////////////////
/*							    	TABLE A10								  */
////////////////////////////////////////////////////////////////////////////////

clear
set more off, permanently

// ---------------------------------------------------------------------------//
// 		        				  Long differences					       	  //	
// ---------------------------------------------------------------------------//

clear 
use "$DATA"
xtivreg2 propconflictCOW2 yr1940- yr1960 (logmaddpop = compsjmhatit) if newsample40_COW==1 & (year==1940 | year==1960) ,fe cluster(ctrycluster)
outreg2  using Results/timing_p1.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("1") replace nocons label noaster
xtivreg2 propconflictCOW2 yr1940- yr1970 (logmaddpop = compsjmhatit) if newsample40_COW==1 & (year==1940 | year==1970) ,fe cluster(ctrycluster)
outreg2  using Results/timing_p1.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("2") append nocons label noaster
xtivreg2 propconflictCOW2 yr1940- yr1980 (logmaddpop = compsjmhatit) if newsample40_COW==1 & (year==1940 | year==1980) ,fe cluster(ctrycluster)
outreg2  using Results/timing_p1.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("3") append nocons label noaster
xtivreg2 propconflictCOW2 yr1940- yr1990 (logmaddpop = compsjmhatit) if newsample40_COW==1 & (year==1940 | year==1990) ,fe cluster(ctrycluster)
outreg2  using Results/timing_p1.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("4") append nocons label noaster
xtivreg2 propconflictCOW2 yr1940- yr1990 yr2000 (logmaddpop = compsjmhatit) if newsample40_COW==1 & (year==1940 | year==2000) ,fe cluster(ctrycluster)
outreg2  using Results/timing_p1.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("5") append nocons label noaster

clear
use "$DATA"
gen HE=.
gen pop=.
qui generate forty_frac_tot_influence1 = frac_tot_influence1 if year==1940 
bys country: egen constant_frac_tot_influence1 = max(forty_frac_tot_influence1)
gen junk1 = constant_frac_tot_influence1*logmaddpop
gen junk2 = constant_frac_tot_influence1*compsjmhatit
xtivreg2 propconflictCOW2 yr1940- yr1980 (logmaddpop junk1 = compsjmhatit junk2) if newsample40_COW==1 & (year==1940 | year==1980) ,fe cluster(ctrycluster)
qui generate samplepanel_frac_tot_influence1 = e(sample)
egen pop_frac_tot_influence1 = mean(logmaddpop) if samplepanel_frac_tot_influence1==1
egen xbar_frac_tot_influence1 = mean(constant_frac_tot_influence1) if samplepanel_frac_tot_influence1==1
generate fv_pop_frac_tot_influence1 = logmaddpop - pop_frac_tot_influence1
generate fv_frac_tot_influence1 = constant_frac_tot_influence1 - xbar_frac_tot_influence1
generate endo_frac_tot_influence1 = fv_pop_frac_tot_influence1 * fv_frac_tot_influence1
generate exo_frac_tot_influence1 = compsjmhatit * fv_frac_tot_influence1
label var pop "log population"
label var HE "log population $\times$ US or Soviet influence" 
replace logmaddpop = fv_pop_frac_tot_influence1
replace HE = endo_frac_tot_influence1
xtivreg2 propconflictCOW2 yr1940- yr1980 fv_frac_tot_influence1 (logmaddpop HE = compsjmhatit exo_frac_tot_influence1) if newsample40_COW==1 & (year==1940 | year==1980) ,fe cluster(ctrycluster)
outreg2  using Results/timing_p1.tex, keep(logmaddpop HE) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("5") append nocons label noaster

cap erase Results/timing_p1.txt

// ---------------------------------------------------------------------------//
// 		        		  			Panel							       	  //	
// ---------------------------------------------------------------------------//

clear 
use "$DATA"

xtivreg2 propconflictCOW2 yr1940- yr1980 (logmaddpop=compsjmhatit) if  year>=1940 & year<=1960,   fe cluster(ctrycluster)
outreg2  using Results/timing_p2.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("1") replace nocons label noaster
xtivreg2 propconflictCOW2 yr1940- yr1980 (logmaddpop=compsjmhatit) if  year>=1940 & year<=1970,   fe cluster(ctrycluster)
outreg2  using Results/timing_p2.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("2") append nocons label noaster
xtivreg2 propconflictCOW2 yr1940- yr1980 (logmaddpop=compsjmhatit) if  year>=1940 & year<=1980,   fe cluster(ctrycluster)
outreg2  using Results/timing_p2.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("3") append nocons label noaster
xtivreg2 propconflictCOW2 yr1940- yr1980 (logmaddpop=compsjmhatit) if  year>=1940 & year<=1990,   fe cluster(ctrycluster)
outreg2  using Results/timing_p2.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("4") append nocons label noaster
xtivreg2 propconflictCOW2 yr1940- yr1980 (logmaddpop=compsjmhatit) if  year>=1940 & year<=2000,   fe cluster(ctrycluster)
outreg2  using Results/timing_p2.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("5") append nocons label noaster

clear
use "$DATA"
gen HE=.
gen pop=.
qui generate forty_frac_tot_influence1 = frac_tot_influence1 if year==1940 
bys country: egen constant_frac_tot_influence1 = max(forty_frac_tot_influence1)
gen junk1 = constant_frac_tot_influence1*logmaddpop
gen junk2 = constant_frac_tot_influence1*compsjmhatit
qui xtivreg2 propconflictCOW2 yr1940- yr1980 (logmaddpop junk1 = compsjmhatit junk2) if year>1930 & year<1990 ,fe cluster(ctrycluster)
qui generate samplepanel_frac_tot_influence1 = e(sample)
egen pop_frac_tot_influence1 = mean(logmaddpop) if samplepanel_frac_tot_influence1==1
egen xbar_frac_tot_influence1 = mean(constant_frac_tot_influence1) if samplepanel_frac_tot_influence1==1
generate fv_pop_frac_tot_influence1 = logmaddpop - pop_frac_tot_influence1
generate fv_frac_tot_influence1 = constant_frac_tot_influence1 - xbar_frac_tot_influence1
generate endo_frac_tot_influence1 = fv_pop_frac_tot_influence1 * fv_frac_tot_influence1
generate exo_frac_tot_influence1 = compsjmhatit * fv_frac_tot_influence1
label var pop "log population"
label var HE "log population $\times$ US or Soviet influence" 
replace logmaddpop = fv_pop_frac_tot_influence1
replace HE = endo_frac_tot_influence1
xtivreg2 propconflictCOW2 yr1940- yr1980 fv_frac_tot_influence1 (logmaddpop HE  = compsjmhatit exo_frac_tot_influence1 ) if year>1930 & year<1990,fe cluster(ctrycluster)
outreg2  using Results/timing_p2.tex, keep(logmaddpop HE) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("5") append nocons label noaster

cap erase Results/timing_p2.txt
