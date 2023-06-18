clear
clear matrix
set scheme s1color
set more off

cd $dir1

use final.dta, clear

*sample selection:
qui reg reb_final n_firms_bid winner_in_reg max_wins_std tt_cont ty_del term_limit unsched6048 dist5m dist4m dist3m dist3p dist4p $geog $time $auction $mayor $electoral
gen sample1=e(sample)
keep if sample1==1


*Show in tables only relevant variables
local keep "keep(ty_del tt_cont tt_party_cont term_limit gender age starting_value pop_res)"


** First Stage

reg tt_cont unsched6048 dist5m dist4m dist3m dist3p dist4p, cluster(id_mayor)
local f=(_b[unsched6048]/_se[unsched6048])^2
local nm= e(N_clust)
su tt_cont if e(sample)
local mout=r(mean)
outreg2 using Tab7, keep(unsched6048) bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout', F-exc.-Inst, `f') nocons replace ct("N. terms in office", OLS) label


reg tt_cont unsched6048 dist5m dist4m dist3m dist3p dist4p term_limit $geog $time $auction $mayor $electoral, cluster(id_mayor)
local f=(_b[unsched6048]/_se[unsched6048])^2
local nm= e(N_clust)
su tt_cont if e(sample)
local mout=r(mean)
outreg2 using Tab7, keep(unsched6048 term_limit gender age starting_value pop_res tt_party_cont) bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout', F-exc.-Inst, `f') nocons append ct("N. terms in office", OLS) label


** Second Stage

** Level of competition: number of bidders

ivreg2 n_firms_bid (tt_cont=unsched6048) dist5m dist4m dist3p dist4p  , cl(id_mayor)
su n_firms_bid if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2 using Tab7, `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons append ct("N. of bidders", 2SLS) label 

ivreg2 n_firms_bid (tt_cont=unsched6048) dist5m dist4m dist3p dist4p term_limit $geog $time $auction $mayor $electoral, cl(id_mayor)
su n_firms_bid if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2 using Tab7, `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons append ct("N. of, bidders", 2SLS) label 

** Level of competition: winning rebate
ivreg2 reb_final (tt_cont=unsched6048) dist5m dist4m dist3p dist4p  , cl(id_mayor)
su reb_final if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2 using Tab7, `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons append ct("Winning, rebate", 2SLS) label 

ivreg2 reb_final (tt_cont=unsched6048) dist5m dist4m dist3p dist4p term_limit $geog $time $auction $mayor $electoral, cl(id_mayor)
su reb_final if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2 using Tab7, `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons append ct("Winning, rebate", 2sLS) tex(nopretty)
