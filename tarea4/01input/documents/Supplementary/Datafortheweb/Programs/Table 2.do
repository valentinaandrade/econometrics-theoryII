////////////////////////////////////////////////////////////////////////////////
/*									TABLE 2									  */
////////////////////////////////////////////////////////////////////////////////

clear
set more off, permanently

// ---------------------------------------------------------------------------//
// 		        		  	Long differences						       	  //	
// ---------------------------------------------------------------------------//

clear
use "$DATA"

xtreg propconflictCOW2 logmaddpop yr1940- yr1980 if newsample40_COW==1 & (year==1940 | year==1980),  fe cluster(ctrycluster)
outreg2 using Results/ols_p1.tex, keep(logmaddpop) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("1") replace nocons label noaster

xtreg propconflictU logmaddpop yr1940- yr1980 if newsample40==1 & (year==1940 | year==1980),  fe cluster(ctrycluster)
outreg2 using Results/ols_p1.tex, keep(logmaddpop) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("2") append nocons label noaster

xtreg propconflictFL logmaddpop yr1940- yr1980 if newsample40==1 & (year==1940 | year==1980),  fe cluster(ctrycluster)
outreg2 using Results/ols_p1.tex, keep(logmaddpop) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("3") append nocons label noaster

xtreg logdeathpop40U logmaddpop yr1940- yr1980 if newsample40==1 & (year==1940 | year==1980),  fe cluster(ctrycluster)
outreg2 using Results/ols_p1.tex, keep(logmaddpop) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("4") append nocons label noaster

cap erase Results/ols_p1.txt


// ---------------------------------------------------------------------------//
// 		        		  			Panel							       	  //	
// ---------------------------------------------------------------------------//

cap erase Results/ols_p2.tex
cap erase Results/ols_p2.txt

foreach var in propconflictCOW2 propconflictU propconflictFL logdeathpop40U {
xtreg `var' logmaddpop yr1940- yr1980 if year>=1940 & year<=1980,  fe cluster(ctrycluster)
outreg2 using Results/ols_p2.tex, keep(logmaddpop) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("`var'") append nocons label noaster

}
cap erase Results/ols_p2.txt


// ---------------------------------------------------------------------------//
// 		        	Long differences & Control for Young			       	  //	
// ---------------------------------------------------------------------------//

clear
use "$DATA"

xtreg propconflictCOW2 logmaddpop youngest yr1940- yr1980 if newsample40_COW==1 & (year==1940 | year==1980),  fe cluster(ctrycluster)
outreg2 using Results/ols_p3.tex, keep(logmaddpop youngest) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("1") replace nocons label noaster

xtreg propconflictU logmaddpop youngest yr1940- yr1980 if newsample40==1 & (year==1940 | year==1980),  fe cluster(ctrycluster)
outreg2 using Results/ols_p3.tex, keep(logmaddpop youngest) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("2") append nocons label noaster

xtreg propconflictFL logmaddpop youngest yr1940- yr1980 if newsample40==1 & (year==1940 | year==1980),  fe cluster(ctrycluster)
outreg2 using Results/ols_p3.tex, keep(logmaddpop youngest) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("3") append nocons label noaster

xtreg logdeathpop40U logmaddpop youngest yr1940- yr1980 if newsample40==1 & (year==1940 | year==1980),  fe cluster(ctrycluster)
outreg2 using Results/ols_p3.tex, keep(logmaddpop youngest) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("4") append nocons label noaster

cap erase Results/ols_p3.txt


// ---------------------------------------------------------------------------//
// 		        		  	Panel & Control for Young				       	  //	
// ---------------------------------------------------------------------------//

cap erase Results/ols_p4.tex
cap erase Results/ols_p4.txt

foreach var in propconflictCOW2 propconflictU propconflictFL logdeathpop40U {
xtreg `var' logmaddpop youngest yr1940- yr1980 if year>=1940 & year<=1980,  fe cluster(ctrycluster)
outreg2 using Results/ols_p4.tex, keep(logmaddpop youngest) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("`var'") append nocons label noaster

}
cap erase Results/ols_p4.txt
