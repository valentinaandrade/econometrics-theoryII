clear
clear matrix
set scheme s1color
set more off

cd $dir1

use final.dta, clear

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
outtable using TabA4, mat(balance) replace format(%9.3f) nobox center
