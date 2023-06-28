////////////////////////////////////////////////////////////////////////////////
/*							    	TABLE A11								  */
////////////////////////////////////////////////////////////////////////////////

clear
set more off, permanently

// ---------------------------------------------------------------------------//
// 		        		  	Long differences						       	  //	
// ---------------------------------------------------------------------------//

clear
use "$DATA"

cap erase Results/rf3_p1.tex
cap erase Results/rf3_p1.txt

foreach x in yr1980xavcons506070 yr1980xloggdppcmadd30 yr1980xlogmaddpop30 yr1980xshare yr1980xL_PC_DIAMONDS yr1980xoil_gas_rentPOP yr1980xETHPOL yr1980xInitialWar30 yr1980xcen_lat40 yr1980xME50{
xtreg propconflictCOW2 compsjmhatit `x' yr1940- yr1980  if newsample40_COW==1 & (year==1940 | year==1980),  fe cluster(ctrycluster)
test `x'
if `r(p)'<0.01 & `r(p)'!=0{
outreg2 using Results/rf_t3p1.tex, keep(compsjmhatit) tex(frag) dec(3) /*noas*/ addstat(Number of clusters, e(N_clust)) addtext(\parbox{7cm}{p-value for post year dummy x variable indicated at the top of each column},  "<0.01")  ctitle("`x'") nor2 nocon label less(0) append noaster
}
else{
outreg2 using Results/rf_t3p1.tex, keep(compsjmhatit) tex(frag) dec(3) /*noas*/ addstat(Number of clusters, e(N_clust), \parbox{7cm}{p-value for post year dummy x variable indicated at the top of each column},  `r(p)')  ctitle("`x'") nor2 nocon label less(0) append noaster
}
}

cap erase Results/rf_t3p1.txt

// ---------------------------------------------------------------------------//
// 		        		  			Panel							       	  //	
// ---------------------------------------------------------------------------//
cap erase Results/rf_t3p2.tex
cap erase Results/rf_t3p2.txt

foreach x in avcons506070 loggdppcmadd30 logmaddpop30 share L_PC_DIAMONDS oil_gas_rentPOP ETHPOL InitialWar30 cen_lat40 ME50{
xtreg propconflictCOW2 yr1950x`x' yr1960x`x' yr1970x`x' yr1980x`x' yr1940- yr1980 compsjmhatit if year>1930 & year<1990,  fe cluster(ctrycluster)
testparm yr1950x`x' yr1960x`x' yr1970x`x' yr1980x`x'
if `r(p)'<0.01 & `r(p)'!=0{
outreg2 using Results/rf_t3p2.tex, keep(compsjmhatit) tex(frag) dec(3) /*noas*/ addstat(Number of clusters, e(N_clust)) addtext(\parbox{7cm}{p-value for post year dummy x variable indicated at the top of each column},  "<0.01")  ctitle("`x'") nor2 nocon label less(0) append noaster
}
else{
outreg2 using Results/rf_t3p2.tex, keep(compsjmhatit) tex(frag) dec(3) /*noas*/ addstat(Number of clusters, e(N_clust), \parbox{7cm}{p-value for post year dummy x variable indicated at the top of each column},  `r(p)')  ctitle("`x'") nor2 nocon label less(0) append noaster
}
}

cap erase Results/rf_t3p2.txt
