* ------------------------------------------------------------------------------
* AUTHOR: Valentina Andrade
* CREATION: May-2022
* ACTION: Problem set 4 - Problem 3
* ------------------------------------------------------------------------------

set more off 
clear all
eststo clear
* ------------------------------------------------------------------------------
* SET PATH AND LOCALS
* ------------------------------------------------------------------------------

if c(username)=="valentinaandrade" global github"/Users/valentinaandrade/Documents/GitHub/me/econometrics-theoryII/tarea4"

global src 	    "$github/01input/src"
global tmp  	"$github/01input/tmp"
global output   "$github/03output"

* ------------------------------------------------------------------------------
**# globals
* ------------------------------------------------------------------------------
*Geo controls
global geog "pop_res dp* tar_eff_lav deficit deficit_miss"
global geog2 "pop_res dp* deficit deficit_miss"
*Time effects
global time " year2000 year2001 year2002 year2003 year2004"
global time2 "year2000 year2001 year2002 year2003 year2004 year2005 year2007 year2008 year2009 year2010 post"
*Auctions 
global auction "starting_value starting_value2 obj_work_road obj_work_school obj_work_build obj_work_house obj_work_art direct_nego_gr"
global auction2 "starting_value starting_value2 obj_work_const obj_work_renov obj_work_road obj_work_plumb obj_work_ground obj_work_elect obj_work_plant obj_work_env obj_work_secu obj_work_other open_part_gr"
global auction3 "                               obj_work_road obj_work_school obj_work_build obj_work_house obj_work_art direct_nego_gr"
global auction4 "starting_value starting_value2 																		 direct_nego_gr"
global auction5 "obj_work_road obj_work_school obj_work_build obj_work_house obj_work_art"
*Mayor
global mayor "gender age born_prov born_prov_miss office_before empl_not empl_not_miss empl_high empl_high_miss empl_low empl_low_miss secondary secondary_miss college college_miss"
*Political
global electoral "tt_party_cont last_year_off centerright_gr centerleft_gr "
*Pre-determined car.
global predeter "NW NE CE SOU IS pop_census1991 alt extension gender age born_reg secondary college empl_not empl_low empl_medium empl_high"


* ------------------------------------------------------------------------------
**# use data
* ------------------------------------------------------------------------------

use "$src/final.dta"


* ------------------------------------------------------------------------------
**# Figure1
* ------------------------------------------------------------------------------


* sample selection
reg reb_final n_firms_bid max_wins_std tt_cont ty_del term_limit mv_t $geog $time $auction $mayor $electoral if open_race==0 & number_rivals>0 & number_rivals!=. 
gen sample1=e(sample)
keep if sample1==1

drop if mv_t==0 & tt_cont==1

gen above=mv_t>=0 

egen group=cut(mv_t),  at(-80(1)80)
egen mv_t_grp=mean(group),by(group)

foreach var of varlist n_firms_bid reb_final winner_in_reg max_wins_std {
egen `var'_mean = mean(`var'), by(mv_t_grp)
}


*For presentational purposes
keep if mv_t>=-10 & mv_t<=10
keep if n_firms_bid_mean<30
gen mv_tXabove=mv_t*above

local nino "n_firms_bid reb_final winner_in_reg max_wins_std"



local i=1
foreach var of local nino{

if `i'== 1 {
 local svar "N. of bidders"
 local ylabel "16(2)26"
 }

else if `i'==2 {
 local svar "Winning rebate (%)"
 local ylabel "10(2)18"
}

else if `i'==3 {
 local svar "Winner local"
 local ylabel "0(0.25)1"
 }

else if `i'==4 {
 local svar "Max % wins same firm"
 local ylabel "0(0.25)1"
}


qui lowess `var' mv_t if above==0, gen(ciccio) nograph mean
qui lowess `var' mv_t if above==1, gen(ciccia) nograph mean

qui reg `var' mv_t mv_t2 mv_t3 if above==0
predict ciccio2, xb, if e(sample)

qui reg `var' mv_t mv_t2 mv_t3 if above==1
predict ciccia2, xb, if e(sample)


twoway (line ciccio mv_t if above==0 & mv_t<0, sort lcolor(blue)) /*
*/	   (line ciccia mv_t if above==1 & mv_t>=0, sort lcolor(red) ) /*
*/	   (line ciccio2 mv_t if above==0 & mv_t<0, sort lcolor(blue) lp(dash)) /*
*/	   (line ciccia2 mv_t if above==1 & mv_t>=0, sort lcolor(red) lp(dash)) /*
*/     (scatter `var'_mean mv_t_grp , msize(small) mlwidth(vthin) msymbol(circle_hollow) mcolor(gray)), /*
*/     ylabel(`ylabel') ytitle(`svar', size(medlarge)) /* 
*/     xtitle(Margin of victory, size(medlarge)) xline(0, lwidth(0.2) lcolor(black)) xscale(range(-10 10)) xlabel(-10 -5 0 5 10) /*
*/	   legend(label(1 "First term") label(2 "Higher term")  label(5 "Observed values") colgap(*3) width(100) order(1 2 5)) /*
*/     saving(Fig1_`var'.gph, replace) nodraw
drop ciccio* ciccia*

local i=`i'+1

}

graph combine Fig1_n_firms_bid.gph Fig1_reb_final.gph Fig1_winner_in_reg.gph Fig1_max_wins_std.gph, saving("output/figures/fig1.gph", replace)

* ------------------------------------------------------------------------------
**# c. continuity
* ---------------------------------------------------------------------------
use "$src/final.dta", clear

* Own idea
gen cutoff =.
replace cutoff = 1 if mv_t >=0
replace cutoff = 0 if mv_t < 0 


bys cutoff: su age

foreach var of varlist gender empl_high empl_medium empl_low empl_not college secondary born_prov born_city born_reg centerright_gr centerleft_gr center_gr same_party1 {
	bys cutoff: tab `var'
	
}

* Option in paper: Balance 
clear
clear matrix
set more off

use "$src/final.dta", clear

* sample selection
reg reb_final n_firms_bid winner_in_reg max_wins_std tt_cont term_limit mv_t $geog $time $auction $mayor $electoral if open_race==0 & number_rivals>0 & number_rivals!=.
gen sample1=e(sample)
keep if sample1==1

drop if mv_t==0 & tt_cont==1

keep if tag_term==1

gen id_sample1=term_limit==0
gen id_sample2=term_limit==1

gen tt_cont_gt1=tt_cont>2

*Correction for time-invariant age/year of birth:

gen agec=age
replace agec=age-4 if tt_cont==2
replace agec=age-8 if tt_cont==3
replace agec=age-12 if tt_cont==4

local pre "NW NE CE SOU IS pop_census1991 alt extension gender agec born_reg secondary college empl_not empl_low empl_medium empl_high office_before party_maj_left_bef party_maj_right_bef party_maj_center_bef party_maj_local_bef same_party1 same_party2"

 matrix balance = J(49,1,.)
 matrix colnames balance  =  All 
 matrix rownames balance  =  NW . NE . CE . SOU . IS . Population . Altitude . Extension . gender . age . born_reg . secondary . /// 
 college . empl_not . empl_low . empl_med . empl_high . office_bef . party_maj_left_bef . party_maj_right_bef . party_maj_center_bef . party_maj_local_bef . same_party1 . same_party2 . N

 matrix pval = J(24,1,.)
 matrix rownames pval  =  NW NE CE SOU IS Population Altitude Extension gender age born_reg secondary /// 
 college empl_not empl_low empl_med empl_high office_bef party_maj_left_bef party_maj_right_bef party_maj_center_bef party_maj_local_bef same_party1 same_party2 

 
local r=1
local s=1
foreach var of local pre {
   disp "Variable: `var'"
   
   *all
   reg `var' tt_cont_gt0 mv_t mv_t2 mv_t3, cluster(id_mayor)
   matrix balance[`r',1]=_b[tt_cont_gt0]
   matrix balance[`r'+1,1]=_se[tt_cont_gt0]
   matrix balance[49,1]=e(N)
   matrix pval[`s',1]= 2*ttail(e(df_r),abs(_b[tt_cont_gt0]/_se[tt_cont_gt0]))
   local r=`r'+2
   local s=`s'+1
}
gen N=.
label var N "Observations"

mat li balance, format(%9.3f)
outtable using TabA4, mat(balance) replace format(%9.3f) nobox center



local pre "NW NE CE SOU IS pop_census1991 alt extension gender agec born_reg secondary college empl_not empl_low empl_medium empl_high office_before party_maj_left_bef party_maj_right_bef party_maj_center_bef party_maj_local_bef same_party1 same_party2"

 matrix balance = J(49,2,.)
 matrix colnames balance  =  id_sample1 id_sample2 
 matrix rownames balance  =  NW . NE . CE . SOU . IS . Population . Altitude . Extension . gender . age . born_reg . secondary . /// 
 college . empl_not . empl_low . empl_med . empl_high . office_bef . party_maj_left_bef . party_maj_right_bef . party_maj_center_bef . party_maj_local_bef . same_party1 . same_party2 . N

 matrix pval = J(24,2,.)
 matrix rownames pval  =  NW NE CE SOU IS Population Altitude Extension gender age born_reg secondary /// 
 college empl_not empl_low empl_med empl_high office_bef party_maj_left_bef party_maj_right_bef party_maj_center_bef party_maj_local_bef same_party1 same_party2 

local r=1
local s=1
foreach var of local pre {
   disp "Variable: `var'"
   
   *id_sample1
   reg `var' tt_cont_gt0 mv_t mv_t2 mv_t3 if id_sample1==1, cluster(id_mayor)
   matrix balance[`r',1]=_b[tt_cont_gt0]
   matrix balance[`r'+1,1]=_se[tt_cont_gt0]
   matrix balance[49,1]=e(N)
   matrix pval[`s',1]= 2*ttail(e(df_r),abs(_b[tt_cont_gt0]/_se[tt_cont_gt0]))
   *id_sample1
   reg `var' tt_cont_gt1 mv_t mv_t2 mv_t3 if id_sample2==1, cluster(id_mayor)
   matrix balance[`r',2]=_b[tt_cont_gt1]
   matrix balance[`r'+1,2]=_se[tt_cont_gt1]
   matrix balance[49,2]=e(N)
  matrix pval[`s',2]= 2*ttail(e(df_r),abs(_b[tt_cont_gt1]/_se[tt_cont_gt1]))
   local r=`r'+2
   local s=`s'+1
}
label var N "Observations"

mat li balance, format(%9.3f)





* ------------------------------------------------------------------------------
**# d table 5 
* ---------------------------------------------------------------------------
use "$src/final.dta", clear

* sample selection
qui reg reb_final n_firms_bid winner_in_reg max_wins_std tt_cont term_limit mv_t $geog $time $auction $mayor $electoral if open_race==0 & number_rivals>0 & number_rivals!=.
gen sample1=e(sample)
keep if sample1==1

drop if mv_t==0 & tt_cont==1

*Show in tables only relevant variables
local keep "keep(ty_del tt_cont tt_party_cont term_limit gender age starting_value pop_res)"


** Level of competition: number of bidders
reg n_firms_bid tt_cont mv_t mv_t2 mv_t3, cluster(id_mayor)
su n_firms_bid if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2 using "$output/models/table5", `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons replace ct("N. of, bidders", RDD) label nonotes
reg n_firms_bid tt_cont mv_t mv_t2 mv_t3 term_limit $geog $time $auction $mayor $electoral, cluster(id_mayor)
su n_firms_bid if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2 using "$output/models/table5", `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons append ct("N. of, bidders", RDD) label nonotes 

** Level of competition: final rebate
reg reb_final tt_cont mv_t mv_t2 mv_t3, cluster(id_mayor)
su reb_final if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2 using "$output/models/table5", `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons append ct("Winning, rebate", OLS) label nonotes
reg reb_final tt_cont mv_t mv_t2 mv_t3 term_limit $geog $time $auction $mayor $electoral, cluster(id_mayor)
su reb_final if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2 using "$output/models/table5", `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons append ct("Winning, rebate", RDD) tex(nopretty) label 

* ------------------------------------------------------------------------------
**# d table  6
* ---------------------------------------------------------------------------
use "$src/final.dta", clear

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
outreg2 using "$output/models/table6", `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons replace ct("Winner, local", RDD) label 
reg winner_in_reg tt_cont mv_t mv_t2 mv_t3 term_limit $geog $time $auction $mayor $electoral, cluster(id_mayor)
su winner_in_reg if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2 using "$output/models/table6", `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons append ct("Winner, local", RDD) label


** Nature of competition: winning incumbency
reg max_wins_std tt_cont mv_t mv_t2 mv_t3 if year_election>=1998 & year_election<=2003, cluster(id_mayor)
su max_wins_std if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2 using "$output/models/table6", `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons append ct("Max % wins, same firm", OLS) label 
reg max_wins_std tt_cont mv_t mv_t2 mv_t3 term_limit $geog $time $auction $mayor $electoral if year_election>=1998 & year_election<=2003, cluster(id_mayor)
su max_wins_std if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2 using "$output/models/table6", `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons append ct("Max % wins, same firm", RDD) tex(nopretty) label 


* ------------------------------------------------------------------------------
**# e. data manipulation
* ----------------------------------------------------------------------------
use "$src/final.dta", clear

* sample selection
reg reb_final n_firms_bid winner_in_reg max_wins_std tt_cont term_limit mv_t $geog $time $auction $mayor $electoral if open_race==0 & number_rivals>0 & number_rivals!=.
gen sample1=e(sample)
keep if sample1==1

drop if mv_t==0 & tt_cont==1
keep if tag_term==1

 
** McCrary test

DCdensity mv_t, breakpoint(0) generate(Xj Yj r0 fhat se_fhat)
 
graph save "$output/figures/figure2", replace
graph export "$output/figures/figure2.png", replace

* ------------------------------------------------------------------------------
**# f. polynomial 2
* ----------------------------------------------------------------------------
* ------------------------------------------------------------------------------
**# f. table 5 
* ---------------------------------------------------------------------------
use "$src/final.dta", clear

* sample selection
qui reg reb_final n_firms_bid winner_in_reg max_wins_std tt_cont term_limit mv_t mv_t2 $geog $time $auction $mayor $electoral if open_race==0 & number_rivals>0 & number_rivals!=.
gen sample1=e(sample)
keep if sample1==1

drop if mv_t==0 & tt_cont==1

*Show in tables only relevant variables
local keep "keep(ty_del tt_cont tt_party_cont term_limit gender age starting_value pop_res)"


** Level of competition: number of bidders
reg n_firms_bid tt_cont mv_t mv_t2 , cluster(id_mayor)
su n_firms_bid if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2 using "$output/models/table5_2", `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons replace ct("N. of, bidders", RDD) label nonotes
reg n_firms_bid tt_cont mv_t mv_t2 term_limit $geog $time $auction $mayor $electoral, cluster(id_mayor)
su n_firms_bid if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2 using "$output/models/table5_2", `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons append ct("N. of, bidders", RDD) label nonotes 

** Level of competition: final rebate
reg reb_final tt_cont mv_t mv_t2, cluster(id_mayor)
su reb_final if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2 using "$output/models/table5_2", `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons append ct("Winning, rebate", OLS) label nonotes
reg reb_final tt_cont mv_t mv_t2 term_limit $geog $time $auction $mayor $electoral, cluster(id_mayor)
su reb_final if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2 using "$output/models/table5_2", `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons append ct("Winning, rebate", RDD) tex(nopretty) label 

* ------------------------------------------------------------------------------
**# f. table  6
* ---------------------------------------------------------------------------
use "$src/final.dta", clear

* sample selection
qui reg reb_final n_firms_bid winner_in_reg max_wins_std tt_cont term_limit mv_t mv_t2 $geog $time $auction $mayor $electoral if open_race==0 & number_rivals>0 & number_rivals!=.
gen sample1=e(sample)
keep if sample1==1

drop if mv_t==0 & tt_cont==1

replace winner_in_reg=winner_in_reg*100 
replace max_wins_std=max_wins_std*100

*Show in tables only relevant variables
local keep "keep(ty_del tt_cont tt_party_cont term_limit gender age starting_value pop_res)"

** Nature of competition: winner outsider
reg winner_in_reg tt_cont mv_t mv_t2, cluster(id_mayor)
su winner_in_reg if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2 using "$output/models/table6_2", `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons replace ct("Winner, local", RDD) label 
reg winner_in_reg tt_cont mv_t mv_t2  term_limit $geog $time $auction $mayor $electoral, cluster(id_mayor)
su winner_in_reg if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2 using "$output/models/table6_2", `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons append ct("Winner, local", RDD) label


** Nature of competition: winning incumbency
reg max_wins_std tt_cont mv_t mv_t2  if year_election>=1998 & year_election<=2003, cluster(id_mayor)
su max_wins_std if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2 using "$output/models/table6_2", `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons append ct("Max % wins, same firm", OLS) label 
reg max_wins_std tt_cont mv_t mv_t2  term_limit $geog $time $auction $mayor $electoral if year_election>=1998 & year_election<=2003, cluster(id_mayor)
su max_wins_std if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2 using "$output/models/table6_2", `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons append ct("Max % wins, same firm", RDD) tex(nopretty) label 



* ------------------------------------------------------------------------------
**# f. polynomial 4
* ----------------------------------------------------------------------------

* ------------------------------------------------------------------------------
**# f. table 5 
* ---------------------------------------------------------------------------
use "$src/final.dta", clear

* sample selection
qui reg reb_final n_firms_bid winner_in_reg max_wins_std tt_cont term_limit mv_t mv_t2 mv_t3 mv_t4 $geog $time $auction $mayor $electoral if open_race==0 & number_rivals>0 & number_rivals!=.
gen sample1=e(sample)
keep if sample1==1

drop if mv_t==0 & tt_cont==1

*Show in tables only relevant variables
local keep "keep(ty_del tt_cont tt_party_cont term_limit gender age starting_value pop_res)"


** Level of competition: number of bidders
reg n_firms_bid tt_cont mv_t mv_t2 mv_t3 mv_t4, cluster(id_mayor)
su n_firms_bid if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2 using "$output/models/table5_4", `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons replace ct("N. of, bidders", RDD) label nonotes
reg n_firms_bid tt_cont mv_t mv_t2 mv_t3 mv_t4 term_limit $geog $time $auction $mayor $electoral, cluster(id_mayor)
su n_firms_bid if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2 using "$output/models/table5_4", `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons append ct("N. of, bidders", RDD) label nonotes 

** Level of competition: final rebate
reg reb_final tt_cont mv_t mv_t2 mv_t3 mv_t4, cluster(id_mayor)
su reb_final if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2 using "$output/models/table5_4", `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons append ct("Winning, rebate", OLS) label nonotes
reg reb_final tt_cont mv_t mv_t2 mv_t3 mv_t4 term_limit $geog $time $auction $mayor $electoral, cluster(id_mayor)
su reb_final if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2 using "$output/models/table5_4", `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons append ct("Winning, rebate", RDD) tex(nopretty) label 

* ------------------------------------------------------------------------------
**# f. table  6
* ---------------------------------------------------------------------------
use "$src/final.dta", clear

* sample selection
qui reg reb_final n_firms_bid winner_in_reg max_wins_std tt_cont term_limit mv_t4 mv_t2 mv_t3 mv_t4 $geog $time $auction $mayor $electoral if open_race==0 & number_rivals>0 & number_rivals!=.
gen sample1=e(sample)
keep if sample1==1

drop if mv_t==0 & tt_cont==1

replace winner_in_reg=winner_in_reg*100 
replace max_wins_std=max_wins_std*100

*Show in tables only relevant variables
local keep "keep(ty_del tt_cont tt_party_cont term_limit gender age starting_value pop_res)"

** Nature of competition: winner outsider
reg winner_in_reg tt_cont mv_t mv_t2 mv_t3 mv_t4, cluster(id_mayor)
su winner_in_reg if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2 using "$output/models/table6_4", `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons replace ct("Winner, local", RDD) label 
reg winner_in_reg tt_cont mv_t mv_t2 mv_t3 mv_t4 term_limit $geog $time $auction $mayor $electoral, cluster(id_mayor)
su winner_in_reg if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2 using "$output/models/table6_4", `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons append ct("Winner, local", RDD) label


** Nature of competition: winning incumbency
reg max_wins_std tt_cont mv_t mv_t2 mv_t3 mv_t4 if year_election>=1998 & year_election<=2003, cluster(id_mayor)
su max_wins_std if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2 using "$output/models/table6_4", `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons append ct("Max % wins, same firm", OLS) label 
reg max_wins_std tt_cont mv_t mv_t2 mv_t3 mv_t4 term_limit $geog $time $auction $mayor $electoral if year_election>=1998 & year_election<=2003, cluster(id_mayor)
su max_wins_std if e(sample)
local nm= e(N_clust)
local mout=r(mean)
outreg2 using "$output/models/table6_4", `keep' bdec(3) addstat(Number of Mayors, `nm', Avg. outcome, `mout') nocons append ct("Max % wins, same firm", RDD) tex(nopretty) label 

