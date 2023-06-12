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

 
** McCrary test

DCdensity mv_t, breakpoint(0) generate(Xj Yj r0 fhat se_fhat)
 
graph save Fig2.gph, replace
graph export Fig2.eps, replace
