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

replace winner_in_reg=winner_in_reg*100 
replace max_wins_std=max_wins_std*100

*Show in tables only relevant variables
local keep "keep(ty_del tt_cont tt_party_cont term_limit gender age starting_value pop_res)"

** Nature of competition: winner outsider
reg winner_in_reg tt_cont mv_t mv_t2 mv_t3, cluster(id_mayor)
su winner_in_reg if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2 using Tab6, `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons replace ct("Winner, local", RDD) label 
reg winner_in_reg tt_cont mv_t mv_t2 mv_t3 term_limit $geog $time $auction $mayor $electoral, cluster(id_mayor)
su winner_in_reg if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2 using Tab6, `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons append ct("Winner, local", RDD) label


** Nature of competition: winning incumbency
reg max_wins_std tt_cont mv_t mv_t2 mv_t3 if year_election>=1998 & year_election<=2003, cluster(id_mayor)
su max_wins_std if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2 using Tab6, `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons append ct("Max % wins, same firm", OLS) label 
reg max_wins_std tt_cont mv_t mv_t2 mv_t3 term_limit $geog $time $auction $mayor $electoral if year_election>=1998 & year_election<=2003, cluster(id_mayor)
su max_wins_std if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2 using Tab6, `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons append ct("Max % wins, same firm", RDD) tex(nopretty) label 
