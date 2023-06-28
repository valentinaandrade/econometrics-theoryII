////////////////////////////////////////////////////////////////////////////////
/*						MEXICO:	SHARE OF POP & EDUCATION					  */
////////////////////////////////////////////////////////////////////////////////

clear
set more off, permanently

// ---------------------------------------------------------------------------//
// 									APPENDIX								  //	
// ---------------------------------------------------------------------------//
clear
use "$XTMEX"
gen control =.
global geo "yr1960xCapital40 yr1960xCiudad40 yr1960xlandquality40"
global controls "yr1960xCapital40 yr1960xCiudad40 yr1960xlandquality40 yr1960xcorr_logpop40 yr1960xprimary_schooling40 yr1960xuniversity40 yr1960xbattles_centroid40 yr1960xshare_basin40 yr1960xshare_ind40"

cap erase Results/final_share_p1.tex
cap erase Results/final_share_p1.txt
cap erase Results/final_share_p2.tex
cap erase Results/final_share_p2.txt

rename yr1960xadults2_40 yr1960xadults240
rename yr1960xliteracy15to39_40 yr1960xliteracy15to3940


foreach var of varlist adults2 primary_schooling literacy literacy15to39 {
acreg `var' index_mean dummy1-dummy32, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using Results/final_share_p1.tex, keep(index_mean) ctitle("`var'") append nocons label dec(3) noaster

replace control = yr1960x`var'40
acreg totalpcviolencia (corr_logpop=index_mean) dummy1-dummy32 control, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using Results/final_share_p2.tex, keep(corr_logpop control) ctitle("`var'") append nocons label dec(3) noaster

}

foreach var of varlist adults2 primary_schooling literacy literacy15to39 {

acreg `var' index_mean dummy1-dummy32 $controls, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using Results/final_share_p1.tex, keep(index_mean) ctitle("`var'") append nocons label dec(3) noaster

if "`var'"=="primary_schooling"{
global controls "yr1960xCapital40 yr1960xCiudad40 yr1960xlandquality40 yr1960xcorr_logpop40 yr1960xuniversity40 yr1960xbattles_centroid40 yr1960xshare_basin40 yr1960xshare_ind40"
replace control = yr1960x`var'40
acreg totalpcviolencia (corr_logpop=index_mean) dummy1-dummy32 control $controls, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using Results/final_share_p2.tex, keep(corr_logpop control) ctitle("`var'") append nocons label dec(3) noaster
}
else {
global controls "yr1960xCapital40 yr1960xCiudad40 yr1960xlandquality40 yr1960xcorr_logpop40 yr1960xprimary_schooling40 yr1960xuniversity40 yr1960xbattles_centroid40 yr1960xshare_basin40 yr1960xshare_ind40"
replace control = yr1960x`var'40
acreg totalpcviolencia (corr_logpop=index_mean) dummy1-dummy32 control $controls, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using Results/final_share_p2.tex, keep(corr_logpop control) ctitle("`var'") append nocons label dec(3) noaster
}

}

cap erase Results/final_share_p1.txt
cap erase Results/final_share_p2.txt

