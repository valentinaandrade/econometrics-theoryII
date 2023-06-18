clear
clear matrix
set scheme s1color
set more off

cd $dir1

use final.dta, clear
*Show in tables only relevant variables
local keep "keep(ty_del tt_cont tt_party_cont term_limit gender age starting_value pop_res)"

* Prob of all other cathegories of objects also summarized in Table 2. This Table in Appendix

local obj "obj_work_school obj_work_build obj_work_house obj_work_art obj_work_other"

local i=1
foreach var of local obj {
if `i'==1 {
local title "% Schools " 
local replace "replace"
local append "append"
}
else if `i'==2 {
local title "% Buildings"
local replace "append"
local append "append"
}
else if `i'==3 {
local title "% Housing"
local replace "append"
local append "append"
}
else if `i'==4 {
local title "% Art"
local replace "append"
local append "append"
}
else if `i'==5 {
local title "% Other"
local replace "append"
local append "append"
}

*******
* OLS *
*******

reg `var' tt_cont term_limit $geog $time $auction4 $mayor $electoral , cluster(id_mayor)
su `var' if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2  using TabA6, nonotes `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons `replace' ct("`title'", OLS) label

*******
* RDD *
*******

reg `var' tt_cont mv_t mv_t2 mv_t3 term_limit $geog $time $auction4 $mayor $electoral if mv_t!=. & open_race==0 & number_rivals>0 & number_rivals!=. , cluster(id_mayor)
su `var' if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2  using TabA6, nonotes `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons `append' ct("`title'", RDD) label


******
* IV *
******

ivreg2 `var' (tt_cont=unsched6048) dist5m dist4m dist3p dist4p term_limit $geog $time $auction4 $mayor $electoral, cluster(id_mayor)
su `var' if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2  using TabA6, nonotes `keep'  bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons `append' ct("`title'", IV) label tex(nopretty) 

local i=`i'+1
}

