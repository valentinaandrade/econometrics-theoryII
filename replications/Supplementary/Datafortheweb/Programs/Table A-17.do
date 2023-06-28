////////////////////////////////////////////////////////////////////////////////
/*							    	TABLE A17								  */
////////////////////////////////////////////////////////////////////////////////

clear
set more off, permanently

// ---------------------------------------------------------------------------//
// 								DEPENDENT VARIABLE							  //	
// ---------------------------------------------------------------------------//

clear all 
use "$DATA"

xtivreg2 propconflictCOW2 yr1940- yr1980 (logmaddpop=compsjmhatit) if year>=1940 & year<1990 ,   fe cluster(ctrycluster)
gen sample = e(sample)

xtivreg2 yr_schlong yr1940- yr1980 (logmaddpop=compsjmhatit) if newsample40_COW==1 & (year==1940 | year==1980), fe cluster(ctrycluster)
outreg2 using Results/educ_p1.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("Long differences")replace nocons label noaster
xtivreg2 yr_schlong yr1950- yr1980 (logmaddpop=compsjmhatit) if  year>=1940 & year<1990 & sample==1, fe cluster(ctrycluster)
outreg2 using Results/educ_p2.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("Panel Regression")  replace nocons label noaster

// ---------------------------------------------------------------------------//
// 					         			CONTROL 				         	  //	
// ---------------------------------------------------------------------------//

xtivreg2 propconflictCOW2 yr1940- yr1980 yr_schlong (logmaddpop=compsjmhatit) if newsample40_COW==1 & (year==1940 | year==1980) ,   fe cluster(ctrycluster)
outreg2 using Results/educ_p1.tex, keep(logmaddpop yr_schlong) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust))   ctitle("propconflictCOW2") append nocons label noaster

foreach x of varlist propconflictU propconflictFL logdeathpop40U {
xtivreg2 `x' yr1940- yr1980 yr_schlong (logmaddpop=compsjmhatit) if  newsample40==1 & (year==1940 | year==1980),   fe cluster(ctrycluster)
outreg2 using Results/educ_p1.tex, keep(logmaddpop yr_schlong) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("`x'") append nocons label noaster
}
foreach x of varlist propconflictCOW2 propconflictU propconflictFL  logdeathpop40U {
xtivreg2 `x' yr1940- yr1980  yr_schlong (logmaddpop=compsjmhatit) if  year>1930 & year<1990,   fe cluster(ctrycluster)
outreg2 using Results/educ_p2.tex, keep(logmaddpop yr_schlong) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("`x'") append nocons label noaster
}

cap erase Results/educ_p1.txt
cap erase Results/educ_p2.txt

