clear
clear matrix
set scheme s1color
set more off

cd $dir1

use final.dta

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
grc1leg Fig1_n_firms_bid.gph Fig1_reb_final.gph Fig1_winner_in_reg.gph Fig1_max_wins_std.gph, saving(Fig1.gph, replace)
graph export Fig1.eps, replace fontface(Times)




