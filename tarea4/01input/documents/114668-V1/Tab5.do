clear
clear matrix
set scheme s1color
set more off

cd $dir1

use final.dta, clear

* sample selection
qui reg reb_final n_firms_bid winner_in_reg max_wins_std tt_cont term_limit mv_t $geog $time $auction $mayor $electoral if open_race==0 & number_rivals>0 & number_rivals!=.
gen sample1=e(sample)
keep if sample1==1

drop if mv_t==0 & tt_cont==1

*Show in tables only relevant variables
local keep "keep(ty_del tt_cont tt_party_cont term_limit gender age starting_value pop_res)"


** Level of competition: number of bidders
reg n_firms_bid tt_cont mv_t mv_t2 mv_t3, cluster(id_mayor)
su n_firms_bid if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2 using Tab5, `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons replace ct("N. of, bidders", RDD) label nonotes
reg n_firms_bid tt_cont mv_t mv_t2 mv_t3 term_limit $geog $time $auction $mayor $electoral, cluster(id_mayor)
su n_firms_bid if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2 using Tab5, `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons append ct("N. of, bidders", RDD) label nonotes 

** Level of competition: final rebate
reg reb_final tt_cont mv_t mv_t2 mv_t3, cluster(id_mayor)
su reb_final if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2 using Tab5, `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons append ct("Winning, rebate", OLS) label nonotes
reg reb_final tt_cont mv_t mv_t2 mv_t3 term_limit $geog $time $auction $mayor $electoral, cluster(id_mayor)
su reb_final if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2 using Tab5, `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons append ct("Winning, rebate", RDD) tex(nopretty) label 
