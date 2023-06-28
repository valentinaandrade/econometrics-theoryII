////////////////////////////////////////////////////////////////////////////////
/*						POPULATION AND CONFLICT								  */
////////////////////////////////////////////////////////////////////////////////

clear all
set more off, permanently
global dir "/Users/juancamiloyamin/Dropbox/Population and Conflict/Population & Conflict Files/Supplementary/Datafortheweb"
cd "$dir"

global DATA = "$dir/Data/data with conflict"	

// ---------------------------------------------------------------------------//
// 		        		 		 CROSS-COUNTRY						       	  //
// ---------------------------------------------------------------------------//

do "$dir/Programs/Figures.do"	// Figures

do "$dir/Programs/Table 1.do"  // Descriptive Statistics

do "$dir/Programs/Table 2.do" 	// OLS Estimates

do "$dir/Programs/Table 3.do" 	// First Stages, Reduced Forms and Falsification Exercises

do "$dir/Programs/Table 4.do" 	// 2SLS Estimates

do "$dir/Programs/Table 5.do" 	// 2SLS and First-Stage Estimates, Basic Robustness

do "$dir/Programs/Table 6.do" 	// 2SLS and First-Stage Estimates, Robustness to Differential Trends

do "$dir/Programs/Table 7.do" 	// Controlling Flexibly for the Impact of Initial Conflict and Mean Reversion, Using Panel Data

do "$dir/Programs/Table 8.do" 	// The importance of Natural-Resource Related Conflicts, Economic Growth, & Popularion Density

// ---------------------------------------------------------------------------//
// 		        		 	APPENDIX CROSS-COUNTRY					       	  //
// ---------------------------------------------------------------------------//

do "$dir/Programs/Table A-2.do" 	// Wild Bootstrap procedure and Global Mortality Instrument

do "$dir/Programs/Table A-3.do" 	// Share of Population 20-39 and Life Expectancy

qui do "$dir/Programs/acreg/acreg.ado" // Run this do-file just once. Otherwise the command won't work. 

do "$dir/Programs/Table A-4.do" 	// Spatial Correction of Standard Errors

do "$dir/Programs/Table A-5.do" 	// Inverse Hyperbolic Sine and Linear Probability Model

do "$dir/Programs/Table A-6.do" 	// The effect of Population on Political Instability and Inter-State Conflict

do "$dir/Programs/Table A-7.do" 	// Robustness to Sample Selection: Asia, Africa, America & Australia

do "$dir/Programs/Table A-8.do" 	// Reduced Form Basic Robustness

do "$dir/Programs/Table A-9.do" 	// Predicted Mortality and Age Structure

do "$dir/Programs/Table A-10.do" 	// Timming of the Effect of Population on Conflict

do "$dir/Programs/Table A-11.do" 	// Reduced Form Robustness to Differential Trends

do "$dir/Programs/Table A-12.do" 	// First and Second Stage Robustness to Additional Differential Trends

do "$dir/Programs/Table A-13.do" 	// Reduced Form Robustness to Additional Differential Trends

do "$dir/Programs/Table A-14.do" 	// Rotemberg Weights

do "$dir/Programs/Table A-15.do" 	// Bartik Instruments: 2SLS Estimates

do "$dir/Programs/Table A-16.do" 	// Bartik Instruments: First Stage Estimates

do "$dir/Programs/Table A-17.do" 	// The Role of Education

do "$dir/Programs/Table A-18.do" 	// Heterogeneous Effects I

do "$dir/Programs/Table A-19.do" 	// Heterogeneous Effects II

do "$dir/Programs/Table A-20.do" 	// Sample Split I

do "$dir/Programs/Table A-21.do" 	// Sample Split II

// ---------------------------------------------------------------------------//
// 		        		 			 MEXICO							       	  //
// ---------------------------------------------------------------------------//
/*
If acreg is not working, please restart Stata and run the following line:
qui do "$dir/Programs/acreg/acreg.ado"
*/
clear all
global MEX = "$dir/Data/Mexico_def.dta"
global XTMEX = "$dir/Data/XTMexico.dta"
*qui do "$dir/Programs/acreg/acreg.ado" // Run this do-file just once. Otherwise the command won't work. 

do "$dir/Programs/Table 9.do" 	// Mexico: Descriptive statistics

do "$dir/Programs/Table 10.do" 	// Mexico: First Stage, Reduced Form and Falsification Exercises

do "$dir/Programs/Table 11.do" 	// Mexico: 2SLS, First Stage and OLS Estimates

do "$dir/Programs/Table 12.do" 	// Mexico: Heterogeneous Effects and Other Outcomes

// ---------------------------------------------------------------------------//
// 		        		 		APPENDIX MEXICO						       	  //
// ---------------------------------------------------------------------------//

do "$dir/Programs/Figures Mexico.do"	// Figures Mexico

do "$dir/Programs/Table A-23.do" 	// Mexico: Heterogeneous Effects - Additional First Stages

do "$dir/Programs/Table A-24.do" 	// Mexico: Population, Shares of Population and Education

do "$dir/Programs/Table A-25.do" 	// Mexico: Heterogeneous Effects - Robustness to Droughts Definition




















