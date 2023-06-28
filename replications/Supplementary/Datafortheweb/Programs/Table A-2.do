////////////////////////////////////////////////////////////////////////////////
/*							    	TABLE A2								  */
////////////////////////////////////////////////////////////////////////////////

clear
set more off, permanently
do "$dir/Programs/programs-bootstrap.do"

// ---------------------------------------------------------------------------//
// 							LONG DIFFERENCES (WILD BOOSTRAP)				  //	
// ---------------------------------------------------------------------------//
* Cluster robust p-values following the wild bootstrap procedure suggested by Cameron, Gelbach and Miller (2008). 
clear 
use "$DATA"
global CLUSTER= "ctrycluster"					
global NULL="no"
global bootreps = 999											
global RHS="cd* yr1940- yr1980"
global TEST="logmaddpop"
global INSTRUMENT="compsjmhatit"
global LHS "propconflictCOW2"
global IF newsample40_COW==1 & (year==1940 | year==1980) 

clear
runme 0																			
use "$DATA", replace
cap keep if $IF
reg $LHS $RHS $TEST , cluster($CLUSTER)
display "$pctile_t_wild"
outreg2 using Results/additional_p1.tex, keep($TEST) tex(frag) dec(3) noas addstat (Number of clusters, e(N_clust), "p-value, wild bootstrap", $pctile_t_wild)  /// 
 ctitle("1") replace nocons label
 
clear
runmeIV 0
clear
use "$DATA", replace
keep if $IF
ivreg $LHS $RHS ($TEST=$INSTRUMENT) ,   cluster($CLUSTER)
display "$pctile_t_wild"
outreg2 using Results/additional_p1.tex, keep($TEST) dec(3) noas addstat (Number of clusters, e(N_clust), "p-value, wild bootstrap", $pctile_t_wild)  ctitle("2") append nocons

// ---------------------------------------------------------------------------//
// 									PANEL (WILD BOOSTRAP)					  //	
// ---------------------------------------------------------------------------//
clear 
use "$DATA"
global CLUSTER= "ctrycluster"					
global NULL="no"
global bootreps = 999 											
global RHS="cd* yr1940- yr1980"
global TEST="logmaddpop"
global INSTRUMENT="compsjmhatit"
global LHS "propconflictCOW2"
global IF year>1930 & year<1990 

clear
runme 0																			
use "$DATA", replace
cap keep if $IF
reg $LHS $RHS $TEST ,  cluster($CLUSTER)
outreg2 $TEST using Results/additional_p2.tex, keep($TEST) dec(3)  tex(frag) noas  addstat (Number of clusters, e(N_clust), "p-value, wild bootstrap", $pctile_t_wild)  /// 
 ctitle("1") replace nocons label
 
clear 
use "$DATA"
clear
runmeIV 0
clear
use "$DATA", replace
keep if $IF
ivreg $LHS $RHS ($TEST=$INSTRUMENT) ,   cluster($CLUSTER)
outreg2 using Results/additional_p2.tex, keep($TEST) dec(3) noas addstat (Number of clusters, e(N_clust), "p-value, wild bootstrap", $pctile_t_wild)  ctitle("2") append nocons

// ---------------------------------------------------------------------------//
// 							LONG DIFFERENCES (GLOBAL MORTAILITY)			  //	
// ---------------------------------------------------------------------------//

xtreg logmaddpop yr1940- yr1980 iindexworldall21000 if newsample40_COW==1 & (year==1940 | year==1980) ,  fe cluster(ctrycluster)
outreg2 using Results/additional_p1.tex, keep(iindexworldall21000) dec(3) noas addstat (Number of clusters, e(N_clust))  ctitle("3") append nocons

xtivreg2 propconflictCOW2 yr1940- yr1980 (logmaddpop=iindexworldall21000) if  newsample40==1 & (year==1940 | year==1980),   fe cluster(ctrycluster)
outreg2 using Results/additional_p1.tex, keep(logmaddpop) dec(3) noas  addstat (Number of clusters, e(N_clust))  ctitle("4") append nocons 

* pval
// ---------------------------------------------------------------------------//
// 								PANEL (GLOBAL MORTAILITY)				      //	
// ---------------------------------------------------------------------------//

xtreg logmaddpop yr1940- yr1980 iindexworldall21000 if year>1930 & year<1990 & propconflictCOW2~=.  ,  fe cluster(ctrycluster)
outreg2 using Results/additional_p2.tex, keep(iindexworldall21000) dec(3) noas addstat (Number of clusters, e(N_clust))  ctitle("3") append nocons

xtivreg2 propconflictCOW2 yr1940- yr1980 (logmaddpop=iindexworldall21000) if  year>1930 & year<1990,   fe cluster(ctrycluster)
outreg2 using Results/additional_p2.tex, keep(logmaddpop) dec(3) noas addstat (Number of clusters, e(N_clust))  ctitle("4") append nocons


cap erase Results/additional_p2.txt
cap erase Results/additional_p1.txt

