cd "$dir"

/*
// Based on Miller's example bs_example.do
// http://www.econ.ucdavis.edu/faculty/dlmiller/statafiles/
// I elminated the "conditioning on x" bootstrapping, otherwise the same

// For any OLS/IV regression

// where the LHS variables is LHS
// where the RHS variables, except the one we want to do the null hypothesis for, is RHS
// where the variable we want to do the hypothesis for is TEST
// where the errors are clustered by CLUSTER, a group identifier
// where the dataset is DATA
// where any if condition for the regression is IF
// where estimation table is stored in OUTREG 
// where INSTRUMENT is the instrument for TEST

// DIRECTIONS FROM MATT (OIL PAPER WITH DARON)

// 1. Run IV, collect "y-hat" and "residuals", save coeff of interest as "beta-hat", and compute t-statistic "t-hat"
// 2. Create "wild y" as follows: "wild y" = "y-hat" + {1/-1} * "residuals", where bracket indicates a coin toss.
// 3. LOOP THE FOLLOWING
//   - Re-sample "wild y", X, Z (where X is endogenous variable and Z is instrument)
//   - Run IV of "wild y" on X instrumenting X with Z, save coeff of interest as "beta-hat-prime"
//   - Save t statistic, (beta-hat-prime - beta-hat) / se(beta-hat-prime)
// 4. After all bootstrap steps, compute p-value by comparing t-hat to empirical distribution of t-statistics computed in (3)

// This is "wild bootstrap" because it's resampling data and "wild y" but note that it does not "impose the null" as Miller et al suggest.  
// It was not obvious (to me or Doug) how to impose the null in IV.

// LHS=BETA*RHS + BETA0*TEST + E

// H0: BETA0=hypothesis

// To invoke the program,
// global bootreps = 999;				define number of repetitions
// runme ## ;							call program with H0= beta0=##
// runmeIV ## ;							call program with H0= beta0=##



// --------------------//
// IV program runmeIV  //
// --------------------//
*/

#delimit ;

version 9.0 ;

clear ;
set more off ;
set seed 365476247 ;

cap prog drop runmeIV ;
prog def runmeIV ;

local hypothesis = `1' ;
tempfile main bootsave ;

use "$DATA" ;
cap keep if $IF ; 

di ;
ivreg  $LHS $RHS ($TEST=$INSTRUMENT), cluster($CLUSTER);
global mainbeta = _b[$TEST] ;									/*reads coefficient of $TEST in regression*/
global maint = (_b[$TEST] - `hypothesis') / _se[$TEST] ;		/*construct main t-statistic 				  */
predict epshat , resid;											/*store residuals and...					  */
predict yhat , xb ;												/*...predicted values						  */

sort $CLUSTER ;
qui save `main' , replace ;										/*save dataset with residuals and predictions or restricted and unrestricted estimation*/

qui by $CLUSTER: keep if _n == 1 ;								/*keep one obs per $CLUSTER	*/
qui summ ;														/*summarize				*/
global num$CLUSTERs = r(N) ;									/*store number of obs in summarize=number of $CLUSTERs*/

cap erase `bootsave' ;

postfile  bskeep t_wild											/*Declare variable names(beta_np ...) and filename(bskeep) where bootstrap results will be stored*/
	using `bootsave' , replace ;

forvalues b = 1/$bootreps { ;									/*Bootstrap loop*/
use `main', replace ;
qui by $CLUSTER: gen temp = uniform() ;							/*returns a uniform[0,1] random variable, sampled by $CLUSTER*/
qui by $CLUSTER: gen pos = (temp[1] < .5) ;						/*=1 if first obs per $CLUSTER of uniform is<0.5 (i.e. with prob 1/2), 0 otherwise*/                

qui gen wildresid = epshat * (2*pos - 1) ;
qui gen wildy = yhat + wildresid ;

qui ivreg wildy $RHS ($TEST=$INSTRUMENT), cluster($CLUSTER) ;	/*regress sampled y on regresors		*/

local bst_wild = (_b[$TEST] - $mainbeta) / _se[$TEST] ;				
qui sum $CLUSTER ;												/*when conditioning on X, will use this for randomly sor new clusters*/
local min=r(min)-1 ;

post bskeep (`bst_wild') ;										/*keep the tests run assign to: beta_np t_np t_fixx t_wild in the postfile*/
} ; /* end of bootstrap reps */
qui postclose bskeep ;

qui drop _all ;
qui set obs 1 ;
gen t_wild = $maint ;											/*main t assigned as one obs of t-tests*/
																/*then other obs appended from the bootstrap*/
qui append using `bootsave' ;

qui gen n = . ;													/*summarize each statistic */
foreach stat in t_wild { ;
qui summ `stat' ;
local bign = r(N) ;												/*keep N*/
sort `stat' ;													/*sort by the respective statistic and store position of obs in n*/
qui replace n = _n ;
qui summ n if abs(`stat' - $maint) < .000001 ;					/*summarize n for those replications close to main t */
local myp = r(mean) / `bign' ;									/*myp=relative position of main t in empirical distribution for the respective bootstrapped t statistics*/
global pctile_`stat' : di %5.3f 2 * min(`myp',(1-`myp')) ;				/*this is like a p-value of two sided test: 
																say main t is very small relative to empirical distribution of the 
																bootstrapped statistic, for example lied 3d of 100, myp=0.03. 
																Then the distribution says we would have rejected for size as small as 0.03*2 */
} ;

global mainp = normal($maint) ;									/*Instead, the main t's p-value calculated from a normal cdf*/
global pctile_main = 2 * min($mainp,(1-$mainp)) ;

local myfmt = "%7.5f" ;

end ;


/*
// --------------------//
// *OLS program runme  //
// --------------------//
*/

#delimit ;

version 9.0 ;

clear ;
set more off ;
set seed 365476247 ;

cap prog drop runme ;
prog def runme ;

local hypothesis = `1' ;
tempfile main bootsave ;

use "$DATA" ;
cap keep if $IF ; 

di ;
reg $LHS $RHS $TEST, cluster($CLUSTER) ;						/*MY COMMENTS LINE BY LINE					  */
global mainbeta = _b[$TEST] ;									/*reads coefficient of $TEST in regression*/
global maint = (_b[$TEST] - `hypothesis') / _se[$TEST] ;		/*construct main t-statistic 				  */
predict epshat , resid;											/*store residuals and...					  */
predict yhat , xb ;												/*...predicted values						  */

/* also generate "impose the null hypothesis" yhat and residual */
gen temp_y = $LHS - $TEST * `hypothesis' ;						/*impose the hypothesis: partial out from y... 		*/
reg temp_y $RHS ;												/*...the regress partialed out on other RHS vars	*/
predict epshat_imposed , resid ;								/* store residuas and...							*/
predict yhat_imposed , xb ;										/*...predicted values of partialed out y			*/
qui replace yhat_imposed = yhat_imposed + $TEST * `hypothesis' ;/*...predicted values of full y						*/


sort $CLUSTER ;
qui save `main' , replace ;										/*save dataset with residuals and predictions or restricted and unrestricted estimation*/

qui by $CLUSTER: keep if _n == 1 ;								/*keep one obs per $CLUSTER	*/
qui summ ;														/*summarize				*/
global num$CLUSTERs = r(N) ;									/*store number of obs in summarize=number of $CLUSTERs*/

cap erase `bootsave' ;
qui postfile bskeep   t_wild									/*Declare variable names and filename(bskeep) where bootstrap results will be stored*/
	using `bootsave' , replace ;

forvalues b = 1/$bootreps { ;

/* first do wild bootstrap */
use `main', replace ;

qui by $CLUSTER: gen temp = uniform() ;							/*returns a uniform[0,1] random variable, sampled by $CLUSTER*/
qui by $CLUSTER: gen pos = (temp[1] < .5) ;						/*=1 if first obs per $CLUSTER of uniform is<0.5 (i.e. with prob 1/2), 0 otherwise*/                

if "$NULL"=="yes" {;
qui gen wildresid = epshat_imposed * (2*pos - 1) ;								
qui gen wildy = yhat_imposed + wildresid ;						/*if pos=1, then yhat+residual (with prob 1/2), if pos=1 then yhat-residual*/
            };
else {;
qui gen wildresid = epshat * (2*pos - 1) ;
qui gen wildy = yhat + wildresid ;
            };

qui reg wildy $RHS $TEST , cluster($CLUSTER) ;					/*regress sampled y on regresors		*/

if "$NULL"=="yes" {;
local bst_wild = (_b[$TEST] - `hypothesis') / _se[$TEST] ;		/*and do t-test on sampled regression	*/
				};
else {	;			
local bst_wild = (_b[$TEST] - $mainbeta) / _se[$TEST] ;
				};
				
qui sum $CLUSTER ;												/*when conditioning on X, will use this for randomly sor new clusters*/
local min=r(min)-1 ;


post bskeep (`bst_wild') ;										/*keep the tests run assign to t_wild in the postfile*/
} ; /* end of bootstrap reps */
qui postclose bskeep ;

qui drop _all ;
qui set obs 1 ;
gen t_wild = $maint ;														
qui append using `bootsave' ;

qui gen n = . ;													/*summarize each statistic */
foreach stat in t_wild { ;
qui summ `stat' ;
local bign = r(N) ;												/*keep N*/
sort `stat' ;													/*sort by the respective statistic and store position of obs in n*/
qui replace n = _n ;
summ n if abs(`stat' - $maint) < .000001 ;						/*summarize n for those replications close to main t */
local myp = r(mean) / `bign' ;									/*myp=relative position of main t in empirical distribution for the respective bootstrapped t statistics*/
global pctile_`stat' : di %5.3f 2 * min(`myp',(1-`myp')) ;				/*this is like a p-value of two sided test: 
																say main t is very small relative to empirical distribution of the 
																bootstrapped statistic, for example lied 3d of 100, myp=0.03. 
																Then the distribution says we would have rejected for size as small as 0.03*2 */
} ;

global mainp = normal($maint) ;									/*Instead, the main t's p-value calculated from a normal cdf*/
global pctile_main = 2 * min($mainp,(1-$mainp)) ;

local myfmt = "%7.5f" ;

end ;

