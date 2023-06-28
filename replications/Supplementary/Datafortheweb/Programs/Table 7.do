////////////////////////////////////////////////////////////////////////////////
/*									TABLE 7									  */
////////////////////////////////////////////////////////////////////////////////

clear
set more off, permanently

// ---------------------------------------------------------------------------//
// 		        		  	Create new variables					       	  //	
// ---------------------------------------------------------------------------//

clear
use "$DATA"

/*Create war in 1900, 1910, 1920, 1930, 1940*/
forvalues year=1900(10)1940 {
gen temp=.
replace temp=propconflictCOW2 if year==`year'
bysort ctry: egen initial_conflict_`year'=mean(temp)
drop temp

/*And interactions with post years*/
forvalues yyear=1950(10)2000 {
gen yr`yyear'xinitial_conflict_`year'=yr`yyear'*initial_conflict_`year'
} 
}
xtset countrynum year, delta(10)
gen lpropconflictCOW2=L.propconflictCOW2
label var lpropconflictCOW2 "lagged conflict"

// ---------------------------------------------------------------------------//
// 		        		  	2SLS Including Initial War		 		      	  //	
// ---------------------------------------------------------------------------//

/*Column 1, simple 2SLS without differential trends*/
xtivreg2 propconflictCOW2 (logmaddpop=compsjmhatit) yr1940- yr1980 if year>1930 & year<1990, fe cluster(ctrycluster) robust
matrix coefs = e(b)
local beta = coefs[1,1]
local junk = `beta'*0.10
local effect = round(`junk', 0.001)
display `beta' "//" `effect' "//" `junk'
outreg2 logmaddpop using Results/iv_Bloom.tex, keep(logmaddpop) addstat(Number of clusters, e(N_clust)) addtext(\parbox{7cm}{Effect of an increase of 0.10 in log pop from 1940 to 1980}, `effect') tex(frag) dec(3) /*noas*/ nor2 nocon label less(0) replace noaster

/*Column 2, simple 2SLS without differential trends for the sample with Initial War Data*/
xtivreg2 propconflictCOW2 (logmaddpop=compsjmhatit) yr1940- yr1980 if year>1930 & year<1990 & initial_conflict_1940~=., fe cluster(ctrycluster) robust
matrix coefs = e(b)
local beta = coefs[1,1]
local junk = `beta'*0.10
local effect = round(`junk', 0.001)
display `beta' "//" `effect' "//" `junk'
outreg2 logmaddpop using Results/iv_Bloom.tex, keep(logmaddpop) addstat(Number of clusters, e(N_clust)) addtext(\parbox{7cm}{Effect of an increase of 0.10 in log pop from 1940 to 1980}, `effect') tex(frag) dec(3) /*noas*/ nor2 nocon label less(0) append noaster

/*Column 3, simple 2SLS with differential trends*/
xtivreg2 propconflictCOW2 (logmaddpop=compsjmhatit) yr1940- yr1980 yr1950xinitial_conflict_1940-yr1990xinitial_conflict_1940 if year>1930 & year<1990 & initial_conflict_1940~=., fe cluster(ctrycluster) robust
matrix coefs = e(b)
local beta = coefs[1,1]
local junk = `beta'*0.10
local effect = round(`junk', 0.001)
display `beta' "//" `effect' "//" `junk'
testparm yr1950xinitial_conflict_1940-yr1990xinitial_conflict_1940
if `r(p)'<0.01 & `r(p)'!=0{
outreg2 logmaddpop using Results/iv_Bloom.tex, keep(logmaddpop) addstat(Number of clusters, e(N_clust)) addtext(\parbox{7cm}{p-value for post year dummy x initial war},  "<0.01", \parbox{7cm}{Effect of an increase of 0.10 in log pop from 1940 to 1980}, `effect')  tex(frag) dec(3) nor2 nocon label less(0) append noaster
}
else{
outreg2 logmaddpop using Results/iv_Bloom.tex, keep(logmaddpop) addstat(Number of clusters, e(N_clust), \parbox{7cm}{p-value for post year dummy x initial war},  `r(p)') addtext(\parbox{7cm}{Effect of an increase of 0.10 in log pop from 1940 to 1980}, `effect') tex(frag) dec(3)  nor2 nocon label less(0) append noaster
}

/*Column 4, simple 2SLS with differential trends, includes lagged war*/
xtivreg2 propconflictCOW2 lpropconflictCOW2 (logmaddpop=compsjmhatit) yr1940- yr1980 yr1950xinitial_conflict_1940-yr1990xinitial_conflict_1940 if year>1930 & year<1990 & initial_conflict_1940~=., fe cluster(ctrycluster) robust
matrix coefs = e(b)
local beta = coefs[1,1]
local alpha = coefs[1,2]
local junk = (`beta'/(1-`alpha'))*0.10
local effect = round(`junk',0.001)
display `beta' "//" `alpha' "//" `effect' "//" `junk'
testparm yr1950xinitial_conflict_1940-yr1990xinitial_conflict_1940
if `r(p)'<0.01 & `r(p)'!=0{
outreg2 logmaddpop using Results/iv_Bloom.tex, keep(logmaddpop lpropconflictCOW2) addstat(Number of clusters, e(N_clust)) addtext(\parbox{7cm}{p-value for post year dummy x initial war},  "<0.01", \parbox{7cm}{Effect of an increase of 0.10 in log pop from 1940 to 1980}, `effect')  tex(frag) dec(3)  nor2 nocon label less(0) append noaster
}
else{
outreg2 logmaddpop using Results/iv_Bloom.tex, keep(logmaddpop lpropconflictCOW2) addstat(Number of clusters, e(N_clust), \parbox{7cm}{p-value for post year dummy x initial war},  `r(p)') addtext(\parbox{7cm}{Effect of an increase of 0.10 in log pop from 1940 to 1980}, `effect') tex(frag) dec(3)  nor2 nocon label less(0) append noaster
}

// ---------------------------------------------------------------------------//
// 		        		  		Arellano & Bond						       	  //	
// ---------------------------------------------------------------------------//
/*Column 5, arellano bond estimates using all internal lags as instruments*/
xtabond2 propconflictCOW2 lpropconflictCOW2 logmaddpop yr1940- yr1980 yr1950xinitial_conflict_1940-yr1990xinitial_conflict_1940 if year>1930 & year<1990 & initial_conflict_1940~=., gmmstyle(propconflictCOW2, laglimits(2 .)) gmmstyle(compsjmhatit, laglimits(1 .)) ivstyle(yr1940- yr1980 yr1950xinitial_conflict_1930-yr1990xinitial_conflict_1930,p) noleveleq robust twostep
matrix coefs = e(b)
local beta = coefs[1,2]
local alpha = coefs[1,1]
local junk =  (`beta'/(1-`alpha'))*0.10
local effect = round(`junk',0.001)
display `beta' "//" `alpha' "//" `effect' "//" `junk'
testparm yr1950xinitial_conflict_1940-yr1990xinitial_conflict_1940
if `r(p)'<0.01 & `r(p)'!=0{
outreg2 logmaddpop using Results/iv_Bloom.tex, keep(logmaddpop lpropconflictCOW2) addstat(Moments, e(j), Hansen p-value, e(hansenp), AR2 p-value, e(ar2p)) addtext(\parbox{7cm}{p-value for post year dummy x initial war},  "<0.01", \parbox{7cm}{Effect of an increase of 0.10 in log pop from 1940 to 1980}, `effect')  tex(frag) dec(3)  nor2 nocon label less(0) append noaster
}
else{
outreg2 logmaddpop using Results/iv_Bloom.tex, keep(logmaddpop lpropconflictCOW2) addstat(Moments, e(j), Hansen p-value, e(hansenp), AR2 p-value, e(ar2p), \parbox{7cm}{p-value for post year dummy x initial war},  `r(p)') addtext(\parbox{7cm}{Effect of an increase of 0.10 in log pop from 1940 to 1980}, `effect') tex(frag) dec(3) nor2 nocon label less(0) append noaster
}

// ---------------------------------------------------------------------------//
// 		        		  	2SLS Including Initial Pop		 		      	  //	
// ---------------------------------------------------------------------------//
/*Column 6, simple 2SLS with differential trends*/
xtivreg2 propconflictCOW2 (logmaddpop=compsjmhatit) yr1940- yr1980 yr1950xlogmaddpop40 yr1960xlogmaddpop40 yr1970xlogmaddpop40 yr1980xlogmaddpop40 if year>1930 & year<1990, fe cluster(ctrycluster) robust
matrix coefs = e(b)
local beta = coefs[1,1]
local junk = `beta'*0.10
local effect = round(`junk', 0.001)
display `beta' "//" `effect' "//" `junk'
testparm yr1950xlogmaddpop40 yr1960xlogmaddpop40 yr1970xlogmaddpop40 yr1980xlogmaddpop40
if `r(p)'<0.01 & `r(p)'!=0{
outreg2 logmaddpop using Results/iv_Bloom.tex, keep(logmaddpop) addstat(Number of clusters, e(N_clust)) addtext(\parbox{7cm}{p-value for post year dummy x initial war},  "<0.01", \parbox{7cm}{Effect of an increase of 0.10 in log pop from 1940 to 1980}, `effect')  tex(frag) dec(3) nor2 nocon label less(0) append noaster
}
else{
outreg2 logmaddpop using Results/iv_Bloom.tex, keep(logmaddpop) addstat(Number of clusters, e(N_clust), \parbox{7cm}{p-value for post year dummy x initial war},  `r(p)') addtext(\parbox{7cm}{Effect of an increase of 0.10 in log pop from 1940 to 1980}, `effect') tex(frag) dec(3)  nor2 nocon label less(0) append noaster
}

/*Column 7, simple 2SLS with differential trends, includes lagged war*/
xtivreg2 propconflictCOW2 lpropconflictCOW2 (logmaddpop=compsjmhatit) yr1940- yr1980 yr1950xlogmaddpop40 yr1960xlogmaddpop40 yr1970xlogmaddpop40 yr1980xlogmaddpop40 if year>1930 & year<1990, fe cluster(ctrycluster) robust
matrix coefs = e(b)
local beta = coefs[1,1]
local alpha = coefs[1,2]
local junk =  (`beta'/(1-`alpha'))*0.10
local effect = round(`junk',0.001) 
display `beta' "//" `alpha' "//" `effect' "//" `junk'
testparm yr1950xlogmaddpop40 yr1960xlogmaddpop40 yr1970xlogmaddpop40 yr1980xlogmaddpop40
if `r(p)'<0.01 & `r(p)'!=0{
outreg2 logmaddpop using Results/iv_Bloom.tex, keep(logmaddpop lpropconflictCOW2) addstat(Number of clusters, e(N_clust)) addtext(\parbox{7cm}{p-value for post year dummy x initial war},  "<0.01", \parbox{7cm}{Effect of an increase of 0.10 in log pop from 1940 to 1980}, `effect')  tex(frag) dec(3)  nor2 nocon label less(0) append noaster
}
else{
outreg2 logmaddpop using Results/iv_Bloom.tex, keep(logmaddpop lpropconflictCOW2) addstat(Number of clusters, e(N_clust), \parbox{7cm}{p-value for post year dummy x initial war},  `r(p)') addtext(\parbox{7cm}{Effect of an increase of 0.10 in log pop from 1940 to 1980}, `effect') tex(frag) dec(3)  nor2 nocon label less(0) append noaster
}


/*Column 8, arellano bond estimates using all internal lags as instruments*/
xtabond2 propconflictCOW2 lpropconflictCOW2 logmaddpop yr1940- yr1980 yr1950xlogmaddpop40 yr1960xlogmaddpop40 yr1970xlogmaddpop40 yr1980xlogmaddpop40 if year>1930 & year<1990, gmmstyle(propconflictCOW2, laglimits(2 .)) gmmstyle(compsjmhatit, laglimits(1 .)) ivstyle(yr1940- yr1980 yr1950xlogmaddpop40 yr1960xlogmaddpop40 yr1970xlogmaddpop40 yr1980xlogmaddpop40,p) noleveleq robust twostep
matrix coefs = e(b)
local beta = coefs[1,2]
local alpha = coefs[1,1]
local junk =  (`beta'/(1-`alpha'))*0.10
local effect = round(`junk',0.001) 
display `beta' "//" `alpha' "//" `effect' "//" `junk'
testparm yr1950xlogmaddpop40 yr1960xlogmaddpop40 yr1970xlogmaddpop40 yr1980xlogmaddpop40
if `r(p)'<0.01 & `r(p)'!=0{
outreg2 logmaddpop using Results/iv_Bloom.tex, keep(logmaddpop lpropconflictCOW2) addstat(Moments, e(j), Hansen p-value, e(hansenp), AR2 p-value, e(ar2p)) addtext(\parbox{7cm}{p-value for post year dummy x initial war},  "<0.01", \parbox{7cm}{Effect of an increase of 0.10 in log pop from 1940 to 1980}, `effect')  tex(frag) dec(3)  nor2 nocon label less(0) append noaster
}
else{
outreg2 logmaddpop using Results/iv_Bloom.tex, keep(logmaddpop lpropconflictCOW2) addstat(Moments, e(j), Hansen p-value, e(hansenp), AR2 p-value, e(ar2p), \parbox{7cm}{p-value for post year dummy x initial war},  `r(p)') addtext(\parbox{7cm}{Effect of an increase of 0.10 in log pop from 1940 to 1980}, `effect') tex(frag) dec(3) nor2 nocon label less(0) append noaster
}


// ---------------------------------------------------------------------------//
// 		        		  		Nonlinear GMM				 		      	  //	
// ---------------------------------------------------------------------------//

/*Column 9, nonlinear GMM approach */

clear
use "$DATA"
quietly: tab year, gen(yy) 
gen time=year/10-193
xtset countrynum time

gmm (D.propconflictCOW2-{beta}*D.logmaddpop-{lambda}*{beta}*L.logmaddpop+{lambda}*L.propconflictCOW2-{time: yr1950 yr1960 yr1970 yr1980}) if year>1940&year<1990, instruments(yr1940-yr1980, noconstant) xtinstruments(compsjmhatit, lags(1/ .)) xtinstruments(propconflictCOW2, lags(2/ .)) winitial(xt D) wmatrix(cluster ctrycluster) 
matrix coefs = e(b)
local pi = coefs[1,1]
local lambda = coefs[1,2]
local junk = `pi'*0.1
local effect = round(`junk',0.001) 
display `pi' "//" `lambda' "//" `effect' "//" `junk'
estat overid

* Some edit of the output is necesary
cap erase Results/iv_Bloom.txt
