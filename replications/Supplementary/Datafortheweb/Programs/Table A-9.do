////////////////////////////////////////////////////////////////////////////////
/*							    	TABLE A9								  */
////////////////////////////////////////////////////////////////////////////////

clear
set more off, permanently

// ---------------------------------------------------------------------------//
// 		        		  	Long differences						       	  //	
// ---------------------------------------------------------------------------//

clear
use "$DATA"

cap erase Results/age_p1_youngest.tex
cap erase Results/age_p1_youngest.txt
cap erase Results/age_p1_medium.tex
cap erase Results/age_p1_medium.txt

xtreg youngest yr1940- yr1980 compsjmhatit if newsample40_COW==1 & (year==1940 | year==1980)  & Russia!=1,  fe cluster(ctrycluster)
outreg2 using Results/age_p1, keep(compsjmhatit) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust))   ctitle("1") replace nocons label noaster
xtreg youngest yr1940- yr1980 compsjmhatit if newsample40_COW==1 & (year==1940 | year==1980)   & startrich~=1  & Russia!=1,  fe cluster(ctrycluster)
outreg2 using Results/age_p1, keep(compsjmhatit) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust))   ctitle("2") append nocons label noaster
xtreg youngest yr1940- yr1980 compsjmhatit if newsample40_COW==1 & (year==1940 | year==1990)  & Russia!=1,  fe cluster(ctrycluster)
outreg2 using Results/age_p1, keep(compsjmhatit) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust))   ctitle("3") append nocons label noaster
xtreg youngest yr1940- yr1980 compsjmhatit if newsample40_COW==1 & (year==1940 | year==1990)   & startrich~=1  & Russia!=1,  fe cluster(ctrycluster)
outreg2 using Results/age_p1, keep(compsjmhatit) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust))   ctitle("4") append nocons label noaster

xtreg medium yr1940- yr1980 compsjmhatit if newsample40_COW==1 & (year==1940 | year==1980)  & Russia!=1,  fe cluster(ctrycluster)
outreg2 using Results/age_p2, keep(compsjmhatit) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust))   ctitle("1") replace nocons label noaster
xtreg medium yr1940- yr1980 compsjmhatit if newsample40_COW==1 & (year==1940 | year==1980)   & startrich~=1  & Russia!=1,  fe cluster(ctrycluster)
outreg2 using Results/age_p2, keep(compsjmhatit) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust))   ctitle("2") append nocons label noaster
xtreg medium yr1940- yr1980 compsjmhatit if newsample40_COW==1 & (year==1940 | year==1990)  & Russia!=1,  fe cluster(ctrycluster)
outreg2 using Results/age_p2, keep(compsjmhatit) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust))   ctitle("3") append nocons label noaster
xtreg medium yr1940- yr1980 compsjmhatit if newsample40_COW==1 & (year==1940 | year==1990)   & startrich~=1  & Russia!=1,  fe cluster(ctrycluster)
outreg2 using Results/age_p2, keep(compsjmhatit) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust))   ctitle("4") append nocons label noaster

cap erase Results/age_p1.txt
cap erase Results/age_p2.txt
