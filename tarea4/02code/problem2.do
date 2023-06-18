* ------------------------------------------------------------------------------
* AUTHOR: Valentina Andrade
* CREATION: May-2022
* ACTION: Problem set 4 - Problem 2
* ------------------------------------------------------------------------------

set more off 
clear all
eststo clear
* ------------------------------------------------------------------------------
* SET PATH AND LOCALS
* ------------------------------------------------------------------------------

if c(username)=="valentinaandrade" global github"/Users/valentinaandrade/Documents/GitHub/me/econometrics-theoryII/tarea4"

global src 	    "$github/01input/src"
global tmp  	"$github/01input/tmp"
global output   "$github/03output"

* ------------------------------------------------------------------------------
**# packages
* ------------------------------------------------------------------------------

ssc install ivreg2
ssc install ranktest 
ssc install acreg
net install tmpdir.pkg


* ------------------------------------------------------------------------------
**# use data
* ------------------------------------------------------------------------------

use "$src/data1940", clear

* ------------------------------------------------------------------------------
**# Table3
* ------------------------------------------------------------------------------


replace newbasesample=0 if country=="AUSTRIA" | country=="BANGLADESH" | country=="MALAYSIA" | country=="RUSSIAN FEDERATION" // Same sample as the second stage in the long differences. 
reg changelogpopulation changemortality if newbasesample==1  ,  cluster(ctrycluster)
outreg2 using "$output/falsification.tex", dec(3) /*noas*/   nocon label less(0) ct(1) replace noaster
reg changelogpopulation changemortality if newbasesample==1 & startrich~=1 ,  cluster(ctrycluster)
outreg2 using "$output/falsification.tex", dec(3) /*noas*/   nocon label less(0) ct(2) append noaster

* ------------------------------------------------------------------------------
**#		        		  		Reduced Form						       	  	
* ------------------------------------------------------------------------------

use "$src/data1940", clear

reg changepconflictCOW2 changemortality if newbasesample==1  ,  cluster(ctrycluster)
outreg2 using "$output/falsification.tex", dec(3) /*noas*/   nocon label less(0) ct(3) append noaster
reg changepconflictCOW2 changemortality if newbasesample==1 & startrich~=1 ,  cluster(ctrycluster)
outreg2 using "$output/falsification.tex", dec(3) /*noas*/   nocon label less(0) ct(4) append noaster

* ------------------------------------------------------------------------------
**#		        		  		Falsification						       	  	
* ------------------------------------------------------------------------------

reg changepconflictCOW2_1900_40 changemortality if newbasesample==1 ,   cluster(ctrycluster)
outreg2 using "$output/falsification.tex", dec(3) /*noas*/   nocon label less(0) ct(5) append noaster
reg changepconflictCOW2_1900_40 changemortality if  newbasesample==1 & startrich~=1 ,   cluster(ctrycluster)
outreg2 using "$output/falsification.tex", dec(3) /*noas*/   nocon label less(0) ct(6) append noaster
reg changelogpopulation_1900_40 changemortality if newbasesample==1 ,   cluster(ctrycluster)
outreg2 using "$output/falsification.tex", dec(3) /*noas*/   nocon label less(0) ct(7) append noaster
reg changelogpopulation_1900_40 changemortality if  newbasesample==1 & startrich~=1 ,   cluster(ctrycluster)
outreg2 using "$output/falsification.tex", dec(3) /*noas*/   nocon label less(0) ct(8) append noaster

cap erase "$output/falsification.tex"


* ------------------------------------------------------------------------------
*                                 Table 4	  	
* ------------------------------------------------------------------------------

use "$src/data with conflict.dta",clear

xtivreg2 propconflictCOW2 yr1940- yr1980 (logmaddpop=compsjmhatit) if newsample40_COW==1 & (year==1940 | year==1980) ,   fe cluster(ctrycluster)
outreg2 using "$output/table4.tex", keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust))   ctitle("propconflictCOW2") replace nocons label noaster

foreach x of varlist propconflictU propconflictFL logdeathpop40U {
xtivreg2 `x' yr1940- yr1980 (logmaddpop=compsjmhatit) if  newsample40==1 & (year==1940 | year==1980),   fe cluster(ctrycluster)
outreg2 using "$output/table4.tex", keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust))   ctitle("`x'") append nocons label noaster

}

cap erase "$output/table4.tex"

// ---------------------------------------------------------------------------//
// 		        		  			Panel	 B						       	  //	
// ---------------------------------------------------------------------------//



foreach x of varlist propconflictCOW2 propconflictU propconflictFL  logdeathpop40U {
xtivreg2 `x' yr1940- yr1980 (logmaddpop=compsjmhatit) if  year>1930 & year<1990,   fe cluster(ctrycluster)
outreg2 using "$output/table42.tex", keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust))   ctitle("`x'") append nocons label noaster
}

cap erase "$output/table42.tex"

* ------------------------------------------------------------------------------
*                                 Table 11  	
* ------------------------------------------------------------------------------
use "$src/XTMexico.dta",clear

global geo "yr1960xCapital40 yr1960xCiudad40 yr1960xlandquality40"
global controls "yr1960xCapital40 yr1960xCiudad40 yr1960xlandquality40 yr1960xcorr_logpop40 yr1960xprimary_schooling40 yr1960xuniversity40 yr1960xbattles_centroid40 yr1960xshare_basin40 yr1960xshare_ind40"


// ---------------------------------------------------------------------------//
// 										2SLS								  //
// ---------------------------------------------------------------------------//

acreg totalpcviolencia (corr_logpop=index_mean) dummy1-dummy32, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster)
outreg2 using "$output/TSLS.tex", keep(corr_logpop) ctitle("1") replace nocons label dec(3) noaster
xtivreg2 totalpcviolencia (corr_logpop=index_mean) dummy1-dummy32, fe first
gen sample1 = e(sample) 

acreg totalpcviolencia (corr_logpop=index_mean) dummy1-dummy32 $geo, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using "$output/TSLS.tex", keep(corr_logpop) ctitle("2") append nocons label dec(3) noaster
xtivreg2 totalpcviolencia (corr_logpop=index_mean) dummy1-dummy32 $geo, fe
gen sample2 = e(sample)

acreg totalpcviolencia (corr_logpop=index_mean) dummy1-dummy32 $geo yr1960xcorr_logpop40, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using "$output/TSLS.tex", keep(corr_logpop yr1960xcorr_logpop40) ctitle("3") append nocons label dec(3) noaster
xtivreg2 totalpcviolencia (corr_logpop=index_mean) dummy1-dummy32 $geo yr1960xcorr_logpop40, fe
gen sample3 = e(sample)

acreg totalpcviolencia (corr_logpop=index_mean) dummy1-dummy32 $geo yr1960xprimary_schooling40, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using "$output/TSLS.tex", keep(corr_logpop yr1960xprimary_schooling40) ctitle("4") append nocons label dec(3) noaster
xtivreg2 totalpcviolencia (corr_logpop=index_mean) dummy1-dummy32 $geo yr1960xprimary_schooling40, fe
gen sample4 = e(sample)

acreg totalpcviolencia (corr_logpop=index_mean) dummy1-dummy32 $geo yr1960xuniversity40, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using "$output/TSLS.tex", keep(corr_logpop yr1960xuniversity40) ctitle("5") append nocons label dec(3) noaster
xtivreg2 totalpcviolencia (corr_logpop=index_mean) dummy1-dummy32 $geo yr1960xuniversity40, fe
gen sample5 = e(sample)

acreg totalpcviolencia (corr_logpop=index_mean) dummy1-dummy32 $geo yr1960xbattles_centroid40, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using "$output/TSLS.tex", keep(corr_logpop yr1960xbattles_centroid40) ctitle("6") append nocons label dec(3) noaster
xtivreg2 totalpcviolencia (corr_logpop=index_mean) dummy1-dummy32 $geo yr1960xbattles_centroid40, fe
gen sample6 = e(sample)

acreg totalpcviolencia (corr_logpop=index_mean) dummy1-dummy32 $geo yr1960xshare_basin40, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using "$output/TSLS.tex", keep(corr_logpop yr1960xshare_basin40) ctitle("7") append nocons label dec(3) noaster
xtivreg2 totalpcviolencia (corr_logpop=index_mean) dummy1-dummy32 $geo yr1960xshare_basin40, fe
gen sample7 = e(sample)

acreg totalpcviolencia (corr_logpop=index_mean) dummy1-dummy32 $geo yr1960xshare_ind40, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using "$output/TSLS.tex", keep(corr_logpop yr1960xshare_ind40) ctitle("8") append nocons label dec(3) noaster
xtivreg2 totalpcviolencia (corr_logpop=index_mean) dummy1-dummy32 $geo yr1960xshare_ind40, fe
gen sample8 = e(sample)

acreg totalpcviolencia (corr_logpop=index_mean) dummy1-dummy32 $controls, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using "$output/TSLS.tex", keep(corr_logpop yr1960xcorr_logpop40 yr1960xprimary_schooling40 yr1960xuniversity40 yr1960xbattles_centroid40 yr1960xshare_basin40 yr1960xshare_ind40) ctitle("8") append nocons label dec(3) noaster
xtivreg2 totalpcviolencia (corr_logpop=index_mean) dummy1-dummy32 $geo yr1960xshare_ind40, fe
gen sample9 = e(sample)

// ---------------------------------------------------------------------------//
// 										FS									  //	
// ---------------------------------------------------------------------------//
preserve
keep if sample1==1
acreg corr_logpop index_mean dummy1-dummy32, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using "$output/FS.tex", keep(index_mean) ctitle("1") replace nocons label dec(3) noaster
restore

preserve
keep if sample2==1
acreg corr_logpop index_mean dummy1-dummy32 $geo, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using "$output/FS.tex", keep(index_mean) ctitle("2") append nocons label dec(3) noaster
restore

preserve
keep if sample3==1
acreg corr_logpop index_mean dummy1-dummy32 $geo yr1960xcorr_logpop40, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using "$output/FS.tex", keep(index_mean) ctitle("3") append nocons label dec(3) noaster
restore

preserve
keep if sample4==1
acreg corr_logpop index_mean dummy1-dummy32 $geo yr1960xprimary_schooling40, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using "$output/FS.tex", keep(index_mean) ctitle("4") append nocons label dec(3) noaster
restore

preserve
keep if sample5==1
acreg corr_logpop index_mean dummy1-dummy32 $geo yr1960xuniversity40, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using "$output/FS.tex", keep(index_mean) ctitle("5") append nocons label dec(3) noaster
restore

preserve
keep if sample6==1
acreg corr_logpop index_mean dummy1-dummy32 $geo yr1960xbattles_centroid40, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using "$output/FS.tex", keep(index_mean) ctitle("6") append nocons label dec(3) noaster
restore

preserve
keep if sample7==1
acreg corr_logpop index_mean dummy1-dummy32 $geo yr1960xshare_basin40, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using "$output/FS.tex", keep(index_mean) ctitle("7") append nocons label dec(3) noaster
restore

preserve
keep if sample8==1
acreg corr_logpop index_mean dummy1-dummy32 $geo yr1960xshare_ind40, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using "$output/FS.tex", keep(index_mean) ctitle("8") append nocons label dec(3) noaster
restore

preserve
keep if sample9==1
acreg corr_logpop index_mean dummy1-dummy32 $controls, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using "$output/FS.tex", keep(index_mean) ctitle("9") append nocons label dec(3) noaster
restore


// ---------------------------------------------------------------------------//
// 										OLS									  //	
// ---------------------------------------------------------------------------//
preserve
keep if sample1==1
acreg totalpcviolencia corr_logpop dummy1-dummy32, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using "$output/OLS.tex", keep(corr_logpop) ctitle("1") replace nocons label dec(3) noaster
restore

preserve
keep if sample2==1
acreg totalpcviolencia corr_logpop dummy1-dummy32 $geo, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using "$output/OLS.tex", keep(corr_logpop) ctitle("2") append nocons label dec(3) noaster
restore

preserve
keep if sample3==1
acreg totalpcviolencia corr_logpop dummy1-dummy32 $geo yr1960xcorr_logpop40, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using "$output/OLS.tex", keep(corr_logpop) ctitle("3") append nocons label dec(3) noaster
restore

preserve
keep if sample4==1
acreg totalpcviolencia corr_logpop dummy1-dummy32 $geo yr1960xprimary_schooling40, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using "$output/OLS.tex", keep(corr_logpop) ctitle("4") append nocons label dec(3) noaster
restore

preserve
keep if sample5==1
acreg totalpcviolencia corr_logpop dummy1-dummy32 $geo yr1960xuniversity40, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using "$output/OLS.tex", keep(corr_logpop) ctitle("5") append nocons label dec(3) noaster
restore

preserve
keep if sample6==1
acreg totalpcviolencia corr_logpop dummy1-dummy32 $geo yr1960xbattles_centroid40, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using "$output/OLS.tex", keep(corr_logpop) ctitle("6") append nocons label dec(3) noaster
restore

preserve
keep if sample7==1
acreg totalpcviolencia corr_logpop dummy1-dummy32 $geo yr1960xshare_basin40, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using "$output/OLS.tex", keep(corr_logpop) ctitle("7") append nocons label dec(3) noaster
restore

preserve
keep if sample8==1
acreg totalpcviolencia corr_logpop dummy1-dummy32 $geo yr1960xshare_ind40, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using "$output/OLS.tex", keep(corr_logpop) ctitle("8") append nocons label dec(3) noaster
restore

preserve
keep if sample9==1
acreg totalpcviolencia corr_logpop dummy1-dummy32 $controls, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using "$output/OLS.tex", keep(corr_logpop) ctitle("9") append nocons label dec(3) noaster
restore
