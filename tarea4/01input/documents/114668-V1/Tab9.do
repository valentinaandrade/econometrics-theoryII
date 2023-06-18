clear
clear matrix
set scheme s1color
set more off

cd $dir1

use final.dta, clear
*Show in tables only relevant variables
local keep "keep(ty_del tt_cont tt_party_cont term_limit gender age starting_value pop_res)"


* Starting Value
 
*******
* OLS *
*******

reg starting_value tt_cont term_limit $geog $time $auction3 $mayor $electoral , cluster(id_mayor)
su starting_value if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2  using Tab9, nonotes `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons replace ct("Starting Value", OLS) label

*******
* RDD *
*******

reg starting_value tt_cont mv_t mv_t2 mv_t3 term_limit $geog $time $auction3 $mayor $electoral if mv_t!=. & open_race==0 & number_rivals>0 & number_rivals!=. , cluster(id_mayor)
su starting_value if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2  using Tab9, nonotes  `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons append ct("Starting Value", RDD) label

******
* IV *
******

ivreg2 starting_value (tt_cont=unsched6048) dist5m dist4m dist3p dist4p term_limit $geog $time $auction3 $mayor $electoral, cluster(id_mayor)
su starting_value if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2  using Tab9, nonotes  `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons append ct("Starting Value", IV) label tex(nopretty)


* Roads/Type

*******
* OLS *
*******

reg obj_work_road tt_cont term_limit $geog $time $auction4 $mayor $electoral , cluster(id_mayor)
su obj_work_road if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2  using Tab9, nonotes `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons append ct("% Roads", OLS) label

*******
* RDD *
*******

reg obj_work_road tt_cont mv_t mv_t2 mv_t3 term_limit $geog $time $auction4 $mayor $electoral if mv_t!=. & open_race==0 & number_rivals>0 & number_rivals!=. , cluster(id_mayor)
su obj_work_road if e(sample) 
local nm= e(N_clust)
local mout=r(mean)
outreg2  using Tab9, nonotes `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons append ct("% Roads", RDD) label

******
* IV *
******

ivreg2 obj_work_road (tt_cont=unsched6048) dist5m dist4m dist3p dist4p term_limit $geog $time $auction4 $mayor $electoral, cluster(id_mayor)
su obj_work_road if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2  using Tab9, nonotes `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons append ct("% Roads", IV) label 


* Discretion: contracts below 300,000 are less complex and need not to be adjudicated with open auctions.

gen direct_nego_gr_old=direct_nego_gr
drop direct_nego_gr
gen direct_nego_gr=starting_value<3

*******
* OLS *
*******

reg  direct_nego_gr tt_cont term_limit $geog $time $auction5 $mayor $electoral , cluster(id_mayor)
su  direct_nego_gr if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2  using Tab9, nonotes `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons append ct("Less Complex", OLS) label

*******
* RDD *
*******

reg  direct_nego_gr tt_cont mv_t mv_t2 mv_t3 term_limit $geog $time $auction5 $mayor $electoral if mv_t!=. & open_race==0 & number_rivals>0 & number_rivals!=. , cluster(id_mayor)
su  direct_nego_gr if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2  using Tab9, nonotes `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons append ct("Less Complex", RDD) label

******
* IV *
******

ivreg2  direct_nego_gr (tt_cont=unsched6048) dist5m dist4m dist3p dist4p term_limit $geog $time $auction5 $mayor $electoral, cluster(id_mayor)
su  direct_nego_gr if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2  using Tab9, nonotes `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons append ct("Less Complex", IV) label 


* Auction with NO Publicity (Threshold 500,000 euros). If Above more publicity=>More Competition. Coviello and Mariniello (2014)

gen publicity=starting_value<5
label var publicity "Auction need not to be publish"

*******
* OLS *
*******

reg publicity tt_cont term_limit $geog $time $auction5 $mayor $electoral , cluster(id_mayor)
su publicity if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2  using Tab9, nonotes `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons append ct("No Publicity", OLS) label

*******
* RDD *
*******

reg publicity tt_cont mv_t mv_t2 mv_t3 term_limit $geog $time $auction5 $mayor $electoral if mv_t!=. & open_race==0 & number_rivals>0 & number_rivals!=. , cluster(id_mayor)
su publicity if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2  using Tab9, nonotes `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons append ct("No Publicity", RDD) label

******
* IV *
******

ivreg2 publicity (tt_cont=unsched6048) dist5m dist4m dist3p dist4p term_limit $geog $time $auction5 $mayor $electoral , cluster(id_mayor)
su publicity if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2  using Tab9, nonotes `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons append ct("No Publicity", IV) label tex(nopretty)
