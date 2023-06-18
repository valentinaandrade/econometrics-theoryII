////////////////////////////////////////////////////////////////////////////////
/*									 TABLE 3								  */
////////////////////////////////////////////////////////////////////////////////

clear
set more off, permanently

* Ouput stored in "falsification.tex"
// ---------------------------------------------------------------------------//
// 		        		  		First Stages						       	  //	
// ---------------------------------------------------------------------------//

use "$dir/Data/data1940", clear
replace newbasesample=0 if country=="AUSTRIA" | country=="BANGLADESH" | country=="MALAYSIA" | country=="RUSSIAN FEDERATION" // Same sample as the second stage in the long differences. 
reg changelogpopulation changemortality if newbasesample==1  ,  cluster(ctrycluster)
outreg2 using Results/falsification.tex, dec(3) /*noas*/   nocon label less(0) ct(1) replace noaster
reg changelogpopulation changemortality if newbasesample==1 & startrich~=1 ,  cluster(ctrycluster)
outreg2 using Results/falsification.tex, dec(3) /*noas*/   nocon label less(0) ct(2) append noaster

// ---------------------------------------------------------------------------//
// 		        		  		Reduced Form						       	  //	
// ---------------------------------------------------------------------------//

use "$dir/Data/data1940", clear

reg changepconflictCOW2 changemortality if newbasesample==1  ,  cluster(ctrycluster)
outreg2 using Results/falsification.tex, dec(3) /*noas*/   nocon label less(0) ct(3) append noaster
reg changepconflictCOW2 changemortality if newbasesample==1 & startrich~=1 ,  cluster(ctrycluster)
outreg2 using Results/falsification.tex, dec(3) /*noas*/   nocon label less(0) ct(4) append noaster

// ---------------------------------------------------------------------------//
// 		        		  		Falsification						       	  //	
// ---------------------------------------------------------------------------//

reg changepconflictCOW2_1900_40 changemortality if newbasesample==1 ,   cluster(ctrycluster)
outreg2 using Results/falsification.tex, dec(3) /*noas*/   nocon label less(0) ct(5) append noaster
reg changepconflictCOW2_1900_40 changemortality if  newbasesample==1 & startrich~=1 ,   cluster(ctrycluster)
outreg2 using Results/falsification.tex, dec(3) /*noas*/   nocon label less(0) ct(6) append noaster
reg changelogpopulation_1900_40 changemortality if newbasesample==1 ,   cluster(ctrycluster)
outreg2 using Results/falsification.tex, dec(3) /*noas*/   nocon label less(0) ct(7) append noaster
reg changelogpopulation_1900_40 changemortality if  newbasesample==1 & startrich~=1 ,   cluster(ctrycluster)
outreg2 using Results/falsification.tex, dec(3) /*noas*/   nocon label less(0) ct(8) append noaster

cap erase Results/falsification.txt
