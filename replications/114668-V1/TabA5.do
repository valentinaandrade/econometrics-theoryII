clear
clear matrix
set scheme s1color
set more off

cd $dir1

use mayoral_demos.dta, clear
keep if tt_cont==0

local drop _all
local pretre "gender age born_reg college empl_not empl_high office_before party_maj_left_bef party_maj_center_bef party_maj_right_bef party_maj_local_bef same_party1 same_party2"

*this is the old 60-48

 matrix balance = J(27,1,.)
 matrix colnames balance  =  60_48 
 matrix rownames balance  =  Female . Age . Local . College . Not-Emp . High-Skill . ///
 Past-Exp . Center-left . Center . Center-right . Local . party-before1 . party-before2 .

local r=1
foreach var of local pretre {
   disp "Variable: `var'"
   *all
   reg `var' unsched6048 dist5m dist4m dist3p dist4p, cluster(id_city)
   matrix balance[`r',1]=_b[unsched6048]
   matrix balance[`r'+1,1]=_se[unsched6048]
   su gender if unsched6048!=.
   matrix balance[27,1]=r(N)
   
   local r=`r'+2
}

gen N=.
label var N "Observations"

di "Balance properties at the threshold"

mat li balance, format(%9.3f)
outtable using TabA5, mat(balance) replace format(%9.3f) nobox center



