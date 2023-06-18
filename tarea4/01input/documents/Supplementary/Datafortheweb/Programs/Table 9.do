////////////////////////////////////////////////////////////////////////////////
/*						MEXICO:	DESCRIPTIVE STATISTICS						  */
////////////////////////////////////////////////////////////////////////////////

clear
set more off, permanently
global geo "Capital Ciudad1960 landquality"

texdoc do "$dir/Programs/TablesMex.do" 
 
cap erase "Results/TablesMex_1.log.tex"
cap erase "Results/TablesMex_1.stloc"
