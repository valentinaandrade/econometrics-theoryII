////////////////////////////////////////////////////////////////////////////////
/*							    	TABLE A16								  */
////////////////////////////////////////////////////////////////////////////////

clear
set more off, permanently

// ---------------------------------------------------------------------------//
// 							Long Differences & Panel						  //	
// ---------------------------------------------------------------------------//

clear 
use "$DATA"

global yr1940 "yr1940xcholera yr1940xtyphus yr1940xplague yr1940xmalaria yr1940xwcough yr1940xscarfever yr1940xdiptheria yr1940xmeasles yr1940xpneumonia yr1940xinfluenza yr1940xtyphoid yr1940xtball yr1940xsmallpox yr1940xyellowfever"
global yr1950 "yr1950xcholera yr1950xtyphus yr1950xplague yr1950xmalaria yr1950xwcough yr1950xscarfever yr1950xdiptheria yr1950xmeasles yr1950xpneumonia yr1950xinfluenza yr1950xtyphoid yr1950xtball yr1950xsmallpox yr1950xyellowfever"
global yr1960 "yr1960xcholera yr1960xtyphus yr1960xplague yr1960xmalaria yr1960xwcough yr1960xscarfever yr1960xdiptheria yr1960xmeasles yr1960xpneumonia yr1960xinfluenza yr1960xtyphoid yr1960xtball yr1960xsmallpox yr1960xyellowfever"
global yr1970 "yr1970xcholera yr1970xtyphus yr1970xplague yr1970xmalaria yr1970xwcough yr1970xscarfever yr1970xdiptheria yr1970xmeasles yr1970xpneumonia yr1970xinfluenza yr1970xtyphoid yr1970xtball yr1970xsmallpox yr1970xyellowfever"
global yr1980 "yr1980xcholera yr1980xtyphus yr1980xplague yr1980xmalaria yr1980xwcough yr1980xscarfever yr1980xdiptheria yr1980xmeasles yr1980xpneumonia yr1980xinfluenza yr1980xtyphoid yr1980xtball yr1980xsmallpox yr1980xyellowfever"

cap erase Results/bartik_t2p1.tex
cap erase Results/bartik_t2p1.txt
cap erase Results/bartik_t2p2.tex
cap erase Results/bartik_t2p2.txt

gen x=.
label var x "\parbox{3cm}{\centering Variable shown in each column title}"
foreach x of varlist predicted_mortality predicted_pneumonia predicted_malaria predicted_tball predicted_3 only_pneumonia only_malaria only_tball{
replace x= `x'
xtreg logmaddpop yr1940- yr1980 x if newsample40_COW==1 & (year==1940 | year==1980) ,  fe cluster(ctrycluster)
outreg2 using Results/bartik_t2p1.tex, keep(x) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust))   ctitle("x") append nocons label noaster

xtreg logmaddpop yr1940- yr1980 x if year>1930 & year<1990 & propconflictCOW2~=.  ,  fe cluster(ctrycluster)
outreg2 using Results/bartik_t2p2.tex, keep(x) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust))   ctitle("x") append nocons label noaster
}

cap erase Results/bartik_t2p1.txt
cap erase Results/bartik_t2p2.txt
