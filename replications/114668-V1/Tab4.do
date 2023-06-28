clear
clear matrix
set scheme s1color
set more off

cd $dir1

use final.dta, clear

replace winner_in_reg=winner_in_reg*100 
replace max_wins_std=max_wins_std*100

*Show in tables only relevant variables
local keep "keep(ty_del tt_cont tt_party_cont term_limit gender age starting_value pop_res)"

** Nature of competition: winner outsider

reg winner_in_reg ty_del , cluster(id_mayor)
su winner_in_reg if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2  using Tab4, `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons replace ct("Winner, local", OLS) label  nonotes
reg winner_in_reg ty_del term_limit $geog $time $auction $mayor $electoral, cluster(id_mayor)
su winner_in_reg if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2 using Tab4, `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons append ct("Winner, local", OLS) label nonotes
reg winner_in_reg tt_cont term_limit $geog $time $auction $mayor $electoral, cluster(id_mayor)
su winner_in_reg if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2 using Tab4, `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons append ct("Winner, local", OLS) label nonotes

** Nature of competition: winning incumbency

reg max_wins_std ty_del if year_election>=1998 & year_election<=2003, cluster(id_mayor)
su max_wins_std if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2 using Tab4, `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons append ct("Max % wins, same firm", OLS) label nonotes
reg max_wins_std ty_del term_limit $geog $time $auction $mayor $electoral if year_election>=1998 & year_election<=2003, cluster(id_mayor)
su max_wins_std if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2 using Tab4, `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons append ct("Max % wins, same firm", OLS) tex(nopretty) label nonotes
reg max_wins_std tt_cont term_limit $geog $time $auction $mayor $electoral if year_election>=1998 & year_election<=2003, cluster(id_mayor)
su max_wins_std if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2 using Tab4, `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons append ct("Max % wins, same firm", OLS) tex(nopretty) label nonotes
