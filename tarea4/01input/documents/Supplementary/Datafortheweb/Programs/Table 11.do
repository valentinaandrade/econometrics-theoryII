////////////////////////////////////////////////////////////////////////////////
/*						MEXICO:	OLS & 2SLS ESTIMATES						  */
////////////////////////////////////////////////////////////////////////////////

clear
set more off, permanently

// ---------------------------------------------------------------------------//
// 										2SLS								  //	
// ---------------------------------------------------------------------------//
clear
use "$XTMEX"
global geo "yr1960xCapital40 yr1960xCiudad40 yr1960xlandquality40"
global controls "yr1960xCapital40 yr1960xCiudad40 yr1960xlandquality40 yr1960xcorr_logpop40 yr1960xprimary_schooling40 yr1960xuniversity40 yr1960xbattles_centroid40 yr1960xshare_basin40 yr1960xshare_ind40"

acreg totalpcviolencia (corr_logpop=index_mean) dummy1-dummy32, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using Results/TSLS.tex, keep(corr_logpop) ctitle("1") replace nocons label dec(3) noaster
xtivreg2 totalpcviolencia (corr_logpop=index_mean) dummy1-dummy32, fe first
gen sample1 = e(sample) 

acreg totalpcviolencia (corr_logpop=index_mean) dummy1-dummy32 $geo, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using Results/TSLS.tex, keep(corr_logpop) ctitle("2") append nocons label dec(3) noaster
xtivreg2 totalpcviolencia (corr_logpop=index_mean) dummy1-dummy32 $geo, fe
gen sample2 = e(sample)

acreg totalpcviolencia (corr_logpop=index_mean) dummy1-dummy32 $geo yr1960xcorr_logpop40, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using Results/TSLS.tex, keep(corr_logpop yr1960xcorr_logpop40) ctitle("3") append nocons label dec(3) noaster
xtivreg2 totalpcviolencia (corr_logpop=index_mean) dummy1-dummy32 $geo yr1960xcorr_logpop40, fe
gen sample3 = e(sample)

acreg totalpcviolencia (corr_logpop=index_mean) dummy1-dummy32 $geo yr1960xprimary_schooling40, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using Results/TSLS.tex, keep(corr_logpop yr1960xprimary_schooling40) ctitle("4") append nocons label dec(3) noaster
xtivreg2 totalpcviolencia (corr_logpop=index_mean) dummy1-dummy32 $geo yr1960xprimary_schooling40, fe
gen sample4 = e(sample)

acreg totalpcviolencia (corr_logpop=index_mean) dummy1-dummy32 $geo yr1960xuniversity40, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using Results/TSLS.tex, keep(corr_logpop yr1960xuniversity40) ctitle("5") append nocons label dec(3) noaster
xtivreg2 totalpcviolencia (corr_logpop=index_mean) dummy1-dummy32 $geo yr1960xuniversity40, fe
gen sample5 = e(sample)

acreg totalpcviolencia (corr_logpop=index_mean) dummy1-dummy32 $geo yr1960xbattles_centroid40, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using Results/TSLS.tex, keep(corr_logpop yr1960xbattles_centroid40) ctitle("6") append nocons label dec(3) noaster
xtivreg2 totalpcviolencia (corr_logpop=index_mean) dummy1-dummy32 $geo yr1960xbattles_centroid40, fe
gen sample6 = e(sample)

acreg totalpcviolencia (corr_logpop=index_mean) dummy1-dummy32 $geo yr1960xshare_basin40, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using Results/TSLS.tex, keep(corr_logpop yr1960xshare_basin40) ctitle("7") append nocons label dec(3) noaster
xtivreg2 totalpcviolencia (corr_logpop=index_mean) dummy1-dummy32 $geo yr1960xshare_basin40, fe
gen sample7 = e(sample)

acreg totalpcviolencia (corr_logpop=index_mean) dummy1-dummy32 $geo yr1960xshare_ind40, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using Results/TSLS.tex, keep(corr_logpop yr1960xshare_ind40) ctitle("8") append nocons label dec(3) noaster
xtivreg2 totalpcviolencia (corr_logpop=index_mean) dummy1-dummy32 $geo yr1960xshare_ind40, fe
gen sample8 = e(sample)

acreg totalpcviolencia (corr_logpop=index_mean) dummy1-dummy32 $controls, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using Results/TSLS.tex, keep(corr_logpop yr1960xcorr_logpop40 yr1960xprimary_schooling40 yr1960xuniversity40 yr1960xbattles_centroid40 yr1960xshare_basin40 yr1960xshare_ind40) ctitle("8") append nocons label dec(3) noaster
xtivreg2 totalpcviolencia (corr_logpop=index_mean) dummy1-dummy32 $geo yr1960xshare_ind40, fe
gen sample9 = e(sample)

// ---------------------------------------------------------------------------//
// 										FS									  //	
// ---------------------------------------------------------------------------//
preserve
keep if sample1==1
acreg corr_logpop index_mean dummy1-dummy32, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using Results/FS.tex, keep(index_mean) ctitle("1") replace nocons label dec(3) noaster
restore

preserve
keep if sample2==1
acreg corr_logpop index_mean dummy1-dummy32 $geo, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using Results/FS.tex, keep(index_mean) ctitle("2") append nocons label dec(3) noaster
restore

preserve
keep if sample3==1
acreg corr_logpop index_mean dummy1-dummy32 $geo yr1960xcorr_logpop40, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using Results/FS.tex, keep(index_mean) ctitle("3") append nocons label dec(3) noaster
restore

preserve
keep if sample4==1
acreg corr_logpop index_mean dummy1-dummy32 $geo yr1960xprimary_schooling40, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using Results/FS.tex, keep(index_mean) ctitle("4") append nocons label dec(3) noaster
restore

preserve
keep if sample5==1
acreg corr_logpop index_mean dummy1-dummy32 $geo yr1960xuniversity40, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using Results/FS.tex, keep(index_mean) ctitle("5") append nocons label dec(3) noaster
restore

preserve
keep if sample6==1
acreg corr_logpop index_mean dummy1-dummy32 $geo yr1960xbattles_centroid40, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using Results/FS.tex, keep(index_mean) ctitle("6") append nocons label dec(3) noaster
restore

preserve
keep if sample7==1
acreg corr_logpop index_mean dummy1-dummy32 $geo yr1960xshare_basin40, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using Results/FS.tex, keep(index_mean) ctitle("7") append nocons label dec(3) noaster
restore

preserve
keep if sample8==1
acreg corr_logpop index_mean dummy1-dummy32 $geo yr1960xshare_ind40, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using Results/FS.tex, keep(index_mean) ctitle("8") append nocons label dec(3) noaster
restore

preserve
keep if sample9==1
acreg corr_logpop index_mean dummy1-dummy32 $controls, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using Results/FS.tex, keep(index_mean) ctitle("9") append nocons label dec(3) noaster
restore


// ---------------------------------------------------------------------------//
// 										OLS									  //	
// ---------------------------------------------------------------------------//
preserve
keep if sample1==1
acreg totalpcviolencia corr_logpop dummy1-dummy32, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using Results/OLS.tex, keep(corr_logpop) ctitle("1") replace nocons label dec(3) noaster
restore

preserve
keep if sample2==1
acreg totalpcviolencia corr_logpop dummy1-dummy32 $geo, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using Results/OLS.tex, keep(corr_logpop) ctitle("2") append nocons label dec(3) noaster
restore

preserve
keep if sample3==1
acreg totalpcviolencia corr_logpop dummy1-dummy32 $geo yr1960xcorr_logpop40, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using Results/OLS.tex, keep(corr_logpop) ctitle("3") append nocons label dec(3) noaster
restore

preserve
keep if sample4==1
acreg totalpcviolencia corr_logpop dummy1-dummy32 $geo yr1960xprimary_schooling40, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using Results/OLS.tex, keep(corr_logpop) ctitle("4") append nocons label dec(3) noaster
restore

preserve
keep if sample5==1
acreg totalpcviolencia corr_logpop dummy1-dummy32 $geo yr1960xuniversity40, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using Results/OLS.tex, keep(corr_logpop) ctitle("5") append nocons label dec(3) noaster
restore

preserve
keep if sample6==1
acreg totalpcviolencia corr_logpop dummy1-dummy32 $geo yr1960xbattles_centroid40, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using Results/OLS.tex, keep(corr_logpop) ctitle("6") append nocons label dec(3) noaster
restore

preserve
keep if sample7==1
acreg totalpcviolencia corr_logpop dummy1-dummy32 $geo yr1960xshare_basin40, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using Results/OLS.tex, keep(corr_logpop) ctitle("7") append nocons label dec(3) noaster
restore

preserve
keep if sample8==1
acreg totalpcviolencia corr_logpop dummy1-dummy32 $geo yr1960xshare_ind40, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using Results/OLS.tex, keep(corr_logpop) ctitle("8") append nocons label dec(3) noaster
restore

preserve
keep if sample9==1
acreg totalpcviolencia corr_logpop dummy1-dummy32 $controls, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using Results/OLS.tex, keep(corr_logpop) ctitle("9") append nocons label dec(3) noaster
restore

cap erase "Results/OLS.txt"
cap erase "Results/TSLS.txt"
cap erase "Results/FS.txt"

