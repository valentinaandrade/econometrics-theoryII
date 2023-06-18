////////////////////////////////////////////////////////////////////////////////
/*							    	TABLE A21								  */
////////////////////////////////////////////////////////////////////////////////

clear
set more off, permanently

// ---------------------------------------------------------------------------//
// 		        		  			Panel							       	  //	
// ---------------------------------------------------------------------------//

clear
use "$DATA"
sort country year
by country: replace yr_sch=yr_sch[_n+1] if missing(yr_sch)
by country: replace agri=agri[_n+2] if missing(agri)
bys country: replace ETHDOM = ETHDOM[_n+2] if year==1940
replace avpolity506070 = avpolity506070[_n+1] if year==1940

cap erase Results/sample_p1_v2.txt
cap erase Results/sample_p1_v2.tex
cap erase Results/sample_p2_v2.txt
cap erase Results/sample_p2_v2.tex

foreach x of varlist area climclip soilclip avgclip average_cereals agri yr_sch xconst polity_corr {
bys year: egen `x'_med = pctile(`x') if !missing(`x'), p(50)
gen junk_`x' = `x'_med if year==1940
replace `x'_med = junk_`x'
drop junk_`x'
gen `x'_junk =.
replace `x'_junk = 1 if `x'>=`x'_med & !missing(`x')
replace `x'_junk = 0 if `x'<`x'_med & !missing(`x')
bys country: egen `x'_above= max(`x'_junk)
drop `x'_junk

xtivreg2 propconflictCOW2 yr1940- yr1980 (logmaddpop=compsjmhatit) if year>1930 & year<1990 & `x'_above==1 ,   fe cluster(ctrycluster)
outreg2 using Results/sample_p1_v2.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust))   ctitle("`x'") append nocons label noaster

xtivreg2 propconflictCOW2 yr1940- yr1980 (logmaddpop=compsjmhatit) if year>1930 & year<1990 & `x'_above==0 ,   fe cluster(ctrycluster)
outreg2 using Results/sample_p2_v2.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  addstat (Number of clusters, e(N_clust))   ctitle("`x'") append nocons label noaster
}

cap erase Results/sample_p1_v2.txt
cap erase Results/sample_p2_v2.txt
