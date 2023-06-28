clear
clear matrix
set scheme s1color
set more off

cd $dir1

use final.dta, clear

*Show in tables only relevant variables
local keep "keep(tt_cont tt_party_cont term_limit gender age starting_value pop_res)"

 
*Table for aggregate estimates at the term level.

foreach var of varlist obj_work_road obj_work_school obj_work_build obj_work_house obj_work_art {
   gen value_`var'=starting_value if `var'==1
}
gen one=1
collapse (mean) n_firms_bid reb_final winner_in_reg max_wins_std tt_cont term_limit mv_t mv_t2 mv_t3 ///
unsched6048 dist5m dist4m dist3p dist4p $geog $time $auction $mayor $electoral (sum) n_auctions=one /// 
(sum) n_auctions_road=obj_work_road n_auctions_school=obj_work_school n_auctions_build=obj_work_build n_auctions_house=obj_work_house /// 
n_auctions_art=obj_work_art n_auctions_oth=obj_work_oth  value_auctions=starting_value value_road=obj_work_road value_school=obj_work_school ///
 value_build=obj_work_build value_house=obj_work_house value_art=obj_work_art value_oth=obj_work_oth, by(id_mayor year_election)
sort id_mayor year_election
 
global auctionTT "direct_nego_gr"
li n_auctions n_auctions_road obj_work_road  id_mayor year_election tt_cont in 1


foreach var of varlist n_auctions_road n_auctions_school n_auctions_build n_auctions_house n_auctions_art n_auctions_oth {
   replace `var'=(`var'/n_auctions)*100
}
foreach var of varlist value_road value_school value_build value_house value_art value_oth {
   replace `var'=(`var'/value_auctions)*100
}



* N.auctions
local i=1
foreach var of varlist n_auctions  {
if `i'==1 {
local title "N.Auctions" 
local replace "replace"
local append "append"
}
else if `i'==2 {
local title "% Roads" 
local replace "append"
local append "append"
}
else if `i'==3 {
local title "% Schools"
local replace "append"
local append "append"
}
else if `i'==4 {
local title "% Buildings"
local replace "append"
local append "append"
}
else if `i'==5 {
local title "% Housing"
local replace "append"
local append "append"
}
else if `i'==6 {
local title "% Art"
local replace "append"
local append "append"
}
else if `i'==7 {
local title "% Other"
local replace "append"
local append "append"
}

   reg `var' tt_cont term_limit $geog $time $auctionTT $mayor $electoral, cluster(id_mayor)
   su `var' if e(sample)
   local nm= e(N_clust)
   local mout=r(mean)
   outreg2 using TabA7, nonotes `keep' /// 
   bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons `replace' ct("`title'", OLS)
   
   reg `var' tt_cont term_limit mv_t mv_t2 mv_t3 $geog $time $auctionTT $mayor $electoral, cluster(id_mayor)
   su `var' if e(sample)
   local nm= e(N_clust)
   local mout=r(mean)
   outreg2 using TabA7, nonotes `keep' addstat(Number of Mayors, `nm', Avg. outcome, `mout') ///
   nocons `append' ct(, RD) 
   
   ivreg2 `var' (tt_cont=unsched6048) dist5m dist4m dist3p dist4p term_limit $geog $time $auctionTT $mayor $electoral, cl(id_mayor)
   su `var' if e(sample)
   local nm= e(N_clust)
   local mout=r(mean)
   outreg2 using TabA7, nonotes `keep' addstat(Number of Mayors, `nm', Avg. outcome, `mout') ///
   bdec(3) nocons `append' ct(, 2SLS) tex(nopretty)

local i=`i'+1
}
