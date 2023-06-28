////////////////////////////////////////////////////////////////////////////////
/*									TABLE 5									  */
////////////////////////////////////////////////////////////////////////////////

clear
set more off, permanently

// ---------------------------------------------------------------------------//
// 		        		  	Long differences - 2SLS					     	  //	
// ---------------------------------------------------------------------------//

clear 
use "$DATA"

xtivreg2  propconflictCOW2 (logmaddpop=compsjmhatit)   yr1940- yr1980 if newsample40_COW==1 & (year==1940 | year==1980) ,    fe cluster(ctrycluster)
outreg2 logmaddpop using Results/iv_t2p1.tex, keep(logmaddpop) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust))  ctitle("1") nor2 nocon label less(0) replace noaster
xtivreg2  propconflictCOW2 (logmaddpop=compsjmhatit)   yr1940- yr1980 if newsample40_COW==1 & EE!=1  & (year==1940 | year==1980),    fe cluster(ctrycluster)
outreg2 logmaddpop using Results/iv_t2p1.tex, keep(logmaddpop) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust))  ctitle("2") nor2 nocon label less(0) append noaster
xtivreg2  propconflictCOW2 (logmaddpop=compsjmhatit)   yr1940- yr1980 if newsample40_COW==1 & WE!=1  & (year==1940 | year==1980),    fe cluster(ctrycluster)
outreg2 logmaddpop using Results/iv_t2p1.tex, keep(logmaddpop) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust))  ctitle("3") nor2 nocon label less(0) append noaster
xtivreg2  propconflictCOW2 (logmaddpop=compsjmhatit)   yr1940- yr1980 if newsample40_COW==1 & (year==1940 | year==1980) & startrich~=1 ,    fe cluster(ctrycluster)
outreg2 logmaddpop using Results/iv_t2p1.tex, keep(logmaddpop) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust))  ctitle("4") nor2 nocon label less(0) append noaster
xtivreg2  propconflictCOW2 (logmaddpop=compsjmhatit)   yr1940- yr1980 if newsample40_COW==1 & (year==1940 | year==1980)  & wwii~=1,    fe cluster(ctrycluster)
outreg2 logmaddpop using Results/iv_t2p1.tex, keep(logmaddpop) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust))  ctitle("5") nor2 nocon label less(0) append noaster
xtivreg2  propconflictCOW250 (logmaddpop=compsjmhatit)   yr1940- yr1980 if newsample40_COW==1 & (year==1940 | year==1980)  ,    fe cluster(ctrycluster)
outreg2 logmaddpop using Results/iv_t2p1.tex, keep(logmaddpop) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust))  ctitle("6") nor2 nocon label less(0) append noaster
xtivreg2  propconflictCOW1 (logmaddpop=compsjmhatit)   yr1940- yr1980 if newsample40_COW==1 & (year==1940 | year==1980) ,    fe cluster(ctrycluster)
outreg2 logmaddpop using Results/iv_t2p1.tex, keep(logmaddpop) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust))  ctitle("7") nor2 nocon label less(0) append noaster
xtivreg2  propconflictCOW2 (logmaddpop=compsjmhatit) youngest  yr1940- yr1980 if newsample40_COW==1 & (year==1940 | year==1980) ,    fe cluster(ctrycluster)
outreg2 logmaddpop using Results/iv_t2p1.tex, keep(logmaddpop) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust))  ctitle("8") nor2 nocon label less(0) append noaster
xtivreg2 propconflictCOW2 yr1940- yr1980 loglife20new (logmaddpop=compsjmhatit) if newsample40_COW==1 & (year==1940 | year==1980) ,   fe cluster(ctrycluster)
outreg2 logmaddpop using Results/iv_t2p1.tex, keep(logmaddpop) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust))  ctitle("9") nor2 nocon label less(0) append noaster
xtivreg2 propconflictCOW2 yr1940-yr1990 yr2000 (logmaddpop=compsjmhatit) if  newsample40_COW==1 & (year==1940 | year==2000) ,   fe cluster(ctrycluster)
outreg2 logmaddpop using Results/iv_t2p1.tex, keep(logmaddpop) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust))  ctitle("10") nor2 nocon label less(0) append noaster

cap erase Results/iv_t2p1.txt

// ---------------------------------------------------------------------------//
// 		        		  Long Differences - First Stage			     	  //	
// ---------------------------------------------------------------------------//

clear
use "$DATA"

xtreg logmaddpop yr1940- yr1980 compsjmhatit if newsample40_COW==1 & (year==1940 | year==1980) ,  fe cluster(ctrycluster)
outreg2 using Results/fs_t1p1.tex, keep(compsjmhatit) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("1") replace nocons label noaster
xtreg logmaddpop yr1940- yr1980 compsjmhatit if newsample40_COW==1 & (year==1940 | year==1980) & EE!=1 ,  fe cluster(ctrycluster)
outreg2 using Results/fs_t1p1.tex, keep(compsjmhatit) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("2") append nocons label noaster
xtreg logmaddpop yr1940- yr1980 compsjmhatit if newsample40_COW==1 & (year==1940 | year==1980) & WE!=1 ,  fe cluster(ctrycluster)
outreg2 using Results/fs_t1p1.tex, keep(compsjmhatit) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("3") append nocons label noaster
xtreg logmaddpop yr1940- yr1980 compsjmhatit if newsample40_COW==1 & (year==1940 | year==1980) & startrich~=1  ,  fe cluster(ctrycluster)
outreg2 using Results/fs_t1p1.tex, keep(compsjmhatit) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("4") append nocons label noaster
xtreg logmaddpop yr1940- yr1980 compsjmhatit if newsample40_COW==1 & (year==1940 | year==1980) & wwii~=1 ,  fe cluster(ctrycluster)
outreg2 using Results/fs_t1p1.tex, keep(compsjmhatit) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("5") append nocons label noaster
xtreg logmaddpop yr1940- yr1980 compsjmhatit if newsample40_COW==1 & (year==1940 | year==1980) ,  fe cluster(ctrycluster)
outreg2 using Results/fs_t1p1.tex, keep(compsjmhatit) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("6") append nocons label noaster
xtreg logmaddpop yr1940- yr1980 compsjmhatit if newsample40_COW==1 & (year==1940 | year==1980) ,  fe cluster(ctrycluster)
outreg2 using Results/fs_t1p1.tex, keep(compsjmhatit) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("7") append nocons label noaster
xtreg logmaddpop yr1940- yr1980 compsjmhatit youngest if newsample40_COW==1 & (year==1940 | year==1980),  fe cluster(ctrycluster)
outreg2 using Results/fs_t1p1.tex, keep(compsjmhatit) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("8") append nocons label noaster
xtreg logmaddpop yr1940- yr1980 compsjmhatit loglife20new if newsample40_COW==1 & (year==1940 | year==1980),  fe cluster(ctrycluster)
outreg2 using Results/fs_t1p1.tex, keep(compsjmhatit) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("9") append nocons label noaster
xtreg logmaddpop yr1940-yr1990 yr2000 compsjmhatit  if newsample40_COW==1 & (year==1940 | year==2000),  fe cluster(ctrycluster)
outreg2 using Results/fs_t1p1.tex, keep(compsjmhatit) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("10") append nocons label noaster

cap erase Results/fs_t1p1.txt

// ---------------------------------------------------------------------------//
// 		        		  			PANEL - 2SLS					     	  //	
// ---------------------------------------------------------------------------//


clear 
use "$DATA"

xtivreg2  propconflictCOW2 (logmaddpop=compsjmhatit)   yr1940- yr1980 if  year>1930 & year<1990 ,    fe cluster(ctrycluster)
outreg2 logmaddpop using Results/iv_t2p2.tex, keep(logmaddpop) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust))  ctitle("1") nor2 nocon label less(0) replace noaster
xtivreg2  propconflictCOW2 (logmaddpop=compsjmhatit)   yr1940- yr1980 if  year>1930 & year<1990  & EE!=1,    fe cluster(ctrycluster)
outreg2 logmaddpop using Results/iv_t2p2.tex, keep(logmaddpop) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust))  ctitle("2") nor2 nocon label less(0) append noaster
xtivreg2  propconflictCOW2 (logmaddpop=compsjmhatit)   yr1940- yr1980 if  year>1930 & year<1990  & WE!=1,    fe cluster(ctrycluster)
outreg2 logmaddpop using Results/iv_t2p2.tex, keep(logmaddpop) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust))  ctitle("3") nor2 nocon label less(0) append noaster
xtivreg2  propconflictCOW2 (logmaddpop=compsjmhatit)   yr1940- yr1980 if year>1930 & year<1990 & startrich~=1 ,    fe cluster(ctrycluster)
outreg2 logmaddpop using Results/iv_t2p2.tex, keep(logmaddpop) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust))  ctitle("4") nor2 nocon label less(0) append noaster
xtivreg2  propconflictCOW2 (logmaddpop=compsjmhatit)   yr1940- yr1980 if  year>1930 & year<1990  & wwii~=1,    fe cluster(ctrycluster)
outreg2 logmaddpop using Results/iv_t2p2.tex, keep(logmaddpop) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust))  ctitle("5") nor2 nocon label less(0) append noaster
xtivreg2  propconflictCOW250 (logmaddpop=compsjmhatit)   yr1940- yr1980 if  year>1930 & year<1990 ,    fe cluster(ctrycluster)
outreg2 logmaddpop using Results/iv_t2p2.tex, keep(logmaddpop) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust))  ctitle("6") nor2 nocon label less(0) append noaster
xtivreg2  propconflictCOW1 (logmaddpop=compsjmhatit)   yr1940- yr1980 if  year>1930 & year<1990 ,    fe cluster(ctrycluster)
outreg2 logmaddpop using Results/iv_t2p2.tex, keep(logmaddpop) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust))  ctitle("7") nor2 nocon label less(0) append noaster
xtivreg2  propconflictCOW2 (logmaddpop=compsjmhatit) youngest  yr1940- yr1980 if  year>1930 & year<1990 ,    fe cluster(ctrycluster)
outreg2 logmaddpop using Results/iv_t2p2.tex, keep(logmaddpop) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust))  ctitle("8") nor2 nocon label less(0) append noaster
xtivreg2 propconflictCOW2 yr1940- yr1980 loglife20new (logmaddpop=compsjmhatit) if  year>1930 & year<1990,   fe cluster(ctrycluster)
outreg2 logmaddpop using Results/iv_t2p2.tex, keep(logmaddpop) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust))  ctitle("9") nor2 nocon label less(0) append noaster
xtivreg2 propconflictCOW2 yr1940-yr1990 yr2000 (logmaddpop=compsjmhatit) if year>1930 & year<=2000,   fe cluster(ctrycluster)
outreg2 logmaddpop using Results/iv_t2p2.tex, keep(logmaddpop) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust))  ctitle("10") nor2 nocon label less(0) append noaster

cap erase Results/iv_t2p2.txt


// ---------------------------------------------------------------------------//
// 		        		  			PANEL - First Stage				     	  //	
// ---------------------------------------------------------------------------//

clear
use "$DATA"

xtreg logmaddpop yr1940- yr1980 compsjmhatit if year>1930 & year<1990 & propconflictCOW2~=.  ,  fe cluster(ctrycluster)
outreg2 using Results/fs_t1p2.tex, keep(compsjmhatit) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("1") replace nocons label noaster
xtreg logmaddpop yr1940- yr1980 compsjmhatit if year>1930 & year<1990 & propconflictCOW2~=.  & EE!=1 ,  fe cluster(ctrycluster)
outreg2 using Results/fs_t1p2.tex, keep(compsjmhatit) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("2") append nocons label noaster
xtreg logmaddpop yr1940- yr1980 compsjmhatit if year>1930 & year<1990 & propconflictCOW2~=.  & WE!=1 ,  fe cluster(ctrycluster)
outreg2 using Results/fs_t1p2.tex, keep(compsjmhatit) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("3") append nocons label noaster
xtreg logmaddpop yr1940- yr1980 compsjmhatit if year>1930 & year<1990 & propconflictCOW2~=.  & startrich~=1  ,  fe cluster(ctrycluster)
outreg2 using Results/fs_t1p2.tex, keep(compsjmhatit) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("4") append nocons label noaster
xtreg logmaddpop yr1940- yr1980 compsjmhatit if year>1930 & year<1990 & propconflictCOW2~=.  & wwii~=1  ,  fe cluster(ctrycluster)
outreg2 using Results/fs_t1p2.tex, keep(compsjmhatit) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("5") append nocons label noaster
xtreg logmaddpop yr1940- yr1980 compsjmhatit if year>1930 & year<1990 & propconflictCOW2~=.  ,  fe cluster(ctrycluster)
outreg2 using Results/fs_t1p2.tex, keep(compsjmhatit) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("6") append nocons label noaster
xtreg logmaddpop yr1940- yr1980 compsjmhatit if year>1930 & year<1990 & propconflictCOW2~=.  ,  fe cluster(ctrycluster)
outreg2 using Results/fs_t1p2.tex, keep(compsjmhatit) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("7") append nocons label noaster
xtreg logmaddpop yr1940- yr1980 compsjmhatit youngest if year>1930 & year<1990 & propconflictCOW2~=. ,  fe cluster(ctrycluster)
outreg2 using Results/fs_t1p2.tex, keep(compsjmhatit) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("8") append nocons label noaster
xtreg logmaddpop yr1940- yr1980 compsjmhatit loglife20new if year>1930 & year<1990 & propconflictCOW2~=. ,  fe cluster(ctrycluster)
outreg2 using Results/fs_t1p2.tex, keep(compsjmhatit) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("9") append nocons label noaster
xtreg logmaddpop yr1940-yr1990 yr2000 compsjmhatit if year>1930 & year<=2000 & propconflictCOW2~=. ,  fe cluster(ctrycluster)
outreg2 using Results/fs_t1p2.tex, keep(compsjmhatit) tex(frag) dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("10") append nocons label noaster

cap erase Results/fs_t1p2.txt



