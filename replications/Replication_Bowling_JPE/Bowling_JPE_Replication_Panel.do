clear all
global folder "C:\Users\Nico Voigtländer\Dropbox\dark side social capital\Replication"

cd "$folder"
use Dataset_Bowling_Replication_Panel_JPE.dta, clear

set logtype text
log using Log_Bowling_JPE_Panel.txt, replace

********************************************* Generate variables ****************************************************

quietly{
gen lnpop25=ln(pop25)

tab entry_year, gen(dummy_year)

tsset cityid entry_year

gen cum_entry_lag = 0
replace cum_entry_lag = l1.entries_FU if entry_year==26
replace cum_entry_lag = l1.entries_FU+l1.cum_entry_lag if entry_year==27
replace cum_entry_lag = l1.entries_FU+l1.cum_entry_lag if entry_year==28
replace cum_entry_lag = l1.entries_FU+l1.cum_entry_lag if entry_year==29
replace cum_entry_lag = l1.entries_FU+l1.cum_entry_lag if entry_year==30
replace cum_entry_lag = l1.entries_FU+l1.cum_entry_lag if entry_year==31
replace cum_entry_lag = l1.entries_FU+l1.cum_entry_lag if entry_year==32
replace cum_entry_lag = l1.entries_FU+l1.cum_entry_lag if entry_year==33

gen entry_growth = ln((entries_FU+cum_entry_lag)/cum_entry_lag)

gen pc_cum_entry_FU_lag = 1000*cum_entry_lag/pop25
gen i_cumLagEntry_clubs = pc_cum_entry_FU_lag*clubs_all_pc

foreach x in lnpop25 share_cath25 bcollar25 share_jew25 unemp33 in_welfare_per1000 war_per1000 sozialrentner_per1000 logtaxpers logtaxprop hitler_speech_per1000 DNVP_votes_avg DVP_votes_avg SPD_votes_avg KPD_votes_avg {
	gen i_`x'_cel = `x'*pc_cum_entry_FU_lag
} 

}

*




////////////////////////////////////////////////// Tables 6 -- Panel Results ///////////////////////////////////////////////////		

*Table 6
eststo clear
xtset entry_year
/*1*/eststo: areg entry_growth pc_cum_entry_FU_lag i_cumLagEntry_clubs dummy_year*, abs(cityid) cl(cityid), if entry_year<33
	*Standardized coefficients
	sum entry_growth clubs_all_pc pc_cum_entry_FU_lag if e(sample)
	display(.0355019*1.554977*.5284594)  //standardized effect: coeff(interaction)*std(clubs)*(avg lagged cum entry pc)
	display(.0355019*1.554977*.5284594/.5328638) //standardized effect, relative to avg. entry growth: coeff(interaction)*std(clubs)*(avg lagged cum entry pc)/mean(entry_growth)
/*2*/eststo: areg entry_growth pc_cum_entry_FU_lag i_cumLagEntry_clubs dummy_year* i_lnpop25_cel-i_KPD_votes_avg_cel, abs(cityid) cl(cityid), if entry_year<33
	*Standardized coefficients
	sum entry_growth clubs_all_pc pc_cum_entry_FU_lag if e(sample)
	display(.0416692*1.563188*.5342763)
	display(.0416692*1.563188*.5342763/.5306739 )
*Early entries
/*3*/eststo: areg entry_growth pc_cum_entry_FU_lag i_cumLagEntry_clubs dummy_year*, abs(cityid) cl(cityid), if entry_year<29
	*Standardized coefficients
	sum entry_growth clubs_all_pc pc_cum_entry_FU_lag if e(sample)
	display(.6112715*1.583836*.1848671)
	display(.6112715*1.583836*.1848671/.3421545)
/*4*/eststo: areg entry_growth pc_cum_entry_FU_lag i_cumLagEntry_clubs dummy_year* i_lnpop25_cel-i_KPD_votes_avg_cel, abs(cityid) cl(cityid), if entry_year<29
	*Standardized coefficients
	sum entry_growth clubs_all_pc pc_cum_entry_FU_lag if e(sample)
	display(.6131744*1.590072*.1855974)
	display(.6131744*1.590072*.1855974/.3437975)
*Late entries
/*5*/eststo: areg entry_growth pc_cum_entry_FU_lag i_cumLagEntry_clubs dummy_year*, abs(cityid) cl(cityid), if entry_year>=29 & entry_year<33
	*Standardized coefficients
	sum entry_growth clubs_all_pc pc_cum_entry_FU_lag if e(sample)
	display(.0511185*1.539653*.7028454)
	display(.0511185*1.539653*.7028454/.629656)
/*6*/eststo: areg entry_growth pc_cum_entry_FU_lag i_cumLagEntry_clubs dummy_year* i_lnpop25_cel-i_KPD_votes_avg_cel, abs(cityid) cl(cityid), if entry_year>=29 & entry_year<33
	*Standardized coefficients
	sum entry_growth clubs_all_pc pc_cum_entry_FU_lag if e(sample)
	display(.0547217*1.549139*.7134521)
	display(.0547217*1.549139*.7134521/.6267041)

******************************************************************************************************************************************

log close

