* ------------------------------------------------------------------------------
* AUTHOR: Valentina Andrade
* CREATION: May-2022
* ACTION: Problem set 3 - Problem 1
* ------------------------------------------------------------------------------

set more off 
clear all
eststo clear
* ------------------------------------------------------------------------------
* SET PATH AND LOCALS
* ------------------------------------------------------------------------------

if c(username)=="valentinaandrade" global github"/Users/valentinaandrade/Documents/GitHub/me/econometrics-theoryII/tarea3"

global src 	    "$github/01input/src"
global tmp  	"$github/01input/tmp"
global output   "$github/03output"

* ------------------------------------------------------------------------------
**# packages
* ------------------------------------------------------------------------------

*ssc install nnmatch 
*net install st0632.pkg

* ------------------------------------------------------------------------------
**# use data
* ------------------------------------------------------------------------------

use "$src/Dataset_Bowling_Replication_JPE", clear

* ------------------------------------------------------------------------------
**# Add new vars
* ------------------------------------------------------------------------------
gen lnpop25=ln(pop25)
label var lnpop25 "ln(pop) in 1925"
*Dummies for size quintiles
xtile pop25_quintiles = pop25, nq(5)

* ------------------------------------------------------------------------------
**# (c) Balance
* ------------------------------------------------------------------------------

bys clubs_pc_AM: su pcNSentry_std lnpop25 share_cath25 bcollar25
bys pog1349 : su pcNSDAP285 pog20s clubs_all_pc lnpop25 share_cath25 bcollar25 latitude longitude if exist1349==1

* unbalance del n 

* ------------------------------------------------------------------------------
**# (d) Table 10: Matchingpo
* ------------------------------------------------------------------------------

*teffects nnmatch
*teffects nnmatch (pcNSentry_std lnpop25) (clubs_pc_AM), atet nneighbor(1)

eststo clear
/*1*/eststo m1: nnmatch pcNSentry_std clubs_pc_AM lnpop25, m(1) robust(1) tc(att)
/*2*/eststo m2: nnmatch pcNSentry_std clubs_pc_AM lnpop25, m(3) robust(3) tc(att)
/*3*/eststo m3: nnmatch pcNSentry_std clubs_pc_AM lnpop25 share_cath25 bcollar25, m(3) robust(3) tc(att)
/*4*/eststo m4: nnmatch pcNSentry_std clubs_pc_AM lnpop25 share_cath25 bcollar25 latitude longitude, m(3) robust(3) tc(att)
*Matching within the same Bundesland 
/*5*/eststo m5: nnmatch pcNSentry_std clubs_pc_AM lnpop25 share_cath25 bcollar25 latitude longitude, m(3) robust(3) tc(att) exact(pop25_quintiles landweimar_num)

esttab m* using "$output/models/model10.tex", se brackets nonumbers plain type nobase unstack noomitted label booktabs lines star(* 0.10 ** 0.05 *** 0.01) cells(b(star fmt(%9.3f))) replace

* ------------------------------------------------------------------------------
**# (e) Table 12
* ------------------------------------------------------------------------------
eststo clear
/*1*/eststo m1: reg pog20s pog1349 lnpop25 share_cath25 bcollar25 if exist1349==1, r beta 
/*2*/eststo m2: nnmatch pog20s pog1349 lnpop25 share_cath25 bcollar25  latitude longitude if exist1349==1, m(3) robust(3) tc(att)
/*3*/eststo m3: reg pcNSDAP285 pog1349 lnpop25 share_cath25 bcollar25 if exist1349==1, r beta 
/*4*/eststo m4: nnmatch pcNSDAP285 pog1349 lnpop25 share_cath25 bcollar25  latitude longitude if exist1349==1, m(3) robust(3) tc(att)
/*5*/eststo m5: reg clubs_all_pc pog1349 lnpop25 share_cath25 bcollar25 if exist1349==1, r beta 
/*6*/eststo m6: nnmatch clubs_all_pc pog1349 lnpop25 share_cath25 bcollar25 latitude longitude if exist1349==1, m(3) robust(3) tc(att)


esttab m* using "$output/models/model12.tex", se  star(* 0.10 ** 0.05 *** 0.01) compress keep(pog1349 SATT) plain type label booktabs lines replace


* ------------------------------------------------------------------------------
**# (f) IPW
* ------------------------------------------------------------------------------
eststo clear
/*2*/eststo m2: teffects ipw (pog20s ) (pog1349 lnpop25 share_cath25 bcollar25  latitude longitude, logit) if exist1349==1, atet

/*4*/eststo m4:  teffects ipw (pcNSDAP285) (pog1349 lnpop25 share_cath25 bcollar25  latitude longitude, logit) if exist1349==1, atet

/*6*/eststo m6: teffects ipw (clubs_all_pc) (pog1349 lnpop25 share_cath25 bcollar25 latitude longitude, logit) if exist1349==1, atet
* Da cero (para ver qe no hay optro confounder)

esttab m* using "$output/models/model13.tex", se  star(* 0.10 ** 0.05 *** 0.01) compres plain type label booktabs lines replace


* ------------------------------------------------------------------------------
**# (h) blopmatching
* ------------------------------------------------------------------------------
eststo clear
/*2*/eststo m2: blopmatch (pog20s lnpop25 share_cath25 bcollar25  latitude longitude ) (pog1349) if exist1349==1, atet metric(euclidean)

/*4*/eststo m4:  blopmatch (pcNSDAP285 lnpop25 share_cath25 bcollar25  latitude longitude) (pog1349) if exist1349==1, atet metric(euclidean)

/*6*/eststo m6: blopmatch (clubs_all_pc lnpop25 share_cath25 bcollar25 latitude longitude) (pog1349) if exist1349==1, atet metric(euclidean)
* Da cero (para ver qe no hay optro confounder)

esttab m* using "$output/models/model14.tex", se  star(* 0.10 ** 0.05 *** 0.01) compress  plain type label booktabs lines replace



