////////////////////////////////////////////////////////////////////////////////
/*									TABLE 4									  */
////////////////////////////////////////////////////////////////////////////////

clear
set more off, permanently

// ---------------------------------------------------------------------------//
// 		        		  	Long differences						       	  //	
// ---------------------------------------------------------------------------//

clear
use "$DATA"

xtivreg2 propconflictCOW2 yr1940- yr1980 (logmaddpop=compsjmhatit) if newsample40_COW==1 & (year==1940 | year==1980) ,   fe cluster(ctrycluster)
outreg2 using Results/iv_t1p1.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust))   ctitle("propconflictCOW2") replace nocons label noaster

foreach x of varlist propconflictU propconflictFL logdeathpop40U {
xtivreg2 `x' yr1940- yr1980 (logmaddpop=compsjmhatit) if  newsample40==1 & (year==1940 | year==1980),   fe cluster(ctrycluster)
outreg2 using Results/iv_t1p1.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust))   ctitle("`x'") append nocons label noaster

}

cap erase Results/iv_t1p1.txt

// ---------------------------------------------------------------------------//
// 		        		  			Panel							       	  //	
// ---------------------------------------------------------------------------//

cap erase Results/iv_t1p2.tex
cap erase Results/iv_t1p2.txt

foreach x of varlist propconflictCOW2 propconflictU propconflictFL  logdeathpop40U {
xtivreg2 `x' yr1940- yr1980 (logmaddpop=compsjmhatit) if  year>1930 & year<1990,   fe cluster(ctrycluster)
outreg2 using Results/iv_t1p2.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust))   ctitle("`x'") append nocons label noaster
}

cap erase Results/iv_t1p2.txt
