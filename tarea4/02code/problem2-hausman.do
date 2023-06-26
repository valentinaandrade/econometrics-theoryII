* ------------------------------------------------------------------------------
*                                 Table 4	  	
* ------------------------------------------------------------------------------

use "$src/data with conflict.dta",clear

xtivreg2 propconflictCOW2 yr1940- yr1980 (logmaddpop=compsjmhatit) if newsample40_COW==1 & (year==1940 | year==1980) ,   fe 
est store propconflictCOW2_iv
outreg2 using "$output/table4.tex", keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust))   ctitle("propconflictCOW2") replace nocons label noaster

reg propconflictCOW2 yr1940- yr1980 logmaddpop if newsample40_COW==1 & (year==1940 | year==1980)
est store propconflictCOW2_ols

hausman propconflictCOW2_iv propconflictCOW2_ols


// ---------------------------------------------------------------------------//
// 		        		  			Panel A						       	  //	
// ---------------------------------------------------------------------------//


foreach x of varlist propconflictU propconflictFL logdeathpop40U {
 qui: xtivreg2 `x' yr1940- yr1980 (logmaddpop=compsjmhatit) if  newsample40==1 & (year==1940 | year==1980),   fe 
est store `x'_iv

qui:  reg `x' yr1940-yr1980 logmaddpop if  newsample40==1 & (year==1940 | year==1980)

est store `x'_ols

hausman `x'_iv `x'_ols

}


// ---------------------------------------------------------------------------//
// 		        		  			Panel B						       	  //	
// ---------------------------------------------------------------------------//



foreach x of varlist propconflictCOW2 propconflictU propconflictFL  logdeathpop40U {
qui: xtivreg2 `x' yr1940- yr1980 (logmaddpop=compsjmhatit) if  year>1930 & year<1990, fe  
est store `x'_iv

qui: reg `x' yr1940- yr1980 logmaddpop if  year>1930 & year<1990
est store `x'_ols
hausman `x'_iv `x'_ols
}

