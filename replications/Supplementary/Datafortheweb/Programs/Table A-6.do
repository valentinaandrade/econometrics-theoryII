////////////////////////////////////////////////////////////////////////////////
/*							    	TABLE A6								  */
////////////////////////////////////////////////////////////////////////////////

clear
set more off, permanently

// ---------------------------------------------------------------------------//
// 		        		  	Long differences						       	  //	
// ---------------------------------------------------------------------------//

clear 
use "$DATA"

xtivreg2 entry_prop yr1940- yr1980 (logmaddpop = compsjmhatit) if newsample40_COW==1 & (year==1940 | year==1980) ,fe cluster(ctrycluster)
outreg2  using Results/other_p1.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("Long 1") replace nocons label noaster
xtivreg2 exit_prop yr1940- yr1980 (logmaddpop = compsjmhatit) if newsample40_COW==1 & (year==1940 | year==1980) ,fe cluster(ctrycluster)
outreg2  using Results/other_p1.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("Long 2") append nocons label noaster
xtivreg2 prop_totalscoup1 yr1940- yr1980 (logmaddpop = compsjmhatit) if newsample40_COW==1 & (year==1940 | year==1980) ,fe cluster(ctrycluster)
outreg2  using Results/other_p1.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("Long 3") append nocons label noaster
xtivreg2 prop_totalatcoup2 yr1940- yr1980 (logmaddpop = compsjmhatit) if newsample40_COW==1 & (year==1940 | year==1980) ,fe cluster(ctrycluster)
outreg2  using Results/other_p1.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("Long 4") append nocons label noaster
xtivreg2 propSF2 yr1940- yr1980 (logmaddpop = compsjmhatit) if newsample40_COW==1 & (year==1940 | year==1980) ,fe cluster(ctrycluster)
outreg2  using Results/other_p1.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("Long 5") append nocons label noaster
xtivreg2 propwarCOW yr1940- yr1980 (logmaddpop = compsjmhatit) if year==1940 | year==1980 ,fe cluster(ctrycluster)
outreg2  using Results/other_p1.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("Long 5") append nocons label noaster
xtivreg2 propwarU yr1940- yr1980 (logmaddpop = compsjmhatit) if year==1940 | year==1980 ,fe cluster(ctrycluster)
outreg2  using Results/other_p1.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("Long 5") append nocons label noaster

cap erase Results/other_p1.txt

// ---------------------------------------------------------------------------//
// 		        		  			Panel							       	  //	
// ---------------------------------------------------------------------------//
clear 
use "$DATA"

xtivreg2 entry_prop yr1940- yr1980 (logmaddpop = compsjmhatit) if year>1930 & year<1990 ,fe cluster(ctrycluster)
outreg2  using Results/other_p2.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("Panel 1") replace nocons label noaster
xtivreg2 exit_prop yr1940- yr1980 (logmaddpop = compsjmhatit) if year>1930 & year<1990 ,fe cluster(ctrycluster)
outreg2  using Results/other_p2.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("Panel 2") append nocons label noaster
xtivreg2 prop_totalscoup1 yr1940- yr1980 (logmaddpop = compsjmhatit) if year>1930 & year<1990 ,fe cluster(ctrycluster)
outreg2  using Results/other_p2.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("Panel 3") append nocons label noaster
xtivreg2 prop_totalatcoup2 yr1940- yr1980 (logmaddpop = compsjmhatit) if year>1930 & year<1990 ,fe cluster(ctrycluster)
outreg2  using Results/other_p2.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("Panel 4") append nocons label noaster
xtivreg2 propSF yr1940- yr1980 (logmaddpop = compsjmhatit) if year>1940 & year<1990 ,fe cluster(ctrycluster)
outreg2  using Results/other_p2.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("Panel 5") append nocons label noaster
xtivreg2 propwarCOW yr1940- yr1980 (logmaddpop = compsjmhatit) if year>1930 & year<1990 ,fe cluster(ctrycluster)
outreg2  using Results/other_p2.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("Panel 5") append nocons label noaster
xtivreg2 propwarU yr1940- yr1980 (logmaddpop = compsjmhatit) if year>1930 & year<1990 ,fe cluster(ctrycluster)
outreg2  using Results/other_p2.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("Panel 5") append nocons label noaster

cap erase Results/other_p2.txt
