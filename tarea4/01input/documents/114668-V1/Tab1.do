clear
clear matrix
set scheme s1color
set more off

cd $dir1

use final.dta, clear

bysort id_city: gen counter1=_n

** city characteristics
replace pop_res=pop_res*10000
sort id_city year_election

statsmat NW NE CE SOU IS pop_res deficit tar_eff_lav if counter1==1, stat(mean sd min p25 p50 p75 max) /*
*/ listwise matrix(Tab1) format(%9.2f)
outtable using Tab1, mat(Tab1) replace nobox format (%9.2f) label
sum NW if counter1==1

** mayor characteristics
replace pop_res=pop_res*10000
sort id_city year_election id_mayor
drop counter1
bysort id_city year_election id_mayor: gen counter1=_n

statsmat gender age born_city born_prov born_reg secondary college empl_not empl_low empl_medium empl_high /*
*/ centerright_gr center_gr centerleft_gr office_before ty_del tt_cont1 tt_cont2 tt_cont3 tt_cont4 term_limit tt_party_cont /*
*/ if counter1==1, stat(mean sd min p25 p50 p75 max) /*
*/ listwise matrix(Tab1) format(%9.2f)
outtable using Tab1, mat(Tab1) append nobox format (%9.2f) label
sum gender if counter1==1
sum gender if counter1==1 & tt_cont1==1
bysort term_limit: sum gender if counter1==1 & tt_cont2==1
bysort term_limit: sum gender if counter1==1 & tt_cont3==1
bysort term_limit: sum gender if counter1==1 & tt_cont4==1


