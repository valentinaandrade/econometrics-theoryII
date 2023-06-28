clear
clear matrix
set scheme s1color
set more off

cd $dir1

use mayoral_demos.dta, clear
keep if tt_cont==0

gen month_election=round((date_election-mdy(03,27,1993))/180)
replace month_election=month_election/2
label define month_election -10 "-5" -9 "" -8 "-4" -7 "" -6 "-3" -5 "" -4 "-2" -3 "" -2 "-1" -1 "" 0 "0" 1 "" 2 "1" 3 "" 4 "2" 5 "" 6 "3" 7 "" 8 "4"
label values month_election month_election 

keep if month_election>=-5 & month_election<=4

foreach var of varlist gender age born_reg secondary college empl_not empl_low empl_medium empl_high office_before party_maj_left_bef party_maj_right_bef party_maj_center_bef party_maj_local_bef same_party1 same_party2 {
  egen `var'_mean = mean(`var'), by(month_election)
}

replace gender_mean=. if gender_mean>0.3
twoway (lowess gender_mean month_election if date_election>=d(27mar1993), pstyle(p p3 p3) sort lcolor(blue)) /*
*/     (lowess gender_mean month_election if date_election<d(27mar1993), pstyle(p p3 p3) sort lcolor(red))  /*
*/     (scatter gender_mean month_election, msize(small) mlwidth(vthin) msymbol(circle_hollow) mcolor(gray)), /*
*/      xtitle("Distance from March 1993 (years)", size(small)) xlabel(-5 -4 -3 -2 -1 0 1 2 3 4, labsize(vsmall)) /*
*/      ytitle("Female") xline(0, lwidth(0.2) lcolor(black)) legend(label(1 "Post-reform") label(2 "Pre-reform") label(3 "Observed values") colgap(*3) width(100))
graph save FigA7_sex.gph, replace

twoway (lowess age_mean month_election if date_election>=d(27mar1993), pstyle(p p3 p3) lcolor(blue)) /*
*/     (lowess age_mean month_election if date_election<d(27mar1993), pstyle(p p3 p3) lcolor(red))  /*
*/     (scatter age_mean month_election, msize(small) msymb(circle) msymbol(circle_hollow) mcolor(gray)), /*
*/      xtitle("Distance from March 1993 (years)", size(small)) xlabel(-5 -4 -3 -2 -1 0 1 2 3 4, labsize(vsmall)) /*
*/      ytitle("Age") xline(0, lwidth(0.2) lcolor(black)) legend(label(1 "Post-reform") label(2 "Pre-reform") label(3 "Observed values") colgap(*3) width(100))
graph save FigA7_age.gph,  replace

replace born_reg_mean=. if born_reg_mean<0.6
twoway (lowess born_reg_mean month_election if date_election>=d(27mar1993) , pstyle(p p3 p3) lcolor(blue)) /*
*/     (lowess born_reg_mean month_election if date_election<d(27mar1993) , pstyle(p p3 p3) lcolor(red))  /*
*/     (scatter born_reg_mean month_election, msize(small) msymb(circle) msymbol(circle_hollow) mcolor(gray)), /*
*/      xtitle("Distance from March 1993 (years)", size(small)) xlabel(-5 -4 -3 -2 -1 0 1 2 3 4, labsize(vsmall)) /*
*/      ytitle("Local") xline(0, lwidth(0.2) lcolor(black)) legend(label(1 "Post-reform") label(2 "Pre-reform") label(3 "Observed values") colgap(*3) width(100))
graph save FigA7_out.gph,  replace

twoway (lowess secondary_mean month_election if date_election>=d(27mar1993) , pstyle(p p3 p3) lcolor(blue)) /*
*/     (lowess secondary_mean month_election if date_election<d(27mar1993) , pstyle(p p3 p3) lcolor(red))  /*
*/     (scatter secondary_mean month_election, msize(small) msymb(circle) msymbol(circle_hollow) mcolor(gray)), /*
*/      xtitle("Distance from March 1993 (years)", size(small)) xlabel(-5 -4 -3 -2 -1 0 1 2 3 4, labsize(vsmall)) /*
*/      ytitle("Secondary") xline(0, lwidth(0.2) lcolor(black)) legend(label(1 "Post-reform") label(2 "Pre-reform") label(3 "Observed values") colgap(*3) width(100))
graph save FigA7_secondary.gph,  replace

twoway (lowess college_mean month_election if date_election>=d(27mar1993) , pstyle(p p3 p3) lcolor(blue)) /*
*/     (lowess college_mean month_election if date_election<d(27mar1993) , pstyle(p p3 p3) lcolor(red))  /*
*/     (scatter college_mean month_election, msize(small) msymb(circle) msymbol(circle_hollow) mcolor(gray)), /*
*/      xtitle("Distance from March 1993 (years)", size(small)) xlabel(-5 -4 -3 -2 -1 0 1 2 3 4, labsize(vsmall)) /*
*/      ytitle("College") xline(0, lwidth(0.2) lcolor(black)) legend(label(1 "Post-reform") label(2 "Pre-reform") label(3 "Observed values") colgap(*3) width(100))
graph save FigA7_college.gph,  replace

twoway (lowess empl_not_mean month_election if date_election>=d(27mar1993) , pstyle(p p3 p3) lcolor(blue)) /*
*/     (lowess empl_not_mean month_election if date_election<d(27mar1993) , pstyle(p p3 p3) lcolor(red))  /*
*/     (scatter empl_not_mean month_election, msize(small) msymb(circle) msymbol(circle_hollow) mcolor(gray)), /*
*/      xtitle("Distance from March 1993 (years)", size(small)) xlabel(-5 -4 -3 -2 -1 0 1 2 3 4, labsize(vsmall)) /*
*/      ytitle("Not employed") xline(0, lwidth(0.2) lcolor(black)) legend(label(1 "Post-reform") label(2 "Pre-reform") label(3 "Observed values") colgap(*3) width(100))
graph save FigA7_emplno.gph,  replace

replace empl_low_mean=. if empl_low_mean>0.2
twoway (lowess empl_low_mean month_election if date_election>=d(27mar1993) , pstyle(p p3 p3) lcolor(blue)) /*
*/     (lowess empl_low_mean month_election if date_election<d(27mar1993) , pstyle(p p3 p3) lcolor(red))  /*
*/     (scatter empl_low_mean month_election, msize(small) msymb(circle) msymbol(circle_hollow) mcolor(gray)), /*
*/      xtitle("Distance from March 1993 (years)", size(small)) xlabel(-5 -4 -3 -2 -1 0 1 2 3 4, labsize(vsmall)) /*
*/      ytitle("Low-skilled") xline(0, lwidth(0.2) lcolor(black)) legend(label(1 "Post-reform") label(2 "Pre-reform") label(3 "Observed values") colgap(*3) width(100))
graph save FigA7_empll.gph,  replace

replace empl_medium_mean=. if empl_medium_mean>0.8
twoway (lowess empl_medium_mean month_election if date_election>=d(27mar1993) , pstyle(p p3 p3) lcolor(blue)) /*
*/     (lowess empl_medium_mean month_election if date_election<d(27mar1993) , pstyle(p p3 p3) lcolor(red))  /*
*/     (scatter empl_medium_mean month_election, msize(small) msymb(circle) msymbol(circle_hollow) mcolor(gray)), /*
*/      xtitle("Distance from March 1993 (years)", size(small)) xlabel(-5 -4 -3 -2 -1 0 1 2 3 4, labsize(vsmall)) /*
*/      ytitle("Medium-skilled") xline(0, lwidth(0.2) lcolor(black)) legend(label(1 "Post-reform") label(2 "Pre-reform") label(3 "Observed values") colgap(*3) width(100))
graph save FigA7_emplm.gph,  replace

replace empl_high_mean=. if empl_high_mean<0.2
twoway (lowess empl_high_mean month_election if date_election>=d(27mar1993) , pstyle(p p3 p3) lcolor(blue)) /*
*/     (lowess empl_high_mean month_election if date_election<d(27mar1993) , pstyle(p p3 p3) lcolor(red))  /*
*/     (scatter empl_high_mean month_election, msize(small) msymb(circle) msymbol(circle_hollow) mcolor(gray)), /*
*/      xtitle("Distance from March 1993 (years)", size(small)) xlabel(-5 -4 -3 -2 -1 0 1 2 3 4, labsize(vsmall)) /*
*/      ytitle("High-skilled") xline(0, lwidth(0.2) lcolor(black)) legend(label(1 "Post-reform") label(2 "Pre-reform") label(3 "Observed values") colgap(*3) width(100))
graph save FigA7_emplh.gph,  replace

twoway (lowess office_before_mean month_election if date_election>=d(27mar1993) , pstyle(p p3 p3) lcolor(blue)) /*
*/     (lowess office_before_mean month_election if date_election<d(27mar1993) , pstyle(p p3 p3) lcolor(red))  /*
*/     (scatter office_before_mean month_election, msize(small) msymb(circle) msymbol(circle_hollow) mcolor(gray)), /*
*/      xtitle("Distance from March 1993 (years)", size(small)) xlabel(-5 -4 -3 -2 -1 0 1 2 3 4, labsize(vsmall)) /*
*/      ytitle("Previous experience") xline(0, lwidth(0.2) lcolor(black)) legend(label(1 "Post-reform") label(2 "Pre-reform") label(3 "Observed values") colgap(*3) width(100))
graph save FigA7_before.gph,  replace

twoway (lowess party_maj_left_bef_mean month_election if date_election>=d(27mar1993) , pstyle(p p3 p3) lcolor(blue)) /*
*/     (lowess party_maj_left_bef_mean month_election if date_election<d(27mar1993) , pstyle(p p3 p3) lcolor(red))  /*
*/     (scatter party_maj_left_bef_mean month_election, msize(small) msymb(circle) msymbol(circle_hollow) mcolor(gray)), /*
*/      xtitle("Distance from March 1993 (years)", size(small)) xlabel(-5 -4 -3 -2 -1 0 1 2 3 4, labsize(vsmall)) /*
*/      ytitle("Party before - Left") xline(0, lwidth(0.2) lcolor(black)) legend(label(1 "Post-reform") label(2 "Pre-reform") label(3 "Observed values") colgap(*3) width(100))
graph save FigA7_left.gph,  replace

twoway (lowess party_maj_right_bef_mean month_election if date_election>=d(27mar1993) , pstyle(p p3 p3) lcolor(blue)) /*
*/     (lowess party_maj_right_bef_mean month_election if date_election<d(27mar1993) , pstyle(p p3 p3) lcolor(red))  /*
*/     (scatter party_maj_right_bef_mean month_election, msize(small) msymb(circle) msymbol(circle_hollow) mcolor(gray)), /*
*/      xtitle("Distance from March 1993 (years)", size(small)) xlabel(-5 -4 -3 -2 -1 0 1 2 3 4, labsize(vsmall)) /*
*/      ytitle("Party before - Right") xline(0, lwidth(0.2) lcolor(black)) legend(label(1 "Post-reform") label(2 "Pre-reform") label(3 "Observed values") colgap(*3) width(100))
graph save FigA7_right.gph,  replace

twoway (lowess party_maj_center_bef_mean month_election if date_election>=d(27mar1993) , pstyle(p p3 p3) lcolor(blue)) /*
*/     (lowess party_maj_center_bef_mean month_election if date_election<d(27mar1993) , pstyle(p p3 p3) lcolor(red))  /*
*/     (scatter party_maj_center_bef_mean month_election, msize(small) msymb(circle) msymbol(circle_hollow) mcolor(gray)), /*
*/      xtitle("Distance from March 1993 (years)", size(small)) xlabel(-5 -4 -3 -2 -1 0 1 2 3 4, labsize(vsmall)) /*
*/      ytitle("Party before - Center") xline(0, lwidth(0.2) lcolor(black)) legend(label(1 "Post-reform") label(2 "Pre-reform") label(3 "Observed values") colgap(*3) width(100))
graph save FigA7_center.gph,  replace

twoway (lowess party_maj_local_bef_mean month_election if date_election>=d(27mar1993) , pstyle(p p3 p3) lcolor(blue)) /*
*/     (lowess party_maj_local_bef_mean month_election if date_election<d(27mar1993) , pstyle(p p3 p3) lcolor(red))  /*
*/     (scatter party_maj_local_bef_mean month_election, msize(small) msymb(circle) msymbol(circle_hollow) mcolor(gray)), /*
*/      xtitle("Distance from March 1993 (years)", size(small)) xlabel(-5 -4 -3 -2 -1 0 1 2 3 4, labsize(vsmall)) /*
*/      ytitle("Party before - Local") xline(0, lwidth(0.2) lcolor(black)) legend(label(1 "Post-reform") label(2 "Pre-reform") label(3 "Observed values") colgap(*3) width(100))
graph save FigA7_local.gph,  replace

twoway (lowess same_party1_mean month_election if date_election>=d(27mar1993) , pstyle(p p3 p3) lcolor(blue)) /*
*/     (lowess same_party1_mean month_election if date_election<d(27mar1993) , pstyle(p p3 p3) lcolor(red))  /*
*/     (scatter same_party1_mean month_election, msize(small) msymb(circle) msymbol(circle_hollow) mcolor(gray)), /*
*/      xtitle("Distance from March 1993 (years)", size(small)) xlabel(-5 -4 -3 -2 -1 0 1 2 3 4, labsize(vsmall)) /*
*/      ytitle("Party majority before") xline(0, lwidth(0.2) lcolor(black)) legend(label(1 "Post-reform") label(2 "Pre-reform") label(3 "Observed values") colgap(*3) width(100))
graph save FigA7_same_party1.gph,  replace

twoway (lowess same_party2_mean month_election if date_election>=d(27mar1993) , pstyle(p p3 p3) lcolor(blue)) /*
*/     (lowess same_party2_mean month_election if date_election<d(27mar1993) , pstyle(p p3 p3) lcolor(red))  /*
*/     (scatter same_party2_mean month_election, msize(small) msymb(circle) msymbol(circle_hollow) mcolor(gray)), /*
*/      xtitle("Distance from March 1993 (years)", size(small)) xlabel(-5 -4 -3 -2 -1 0 1 2 3 4, labsize(vsmall)) /*
*/      ytitle("Party majority before") xline(0, lwidth(0.2) lcolor(black)) legend(label(1 "Post-reform") label(2 "Pre-reform") label(3 "Observed values") colgap(*3) width(100))
graph save FigA7_same_party2.gph,  replace
 
grc1leg FigA7_sex.gph FigA7_age.gph FigA7_out.gph FigA7_college.gph FigA7_emplno.gph FigA7_emplh.gph FigA7_before.gph /*
*/ FigA7_same_party1.gph, saving(FigA7.gph, replace)
graph export FigA7.eps, replace fontface(Times)

