*Borrador pregunta 2

*** Figure 2
twoway (line crime week if bus==1 & cash==1, lc(black) xline(42 110)), ///
		 ytitle("# Incidents", size(med)) xtitle("") ///
		tlabel(0 "2005" 52 "2006" 105 "2007" 158 "2008" 210 "2009" 262 "2010"  314 "2011", labsize(med) nogrid) xscale(range(0 313) )
		graph export "$output/figures/figure2_2.png", replace
	
*** Figure 3
twoway (line crime week if bus==1 & cash==1, lc(black) xline(42 110)) ///
		(line crime week if bus==1 & cash==0, lc(gs12) lp(solid) ),  ///
		legend(label(1 "Cash") label(2 "Noncash") size(med)) ytitle("# Incidents", size(med)) xtitle("") ///
		tlabel(0 "2005" 52 "2006" 105 "2007" 158 "2008" 210 "2009" 262 "2010"  314 "2011", labsize(med) nogrid) xscale(range(0 313) )
		graph export "$output/figures/figure3_2.png", replace

*** Figure 4
twoway (line crime week if bus==0 & cash==1, lc(black) xline(42 110)) ///
		(line crime week if bus==0 & cash==0, lc(gs12) lp(solid) ),  ///
		legend(label(1 "Cash") label(2 "Noncash") size(med)) ytitle("# Incidents", size(med)) xtitle("") ///
		tlabel(0 "2005" 52 "2006" 105 "2007" 158 "2008" 210 "2009" 262 "2010"  314 "2011", labsize(med) nogrid) xscale(range(0 313) )
		graph export "$output/figures/figure4_2.png", replace
