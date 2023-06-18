clear
clear matrix
set scheme s1color
set more off

cd $dir1

use final.dta, clear

*sample selection:
reg reb_final n_firms_bid winner_in_reg max_wins_std tt_cont ty_del term_limit mv_t $geog $time $auction $mayor $electoral if open_race==0 & number_rivals>0 & number_rivals!=.
gen sample1=e(sample)
keep if sample1==1

replace winner_in_reg=winner_in_reg*100 
replace max_wins_std=max_wins_std*100

drop if mv_t==0 & tt_cont==1

matrix robu = J(8,4,.)
matrix colnames robu  =  n_firms_bid reb_final  winner_in_reg max_wins_std
matrix rownames robu  =  ten_mv_gr0 . te_mv_le0 . cten_mv_gr0 . cte_mv_le0 .

* Placebo tests (median above and below)

*above
preserve

keep if  mv_t>=0
su mv_t , de
gen mv_f=mv_t
replace mv_f=mv_t-24.5 if mv_t>=24.5 & mv_t!=.
replace mv_f=-1*mv_t if mv_t<24.5 & mv_t!=.
gen tt_cont_gt0_f=mv_f>=0 & mv_f!=.
gen mv_f2=mv_f^2
gen mv_f3=mv_f^3

local out "n_firms_bid reb_final  winner_in_reg"
local i=1
foreach var of local out{

*Only controlling for TL
reg `var' tt_cont_gt0_f term_limit mv_f mv_f2 mv_f3  , cluster(id_mayor)
	matrix robu[1,`i']=_b[tt_cont_gt0_f]
	matrix robu[2,`i']=_se[tt_cont_gt0_f]
local i=`i'+1

}


*Max wins:
*Only controlling for TL
reg max_wins_std tt_cont_gt0_f term_limit mv_f mv_f2 mv_f3  if year_election>=1998 & year_election<=2003, cluster(id_mayor)
	matrix robu[1,4]=_b[tt_cont_gt0_f]
	matrix robu[2,4]=_se[tt_cont_gt0_f]

restore

*below

preserve
keep if  mv_t<0
su mv_t , de
gen mv_f=mv_t
replace mv_f=-1*mv_t if mv_t>=-12
replace mv_f=mv_t+12 if mv_t>=-12 & mv_t!=.
gen tt_cont_gt0_f=mv_f>=0 & mv_f!=.
gen mv_f2=mv_f^2
gen mv_f3=mv_f^3
gen mv_f4=mv_f^4
gen tt_cont_gt0_fXmv_f=tt_cont_gt0_f*mv_f
gen tt_cont_gt0_fXmv_f2=tt_cont_gt0_f*mv_f2
gen tt_cont_gt0_fXmv_f3=tt_cont_gt0_f*mv_f3
gen tt_cont_gt0_fXmv_f4=tt_cont_gt0_f*mv_f4



local out "n_firms_bid reb_final  winner_in_reg"
local i=1
foreach var of local out{

*Only controlling for TL
reg `var' tt_cont_gt0_f term_limit mv_f mv_f2 mv_f3  , cluster(id_mayor)
	matrix robu[3,`i']=_b[tt_cont_gt0_f]
	matrix robu[4,`i']=_se[tt_cont_gt0_f]
local i=`i'+1

}


*Max wins:
*Only controlling for TL
reg max_wins_std tt_cont_gt0_f term_limit mv_f mv_f2 mv_f3  if year_election>=1998 & year_election<=2003, cluster(id_mayor)
	matrix robu[3,4]=_b[tt_cont_gt0_f]
	matrix robu[4,4]=_se[tt_cont_gt0_f]

restore



* Placebo tests adding controls as in the main estimates this is what reported in the paper 
*above
preserve

keep if  mv_t>=0
su mv_t , de
gen mv_f=mv_t
replace mv_f=mv_t-24.5 if mv_t>=24.5 & mv_t!=.
replace mv_f=-1*mv_t if mv_t<24.5 & mv_t!=.
gen tt_cont_gt0_f=mv_f>=0 & mv_f!=.
gen mv_f2=mv_f^2
gen mv_f3=mv_f^3



local out "n_firms_bid reb_final  winner_in_reg"
local i=1
foreach var of local out{

*Only controlling for TL
reg `var' tt_cont_gt0_f term_limit mv_f mv_f2 mv_f3  $geog $time $auction $mayor $electoral, cluster(id_mayor)
	matrix robu[1+4,`i']=_b[tt_cont_gt0_f]
	matrix robu[2+4,`i']=_se[tt_cont_gt0_f]
local i=`i'+1

}


*Max wins:
*Only controlling for TL
reg max_wins_std tt_cont_gt0_f term_limit mv_f mv_f2 mv_f3 $geog $time $auction $mayor $electoral if year_election>=1998 & year_election<=2003, cluster(id_mayor)
	matrix robu[1+4,4]=_b[tt_cont_gt0_f]
	matrix robu[2+4,4]=_se[tt_cont_gt0_f]

restore

*below

preserve
keep if  mv_t<0
su mv_t , de
gen mv_f=mv_t
replace mv_f=-1*mv_t if mv_t>=-12
replace mv_f=mv_t+12 if mv_t>=-12 & mv_t!=.
gen tt_cont_gt0_f=mv_f>=0 & mv_f!=.
gen mv_f2=mv_f^2
gen mv_f3=mv_f^3
gen mv_f4=mv_f^4
gen tt_cont_gt0_fXmv_f=tt_cont_gt0_f*mv_f
gen tt_cont_gt0_fXmv_f2=tt_cont_gt0_f*mv_f2
gen tt_cont_gt0_fXmv_f3=tt_cont_gt0_f*mv_f3
gen tt_cont_gt0_fXmv_f4=tt_cont_gt0_f*mv_f4



local out "n_firms_bid reb_final  winner_in_reg"
local i=1
foreach var of local out{

*Only controlling for TL
reg `var' tt_cont_gt0_f term_limit mv_f mv_f2 mv_f3 $geog $time $auction $mayor $electoral , cluster(id_mayor)
	matrix robu[3+4,`i']=_b[tt_cont_gt0_f]
	matrix robu[4+4,`i']=_se[tt_cont_gt0_f]
local i=`i'+1

}


*Max wins:
*Only controlling for TL
reg max_wins_std tt_cont_gt0_f term_limit mv_f mv_f2 mv_f3 $geog $time $auction $mayor $electoral if year_election>=1998 & year_election<=2003, cluster(id_mayor)
	matrix robu[3+4,4]=_b[tt_cont_gt0_f]
	matrix robu[4+4,4]=_se[tt_cont_gt0_f]

restore


mat li robu, format(%9.3f)
outtable using TabA3,mat(robu) replace format(%9.3f) nobox center





