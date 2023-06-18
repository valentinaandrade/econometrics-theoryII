////////////////////////////////////////////////////////////////////////////////
/*							    	TABLE A13								  */
////////////////////////////////////////////////////////////////////////////////

clear
set more off, permanently

// ---------------------------------------------------------------------------//
// 		        		  	Long differences						       	  //	
// ---------------------------------------------------------------------------//

clear 
use "$DATA"
global poor "yr1950xpoor40 yr1960xpoor40 yr1970xpoor40 yr1980xpoor40"
global middle "yr1950xmiddle40 yr1960xmiddle40 yr1970xmiddle40 yr1980xmiddle40"
global rich "yr1950xrich40 yr1960xrich40 yr1970xrich40 yr1980xrich40"

cap erase Results/rf_t4p1.tex
cap erase Results/rf_t4p1.txt

foreach x in yr1980xshnr1970 yr1980xsnr yr1980xL_PRODUCTION yr1980xL_DIAMONDS yr1980xRELPOL yr1980xRELFRAC yr1980xavelf yr1980xETHFRAC{
xtreg propconflictCOW2 compsjmhatit `x' yr1940- yr1980  if newsample40_COW==1 & (year==1940 | year==1980),  fe cluster(ctrycluster)
test `x'
if `r(p)'<0.01 & `r(p)'!=0{
outreg2 using Results/rf_t4p1.tex, keep(compsjmhatit) tex(frag) dec(3) /*noas*/ addstat(Number of clusters, e(N_clust)9 addtext(\parbox{7cm}{p-value for post year dummy x variable indicated at the top of each column},  "<0.01" )  ctitle("`x'") nor2 nocon label less(0) append noaster
}
else{
outreg2 using Results/rf_t4p1.tex, keep(compsjmhatit) tex(frag) dec(3) /*noas*/ addstat(Number of clusters, e(N_clust), \parbox{7cm}{p-value for post year dummy x variable indicated at the top of each column},  `r(p)' )  ctitle("`x'") nor2 nocon label less(0) append noaster
}
}
xtreg propconflictCOW2 compsjmhatit yr1980xcatho80 yr1980xmuslim80 yr1980xprotmg80 yr1940- yr1980  if newsample40_COW==1 & (year==1940 | year==1980),  fe cluster(ctrycluster)
test yr1980xcatho80 yr1980xmuslim80 yr1980xprotmg80
if `r(p)'<0.01 & `r(p)'!=0{
outreg2 using Results/rf_t4p1.tex, keep(compsjmhatit) tex(frag) dec(3) /*noas*/ addstat(Number of clusters, e(N_clust)9 addtext(\parbox{7cm}{p-value for post year dummy x variable indicated at the top of each column},  "<0.01" )  ctitle("`x'") nor2 nocon label less(0) append noaster
}
else{
outreg2 using Results/rf_t4p1.tex, keep(compsjmhatit) tex(frag) dec(3) /*noas*/ addstat(Number of clusters, e(N_clust), \parbox{7cm}{p-value for post year dummy x variable indicated at the top of each column},  `r(p)' )  ctitle("`x'") nor2 nocon label less(0) append noaster
}
xtreg propconflictCOW2 compsjmhatit yr1980xindep1940 yr1940- yr1980  if newsample40_COW==1 & (year==1940 | year==1980),  fe cluster(ctrycluster)
test yr1980xindep1940
if `r(p)'<0.01 & `r(p)'!=0{
outreg2 using Results/rf_t4p1.tex, keep(compsjmhatit) tex(frag) dec(3) /*noas*/ addstat(Number of clusters, e(N_clust)9 addtext(\parbox{7cm}{p-value for post year dummy x variable indicated at the top of each column},  "<0.01" )  ctitle("`x'") nor2 nocon label less(0) append noaster
}
else{
outreg2 using Results/rf_t4p1.tex, keep(compsjmhatit) tex(frag) dec(3) /*noas*/ addstat(Number of clusters, e(N_clust), \parbox{7cm}{p-value for post year dummy x variable indicated at the top of each column},  `r(p)' )  ctitle("`x'") nor2 nocon label less(0) append noaster
}
xtreg propconflictCOW2 compsjmhatit yr1980xpoor40 yr1980xmiddle40 yr1980xrich40 yr1940- yr1980  if newsample40_COW==1 & (year==1940 | year==1980),  fe cluster(ctrycluster)
test yr1980xpoor40 yr1980xmiddle40 yr1980xrich40
if `r(p)'<0.01 & `r(p)'!=0{
outreg2 using Results/rf_t4p1.tex, keep(compsjmhatit) tex(frag) dec(3) /*noas*/ addstat(Number of clusters, e(N_clust)) addtext(\parbox{7cm}{p-value for post year dummy x variable indicated at the top of each column},  "<0.01")  ctitle("`x'") nor2 nocon label less(0) append noaster
}
else{
outreg2 using Results/rf_t4p1.tex, keep(compsjmhatit) tex(frag) dec(3) /*noas*/ addstat(Number of clusters, e(N_clust), \parbox{7cm}{p-value for post year dummy x variable indicated at the top of each column},  `r(p)')  ctitle("`x'") nor2 nocon label less(0) append noaster
}
cap erase Results/rf_t4p1.txt

// ---------------------------------------------------------------------------//
// 		        		  			Panel							       	  //	
// ---------------------------------------------------------------------------//

cap erase Results/rf_t4p2.tex
cap erase Results/rf_t4p2.txt

foreach x in shnr1970 snr L_PRODUCTION L_DIAMONDS RELPOL RELFRAC avelf ETHFRAC{
xtreg propconflictCOW2 yr1950x`x' yr1960x`x' yr1970x`x' yr1980x`x' yr1940- yr1980 compsjmhatit if year>1930 & year<1990,  fe cluster(ctrycluster)
testparm yr1950x`x' yr1960x`x' yr1970x`x' yr1980x`x'
if `r(p)'<0.01 & `r(p)'!=0{
outreg2 using Results/rf_t4p2.tex, keep(compsjmhatit) tex(frag) dec(3) /*noas*/ addstat(Number of clusters, e(N_clust)) addtext(\parbox{7cm}{p-value for post year dummy x variable indicated at the top of each column},  "<0.01" ) ctitle("`x'") nor2 nocon label less(0) append noaster

}
else{
outreg2 using Results/rf_t4p2.tex, keep(compsjmhatit) tex(frag) dec(3) /*noas*/ addstat(Number of clusters, e(N_clust), \parbox{7cm}{p-value for post year dummy x variable indicated at the top of each column},  `r(p)' ) ctitle("`x'") nor2 nocon label less(0) append noaster
}
}
xtreg propconflictCOW2 yr1950xcatho80-yr1980xcatho80 yr1950xmuslim80-yr1980xmuslim80 yr1950xprotmg80-yr1980xprotmg80 yr1940- yr1980 compsjmhatit if year>1930 & year<1990,  fe cluster(ctrycluster)
testparm yr1950xcatho80 yr1960xcatho80 yr1970xcatho80 yr1980xcatho80 yr1950xmuslim80 yr1960xmuslim80 yr1970xmuslim80 yr1980xmuslim80 yr1950xprotmg80 yr1960xprotmg80 yr1970xprotmg80 yr1980xprotmg80
if `r(p)'<0.01 & `r(p)'!=0{
outreg2 using Results/rf_t4p2.tex, keep(compsjmhatit) tex(frag) dec(3) /*noas*/ addstat(Number of clusters, e(N_clust)) addtext(\parbox{7cm}{p-value for post year dummy x variable indicated at the top of each column},  "<0.01" ) ctitle("`x'") nor2 nocon label less(0) append noaster
}
else{
outreg2 using Results/rf_t4p2.tex, keep(compsjmhatit) tex(frag) dec(3) /*noas*/ addstat(Number of clusters, e(N_clust), \parbox{7cm}{p-value for post year dummy x variable indicated at the top of each column},  `r(p)' ) ctitle("`x'") nor2 nocon label less(0) append noaster
}
xtreg propconflictCOW2 yr1950xindep1940 yr1960xindep1940 yr1970xindep1940 yr1980xindep1940 yr1940- yr1980 compsjmhatit if year>1930 & year<1990,  fe cluster(ctrycluster)
testparm yr1950xindep1940 yr1960xindep1940 yr1970xindep1940 yr1980xindep1940
if `r(p)'<0.01 & `r(p)'!=0{
outreg2 using Results/rf_t4p2.tex, keep(compsjmhatit) tex(frag) dec(3) /*noas*/ addstat(Number of clusters, e(N_clust)) addtext(\parbox{7cm}{p-value for post year dummy x variable indicated at the top of each column},  "<0.01" ) ctitle("`x'") nor2 nocon label less(0) append noaster
}
else{
outreg2 using Results/rf_t4p2.tex, keep(compsjmhatit) tex(frag) dec(3) /*noas*/ addstat(Number of clusters, e(N_clust), \parbox{7cm}{p-value for post year dummy x variable indicated at the top of each column},  `r(p)' ) ctitle("`x'") nor2 nocon label less(0) append noaster
}
xtreg propconflictCOW2 $poor $rich $middle  yr1940- yr1980 compsjmhatit if year>1930 & year<1990,  fe cluster(ctrycluster)
testparm $poor $rich $middle 
if `r(p)'<0.01 & `r(p)'!=0{
outreg2 using Results/rf_t4p2.tex, keep(compsjmhatit) tex(frag) dec(3) /*noas*/ addstat(Number of clusters, e(N_clust)) addtext(\parbox{7cm}{p-value for post year dummy x variable indicated at the top of each column},  "<0.01")  ctitle("`x'") nor2 nocon label less(0) append noaster
}
else{
outreg2 using Results/rf_t4p2.tex, keep(compsjmhatit) tex(frag) dec(3) /*noas*/ addstat(Number of clusters, e(N_clust), \parbox{7cm}{p-value for post year dummy x variable indicated at the top of each column},  `r(p)')  ctitle("`x'") nor2 nocon label less(0) append noaster
}

cap erase Results/rf_t4p2.txt
