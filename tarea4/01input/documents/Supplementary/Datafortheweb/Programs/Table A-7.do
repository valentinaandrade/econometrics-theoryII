////////////////////////////////////////////////////////////////////////////////
/*							    	TABLE A7								  */
////////////////////////////////////////////////////////////////////////////////

clear
set more off, permanently

// ---------------------------------------------------------------------------//
// 							LONG DIFFERENCES: FIRST STAGE					  //	
// ---------------------------------------------------------------------------//
clear
use "$DATA"

xtreg logmaddpop yr1940- yr1980 compsjmhatit if asia!=1 & newsample40_COW==1 & (year==1940 | year==1980),  fe cluster(ctrycluster)
outreg2  using Results/continents_p1.tex, keep(compsjmhatit) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("1")  replace nocons label noaster
xtreg logmaddpop yr1940- yr1980 compsjmhatit if africa!=1 & newsample40_COW==1 & (year==1940 | year==1980),  fe cluster(ctrycluster)
outreg2  using Results/continents_p1.tex, keep(compsjmhatit) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("2")  append nocons label noaster
xtreg logmaddpop yr1940- yr1980 compsjmhatit if america!=1 & newsample40_COW==1 & (year==1940 | year==1980),  fe cluster(ctrycluster)
outreg2  using Results/continents_p1.tex, keep(compsjmhatit) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("3")  append nocons label noaster
xtreg logmaddpop yr1940- yr1980 compsjmhatit if auscont!=1 & newsample40_COW==1 & (year==1940 | year==1980),  fe cluster(ctrycluster)
outreg2  using Results/continents_p1.tex, keep(compsjmhatit) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("4")  append nocons label noaster

// ---------------------------------------------------------------------------//
// 							LONG DIFFERENCES: REDUCED FORM 					  //	
// ---------------------------------------------------------------------------//

xtreg propconflictCOW2 compsjmhatit yr1940- yr1980  if asia!=1  & newsample40_COW==1 & (year==1940 | year==1980),  fe cluster(ctrycluster)
outreg2  using Results/continents_p1.tex, keep(compsjmhatit) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("5")  append nocons label noaster
xtreg propconflictCOW2 compsjmhatit yr1940- yr1980  if africa!=1 & newsample40_COW==1 & (year==1940 | year==1980),  fe cluster(ctrycluster)
outreg2  using Results/continents_p1.tex, keep(compsjmhatit) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("6")  append nocons label noaster
xtreg propconflictCOW2 compsjmhatit yr1940- yr1980  if america!=1 & newsample40_COW==1 & (year==1940 | year==1980),  fe cluster(ctrycluster)
outreg2  using Results/continents_p1.tex, keep(compsjmhatit) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("7")  append nocons label noaster
xtreg propconflictCOW2 compsjmhatit yr1940- yr1980  if auscont!=1 & newsample40_COW==1 & (year==1940 | year==1980),  fe cluster(ctrycluster)
outreg2  using Results/continents_p1.tex, keep(compsjmhatit) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("8")  append nocons label noaster

// ---------------------------------------------------------------------------//
// 							   LONG DIFFERENCES: 2SLS	 					  //	
// ---------------------------------------------------------------------------//

xtivreg2  propconflictCOW2 (logmaddpop=compsjmhatit)  yr1940- yr1980 if asia!=1 & newsample40_COW==1 & (year==1940 | year==1980) ,    fe cluster(ctrycluster)
outreg2  using Results/continents_p1.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("9")  append nocons label noaster
xtivreg2  propconflictCOW2 (logmaddpop=compsjmhatit)  yr1940- yr1980 if africa!=1 & newsample40_COW==1 & (year==1940 | year==1980) ,    fe cluster(ctrycluster)
outreg2  using Results/continents_p1.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("10")  append nocons label noaster
xtivreg2  propconflictCOW2 (logmaddpop=compsjmhatit)  yr1940- yr1980 if america!=1 & newsample40_COW==1 & (year==1940 | year==1980) ,    fe cluster(ctrycluster)
outreg2  using Results/continents_p1.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("11")  append nocons label noaster
xtivreg2  propconflictCOW2 (logmaddpop=compsjmhatit)  yr1940- yr1980 if auscont!=1 & newsample40_COW==1 & (year==1940 | year==1980) ,    fe cluster(ctrycluster)
outreg2  using Results/continents_p1.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("12")  append nocons label noaster

cap erase Results/continents_p1.txt

// ---------------------------------------------------------------------------//
// 							  	PANEL: FIRST STAGE	 						  //	
// ---------------------------------------------------------------------------//

xtreg logmaddpop yr1940- yr1980 compsjmhatit if asia!=1 & year>1930 & year<1990 & propconflictCOW2~=.,  fe cluster(ctrycluster)
outreg2  using Results/continents_p2.tex, keep(compsjmhatit) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("1")  replace nocons label noaster
xtreg logmaddpop yr1940- yr1980 compsjmhatit if africa!=1 & year>1930 & year<1990 & propconflictCOW2~=.,  fe cluster(ctrycluster)
outreg2  using Results/continents_p2.tex, keep(compsjmhatit) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("2")  append nocons label noaster
xtreg logmaddpop yr1940- yr1980 compsjmhatit if america!=1 & year>1930 & year<1990 & propconflictCOW2~=.,  fe cluster(ctrycluster)
outreg2  using Results/continents_p2.tex, keep(compsjmhatit) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("3")  append nocons label noaster
xtreg logmaddpop yr1940- yr1980 compsjmhatit if auscont!=1 & year>1930 & year<1990 & propconflictCOW2~=.,  fe cluster(ctrycluster)
outreg2  using Results/continents_p2.tex, keep(compsjmhatit) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("4")  append nocons label noaster

// ---------------------------------------------------------------------------//
// 							  		PANEL: REDUCED FORM 					  //	
// ---------------------------------------------------------------------------//

xtreg propconflictCOW2 compsjmhatit yr1940- yr1980  if asia!=1 & year>1930 & year<1990,  fe cluster(ctrycluster)
outreg2  using Results/continents_p2.tex, keep(compsjmhatit) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("5")  append nocons label noaster
xtreg propconflictCOW2 compsjmhatit yr1940- yr1980  if africa!=1 & year>1930 & year<1990,  fe cluster(ctrycluster)
outreg2  using Results/continents_p2.tex, keep(compsjmhatit) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("6")  append nocons label noaster
xtreg propconflictCOW2 compsjmhatit yr1940- yr1980  if america!=1 & year>1930 & year<1990,  fe cluster(ctrycluster)
outreg2  using Results/continents_p2.tex, keep(compsjmhatit) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("7")  append nocons label noaster
xtreg propconflictCOW2 compsjmhatit yr1940- yr1980  if auscont!=1 & year>1930 & year<1990,  fe cluster(ctrycluster)
outreg2  using Results/continents_p2.tex, keep(compsjmhatit) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("8")  append nocons label noaster

// ---------------------------------------------------------------------------//
// 							  		PANEL: 2SLS	 							  //	
// ---------------------------------------------------------------------------//

xtivreg2  propconflictCOW2 (logmaddpop=compsjmhatit)  yr1940- yr1980 if asia!=1 & year>1930 & year<1990 ,    fe cluster(ctrycluster)
outreg2  using Results/continents_p2.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("9")  append nocons label noaster
xtivreg2  propconflictCOW2 (logmaddpop=compsjmhatit)  yr1940- yr1980 if africa!=1 & year>1930 & year<1990 ,    fe cluster(ctrycluster)
outreg2  using Results/continents_p2.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("9")  append nocons label noaster
xtivreg2  propconflictCOW2 (logmaddpop=compsjmhatit)  yr1940- yr1980 if america!=1 & year>1930 & year<1990 ,    fe cluster(ctrycluster)
outreg2  using Results/continents_p2.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("9")  append nocons label noaster
xtivreg2  propconflictCOW2 (logmaddpop=compsjmhatit)  yr1940- yr1980 if auscont!=1 & year>1930 & year<1990 ,    fe cluster(ctrycluster)
outreg2  using Results/continents_p2.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust)) ctitle("9")  append nocons label noaster

cap erase Results/continents_p2.txt
