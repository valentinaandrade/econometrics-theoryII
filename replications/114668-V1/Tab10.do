clear
clear matrix
set scheme s1color
set more off

cd $dir1

use final.dta, clear

*Show in tables only relevant variables
local keep "keep(ty_del tt_cont tt_party_cont term_limit gender age starting_value pop_res)"


bysort id_mayor tt_cont id_manager: egen n_man=count(id_manager) if id_manager!=.
bysort id_mayor tt_cont: egen max_man=max(n_man) if n_man!=.
gen max_man_std=100*max_man/tot_auctions if max_man!=0 & max_man!=.

* sample selection
reg reb_final n_firms_bid winner_in_reg max_wins_std tt_cont ty_del term_limit mv_t $geog $time $auction $mayor $electoral 
gen sample1=e(sample)
keep if sample1==1
 

*******
* OLS *
*******

reg max_man_std tt_cont term_limit $geog $time $auction $mayor $electoral if year_election>=1998 & year_election<=2003, cluster(id_mayor)
su max_man_std if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2 using Tab10, `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons replace ct("Max % same manager", OLS) label

*******
* RDD *
*******

reg max_man_std tt_cont mv_t mv_t2 mv_t3 term_limit $geog $time $auction $mayor $electoral if mv_t!=. & open_race==0 & number_rivals>0 & number_rivals!=. & (year_election>=1998 & year_election<=2003), cluster(id_mayor)
su max_man_std if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2 using Tab10, `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons append ct("Max % same manager", RDD) label

******
* IV *
******

ivreg2 max_man_std (tt_cont=unsched6048) dist5m dist4m dist3p dist4p term_limit $geog $time $auction $mayor $electoral if unsched6048!=. & dist5m!=. & (year_election>=1998 & year_election<=2003), cluster(id_mayor)
su max_man_std if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2 using Tab10, `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons append ct("Max % same manager", IV) label tex(nopretty)
