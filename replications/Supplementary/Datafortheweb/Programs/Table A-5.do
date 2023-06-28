////////////////////////////////////////////////////////////////////////////////
/*							    	TABLE A5								  */
////////////////////////////////////////////////////////////////////////////////

clear
set more off, permanently

// ---------------------------------------------------------------------------//
// 		        		  	Long differences						       	  //	
// ---------------------------------------------------------------------------//
clear 
use "$DATA"

generate transformation = log(death_population40U+sqrt(1+death_population40U^2))
generate dummy=1 if propconflictCOW2!=0 & propconflictCOW2!=.
replace dummy=0 if dummy==. & propconflictCOW2==0 

xtreg transformation yr1940- yr1980 logmaddpop if newsample40_COW==1 & (year==1940 | year==1980), fe cluster(ctrycluster)
outreg2 logmaddpop using Results/depvar_p1.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("1")replace nocons label noaster
xtivreg2 transformation yr1940- yr1980 (logmaddpop=compsjmhatit) if newsample40_COW==1 & (year==1940 | year==1980), fe cluster(ctrycluster)
outreg2 logmaddpop using Results/depvar_p1.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("2") append nocons label noaster
xtreg dummy yr1940- yr1980 logmaddpop if newsample40_COW==1 & (year==1940 | year==1980), fe cluster(ctrycluster)
outreg2 logmaddpop using Results/depvar_p1.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("3") append nocons label noaster
xtivreg2 dummy yr1940- yr1980 (logmaddpop=compsjmhatit) if newsample40_COW==1 & (year==1940 | year==1980), fe cluster(ctrycluster)
outreg2 logmaddpop using Results/depvar_p1.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("4") append nocons label noaster

cap erase Results/depvar_p1.txt

// ---------------------------------------------------------------------------//
// 		        		  			Panel							       	  //	
// ---------------------------------------------------------------------------//
clear 
use "$DATA"

generate transformation = log(death_population40U+sqrt(1+death_population40U^2))
generate dummy=1 if propconflictCOW2!=0 & propconflictCOW2!=.
replace dummy=0 if dummy==. & propconflictCOW2==0

xtreg transformation yr1940- yr1980 logmaddpop if year>1930 & year<1990, fe cluster(ctrycluster)
outreg2 logmaddpop using Results/depvar_p2.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("1")replace nocons label noaster
xtivreg2  transformation yr1940- yr1980 (logmaddpop=compsjmhatit) if year>1930 & year<1990, fe cluster(ctrycluster)
outreg2 logmaddpop using Results/depvar_p2.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("2") append nocons label noaster
xtreg dummy yr1940- yr1980 logmaddpop if year>1930 & year<1990, fe cluster(ctrycluster)
outreg2 logmaddpop using Results/depvar_p2.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("3") append nocons label noaster
xtivreg2 dummy yr1940- yr1980 (logmaddpop=compsjmhatit) if year>1930 & year<1990, fe cluster(ctrycluster)
outreg2 logmaddpop using Results/depvar_p2.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("4") append nocons label noaster

cap erase Results/depvar_p2.txt
