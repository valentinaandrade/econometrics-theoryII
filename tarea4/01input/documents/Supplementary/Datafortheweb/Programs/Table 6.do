////////////////////////////////////////////////////////////////////////////////
/*									TABLE 6								  */
////////////////////////////////////////////////////////////////////////////////

clear
set more off, permanently

// ---------------------------------------------------------------------------//
// 		        		  	Long differences (2SLS)					       	  //	
// ---------------------------------------------------------------------------//

clear
use "$DATA"

cap erase Results/iv_t3p1.tex
cap erase Results/iv_t3p1.txt

foreach x in yr1980xavcons506070 yr1980xloggdppcmadd30 yr1980xlogmaddpop30 yr1980xshare yr1980xL_PC_DIAMONDS yr1980xoil_gas_rentPOP yr1980xETHPOL yr1980xInitialWar30 yr1980xcen_lat40 yr1980xME50{
xtivreg2  propconflictCOW2 (logmaddpop=compsjmhatit) `x'   yr1940- yr1980 if newsample40_COW==1 & (year==1940 | year==1980) ,    fe cluster(ctrycluster)
test `x'
if `r(p)'<0.01 & `r(p)'!=0{
outreg2 using Results/iv_t3p1.tex, keep(logmaddpop) tex(frag) dec(3) /*noas*/ addstat(Number of clusters, e(N_clust)) addtext(\parbox{7cm}{p-value for post year dummy x variable indicated at the top of each column},  "<0.01")   ctitle("`x'") nor2 nocon label less(0) append noaster
}
else{
outreg2 using Results/iv_t3p1.tex, keep(logmaddpop) tex(frag) dec(3) /*noas*/ addstat(Number of clusters, e(N_clust), \parbox{7cm}{p-value for post year dummy x variable indicated at the top of each column},  `r(p)')  ctitle("`x'") nor2 nocon label less(0) append noaster
}
}

cap erase Results/iv_t3p1.txt

// ---------------------------------------------------------------------------//
// 		        		  	Long differences (First Stage)			       	  //	
// ---------------------------------------------------------------------------//

clear
use "$DATA"

cap erase Results/fs_t2p1.tex
cap erase Results/fs_t2p1.txt

foreach x in yr1980xavcons506070 yr1980xloggdppcmadd30 yr1980xlogmaddpop30 yr1980xshare yr1980xL_PC_DIAMONDS yr1980xoil_gas_rentPOP yr1980xETHPOL yr1980xInitialWar30 yr1980xcen_lat40 yr1980xME50{
xtreg logmaddpop `x' yr1940- yr1980 compsjmhatit if newsample40_COW==1 & (year==1940 | year==1980),  fe cluster(ctrycluster)
test `x'
if `r(p)'<0.01 & `r(p)'!=0{
outreg2 using Results/fs_t2p1.tex, keep(compsjmhatit) tex(frag) dec(3) /*noas*/  addstat( Number of clusters, e(N_clust)) addtext( \parbox{7cm}{p-value for post year dummy x variable indicated at the top of each column},   "<0.01") ctitle("2")  nocon label append noaster
}
else {
outreg2 using Results/fs_t2p1.tex, keep(compsjmhatit) tex(frag) dec(3) /*noas*/  addstat( Number of clusters, e(N_clust), \parbox{7cm}{p-value for post year dummy x variable indicated at the top of each column},  `r(p)') ctitle("2")  nocon label append noaster
}
}

cap erase Results/fs_t2p1.txt

// ---------------------------------------------------------------------------//
// 		        		  			Panel (2SLS)					       	  //	
// ---------------------------------------------------------------------------//
clear
use "$DATA"

cap erase Results/iv_t3p2.tex
cap erase Results/iv_t3p2.txt
global poor "yr1950xpoor40 yr1960xpoor40 yr1970xpoor40 yr1980xpoor40"
global middle "yr1950xmiddle40 yr1960xmiddle40 yr1970xmiddle40 yr1980xmiddle40"
global rich "yr1950xrich40 yr1960xrich40 yr1970xrich40 yr1980xrich40"

foreach x in avcons506070 loggdppcmadd30 logmaddpop30 share L_PC_DIAMONDS oil_gas_rentPOP ETHPOL InitialWar30 cen_lat40 ME50{
xtivreg2  propconflictCOW2 (logmaddpop=compsjmhatit) yr1950x`x' yr1960x`x' yr1970x`x' yr1980x`x'   yr1940- yr1980 if year>1930 & year<1990 ,    fe cluster(ctrycluster)
test yr1950x`x' yr1960x`x' yr1970x`x' yr1980x`x'
if `r(p)'<0.01 & `r(p)'!=0{
outreg2 using Results/iv_t3p2.tex, keep(logmaddpop) tex(frag) dec(3) /*noas*/ addstat(Number of clusters, e(N_clust)) addtext(\parbox{7cm}{p-value for post year dummy x variable indicated at the top of each column},  "<0.01")  ctitle("`x'") nor2 nocon label less(0) append noaster
}
else{
outreg2 using Results/iv_t3p2.tex, keep(logmaddpop) tex(frag) dec(3) /*noas*/ addstat(Number of clusters, e(N_clust), \parbox{7cm}{p-value for post year dummy x variable indicated at the top of each column},  `r(p)')  ctitle("`x'") nor2 nocon label less(0) append noaster
}
}

cap erase Results/iv_t3p2.txt

// ---------------------------------------------------------------------------//
// 		        		  			Panel (First Stage)				    	  //	
// ---------------------------------------------------------------------------//

clear
use "$DATA"

cap erase Results/fs_t2p2.tex
cap erase Results/fs_t2p2.txt

foreach x in avcons506070 loggdppcmadd30 logmaddpop30 share L_PC_DIAMONDS oil_gas_rentPOP ETHPOL  InitialWar30 cen_lat40 ME50{
xtreg logmaddpop yr1950x`x' yr1960x`x' yr1970x`x' yr1980x`x' yr1940- yr1980 compsjmhatit if year>1930 & year<1990 & propconflictCOW2~=. ,  fe cluster(ctrycluster)
testparm yr1950x`x' yr1960x`x' yr1970x`x' yr1980x`x'
if `r(p)'<0.01 & `r(p)'!=0{
outreg2 using Results/fs_t2p2.tex, keep(compsjmhatit) tex(frag) dec(3) /*noas*/  addstat( Number of clusters, e(N_clust)) addtext(\parbox{7cm}{p-value for post year dummy x variable indicated at the top of each column},  "<0.01") ctitle("`x'")  nocon label append noaster
}
else {
outreg2 using Results/fs_t2p2.tex, keep(compsjmhatit) tex(frag) dec(3) /*noas*/  addstat( Number of clusters, e(N_clust), \parbox{7cm}{p-value for post year dummy x variable indicated at the top of each column},  `r(p)') ctitle("`x'")  nocon label append noaster
}
}

cap erase Results/fs_t2p2.txt

