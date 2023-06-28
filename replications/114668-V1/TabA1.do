clear
clear matrix
set scheme s1color
set more off

cd $dir1

use final.dta, clear

gen pop_res_gt10=pop_res>=.7
gen pop_res_gt10Xterm_limit=pop_res_gt10*term_limit


*Show in tables only relevant variables
local keep "keep(ty_del tt_cont tt_party_cont term_limit gender age starting_value pop_res)"


local i=1
foreach var of varlist n_firms_bid reb_final winner_in_reg {
   if `i'==1 {
      global append="replace" 
   }
   else {
      global append="append" 
   }
   reg `var' tt_cont term_limit pop_res_gt10Xterm_limit  $geog $time $auction $mayor $electoral, cluster(id_mayor)
   outreg2  using TabA1, `keep' bdec(3) nocons $append ct(OLS) tex(nopretty)
   local i=`i'+1
}
   reg max_wins_std tt_cont term_limit pop_res_gt10Xterm_limit  $geog $time $auction $mayor $electoral if year_election>=1998 & year_election<=2003, cluster(id_mayor)
   outreg2  using TabA1, `keep' bdec(3) nocons append ct(OLS) tex(nopretty)
