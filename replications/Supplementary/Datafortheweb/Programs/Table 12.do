////////////////////////////////////////////////////////////////////////////////
/*						MEXICO:	HETEROGENEOUS EFFECTS						  */
////////////////////////////////////////////////////////////////////////////////

clear
set more off, permanently

// ---------------------------------------------------------------------------//
// 								OTHER OUTCOMES - MAIN						  //	
// ---------------------------------------------------------------------------//

clear
use "$XTMEX"
global geo "yr1960xCapital40 yr1960xCiudad40 yr1960xlandquality40"
global controls "yr1960xCapital40 yr1960xCiudad40 yr1960xlandquality40 yr1960xcorr_logpop40 yr1960xprimary_schooling40 yr1960xuniversity40 yr1960xbattles_centroid40 yr1960xshare_basin40 yr1960xshare_ind40"

acreg nr_pc (corr_logpop=index_mean) dummy1-dummy32, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using Results/TSLS_2.tex, keep(corr_logpop) ctitle("1") replace nocons label dec(3) noaster
xtivreg2 nr_pc (corr_logpop=index_mean) dummy1-dummy32, fe first
gen sample1 = e(sample) 

acreg nr_pc (corr_logpop=index_mean) dummy1-dummy32 $controls, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using Results/TSLS_2.tex, keep(corr_logpop) ctitle("2") append nocons label dec(3) noaster
xtivreg2 nr_pc (corr_logpop=index_mean) dummy1-dummy32 $controls, fe first
gen sample2 = e(sample) 

acreg notnr_pc  (corr_logpop=index_mean) dummy1-dummy32, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using Results/TSLS_2.tex, keep(corr_logpop) ctitle("3") append nocons label dec(3) noaster

acreg notnr_pc (corr_logpop=index_mean) dummy1-dummy32 $controls, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using Results/TSLS_2.tex, keep(corr_logpop) ctitle("4") append nocons label dec(3) noaster

acreg totalpcnoviolenta  (corr_logpop=index_mean) dummy1-dummy32, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using Results/TSLS_2.tex, keep(corr_logpop) ctitle("5") append nocons label dec(3) noaster

acreg totalpcnoviolenta (corr_logpop=index_mean) dummy1-dummy32 $controls, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using Results/TSLS_2.tex, keep(corr_logpop) ctitle("6") append nocons label dec(3) noaster

tempfile junk
save `junk', replace 

// ---------------------------------------------------------------------------//
// 									HE	- MAIN								  //	
// ---------------------------------------------------------------------------//

clear
use "$XTMEX"
global geo "yr1960xCapital40 yr1960xCiudad40 yr1960xlandquality40"
global controls "yr1960xCapital40 yr1960xCiudad40 yr1960xlandquality40 yr1960xcorr_logpop40 yr1960xprimary_schooling40 yr1960xuniversity40 yr1960xbattles_centroid40 yr1960xshare_basin40 yr1960xshare_ind40"

generate HE1 =.
generate HE2 =.
label var HE1 "log pop $\times$ Non-harvest"
label var HE2 "log pop $\times$ Harvest"

/*------------- NO CONTROLS -------------*/
gen endo1 = corr_logpop*drought_nonharvest5 
gen endo2 = corr_logpop*drought_harvest5
gen exo1 = index_mean*drought_nonharvest5
gen exo2 = index_mean*drought_harvest5 

xtivreg2 totalpcviolencia dummy1-dummy32 (corr_logpop endo1 endo2 = ///
	index_mean exo1 exo2), fe
g sample = e(sample)
egen mean_pop = mean(corr_logpop) if sample==1 
egen mean_harvest =  mean(drought_harvest5) if sample==1
egen mean_nonharvest =  mean(drought_nonharvest5) if sample==1

replace HE1 = corr_logpop*(drought_nonharvest5 - mean_nonharvest)
replace HE2 = corr_logpop*(drought_harvest5 - mean_harvest)

gen Z_HE1 = drought_nonharvest5*index_mean
gen Z_HE2 = drought_harvest5*index_mean

xtivreg2 totalpcviolencia dummy1-dummy32 (corr_logpop HE1 HE2 = ///
	index_mean Z_HE1 Z_HE2), fe first
	

acreg totalpcviolencia dummy1-dummy32 (corr_logpop HE1 HE2 =index_mean Z_HE1 Z_HE2), id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster)
outreg2 using Results/TSLS_2.tex, keep(corr_logpop HE1 HE2) ctitle("7") append nocons label dec(3) noaster

drop HE1- Z_HE2

/*------------- ALL CONTROLS -------------*/
gen endo1 = corr_logpop*drought_nonharvest5 
gen endo2 = corr_logpop*drought_harvest5
gen exo1 = index_mean*drought_nonharvest5
gen exo2 = index_mean*drought_harvest5 

generate HE1 =.
generate HE2 =.
label var HE1 "log pop $\times$ Non-harvest"
label var HE2 "log pop $\times$ Harvest"

xtivreg2 totalpcviolencia dummy1-dummy32 $controls (corr_logpop endo1 endo2 = ///
	index_mean exo1 exo2), fe
g sample = e(sample)
egen mean_pop = mean(corr_logpop) if sample==1 
egen mean_harvest =  mean(drought_harvest5) if sample==1
egen mean_nonharvest =  mean(drought_nonharvest5) if sample==1

replace HE1 = corr_logpop*(drought_nonharvest5 - mean_nonharvest)
replace HE2 = corr_logpop*(drought_harvest5 - mean_harvest)

gen Z_HE1 = drought_nonharvest5*index_mean
gen Z_HE2 = drought_harvest5*index_mean

xtivreg2 totalpcviolencia dummy1-dummy32 $controls (corr_logpop HE1 HE2 = ///
	index_mean Z_HE1 Z_HE2), fe
	
acreg totalpcviolencia dummy1-dummy32 $controls (corr_logpop HE1 HE2 =index_mean Z_HE1 Z_HE2), id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster)
outreg2 using Results/TSLS_2.tex, keep(corr_logpop HE1 HE2) ctitle("8") append nocons label dec(3) noaster

drop HE1- Z_HE2

******** droughts times post ********

clear
use "$XTMEX"
global geo "yr1960xCapital40 yr1960xCiudad40 yr1960xlandquality40"
global controls "yr1960xCapital40 yr1960xCiudad40 yr1960xlandquality40 yr1960xcorr_logpop40 yr1960xprimary_schooling40 yr1960xuniversity40 yr1960xbattles_centroid40 yr1960xshare_basin40 yr1960xshare_ind40"

foreach name in drought_nonharvest5 drought_harvest5 {
gen junk=`name' if year==1940
by cve_mun, sort: egen `name'40=max(junk)
gen postx`name'=yr1960*`name'40 
drop junk
}

global drought postxdrought_nonharvest5 postxdrought_harvest5


generate HE1 =.
generate HE2 =.
label var HE1 "log pop $\times$ Non-harvest"
label var HE2 "log pop $\times$ Harvest"

/*------------- NO CONTROLS -------------*/
gen endo1 = corr_logpop*drought_nonharvest5 
gen endo2 = corr_logpop*drought_harvest5
gen exo1 = index_mean*drought_nonharvest5
gen exo2 = index_mean*drought_harvest5 

xtivreg2 totalpcviolencia dummy1-dummy32 $drought (corr_logpop endo1 endo2 = ///
	index_mean exo1 exo2), fe
g sample = e(sample)
egen mean_pop = mean(corr_logpop) if sample==1 
egen mean_harvest =  mean(drought_harvest5) if sample==1
egen mean_nonharvest =  mean(drought_nonharvest5) if sample==1

replace HE1 = corr_logpop*(drought_nonharvest5 - mean_nonharvest)
replace HE2 = corr_logpop*(drought_harvest5 - mean_harvest)

gen Z_HE1 = drought_nonharvest5*index_mean
gen Z_HE2 = drought_harvest5*index_mean

xtivreg2 totalpcviolencia dummy1-dummy32 $drought (corr_logpop HE1 HE2 = ///
	index_mean Z_HE1 Z_HE2), fe first

acreg totalpcviolencia dummy1-dummy32 $drought (corr_logpop HE1 HE2 =index_mean Z_HE1 Z_HE2), id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster)
outreg2 using Results/TSLS_2.tex, keep(corr_logpop HE1 HE2) ctitle("9") append nocons label dec(3) noaster

drop HE1- Z_HE2

/*------------- ALL CONTROLS -------------*/
gen endo1 = corr_logpop*drought_nonharvest5 
gen endo2 = corr_logpop*drought_harvest5
gen exo1 = index_mean*drought_nonharvest5
gen exo2 = index_mean*drought_harvest5 

generate HE1 =.
generate HE2 =.
label var HE1 "log pop $\times$ Non-harvest"
label var HE2 "log pop $\times$ Harvest"

xtivreg2 totalpcviolencia dummy1-dummy32 $controls $drought (corr_logpop endo1 endo2 = ///
	index_mean exo1 exo2), fe
g sample = e(sample)
egen mean_pop = mean(corr_logpop) if sample==1 
egen mean_harvest =  mean(drought_harvest5) if sample==1
egen mean_nonharvest =  mean(drought_nonharvest5) if sample==1

replace HE1 = corr_logpop*(drought_nonharvest5 - mean_nonharvest)
replace HE2 = corr_logpop*(drought_harvest5 - mean_harvest)

gen Z_HE1 = drought_nonharvest5*index_mean
gen Z_HE2 = drought_harvest5*index_mean

xtivreg2 totalpcviolencia dummy1-dummy32 $controls $drought (corr_logpop HE1 HE2 = ///
	index_mean Z_HE1 Z_HE2), fe

acreg totalpcviolencia dummy1-dummy32 $controls $drought (corr_logpop HE1 HE2 =index_mean Z_HE1 Z_HE2), id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster)
outreg2 using Results/TSLS_2.tex, keep(corr_logpop HE1 HE2) ctitle("10") append nocons label dec(3) noaster

drop HE1- Z_HE2

// ---------------------------------------------------------------------------//
// 								OTHER OUTCOMES - FS							  //	
// ---------------------------------------------------------------------------//
clear
use `junk'
preserve
keep if sample1==1
acreg corr_logpop index_mean dummy1-dummy32, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using Results/FS_2.tex, keep(index_mean) ctitle("1") replace nocons label dec(3) noaster
restore
global controls "yr1960xCapital40 yr1960xCiudad40 yr1960xlandquality40 yr1960xcorr_logpop40 yr1960xprimary_schooling40 yr1960xuniversity40 yr1960xbattles_centroid40 yr1960xshare_basin40 yr1960xshare_ind40"
preserve
keep if sample2==1
acreg corr_logpop index_mean dummy1-dummy32 $controls, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using Results/FS_2.tex, keep(index_mean) ctitle("2") append nocons label dec(3) noaster
restore
preserve
keep if sample1==1
acreg corr_logpop index_mean dummy1-dummy32, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using Results/FS_2.tex, keep(index_mean) ctitle("3") append nocons label dec(3) noaster
restore
global controls "yr1960xCapital40 yr1960xCiudad40 yr1960xlandquality40 yr1960xcorr_logpop40 yr1960xprimary_schooling40 yr1960xuniversity40 yr1960xbattles_centroid40 yr1960xshare_basin40 yr1960xshare_ind40"
preserve
keep if sample2==1
acreg corr_logpop index_mean dummy1-dummy32 $controls, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using Results/FS_2.tex, keep(index_mean) ctitle("4") append nocons label dec(3) noaster
restore
preserve
keep if sample1==1
acreg corr_logpop index_mean dummy1-dummy32, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using Results/FS_2.tex, keep(index_mean) ctitle("5") append nocons label dec(3) noaster
restore
global controls "yr1960xCapital40 yr1960xCiudad40 yr1960xlandquality40 yr1960xcorr_logpop40 yr1960xprimary_schooling40 yr1960xuniversity40 yr1960xbattles_centroid40 yr1960xshare_basin40 yr1960xshare_ind40"
preserve
keep if sample2==1
acreg corr_logpop index_mean dummy1-dummy32 $controls, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster) 
outreg2 using Results/FS_2.tex, keep(index_mean) ctitle("6") append nocons label dec(3) noaster
restore

// ---------------------------------------------------------------------------//
// 									HE	- FS								  //	
// ---------------------------------------------------------------------------//

clear
use "$XTMEX"
global geo "yr1960xCapital40 yr1960xCiudad40 yr1960xlandquality40"
global controls "yr1960xCapital40 yr1960xCiudad40 yr1960xlandquality40 yr1960xcorr_logpop40 yr1960xprimary_schooling40 yr1960xuniversity40 yr1960xbattles_centroid40 yr1960xshare_basin40 yr1960xshare_ind40"

generate HE1 =.
generate HE2 =.

/*------------- NO CONTROLS -------------*/
gen endo1 = corr_logpop*drought_nonharvest5 
gen endo2 = corr_logpop*drought_harvest5
gen exo1 = index_mean*drought_nonharvest5
gen exo2 = index_mean*drought_harvest5 

xtivreg2 totalpcviolencia dummy1-dummy32 (corr_logpop endo1 endo2 = ///
	index_mean exo1 exo2), fe first
g sample = e(sample)
egen mean_pop = mean(corr_logpop) if sample==1 
egen mean_harvest =  mean(drought_harvest5) if sample==1
egen mean_nonharvest =  mean(drought_nonharvest5) if sample==1

replace HE1 = corr_logpop*(drought_nonharvest5 - mean_nonharvest)
replace HE2 = corr_logpop*(drought_harvest5 - mean_harvest)

gen Z_HE1 = drought_nonharvest5*index_mean
gen Z_HE2 = drought_harvest5*index_mean
label var Z_HE1 "Modified predicted mortality (Mexico) $\times$ Non-harvest"
label var Z_HE2 "Modified predicted mortality (Mexico) $\times$ Harvest"

xtivreg2 totalpcviolencia dummy1-dummy32 (corr_logpop HE1 HE2 = ///
	index_mean Z_HE1 Z_HE2), fe first
	
acreg corr_logpop index_mean Z_HE1 Z_HE2 dummy1-dummy32, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster)
outreg2 using Results/FS_2.tex, keep(index_mean Z_HE1 Z_HE2) ctitle("7") append nocons label dec(3)  noaster

drop HE1- Z_HE2

/*------------- ALL CONTROLS -------------*/
generate HE1 =.
generate HE2 =.
label var HE1 "log pop $\times$ Non-harvest"
label var HE2 "log pop $\times$ Harvest"

gen endo1 = corr_logpop*drought_nonharvest5 
gen endo2 = corr_logpop*drought_harvest5
gen exo1 = index_mean*drought_nonharvest5
gen exo2 = index_mean*drought_harvest5 

xtivreg2 totalpcviolencia dummy1-dummy32 (corr_logpop endo1 endo2 = ///
	index_mean exo1 exo2) $controls, fe first
g sample = e(sample)
egen mean_pop = mean(corr_logpop) if sample==1 
egen mean_harvest =  mean(drought_harvest5) if sample==1
egen mean_nonharvest =  mean(drought_nonharvest5) if sample==1

replace HE1 = corr_logpop*(drought_nonharvest5 - mean_nonharvest)
replace HE2 = corr_logpop*(drought_harvest5 - mean_harvest)

gen Z_HE1 = drought_nonharvest5*index_mean
gen Z_HE2 = drought_harvest5*index_mean
label var Z_HE1 "Modified predicted mortality (Mexico) $\times$ Non-harvest"
label var Z_HE2 "Modified predicted mortality (Mexico) $\times$ Harvest"

acreg corr_logpop index_mean Z_HE1 Z_HE2 dummy1-dummy32 $controls, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster)
outreg2 using Results/FS_2.tex, keep(index_mean Z_HE1 Z_HE2) ctitle("7") append nocons label dec(3)  noaster

******** droughts times post ********

clear
use "$XTMEX"
global geo "yr1960xCapital40 yr1960xCiudad40 yr1960xlandquality40"
global controls "yr1960xCapital40 yr1960xCiudad40 yr1960xlandquality40 yr1960xcorr_logpop40 yr1960xprimary_schooling40 yr1960xuniversity40 yr1960xbattles_centroid40 yr1960xshare_basin40 yr1960xshare_ind40"
label var corr_logpop "log population"

foreach name in drought_nonharvest5 drought_harvest5 {
gen junk=`name' if year==1940
by cve_mun, sort: egen `name'40=max(junk)
gen postx`name'=yr1960*`name'40 
drop junk
}

global drought postxdrought_nonharvest5 postxdrought_harvest5


generate HE1 =.
generate HE2 =.
label var HE1 "log pop $\times$ Non-harvest"
label var HE2 "log pop $\times$ Harvest"

/*------------- NO CONTROLS -------------*/
gen endo1 = corr_logpop*drought_nonharvest5 
gen endo2 = corr_logpop*drought_harvest5
gen exo1 = index_mean*drought_nonharvest5
gen exo2 = index_mean*drought_harvest5 

xtivreg2 totalpcviolencia dummy1-dummy32 $drought (corr_logpop endo1 endo2 = ///
	index_mean exo1 exo2), fe
g sample = e(sample)
egen mean_pop = mean(corr_logpop) if sample==1 
egen mean_harvest =  mean(drought_harvest5) if sample==1
egen mean_nonharvest =  mean(drought_nonharvest5) if sample==1

replace HE1 = corr_logpop*(drought_nonharvest5 - mean_nonharvest)
replace HE2 = corr_logpop*(drought_harvest5 - mean_harvest)

gen Z_HE1 = drought_nonharvest5*index_mean
gen Z_HE2 = drought_harvest5*index_mean
label var Z_HE1 "Modified predicted mortality (Mexico) $\times$ Non-harvest"
label var Z_HE2 "Modified predicted mortality (Mexico) $\times$ Harvest"

acreg corr_logpop index_mean Z_HE1 Z_HE2 dummy1-dummy32 $drought, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster)
outreg2 using Results/FS_2.tex, keep(index_mean Z_HE1 Z_HE2) ctitle("7") append nocons label dec(3)  noaster

drop HE1- Z_HE2

/*------------- ALL CONTROLS -------------*/
gen endo1 = corr_logpop*drought_nonharvest5 
gen endo2 = corr_logpop*drought_harvest5
gen exo1 = index_mean*drought_nonharvest5
gen exo2 = index_mean*drought_harvest5 

generate HE1 =.
generate HE2 =.
label var HE1 "log pop $\times$ Non-harvest"
label var HE2 "log pop $\times$ Harvest"

xtivreg2 totalpcviolencia dummy1-dummy32 $controls $drought (corr_logpop endo1 endo2 = ///
	index_mean exo1 exo2), fe
g sample = e(sample)
egen mean_pop = mean(corr_logpop) if sample==1 
egen mean_harvest =  mean(drought_harvest5) if sample==1
egen mean_nonharvest =  mean(drought_nonharvest5) if sample==1

replace HE1 = corr_logpop*(drought_nonharvest5 - mean_nonharvest)
replace HE2 = corr_logpop*(drought_harvest5 - mean_harvest)

gen Z_HE1 = drought_nonharvest5*index_mean
gen Z_HE2 = drought_harvest5*index_mean
label var Z_HE1 "Modified predicted mortality (Mexico) $\times$ Non-harvest"
label var Z_HE2 "Modified predicted mortality (Mexico) $\times$ Harvest"

acreg corr_logpop index_mean Z_HE1 Z_HE2 dummy1-dummy32 $controls $drought, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster)
outreg2 using Results/FS_2.tex, keep(index_mean Z_HE1 Z_HE2) ctitle("7") append nocons label dec(3)  noaster

drop HE1- Z_HE2

cap erase Results/FS_2.txt
cap erase Results/TSLS_2.txt
