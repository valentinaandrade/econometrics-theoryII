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
matrix rownames robu  =  pre . asy . fourth . llr_ob . 

local out "n_firms_bid reb_final winner_in_reg max_wins_std"


local i=1
foreach var of local out {

if "`out'"=="max_wins_std" {
local if="if year_election>=1998 & year_election<=2003"
}
else {
local if=""
}

* With predetermined controls only
reg `var' tt_cont mv_t mv_t2 mv_t3 term_limit $predeter `if', cluster(id_mayor)
	matrix robu[1,`i']=_b[tt_cont]
	matrix robu[2,`i']=_se[tt_cont]

* Asymmetric (LLR)
reg `var' tt_cont tt_contXmv_t tt_contXmv_t2 tt_contXmv_t3 mv_t mv_t2 mv_t3 term_limit $geog $time $auction $mayor $electoral `if', cluster(id_mayor)
	matrix robu[3,`i']=_b[tt_cont]
	matrix robu[4,`i']=_se[tt_cont]

* 4th order polynomial
reg `var' tt_cont mv_t mv_t2 mv_t3 mv_t4 term_limit $geog $time $auction $mayor $electoral `if', cluster(id_mayor)
	matrix robu[5,`i']=_b[tt_cont]
	matrix robu[6,`i']=_se[tt_cont]

* Optimal bandwidth
preserve
qui rdbwselect `var' mv_t `if',  bwselect(IK)
keep if mv_t>=-(e(h_IK)) & mv_t<=e(h_IK) 

*LLR
reg `var' tt_cont mv_t  tt_contXmv_t term_limit $geog $time $auction $mayor $electoral `if', cluster(id_mayor)  
	matrix robu[7,`i']=_b[tt_cont]
	matrix robu[8,`i']=_se[tt_cont]
restore

local i=`i'+1

}



* Estimated coefficients
mat li robu, format(%9.3f)
outtable using TabA2,mat(robu) replace format(%9.3f) nobox center
*Note: stars are not reported in the table. We manually put them from the regressions
