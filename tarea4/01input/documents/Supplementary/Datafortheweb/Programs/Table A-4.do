////////////////////////////////////////////////////////////////////////////////
/*							    	TABLE A4								  */
////////////////////////////////////////////////////////////////////////////////

clear
set more off, permanently

// ---------------------------------------------------------------------------//
// 		        		  	Long differences						       	  //	
// ---------------------------------------------------------------------------//

clear 
use "$DATA"

keep if newsample40_COW==1 & (year==1940 | year==1980)
acreg propconflictCOW2 logmaddpop  yr1940, id(countrynum) latitude(cen_lat) longitude(cen_lon) spatial dist(9684.715) time(year) pfe1(countrynum)
outreg2 using Results/spatial_p1.tex , keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  ctitle("1") replace nocons label noaster
acreg propconflictCOW2 yr1940 (logmaddpop = compsjmhatit), id(countrynum) latitude(cen_lat) longitude(cen_lon) spatial dist(9684.715) time(year) pfe1(countrynum)
outreg2 using Results/spatial_p1.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  ctitle("2") append nocons label noaster

// ---------------------------------------------------------------------------//
// 		        		  			Panel							       	  //	
// ---------------------------------------------------------------------------//

clear 
use "$DATA"

keep if year>=1940 & year<=1980 
acreg propconflictCOW2 logmaddpop  yr1940 yr1950  yr1960 yr1970 yr1980, id(countrynum) latitude(cen_lat) longitude(cen_lon) spatial dist(9684.715) time(year) pfe1(countrynum)
outreg2 using Results/spatial_p2.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  ctitle("1") replace nocons label noaster
acreg propconflictCOW2 yr1940 yr1950 yr1960 yr1970 (logmaddpop = compsjmhatit), id(countrynum) latitude(cen_lat) longitude(cen_lon) spatial dist(9684.715) time(year) pfe1(countrynum)
outreg2 using Results/spatial_p2.tex, keep(logmaddpop) tex(frag) nor2 dec(3) /*noas*/  ctitle("2")  append nocons label noaster

cap erase Results/spatial_p2.txt
cap erase Results/spatial_p1.txt
