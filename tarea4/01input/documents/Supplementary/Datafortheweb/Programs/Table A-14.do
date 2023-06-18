////////////////////////////////////////////////////////////////////////////////
/*							    	TABLE A14								  */
////////////////////////////////////////////////////////////////////////////////

clear
set more off, permanently

// ---------------------------------------------------------------------------//
// 						 LONG DIFFERENCES: COL 1							  //	
// ---------------------------------------------------------------------------//
clear 
use "$DATA"
keep country year compsjmhatit cholera-I_diptheria yr1940xcholera - yr1980xyellowfever yr1940 yr1950 yr1960 yr1970 yr1980 propconflictCOW2 logmaddpop ctrycluster countrynum newsample40_COW EE WE startrich wwii
order country  countrynum year compsjmhatit propconflictCOW2 logmaddpop yr1940 yr1950 yr1960 yr1970 yr1980 yr1940xcholera - yr1980xyellowfever


global yr1940 "yr1940xcholera yr1940xtyphus yr1940xplague yr1940xmalaria yr1940xwcough yr1940xscarfever yr1940xdiptheria yr1940xmeasles yr1940xpneumonia yr1940xinfluenza yr1940xtyphoid yr1940xtball yr1940xsmallpox yr1940xyellowfever"
global yr1980 "yr1980xcholera yr1980xtyphus yr1980xplague yr1980xmalaria yr1980xwcough yr1980xscarfever yr1980xdiptheria yr1980xmeasles yr1980xpneumonia yr1980xinfluenza yr1980xtyphoid yr1980xtball yr1980xsmallpox yr1980xyellowfever"
global disease "cholera typhus plague malaria wcough scarfever diptheria measles pneumonia influenza typhoid tball smallpox yellowfever"
global intervention "I_cholera I_typhus I_plague I_malaria I_wcough I_scarfever I_diptheria I_measles I_pneumonia I_influenza I_typhoid I_tball I_smallpox I_yellowfever"

preserve
keep if newsample40_COW==1 & (year==1940 | year==1980)

foreach var of varlist propconflictCOW2 logmaddpop yr1940xcholera-yr1980xyellowfever yr1940 yr1950 yr1960 yr1970 compsjmhatit{
sort country
by country: egen `var'_prom=mean(`var') 
gen `var'_within=`var'-`var'_prom 
replace  `var' = `var'_within
drop `var'_within `var'_prom
}


bartik_weight, z($yr1940 $yr1980) weightstub($intervention) x(logmaddpop) y(propconflictCOW2) controls(yr1980) by(year)
mat beta_ld_1 = r(beta)
mat alpha_ld_1 = r(alpha)
mat G_ld_1 = r(G)

qui desc $yr1940 $yr1980, varlist
local varlist = r(varlist)
display `varlist'

clear
svmat beta_ld_1
svmat alpha_ld_1
svmat G_ld_1

qui gen disease = ""
qui gen year = ""
local t = 1
foreach var in `varlist' {
foreach x in $disease{
	if regexm("`var'", "yr(.*)x`x'") {
		qui replace year = regexs(1) if _n == `t'
		qui replace disease = regexs(0) if _n == `t'
		}
		}
	local t = `t' + 1
}

replace disease = substr(disease,8,.)

tempfile col1
save `col1', replace 
restore

// ---------------------------------------------------------------------------//
// 						 LONG DIFFERENCES: COL 2							  //	
// ---------------------------------------------------------------------------//
preserve
keep if newsample40_COW==1 & (year==1940 | year==1980) & EE!=1

foreach var of varlist propconflictCOW2 logmaddpop yr1940xcholera-yr1980xyellowfever yr1940 yr1950 yr1960 yr1970 compsjmhatit{
sort country
by country: egen `var'_prom=mean(`var') 
gen `var'_within=`var'-`var'_prom 
replace  `var' = `var'_within
drop `var'_within `var'_prom
}

bartik_weight, z($yr1940 $yr1980) weightstub($intervention) x(logmaddpop) y(propconflictCOW2) controls(yr1980) by(year)
mat beta_ld_2 = r(beta)
mat alpha_ld_2 = r(alpha)
mat G_ld_2 = r(G)

qui desc $yr1940 $yr1980, varlist
local varlist = r(varlist)
display `varlist'

clear
svmat beta_ld_2
svmat alpha_ld_2
svmat G_ld_2

qui gen disease = ""
qui gen year = ""
local t = 1
foreach var in `varlist' {
foreach x in $disease{
	if regexm("`var'", "yr(.*)x`x'") {
		qui replace year = regexs(1) if _n == `t'
		qui replace disease = regexs(0) if _n == `t'
		}
		}
	local t = `t' + 1
}

replace disease = substr(disease,8,.)

tempfile col2
save `col2', replace 
restore
// ---------------------------------------------------------------------------//
// 						 LONG DIFFERENCES: COL 3							  //	
// ---------------------------------------------------------------------------//
preserve
keep if newsample40_COW==1 & (year==1940 | year==1980) & WE!=1

foreach var of varlist propconflictCOW2 logmaddpop yr1940xcholera-yr1980xyellowfever yr1940 yr1950 yr1960 yr1970 compsjmhatit{
sort country
by country: egen `var'_prom=mean(`var') 
gen `var'_within=`var'-`var'_prom 
replace  `var' = `var'_within
drop `var'_within `var'_prom
}


bartik_weight, z($yr1940 $yr1980) weightstub($intervention) x(logmaddpop) y(propconflictCOW2) controls(yr1980) by(year)
mat beta_ld_3 = r(beta)
mat alpha_ld_3 = r(alpha)
mat G_ld_3 = r(G)

qui desc $yr1940 $yr1980, varlist
local varlist = r(varlist)
display `varlist'

clear
svmat beta_ld_3
svmat alpha_ld_3
svmat G_ld_3


qui gen disease = ""
qui gen year = ""
local t = 1
foreach var in `varlist' {
foreach x in $disease{
	if regexm("`var'", "yr(.*)x`x'") {
		qui replace year = regexs(1) if _n == `t'
		qui replace disease = regexs(0) if _n == `t'
		}
		}
	local t = `t' + 1
}

replace disease = substr(disease,8,.)

tempfile col3
save `col3', replace 
restore

// ---------------------------------------------------------------------------//
// 						 LONG DIFFERENCES: COL 4							  //	
// ---------------------------------------------------------------------------//
preserve
keep if newsample40_COW==1 & (year==1940 | year==1980) & startrich!=1

foreach var of varlist propconflictCOW2 logmaddpop yr1940xcholera-yr1980xyellowfever yr1940 yr1950 yr1960 yr1970 compsjmhatit{
sort country
by country: egen `var'_prom=mean(`var') 
gen `var'_within=`var'-`var'_prom 
replace  `var' = `var'_within
drop `var'_within `var'_prom
}


bartik_weight, z($yr1940 $yr1980) weightstub($intervention) x(logmaddpop) y(propconflictCOW2) controls(yr1980) by(year)
mat beta_ld_4 = r(beta)
mat alpha_ld_4 = r(alpha)
mat G_ld_4 = r(G)

qui desc $yr1940 $yr1980, varlist
local varlist = r(varlist)
display `varlist'

clear
svmat beta_ld_4
svmat alpha_ld_4
svmat G_ld_4


qui gen disease = ""
qui gen year = ""
local t = 1
foreach var in `varlist' {
foreach x in $disease{
	if regexm("`var'", "yr(.*)x`x'") {
		qui replace year = regexs(1) if _n == `t'
		qui replace disease = regexs(0) if _n == `t'
		}
		}
	local t = `t' + 1
}

replace disease = substr(disease,8,.)

tempfile col4
save `col4', replace 
restore
// ---------------------------------------------------------------------------//
// 						 LONG DIFFERENCES: COL 5							  //	
// ---------------------------------------------------------------------------//
preserve
keep if newsample40_COW==1 & (year==1940 | year==1980) & wwii!=1

foreach var of varlist propconflictCOW2 logmaddpop yr1940xcholera-yr1980xyellowfever yr1940 yr1950 yr1960 yr1970 compsjmhatit{
sort country
by country: egen `var'_prom=mean(`var') 
gen `var'_within=`var'-`var'_prom 
replace  `var' = `var'_within
drop `var'_within `var'_prom
}


bartik_weight, z($yr1940 $yr1980) weightstub($intervention) x(logmaddpop) y(propconflictCOW2) controls(yr1980) by(year)
mat beta_ld_5 = r(beta)
mat alpha_ld_5 = r(alpha)
mat G_ld_5 = r(G)

qui desc $yr1940 $yr1980, varlist
local varlist = r(varlist)
display `varlist'

clear
svmat beta_ld_5
svmat alpha_ld_5
svmat G_ld_5


qui gen disease = ""
qui gen year = ""
local t = 1
foreach var in `varlist' {
foreach x in $disease{
	if regexm("`var'", "yr(.*)x`x'") {
		qui replace year = regexs(1) if _n == `t'
		qui replace disease = regexs(0) if _n == `t'
		}
		}
	local t = `t' + 1
}

replace disease = substr(disease,8,.)

tempfile col5
save `col5', replace 
restore
// ---------------------------------------------------------------------------//
// 						 LONG DIFFERENCES: COL 6							  //	
// ---------------------------------------------------------------------------//
preserve
keep if newsample40_COW==1 & (year==1940 | year==1980)

foreach var of varlist propconflictCOW2 logmaddpop yr1940xcholera-yr1980xyellowfever yr1940 yr1950 yr1960 yr1970 compsjmhatit{
sort country
by country: egen `var'_prom=mean(`var') 
gen `var'_within=`var'-`var'_prom 
replace  `var' = `var'_within
drop `var'_within `var'_prom
}

global intervention "I_cholera I_typhus I_plague I_malaria I_wcough I_scarfever I_diptheria I_measles I_influenza I_typhoid I_tball I_smallpox I_yellowfever"
global yr1940 "yr1940xcholera yr1940xtyphus yr1940xplague yr1940xmalaria yr1940xwcough yr1940xscarfever yr1940xdiptheria yr1940xmeasles yr1940xinfluenza yr1940xtyphoid yr1940xtball yr1940xsmallpox yr1940xyellowfever"
global yr1980 "yr1980xcholera yr1980xtyphus yr1980xplague yr1980xmalaria yr1980xwcough yr1980xscarfever yr1980xdiptheria yr1980xmeasles yr1980xinfluenza yr1980xtyphoid yr1980xtball yr1980xsmallpox yr1980xyellowfever"


bartik_weight, z($yr1940 $yr1980) weightstub($intervention) x(logmaddpop) y(propconflictCOW2) controls(yr1980) by(year)
mat beta_ld_6 = r(beta)
mat alpha_ld_6 = r(alpha)
mat G_ld_6 = r(G)

qui desc $yr1940 $yr1980, varlist
local varlist = r(varlist)
display `varlist'

clear
svmat beta_ld_6
svmat alpha_ld_6
svmat G_ld_6


qui gen disease = ""
qui gen year = ""
local t = 1
foreach var in `varlist' {
foreach x in $disease{
	if regexm("`var'", "yr(.*)x`x'") {
		qui replace year = regexs(1) if _n == `t'
		qui replace disease = regexs(0) if _n == `t'
		}
		}
	local t = `t' + 1
}

replace disease = substr(disease,8,.)

tempfile col6
save `col6', replace 
restore
// ---------------------------------------------------------------------------//
// 						 LONG DIFFERENCES: MERGE							  //	
// ---------------------------------------------------------------------------//
clear
use `col1'
forvalues j=2/6{
merge 1:1 disease year using `col`j''
drop _merge
}

keep disease year alpha_ld_11 alpha_ld_21 alpha_ld_31 alpha_ld_41 alpha_ld_51 alpha_ld_61
order disease year alpha_ld_11 alpha_ld_21 alpha_ld_31 alpha_ld_41 alpha_ld_51 alpha_ld_61
drop if year=="1980"
drop if disease=="yellowfever"

rename alpha_ld_11 alpha1
rename alpha_ld_21 alpha2
rename alpha_ld_31 alpha3
rename alpha_ld_41 alpha4
rename alpha_ld_51 alpha5
rename alpha_ld_61 alpha6

foreach var of varlist alpha1-alpha6{
egen rank_`var' = rank(`var')
}

sort rank_alpha1
tempfile LONG
save `LONG', replace


// ---------------------------------------------------------------------------//
// 								PANEL: COL 1								  //	
// ---------------------------------------------------------------------------//

clear 
use "$DATA"

global intervention "I_cholera I_typhus I_plague I_malaria I_wcough I_scarfever I_diptheria I_measles I_pneumonia I_influenza I_typhoid I_tball I_smallpox I_yellowfever"
global yr1940 "yr1940xcholera yr1940xtyphus yr1940xplague yr1940xmalaria yr1940xwcough yr1940xscarfever yr1940xdiptheria yr1940xmeasles yr1940xpneumonia yr1940xinfluenza yr1940xtyphoid yr1940xtball yr1940xsmallpox yr1940xyellowfever"
global yr1950 "yr1950xcholera yr1950xtyphus yr1950xplague yr1950xmalaria yr1950xwcough yr1950xscarfever yr1950xdiptheria yr1950xmeasles yr1950xpneumonia yr1950xinfluenza yr1950xtyphoid yr1950xtball yr1950xsmallpox yr1950xyellowfever"
global yr1960 "yr1960xcholera yr1960xtyphus yr1960xplague yr1960xmalaria yr1960xwcough yr1960xscarfever yr1960xdiptheria yr1960xmeasles yr1960xpneumonia yr1960xinfluenza yr1960xtyphoid yr1960xtball yr1960xsmallpox yr1960xyellowfever"
global yr1970 "yr1970xcholera yr1970xtyphus yr1970xplague yr1970xmalaria yr1970xwcough yr1970xscarfever yr1970xdiptheria yr1970xmeasles yr1970xpneumonia yr1970xinfluenza yr1970xtyphoid yr1970xtball yr1970xsmallpox yr1970xyellowfever"
global yr1980 "yr1980xcholera yr1980xtyphus yr1980xplague yr1980xmalaria yr1980xwcough yr1980xscarfever yr1980xdiptheria yr1980xmeasles yr1980xpneumonia yr1980xinfluenza yr1980xtyphoid yr1980xtball yr1980xsmallpox yr1980xyellowfever"

keep country year compsjmhatit cholera-I_diptheria yr1940xcholera - yr1980xyellowfever yr1940 yr1950 yr1960 yr1970 yr1980 propconflictCOW2 logmaddpop ctrycluster countrynum newsample40_COW EE WE startrich wwii
order country  countrynum year compsjmhatit propconflictCOW2 logmaddpop yr1940 yr1950 yr1960 yr1970 yr1980 yr1940xcholera - yr1980xyellowfever


preserve
keep if year>=1940 & year<=1980

drop if country=="ALGERIA"
drop if country=="AUSTRIA"
drop if country=="BANGLADESH"
drop if country=="EGYPT, ARAB REP."
drop if country=="IRAN, ISLAMIC REP."
drop if country=="IRAQ"
drop if country=="LEBANON"
drop if country=="MALAYSIA"
drop if country=="MOROCCO"
drop if country=="RUSSIAN FEDERATION"
drop if country=="SINGAPORE"
drop if country=="SOUTH AFRICA"
drop if country=="TUNISIA"
drop if country=="VIETNAM"

foreach var of varlist propconflictCOW2 logmaddpop yr1940xcholera-yr1980xyellowfever yr1940 yr1950 yr1960 yr1970 compsjmhatit{
sort country
by country: egen `var'_prom=mean(`var') 
gen `var'_within=`var'-`var'_prom 
replace  `var' = `var'_within
drop `var'_within `var'_prom
}

bartik_weight, z($yr1940 $yr1950 $yr1960 $yr1970 $yr1980) weightstub($intervention) x(logmaddpop) y(propconflictCOW2) controls(yr1940-yr1970) by(year)
mat beta_p_1 = r(beta)
mat alpha_p_1 = r(alpha)
mat G_p_1 = r(G)

qui desc $yr1940 $yr1950 $yr1960 $yr1970 $yr1980, varlist
local varlist = r(varlist)
display `varlist'

clear
svmat beta_p_1
svmat alpha_p_1
svmat G_p_1


qui gen disease = ""
qui gen year = ""
local t = 1
foreach var in `varlist' {
foreach x in $disease{
	if regexm("`var'", "yr(.*)x`x'") {
		qui replace year = regexs(1) if _n == `t'
		qui replace disease = regexs(0) if _n == `t'
		}
		}
	local t = `t' + 1
}

replace disease = substr(disease,8,.)

tempfile col1
save `col1', replace 
restore

// ---------------------------------------------------------------------------//
// 								PANEL: COL 2								  //	
// ---------------------------------------------------------------------------//

preserve
keep if year>=1940 & year<=1980 & EE!=1

drop if country=="ALGERIA"
drop if country=="AUSTRIA"
drop if country=="BANGLADESH"
drop if country=="EGYPT, ARAB REP."
drop if country=="IRAN, ISLAMIC REP."
drop if country=="IRAQ"
drop if country=="LEBANON"
drop if country=="MALAYSIA"
drop if country=="MOROCCO"
drop if country=="RUSSIAN FEDERATION"
drop if country=="SINGAPORE"
drop if country=="SOUTH AFRICA"
drop if country=="TUNISIA"
drop if country=="VIETNAM"


foreach var of varlist propconflictCOW2 logmaddpop yr1940xcholera-yr1980xyellowfever yr1940 yr1950 yr1960 yr1970 compsjmhatit{
sort country
by country: egen `var'_prom=mean(`var') 
gen `var'_within=`var'-`var'_prom 
replace  `var' = `var'_within
drop `var'_within `var'_prom
}

bartik_weight, z($yr1940 $yr1950 $yr1960 $yr1970 $yr1980) weightstub($intervention) x(logmaddpop) y(propconflictCOW2) controls(yr1940-yr1970) by(year)
mat beta_p_2 = r(beta)
mat alpha_p_2 = r(alpha)
mat G_p_2 = r(G)

qui desc $yr1940 $yr1950 $yr1960 $yr1970 $yr1980, varlist
local varlist = r(varlist)
display `varlist'

clear
svmat beta_p_2
svmat alpha_p_2
svmat G_p_2


qui gen disease = ""
qui gen year = ""
local t = 1
foreach var in `varlist' {
foreach x in $disease{
	if regexm("`var'", "yr(.*)x`x'") {
		qui replace year = regexs(1) if _n == `t'
		qui replace disease = regexs(0) if _n == `t'
		}
		}
	local t = `t' + 1
}

replace disease = substr(disease,8,.)

tempfile col2
save `col2', replace 
restore

// ---------------------------------------------------------------------------//
// 								PANEL: COL 3								  //	
// ---------------------------------------------------------------------------//

preserve
keep if year>=1940 & year<=1980 & WE!=1

drop if country=="ALGERIA"
drop if country=="AUSTRIA"
drop if country=="BANGLADESH"
drop if country=="EGYPT, ARAB REP."
drop if country=="IRAN, ISLAMIC REP."
drop if country=="IRAQ"
drop if country=="LEBANON"
drop if country=="MALAYSIA"
drop if country=="MOROCCO"
drop if country=="RUSSIAN FEDERATION"
drop if country=="SINGAPORE"
drop if country=="SOUTH AFRICA"
drop if country=="TUNISIA"
drop if country=="VIETNAM"

foreach var of varlist propconflictCOW2 logmaddpop yr1940xcholera-yr1980xyellowfever yr1940 yr1950 yr1960 yr1970 compsjmhatit{
sort country
by country: egen `var'_prom=mean(`var') 
gen `var'_within=`var'-`var'_prom 
replace  `var' = `var'_within
drop `var'_within `var'_prom
}

bartik_weight, z($yr1940 $yr1950 $yr1960 $yr1970 $yr1980) weightstub($intervention) x(logmaddpop) y(propconflictCOW2) controls(yr1940-yr1970) by(year)
mat beta_p_3 = r(beta)
mat alpha_p_3 = r(alpha)
mat G_p_3 = r(G)

qui desc $yr1940 $yr1950 $yr1960 $yr1970 $yr1980, varlist
local varlist = r(varlist)
display `varlist'

clear
svmat beta_p_3
svmat alpha_p_3
svmat G_p_3


qui gen disease = ""
qui gen year = ""
local t = 1
foreach var in `varlist' {
foreach x in $disease{
	if regexm("`var'", "yr(.*)x`x'") {
		qui replace year = regexs(1) if _n == `t'
		qui replace disease = regexs(0) if _n == `t'
		}
		}
	local t = `t' + 1
}

replace disease = substr(disease,8,.)

tempfile col3
save `col3', replace 
restore


// ---------------------------------------------------------------------------//
// 								PANEL: COL 4								  //	
// ---------------------------------------------------------------------------//

preserve
keep if year>=1940 & year<=1980 & startrich!=1

drop if country=="ALGERIA"
drop if country=="AUSTRIA"
drop if country=="BANGLADESH"
drop if country=="EGYPT, ARAB REP."
drop if country=="IRAN, ISLAMIC REP."
drop if country=="IRAQ"
drop if country=="LEBANON"
drop if country=="MALAYSIA"
drop if country=="MOROCCO"
drop if country=="RUSSIAN FEDERATION"
drop if country=="SINGAPORE"
drop if country=="SOUTH AFRICA"
drop if country=="TUNISIA"
drop if country=="VIETNAM"

foreach var of varlist propconflictCOW2 logmaddpop yr1940xcholera-yr1980xyellowfever yr1940 yr1950 yr1960 yr1970 compsjmhatit{
sort country
by country: egen `var'_prom=mean(`var') 
gen `var'_within=`var'-`var'_prom 
replace  `var' = `var'_within
drop `var'_within `var'_prom
}

bartik_weight, z($yr1940 $yr1950 $yr1960 $yr1970 $yr1980) weightstub($intervention) x(logmaddpop) y(propconflictCOW2) controls(yr1940-yr1970) by(year)
mat beta_p_4 = r(beta)
mat alpha_p_4 = r(alpha)
mat G_p_4 = r(G)

qui desc $yr1940 $yr1950 $yr1960 $yr1970 $yr1980, varlist
local varlist = r(varlist)
display `varlist'

clear
svmat beta_p_4
svmat alpha_p_4
svmat G_p_4


qui gen disease = ""
qui gen year = ""
local t = 1
foreach var in `varlist' {
foreach x in $disease{
	if regexm("`var'", "yr(.*)x`x'") {
		qui replace year = regexs(1) if _n == `t'
		qui replace disease = regexs(0) if _n == `t'
		}
		}
	local t = `t' + 1
}

replace disease = substr(disease,8,.)

tempfile col4
save `col4', replace 
restore

// ---------------------------------------------------------------------------//
// 								PANEL: COL 5								  //	
// ---------------------------------------------------------------------------//

preserve
keep if year>=1940 & year<=1980 & wwii!=1

drop if country=="ALGERIA"
drop if country=="AUSTRIA"
drop if country=="BANGLADESH"
drop if country=="EGYPT, ARAB REP."
drop if country=="IRAN, ISLAMIC REP."
drop if country=="IRAQ"
drop if country=="LEBANON"
drop if country=="MALAYSIA"
drop if country=="MOROCCO"
drop if country=="RUSSIAN FEDERATION"
drop if country=="SINGAPORE"
drop if country=="SOUTH AFRICA"
drop if country=="TUNISIA"
drop if country=="VIETNAM"


foreach var of varlist propconflictCOW2 logmaddpop yr1940xcholera-yr1980xyellowfever yr1940 yr1950 yr1960 yr1970 compsjmhatit{
sort country
by country: egen `var'_prom=mean(`var') 
gen `var'_within=`var'-`var'_prom 
replace  `var' = `var'_within
drop `var'_within `var'_prom
}

bartik_weight, z($yr1940 $yr1950 $yr1960 $yr1970 $yr1980) weightstub($intervention) x(logmaddpop) y(propconflictCOW2) controls(yr1940-yr1970) by(year)
mat beta_p_5 = r(beta)
mat alpha_p_5 = r(alpha)
mat G_p_5 = r(G)

qui desc $yr1940 $yr1950 $yr1960 $yr1970 $yr1980, varlist
local varlist = r(varlist)
display `varlist'

clear
svmat beta_p_5
svmat alpha_p_5
svmat G_p_5


qui gen disease = ""
qui gen year = ""
local t = 1
foreach var in `varlist' {
foreach x in $disease{
	if regexm("`var'", "yr(.*)x`x'") {
		qui replace year = regexs(1) if _n == `t'
		qui replace disease = regexs(0) if _n == `t'
		}
		}
	local t = `t' + 1
}

replace disease = substr(disease,8,.)

tempfile col5
save `col5', replace 
restore

// ---------------------------------------------------------------------------//
// 								PANEL: COL 6								  //	
// ---------------------------------------------------------------------------//

preserve
keep if year>=1940 & year<=1980

drop if country=="ALGERIA"
drop if country=="AUSTRIA"
drop if country=="BANGLADESH"
drop if country=="EGYPT, ARAB REP."
drop if country=="IRAN, ISLAMIC REP."
drop if country=="IRAQ"
drop if country=="LEBANON"
drop if country=="MALAYSIA"
drop if country=="MOROCCO"
drop if country=="RUSSIAN FEDERATION"
drop if country=="SINGAPORE"
drop if country=="SOUTH AFRICA"
drop if country=="TUNISIA"
drop if country=="VIETNAM"

foreach var of varlist propconflictCOW2 logmaddpop yr1940xcholera-yr1980xyellowfever yr1940 yr1950 yr1960 yr1970 compsjmhatit{
sort country
by country: egen `var'_prom=mean(`var') 
gen `var'_within=`var'-`var'_prom 
replace  `var' = `var'_within
drop `var'_within `var'_prom
}


global intervention "I_cholera I_typhus I_plague I_malaria I_wcough I_scarfever I_diptheria I_measles I_influenza I_typhoid I_tball I_smallpox I_yellowfever"
global yr1940 "yr1940xcholera yr1940xtyphus yr1940xplague yr1940xmalaria yr1940xwcough yr1940xscarfever yr1940xdiptheria yr1940xmeasles yr1940xinfluenza yr1940xtyphoid yr1940xtball yr1940xsmallpox yr1940xyellowfever"
global yr1950 "yr1950xcholera yr1950xtyphus yr1950xplague yr1950xmalaria yr1950xwcough yr1950xscarfever yr1950xdiptheria yr1950xmeasles yr1950xinfluenza yr1950xtyphoid yr1950xtball yr1950xsmallpox yr1950xyellowfever"
global yr1960 "yr1960xcholera yr1960xtyphus yr1960xplague yr1960xmalaria yr1960xwcough yr1960xscarfever yr1960xdiptheria yr1960xmeasles yr1960xinfluenza yr1960xtyphoid yr1960xtball yr1960xsmallpox yr1960xyellowfever"
global yr1970 "yr1970xcholera yr1970xtyphus yr1970xplague yr1970xmalaria yr1970xwcough yr1970xscarfever yr1970xdiptheria yr1970xmeasles yr1970xinfluenza yr1970xtyphoid yr1970xtball yr1970xsmallpox yr1970xyellowfever"
global yr1980 "yr1980xcholera yr1980xtyphus yr1980xplague yr1980xmalaria yr1980xwcough yr1980xscarfever yr1980xdiptheria yr1980xmeasles yr1980xinfluenza yr1980xtyphoid yr1980xtball yr1980xsmallpox yr1980xyellowfever"


bartik_weight, z($yr1940 $yr1950 $yr1960 $yr1970 $yr1980) weightstub($intervention) x(logmaddpop) y(propconflictCOW2) controls(yr1940-yr1970) by(year)
mat beta_p_6 = r(beta)
mat alpha_p_6 = r(alpha)
mat G_p_6 = r(G)

qui desc $yr1940 $yr1950 $yr1960 $yr1970 $yr1980, varlist
local varlist = r(varlist)
display `varlist'

clear
svmat beta_p_6
svmat alpha_p_6
svmat G_p_6


qui gen disease = ""
qui gen year = ""
local t = 1
foreach var in `varlist' {
foreach x in $disease{
	if regexm("`var'", "yr(.*)x`x'") {
		qui replace year = regexs(1) if _n == `t'
		qui replace disease = regexs(0) if _n == `t'
		}
		}
	local t = `t' + 1
}

replace disease = substr(disease,8,.)

tempfile col6
save `col6', replace 
restore

// ---------------------------------------------------------------------------//
// 								PANEL: MERGE								  //	
// ---------------------------------------------------------------------------//
clear
use `col1'
forvalues j=2/6{
merge 1:1 disease year using `col`j''
drop _merge
}


keep disease year alpha_p_11 alpha_p_21 alpha_p_31 alpha_p_41 alpha_p_51 alpha_p_61
order disease year alpha_p_11 alpha_p_21 alpha_p_31 alpha_p_41 alpha_p_51 alpha_p_61

rename alpha_p_11 alpha1
rename alpha_p_21 alpha2
rename alpha_p_31 alpha3
rename alpha_p_41 alpha4
rename alpha_p_51 alpha5
rename alpha_p_61 alpha6

drop if alpha1==0

foreach var of varlist alpha1-alpha6{
egen rank_`var' = rank(`var')
}

sort rank_alpha1

tempfile PANEL
save `PANEL', replace


// ---------------------------------------------------------------------------//
// 							 TABLE - PANEL A								  //	
// ---------------------------------------------------------------------------//

clear
use `LONG'
drop rank_alpha1-rank_alpha6

replace alpha6 = 0 if missing(alpha6)

replace disease="Diphtheria" if disease=="diptheria"
replace disease="Scarlet fever" if disease=="scarfever"
replace disease="Plague" if disease=="plague"
replace disease="Whooping cough" if disease=="wcough"
replace disease="Cholera" if disease=="cholera"
replace disease="Smallpox" if disease=="smallpox"
replace disease="Typhus" if disease=="typhus"
replace disease="Measles (rubeola)" if disease=="measles"
replace disease="Typhoid" if disease=="typhoid"
replace disease="Influenza" if disease=="influenza"
replace disease="Malaria" if disease=="malaria"
replace disease="Tuberculosis" if disease=="tball"
replace disease="Pneumonia" if disease=="pneumonia"

gen junk =", "

egen name = concat(disease junk year)
drop disease year junk
order name
dataout, save("$dir/Results/RotWeights_p1.txt") replace tex dec(3)

// ---------------------------------------------------------------------------//
// 							 TABLE - PANEL B								  //	
// ---------------------------------------------------------------------------//

clear
use `PANEL'

replace alpha6 = 0 if missing(alpha6)

sort rank_alpha1
drop rank_alpha1-rank_alpha6

replace disease="Diphtheria" if disease=="diptheria"
replace disease="Scarlet fever" if disease=="scarfever"
replace disease="Plague" if disease=="plague"
replace disease="Whooping cough" if disease=="wcough"
replace disease="Cholera" if disease=="cholera"
replace disease="Smallpox" if disease=="smallpox"
replace disease="Typhus" if disease=="typhus"
replace disease="Measles (rubeola)" if disease=="measles"
replace disease="Typhoid" if disease=="typhoid"
replace disease="Influenza" if disease=="influenza"
replace disease="Malaria" if disease=="malaria"
replace disease="Tuberculosis" if disease=="tball"
replace disease="Pneumonia" if disease=="pneumonia"

gen junk =", "

egen name = concat(disease junk year)
drop disease year junk
order name
dataout, save("$dir/Results/RotWeights_p2.txt") replace tex dec(3)
