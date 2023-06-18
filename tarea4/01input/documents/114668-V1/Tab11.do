clear
clear matrix
set scheme s1color
set more off

cd $dir1

use final.dta, clear
*Show in tables only relevant variables
local keep "keep(ty_del tt_cont tt_party_cont term_limit gender age starting_value pop_res)"


*******
* OLS *
*******

reg delay tt_cont term_limit $geog $time $auction $mayor $electoral, cluster(id_mayor)
su delay if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2 using Tab11, `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons replace ct("Days late", OLS) label

*******
* RDD *
*******

reg delay tt_cont mv_t mv_t2 mv_t3 term_limit $geog $time $auction $mayor $electoral if mv_t!=. & open_race==0 & number_rivals>0 & number_rivals!=., cluster(id_mayor)
su delay if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2 using Tab11, `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons append ct("Days late", RDD) label

******
* IV *
******

ivreg2 delay (tt_cont=unsched6048) dist5m dist4m dist3p dist4p term_limit $geog $time $auction $mayor $electoral if unsched6048!=. & dist5m!=., cl(id_mayor)
su delay if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2 using Tab11, `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons append ct("Days late", IV) label tex(nopretty)
