clear
clear matrix
set scheme s1color
set more off

cd $dir1

use final.dta, clear

qui reg reb_final n_firms_bid winner_in_reg max_wins_std tt_cont ty_del term_limit unsched6048 dist5m dist4m dist3m dist3p dist4p $geog $time $auction $mayor $electoral
gen sample1=e(sample)
keep if sample1==1

replace winner_in_reg=winner_in_reg*100 
replace max_wins_std=max_wins_std*100
*Show in tables only relevant variables
local keep "keep(ty_del tt_cont tt_party_cont term_limit gender age starting_value pop_res)"

** Second Stage

** Nature of competition: winner outsider

ivreg2 winner_in_reg (tt_cont=unsched6048) dist5m dist4m dist3p dist4p , cl(id_mayor)
su winner_in_reg if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2 using Tab8, `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons replace ct("Winner, local", 2SLS) label

ivreg2 winner_in_reg (tt_cont=unsched6048) dist5m dist4m dist3p dist4p term_limit $geog $time $auction $mayor $electoral, cl(id_mayor)
su winner_in_reg if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2 using Tab8, `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons append ct("Winner, local", 2SLS) label 

** Nature of competition: winning incumbency

ivreg2 max_wins_std (tt_cont=unsched6048) dist5m dist4m dist3p dist4p  if year_election>=1998 & year_election<=2003, cl(id_mayor)
su max_wins_std if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2 using Tab8, `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons append ct("Max % wins, same firm", 2SLS) label 

ivreg2 max_wins_std (tt_cont=unsched6048) dist5m dist4m dist3p dist4p term_limit $geog $time $auction $mayor $electoral if year_election>=1998 & year_election<=2003, cl(id_mayor)
su max_wins_std if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2 using Tab8, `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons append ct("Max % wins, same firm", 2SLS) label tex(nopretty)
