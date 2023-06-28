////////////////////////////////////////////////////////////////////////////////
/*							    	TABLE A8								  */
////////////////////////////////////////////////////////////////////////////////

clear
set more off, permanently

// ---------------------------------------------------------------------------//
// 		        		  	Long differences						       	  //	
// ---------------------------------------------------------------------------//

clear
use "$DATA"

xtreg  propconflictCOW2 compsjmhatit yr1940- yr1980 if newsample40_COW==1 & (year==1940 | year==1980) ,    fe cluster(ctrycluster)
outreg2 logmaddpop using Results/rf_t2p1.tex, keep(compsjmhatit) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust))  ctitle("1") nor2 nocon label less(0) replace noaster
xtreg  propconflictCOW2 compsjmhatit yr1940- yr1980 if newsample40_COW==1 & (year==1940 | year==1980) & EE!=1 ,    fe cluster(ctrycluster)
outreg2 logmaddpop using Results/rf_t2p1.tex, keep(compsjmhatit) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust))  ctitle("2") nor2 nocon label less(0) append noaster
xtreg  propconflictCOW2 compsjmhatit yr1940- yr1980 if newsample40_COW==1 & (year==1940 | year==1980) & WE!=1 ,    fe cluster(ctrycluster)
outreg2 logmaddpop using Results/rf_t2p1.tex, keep(compsjmhatit) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust))  ctitle("3") nor2 nocon label less(0) append noaster
xtreg  propconflictCOW2 compsjmhatit yr1940- yr1980 if newsample40_COW==1 & (year==1940 | year==1980) & startrich~=1 ,    fe cluster(ctrycluster)
outreg2 logmaddpop using Results/rf_t2p1.tex, keep(compsjmhatit) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust))  ctitle("4") nor2 nocon label less(0) append noaster
xtreg  propconflictCOW2 compsjmhatit yr1940- yr1980 if newsample40_COW==1 & (year==1940 | year==1980) & wwii~=1 ,    fe cluster(ctrycluster)
outreg2 logmaddpop using Results/rf_t2p1.tex, keep(compsjmhatit) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust))  ctitle("5") nor2 nocon label less(0) append noaster
xtreg  propconflictCOW250 compsjmhatit yr1940- yr1980 if newsample40_COW==1 & (year==1940 | year==1980) ,    fe cluster(ctrycluster)
outreg2 logmaddpop using Results/rf_t2p1.tex, keep(compsjmhatit) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust))  ctitle("6") nor2 nocon label less(0) append noaster
xtreg  propconflictCOW1 compsjmhatit yr1940- yr1980 if newsample40_COW==1 & (year==1940 | year==1980) ,    fe cluster(ctrycluster)
outreg2 logmaddpop using Results/rf_t2p1.tex, keep(compsjmhatit) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust))  ctitle("7") nor2 nocon label less(0) append noaster
xtreg  propconflictCOW2 compsjmhatit yr1940- yr1980 youngest if newsample40_COW==1 & (year==1940 | year==1980) ,    fe cluster(ctrycluster)
outreg2 logmaddpop using Results/rf_t2p1.tex, keep(compsjmhatit) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust))  ctitle("8") nor2 nocon label less(0) append noaster
xtreg  propconflictCOW2 compsjmhatit yr1940- yr1990 yr2000 if newsample40_COW==1 & (year==1940 | year==2000) ,    fe cluster(ctrycluster)
outreg2 logmaddpop using Results/rf_t2p1.tex, keep(compsjmhatit) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust))  ctitle("9") nor2 nocon label less(0) append noaster

cap erase Results/rf_t2p1.txt


// ---------------------------------------------------------------------------//
// 		        		  			Panel							       	  //	
// ---------------------------------------------------------------------------//

clear
use "$DATA"

xtreg  propconflictCOW2 compsjmhatit yr1940- yr1980 if year>1930 & year<1990 ,    fe cluster(ctrycluster)
outreg2 logmaddpop using Results/rf_t2p2.tex, keep(compsjmhatit) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust))  ctitle("1") nor2 nocon label less(0) replace noaster
xtreg  propconflictCOW2 compsjmhatit yr1940- yr1980 if year>1930 & year<1990 & EE!=1 ,    fe cluster(ctrycluster)
outreg2 logmaddpop using Results/rf_t2p2.tex, keep(compsjmhatit) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust))  ctitle("2") nor2 nocon label less(0) append noaster
xtreg  propconflictCOW2 compsjmhatit yr1940- yr1980 if year>1930 & year<1990 & WE!=1 ,    fe cluster(ctrycluster)
outreg2 logmaddpop using Results/rf_t2p2.tex, keep(compsjmhatit) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust))  ctitle("3") nor2 nocon label less(0) append noaster
xtreg  propconflictCOW2 compsjmhatit yr1940- yr1980 if year>1930 & year<1990 & startrich~=1 ,    fe cluster(ctrycluster)
outreg2 logmaddpop using Results/rf_t2p2.tex, keep(compsjmhatit) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust))  ctitle("4") nor2 nocon label less(0) append noaster
xtreg  propconflictCOW2 compsjmhatit yr1940- yr1980 if year>1930 & year<1990 & wwii~=1 ,    fe cluster(ctrycluster)
outreg2 logmaddpop using Results/rf_t2p2.tex, keep(compsjmhatit) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust))  ctitle("5") nor2 nocon label less(0) append noaster
xtreg  propconflictCOW250 compsjmhatit yr1940- yr1980 if year>1930 & year<1990 ,    fe cluster(ctrycluster)
outreg2 logmaddpop using Results/rf_t2p2.tex, keep(compsjmhatit) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust))  ctitle("6") nor2 nocon label less(0) append noaster
xtreg  propconflictCOW1 compsjmhatit yr1940- yr1980 if year>1930 & year<1990 ,    fe cluster(ctrycluster)
outreg2 logmaddpop using Results/rf_t2p2.tex, keep(compsjmhatit) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust))  ctitle("7") nor2 nocon label less(0) append noaster
xtreg  propconflictCOW2 compsjmhatit yr1940- yr1980 youngest if year>1930 & year<1990 ,    fe cluster(ctrycluster)
outreg2 logmaddpop using Results/rf_t2p2.tex, keep(compsjmhatit) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust))  ctitle("8") nor2 nocon label less(0) append noaster
xtreg  propconflictCOW2 compsjmhatit yr1940- yr1990 yr2000 if year>1930 & year<=2000 ,    fe cluster(ctrycluster)
outreg2 logmaddpop using Results/rf_t2p2.tex, keep(compsjmhatit) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust))  ctitle("9") nor2 nocon label less(0) append noaster

cap erase Results/rf_t2p2.txt

