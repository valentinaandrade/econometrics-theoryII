clear
clear matrix
set scheme s1color
set more off

cd $dir1

use final.dta, clear

* sample selection
reg reb_final n_firms_bid max_wins_std tt_cont ty_del term_limit mv_t $geog $time $auction $mayor $electoral if open_race==0 & number_rivals>0 & number_rivals!=. 
gen sample1=e(sample)
keep if sample1==1

drop if mv_t==0 & tt_cont==1


gen above=mv_t>=0 

* 
egen group=cut(mv_t),  at(-80(1)80)
egen mv_t_grp=mean(group),by(group)


egen tag_term=tag(id_city id_mayor year_election)
keep if tag_term==1

foreach var of varlist gender age born_reg secondary college empl_not empl_low empl_medium empl_high office_before party_maj_left_bef party_maj_right_bef party_maj_center_bef party_maj_local_bef same_party1 same_party2 {
egen `var'_mean = mean(`var'), by(mv_t_grp)
}


** Mayor characteristics
keep if mv_t>=-10 & mv_t<=10
gen mv_tXabove=mv_t*above

local nino "gender age born_reg secondary college empl_not empl_low empl_medium empl_high office_before party_maj_left_bef party_maj_right_bef party_maj_center_bef party_maj_local_bef same_party1 same_party2"


local i=1
foreach var of local nino {


if `i'== 1 {
 local svar "Female"
 local ylabel "0(0.25)1"
 }

if `i'== 2 {
 local svar "Age"
 local ylabel "42(8)62"
 }


 if `i'== 3 {
 local svar "Local"
 local ylabel "0(0.25)1"
 }

if `i'== 4 {
 local svar "Secondary"
 local ylabel "0(0.25)1"
 }
 

 if `i'== 5 {
 local svar "College"
 local ylabel "0(0.25)1"
 }


 if `i'== 6 {
 local svar "Not employed"
 local ylabel "0(0.25)1"
 }

if `i'== 7 {
 local svar "Low-skilled"
 local ylabel "0(0.25)1"
 }

 if `i'== 8 {
 local svar "Medium-skilled"
 local ylabel "0(0.25)1"
 }

 if `i'== 9 {
 local svar "High-skilled"
 local ylabel "0(0.25)1"
 }

 if `i'== 10 {
 local svar "Previuous experience"
 local ylabel "0(0.25)1"
 }

 if `i'== 11 {
 local svar "Party before - Left"
 local ylabel "0(0.25)1"
 }

 
 
 if `i'== 12 {
 local svar "Party before - Right"
 local ylabel "0(0.25)1"
 }

 if `i'== 13 {
 local svar "Party before - Center"
 local ylabel "0(0.25)1"
 }

 
 if `i'== 14 {
 local svar "Party before - Local"
 local ylabel "0(0.25)1"
 }
 
 if `i'== 14 {
 local svar "Party majority before"
 local ylabel "0(0.25)1"
 }
 
 if `i'== 14 {
 local svar "Party majority before"
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
*/	   xtitle(Margin of victory, size(medlarge)) xline(0, lwidth(0.2) lcolor(black)) xscale(range(-10 10)) xlabel(-10 -5 0 5 10) /*
*/	   legend(label(1 "First term") label(2 "Higher term")  label(5 "Observed values") colgap(*3) width(100) order(1 2 5)) /*
*/     saving(FigA6_`var'.gph, replace) nodraw
drop ciccio* ciccia* 

local i=`i'+1

}


grc1leg FigA6_gender.gph FigA6_age.gph FigA6_born_reg.gph FigA6_college.gph FigA6_empl_not.gph FigA6_empl_high.gph FigA6_office_before.gph FigA6_same_party1.gph
graph export FigA6.eps, replace fontface(Times)


