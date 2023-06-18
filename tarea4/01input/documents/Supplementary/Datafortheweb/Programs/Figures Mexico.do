////////////////////////////////////////////////////////////////////////////////
/*								MEXICO:	FIGURE								  */
////////////////////////////////////////////////////////////////////////////////

clear
set more off, permanently

// ---------------------------------------------------------------------------//
// 				PANEL A: Log pop and modified predicted mortality			  //	
// ---------------------------------------------------------------------------//

clear
use "$MEX"

binscatter corr_cam4060 index_mean, mcolor(gray) lcolor(black) ytitle("") xtitle("Change in predicted mortality (Mexico), 1940-1960", size(big)) legend(off) graphregion(fcolor(white)) ///
	ylabel(, labsize(small)) xlabel(, labsize(medium)) title("2a. Change in log Population, 1940-1960", size(big) color(black)) subtitle("Base Sample, Binned", size(small)) ///
	saving(Results/2a, replace)
	
// ---------------------------------------------------------------------------//
// 				PANEL B: Log pop and modified predicted mortality			  //	
// ---------------------------------------------------------------------------//

binscatter totalpcviolencia index_mean, mcolor(gray) lcolor(black) ytitle("") xtitle("Change in predicted mortality (Mexico), 1940-1960", size(big)) legend(off) graphregion(fcolor(white)) ///
	ylabel(, labsize(small)) xlabel(, labsize(medium)) title("2b. Change in Violent Protests, 1940-1960", size(big) color(black)) subtitle("Base Sample, Binned", size(small)) ///
	saving(Results/2b, replace)
	
gr combine Results/2a.gph Results/2b.gph, title("", size(big)) graphregion(fcolor(white)) cols(2) ysize(4) xsize(7)
graph export Results/Figure2new.eps, replace as(eps)

cap erase Results/2a.gph
cap erase Results/2b.gph

