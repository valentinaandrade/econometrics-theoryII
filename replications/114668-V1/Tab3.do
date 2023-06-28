clear
clear matrix
set scheme s1color
set more off

cd $dir1

use final.dta, clear
*Show in tables only relevant variables
local keep "keep(ty_del tt_cont tt_party_cont term_limit gender age starting_value pop_res)"

** Level of competition: number of bidders

reg n_firms_bid ty_del, cluster(id_mayor)
su n_firms_bid if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2  using Tab3, `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons replace ct("N. of, bidders", OLS) label  nonotes
reg n_firms_bid ty_del term_limit $geog $time $auction $mayor $electoral, cluster(id_mayor)
su n_firms_bid if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2 using Tab3, `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons append ct("N. of, bidders", OLS) label nonotes
reg n_firms_bid tt_cont term_limit $geog $time $auction $mayor $electoral, cluster(id_mayor)
su n_firms_bid if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2 using Tab3, `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons append ct("N. of, bidders", OLS) label nonotes

** Level of competition: winning rebate

reg reb_final ty_del, cluster(id_mayor)
su reb_final if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2 using Tab3, `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons append ct("Winning, Rebate", OLS) label 
reg reb_final ty_del term_limit $geog $time $auction $mayor $electoral, cluster(id_mayor)
su reb_final if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2 using Tab3, `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons append ct("Winning, Rebate", OLS) tex(nopretty) label 
reg reb_final tt_cont term_limit $geog $time $auction $mayor $electoral, cluster(id_mayor)
su reb_final if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2 using Tab3, `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons append ct("Winning, Rebate", OLS) tex(nopretty) label 
