////////////////////////////////////////////////////////////////////////////////
/*							    	TABLE A3								  */
////////////////////////////////////////////////////////////////////////////////

clear
set more off, permanently

// ---------------------------------------------------------------------------//
// 		        				Long differences					       	  //	
// ---------------------------------------------------------------------------//
clear 
use "$DATA"

xtreg  propconflictCOW2 logmaddpop medium yr1940- yr1980  if  newsample40_COW==1 & (year==1940 | year==1980) ,  fe cluster(ctrycluster)
outreg2 logmaddpop medium using Results/ols_t2p1.tex, keep(logmaddpop medium) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("COW") replace nocons label noaster
xtreg propconflictU logmaddpop medium yr1940- yr1980  if  newsample40==1 & (year==1940 | year==1980) ,  fe cluster(ctrycluster)
outreg2 logmaddpop medium using Results/ols_t2p1.tex, keep(logmaddpop medium) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("U") append nocons label noaster
xtreg propconflictFL logmaddpop medium yr1940- yr1980  if newsample40==1 & (year==1940 | year==1980) ,  fe cluster(ctrycluster)
outreg2 logmaddpop medium using Results/ols_t2p1.tex, keep(logmaddpop medium) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("FL") append nocons label noaster
xtreg logdeathpop40U logmaddpop medium yr1940- yr1980  if newsample40==1 & (year==1940 | year==1980) ,  fe cluster(ctrycluster)
outreg2 logmaddpop medium using Results/ols_t2p1.tex, keep(logmaddpop medium) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("Log") append nocons label noaster

cap erase Results/ols_t2p1.txt

// ---------------------------------------------------------------------------//
// 		        		  			Panel						       	  //	
// ---------------------------------------------------------------------------//

xtreg  propconflictCOW2 logmaddpop medium yr1940- yr1980  if  year>1930 & year<1990 ,  fe cluster(ctrycluster)
outreg2 logmaddpop medium using Results/ols_t2p2.tex, keep(logmaddpop medium) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("COW") replace nocons label noaster
xtreg propconflictU logmaddpop medium yr1940- yr1980  if  year>1930 & year<1990 ,  fe cluster(ctrycluster)
outreg2 logmaddpop medium using Results/ols_t2p2.tex, keep(logmaddpop medium) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("U") append nocons label noaster
xtreg propconflictFL logmaddpop medium yr1940- yr1980  if year>1930 & year<1990 ,  fe cluster(ctrycluster)
outreg2 logmaddpop medium using Results/ols_t2p2.tex, keep(logmaddpop medium) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("FL") append nocons label noaster
xtreg logdeathpop40U logmaddpop medium yr1940- yr1980  if  year>1930 & year<1990 ,  fe cluster(ctrycluster)
outreg2 logmaddpop medium using Results/ols_t2p2.tex, keep(logmaddpop medium) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust))  ctitle("Log") append nocons label noaster

cap erase Results/ols_t2p2.txt


