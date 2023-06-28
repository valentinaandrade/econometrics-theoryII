clear
clear matrix
set scheme s1color
set more off

cd $dir1

use final.dta, clear

foreach var of varlist max_wins_std winner_in_city winner_in_prov winner_in_reg {
   replace `var'=`var'*100
}

** auction characteristics

statsmat n_firms_bid reb_final max_wins_std winner_in_city winner_in_prov winner_in_reg /*
*/ direct_nego_gr /* 
*/ starting_value obj_work_road obj_work_school obj_work_build obj_work_house obj_work_art/*
*/ obj_work_other year2000-year2005, stat(mean sd min p25 p50 p75 max) /*
*/ listwise matrix(Tab2) format(%9.2f)
outtable using Tab2, mat(Tab2) replace nobox format (%9.2f) label
sum n_firms_bid
