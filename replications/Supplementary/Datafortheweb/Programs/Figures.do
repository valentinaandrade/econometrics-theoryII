////////////////////////////////////////////////////////////////////////////////
/*							    	GRAPHS								  */
////////////////////////////////////////////////////////////////////////////////

clear
set more off, permanently

// ---------------------------------------------------------------------------//
// 							  		 Figure 1								  //
// ---------------------------------------------------------------------------//

// Reduced forms and falsifications  
use "$dir/Data/data1940", clear 

gen newbasesample_nomex=(newbasesample==1 & country!="MEXICO")

// Conflict and predicted mortality, base sample
twoway(scatter changepconflictCOW2 changemortality if newbasesample==1 & country=="MEXICO", mlabel(shortnam) mlabpos(12) msymbol(diamond) msize(medsmall) mlabsize(small) mcolor(gray*2) mlabcolor(gray*2)) ///
 (scatter changepconflictCOW2 changemortality if newbasesample_nomex==1, mlabel(shortnam) msize(tiny) mlabsize(vsmall) mcolor(gray) mlabcolor(gray)) ///
 (lfit changepconflictCOW2 changemortality if newbasesample==1, lpattern(solid) lcolor(black)), ///
 ytitle("") xtitle("Change in predicted mortality, 1940-1980", size(small)) legend(off) graphregion(fcolor(white)) ///
 ylabel(, labsize(small)) xlabel(, labsize(small)) ///
 title("1c. Change in fraction of decade in conflict, 1940-1980", size(small) color(black)) subtitle("Base Sample", size(small)) saving(Results/3a, replace)

// Conflict and predicted mortality, Low and Middle income
twoway(scatter changepconflictCOW2 changemortality if newbasesample==1 & startrich~=1 & country=="MEXICO", mlabel(shortnam) mlabpos(12) msymbol(diamond) msize(medsmall) mlabsize(small) mcolor(gray*2) mlabcolor(gray*2)) ///
(scatter changepconflictCOW2 changemortality if newbasesample_nomex==1 & startrich~=1, mlabel(shortnam) msize(tiny) mlabsize(vsmall) mcolor(gray) mlabcolor(gray)) (lfit changepconflictCOW2 changemortality if newbasesample==1 & startrich~=1, lpattern(solid) lcolor(black)), ///
 ytitle("") xtitle("Change in predicted mortality, 1940-1980", size(small)) legend(off) graphregion(fcolor(white)) ///
  ylabel(, labsize(small)) xlabel(, labsize(small)) ///
 title("1d. Change in fraction of decade in conflict, 1940-1980", size(small) color(black)) subtitle("Low and Middle Income Countries", size(small)) saving(Results/3b, replace)
 
// Falsification, base sample
twoway(scatter changepconflictCOW2_1900_40 changemortality if newbasesample==1 & country=="MEXICO", mlabel(shortnam) mlabpos(12) msymbol(diamond) msize(medsmall) mlabsize(small) mcolor(gray*2) mlabcolor(gray*2)) ///
(scatter changepconflictCOW2_1900_40 changemortality if newbasesample_nomex==1, mlabel(shortnam) msize(tiny) mlabsize(vsmall) mcolor(gray) mlabcolor(gray)) (lfit changepconflictCOW2_1900_40 changemortality if newbasesample==1, lpattern(solid) lcolor(black)), ///
 ytitle("") xtitle("Change in predicted mortality, 1940-1980", size(small)) legend(off) graphregion(fcolor(white)) ///
  ylabel(, labsize(small)) xlabel(, labsize(small)) ///
 title("1e. Change in fraction of decade in conflict 1900-1940", size(small) color(black)) subtitle("Base Sample", size(small)) saving(Results/3c, replace)

// Falsification, low and Middle income
twoway(scatter changepconflictCOW2_1900_40 changemortality if newbasesample==1 & startrich~=1 & country=="MEXICO", mlabel(shortnam) mlabpos(12) msymbol(diamond) msize(medsmall) mlabsize(small) mcolor(gray*2) mlabcolor(gray*2)) ///
(scatter changepconflictCOW2_1900_40 changemortality if newbasesample_nomex==1 & startrich~=1, mlabel(shortnam) msize(tiny) mlabsize(vsmall) mcolor(gray) mlabcolor(gray)) (lfit changepconflictCOW2_1900_40 changemortality if newbasesample==1 & startrich~=1, lpattern(solid) lcolor(black)), ///
 ytitle("") xtitle("Change in predicted mortality, 1940-1980", size(small)) legend(off) graphregion(fcolor(white)) ///
 ylabel(, labsize(small)) xlabel(, labsize(small)) ///
 title("1f. Change in fraction of decade in conflict 1900-1940", size(small) color(black)) subtitle("Low and Middle Income Countries", size(small)) saving(Results/3d, replace)

// First stages, base sample
twoway(scatter changelogpopulation changemortality if newbasesample==1 & country=="MEXICO", mlabel(shortnam) mlabpos(9) msymbol(diamond) msize(medsmall) mlabsize(small) mcolor(gray*2) mlabcolor(gray*2)) ///
(scatter changelogpopulation changemortality if newbasesample_nomex==1, mlabel(shortnam) msize(tiny) mlabsize(vsmall) mcolor(gray) mlabcolor(gray)) (lfit changelogpopulation changemortality if newbasesample==1, lpattern(solid) lcolor(black)), ///
 ytitle("") xtitle("Change in predicted mortality, 1940-1980", size(small)) legend(off) graphregion(fcolor(white)) ///
  ylabel(, labsize(small)) xlabel(, labsize(small)) ///
 title("1a. Change in log population 1940-1980", size(small) color(black)) subtitle("Base Sample", size(small)) saving(Results/3e, replace)

// First stages, low and Middle income
twoway(scatter changelogpopulation changemortality if newbasesample==1 & startrich~=1 & country=="MEXICO", mlabel(shortnam) mlabpos(9) msymbol(diamond) msize(medsmall) mlabsize(small) mcolor(gray*2) mlabcolor(gray*2)) ///
(scatter changelogpopulation changemortality if newbasesample_nomex==1 & startrich~=1, mlabel(shortnam) msize(tiny) mlabsize(vsmall) mcolor(gray) mlabcolor(gray)) (lfit changelogpopulation changemortality if newbasesample==1 & startrich~=1, lpattern(solid) lcolor(black)), ///
 ytitle("") xtitle("Change in predicted mortality, 1940-1980", size(small)) legend(off) graphregion(fcolor(white)) ///
 ylabel(, labsize(small)) xlabel(, labsize(small)) ///
 title("1b. Change in log population 1940-1980", size(small) color(black)) subtitle("Low and Middle Income Countries", size(small)) saving(Results/3f, replace)
 
gr combine Results/3e.gph Results/3f.gph Results/3a.gph Results/3b.gph Results/3c.gph Results/3d.gph, title("", size(medium)) graphregion(fcolor(white)) cols(2) ysize(11) xsize(9.5)
graph export Results/Figure1new.eps, replace as(eps)

cap erase Results/3a.gph
cap erase Results/3b.gph
cap erase Results/3c.gph
cap erase Results/3d.gph
cap erase Results/3e.gph
cap erase Results/3f.gph

