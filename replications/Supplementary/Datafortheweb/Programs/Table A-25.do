////////////////////////////////////////////////////////////////////////////////
/*					MEXICO:	ROBUSTNESS TO DROUGHTS DEFINITION				  */
////////////////////////////////////////////////////////////////////////////////

clear
set more off, permanently

// ---------------------------------------------------------------------------//
// 						ROBUSTNESS TO DROUGHTS DEFINITION					  //	
// ---------------------------------------------------------------------------//

clear
use "$XTMEX"
global geo "yr1960xCapital40 yr1960xCiudad40 yr1960xlandquality40"
global controls "yr1960xCapital40 yr1960xCiudad40 yr1960xlandquality40 yr1960xcorr_logpop40 yr1960xprimary_schooling40 yr1960xuniversity40 yr1960xbattles_centroid40 yr1960xshare_basin40 yr1960xshare_ind40"

generate inter =.
generate HE1 =.
generate HE2 =.
label var HE1 "log pop $\times$ Non-harvest"
label var HE2 "log pop $\times$ Harvest"

/*------------- NO CONTROLS -------------*/

forvalues j=1/5{
gen endo1 = corr_logpop*drought_nonharvest`j' 
gen endo2 = corr_logpop*drought_harvest`j'
gen exo1 = index_mean*drought_nonharvest`j'
gen exo2 = index_mean*drought_harvest`j'

xtivreg2 totalpcviolencia dummy1-dummy32 (corr_logpop endo1 endo2 = ///
	index_mean exo1 exo2), fe

g sample = e(sample)
egen mean_pop_`j' = mean(corr_logpop) if sample==1 
egen mean_harvest_`j' =  mean(drought_harvest`j') if sample==1
egen mean_nonharvest_`j' =  mean(drought_nonharvest`j') if sample==1

gen HE1_p`j' = corr_logpop*(drought_nonharvest`j' - mean_nonharvest_`j')
gen HE2_p`j' = corr_logpop*(drought_harvest`j' - mean_harvest_`j')

gen Z_HE1_p`j' = drought_nonharvest`j'*index_mean
gen Z_HE2_p`j' = drought_harvest`j'*index_mean

drop sample mean_harvest_`j' mean_nonharvest_`j' endo* exo*
}

foreach var of varlist dell1_all dell1_nonharvest dell1_harvest{
gen endo1 = corr_logpop*`var'
gen exo1 = index_mean*`var'

xtivreg2 totalpcviolencia dummy1-dummy32 (corr_logpop endo1 = ///
	index_mean exo1), fe

g sample = e(sample)
egen mean_pop_`var' = mean(corr_logpop) if sample==1 
egen mean_`var' =  mean(`var') if sample==1

gen HE1_`var' = corr_logpop*(`var' - mean_`var')

gen Z_HE1_`var' = `var'*index_mean

drop sample mean_`var' endo* exo*
}

cap erase "Results/HE_robustness_p1.tex"
cap erase "Results/HE_robustness_p1.txt"
forvalues j=1/5{
preserve
replace HE1 = HE1_p`j'
replace HE2 = HE2_p`j'
acreg totalpcviolencia dummy1-dummy32 (corr_logpop HE1 HE2 =index_mean Z_HE1_p`j' Z_HE2_p`j'), id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster)
outreg2 using Results/HE_robustness_p1.tex, keep(corr_logpop HE1 HE2) ctitle("`j'") append nocons label dec(3) noaster
restore
}
foreach var of varlist dell1_all dell1_nonharvest dell1_harvest{
preserve
if "`var'"=="dell1_harvest"{
replace HE2 = HE1_`var'
acreg totalpcviolencia dummy1-dummy32 (corr_logpop HE2 =index_mean Z_HE1_`var'), id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster)
outreg2 using Results/HE_robustness_p1.tex, keep(corr_logpop HE2) ctitle("`var'") append nocons label dec(3) noaster
}
else{
replace HE1 = HE1_`var'
acreg totalpcviolencia dummy1-dummy32 (corr_logpop HE1 =index_mean Z_HE1_`var'), id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster)
outreg2 using Results/HE_robustness_p1.tex, keep(corr_logpop HE1) ctitle("`var'") append nocons label dec(3) noaster
}
restore
}

replace HE1 = HE1_dell1_nonharvest
replace HE2 = HE1_dell1_harvest
acreg totalpcviolencia dummy1-dummy32 (corr_logpop HE1 HE2 =index_mean Z_HE1_dell1_nonharvest Z_HE1_dell1_harvest), id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster)
outreg2 using Results/HE_robustness_p1.tex, keep(corr_logpop HE1 HE2) ctitle("Dell-All") append nocons label dec(3) noaster

cap erase "Results/HE_robustness_p1.txt"

drop HE1-Z_HE1_dell1_harvest

/*------------- ALL CONTROLS -------------*/

generate HE1 =.
generate HE2 =.
label var HE1 "log pop $\times$ Non-harvest"
label var HE2 "log pop $\times$ Harvest"

forvalues j=1/5{
gen endo1 = corr_logpop*drought_nonharvest`j' 
gen endo2 = corr_logpop*drought_harvest`j'
gen exo1 = index_mean*drought_nonharvest`j'
gen exo2 = index_mean*drought_harvest`j'

xtivreg2 totalpcviolencia dummy1-dummy32 $controls (corr_logpop endo1 endo2 = ///
	index_mean exo1 exo2), fe

g sample = e(sample)
egen mean_pop_`j' = mean(corr_logpop) if sample==1 
egen mean_harvest_`j' =  mean(drought_harvest`j') if sample==1
egen mean_nonharvest_`j' =  mean(drought_nonharvest`j') if sample==1

gen HE1_p`j' = corr_logpop*(drought_nonharvest`j' - mean_nonharvest_`j')
gen HE2_p`j' = corr_logpop*(drought_harvest`j' - mean_harvest_`j')

gen Z_HE1_p`j' = drought_nonharvest`j'*index_mean
gen Z_HE2_p`j' = drought_harvest`j'*index_mean

drop sample mean_harvest_`j' mean_nonharvest_`j' endo* exo*
}

foreach var of varlist dell1_all dell1_nonharvest dell1_harvest{
gen endo1 = corr_logpop*`var'
gen exo1 = index_mean*`var'

xtivreg2 totalpcviolencia dummy1-dummy32 $controls (corr_logpop endo1 = ///
	index_mean exo1), fe

g sample = e(sample)
egen mean_pop_`var' = mean(corr_logpop) if sample==1 
egen mean_`var' =  mean(`var') if sample==1

gen HE1_`var' = corr_logpop*(`var' - mean_`var')

gen Z_HE1_`var' = `var'*index_mean

drop sample mean_`var' endo* exo*
}

cap erase "Results/HE_robustness_p2.tex"
cap erase "Results/HE_robustness_p2.txt"
forvalues j=1/5{
preserve
replace HE1 = HE1_p`j'
replace HE2 = HE2_p`j'
acreg totalpcviolencia dummy1-dummy32 $controls (corr_logpop HE1 HE2 =index_mean Z_HE1_p`j' Z_HE2_p`j'), id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster)
outreg2 using Results/HE_robustness_p2.tex, keep(corr_logpop HE1 HE2) ctitle("`j'") append nocons label dec(3) noaster
restore
}
foreach var of varlist dell1_all dell1_nonharvest dell1_harvest{
preserve
if "`var'"=="dell1_harvest"{
replace HE2 = HE1_`var'
acreg totalpcviolencia dummy1-dummy32 $controls (corr_logpop HE2 =index_mean Z_HE1_`var'), id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster)
outreg2 using Results/HE_robustness_p2.tex, keep(corr_logpop HE2) ctitle("`var'") append nocons label dec(3) noaster
}
else{
replace HE1 = HE1_`var'
acreg totalpcviolencia dummy1-dummy32 $controls (corr_logpop HE1 =index_mean Z_HE1_`var'), id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster)
outreg2 using Results/HE_robustness_p2.tex, keep(corr_logpop HE1) ctitle("`var'") append nocons label dec(3) noaster
}
restore
}

replace HE1 = HE1_dell1_nonharvest
replace HE2 = HE1_dell1_harvest
acreg totalpcviolencia dummy1-dummy32 $controls (corr_logpop HE1 HE2 =index_mean Z_HE1_dell1_nonharvest Z_HE1_dell1_harvest), id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512) time(year) pfe1(muncluster)
outreg2 using Results/HE_robustness_p2.tex, keep(corr_logpop HE1 HE2) ctitle("Dell-All") append nocons label dec(3) noaster

cap erase "Results/HE_robustness_p2.txt"
