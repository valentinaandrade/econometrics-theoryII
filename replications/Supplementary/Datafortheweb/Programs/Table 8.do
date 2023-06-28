////////////////////////////////////////////////////////////////////////////////
/*							    	TABLE 8									  */
////////////////////////////////////////////////////////////////////////////////

clear
set more off, permanently

// ---------------------------------------------------------------------------//
// 		        		  	Natural Resources						       	  //	
// ---------------------------------------------------------------------------//

/*--- Long Differences ---*/
clear 
use "$DATA"

xtivreg2 propconflictNR yr1940- yr1980 (logmaddpop = compsjmhatit) if newsample40_COW==1 & (year==1940 | year==1980) ,fe cluster(ctrycluster)
outreg2  using Results/nr_p1.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("1")  replace nocons label noaster

xtivreg2 propconflict yr1940- yr1980 (logmaddpop = compsjmhatit) if newsample40_COW==1 & (year==1940 | year==1980) ,fe cluster(ctrycluster)
outreg2  using Results/nr_p1.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("1")  append nocons label noaster

/*--- Panel ---*/

xtivreg2 propconflictNR yr1940- yr1980 (logmaddpop = compsjmhatit) if year>1930 & year<1990 ,fe cluster(ctrycluster)
outreg2  using Results/nr_p2.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("1")  replace nocons label noaster

xtivreg2 propconflict yr1940- yr1980 (logmaddpop = compsjmhatit) if year>1930 & year<1990 ,fe cluster(ctrycluster)
outreg2  using Results/nr_p2.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("2")  append nocons label noaster


// ---------------------------------------------------------------------------//
// 		        		  	Population density						       	  //	
// ---------------------------------------------------------------------------//

/*--- Long Differences ---*/
clear
use "$DATA"

xtivreg2 propconflictCOW2 yr1940- yr1980 (logmaddpop = compsjmhatit) if density_above==1 & newsample40_COW==1 & (year==1940 | year==1980) ,fe cluster(ctrycluster)
outreg2  using Results/nr_p1.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("3")  append nocons label noaster

xtivreg2 propconflictCOW2 yr1940- yr1980 (logmaddpop = compsjmhatit) if density_above==0 & newsample40_COW==1 & (year==1940 | year==1980) ,fe cluster(ctrycluster)
outreg2  using Results/nr_p1.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("4")  append nocons label noaster

/*--- Panel ---*/

xtivreg2 propconflictCOW2 yr1940- yr1980 (logmaddpop = compsjmhatit) if density_above==1 & year>1930 & year<1990 ,fe cluster(ctrycluster)
outreg2  using Results/nr_p2.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("3")  append nocons label noaster

xtivreg2 propconflictCOW2 yr1940- yr1980 (logmaddpop = compsjmhatit) if density_above==0 & year>1930 & year<1990 ,fe cluster(ctrycluster)
outreg2  using Results/nr_p2.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("4")  append nocons label noaster



// ---------------------------------------------------------------------------//
// 		        		  		Fast vs. Slow						       	  //	
// ---------------------------------------------------------------------------//

/*--- Long Differences ---*/
clear
use "$dir/Data/data1940.dta"

replace logmaddpop = changelogpopulation
label var logmaddpop "log of population"

foreach y of varlist y_minus_median y_plus_median{
ivreg2 `y' (logmaddpop=changemortality) if newbasesample==1 ,  cluster(ctrycluster)
outreg2  using Results/nr_p1.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("`y'")  append nocons label noaster
}


/*--- Panel ---*/

clear 
use "$DATA"

xtivreg2 y_minus_median yr1940- yr1980 (logmaddpop = compsjmhatit) if year>=1940 & year<=1980 ,fe cluster(ctrycluster)
outreg2  using Results/nr_p2.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("5")  append nocons label noaster

xtivreg2 y_plus_median yr1940- yr1980 (logmaddpop = compsjmhatit) if year>=1940 & year<=1980 ,fe cluster(ctrycluster)
outreg2  using Results/nr_p2.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("6")  append nocons label noaster

// ---------------------------------------------------------------------------//
// 		        		  		Shock vs. No Shock					       	  //	
// ---------------------------------------------------------------------------//

/*--- Long Differences ---*/
clear
use "$DATA"

xtivreg2 y_plus_median_shock yr1940- yr1980 (logmaddpop = compsjmhatit) if newsample40_COW==1 & (year==1940 | year==1980) ,fe cluster(ctrycluster)
outreg2  using Results/nr_p1.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("7")  append nocons label noaster


xtivreg2 y_minus_median_shock yr1940- yr1980 (logmaddpop = compsjmhatit) if newsample40_COW==1 & (year==1940 | year==1980) ,fe cluster(ctrycluster)
outreg2  using Results/nr_p1.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("8")  append nocons label noaster


/*--- Panel ---*/

clear
use "$DATA"

xtivreg2 y_plus_median_shock yr1940- yr1980 (logmaddpop = compsjmhatit) if year>1930 & year<1990 ,fe cluster(ctrycluster)
outreg2  using Results/nr_p2.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("7")  append nocons label noaster

xtivreg2 y_minus_median_shock yr1940- yr1980 (logmaddpop = compsjmhatit) if year>1930 & year<1990 ,fe cluster(ctrycluster)
outreg2  using Results/nr_p2.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("8")  append nocons label noaster

cap erase Results/nr_p1.txt
cap erase Results/nr_p2.txt
