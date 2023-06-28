clear
clear matrix
set scheme s1color
set more off

cd $dir1

use final_gs.dta, clear

*Show in tables only relevant variables
local keep "keep(ty_del tt_cont tt_party_cont term_limit gender age starting_value pop_res)"

**********************
* FE for the objects *
**********************

areg reb_final tt_cont term_limit $geog2 $time2 $auction2 $mayor $electoral, cluster(id_mayor) a(objcat)
su reb_final if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2 using Tab12, `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons replace ct("Rebate", FE) label

*******
* RDD *
*******

areg reb_final tt_cont term_limit mv_t mv_t2 mv_t3 $geog2 $time2 $auction2 $mayor $electoral if open_race==0 & number_rivals>0 & number_rivals!=., cluster(id_mayor) a(objcat)
su reb_final if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2 using Tab12, `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons append ct("Rebate", FE-RDD) label

*******
* IV *
*******

ivreg2 reb_final (tt_cont=unsched6048) dist5m dist4m dist3p dist4p term_limit $geog2 $time2 $auction2 $mayor $electoral dobj* if unsched6048!=. & dist5m!=., cl(id_mayor)
su reb_final if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2 using Tab12, `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons append ct("Rebate", IV) label tex(nopretty)
