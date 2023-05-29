clear all
global folder "C:\Users\Nico Voigtl‰nder\Dropbox\dark side social capital\Replication"

cd "$folder"
use Dataset_Bowling_Replication_JPE.dta, clear

set logtype text
log using Log_Bowling_JPE_Appendix.txt, replace

********************************************* Generate variables ****************************************************
quietly{
*Log entry rates:
gen lnNSentry_total=ln(1+NSentry_total)
label var lnNSentry_total "log total (Falter) Party entries 1925-01/33"
gen lnNSentry_FU_total=ln(1+NSentry_FU_total)
label var lnNSentry_total "log total (Falter-corrected) Party entries 1925-01/33"
gen lnclubs_all = ln(clubs_all)

*Population:
gen pop2 = (pop25/1000)^2
gen pop3 = (pop25/1000)^3
gen lnpop25=ln(pop25)
label var pop2 "(pop'25)^2"
label var pop3 "(pop'25)^3"
label var lnpop25 "ln(pop) in 1925"

*Dummies for size quintiles
xtile pop25_quintiles = pop25, nq(5)
tab  pop25_quintiles, gen(d_pop_quintile)

*Population density:
gen lnpop_density=ln(pop_density)
gen dummy_maps=1 if area_source =="Maps"
recode dummy_maps .=0
gen i_popden_maps = lnpop_density*dummy_maps

*Government stability 
pca govt_longest_perc party_longest_perc weimar_coalition_perc
predict govt_stability, score

xtile govt_stability_AM = govt_stability if landweimar!="Preuﬂen", nq(2)
replace govt_stability_AM= govt_stability_AM-1 if landweimar!="Preuﬂen"
replace govt_stability_AM= 0 if landweimar=="Preuﬂen"

*Principal Component for IV analysis
pca turnmembers_pc singersfest_members_pc
predict IV_pca
label var IV_pca "First Principal Component of turnmembers_pc singersfest_members_pc"


*Total members in sports clubs in 1920s from Statistical Yearbook:
gen sportsclubmembers = JBturnadult+JBsportadult
gen sportsclubmembers_pc = sportsclubmembers/(pop25/1000)
label var sportsclubmembers_pc "Members in sports clubs in 1920s, per 1000 pop"
*Total number of sports clubs in 1920s from Statistical Yearbook:
gen sportsclubs = JBturnclub+JBsportclub
gen sportsclubs_pc = sportsclubs/(pop25/1000)
label var sportsclubs_pc "Number of sports clubs in 1920s, per 1000 pop"

*Nazi Potential (Appendix E.8)
gen proNaziPotential=pcDVP245

xtile proNaziPotential_abMed = proNaziPotential, nq(2)
gen proNaziPot_high = 1 if proNaziPotential_abMed==2
recode proNaziPot_high .=0 if proNaziPotential_abMed==1

gen inter_proNazi_high = proNaziPot_high*clubs_all_pc

foreach x in lnpop25 share_cath25 bcollar25 {
	gen i_high_`x' = `x'*proNaziPot_high
} 

}
*


*********************************************************************************************************************************************************************************	
********************************************************************** APPENDIX *************************************************************************************************	
*********************************************************************************************************************************************************************************	



/////////////////////////////////////////////////////////
//////////////// Appendix Figures ///////////////////////
/////////////////////////////////////////////////////////


*Figure A.1. for appendix: exclude top decile of club density:
reg pcNSentry_std clubs_all_pc lnpop25 share_cath25 bcollar25, r beta, if clubs_all_pc<4.45	 
	avplot clubs_all_pc, recast(scatter) mcolor(navy) msize(small) msymbol(diamond) mlabel(city) mlabcolor(navy) mlabsize(small) rlopts(lcolor(black)) ytitle(NSDAP entry rate (residual)) ///
	ytitle(, size(medlarge)) xtitle(Association density (residual)) xtitle(, size(medlarge)) note(, size(medsmall) ring(0)) note("") scheme(s1color)
	
*Figure A.2 // exclude two outliers, Calau (761) and Hirschberg (1045)
twoway (scatter pcNSentry_late pcNSentry_early if cityid~=761 & cityid~=1045, mcolor(black) msize(small) msymbol(circle) mlabel(city) mlabcolor(dknavy)), ///
 ytitle(Late (1929-1/33) Nazi Party entries) xtitle(Early (1925-28) Nazi Party entries) scheme(s1color)

	list city pop25 if cityid==761 | cityid==1045
	pwcorr pcNSentry_late pcNSentry_early if cityid~=761 & cityid~=1045, sig

	
*Figure A.3: Generated separataly; no replication data required. 
	
*Figure A.4: Binscatter 
binscatter pcNSentry_std clubs_all_pc, controls(lnpop25 share_cath25 bcollar25) by(original_sample) msymbols(circle circle_hollow) mcolors(blue black) lcolors(blue black) ///
legend(order(2 "City sample from Step 1" 1 "City sample from Step 2") cols(1) position(5) ring(0) size(medlarge)) scheme(s1color) ///
ytitle(NSDAP entry rate (residual), size(medlarge)) xtitle(Association density (residual), size(medlarge))


//////////////// Figure A.5 /////////////////////

*Figure A.5 (left panel): Show that clubs per capita are a close proxy for members per capita.
pwcorr sportsclubmembers_pc sportsclubs_pc, sig
reg sportsclubmembers_pc sportsclubs_pc, r
		twoway(lfit sportsclubmembers_pc sportsclubs_pc, clcolor(black) fcolor(gray)) (scatter sportsclubmembers_pc sportsclubs_pc, mcolor(navy) msize(small) msymbol(diamond) mlabel(city) mlabcolor(navy) mlabsize(small)), ///
		ytitle("Sports club members per 1,000") ytitle(, size(medlarge)) xtitle("Sports clubs per 1,000 inhabitants") ///
		xtitle(, size(medlarge)) note(, size(medium) ring(0) position(5)) scheme(s1color) note("coef=91.90***, se=24.23 t=3.79, R2=0.22") legend(off)
	
*Figure A.5 (right panel): Putnam data
preserve
use "Data_Assoc_USA_Putnam.dta", clear
pwcorr gssmeannumberofgroupmemberships civicandsocialorgztsper1000pop19, sig
reg gssmeannumberofgroupmemberships civicandsocialorgztsper1000pop19, r
		twoway(lfit gssmeannumberofgroupmemberships civicandsocialorgztsper1000pop19, clcolor(black) fcolor(gray)) (scatter gssmeannumberofgroupmemberships civicandsocialorgztsper1000pop19, mcolor(navy) msize(small) msymbol(diamond) mlabel(state) mlabcolor(navy) mlabsize(small)), ///
		ytitle("Mean number of group memberships") ytitle(, size(medlarge)) xtitle("Civic and social organizations per 1,000 pop (1977-1992)") ///
		xtitle(, size(medlarge)) note(, size(medium) ring(0) position(5)) scheme(s1color) note("coef=3.53***, se=0.97 t=3.65, R2=0.27") legend(off)
restore  

//////////////// Figure A.6 /////////////////////
*Figure A.6: Kernel Density
	sum govt_stability, d
	gen govt_stability_AM_all=1 if govt_stability>=1.287139
	recode govt_stability_AM_all .=0
	 twoway (kdensity pcNSentry_PRS_std if govt_stability_AM_all==1, bwidth(0.35) lcolor(black) lpattern(solid) range(-2 4) lwidth(medthick) lpattern(solid)) ///
	(kdensity pcNSentry_PRS_std if govt_stability_AM_all==0, bwidth(0.35) lcolor(green) lpattern(dash) lwidth(medthick)), ///
	ytitle(Kernel density) xtitle(Standardized frequency of Nazi party entry 1925-07/1932, size(medlarge))  ytitle(Kernel density, size(medlarge)) ///
	legend(order(1 "Above-Median Stability" 2 "Below-Median Stability") position(2) ring(0) cols(1) size(medlarge)) scheme(s1color)


//////////////// Figure A.7 /////////////////////

/*Run separately -- else, log-file freezes.
	************************ Interaction plot ******************************
	gen i_assoc_stability=govt_stability*clubs_all_pc

	foreach var of varlist share_cath25 lnpop25 bcollar25 {
		gen i_`var'_stab = `var'*govt_stability
		}
		#delimit ;
		set obs 10000 ;
		reg pcNSentry_PRS_std clubs_all_pc govt_stability i_assoc_stability  share_cath25 lnpop25 bcollar25 i_share_cath25_stab i_lnpop25_stab i_bcollar25_stab, cl(landweimar);
		matrix b=e(b);
		matrix V=e(V);

		scalar b1=b[1,1];
		scalar b3=b[1,3];
		scalar varb1=V[1,1];
		scalar varb3=V[3,3];
		scalar covb1b3=V[1,3];
		scalar list b1 b3 varb1 varb3 covb1b3;

		*     ****************************************************************  *;
		*       Calculate data necessary for top marginal effect plot.          *;
		*     ****************************************************************  *;

		generate MVZ=((_n-270)/100);
		replace  MVZ=. if _n>800;
		gen conbx=b1+b3*MVZ if _n<800;
		gen consx=sqrt(varb1+varb3*(MVZ^2)+2*covb1b3*MVZ) if _n<800;
		gen ax=1.96*consx;
		gen upperx=conbx+ax;
		gen lowerx=conbx-ax;

		*     ****************************************************************  *;
		*       Construct stuff to produce the rug plot.  Need to create an     *;
		*       offset position for the pipe marker, which will depend on       *;
		*       where the histogram sits on the y-axis. This will requie some   *;
		*       trial and error.                                                *;
		*     ****************************************************************  *;

		gen where=-0.045;
		gen pipe = "";
		egen tag_nonslav = tag(govt_stability);

		*     ****************************************************************  *;
		*       Construct variable to produce y=0 line.                         *;
		*     ****************************************************************  *;

		gen yline=0;

		*     ****************************************************************  *;
		*     ****************************************************************  *;
		*       Produce marginal effect plot for X.                             *;
		*     ****************************************************************  *;
		*     ****************************************************************  *;

		graph twoway scatter where govt_stability if tag_nonslav, plotr(m(b 4)) ms(none) mlabcolor(gs5) mlabel(pipe) mlabpos(6) legend(off)
				||   line conbx   MVZ, clpattern(solid) clwidth(medium) clcolor(black) yaxis(1)
				||   line upperx  MVZ, clpattern(dash) clwidth(thin) clcolor(black)
				||   line lowerx  MVZ, clpattern(dash) clwidth(thin) clcolor(black)
				||   line yline  MVZ,  clwidth(thin) clcolor(black) clpattern(solid)
				||   ,
					 xlabel(-3 -2 -1 0 1 2 3 4, nogrid labsize(2))
					 ylabel(-.3 -.2 -0.1 -0.05 0 .05 .1 .15 .2 .25 .3 .4, axis(1) nogrid labsize(2))
					 
					 yscale(noline alt)
					 xscale(noline)
					 legend(off)
					 xtitle("" , size(2.5)  )
					 xsca(titlegap(2))
					 ysca(titlegap(2))
					 scheme(s2mono) graphregion(fcolor(white) ilcolor(white) lcolor(white));

		#delimit ;
		drop MVZ;
		drop conbx;
		drop consx;
		drop ax;
		drop upperx;
		drop lowerx;
		drop where;
		drop pipe;
		drop tag_nonslav;
		drop yline;

*/		

*********************************************************************************************************************************	

///////////////////////////////// Figure A.8: Different types of associations  //////////////////////////////////////////

 	*Figure A.8, Panel A: Civic and Military
	twoway(lfit clubs_civic_pc clubs_nonCivic_pc, clcolor(black) fcolor(gray)) (scatter clubs_civic_pc clubs_nonCivic_pc, mcolor(navy) msize(medium) msymbol(diamond)), ///
	ytitle("Military clubs per 1,000 inhabitants") ytitle(, size(medlarge)) xtitle("Civic clubs per 1,000 inhabitants") ///
	xtitle(, size(medlarge)) note(, size(medium) ring(0) position(5)) scheme(s1color) note("") legend(off)
	
	*Figure A.8, Panel B: Bridging and Bonding
	twoway(lfit clubs_bridging_pc clubs_bonding_pc, clcolor(black) fcolor(gray)) (scatter clubs_bridging_pc clubs_bonding_pc, mcolor(navy) msize(medium) msymbol(diamond)), ///
	ytitle("Bridging clubs per 1,000 inhabitants") ytitle(, size(medlarge)) xtitle("Bonding clubs per 1,000 inhabitants") ///
	xtitle(, size(medlarge)) note(, size(medium) ring(0) position(5)) scheme(s1color) note("") legend(off)
	
 	*Figure A.8, Panel C: Workers and non-Workers
	twoway(lfit clubs_workers_pc clubs_pc_noWorkers, clcolor(black) fcolor(gray)) (scatter clubs_workers_pc clubs_pc_noWorkers, mcolor(navy) msize(medium) msymbol(diamond)), ///
	ytitle("Workers clubs per 1,000 inhabitants") ytitle(, size(medlarge)) xtitle("Clubs not associated with workers, per 1,000 inhabitants") ///
	xtitle(, size(medlarge)) note(, size(medium) ring(0) position(5)) scheme(s1color) note("") legend(off)

	
////////////////////////////////////////////////// Figure A.9: Nazi Party Potential ///////////////////////////////////////////////////			
*Left Panel:
reg pcNSentry_std clubs_all_pc share_cath25 lnpop25 bcollar25 if proNaziPot_high==0, r 
	avplot clubs_all_pc, recast(scatter) mcolor(navy) msize(small) msymbol(diamond) mlabel(city) mlabcolor(navy) mlabsize(small) rlopts(lcolor(black)) ytitle(NSDAP entry rate (residual)) ytitle(, size(medlarge)) ///
	 xtitle(Association density (residual)) xtitle(, size(medlarge)) note(, size(medsmall) ring(0)) note("") scheme(s1color)

*Right Panel:	 
reg pcNSentry_std clubs_all_pc share_cath25 lnpop25 bcollar25 if proNaziPot_high==1, r 
	avplot clubs_all_pc, recast(scatter) mcolor(navy) msize(small) msymbol(diamond) mlabel(city) mlabcolor(navy) mlabsize(small) rlopts(lcolor(black)) ytitle(NSDAP entry rate (residual)) ytitle(, size(medlarge)) ///
	 xtitle(Association density (residual)) xtitle(, size(medlarge)) note(, size(medsmall) ring(0)) note("") scheme(s1color)

////////////////////////////////////////////////// Figure A.10: Demokratenkongress and later associational life ///////////////////////////////////////////////////	

*Left Panel: Gymnast members in 1861
reg turnmembers_pc dk_reps_pc, r, if dk_reps_total~=. & turnmembers_pc~=0
	twoway(lfit turnmembers_pc dk_reps_pc if dk_reps_total~=. & turnmembers_pc~=0, clcolor(black) fcolor(gray)) (scatter turnmembers_pc dk_reps_pc if dk_reps_total~=. & turnmembers_pc~=0, mcolor(navy) msize(small) msymbol(diamond) mlabel(city) mlabcolor(navy) mlabsize(small)), ///
	ytitle("Gymnast club members in 1863 (per 1,000)") ytitle(, size(medlarge)) xtitle("Delegates to Democratic Congress 1848 (per 1,000)") ///
	xtitle(, size(medlarge)) note(, size(medium) ring(0) position(5)) scheme(s1color) note("coef=26.19***, se=7.68 t=3.41, R2=0.13") legend(off)

*Right Panel: Associations in 1920s
reg clubs_all_pc dk_reps_pc, r,  if dk_reps_total~=. 
	twoway(lfit clubs_all_pc dk_reps_pc if dk_reps_total~=., clcolor(black) fcolor(gray)) (scatter clubs_all_pc dk_reps_pc if dk_reps_total~=., mcolor(navy) msize(small) msymbol(diamond) mlabel(city) mlabcolor(navy) mlabsize(small)), ///
	ytitle("ASSOC(all) in 1920s (per 1,000)") ytitle(, size(medlarge)) xtitle("Delegates to Democratic Congress 1848 (per 1,000)") ///
	xtitle(, size(medlarge)) note(, size(medium) ring(0) position(5)) scheme(s1color) note("coef=11.76***, se=1.84, t=6.39, R2=0.46") legend(off)
	
	
////////////////////////////////////////////////// Figure A.11: Conley et al. -- see separate file "Bowling_JPE_Replication_Conley_etal.do" ///////////////////////////////////////////////////	



	
	
/////////////////////////////////////////////////////////
//////////////// Appendix Tables ////////////////////////
/////////////////////////////////////////////////////////


/////////////////////////////// Table A.1: Descriptive Statistics for main variables ////////////////////////////////////
*Table A.1.

tabstat clubs_all_pc clubs_civic_pc clubs_nonCivic_pc pcNSentry_total pcNSentry_std pcNSDAP285 pcNSDAP309 pcNSDAP333, statistics(mean sd) format(%9.3f) column(statistics)

/////////////////////////////// Tables A.2-A.6: No regressions -- see Appendix ////////////////////////////////////


////////////////////////////////////////////////// Table A.7: Different measures of Party entry: ///////////////////////////////////////////////////				

*Panel A:
local controls_socioecon "share_jew25 unemp33 in_welfare_per1000 war_per1000 sozialrentner_per1000 logtaxpers logtaxprop"
local controls_political "hitler_speech_per1000 DNVP_votes_avg DVP_votes_avg SPD_votes_avg KPD_votes_avg"		
eststo clear
/*1*/eststo: reg pcNSentry clubs_all_pc lnpop25 share_cath25 bcollar25, cl(landweimar)
/*2*/eststo: reg pcNSentry clubs_all_pc lnpop25 share_cath25 bcollar25 `controls_socioecon', cl(landweimar)
/*3*/eststo: reg pcNSentry clubs_all_pc lnpop25 share_cath25 bcollar25 `controls_socioecon' `controls_political', cl(landweimar)
/*4*/eststo: reg pcNSentry clubs_all_pc lnpop25 share_cath25 bcollar25 `controls_socioecon' `controls_political' dummy_land*, cl(landweimar)
/*5*/eststo: reg pcNSentry_early clubs_all_pc lnpop25 share_cath25 bcollar25 `controls_socioecon' `controls_political' dummy_land*, cl(landweimar)
/*6*/eststo: reg pcNSentry_late clubs_all_pc lnpop25 share_cath25 bcollar25 `controls_socioecon' `controls_political' dummy_land*, cl(landweimar)
esttab , se beta star compress keep(clubs_all_pc) //view beta coefficients

*Panel B:
local controls_socioecon "share_jew25 unemp33 in_welfare_per1000 war_per1000 sozialrentner_per1000 logtaxpers logtaxprop"
local controls_political "hitler_speech_per1000 DNVP_votes_avg DVP_votes_avg SPD_votes_avg KPD_votes_avg"		
eststo clear
/*1*/eststo: reg pcNSentry_FU clubs_all_pc lnpop25 share_cath25 bcollar25, cl(landweimar)
/*2*/eststo: reg pcNSentry_FU clubs_all_pc lnpop25 share_cath25 bcollar25 `controls_socioecon', cl(landweimar)
/*3*/eststo: reg pcNSentry_FU clubs_all_pc lnpop25 share_cath25 bcollar25 `controls_socioecon' `controls_political', cl(landweimar)
/*4*/eststo: reg pcNSentry_FU clubs_all_pc lnpop25 share_cath25 bcollar25 `controls_socioecon' `controls_political' dummy_land*, cl(landweimar)
/*5*/eststo: reg pcNSentry_early_FU clubs_all_pc lnpop25 share_cath25 bcollar25 `controls_socioecon' `controls_political' dummy_land*, cl(landweimar)
/*6*/eststo: reg pcNSentry_late_FU clubs_all_pc lnpop25 share_cath25 bcollar25 `controls_socioecon' `controls_political' dummy_land*, cl(landweimar)
esttab , se beta star compress keep(clubs_all_pc) //view beta coefficients

******************************************************************************************************************************************

////////////////////////////////////////////////// Table A.8: Appendix on Govt stability: ///////////////////////////////////////////////////	

preserve
collapse govt_longest_perc party_longest_perc weimar_coalition_perc govt_stability, by(landweimar)
	*drop if stability_pca==.
	gsort -govt_stability
	*export excel "Govt_Stability_Overview.xlsx", firstrow(variables) replace  
restore 

////////////////////////////////////////////////// Table A.9: Reporting individual coefficients for controls in Table 3B -- see replication of paper //////////////////////////////////



////////////////////////////////////////////////// Table A.10: Robustness of Table 4 ///////////////////////////////////////////////////		
*For online appendix: With full controls and FE, also with clustering 
*Table A.10, PANEL A:
eststo clear
local controls_socioecon "share_jew25 unemp33 in_welfare_per1000 war_per1000 sozialrentner_per1000 logtaxpers logtaxprop"
local controls_political "hitler_speech_per1000 DNVP_votes_avg DVP_votes_avg SPD_votes_avg KPD_votes_avg"
/*1*/eststo: reg pcNSDAP285 clubs_all_pc lnpop25 share_cath25 bcollar25 `controls_political' `controls_socioecon' dummy_land*, cl(landweimar)
/*2*/eststo: reg pcNSDAP309 clubs_all_pc lnpop25 share_cath25 bcollar25 `controls_political' `controls_socioecon' dummy_land*, cl(landweimar)
/*3*/eststo: reg pcNSDAP333 clubs_all_pc lnpop25 share_cath25 bcollar25 `controls_political' `controls_socioecon' dummy_land*, cl(landweimar)
*First stage: "Model with mediator regressed on iv":
/*4*/eststo: reg pcNSentry_early_std clubs_all_pc lnpop25 share_cath25 bcollar25 `controls_political' `controls_socioecon' dummy_land*, cl(landweimar)
/*5*/eststo: reg pcNSentry_pre1930_std clubs_all_pc lnpop25 share_cath25 bcollar25 `controls_political' `controls_socioecon' dummy_land*, cl(landweimar)
/*6*/eststo: reg pcNSentry_std clubs_all_pc lnpop25 share_cath25 bcollar25 `controls_political' `controls_socioecon' dummy_land*, cl(landweimar)
esttab , se beta star compress keep(clubs_all_pc) //view beta coefficients

*Table A.10, PANEL B:
eststo clear
local controls_socioecon "share_jew25 unemp33 in_welfare_per1000 war_per1000 sozialrentner_per1000 logtaxpers logtaxprop"
local controls_political "hitler_speech_per1000 DNVP_votes_avg DVP_votes_avg SPD_votes_avg KPD_votes_avg"
*"Model with dv regressed on mediator and iv":
/*1*/eststo: reg pcNSDAP285 pcNSentry_early_std clubs_all_pc lnpop25 share_cath25 bcollar25 `controls_political' `controls_socioecon' dummy_land*, cl(landweimar)
sum clubs_all_pc pcNSDAP285 if e(sample)
/*2*/eststo: reg pcNSDAP309 pcNSentry_pre1930_std clubs_all_pc lnpop25 share_cath25 bcollar25 `controls_political' `controls_socioecon' dummy_land*, cl(landweimar)
sum clubs_all_pc pcNSDAP309 if e(sample)
/*3*/eststo: reg pcNSDAP333 pcNSentry_std clubs_all_pc lnpop25 share_cath25 bcollar25 `controls_political' `controls_socioecon' dummy_land*, cl(landweimar)
sum clubs_all_pc pcNSDAP333 if e(sample)
esttab , se beta star compress keep(clubs_all_pc pcNSentry_early_std pcNSentry_pre1930_std pcNSentry_std) //view beta coefficients

local controls_socioecon "share_jew25 unemp33 in_welfare_per1000 war_per1000 sozialrentner_per1000 logtaxpers logtaxprop"
local controls_political "hitler_speech_per1000 DNVP_votes_avg DVP_votes_avg SPD_votes_avg KPD_votes_avg"
sgmediation pcNSDAP285, iv(clubs_all_pc) mv(pcNSentry_early_std) cv(lnpop25 share_cath25 bcollar25 `controls_political' `controls_socioecon' dummy_land*)
disp(1.571497*.224269/4.758155) //standardized indirect effect
sgmediation pcNSDAP309, iv(clubs_all_pc) mv(pcNSentry_pre1930_std) cv(lnpop25 share_cath25 bcollar25 `controls_political' `controls_socioecon' dummy_land*)
disp(1.571497*.298721/4.758155) //standardized indirect effect
sgmediation pcNSDAP333, iv(clubs_all_pc) mv(pcNSentry_std) cv(lnpop25 share_cath25 bcollar25 `controls_political' `controls_socioecon' dummy_land*)
disp(1.571497*.195212/4.758155) //standardized indirect effect


////////////////////////////////////////////////// Table A.11: Robustness of Table 5 ///////////////////////////////////////////////////		
estimates clear
local controls_socioecon "share_jew25 unemp33 in_welfare_per1000 war_per1000 sozialrentner_per1000 logtaxpers logtaxprop"
local controls_political "hitler_speech_per1000 DNVP_votes_avg DVP_votes_avg SPD_votes_avg KPD_votes_avg"  
/*1*/eststo: reg pcNSentry_early_std clubs_all_pc lnpop25 share_cath25 bcollar25 `controls_socioecon' `controls_political' dummy_land*, cl(landweimar) 
/*2*/eststo: reg pcNSentry_late_std clubs_all_pc lnpop25 share_cath25 bcollar25 `controls_socioecon' `controls_political' dummy_land*, cl(landweimar) 
/*3*/eststo: reg pcNSentry_late_std clubs_all_pc pcNSentry_early_std lnpop25 share_cath25 bcollar25 `controls_socioecon' `controls_political' dummy_land*, cl(landweimar) 
esttab , se beta star compress keep(clubs_all_pc pcNSentry_early_std) //view beta coefficients
		
	*Sobel-Goodman test for col 3:	
	local controls_socioecon "share_jew25 unemp33 in_welfare_per1000 war_per1000 sozialrentner_per1000 logtaxpers logtaxprop"
	local controls_political "hitler_speech_per1000 DNVP_votes_avg DVP_votes_avg SPD_votes_avg KPD_votes_avg" 
		sgmediation pcNSentry_late_std, iv(clubs_all_pc) mv(pcNSentry_early_std) cv(lnpop25 share_cath25 bcollar25 `controls_socioecon' `controls_political' dummy_land*)	
		
		

////////////////////////////////////////////////// Table A.12: Robustness of Table 8 ///////////////////////////////////////////////////		
foreach var of varlist lnpop25 bcollar25 share_jew25 {
	xtile `var'_AM = `var', nq(2)
	replace `var'_AM= `var'_AM-1
	}

*Panel A:
estimates clear
local controls_socioecon "share_jew25 unemp33 in_welfare_per1000 war_per1000 sozialrentner_per1000 logtaxpers logtaxprop"
local controls_political "hitler_speech_per1000 DNVP_votes_avg DVP_votes_avg SPD_votes_avg KPD_votes_avg" 
eststo: reg pcNSentry_std clubs_all_pc lnpop25 share_cath25 bcollar25 `controls_political' `controls_socioecon' dummy_land*, cl(landweimar), if lnpop25_AM==0
eststo: reg pcNSentry_std clubs_all_pc lnpop25 share_cath25 bcollar25 `controls_political' `controls_socioecon' dummy_land*, cl(landweimar), if lnpop25_AM==1
eststo: reg pcNSentry_std clubs_all_pc lnpop25 share_cath25 bcollar25 `controls_political' `controls_socioecon' dummy_land*, cl(landweimar), if share_cath25<0.5 
eststo: reg pcNSentry_std clubs_all_pc lnpop25 share_cath25 bcollar25 `controls_political' `controls_socioecon' dummy_land*, cl(landweimar), if share_cath25>0.5
eststo: reg pcNSentry_std clubs_all_pc lnpop25 share_cath25 bcollar25 `controls_political' `controls_socioecon' dummy_land*, cl(landweimar), if bcollar25_AM==0
eststo: reg pcNSentry_std clubs_all_pc lnpop25 share_cath25 bcollar25 `controls_political' `controls_socioecon' dummy_land*, cl(landweimar), if bcollar25_AM==1
esttab , se beta star compress keep(clubs_all_pc) //view beta coefficients

*Panel B:
estimates clear
local controls_socioecon "share_jew25 unemp33 in_welfare_per1000 war_per1000 sozialrentner_per1000 logtaxpers logtaxprop"
local controls_political "hitler_speech_per1000 DNVP_votes_avg DVP_votes_avg SPD_votes_avg KPD_votes_avg" 
eststo: reg pcNSentry_std clubs_civic_pc lnpop25 share_cath25 bcollar25 `controls_political' `controls_socioecon' dummy_land*, cl(landweimar), if lnpop25_AM==0
eststo: reg pcNSentry_std clubs_civic_pc lnpop25 share_cath25 bcollar25 `controls_political' `controls_socioecon' dummy_land*, cl(landweimar), if lnpop25_AM==1
eststo: reg pcNSentry_std clubs_civic_pc lnpop25 share_cath25 bcollar25 `controls_political' `controls_socioecon' dummy_land*, cl(landweimar), if share_cath25<0.5 
eststo: reg pcNSentry_std clubs_civic_pc lnpop25 share_cath25 bcollar25 `controls_political' `controls_socioecon' dummy_land*, cl(landweimar), if share_cath25>0.5
eststo: reg pcNSentry_std clubs_civic_pc lnpop25 share_cath25 bcollar25 `controls_political' `controls_socioecon' dummy_land*, cl(landweimar), if bcollar25_AM==0
eststo: reg pcNSentry_std clubs_civic_pc lnpop25 share_cath25 bcollar25 `controls_political' `controls_socioecon' dummy_land*, cl(landweimar), if bcollar25_AM==1
esttab , se beta star compress keep(clubs_civic_pc) //view beta coefficients



////////////////////////////////////////////////// Table A.13: Quantile and robust regressions: ///////////////////////////////////////////////////		

*Panel A:		
local controls_socioecon "share_jew25 unemp33 in_welfare_per1000 war_per1000 sozialrentner_per1000 logtaxpers logtaxprop"
local controls_political "hitler_speech_per1000 DNVP_votes_avg DVP_votes_avg SPD_votes_avg KPD_votes_avg"		
eststo clear
/*1*/eststo: qreg pcNSentry_std clubs_all_pc lnpop25 share_cath25 bcollar25 `controls_socioecon' `controls_political', quantile(.2)
/*2*/eststo: qreg pcNSentry_std clubs_all_pc lnpop25 share_cath25 bcollar25 `controls_socioecon' `controls_political', quantile(.4)
/*3*/eststo: qreg pcNSentry_std clubs_all_pc lnpop25 share_cath25 bcollar25 `controls_socioecon' `controls_political', quantile(.5)
/*4*/eststo: qreg pcNSentry_std clubs_all_pc lnpop25 share_cath25 bcollar25 `controls_socioecon' `controls_political', quantile(.6)
/*5*/eststo: qreg pcNSentry_std clubs_all_pc lnpop25 share_cath25 bcollar25 `controls_socioecon' `controls_political', quantile(.8)
/*6*/eststo: rreg pcNSentry_std clubs_all_pc lnpop25 share_cath25 bcollar25 `controls_socioecon' `controls_political' 
esttab , se beta star compress keep(clubs_all_pc) //view beta coefficients

*Panel B:
local controls_socioecon "share_jew25 unemp33 in_welfare_per1000 war_per1000 sozialrentner_per1000 logtaxpers logtaxprop"
local controls_political "hitler_speech_per1000 DNVP_votes_avg DVP_votes_avg SPD_votes_avg KPD_votes_avg"		
eststo clear
/*1*/eststo: qreg pcNSentry_std clubs_civic_pc lnpop25 share_cath25 bcollar25 `controls_socioecon' `controls_political', quantile(.2)
/*2*/eststo: qreg pcNSentry_std clubs_civic_pc lnpop25 share_cath25 bcollar25 `controls_socioecon' `controls_political', quantile(.4)
/*3*/eststo: qreg pcNSentry_std clubs_civic_pc lnpop25 share_cath25 bcollar25 `controls_socioecon' `controls_political', quantile(.5)
/*4*/eststo: qreg pcNSentry_std clubs_civic_pc lnpop25 share_cath25 bcollar25 `controls_socioecon' `controls_political', quantile(.6)
/*5*/eststo: qreg pcNSentry_std clubs_civic_pc lnpop25 share_cath25 bcollar25 `controls_socioecon' `controls_political', quantile(.8)
/*6*/eststo: rreg pcNSentry_std clubs_civic_pc lnpop25 share_cath25 bcollar25 `controls_socioecon' `controls_political' 
esttab , se beta star compress keep(clubs_civic_pc) //view beta coefficients


////////////////////////////////////////////////// Table A.14: Weighted regressions: ///////////////////////////////////////////////////

local controls_socioecon "share_jew25 unemp33 in_welfare_per1000 war_per1000 sozialrentner_per1000 logtaxpers logtaxprop"
local controls_political "hitler_speech_per1000 DNVP_votes_avg DVP_votes_avg SPD_votes_avg KPD_votes_avg"		
eststo clear
/*1*/eststo: reg pcNSentry_std clubs_all_pc lnpop25 share_cath25 bcollar25 `controls_socioecon' `controls_political' [aweight=pop25], cl(landweimar)
/*2*/eststo: reg pcNSentry_std clubs_all_pc lnpop25 share_cath25 bcollar25 `controls_socioecon' `controls_political' dummy_land* [aweight=pop25], cl(landweimar)
/*3*/eststo: reg pcNSentry_std clubs_civic_pc lnpop25 share_cath25 bcollar25 `controls_socioecon' `controls_political' [aweight=pop25], cl(landweimar)
/*4*/eststo: reg pcNSentry_std clubs_civic_pc lnpop25 share_cath25 bcollar25 `controls_socioecon' `controls_political' dummy_land* [aweight=pop25], cl(landweimar)
/*5*/eststo: reg pcNSentry_std clubs_nonCivic_pc lnpop25 share_cath25 bcollar25 `controls_socioecon' `controls_political' [aweight=pop25], cl(landweimar)
/*6*/eststo: reg pcNSentry_std clubs_nonCivic_pc lnpop25 share_cath25 bcollar25 `controls_socioecon' `controls_political' dummy_land* [aweight=pop25], cl(landweimar)
esttab , se beta star compress keep(clubs_all_pc clubs_civic_pc clubs_nonCivic_pc) //view beta coefficients


////////////////////////////////////////////////// Table A.15: Different functional forms for population: ///////////////////////////////////////////////////
foreach x of varlist d_pop_quintile1-d_pop_quintile5  {
	gen i_pop_`x' = `x'*lnpop25
} 	
bysort pop25_quintiles: sum pop25 //for note

local controls_socioecon "share_jew25 unemp33 in_welfare_per1000 war_per1000 sozialrentner_per1000 logtaxpers logtaxprop"
local controls_political "hitler_speech_per1000 DNVP_votes_avg DVP_votes_avg SPD_votes_avg KPD_votes_avg"		
eststo clear
/*1*/eststo: reg pcNSentry_std clubs_all_pc pop25 pop2 pop3 share_cath25 bcollar25 `controls_socioecon' `controls_political', cl(landweimar)
/*2*/eststo: reg pcNSentry_std clubs_all_pc d_pop_quintile* lnpop25 share_cath25 bcollar25 `controls_socioecon' `controls_political', cl(landweimar)
/*3*/eststo: reg pcNSentry_std clubs_all_pc d_pop_quintile* i_pop_d_pop_quintile* share_cath25 bcollar25 `controls_socioecon' `controls_political', cl(landweimar)
/*4*/eststo: reg pcNSentry_std clubs_civic_pc d_pop_quintile* i_pop_d_pop_quintile* share_cath25 bcollar25 `controls_socioecon' `controls_political', cl(landweimar)
/*5*/eststo: reg pcNSentry_std clubs_nonCivic_pc d_pop_quintile* i_pop_d_pop_quintile* share_cath25 bcollar25 `controls_socioecon' `controls_political', cl(landweimar)
esttab , se beta star compress keep(clubs_all_pc clubs_civic_pc clubs_nonCivic_pc) //view beta coefficients


////////////////////////////////////////////////// Table A.16: Exclude towns with less than 10,000 inhabitants: ///////////////////////////////////////////////////

local controls_socioecon "share_jew25 unemp33 in_welfare_per1000 war_per1000 sozialrentner_per1000 logtaxpers logtaxprop"
local controls_political "hitler_speech_per1000 DNVP_votes_avg DVP_votes_avg SPD_votes_avg KPD_votes_avg"		
eststo clear
/*1*/eststo: reg pcNSentry_std clubs_all_pc lnpop25 share_cath25 bcollar25 `controls_socioecon' `controls_political', cl(landweimar), if pop25>=10000
/*2*/eststo: reg pcNSentry_std clubs_all_pc lnpop25 share_cath25 bcollar25 `controls_socioecon' `controls_political' dummy_land*, cl(landweimar), if pop25>=10000
/*3*/eststo: reg pcNSentry_std clubs_civic_pc lnpop25 share_cath25 bcollar25 `controls_socioecon' `controls_political', cl(landweimar), if pop25>=10000
/*4*/eststo: reg pcNSentry_std clubs_civic_pc lnpop25 share_cath25 bcollar25 `controls_socioecon' `controls_political' dummy_land*, cl(landweimar), if pop25>=10000
/*5*/eststo: reg pcNSentry_std clubs_nonCivic_pc lnpop25 share_cath25 bcollar25 `controls_socioecon' `controls_political', cl(landweimar), if pop25>=10000
/*6*/eststo: reg pcNSentry_std clubs_nonCivic_pc lnpop25 share_cath25 bcollar25 `controls_socioecon' `controls_political' dummy_land*, cl(landweimar), if pop25>=10000
esttab , se beta star compress keep(clubs_all_pc clubs_civic_pc clubs_nonCivic_pc) //view beta coefficients


////////////////////////////////////////////////// Table A.17: Pop-density  ///////////////////////////////////////////////////	

eststo clear
/*1*/eststo: reg clubs_all_pc lnpop_density share_cath25 bcollar25 if area_source=="Brockhaus", r
/*2*/eststo: reg pcNSentry_std lnpop_density share_cath25 bcollar25 if area_source=="Brockhaus", r
/*3*/eststo: reg pcNSentry_std clubs_all_pc share_cath25 bcollar25 if area_source=="Brockhaus", r
/*4*/eststo: reg pcNSentry_std clubs_all_pc lnpop_density share_cath25 bcollar25 if area_source=="Brockhaus", r
/*5*/eststo: reg clubs_all_pc lnpop_density dummy_maps i_popden_maps share_cath25 bcollar25, r
/*6*/eststo: reg pcNSentry_std lnpop_density dummy_maps i_popden_maps share_cath25 bcollar25, r
/*7*/eststo: reg pcNSentry_std clubs_all_pc share_cath25 bcollar25, r, if pop_density~=.
/*8*/eststo: reg pcNSentry_std clubs_all_pc lnpop_density dummy_maps i_popden_maps share_cath25 bcollar25, r
esttab , se beta star compress keep(clubs_all_pc lnpop_density) //view beta coefficients

	
////////////////////////////////////////////////// Table A.18: fragmentation  ///////////////////////////////////////////////////	

eststo clear
/*1*/eststo: reg clubs_all_pc clubs_per_category lnpop25 share_cath25 bcollar25, r
/*2*/eststo: reg clubs_all_pc clubs_Herfindahl lnpop25 share_cath25 bcollar25, r
/*3*/eststo: reg clubs_all_pc religion_Herfindahl lnpop25 share_cath25 bcollar25, r
/*4*/eststo: reg pcNSentry_std clubs_all_pc clubs_per_category share_cath25 lnpop25 bcollar25, r
/*5*/eststo: reg pcNSentry_std clubs_all_pc clubs_Herfindahl share_cath25 lnpop25 bcollar25, r
/*6*/eststo: reg pcNSentry_std clubs_all_pc religion_Herfindahl share_cath25 lnpop25 bcollar25, r
esttab , se beta star compress keep(clubs_all_pc clubs_per_category clubs_Herfindahl religion_Herfindahl) //view beta coefficients
	

////////////////////////////////////////////////// Table A.19: Different types of associations ///////////////////////////////////////////////////			
*"Horseraces" for different types of clubs. Note [footnote 18]: to avoid that outliers of the (smaller) counts of smaller club categories drive the results, we exclude
* the top 5 pctile for each sub-category.
*Table A.18: 
estimates clear
local controls_socioecon "share_jew25 unemp33 in_welfare_per1000 war_per1000 sozialrentner_per1000 logtaxpers logtaxprop"
local controls_political "hitler_speech_per1000 DNVP_votes_avg DVP_votes_avg SPD_votes_avg KPD_votes_avg" 
/*1*/eststo: reg pcNSentry_std clubs_civic_pc clubs_nonCivic_pc lnpop25 share_cath25 bcollar25 `controls_political' `controls_socioecon' if clubs_civic_pc<1.906578 & clubs_nonCivic_pc<.9943323, cl(landweimar) 
/*2*/eststo: reg pcNSentry_std clubs_civic_pc clubs_nonCivic_pc lnpop25 share_cath25 bcollar25 `controls_political' `controls_socioecon' dummy_land* if clubs_civic_pc<1.906578 & clubs_nonCivic_pc<.9943323, cl(landweimar) 
/*3*/eststo: reg pcNSentry_std clubs_bridging_pc clubs_bonding_pc lnpop25 share_cath25 bcollar25  `controls_political' `controls_socioecon' if clubs_bridging_pc<4.057279 & clubs_bonding_pc<1.179047, cl(landweimar) 
/*4*/eststo: reg pcNSentry_std clubs_bridging_pc clubs_bonding_pc lnpop25 share_cath25 bcollar25  `controls_political' `controls_socioecon' dummy_land* if clubs_bridging_pc<4.057279 & clubs_bonding_pc<1.179047, cl(landweimar) 
/*5*/eststo: reg pcNSentry_std clubs_workers_pc lnpop25 share_cath25 bcollar25  `controls_political' `controls_socioecon' if clubs_workers_pc<.3650967, cl(landweimar)
/*6*/eststo: reg pcNSentry_std clubs_workers_pc lnpop25 share_cath25 bcollar25  `controls_political' `controls_socioecon' dummy_land* if clubs_workers_pc<.3650967, cl(landweimar)
/*7*/eststo: reg pcNSentry_std clubs_workers_pc clubs_pc_noWorkers lnpop25 share_cath25 bcollar25  `controls_political' `controls_socioecon' if clubs_workers_pc<.3650967 & clubs_pc_noWorkers<5.378467, cl(landweimar)
/*8*/eststo: reg pcNSentry_std clubs_workers_pc clubs_pc_noWorkers lnpop25 share_cath25 bcollar25  `controls_political' `controls_socioecon' dummy_land* if clubs_workers_pc<.3650967 & clubs_pc_noWorkers<5.378467, cl(landweimar)
esttab , se beta star compress keep(clubs_civic_pc clubs_nonCivic_pc clubs_bridging_pc clubs_bonding_pc clubs_workers_pc clubs_pc_noWorkers) //view beta coefficients
	
	*Footnote 19: t-test for difference in coeff:
	*Col 2: 
	local controls_socioecon "share_jew25 unemp33 in_welfare_per1000 war_per1000 sozialrentner_per1000 logtaxpers logtaxprop"
	local controls_political "hitler_speech_per1000 DNVP_votes_avg DVP_votes_avg SPD_votes_avg KPD_votes_avg" 
	/*2*/ reg pcNSentry_std clubs_civic_pc clubs_nonCivic_pc lnpop25 share_cath25 bcollar25 `controls_political' `controls_socioecon' dummy_land* if clubs_civic_pc<1.906578 & clubs_nonCivic_pc<.9943323, cl(landweimar) 
	sum pcNSentry_std clubs_civic_pc clubs_nonCivic_pc if e(sample)
	test (clubs_civic_pc*.4561513/.8847494) = (clubs_nonCivic_pc*.2595718/.8847494)
	*Col 4: 
	local controls_socioecon "share_jew25 unemp33 in_welfare_per1000 war_per1000 sozialrentner_per1000 logtaxpers logtaxprop"
	local controls_political "hitler_speech_per1000 DNVP_votes_avg DVP_votes_avg SPD_votes_avg KPD_votes_avg" 
	/*4*/ reg pcNSentry_std clubs_bridging_pc clubs_bonding_pc lnpop25 share_cath25 bcollar25  `controls_political' `controls_socioecon' dummy_land* if clubs_bridging_pc<4.057279 & clubs_bonding_pc<1.179047, cl(landweimar) 
	sum pcNSentry_std clubs_bridging_pc clubs_bonding_pc if e(sample)
	test (clubs_bridging_pc*.8861573/.848254) = (clubs_bonding_pc*.2904777/.848254)
	*Col 8: 
	local controls_socioecon "share_jew25 unemp33 in_welfare_per1000 war_per1000 sozialrentner_per1000 logtaxpers logtaxprop"
	local controls_political "hitler_speech_per1000 DNVP_votes_avg DVP_votes_avg SPD_votes_avg KPD_votes_avg" 
	/*4*/ reg pcNSentry_std clubs_workers_pc clubs_pc_noWorkers lnpop25 share_cath25 bcollar25  `controls_political' `controls_socioecon' dummy_land* if clubs_workers_pc<.3650967 & clubs_pc_noWorkers<5.378467, cl(landweimar) 
	sum pcNSentry_std clubs_workers_pc clubs_pc_noWorkers if e(sample)
	test (clubs_workers_pc*.0887493/.9171885) = (clubs_pc_noWorkers*1.190381/.9171885)

	
	
	*For footnote: strong correlation between the two variables
	eststo: reg clubs_workers_pc clubs_pc_noWorkers lnpop25 share_cath25 bcollar25, r beta	
	*For footnote 18: results largely identical when not dropping top 5% (except for bonding/bridging)
	local controls_socioecon "share_jew25 unemp33 in_welfare_per1000 war_per1000 sozialrentner_per1000 logtaxpers logtaxprop"
	local controls_political "hitler_speech_per1000 DNVP_votes_avg DVP_votes_avg SPD_votes_avg KPD_votes_avg" 
	/*1*/eststo: reg pcNSentry_std clubs_civic_pc clubs_nonCivic_pc lnpop25 share_cath25 bcollar25 `controls_political' `controls_socioecon', cl(landweimar) 
	/*2*/eststo: reg pcNSentry_std clubs_civic_pc clubs_nonCivic_pc lnpop25 share_cath25 bcollar25 `controls_political' `controls_socioecon' dummy_land*, cl(landweimar) 
	/*3*/eststo: reg pcNSentry_std clubs_bridging_pc clubs_bonding_pc lnpop25 share_cath25 bcollar25  `controls_political' `controls_socioecon', cl(landweimar) 
	/*4*/eststo: reg pcNSentry_std clubs_bridging_pc clubs_bonding_pc lnpop25 share_cath25 bcollar25  `controls_political' `controls_socioecon' dummy_land*, cl(landweimar) 
	/*5*/eststo: reg pcNSentry_std clubs_workers_pc lnpop25 share_cath25 bcollar25  `controls_political' `controls_socioecon', cl(landweimar)
	/*6*/eststo: reg pcNSentry_std clubs_workers_pc lnpop25 share_cath25 bcollar25  `controls_political' `controls_socioecon' dummy_land*, cl(landweimar)
	/*7*/eststo: reg pcNSentry_std clubs_workers_pc clubs_pc_noWorkers lnpop25 share_cath25 bcollar25  `controls_political' `controls_socioecon', cl(landweimar)
	/*8*/eststo: reg pcNSentry_std clubs_workers_pc clubs_pc_noWorkers lnpop25 share_cath25 bcollar25  `controls_political' `controls_socioecon' dummy_land*, cl(landweimar)

////////////////////////////////////////////////// Table A.20: Election counterfactuals ///////////////////////////////////////////////////			
*OLS for KPD (reduced form):
eststo clear	
/*1*/eststo: reg pcKPD285 clubs_all_pc lnpop25 share_cath25 bcollar25, r beta
/*2*/eststo: reg pcKPD309 clubs_all_pc lnpop25 share_cath25 bcollar25, r beta
/*3*/eststo: reg pcKPD333 clubs_all_pc lnpop25 share_cath25 bcollar25, r beta
*OLS for DNVP (reduced form):
/*4*/eststo: reg pcDNVP285 clubs_all_pc lnpop25 share_cath25 bcollar25, r beta
/*5*/eststo: reg pcDNVP309 clubs_all_pc lnpop25 share_cath25 bcollar25, r beta
/*6*/eststo: reg pcDNVP333 clubs_all_pc lnpop25 share_cath25 bcollar25, r beta
esttab , se beta star compress keep(clubs_all_pc) //view beta coefficients


//////////////////////////////////////////////// Table A.21: SPD votes in Imperial Germany and NSDAP entry  ////////////////////////////////////////////////////////////		
eststo clear
/*1*/eststo: reg SPD_votes_avg_28_33 SPD_votes_avg_1890_1912 lnpop25 share_cath25 bcollar25, r beta 
/*2*/eststo: reg pcNSDAP_avg SPD_votes_avg_1890_1912 lnpop25 share_cath25 bcollar25, r beta 
/*3*/eststo: reg pcNSentry_std SPD_votes_avg_1890_1912 lnpop25 share_cath25 bcollar25, r beta
/*4*/eststo: reg clubs_all_pc SPD_votes_avg_1890_1912 lnpop25 share_cath25 bcollar25, r beta
esttab , se beta star compress keep(SPD_votes_avg_1890_1912) //view beta coefficients


//////////////////////////////////////////////// Table A.22: Nazi party potential  ////////////////////////////////////////////////////////////
estimates clear
/*1*/eststo: reg pcNSentry_std clubs_all_pc lnpop25 share_cath25 bcollar25, cl(landweimar), if proNaziPot_high==0
/*2*/eststo: reg pcNSentry_std clubs_all_pc lnpop25 share_cath25 bcollar25, cl(landweimar), if proNaziPot_high==1
/*3*/eststo: reg pcNSentry_std clubs_all_pc proNaziPot_high inter_proNazi_high lnpop25 share_cath25 bcollar25 i_high_lnpop25 i_high_share_cath25 i_high_bcollar25, cl(landweimar) 
		*Beta coefficient for interaction term:
		sum pcNSentry_std clubs_all_pc if e(sample)
		disp(-.2716826*1.571497/1.000253)
/*4*/eststo: reg pcNSentry_std clubs_all_pc proNaziPot_high inter_proNazi_high lnpop25 share_cath25 bcollar25 i_high_lnpop25 i_high_share_cath25 i_high_bcollar25 dummy_land*, cl(landweimar)
		*Beta coefficient for interaction term:
		sum pcNSentry_std clubs_all_pc if e(sample)
		disp(-.1501002*1.571497/1.000253)
esttab , se beta star compress keep(clubs_all_pc) //view beta coefficients

	****Test for significance of difference in coeff in cols 1 and 2 
		/*1*/reg pcNSentry_std clubs_all_pc lnpop25 share_cath25 bcollar25 if proNaziPot_high==0 
		estimates store m1
		sum clubs_all_pc pcNSentry_std if e(sample)
		/*2*/reg pcNSentry_std clubs_all_pc lnpop25 share_cath25 bcollar25 if proNaziPot_high==1 
		estimates store m2
		sum clubs_all_pc pcNSentry_std if e(sample)
		suest m1 m2, vce(cl landweimar)
		test [m1_mean]clubs_all_pc*1.448542/1.131915 = [m2_mean]clubs_all_pc*1.691287/.8509573



////////////////////////////////////// Table A.23: IV Reduced Form ////////////////////////////////////////////
eststo clear
local controls_socioecon "share_jew25 unemp33 in_welfare_per1000 war_per1000 sozialrentner_per1000 logtaxpers logtaxprop"
local controls_political "hitler_speech_per1000 DNVP_votes_avg DVP_votes_avg SPD_votes_avg KPD_votes_avg" 
/*1*/eststo: reg pcNSentry_std IV_pca, r first
/*2*/eststo: reg pcNSentry_std IV_pca lnpop25 share_cath25 bcollar25, r 
/*3*/eststo: reg pcNSentry_std IV_pca lnpop25 share_cath25 bcollar25 `controls_political' `controls_socioecon', r 	
/*4*/eststo: reg pcNSentry_std IV_pca lnpop25 share_cath25 bcollar25 `controls_political' `controls_socioecon' dummy_land*, r 	
/*5*/eststo: reg pcNSentry_std IV_pca lnpop25 share_cath25 bcollar25 `controls_political' `controls_socioecon', r 
esttab , se beta star compress keep(IV_pca) //view beta coefficients


////////////////// Table A.24: Some checks with NLP, DKP, and AS votes //////////////////
eststo clear
/*1*/eststo: reg pcNSDAP_avg avg_NLP, r beta //check: strong predictor of avg Nazi votes.
/*2*/eststo: reg pcNSDAP_avg avg_DKP, r beta //check: strong predictor of avg Nazi votes.
/*3*/eststo: reg pcNSDAP_avg AS_vote_simple, r beta //check: strong predictor of avg Nazi votes.
/*4*/eststo: reg avg_NLP IV_pca, r beta //not predicted by IV!
/*5*/eststo: reg avg_DKP IV_pca, r beta //not predicted by IV!
/*6*/eststo: reg AS_vote_simple IV_pca, r beta //not predicted by IV!
esttab , se beta star compress keep(avg_NLP avg_DKP AS_vote_simple IV_pca) //view beta coefficients



////////////////// Table A.25: IV Robustness -- using both instruments //////////////////
*Panel A: Second Stage:
eststo clear
local controls_socioecon "share_jew25 unemp33 in_welfare_per1000 war_per1000 sozialrentner_per1000 logtaxpers logtaxprop"
local controls_political "hitler_speech_per1000 DNVP_votes_avg DVP_votes_avg SPD_votes_avg KPD_votes_avg" 
/*1*/eststo: ivreg2 pcNSentry_std (clubs_all_pc = turnmembers_pc singersfest_members_pc) lnpop25 share_cath25 bcollar25 `controls_political' `controls_socioecon', r first	
/*2*/eststo: ivreg2 pcNSentry_std (clubs_all_pc = turnmembers_pc singersfest_members_pc) lnpop25 share_cath25 bcollar25 `controls_political' `controls_socioecon', r first, if singersfest_members~=. //count attendance at singersfestival for non-reported singers as zeros
/*3*/eststo: ivreg2 pcNSentry_std (clubs_all_pc = turnmembers_pc singersfest_members_pc) lnpop25 share_cath25 bcollar25 lnDistNuremberg `controls_political' `controls_socioecon', r first, if singersfest_members~=. //count attendance at singersfestival for non-reported singers as zeros
/*4*/eststo: ivreg2 pcNSentry_std (clubs_civic_pc = turnmembers_pc singersfest_members_pc) lnpop25 share_cath25 bcollar25 `controls_political' `controls_socioecon', r first
esttab , se beta star compress keep(clubs_all_pc clubs_civic_pc) //view beta coefficients

*Panel B: First Stage:
eststo clear
local controls_socioecon "share_jew25 unemp33 in_welfare_per1000 war_per1000 sozialrentner_per1000 logtaxpers logtaxprop"
local controls_political "hitler_speech_per1000 DNVP_votes_avg DVP_votes_avg SPD_votes_avg KPD_votes_avg" 
/*1*/eststo: reg clubs_all_pc turnmembers_pc singersfest_members_pc lnpop25 share_cath25 bcollar25 `controls_political' `controls_socioecon', r first	
/*2*/eststo: reg clubs_all_pc turnmembers_pc singersfest_members_pc lnpop25 share_cath25 bcollar25 `controls_political' `controls_socioecon', r first, if singersfest_members~=. //count attendance at singersfestival for non-reported singers as zeros
/*3*/eststo: reg clubs_all_pc turnmembers_pc singersfest_members_pc lnpop25 share_cath25 bcollar25 lnDistNuremberg `controls_political' `controls_socioecon', r first, if singersfest_members~=. //count attendance at singersfestival for non-reported singers as zeros
/*4*/eststo: reg clubs_civic_pc turnmembers_pc singersfest_members_pc lnpop25 share_cath25 bcollar25 `controls_political' `controls_socioecon', r first
	test (turnmembers_pc=0) (singersfest_members_pc=0)



////////////////////////////// Table A.26: Using Democratic Congress Delegates in 1848 as IV //////////////////////////////////////////////////
*Panel A: Second stage:
eststo clear
/*1*/eststo: ivreg2 pcNSentry_std (clubs_all_pc = dk_reps_pc) lnpop1863 lndistance_to_Berlin, r first, if dk_reps_total~=. 
	sum pcNSentry_std clubs_all_pc if e(sample)
	display(.4904061*1.595715/.7210915)
/*2*/eststo: ivreg2 pcNSentry_std (clubs_all_pc = dk_reps_pc) lndistance_to_Berlin lnpop25 lnpop1863 share_cath25 bcollar25, r first, if dk_reps_total~=. 
	sum pcNSentry_std clubs_all_pc if e(sample)
	display(.4431885*1.595715/.7210915)
esttab , se beta star compress keep(clubs_all_pc) //view beta coefficients

*Panel B: First stage:
pwcorr clubs_all_pc turnmembers_pc singersfest_members_pc dk_reps_pc, sig  
eststo clear
/*1*/eststo: reg clubs_all_pc dk_reps_pc lnpop1863 lndistance_to_Berlin, r,  if dk_reps_total~=. 
/*2*/eststo: reg clubs_all_pc dk_reps_pc lndistance_to_Berlin lnpop25 lnpop1863 share_cath25 bcollar25, r, if dk_reps_total~=.


	
////////////////////////////////////////////////// Table A.27: Altonji et al regs ///////////////////////////////////////////////////	
      
gen insample1 = 1 if pcNSentry_std~=. & clubs_all_pc~=. & lnpop25 ~=. & share_cath25~=. & bcollar25~=. //for first set of controls
gen insample2 = 1 if pcNSentry_std~=. & clubs_all_pc~=. & lnpop25 ~=. & share_cath25~=. & bcollar25~=. & ///
	share_jew25~=. & in_welfare_per1000~=. & war_per1000~=. & sozialrentner_per1000~=. & logtaxpers~=. & logtaxprop~=. & ///
	hitler_speech_per1000~=. & DNVP_votes_avg~=. & DVP_votes_avg~=. & SPD_votes_avg~=. & KPD_votes_avg //for second set of controls

*Panel A:
foreach x in clubs_all_pc clubs_civic_pc clubs_nonCivic_pc {

	*Reg 1: No controls
	reg pcNSentry_std `x' if insample1==1, r 
	gen beta1=_b[`x'] if insample1==1

	*Reg 2: Set 1 of controls (baseline)
	reg pcNSentry_std `x' lnpop25 share_cath25 bcollar25, r 
	gen beta2=_b[`x'] if insample1==1

	*Reg 3: No controls, for subsample where all controls are also observed
	reg pcNSentry_std `x' lnpop25 share_cath25 bcollar25 if insample2==1, r 
	gen beta3=_b[`x'] if insample2==1

	*Reg 4: Set 2 of controls
	local controls_socioecon "share_jew25 unemp33 in_welfare_per1000 war_per1000 sozialrentner_per1000 logtaxpers logtaxprop"
	local controls_political "hitler_speech_per1000 DNVP_votes_avg DVP_votes_avg SPD_votes_avg KPD_votes_avg"
	reg pcNSentry_std `x' lnpop25 share_cath25 bcollar25 `controls_socioecon' `controls_political', r 
	gen beta4=_b[`x'] if insample2==1

	*Altonji et al ratios:
	gen Altonji1_`x' = beta2/(beta1-beta2)  if insample1==1
	gen Altonji2_`x' = beta4/(beta3-beta4)  if insample2==1

	drop beta1-beta4
}

sum  Altonji*


log close	


////NOTE: You may have to restart Stata and then run the part below separately -- there seems to be a bug, with one of the earlier commands affecting psacalc. 
////      Output is reported in the log file in the replacation package. 

*Panel B: Oster's Altonji et al correction:
foreach z in clubs_all_pc clubs_civic_pc clubs_nonCivic_pc {	
	reg pcNSentry_std `z' lnpop25 share_cath25 bcollar25
	psacalc `z' delta //set	

	local controls_socioecon "share_jew25 unemp33 in_welfare_per1000 war_per1000 sozialrentner_per1000 logtaxpers logtaxprop"
	local controls_political "hitler_speech_per1000 DNVP_votes_avg DVP_votes_avg SPD_votes_avg KPD_votes_avg"	
	reg pcNSentry_std `z'  lnpop25 share_cath25 bcollar25 `controls_socioecon' `controls_political'
	psacalc `z' delta, mcontrol(lnpop25 share_cath25 bcollar25)	//set
}


********************************************************************************************************************************


