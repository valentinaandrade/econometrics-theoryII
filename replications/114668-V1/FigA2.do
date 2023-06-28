clear
clear matrix
set scheme s1color
set more off

cd $dir1

use final.dta, clear

rename reb_final rebate
rename n_firms_bid nbid
rename reb_min minreb
rename reb_max maxreb

* Discretization and collapse

* Scatter

egen group=cut(nbid),  at(10(5)90)
egen nbid_re=mean(nbid),by(group)


gen minreb_se=minreb
gen rebate_se=rebate
*gen  soglia_se=soglia
gen  maxreb_se=maxreb
gen n=1


collapse (mean) minreb rebate   maxreb (sem) minreb_se rebate_se  maxreb_se   , by(nbid_re)

local pippo "minreb rebate  maxreb"



foreach var of local pippo{

bysort nbid_re : gen l_`var'=`var'-1.96*`var'_se
bysort nbid_re : gen u_`var'=`var'+1.96*`var'_se

}


*Picture:

twoway (scatter minreb nbid,  m(Oh) mc(red)) ///
(rspike l_minreb u_minreb nbid, lwidth(thin) color(red))   ///
(scatter rebate nbid,  m(Th) mc(red)) /// 
(rspike l_rebate u_rebate nbid, lwidth(thin) color(red))  /// 
(scatter maxreb nbid,  m(Dh) mc(red)) ///
(rspike l_maxreb u_maxreb nbid, lwidth(thin) color(red)),   ///
ylabel(5(5)30)  xtitle("N. of bidders") l2title("Winning rebate (%)")  xlabel(10(10)90) /// 
legend(order(1 "Min. rebate" 3 "Winning rebate" 5 "Max. rebate")  rows(1) pos(12) region(lwidth(none))) title("Full sample") ///
 saving(nbid, replace)
 
 
 
 
 
use final.dta, clear

* sample selection
reg reb_final n_firms_bid winner_in_reg max_wins_std tt_cont ty_del term_limit $geog $time $auction $mayor $electoral
gen sample1=e(sample)
keep if sample1==1

keep  if  starting_value<5

rename reb_final rebate
rename n_firms_bid nbid
rename reb_min minreb
rename reb_max maxreb


* Discretization and collapse
*Scatter

egen group=cut(nbid),  at(10(5)90)
egen nbid_re=mean(nbid),by(group)


gen minreb_se=minreb
gen rebate_se=rebate
*gen  soglia_se=soglia
gen  maxreb_se=maxreb
gen n=1


collapse (mean) minreb rebate   maxreb (sem) minreb_se rebate_se  maxreb_se   , by(nbid_re)

local pippo "minreb rebate  maxreb"



foreach var of local pippo{

bysort nbid_re : gen l_`var'=`var'-1.96*`var'_se
bysort nbid_re : gen u_`var'=`var'+1.96*`var'_se

}


*Picture:

twoway (scatter minreb nbid,  m(Oh) mc(red)) ///
(rspike l_minreb u_minreb nbid, lwidth(thin) color(red))   ///
(scatter rebate nbid,  m(Th) mc(red)) /// 
(rspike l_rebate u_rebate nbid, lwidth(thin) color(red))  /// 
(scatter maxreb nbid,  m(Dh) mc(red)) ///
(rspike l_maxreb u_maxreb nbid, lwidth(thin) color(red)),   ///
ylabel(5(5)30)  xtitle("N. of bidders") l2title("Winning rebate (%)")  xlabel(10(10)90) /// 
legend(order(1 "Min. rebate" 3 "Winning rebate" 5 "Max. rebate")  rows(1) pos(12) region(lwidth(none))) title("Small Works") ///
 saving(nbid_s, replace)
 
 
 
gr combine nbid.gph nbid_s.gph, cols(2)
graph export FigA2.eps, replace logo(off) fontface(Times)

