////////////////////////////////////////////////////////////////////////////////
/*						MEXICO:	HE - ADDTIONAL FIRST STAGES			    	  */
////////////////////////////////////////////////////////////////////////////////

clear
set more off, permanently

// ---------------------------------------------------------------------------//
// 							HE - ADDTIONAL FIRST STAGES						  //	
// ---------------------------------------------------------------------------//
clear
use "$XTMEX"
global geo "yr1960xCapital40 yr1960xCiudad40 yr1960xlandquality40"
global controls "yr1960xCapital40 yr1960xCiudad40 yr1960xlandquality40 yr1960xcorr_logpop40 yr1960xprimary_schooling40 yr1960xuniversity40 yr1960xbattles_centroid40 yr1960xshare_basin40 yr1960xshare_ind40"

generate HE1 =.
generate HE2 =.
label var HE1 "Log Pop$_{1940-60}$ $\times$ Non-harvest"
label var HE2 "Log Pop$_{1940-60}$ $\times$ Harvest"

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
label var Z_HE1 "Predicted mortality (Mexico) $\times$ Non-harvest"
label var Z_HE2 "Predicted mortality (Mexico) $\times$ Harvest"

acreg HE1 index_mean Z_HE1 Z_HE2 dummy1-dummy32, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster)
outreg2 using Results/APP_FS_p1.tex, keep(index_mean Z_HE1 Z_HE2) ctitle("1") replace nocons label dec(3)  noaster

acreg HE2 index_mean Z_HE1 Z_HE2 dummy1-dummy32, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster)
outreg2 using Results/APP_FS_p1.tex, keep(index_mean Z_HE1 Z_HE2) ctitle("2") append nocons label dec(3)  noaster

drop HE1- Z_HE2

/*------------- ALL CONTROLS -------------*/
generate HE1 =.
generate HE2 =.
label var HE1 "Log Pop$_{1940-60}$ $\times$ Non-harvest"
label var HE2 "Log Pop$_{1940-60}$ $\times$ Harvest"

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
label var Z_HE1 "Predicted mortality (Mexico) $\times$ Non-harvest"
label var Z_HE2 "Predicted mortality (Mexico) $\times$ Harvest"

acreg HE1 index_mean Z_HE1 Z_HE2 dummy1-dummy32 $controls, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster)
outreg2 using Results/APP_FS_p2.tex, keep(index_mean Z_HE1 Z_HE2) ctitle("1") replace nocons label dec(3)  noaster

acreg HE2 index_mean Z_HE1 Z_HE2 dummy1-dummy32 $controls, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster)
outreg2 using Results/APP_FS_p2.tex, keep(index_mean Z_HE1 Z_HE2) ctitle("2") append nocons label dec(3)  noaster


******** droughts times post ********

clear
use "$XTMEX"
global geo "yr1960xCapital40 yr1960xCiudad40 yr1960xlandquality40"
global controls "yr1960xCapital40 yr1960xCiudad40 yr1960xlandquality40 yr1960xcorr_logpop40 yr1960xprimary_schooling40 yr1960xuniversity40 yr1960xbattles_centroid40 yr1960xshare_basin40 yr1960xshare_ind40"
label var corr_logpop "log population"

label var index_mean "Modified predicted mortality"
label var yr1960xprimary_schooling40 "Primary school, 1940"
label var yr1960xuniversity40 "University enrollment, 1940"
label var yr1960xbattles_centroid40 "Historical conflict"
label var yr1960xshare_basin40 "Sedimentary basin"
label var yr1960xshare_ind40 "Share of indigenous"
label var corr_logpop "$\Delta$ log of population$_{1940-60}$"
label var yr1960xcorr_logpop40 "log(pop 1940) $\times$ post year dummy"

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

acreg HE1 index_mean Z_HE1 Z_HE2 dummy1-dummy32 $drought, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster)
outreg2 using Results/APP_FS_p1.tex, keep(index_mean Z_HE1 Z_HE2) ctitle("3") append nocons label dec(3)  noaster

acreg HE2 index_mean Z_HE1 Z_HE2 dummy1-dummy32 $drought, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster)
outreg2 using Results/APP_FS_p1.tex, keep(index_mean Z_HE1 Z_HE2) ctitle("4") append nocons label dec(3)  noaster

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

acreg HE1 index_mean Z_HE1 Z_HE2 dummy1-dummy32 $controls $drought, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster)
outreg2 using Results/APP_FS_p2.tex, keep(index_mean Z_HE1 Z_HE2) ctitle("1") append nocons label dec(3)  noaster

acreg HE2 index_mean Z_HE1 Z_HE2 dummy1-dummy32 $controls $drought, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster)
outreg2 using Results/APP_FS_p2.tex, keep(index_mean Z_HE1 Z_HE2) ctitle("2") append nocons label dec(3)  noaster

drop HE1- Z_HE2


cap erase Results/APP_FS_p1.txt
cap erase Results/APP_FS_p2.txt
