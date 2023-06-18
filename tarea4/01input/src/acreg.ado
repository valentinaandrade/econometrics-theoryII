*********************************************************************************************
*********************************************************************************************
*     Program to compute corrected standard errors for IV Spatial and Network Databases	    *
*		   		  Copyright: F. Colella, R. Lalive, S.O. Sakalli, M. Thoenig			    *
*											  												*
*			Beta Version, please do not circulate - This Version: November 2017			    *
*********************************************************************************************
*********************************************************************************************

capt program drop acreg
program acreg, eclass
	version 12
	if replay() {
	di "No Variables" 
	exit
	}
	else {
syntax [anything(name=0)]  [if] [in] [,  dist_mat(varlist) links_mat(varlist) weights(varlist) ///
	latitude(varname) longitude(varname) id(varname) time(varname) ///
	LAGcutoff(integer 0) DISTcutoff(real 1) LAGDISTcutoff(integer 0) ///
	bartlett partial correction network spatial storeweights storedistances small pfe1(varname) pfe2(varname) ]
	
	tempname b V weightsmat

	
	local current_dir `c(pwd)'
	
			local n 0

		gettoken depvar1 0 : 0, parse(" ,[") match(paren)
		PEnd `depvar1'
		if `s(stop)' { 
			error 198 
		}
		while `s(stop)'==0 { 
			if "`paren'"=="(" {
				local n = `n' + 1
				if `n'>1 { 
capture noi error 198
di in red `"syntax is "(all instrumented variables = instrument variables)""'
exit 198
				}
				gettoken p depvar1 : depvar1, parse(" =")
				while "`p'"!="=" {
					if "`p'"=="" {
capture noi error 198 
di in red `"syntax is "(all instrumented variables = instrument variables)""'
di in red `"the equal sign "=" is required"'
exit 198 
					}
					local end1 `end1' `p'
					gettoken p depvar1 : depvar1, parse(" =")
				}
				local temp_ct  : word count `end1'
				if `temp_ct' > 0 {
	//				tsunab end1 : `end1'
					prog_fv_unab `end1' 
					local end1 `r(ts_varlist)'
				}
* Allow for empty instrument list
				local temp_ct  : word count `depvar1'
				if `temp_ct' > 0 {
	//				tsunab ivv1 : `depvar1'
					prog_fv_unab `depvar1'
					local ivv1 `r(ts_varlist)'
				}
			}
			else {
				local exog1 `exog1' `depvar1'
			}
			gettoken depvar1 0 : 0, parse(" ,[") match(paren)
			PEnd `depvar1'
		}
		local 0 `"`depvar1' `0'"'

	//	tsunab exog1 : `exog1'
		prog_fv_unab `exog1' 
		local exog1 `r(ts_varlist)'
		tokenize `exog1'
		local depvar1 "`1'"
		local 1 " " 
		local exog1 `*'
	
	capture drop touse
	marksample touse
	


	
*error messages
if ("`weights'" == ""){
	if ("`network'" == "network"){
		if ("`spatial'" == "spatial"){
			disp as error "Only one option between network and spatial is allowed"
			exit 498 
		}
	}
	else { 
		if ("`spatial'" == "spatial"){
		}
		else {
			disp as error "At least one option between network and spatial must be specified"
			exit 498 
		}
	}
}
else {
}
}

	if ("`time'" == ""){
		qui sort `id' 
	}
	else { 
	qui sort `id' `time'
	}
*




********************************************************************************************
*This Routine has been partially taken from
*ivreg2hdfe v1.0.0 | Dany Bahar | dbaharc@gmail.com | 15May2014

if ("`pfe1'"!=""){
	if ("`pfe2'"!=""){
	di "FE: `pfe1' and `pfe2'"
	local fe_1 "`pfe1'"
	local fe_2 "`pfe2'"
	}
	else {
	di "FE: `pfe1' "
	local fe_1 "`pfe1'"
	local fe_2 "fake_fe2"
	capt drop fake_fe2
	gen fake_fe2=0
	}

//if ("`onlyidfe'" == "onlyidfe"){
//di "NOTIMEDUMMIES"
//local time1 "t_notime"
//local stotime = "stotime(`time')"
//}
//else {
//local time1 = "`time'"
//local stotime = ""
//}




//capt drop t_notime
//gen t_notime=0

//acreg_hdfe `0' ,    dist_mat(`dist_mat') links_mat(`links_mat') weights(`weights') ///
//	latitude(`latitude') longitude(`longitude') id(`id') time(`time')  ///
//	lag(`lagcutoff') dist(`distcutoff') lagdist(`lagdistcutoff') ///
//	`bartlett' `partial' `correction' `network' `spatial' `storeweights' `storedistances' `small'

tmpdir returns r(tmpdir):
local tdir  `r(tmpdir)'

qui cd "`tdir'"
local tempfiles : dir . files "*.dta"
foreach f in `tempfiles' {
	erase `f'
}

preserve



bys `fe_1':gen NN=_N
qui drop if NN==1
drop NN


qui reg2hdfe2 `depvar1' `end1' `exog1' `ivv1',  id1(`fe_1') id2(`fe_2') out("`tdir'") noregress ident(`id') timevariable(`time')



/* From reg2hdfe.ado */
tempfile tmp1 tmp2 tmp3 readdata
quietly {
	use _ids, clear
	sort __uid
	qui save "`tmp1'", replace


	
* Now read the original variables
	foreach var in `depvar1' `end1' `exog1' `ivv1' {
	merge __uid using _`var'
		sum _merge, meanonly
		if r(min)<r(max) { 
			di "Fatal Error"
			error 198
		}
		drop _merge
		drop __fe2*
		drop __t_*
		sort __uid
		qui save "`tmp2'", replace
	}
	


	foreach var in `depvar1' `end1' `exog1' `ivv1' {
		rename __o_`var' `var'
	}
	sum `depvar1', meanonly
	tempvar yy sy
	gen double `yy'=(`depvar1'-r(mean))^2
	gen double `sy'=sum(`yy')
	local tss=`sy'[_N]
	drop `yy' `sy'
	qui save "`readdata'", replace
	use `tmp1', clear
	foreach var in `depvar1' `end1' `exog1' `ivv1'  {
	merge __uid using _`var'
		sum _merge, meanonly
		if r(min)<r(max) { 
			di "Fatal Error."
			error 198
		}
		drop _merge
		drop __fe2*
		drop __o_*
		sort __uid
		qui save "`tmp3'", replace
	}       
	foreach var in `depvar1' `end1' `exog1' `ivv1' {
		rename __t_`var' `var'
	}
}  

 

* Create group variable
tempvar group
qui makegps2, id1(`fe_1') id2(`fe_2') groupid(`group')

* Calculate Degrees of Freedom	
qui count
local N = r(N)
//local k : word count `end1' `exog1' `ivv1' //Check whether here I need also the instruments or not
sort `fe_1'
//qui count if `id'!=`id'[_n-1]
//local G1 = r(N)
sort `fe_2'
//qui count if `time'!=`time'[_n-1]
//local G2 = r(N)
sort `group'
//qui count if `group'!=`group'[_n-1]
//local M = r(N)
//local kk = `k' + `G1' + `G2' - `M'
//local dof = `N' - `kk'	
//local G = `G2'-1
	

	
	
	sort `id' `time'
	tempfile newvars_temp
	qui save `newvars_temp', replace
	restore
	

	preserve
	drop `depvar1' `exog1' `end1' `ivv1'

	qui merge 1:1 `id' `time' using `newvars_temp'	
	
		
	capt cd "`current_dir'"
	
	acreg_core  `exog1' ,  depvar(`depvar1')  end(`end1') iv(`ivv1') ///
	dist_mat(`dist_mat') links_mat(`links_mat') weights(`weights') ///
	latitude(`latitude') longitude(`longitude') id(`id') time(`time')  ///
	lag(`lagcutoff') dist(`distcutoff') lagdist(`lagdistcutoff') ///
	`bartlett' `partial' `correction' `network' `spatial' `storeweights' `storedistances' `small'


//	estimates store `name1'
//	local r=1-e(rss)/`tss'
//   local KP = e(widstat)
//    ereturn scalar df_m = `kk'-1
//	ereturn scalar mss=`tss'-e(rss)
//	ereturn scalar r2=`r'
//	ereturn scalar r2_a=1-(e(rss)/e(df_r))/(`tss'/(e(N)-1))
//	ereturn scalar F=(`r'/(1-`r'))*(e(df_r)/(`kk'-1))
//	ereturn scalar widstat = `KP' 
//	ereturn local cmdline "ivv1reg2hdfe `0'"
//	ereturn local cmd "ivv1reg2hdfe"
//	ereturn local predict ""
//	ereturn local estat_cmd ""
//	estimates store `name1'
//	ereturn display
		

		
restore

capt drop fake_fe2

}
else {
di "NO FE"




preserve
acreg_core  `exog1' ,  depvar(`depvar1') end(`end1') iv(`ivv1') ///
 dist_mat(`dist_mat') links_mat(`links_mat') weights(`weights') ///
	latitude(`latitude') longitude(`longitude') id(`id') time(`time')  ///
	lag(`lagcutoff') dist(`distcutoff') lagdist(`lagdistcutoff') ///
	`bartlett' `partial' `correction' `network' `spatial' `storeweights' `storedistances' `small'
restore

}

********************************************************************************************

end







**************** SUBROUTINES***************

*************************************************************************************

capt program drop acreg_core
program acreg_core, eclass
	version 12	
	syntax   [anything(name=regs)]  [if] [in]  [, depvar(string)  end(string) iv(string) ///
	dist_mat(varlist) links_mat(varlist) weights(varlist) ///
	latitude(varname) longitude(varname) id(varname) time(varname) ///
	LAGcutoff(integer 0) DISTcutoff(real 1) LAGDISTcutoff(integer 0) ///
	bartlett partial correction network spatial storeweights storedistances small ]

		tempname b V weightsmat


	
*subrutines	
*qui do "./acreg_netw_dist_no_bartlett.do"
*qui do "./acreg_netw_dist_bartlett.do"
*qui do "./acreg_netw_links_no_bartlett.do"
*qui do "./acreg_netw_links_bartlett.do"
*qui do "./acreg_spat_dist_bartlett.do"
*qui do "./acreg_spat_dist_no_bartlett.do"
*qui do "./acreg_spat_ll_bartlett.do"
*qui do "./acreg_spat_ll_no_bartlett.do"
*qui do "./acreg_weig.do"
*qui do "./nwacRanktest.ado"

*-------------------------------------------------------
*A) Run reg to check for missing values and etc 

///// Will be modified
qui reg `depvar' `regs' `end' `iv'  `if' `in'
*qui ivreg2 `depvar' `regs' (`end'=`iv')  `if' `in'
*predict rrr, resid
*mata st_view(residuals=., .,"rrr")

qui keep if e(sample)==1	




*-------------------------------------------------------
*B) Construct the matrices in Mata
	
	if ("`time'" == ""){
		qui sort `id' 
	}
	else { 
	qui sort `id' `time'
	}

//if `touse' == 1 {	
	if ("`time'" == ""){
		qui sort `id' 
	}
	else { 
	qui sort `id' `time'
	}
	
	scalar define ntsize = _N
	scalar define ntsq = ntsize*ntsize
	scalar lagcutoff = `lagcutoff'
	scalar distcutoff = `distcutoff'
	scalar lagdistcutoff = `lagdistcutoff'
	
* Destring ID (if needed)
local vartype: type `id'
	if substr("`vartype'",1,3)=="str" { 
		qui tempvar id_enc
		encode `id', generate(`id_enc')
	*	drop `id'
		qui tempvar id
		gen  `id'=`id_enc' 
	}
*	
	mata {
	lagcutoff_s = st_numscalar("lagcutoff")
	distcutoff_s = st_numscalar("distcutoff")
	lagdistcutoff_s = st_numscalar("lagdistcutoff")

	*st_view(id_vec=.,.,"`id_enc'")
	id_vec = st_data(., "`id'")	
	}
	if ("`time'" == ""){
	mata: time=J(rows(id_vec),1,1)
	}
	else { 
	mata: st_view(time=.,.,"`time'")
	}
	
//	qui sort `id' `time'

	

	
	mata {				
	ntsq = st_numscalar("ntsq")
	st_view(Y=., ., "`depvar'")
	st_view(X=., ., "`end' `regs'")
	st_view(Z=., ., "`iv' `regs'")
	st_view(KX=., ., "`regs'") 			// -------------------------- KP
	st_view(KZ=., ., "`iv'")			// -------------------------- KP
	st_view(KY=., ., "`end'")        	// -------------------------- KP
	

	
	}
*	qui drop id_enc 




	if ("`weights'" == ""){	
		if ("`spatial'" == "spatial"){
			if ("`dist_mat'"==""){	 
				mata: st_view(lat=.,.,"`latitude'")                  
				mata: st_view(lon=.,.,"`longitude'")					
			}
			else{
				mata: st_view(distance=., ., "`dist_mat'")				
			}
		}
		
		if ("`network'" == "network"){
			if ("`dist_mat'"==""){	 
				mata: st_view(links=., ., "`links_mat'")					
			}
			else{
				mata: st_view(distance=., ., "`dist_mat'")				
			}
		}
	}
	else {
	mata: weig = st_data(., "`weights'")	
	//st_view(weig=.,.,"`weights'")	
	}
//}
*


*PARTIAL OPTION (not implemented yet)		
/*
		if ("`partial'"=="partial"){
		qui nw2sls_partial.do
		nw2sls_partial `depvar'  `regs', end(`end') iv(`iv')  correc(`Nclus')
		* di "Nb of independant pseudo-clusters (for VCV adjustment)=" `Nclus'
		di "Hansen J (p-value)=  " e(pValueHansen)
		di "Hansen J =  " e(Hansen)
		}
*/



*NO PARTIAL 
if ("`weights'" == ""){
	if ("`spatial'" == "spatial"){
		if ("`dist_mat'"==""){	 
			if ("`partial'"==""){
				if ("`bartlett'"=="bartlett"){
					if ("`storeweights'" == "storeweights"){
						if ("`storedistances'" == "storedistances"){
							acreg_spat_ll_bart ,  storeweights storedistances
						}
						else{					
							acreg_spat_ll_bart , storeweights	
						}
					}
					else{
							if ("`storedistances'" == "storedistances"){
							acreg_spat_ll_bart , storedistances
						}
						else{					
							acreg_spat_ll_bart 
						} 
					}
				if ("`correction'"=="correction"){	
					mata: mean_nonzero = nonzero / ntsq
					mata: Nclus = 1 / mean_nonzero
					mata: AVCVb_fs = (Nclus/(Nclus -1)) * AVCVb_fs
				}	 
				}
				else{
					if ("`storeweights'" == "storeweights"){
						if ("`storedistances'" == "storedistances"){
							acreg_spat_ll_no_bart , storeweights storedistances
						}
						else{					
							acreg_spat_ll_no_bart , storeweights	
						}	
					}
					else{
						if ("`storedistances'" == "storedistances"){
							acreg_spat_ll_no_bart ,  storedistances
						}
						else{					
							acreg_spat_ll_no_bart 
						}	
					}		
				if ("`correction'"=="correction"){	
					mata: mean_nonzero = nonzero / ntsq
					mata: Nclus = 1 / mean_nonzero
					mata: AVCVb_fs = (Nclus/(Nclus -1)) * AVCVb_fs
				}	 
				}
			
			}
			else {
				disp as error "Option partial non allowed yet"
				exit 498 
			}
		}
		else{
			if ("`partial'"==""){
				if ("`bartlett'"=="bartlett"){
					if ("`storeweights'" == "storeweights"){
					acreg_spat_dist_bart ,storeweights	
					}
					else{
					acreg_spat_dist_bart 
					}	
					if ("`correction'"=="correction"){	
						mata: mean_nonzero = nonzero / ntsq
						mata: Nclus = 1 / mean_nonzero
						mata: AVCVb_fs = (Nclus/(Nclus -1)) * AVCVb_fs
					}	 
				}
				else{
					if ("`storeweights'" == "storeweights"){
					acreg_spat_dist_no_bart ,	 storeweights	
					}
					else{
					acreg_spat_dist_no_bart 
					}
					if ("`correction'"=="correction"){	
						mata: mean_nonzero = nonzero / ntsq
						mata: Nclus = 1 / mean_nonzero
						mata: AVCVb_fs = (Nclus/(Nclus -1)) * AVCVb_fs
					}	 
				}
			
			}
			else {
				disp as error "Option partial non allowed yet"
				exit 498 
			}
		}
	}

	
	if ("`network'" == "network"){
		**----------------------------------------------------------**
		**        acreg_netw_links TBC 			**
		if ("`dist_mat'"==""){	 
			if ("`partial'"==""){
				if ("`bartlett'"=="bartlett"){
					if ("`storeweights'" == "storeweights"){
						if ("`storedistances'" == "storedistances"){
							acreg_netw_links_bart , storeweights storedistances
						}
						else{					
							acreg_netw_links_bart , storeweights	
						}
					}
					else{
							if ("`storedistances'" == "storedistances"){
							acreg_netw_links_bart , storedistances
						}
						else{					
							acreg_netw_links_bart 
						} 
					}
				if ("`correction'"=="correction"){	
					mata: mean_nonzero = nonzero / ntsq
					mata: Nclus = 1 / mean_nonzero
					mata: AVCVb_fs = (Nclus/(Nclus -1)) * AVCVb_fs
				}	 
				}
				else{
					if ("`storeweights'" == "storeweights"){
						if ("`storedistances'" == "storedistances"){
							acreg_netw_links_no_bart , storeweights storedistances
						}
						else{					
							acreg_netw_links_no_bart , storeweights	
						}	
					}
					else{
						if ("`storedistances'" == "storedistances"){
							acreg_netw_links_no_bart , storedistances
						}
						else{					
							acreg_netw_links_no_bart 
						}	
					}		
					if ("`correction'"=="correction"){	
						mata: mean_nonzero = nonzero / ntsq
						mata: Nclus = 1 / mean_nonzero
						mata: AVCVb_fs = (Nclus/(Nclus -1)) * AVCVb_fs
					}	 
				}	
			}
			else {
				disp as error "Option partial non allowed yet"
				exit 498 
			}
		}
		**----------------------------------------------------------**
		else{
			if ("`partial'"==""){
				if ("`bartlett'"=="bartlett"){
					if ("`storeweights'" == "storeweights"){
					acreg_netw_dist_bart ,	 storeweights	
					}
					else{
					acreg_netw_dist_bart
					}
					if ("`correction'"=="correction"){	
						mata: mean_nonzero = nonzero / ntsq
						mata: Nclus = 1 / mean_nonzero
						mata: AVCVb_fs = (Nclus/(Nclus -1)) * AVCVb_fs
					}	 
				}
				else{
					if ("`storeweights'" == "storeweights"){
					acreg_netw_dist_no_bart , storeweights	
					}
					else{
					acreg_netw_dist_no_bart 	
					}	
					if ("`correction'"=="correction"){	
						mata: mean_nonzero = nonzero / ntsq
						mata: Nclus = 1 / mean_nonzero
						mata: AVCVb_fs = (Nclus/(Nclus -1)) * AVCVb_fs
					}	 
				}
		
			}
			else {
				disp as error "Option partial non allowed yet"
				exit 498 
			}				
		}
	}
}
else {
acreg_weig 
}
*	



// export
	local temp_ct  : word count `regs'
	if `temp_ct' > 0 {
		prog_fvexpand `regs'
		local regss `r(newfvvars)'
	di "Included instruments: `regss'"
	local fvops `r(fvops)'
	}
	local temp_ct  : word count `end'
	if `temp_ct' > 0 {
		prog_fvexpand `end'
		local ends `r(newfvvars)'
	di "Instrumented: `ends'"
	if "`fvops'" == "true" {
		}
		else {
		local fvops `r(fvops)'
		}
	}
	local temp_ct  : word count `iv'
	if `temp_ct' > 0 {	
		prog_fvexpand `iv'
		local ivs `r(newfvvars)'
	di "Excluded instruments: `ivs'"
	if "`fvops'" == "true" {
		}
		else {
		local fvops `r(fvops)'
		}
	}
	

	
	//small sample correction
if ("`small'" == ""){
local n_cluster=1000000
}
else {
	local iv_ct : word count `ivs'
	local sdofminus = 0
	local partial_ct : word count `regss'
	local partial_ct = `partial_ct' + 1
	local sdofminus =`sdofminus'+`partial_ct'
	mata: mean_nonzero = nonzero / ntsq
	mata: n_cluster = 1 / mean_nonzero
	mata: st_local("N", strofreal(N))
	mata: st_local("n_cluster", strofreal(n_cluster))
	local n_cluster `n_cluster'
	mata: rankxx = rows(W) - diag0cnt(W)
	mata: st_local("rankxx", strofreal(rankxx))
	local ss_corr = (`N'-1) / (`N'-`rankxx'-`sdofminus') *`n_cluster'/(`n_cluster'-1)
	mata ss_corr = st_numscalar("ss_corr")
	mata: V = V * `ss_corr' 
	mata: AVCVb_fs = (n_cluster/(n_cluster -1)) * AVCVb_fs
}


mata {	
	b=b'
	st_matrix("r(V)", V)
	st_matrix("r(b)", b)
	st_numscalar("r(N)", N)
}	


	mat `b'=r(b)
	mat `V'=r(V)
	
	matname `V' `ends' `regss' "_cons" , e
	mat colnames `b' = `ends' `regss' _cons


	
    ereturn post `b' `V'
	ereturn local depvar "`depvar'"
	ereturn scalar N=r(N)
    ereturn local cmd "acreg"
    
    ereturn display


*
*-------------------------------------------------------
*Z) KP TEST
********************************************************************

if ("`iv'" == ""){
}
else {
if "`fvops'" == "true" {
di "No KP test with factor variables - in progress"
}
else{
	

	mata: st_matrix("r(AVCVb_fs)", AVCVb_fs)
	mat AVCVb_fs=r(AVCVb_fs)

	*** We retrieve code for IVreg2

	* Stata convention is to exclude constant from instrument list
	* Need word option so that varnames with "_cons" in them aren't zapped
	qui count
	local N = r(N)
	local iv_ct : word count `ivs'
	local iv_ct  = `iv_ct' + 1
	local sdofminus = 0
	local partial_ct : word count `regs'
	local partial_ct = `partial_ct' + 1
	local sdofminus =`sdofminus'+`partial_ct'
//	local N_clust=1000000	// November 2017, beta version: this will become endogenous in the future
	local N_clust "`n_cluster'"
	local exex1_ct     : word count `iv'
	*local noconstant "noconstant"
	local noconstant ""
	local robust "robust"
	*local robust ""
	local CLUS="AVCVb_fs"

	* (line 1735 in ivreg2)
	*Need only test of full rank 
	qui nwacRanktest (`end') (`iv') , vb("`CLUS'") partial(`regs') full wald `noconstant' `robust'
					/* `robust' `clopt' `bwopt' `kernopt'*/

	* sdofminus used here so that F-stat matches test stat from regression with no partial
	scalar Chi2=r(chi2)
	scalar rkf=r(chi2)/(`N'-1) *(`N'-`iv_ct'-`sdofminus')  *(`N_clust'-1)/`N_clust' /`exex1_ct' 
					
	scalar widstat=rkf
	scalar KPstat=widstat

	di "Kleibergen Paap rk statistic =  " KPstat
	********************************************************************
	}
}


end


**************************************************************************************
capt program drop PEnd
program define PEnd, sclass
	version 8.2
	if `"`0'"' == "[" {		
		sret local stop 1
		exit
	}
	if `"`0'"' == "," {
		sret local stop 1
		exit
	}
	if `"`0'"' == "if" {
		sret local stop 1
		exit
	}
	if substr(`"`0'"',1,3) == "if(" {
		sret local stop 1
		exit
	}
	if `"`0'"' == "in" {
		sret local stop 1
		exit
	}
	if `"`0'"' == "" {
		sret local stop 1
		exit
	}
	else	sret local stop 0
end


*******************************************************************************************
capt program drop prog_fvexpand
program prog_fvexpand, rclass
		syntax varlist(numeric fv)
		fvexpand `varlist'
		local fvops = r(fvops)
		if "`fvops'" == "true" {
		local newfvvarlist = "`r(varlist)'"
		return local newfvvars `"`newfvvarlist'"'
		return local fvops `"`fvops'"'
		}
		else {
		return local newfvvars `"`varlist'"'
		}
	end 
	
	
*******************************************************************************************	
capt program drop prog_fv_unab
program prog_fv_unab, rclass
	syntax varlist(numeric fv)
	local temp_vt  : word count `varlist'
	forval j=1/`temp_vt' {
		local this_var `: word `j' of `varlist''
		if substr("`this_var'", 1, 2) == "i." {
			fvrevar `this_var', list
			local this_var = "`r(varlist)'"
			return local this_var `"`this_var'"'
			tsunab this_var : `this_var'
			local this_var = "i.`this_var'"
		}
		else {
		tsunab this_var : `this_var'
		}
		local ts_varlist `ts_varlist' `this_var' 
	}
	return local ts_varlist `"`ts_varlist'"'
end 


********************************************************************************************
*This Routine has been partially taken from
*Reg2hdfe - Estimates linear regression model with two high dimensional fixed effects 
*Author: Paulo Guimaraes */

capt program drop reg2hdfe2
program reg2hdfe2, eclass
version 9.1
if replay() {
if ("`e(cmd)'"!="reg2hdfe2") error 301
Display2 `0'
}
else Estimate2 `0'
end

capt program drop Estimate2
program define Estimate2, eclass
syntax varlist [if] [in], id1(str) id2(str)   ///
[TOL(real 0.000001) MAXiter(integer 0) ident(str) timevariable(str) ///
CHECK NODOTS SIMPLE fe1(str) fe2(str) cluster(str) GROUPid(str)  INdata(string) ///
OUTdata(string) IMProve(str) VERBose NOREGress PARAM1 PARAM2 OP1(integer 3) ///
OP2(integer 1) OP3(integer 10) OP4(integer 1000) OP5(real 0.001) AUTOFF]

*********************************************************************
* Checking syntax
*********************************************************************
tokenize `varlist'
local lhs `1'
mac shift
local rhs `*'

if ("`fe1'"!=""&"`fe2'"=="")|("`fe2'"!=""&"`fe1'"=="") {
di in red "Error: You must specify both options fe1 and fe2"
error 198
}

if "`param1'"=="param1"&"`param2'"=="param2" {
di in red "Error: Choose either param1 or param2"
error 198
}

if "`indata'"!=""&"`improve'"!="" {
di in red "Error: Indata option not valid with improve option"
error 198
}

if "`outdata'"!=""&"`improve'"!="" {
di in red "Error: Outdata option not valid with improve option"
error 198
}

if "`improve'"!=""&"`rhs'"!="" {
di in red "Error: Improve option can only be used with a single variable"
error 198
}

if "`improve'"!=""&"`fe1'"!="" {
di in red "Error: Can not estimate fixed effects with improve option"
error 198
}

if "`improve'"!=""&"`check'"!="" {
di in red "Error: Can not use check and improve option simultaneously"
error 198
}

if "`improve'"!=""&"`cluster'"!="" {
di in red "Error: Can not use cluster and improve option simultaneously"
error 198
}

if "`indata'"==""&"`improve'"==""&"`outdata'"=="" {
local standard "standard"
}

if `"`fe1'"'!=`""' confirm new var `fe1' 
if `"`fe2'"'!=`""' confirm new var `fe2'
if `"`groupid'"'!=`""' confirm new var `groupid'

capture drop __uid
**********************************************************************
* Define Initial Variables
**********************************************************************
tempvar clustervar

di in ye "=============================================================="

local dots `=cond("`nodots'"=="",1,0)'

***********************************************************************
* Do Main Loop
***********************************************************************

if "`improve'"!="" {
preserve 
tempvar varfe2
tempfile tmp1 tmp2
quietly {
if "`verbose'"!="" {        
noisily di "Reading `improve'_ids"
}
use `improve'_ids, clear
sort __uid
qui save `tmp1', replace
merge __uid using `improve'_`lhs'
sum _merge, meanonly
if r(min)<r(max) { 
di "There was an error merging `improve'_ids with `improve'_`lhs'"
di "Data sets do not match"
error 198
}
drop _merge
rename __t_`lhs' `lhs'
}
* Now we try to improve convergence
di in ye "Improving Convergence for Variable: `lhs'" 
di in red "Improve may not work if fixed effects are not specified in the same order as saved"
iteralg2 "`lhs'" "`id1'" "`id2'" "__fe2_`lhs'" "`tol'" "`maxiter'" "`simple'" ///
"`verbose'" "`dots'" "`varfe2'" "`op1'" "`op2'" "`op3'" "`op4'" "`op5'" "`autoff'"
if "`outdata'"!="" {
outvars2 "__o_`lhs'" "`lhs'" "`varfe2'" "`outdata'" 
}
if "`check'"=="check" {
checkvars2 "__o_`lhs'" "`varfe2'" "`id1'"
}
restore
}     

if "`indata'"!="" {      
tempfile tmp1 tmp2 tmp3 readdata
quietly {
if "`verbose'"!="" {        
noisily di "Reading `indata'_ids"
}
use `indata'_ids, clear
sort __uid
qui save `tmp1', replace
if "`cluster'"!="" {
noisily di in yellow "The clustering variable is the one used when the data was created!!! "
if "`verbose'"!="" {        
noisily di in yellow "Adding `indata'_clustervar"
}
merge __uid using `indata'_clustervar
sum _merge, meanonly
if r(min)<r(max) { 
di "There was an error merging `indata'_ids with `indata'_clustervar "
di "Data sets do not match"
error 198
}
drop _merge
sort __uid
rename __clustervar `clustervar'
qui save `tmp1', replace
}
* Now read the original variables
foreach var in `varlist' {
if "`verbose'"!="" {        
noisily di "Adding original `indata'_`var'"
}
merge __uid using `indata'_`var'
sum _merge, meanonly
if r(min)<r(max) { 
di "There was an error merging `indata'_ids with `indata'_`var' "
di "Data sets do not match"
error 198
}
drop _merge
drop __fe2*
drop __t_*
sort __uid
qui save `tmp2', replace
}
foreach var in `lhs' `rhs' {
rename __o_`var' `var'
}
sum `lhs', meanonly
tempvar yy sy
gen double `yy'=(`lhs'-r(mean))^2
gen double `sy'=sum(`yy')
local tss=`sy'[_N]
drop `yy' `sy'
qui save `readdata'
use `tmp1', clear
foreach var in `varlist' {
if "`verbose'"!="" {        
noisily di "Adding transformed `indata'_`var'"
}
merge __uid using `indata'_`var'
sum _merge, meanonly
if r(min)<r(max) { 
di "There was an error merging `indata'_ids with `indata'_`var' "
di "Data sets do not match"
error 198
}
drop _merge
drop __fe2*
drop __o_*
sort __uid
qui save `tmp3', replace
}
        
foreach var in `lhs' `rhs' {
rename __t_`var' `var'
}
if "`verbose'"!="" {
noisily di "Done reading data"
}
}
}   

if "`outdata'"!=""|"`standard'"!="" {

************ Mark usable sample and store all data
mark __touse `if' `in'
if "`cluster'"!="" {
gen double `clustervar'=`cluster'
markout __touse `lhs' `rhs' `id1' `id2' `clustervar'
}
else {
markout __touse `lhs' `rhs' `id1' `id2'
}

tempfile origdata
if "`verbose'"!="" {
di in yellow "Saving original file"
}
gen long __uid = _n
sort __uid
qui save `origdata'

* Restrict data to usable sample
qui keep if __touse
if "`cluster'"!="" {
keep __uid `id1' `id2' `lhs' `rhs' `clustervar' 
}
else {
keep __uid `id1' `id2' `lhs' `rhs' `ident' `timevariable'
}

*************************
sum `lhs', meanonly
tempvar yy sy
gen double `yy'=(`lhs'-r(mean))^2
gen double `sy'=sum(`yy')
local tss=`sy'[_N]
drop `yy' `sy'

***************************
if "`outdata'"!="" {
preserve
keep __uid `id1' `id2' `ident' `timevariable'
order __uid `id1' `id2' `ident' `timevariable'
if "`verbose'"!="" {
di in yellow "Saving fixed effects variables... "
}
capture qui save `outdata'_ids
local err _rc
if `err'!=0 {
use `origdata', clear
drop __touse
error `err'
}
restore
if "`cluster'"!="" {
if "`verbose'"!="" {
di in yellow "Saving cluster variable... "
}
preserve
keep __uid `clustervar'
rename `clustervar' __clustervar
qui save `outdata'_clustervar
restore
}        
}                         
di in ye "Tolerance Level for Iterations: `tol' "
tempvar start2
tempname dum1
gen double `start2'=0
foreach var of varlist `varlist' {
di
di in ye "Transforming variable: `var' " 
gen double __o_`var' = `var'
iteralg2 "`var'" "`id1'" "`id2'" "`start2'" "`tol'" "`maxiter'" "`simple'" ///
"`verbose'" "`dots'" "`dum1'" "`op1'" "`op2'" "`op3'" "`op4'" "`op5'" "`autoff'"
if "`outdata'"!="" {
outvars2 "__o_`var'" "`var'" "`dum1'" "`outdata'" 
}
checkvars2 "__o_`var'" "`dum1'" "`id1'"
drop __o_`var'
drop `dum1'
}
drop `start2'   
}  

if "`improve'"==""&"`noregress'"=="" {
if "`verbose'"!="" {        
di "Calculating degrees of freedom ... "
}

* Create group variable
tempvar group
qui makegps2, id1(`id1') id2(`id2') groupid(`group')

* Calculate Degrees of Freedom	
qui count
local N = r(N)
local k : word count `rhs'
sort `id1'
qui count if `id1'!=`id1'[_n-1]
local G1 = r(N)
sort `id2'
qui count if `id2'!=`id2'[_n-1]
local G2 = r(N)
sort `group'
qui count if `group'!=`group'[_n-1]
local M = r(N)
local kk = `k' + `G1' + `G2' - `M'
local dof = `N' - `kk'	

* Estimate the model
if "`verbose'"!="" {        
            di "Estimating Regression ... "
}

tempname name1 name2
if "`cluster'"=="" {
di
* Estimate Regression		
qui _regress `lhs' `rhs', nocons dof(`dof')
estimates store `name2'
local r=1-e(rss)/`tss'
ereturn scalar df_m = `kk'-1
ereturn scalar mss=`tss'-e(rss)
ereturn scalar r2=`r'
ereturn scalar r2_a=1-(e(rss)/e(df_r))/(`tss'/(e(N)-1))
ereturn scalar F=(`r'/(1-`r'))*(e(df_r)/(`kk'-1))
ereturn local cmdline "reg2hdfe2 `0'"
ereturn local cmd "reg2hdfe2"
ereturn local predict ""
ereturn local estat_cmd ""
estimates store `name1'
}
else {
sort `clustervar'
qui count if `clustervar'!=`clustervar'[_n-1]
local Nclust = r(N)
qui _regress `lhs' `rhs', nocons mse1
estimates store `name2'
tempname b V
matrix `V'=e(V)
matrix `b'=e(b)
local rss=e(rss)
local r=1-`rss'/`tss'
local nobs=e(N)
tempvar res
predict double `res', residual
_robust `res', v(`V') minus(`kk') cluster(`clustervar')
ereturn scalar Mgroups = `M'
ereturn post `b' `V', depname(`lhs') obs(`nobs') dof(`kk')
ereturn local eclustvar "`cluster'"
ereturn local vce "cluster"
ereturn local vcetype "Robust"
ereturn local cmdline "reg2hdfe2 `0'"
ereturn local depvar "y"
ereturn local cmd "reg2hdfe2"
ereturn scalar N_clust=`Nclust'
ereturn scalar r2=`r'
ereturn scalar rss=`rss'
ereturn scalar mss=`tss'-`rss'
estimates store `name1'
di
}

if "`verbose'"!="" {        
di "Done with estimation ... "
}
}

if "`indata'"!="" {
use `readdata', clear
}
if "`indata'"==""&"`improve'"=="" {
use `origdata', clear
quietly keep if __touse==1
drop __touse
}

* Compute Fixed Effects

if `"`fe1'"'!=`""' & `"`fe2'"'!=`""' { 
di in ye "Calculating Fixed Effects"
tempvar dum1 dum2 dum3
qui estimates restore `name2'
qui predict `dum1', res
qui gen double `dum2'=`dum1'     
*di in ye "Tolerance Level for Iterations: `tol'"
local dots `=cond("`nodots'"=="",1,0)'
tempvar start2
gen double `start2'=0
quietly {
iteralg2 "`dum1'" "`id1'" "`id2'" "`start2'" "`tol'" "`maxiter'" "`simple'" ///
"`verbose'" "`dots'" "`dum3'" "`op1'" "`op2'" "`op3'" "`op4'" "`op5'" "`autoff'"
}
drop `start2'
qui replace `dum2'=`dum2'-`dum3', nopromote 
sort `id1' 
qui by `id1': g double `fe1' = sum(`dum2')/_n
qui by `id1': replace `fe1' = `fe1'[_N], nopromote
rename `dum3' `fe2'
di in ye "Done!!! "
* Implement parameterization 1
if "`param1'"=="param1" {
tempvar sumfe 
gen double `sumfe'=`fe1'+`fe2'
qui makegps2, id1(`id1') id2(`id2') groupid(`group')
sort `group' 
qui by `group': replace `dum1' = sum(`fe1')/_n, nopromote
qui by `group': replace `fe1' = `fe1'-`dum1'[_N], nopromote
qui replace `fe2'=`sumfe'-`fe1', nopromote
}
* Implement parameterization 2
if "`param2'"=="param2" {
tempvar sumfe 
gen double `sumfe'=`fe1'+`fe2'
qui makegps2, id1(`id1') id2(`id2') groupid(`group')
sort `group' 
qui by `group': replace `dum1' = sum(`fe2')/_n, nopromote
qui by `group': replace `fe2' = `fe2'-`dum1'[_N], nopromote
qui replace `fe1'=`sumfe'-`fe2', nopromote
}
Display2 `name1'
local nodisp nodisp
* Test Final Model 
if "`check'"=="check" {
qui _regress `lhs' `rhs' `fe1' `fe2' 
di
di in yellow "Checking if final model converged - Coefficients for fixed effects should equal 1"
di in yellow "Coefficient for `id1' --> "_b[`fe1']
di in yellow "Coefficient for `id2' --> "_b[`fe2']
}
}

if `"`groupid'"'!=`""' {
qui makegps2, id1(`id1') id2(`id2') groupid(`groupid')
label var `groupid' "Unique identifier for mobility groups"
}

if "`indata'"==""&"`improve'"=="" {
tempfile addvars
qui describe
if r(k)> 1 {
keep __uid `fe1' `fe2' `groupid'
sort __uid
qui save `addvars', replace 
use `origdata', clear
drop __touse
sort __uid
merge __uid using `addvars'
drop _merge
}
else {
use `origdata', clear
drop __touse
}
}

if "`nodisp'"!="nodisp" {
Display2 `name1'
}


capture drop __uid
di
end

********************************************************************************
capt program drop Display2
program Display2
args name
if "`name'"!="" {
qui estimates restore `name'
_coef_table_header, title( ********** Linear Regression with 2 High-Dimensional Fixed Effects ********** )
_coef_table
}
end

********************************************************************************
capt program drop iteralg2
program define iteralg2
args var id1 id2 start2 tol maxiter simple verbose dots jfe op1 op2 op3 op4 op5 autoff
local count1=0
local count2=0
local count3=0
local count4=0
local count5=0
quietly {
recast double `var'
tempvar temp v1 v2 mean
gen double `v1'=0
gen double `temp'=0
gen double `v2'=`start2'
qui sum `v2', meanonly
if r(min)!=r(max) {
qui replace `var' = `var' + `v2', nopromote
}
if "`simple'"=="" {
tempvar v0 ym1 ym2 dum
gen double `v0'=0
gen double `ym1'=0
gen double `ym2'=0
}
local iter=1
local dif=1
local c1 "(`v2'>`v1'&`v1'>`v0'&((`v2'+`v0')<(2*`v1')))"
local c2 "(`v2'<`v1'&`v1'<`v0'&((`v2'+`v0')>(2*`v1')))"
capture drop `mean'
sort `id1'
by `id1': g double `mean' = sum(`var')/_n
qui by `id1': replace `var' = `var' - `mean'[_N], nopromote	
while abs(`dif')>`tol' & `iter'!=`maxiter'{
*while `dif'<1 & `iter'!=`maxiter'{
capture drop `mean'
sort `id1'
by `id1': g double `mean' = sum(`v2')/_n
qui by `id1': replace `mean' = `mean'[_N], nopromote				
if "`simple'"=="" {
capture drop `v0'
rename `v1' `v0'
}
else {
capture drop `v1'
}
rename `v2' `v1'
sort `id2'
by `id2': g double `v2' = sum(`var'+`mean')/_n 
qui by `id2': replace `v2' = `v2'[_N], nopromote
if `iter'>`op1'&"`simple'"=="" {
capture drop `dum'
gen `dum'=`v1'+((`v2'-`v1')*(`v1'-`v0')/(2*`v1'-`v0'-`v2'))*(1-[(`v2'-`v1')/(`v1'-`v0')]^`op2')
replace `v2'=`dum' if (`c1'|`c2')&(`dum'<.), nopromote 
if mod(`iter',`op3')==0 {
replace `ym1'=`ym2', nopromote
replace `ym2'=`v1'+((`v2'-`v1')*(`v1'-`v0')/(2*`v1'-`v0'-`v2'))*(1-[(`v2'-`v1')/(`v1'-`v0')]^`op4')
replace `v2'=`ym2' if (`c1'|`c2')&(abs(`ym1'-`ym2')<`op5'), nopromote
}
}
qui replace `temp'=sum(reldif(`v2',`v1')), nopromote
local dif=`temp'[_N]/_N
*count if abs(`v2'-`v1')<`tol'
*local dif=r(N)/_N
if `dots' {
if `iter'==1 {
_dots 0, title(Iterations) reps(`maxiter')
}
_dots `iter' 0
}
if "`verbose'"!="" {
count if abs(`v2'-`v1')<`tol'
noisily di " `iter' - Dif --> " %-12.7g `dif' "  % fe below tolerance --> "  %-07.5f 100*r(N)/_N " OP2 -> "`op2'
*noisily di "`iter' --> % fe below tolerance --> "  %-08.5f 100*`dif' " OP2 -> "`op2'
} 
local count1=`count2'
local count2=`count3'
local count3=`count4'
local count4=`count5'
local count5=`dif'
if (`count5'>`count4')&(`count4'>`count3')&("`autoff'"=="")&("`simple'"=="")&(`op2'>1) {
local op2=1
local count5=0
}
if (`count5'<`count4')&(`count4'<`count3')&(`count3'<`count2')&(`count2'<`count1')&("`autoff'"=="")&("`simple'"=="") {
local op2=`op2'+1
local count5=.
}
local iter=`iter'+1
}
qui replace `var' = `var' - `v2' + `mean', nopromote
}
if `iter'==`maxiter' {
di
di in red "Maximum number of iterations reached"
di in red "Algorithm did not converge for variable `var'"
di in red "Last improvement: `dif'"
}			
else {			
di
di in yellow "Variable `var' converged after `iter' Iterations"
}
if "`jfe'"!="" {
gen double `jfe'=`v2'
}	
end


********************************************************************************
capt program drop outvars2
program define outvars2
args orig var fe2 outdata
preserve
keep __uid `orig' `var' `fe2' 
sort __uid
rename `var' __t_`var'
rename `fe2' __fe2_`var'
qui save `outdata'_`var', replace
di in yellow " `var' was saved "
restore
end       


********************************************************************************
capt program drop checkvars2
program define checkvars2
args orig fe2 id1
tempvar fe1 dum2
gen double `dum2'=`orig'-`fe2'
sort `id1' 
by `id1': g double `fe1' = sum(`dum2')/_n
qui by `id1': replace `fe1' = `fe1'[_N], nopromote
qui _regress `orig' `fe1' `fe2' 
di in yellow "Checking if model converged - Coefficients for fixed effects should equal 1"
di in yellow "Coefficient for id1 --> "_b[`fe1']
di in yellow "Coefficient for id2 --> "_b[`fe2']
end




************************************************************************************
/* This routine is from Amine Quazad's a2reg program */
/* It establishes the connected groups in the data */
*Find connected groups for normalization
capture program drop makegps2
program define makegps2
version 9.2
syntax [if] [in], id1(varname) id2(varname) groupid(name)
marksample touse
markout `touse' `id1' `id2'
confirm new variable `groupid'
sort `id1' `id2'
preserve
*Work with a subset of the data consisting of all id1-id2 combinations
keep if `touse'
collapse (sum) `touse', by(`id1' `id2')
sort `id1' `id2'
*Start by assigning the first id1 value to group 1, then iterate to fill this out
tempvar group newgroup1 newgroup2
gen double `group'=`id1'
local finished=0
local iter=1
while `finished'==0 {
quietly {
bysort `id2': egen double `newgroup1'=min(`group')
bysort `id1': egen double `newgroup2'=min(`newgroup1')
qui count if `newgroup2'~=`group'
local nchange=r(N)
local finished=(`nchange'==0)
replace `group'=`newgroup2'
 drop `newgroup1' `newgroup2'
}
di in yellow "On iteration `iter', changed `nchange' assignments"
local iter=`iter'+1
}
sort `group' `id1' `id2'
tempvar nobs complement
by `group': egen double `nobs'=sum(`touse')
replace `nobs'= -1*`nobs'
egen double `groupid'=group(`nobs' `group')
keep `id1' `id2' `groupid'
sort `id1' `id2'
tempfile gps
save `gps'
restore
tempvar mrg2group
merge `id1' `id2' using `gps', uniqusing _merge(`mrg2group')
assert `mrg2group'~=2
assert `groupid'<. if `mrg2group'==3
assert `groupid'==. if `mrg2group'==1
drop `mrg2group'
end
	
*********************************************************************************************
*********************************************************************************************
*     Program to compute corrected standard errors for IV Spatial and Network Databases	    *
*				     (F. Colella, R. Lalive, S.O. Sakalli, M. Thoenig)					    *
*																						    *
*						    Beta Version, please do not circulate						    *
*********************************************************************************************
*********************************************************************************************

capt program drop acreg_weig
program acreg_weig, eclass
	version 12
	syntax [, ] 
	
mata {	
X=(X, J(rows(Y),1,1))
Z=(Z, J(rows(Y),1,1))
K = cols(Z)

// 2SLS: parameters
W=invsym(Z'Z)
P=invsym(X'Z * W * Z'X)* X'Z * W *Z'
b=P * Y
res = Y-X*b
N=rows(res)

Nend = cols(KY) 	// -------------------------- KP
Niv = cols(KZ) 		// -------------------------- KP
Nie = Nend*Niv		// -------------------------- KP // -------------------------- KP

*------------------------------------------------------------------------
*        -------------------------- KP --------------------------	 	*
* Partial out X, p refers to partialling out
KX = (KX, J(rows(Y),1,1))

Zp1 = KX'*KZ
Zp2 = KX*invsym(KX'KX)*Zp1
Zp = KZ - Zp2

Yp1 = KX'*KY
Yp2 = KX*invsym(KX'KX)*Yp1
Yp = KY - Yp2

yp1 = KX'*Y
yp2 = KX*invsym(KX'KX)*yp1
yp = Y - yp2

* VCV first stage parameters
mata: u1 = (invsym(Zp'Zp)*Zp') * Yp

u1 = (invsym(Zp'Zp)*Zp') * Yp
u2 = Zp * u1
u = Yp - u2 

Sz = 1/sqrt(N)*Zp'
SzN = Sz

*------------------------------------------------------------------------

*
/*
* First stage
mata: PZ=Z*invsym(Z'Z)*Z'
mata: MZ=I(rows(PZ))-PZ


mata: X1=Xe[.,1]
mata: X2=Xe[.,2]

mata: gamma1=PZ * X1
*mata: rows(gamma1)
mata: resX1 = MZ * X1

mata: VCV1 = PZ * (resX1 * resX1' :* cluster) * PZ'
mata: VCV1 = VCV1[|1,1\16,16|]

mata: F1 = (gamma1[.,1..Niv]'*invsym(VCV1)*gamma1[.,1..Niv])/Niv
*/


weight_cols = cols(weig)
weight_rows = rows(weig)

st_local("N_o", strofreal(N))
st_local("weight_cols", strofreal(weight_cols))
st_local("weight_rows", strofreal(weight_rows))

}

if `N_o' != `weight_cols' {
	disp as error "The number of columns in the wights matrix is different than the number of observations"
exit 498
}


mata {

// 2SLS: VCV
V = J(K,K, 0)
nonzero = 0

AVCVb_fs = J(Nie,Nie, 0)   		// -------------------------- KP // -------------------------- KP

		V =  P * (res * res' :* weig) * P'
		weigz = weig :> 0
		nonzero = sum(weigz)

		AVCVb_fs = (I(Nend)#SzN) * ((vec(u) * (vec(u))') :* (J(Nend,Nend, 1)#weig)) * (I(Nend)#SzN)'		// -------------------------- KP
		
//*mata: V[1..5,1..5]

_makesymmetric(V)

}

end


*********************************************************************************************
*********************************************************************************************
*     Program to compute corrected standard errors for IV Spatial and Network Databases	    *
*		   		  Copyright: F. Colella, R. Lalive, S.O. Sakalli, M. Thoenig			    *
*											  												*
*			Beta Version, please do not circulate - This Version: November 2017			    *
*********************************************************************************************
*********************************************************************************************

capt program drop acreg_spat_ll_no_bart
program acreg_spat_ll_no_bart, eclass
	version 12
	syntax [,  storeweights storedistances ] // storedistances to be implemented 

mata {	
X=(X, J(rows(Y),1,1))
Z=(Z, J(rows(Y),1,1))
K = cols(X)

// 2SLS: parameters
W=invsym(Z'Z)
P=invsym(X'Z * W * Z'X)* X'Z * W *Z'
b=P * Y
res = Y-X*b
N=rows(res)

Nend = cols(KY) 	// -------------------------- KP
Niv = cols(KZ) 		// -------------------------- KP
Nie = Nend*Niv		// -------------------------- KP 

*------------------------------------------------------------------------
*        -------------------------- KP --------------------------	 	*
* Partial out X, p refers to partialling out
KX = (KX, J(rows(Y),1,1))

Zp1 = KX'*KZ
Zp2 = KX*invsym(KX'KX)*Zp1
Zp = KZ - Zp2

Yp1 = KX'*KY
Yp2 = KX*invsym(KX'KX)*Yp1
Yp = KY - Yp2

yp1 = KX'*Y
yp2 = KX*invsym(KX'KX)*yp1
yp = Y - yp2

* VCV first stage parameters
mata: u1 = (invsym(Zp'Zp)*Zp') * Yp

u1 = (invsym(Zp'Zp)*Zp') * Yp
u2 = Zp * u1
u = Yp - u2 

Sz = 1/sqrt(N)*Zp'
SzN = Sz

*------------------------------------------------------------------------
}
*
/*
* First stage
mata: PZ=Z*invsym(Z'Z)*Z'
mata: MZ=I(rows(PZ))-PZ


mata: X1=Xe[.,1]
mata: X2=Xe[.,2]

mata: gamma1=PZ * X1
*mata: rows(gamma1)
mata: resX1 = MZ * X1

mata: VCV1 = PZ * (resX1 * resX1' :* cluster) * PZ'
mata: VCV1 = VCV1[|1,1\16,16|]

mata: F1 = (gamma1[.,1..Niv]'*invsym(VCV1)*gamma1[.,1..Niv])/Niv
*/

mata {

// 2SLS: VCV
V = J(K,K, 0)
nonzero = 0
ind = 0
pos = 0

AVCVb_fs_1 = J(Nie,Nie, 0) 		// -------------------------- KP 
AVCVb_fs = J(Nie,Nie, 0)   		// -------------------------- KP 

// values 
a = .01745329
c = 6371
pi = 3.141593

Idunique = uniqrows(id_vec)
NId = rows(Idunique)

*some vars for checks
**dist= J(N,NId, 0)
**adjj= J(N,N, 0)



if ("`storeweights'" == "storeweights"){
weigg = J(N,N, 0)
for (i = 1; i <= NId; i++){

	rows_ni = id_vec:==Idunique[i,1] 
	
	// __ Get subsets of variables for ID i (without changing original matrix)
	time1 = select(time, rows_ni)
	t1 = length(time1)
	
	// __ Weights ID i vector
	w = J(N,1, 0)
	distance_i = J(N,1, 0)
	
	// __ Indicator variables (start, end)
	s = ind + 1
	e = ind + t1
	
	// __ Vector of weights (different ID)
		if (distcutoff_s>0) {
	
		// a) Computing Distance vector
			lon_scale = cos(lat[s,1]*pi()/180)*111 
			lat_scale = 111
			distance_i = ((lat_scale*(lat[s,1]:-lat[.,1])):^2 + /// 	
					  (lon_scale*(lon[s,1]:-lon[.,1])):^2):^0.5
		}
		
**dist[.,i] = distance_i // check
		
	for (t = 1; t <= t1; t++){
	
	// __ Indicator variables (position in the vector)
	pos  = ind + t		
	if (distcutoff_s>0) {	
	// a) Computing Weights
		time_dis_gap_i = abs(time1[t,1] :- time[.,1])
		weight_dis = (1 :- time_dis_gap_i :/ (lagdistcutoff_s +1)) :* (time_dis_gap_i :<= lagdistcutoff_s) :* (distance_i :<= distcutoff_s)
		w[.,1] = weight_dis
	}
	if (lagcutoff_s>0) {
	// __ Vector of weights (same ID)
		time_gap_i = abs(time1[t,1] :- time1)
		time_gap_cut_i = time_gap_i :<= lagcutoff_s
		weight = (1 :- time_gap_i :/ (lagcutoff_s +1)):* (time_gap_i :<= lagcutoff_s)
		w[s..e,1] = weight
	}
	else {
	w[s..e,1] = J(t1,1,0)
	w[pos,1] = 1
	}
	// __ VCV	
		wz = w :> 0
		nonzero = nonzero + sum(wz) 
		V1 =  P * (res :* res[pos,1] * w[.,1]) * (P[.,pos])'
		V = V + V1
		weigg[.,pos] = w[.,1]
		AVCVb_fs_1 = (I(Nend)#SzN) * ((vec(u) * u[pos,.]) :* (J(Nend,1, 1)# w[.,1])) * (I(Nend)#SzN[.,pos])' // -------------------------- KP // -------------------------- KP
		AVCVb_fs =  AVCVb_fs + AVCVb_fs_1																	 // -------------------------- KP
		
**adjj[.,ind+1] = w[.,1] // check
	}
	
	ind = ind + t1
}

*
st_matrix("weightsmat", weigg)
}
else {
for (i = 1; i <= NId; i++){

	rows_ni = id_vec:==Idunique[i,1] 
	
	// __ Get subsets of variables for ID i (without changing original matrix)
	time1 = select(time, rows_ni)
	t1 = length(time1)
	
	// __ Weights ID i vector
	w = J(N,1, 0)
	distance_i = J(N,1, 0)
	
	// __ Indicator variables (start, end)
	s = ind + 1
	e = ind + t1
	
	// __ Vector of weights (different ID)
		if (distcutoff_s>0) {
	
		// a) Computing Distance vector
			lon_scale = cos(lat[s,1]*pi()/180)*111 
			lat_scale = 111
			distance_i = ((lat_scale*(lat[s,1]:-lat[.,1])):^2 + /// 	
					  (lon_scale*(lon[s,1]:-lon[.,1])):^2):^0.5
		}
		
		
	for (t = 1; t <= t1; t++){
	
	// __ Indicator variables (position in the vector)
	pos  = ind + t		
	if (distcutoff_s>0) {	
	// a) Computing Weights
		time_dis_gap_i = abs(time1[t,1] :- time[.,1])
		weight_dis = (1 :- time_dis_gap_i :/ (lagdistcutoff_s +1)) :* (time_dis_gap_i :<= lagdistcutoff_s) :* (distance_i :<= distcutoff_s)
		w[.,1] = weight_dis
	}
	if (lagcutoff_s>0) {
	// __ Vector of weights (same ID)
		time_gap_i = abs(time1[t,1] :- time1)
		time_gap_cut_i = time_gap_i :<= lagcutoff_s
		weight = (1 :- time_gap_i :/ (lagcutoff_s +1)):* (time_gap_i :<= lagcutoff_s)
		w[s..e,1] = weight
	}
	else {
	w[s..e,1] = J(t1,1,0)
	w[pos,1] = 1
	}
	// __ VCV	
		wz = w :> 0
		nonzero = nonzero + sum(wz) 
		V1 =  P * (res :* res[pos,1] * w[.,1]) * (P[.,pos])'
		V = V + V1 
		AVCVb_fs_1 = (I(Nend)#SzN) * ((vec(u) * u[pos,.]) :* (J(Nend,1, 1)# w[.,1])) * (I(Nend)#SzN[.,pos])' // -------------------------- KP
		AVCVb_fs =  AVCVb_fs + AVCVb_fs_1																	 // -------------------------- KP
		
**adjj[.,ind+1] = w[.,1] // check
	}
	
	ind = ind + t1
}

*
}
*

_makesymmetric(V)

}
end


*********************************************************************************************
*********************************************************************************************
*     Program to compute corrected standard errors for IV Spatial and Network Databases	    *
*		   		  Copyright: F. Colella, R. Lalive, S.O. Sakalli, M. Thoenig			    *
*											  												*
*			Beta Version, please do not circulate - This Version: November 2017			    *
*********************************************************************************************
*********************************************************************************************

capt program drop acreg_spat_ll_bart
program acreg_spat_ll_bart, eclass
	version 12
	syntax  [, storeweights storedistances ] // storedistances to be implemented

mata {	
X=(X, J(rows(Y),1,1))
Z=(Z, J(rows(Y),1,1))
K = cols(X)

// 2SLS: parameters
W=invsym(Z'Z)
P=invsym(X'Z * W * Z'X)* X'Z * W *Z'
b=P * Y
res = Y-X*b
N=rows(res)

Nend = cols(KY) 	// -------------------------- KP
Niv = cols(KZ) 		// -------------------------- KP
Nie = Nend*Niv		// -------------------------- KP 

*------------------------------------------------------------------------
*        -------------------------- KP --------------------------	 	*
* Partial out X, p refers to partialling out
KX = (KX, J(rows(Y),1,1))

Zp1 = KX'*KZ
Zp2 = KX*invsym(KX'KX)*Zp1
Zp = KZ - Zp2

Yp1 = KX'*KY
Yp2 = KX*invsym(KX'KX)*Yp1
Yp = KY - Yp2

yp1 = KX'*Y
yp2 = KX*invsym(KX'KX)*yp1
yp = Y - yp2

* VCV first stage parameters
mata: u1 = (invsym(Zp'Zp)*Zp') * Yp

u1 = (invsym(Zp'Zp)*Zp') * Yp
u2 = Zp * u1
u = Yp - u2 

Sz = 1/sqrt(N)*Zp'
SzN = Sz

*------------------------------------------------------------------------
}
*
/*
* First stage
mata: PZ=Z*invsym(Z'Z)*Z'
mata: MZ=I(rows(PZ))-PZ


mata: X1=Xe[.,1]
mata: X2=Xe[.,2]

mata: gamma1=PZ * X1
*mata: rows(gamma1)
mata: resX1 = MZ * X1

mata: VCV1 = PZ * (resX1 * resX1' :* cluster) * PZ'
mata: VCV1 = VCV1[|1,1\16,16|]

mata: F1 = (gamma1[.,1..Niv]'*invsym(VCV1)*gamma1[.,1..Niv])/Niv
*/

mata {

// 2SLS: VCV
V = J(K,K, 0)
nonzero = 0
ind = 0
pos = 0

AVCVb_fs_1 = J(Nie,Nie, 0) 		// -------------------------- KP 
AVCVb_fs = J(Nie,Nie, 0)   		// -------------------------- KP 

// values 
a = .01745329
c = 6371
pi = 3.141593

Idunique = uniqrows(id_vec)
NId = rows(Idunique)

*some vars for checks
**dist= J(N,NId, 0)
**adjj= J(N,N, 0)

if ("`storeweights'" == "storeweights"){
weigg = J(N,N, 0)
for (i = 1; i <= NId; i++){

	rows_ni = id_vec:==Idunique[i,1] 
	
	// __ Get subsets of variables for ID i (without changing original matrix)
	time1 = select(time, rows_ni)
	t1 = length(time1)
	
	// __ Weights ID i vector
	w = J(N,1, 0)
	distance_i = J(N,1, 0)
	
	// __ Indicator variables (start, end)
	s = ind + 1
	e = ind + t1
	
	// __ Vector of weights (different ID)
		if (distcutoff_s>0) {
	
		// a) Computing Distance vector
			lon_scale = cos(lat[s,1]*pi()/180)*111 
			lat_scale = 111
			distance_i = ((lat_scale*(lat[s,1]:-lat[.,1])):^2 + /// 	
					  (lon_scale*(lon[s,1]:-lon[.,1])):^2):^0.5
		}

	for (t = 1; t <= t1; t++){
	
	// __ Indicator variables (position in the vector)
	pos  = ind + t		
	if (distcutoff_s>0) {
	// a) Computing Weights
			time_dis_gap_i = abs(time1[t,1] :- time[.,1])
			weight_dis = (1 :- time_dis_gap_i :/ (lagdistcutoff_s +1)):*(1:-abs(distance_i :/ distcutoff_s)) :* ( (time_dis_gap_i :<= lagdistcutoff_s) :* (distance_i :<= distcutoff_s))	
			w[.,1] = weight_dis	
	}
	if (lagcutoff_s>0) {	
	// __ Vector of weights (same ID)
		time_gap_i = abs(time1[t,1] :- time1)
		time_gap_cut_i = time_gap_i :<= lagcutoff_s
		weight = (1 :- time_gap_i :/ (lagcutoff_s +1)):* (time_gap_i :<= lagcutoff_s)
		w[s..e,1] = weight
	}
	else {
	w[s..e,1] = J(t1,1,0)
	w[pos,1] = 1
	}
	// __ VCV	
		wz = w :> 0
		nonzero = nonzero + sum(wz)
		V1 =  P * (res :* res[pos,1] * w[.,1]) * (P[.,pos])'
		V = V + V1
		weigg[.,pos] = w[.,1]
		AVCVb_fs_1 = (I(Nend)#SzN) * ((vec(u) * u[pos,.]) :* (J(Nend,1, 1)# w[.,1])) * (I(Nend)#SzN[.,pos])' // -------------------------- KP 
		AVCVb_fs =  AVCVb_fs + AVCVb_fs_1																	 // -------------------------- KP
	}	
	
	ind = ind + t1
}

*
st_matrix("weightsmat", weigg)
}
else {
for (i = 1; i <= NId; i++){

	rows_ni = id_vec:==Idunique[i,1] 
	
	// __ Get subsets of variables for ID i (without changing original matrix)
	time1 = select(time, rows_ni)
	t1 = length(time1)
	
	// __ Weights ID i vector
	w = J(N,1, 0)
	distance_i = J(N,1, 0)
	
	// __ Indicator variables (start, end)
	s = ind + 1
	e = ind + t1
	
	// __ Vector of weights (different ID)
		if (distcutoff_s>0) {
	
		// a) Computing Distance vector
			lon_scale = cos(lat[s,1]*pi()/180)*111 
			lat_scale = 111
			distance_i = ((lat_scale*(lat[s,1]:-lat[.,1])):^2 + /// 	
					  (lon_scale*(lon[s,1]:-lon[.,1])):^2):^0.5
		}

	for (t = 1; t <= t1; t++){
	
	// __ Indicator variables (position in the vector)
	pos  = ind + t		
	if (distcutoff_s>0) {
	// a) Computing Weights
			time_dis_gap_i = abs(time1[t,1] :- time[.,1])
			weight_dis = (1 :- time_dis_gap_i :/ (lagdistcutoff_s +1)):*(1:-abs(distance_i :/ distcutoff_s)) :* ( (time_dis_gap_i :<= lagdistcutoff_s) :* (distance_i :<= distcutoff_s))	
			w[.,1] = weight_dis	
	}
	if (lagcutoff_s>0) {	
	// __ Vector of weights (same ID)
		time_gap_i = abs(time1[t,1] :- time1)
		time_gap_cut_i = time_gap_i :<= lagcutoff_s
		weight = (1 :- time_gap_i :/ (lagcutoff_s +1)):* (time_gap_i :<= lagcutoff_s)
		w[s..e,1] = weight
	}
	else {
	w[s..e,1] = J(t1,1,0)
	w[pos,1] = 1
	}
	// __ VCV	
		wz = w :> 0
		nonzero = nonzero + sum(wz)
		V1 =  P * (res :* res[pos,1] * w[.,1]) * (P[.,pos])'
		V = V + V1
		AVCVb_fs_1 = (I(Nend)#SzN) * ((vec(u) * u[pos,.]) :* (J(Nend,1, 1)# w[.,1])) * (I(Nend)#SzN[.,pos])' // -------------------------- KP 
		AVCVb_fs =  AVCVb_fs + AVCVb_fs_1																	 // -------------------------- KP	
	}	
	
	ind = ind + t1
}

*
}
*

_makesymmetric(V)

}
end


*********************************************************************************************
*********************************************************************************************
*     Program to compute corrected standard errors for IV Spatial and Network Databases	    *
*		   		  Copyright: F. Colella, R. Lalive, S.O. Sakalli, M. Thoenig			    *
*											  												*
*			Beta Version, please do not circulate - This Version: November 2017			    *
*********************************************************************************************
*********************************************************************************************

capt program drop acreg_spat_dist_no_bart
program acreg_spat_dist_no_bart, eclass
	version 12
	syntax [, storeweights ]  

mata {	
X=(X, J(rows(Y),1,1))
Z=(Z, J(rows(Y),1,1))
K = cols(X)

// 2SLS: parameters
W=invsym(Z'Z)
P=invsym(X'Z * W * Z'X)* X'Z * W *Z'
b=P * Y
res = Y-X*b
N=rows(res)

Nend = cols(KY) 	// -------------------------- KP
Niv = cols(KZ) 		// -------------------------- KP
Nie = Nend*Niv		// -------------------------- KP 

*------------------------------------------------------------------------
*        -------------------------- KP --------------------------	 	*
* Partial out X, p refers to partialling out
KX = (KX, J(rows(Y),1,1))

Zp1 = KX'*KZ
Zp2 = KX*invsym(KX'KX)*Zp1
Zp = KZ - Zp2

Yp1 = KX'*KY
Yp2 = KX*invsym(KX'KX)*Yp1
Yp = KY - Yp2

yp1 = KX'*Y
yp2 = KX*invsym(KX'KX)*yp1
yp = Y - yp2

* VCV first stage parameters
mata: u1 = (invsym(Zp'Zp)*Zp') * Yp

u1 = (invsym(Zp'Zp)*Zp') * Yp
u2 = Zp * u1
u = Yp - u2 

Sz = 1/sqrt(N)*Zp'
SzN = Sz

*------------------------------------------------------------------------
}
*
/*
* First stage
mata: PZ=Z*invsym(Z'Z)*Z'
mata: MZ=I(rows(PZ))-PZ


mata: X1=Xe[.,1]
mata: X2=Xe[.,2]

mata: gamma1=PZ * X1
*mata: rows(gamma1)
mata: resX1 = MZ * X1

mata: VCV1 = PZ * (resX1 * resX1' :* cluster) * PZ'
mata: VCV1 = VCV1[|1,1\16,16|]

mata: F1 = (gamma1[.,1..Niv]'*invsym(VCV1)*gamma1[.,1..Niv])/Niv
*/

mata {

// 2SLS: VCV
V = J(K,K, 0)
nonzero = 0
ind = 0
pos = 0

AVCVb_fs_1 = J(Nie,Nie, 0) 		// -------------------------- KP 
AVCVb_fs = J(Nie,Nie, 0)   		// -------------------------- KP 

// values 
a = .01745329
c = 6371
pi = 3.141593

Idunique = uniqrows(id_vec)
NId = rows(Idunique)
d_cols = cols(distance)

st_local("NId", strofreal(NId))
st_local("d_cols", strofreal(d_cols))

}

if `NId' != `d_cols' {
	disp as error "The number of columns in the distance matrix is different than the number of individuals"
exit 498
}

mata {

if ("`storeweights'" == "storeweights"){
weigg = J(N,N, 0)
for (i = 1; i <= NId; i++){

	rows_ni = id_vec:==Idunique[i,1] 
	
	// __ Get subsets of variables for ID i (without changing original matrix)
	time1 = select(time, rows_ni)
	t1 = length(time1)
	
	// __ Weights ID i vector
	w = J(N,1, 0)
	distance_i = J(N,1, 0)
	
	// __ Indicator variables (start, end)
	s = ind + 1
	e = ind + t1
	
	// __ Vector of weights (different ID)
		if (distcutoff_s>0) {
	
		// a) Computing Distance vector
			distance_i = distance[.,i]		
		}
		
	for (t = 1; t <= t1; t++){
	
	// __ Indicator variables (position in the vector)
	pos  = ind + t		
	if (distcutoff_s>0) {	
	// a) Computing Weights
		time_dis_gap_i = abs(time1[t,1] :- time[.,1])
		weight_dis = (1 :- time_dis_gap_i :/ (lagdistcutoff_s +1)) :* (time_dis_gap_i :<= lagdistcutoff_s) :* (distance_i :<= distcutoff_s) 
		w[.,1] = weight_dis
	}
	if (lagcutoff_s>0) {
	// __ Vector of weights (same ID)
		time_gap_i = abs(time1[t,1] :- time1)
		time_gap_cut_i = time_gap_i :<= lagcutoff_s
		weight = (1 :- time_gap_i :/ (lagcutoff_s +1)):* (time_gap_i :<= lagcutoff_s)
		w[s..e,1] = weight
	}
	else {
	w[s..e,1] = J(t1,1,0)
	w[pos,1] = 1
	}
	// __ VCV	
		wz = w :> 0
		nonzero = nonzero + sum(wz) 
		V1 =  P * (res :* res[pos,1] * w[.,1]) * (P[.,pos])'
		V = V + V1
		weigg[.,pos] = w[.,1]
		AVCVb_fs_1 = (I(Nend)#SzN) * ((vec(u) * u[pos,.]) :* (J(Nend,1, 1)# w[.,1])) * (I(Nend)#SzN[.,pos])' // -------------------------- KP
		AVCVb_fs =  AVCVb_fs + AVCVb_fs_1																	 // -------------------------- KP
	}
	
	ind = ind + t1
}
*
st_matrix("weightsmat", weigg)
}
else {
for (i = 1; i <= NId; i++){

	rows_ni = id_vec:==Idunique[i,1] 
	
	// __ Get subsets of variables for ID i (without changing original matrix)
	time1 = select(time, rows_ni)
	t1 = length(time1)
	
	// __ Weights ID i vector
	w = J(N,1, 0)
	distance_i = J(N,1, 0)
	
	// __ Indicator variables (start, end)
	s = ind + 1
	e = ind + t1
	
	// __ Vector of weights (different ID)
		if (distcutoff_s>0) {
	
		// a) Computing Distance vector
			distance_i = distance[.,i]
		}
		
	for (t = 1; t <= t1; t++){
	
	// __ Indicator variables (position in the vector)
	pos  = ind + t		
	if (distcutoff_s>0) {	
	// a) Computing Weights
		time_dis_gap_i = abs(time1[t,1] :- time[.,1])
		weight_dis = (1 :- time_dis_gap_i :/ (lagdistcutoff_s +1)) :* (time_dis_gap_i :<= lagdistcutoff_s) :* (distance_i :<= distcutoff_s) 
		w[.,1] = weight_dis
	}
	if (lagcutoff_s>0) {
	// __ Vector of weights (same ID)
		time_gap_i = abs(time1[t,1] :- time1)
		time_gap_cut_i = time_gap_i :<= lagcutoff_s
		weight = (1 :- time_gap_i :/ (lagcutoff_s +1)):* (time_gap_i :<= lagcutoff_s)
		w[s..e,1] = weight
	}
	else {
	w[s..e,1] = J(t1,1,0)
	w[pos,1] = 1
	}
	// __ VCV	
		wz = w :> 0
		nonzero = nonzero + sum(wz) 
		V1 =  P * (res :* res[pos,1] * w[.,1]) * (P[.,pos])'
		V = V + V1
		AVCVb_fs_1 = (I(Nend)#SzN) * ((vec(u) * u[pos,.]) :* (J(Nend,1, 1)# w[.,1])) * (I(Nend)#SzN[.,pos])' // -------------------------- KP 
		AVCVb_fs =  AVCVb_fs + AVCVb_fs_1																	 // -------------------------- KP
	}
	
	ind = ind + t1
}


*
}
*

_makesymmetric(V)

}

end


*********************************************************************************************
*********************************************************************************************
*     Program to compute corrected standard errors for IV Spatial and Network Databases	    *
*		   		  Copyright: F. Colella, R. Lalive, S.O. Sakalli, M. Thoenig			    *
*											  												*
*			Beta Version, please do not circulate - This Version: November 2017			    *
*********************************************************************************************
*********************************************************************************************

capt program drop acreg_spat_dist_bart
program acreg_spat_dist_bart, eclass
	version 12
	syntax  [,storeweights ]  
	
mata {	
X=(X, J(rows(Y),1,1))
Z=(Z, J(rows(Y),1,1))
K = cols(X)

// 2SLS: parameters
W=invsym(Z'Z)
P=invsym(X'Z * W * Z'X)* X'Z * W *Z'
b=P * Y
res = Y-X*b
N=rows(res)

Nend = cols(KY) 	// -------------------------- KP
Niv = cols(KZ) 		// -------------------------- KP
Nie = Nend*Niv		// -------------------------- KP 

*------------------------------------------------------------------------
*        -------------------------- KP --------------------------	 	*
* Partial out X, p refers to partialling out
KX = (KX, J(rows(Y),1,1))

Zp1 = KX'*KZ
Zp2 = KX*invsym(KX'KX)*Zp1
Zp = KZ - Zp2

Yp1 = KX'*KY
Yp2 = KX*invsym(KX'KX)*Yp1
Yp = KY - Yp2

yp1 = KX'*Y
yp2 = KX*invsym(KX'KX)*yp1
yp = Y - yp2

* VCV first stage parameters
mata: u1 = (invsym(Zp'Zp)*Zp') * Yp

u1 = (invsym(Zp'Zp)*Zp') * Yp
u2 = Zp * u1
u = Yp - u2 

Sz = 1/sqrt(N)*Zp'
SzN = Sz

*------------------------------------------------------------------------
}
*
/*
* First stage
mata: PZ=Z*invsym(Z'Z)*Z'
mata: MZ=I(rows(PZ))-PZ


mata: X1=Xe[.,1]
mata: X2=Xe[.,2]

mata: gamma1=PZ * X1
*mata: rows(gamma1)
mata: resX1 = MZ * X1

mata: VCV1 = PZ * (resX1 * resX1' :* cluster) * PZ'
mata: VCV1 = VCV1[|1,1\16,16|]

mata: F1 = (gamma1[.,1..Niv]'*invsym(VCV1)*gamma1[.,1..Niv])/Niv
*/

mata {

// 2SLS: VCV
V = J(K,K, 0)
nonzero = 0
ind = 0
pos = 0

AVCVb_fs_1 = J(Nie,Nie, 0) 		// -------------------------- KP 
AVCVb_fs = J(Nie,Nie, 0)   		// -------------------------- KP 

// values 
a = .01745329
c = 6371
pi = 3.141593

Idunique = uniqrows(id_vec)
NId = rows(Idunique)
d_cols = cols(distance)

st_local("NId", strofreal(NId))
st_local("d_cols", strofreal(d_cols))

}

if `NId' != `d_cols' {
	disp as error "The number of columns in the distance matrix is different than the number of individuals"
exit 498
}

mata {

if ("`storeweights'" == "storeweights"){
weigg = J(N,N, 0)
for (i = 1; i <= NId; i++){

	rows_ni = id_vec:==Idunique[i,1] 
	
	// __ Get subsets of variables for ID i (without changing original matrix)
	time1 = select(time, rows_ni)
	t1 = length(time1)
	
	// __ Weights ID i vector
	w = J(N,1, 0)
	distance_i = J(N,1, 0)
	
	// __ Indicator variables (start, end)
	s = ind + 1
	e = ind + t1
	
	// __ Vector of weights (different ID)
		if (distcutoff_s>0) {
	
		// a) Computing Distance vector			
			distance_i = distance[.,i]
		}
		
	for (t = 1; t <= t1; t++){
	
	// __ Indicator variables (position in the vector)
	pos  = ind + t		
	if (distcutoff_s>0) {
	// a) Computing Weights
		time_dis_gap_i = abs(time1[t,1] :- time[.,1])
		weight_dis = (1 :- time_dis_gap_i :/ (lagdistcutoff_s +1)):*(1:-abs(distance_i :/ distcutoff_s)) :* ( (time_dis_gap_i :<= lagdistcutoff_s) :* (distance_i :<= distcutoff_s)) 
		w[.,1] = weight_dis	
	}
	if (lagcutoff_s>0) {	
	// __ Vector of weights (same ID)
		time_gap_i = abs(time1[t,1] :- time1)
		time_gap_cut_i = time_gap_i :<= lagcutoff_s
		weight = (1 :- time_gap_i :/ (lagcutoff_s +1)):* (time_gap_i :<= lagcutoff_s)
		w[s..e,1] = weight
	}
	else {
	w[s..e,1] = J(t1,1,0)
	w[pos,1] = 1
	}
	// __ VCV	
		wz = w :> 0
		nonzero = nonzero + sum(wz)
		V1 =  P * (res :* res[pos,1] * w[.,1]) * (P[.,pos])'
		V = V + V1
		weigg[.,pos] = w[.,1]
		AVCVb_fs_1 = (I(Nend)#SzN) * ((vec(u) * u[pos,.]) :* (J(Nend,1, 1)# w[.,1])) * (I(Nend)#SzN[.,pos])' // -------------------------- KP 
		AVCVb_fs =  AVCVb_fs + AVCVb_fs_1																	 // -------------------------- KP
	}	
	
	ind = ind + t1
}

*
st_matrix("weightsmat", weigg)
}
else {
for (i = 1; i <= NId; i++){

	rows_ni = id_vec:==Idunique[i,1] 
	
	// __ Get subsets of variables for ID i (without changing original matrix)
	time1 = select(time, rows_ni)
	t1 = length(time1)
	
	// __ Weights ID i vector
	w = J(N,1, 0)
	distance_i = J(N,1, 0)
	
	// __ Indicator variables (start, end)
	s = ind + 1
	e = ind + t1
	
	// __ Vector of weights (different ID)
		if (distcutoff_s>0) {
	
		// a) Computing Distance vector
			
			distance_i = distance[.,i]
			
			*lon_scale = cos(lat[s,1]*pi()/180)*111 
			*lat_scale = 111
			*distance_i = ((lat_scale*(lat[s,1]:-lat[.,1])):^2 + /// 	
			*		  (lon_scale*(lon[s,1]:-lon[.,1])):^2):^0.5
		}
		
	for (t = 1; t <= t1; t++){
	
	// __ Indicator variables (position in the vector)
	pos  = ind + t		
	if (distcutoff_s>0) {
	// a) Computing Weights
		time_dis_gap_i = abs(time1[t,1] :- time[.,1])
		weight_dis = (1 :- time_dis_gap_i :/ (lagdistcutoff_s +1)):*(1:-abs(distance_i :/ distcutoff_s)) :* ( (time_dis_gap_i :<= lagdistcutoff_s) :* (distance_i :<= distcutoff_s)) 
		w[.,1] = weight_dis	
	}
	if (lagcutoff_s>0) {	
	// __ Vector of weights (same ID)
		time_gap_i = abs(time1[t,1] :- time1)
		time_gap_cut_i = time_gap_i :<= lagcutoff_s
		weight = (1 :- time_gap_i :/ (lagcutoff_s +1)):* (time_gap_i :<= lagcutoff_s)
		w[s..e,1] = weight
	}
	else {
	w[s..e,1] = J(t1,1,0)
	w[pos,1] = 1
	}
	// __ VCV	
		wz = w :> 0
		nonzero = nonzero + sum(wz)
		V1 =  P * (res :* res[pos,1] * w[.,1]) * (P[.,pos])'
		V = V + V1
		AVCVb_fs_1 = (I(Nend)#SzN) * ((vec(u) * u[pos,.]) :* (J(Nend,1, 1)# w[.,1])) * (I(Nend)#SzN[.,pos])' // -------------------------- KP 
		AVCVb_fs =  AVCVb_fs + AVCVb_fs_1																	 // -------------------------- KP
	}	
	
	ind = ind + t1
}

*
}
*
//*mata: V[1..5,1..5]

_makesymmetric(V)

}

end


*********************************************************************************************
*********************************************************************************************
*     Program to compute corrected standard errors for IV Spatial and Network Databases	    *
*		   		  Copyright: F. Colella, R. Lalive, S.O. Sakalli, M. Thoenig			    *
*											  												*
*			Beta Version, please do not circulate - This Version: November 2017			    *
*********************************************************************************************
*********************************************************************************************

capt program drop acreg_netw_links_no_bart
program acreg_netw_links_no_bart, eclass
	version 12
	syntax [, storeweights ] 

mata {	
X=(X, J(rows(Y),1,1))
Z=(Z, J(rows(Y),1,1))
K = cols(X)

// 2SLS: parameters
W=invsym(Z'Z)
P=invsym(X'Z * W * Z'X)* X'Z * W *Z'
b=P * Y
res = Y-X*b
N=rows(res)

Nend = cols(KY) 	// -------------------------- KP
Niv = cols(KZ) 		// -------------------------- KP
Nie = Nend*Niv		// -------------------------- KP 

*------------------------------------------------------------------------
*        -------------------------- KP --------------------------	 	*
* Partial out X, p refers to partialling out
KX = (KX, J(rows(Y),1,1))

Zp1 = KX'*KZ
Zp2 = KX*invsym(KX'KX)*Zp1
Zp = KZ - Zp2

Yp1 = KX'*KY
Yp2 = KX*invsym(KX'KX)*Yp1
Yp = KY - Yp2

yp1 = KX'*Y
yp2 = KX*invsym(KX'KX)*yp1
yp = Y - yp2

* VCV first stage parameters
mata: u1 = (invsym(Zp'Zp)*Zp') * Yp

u1 = (invsym(Zp'Zp)*Zp') * Yp
u2 = Zp * u1
u = Yp - u2 

Sz = 1/sqrt(N)*Zp'
SzN = Sz

*------------------------------------------------------------------------
}
*
/*
* First stage
mata: PZ=Z*invsym(Z'Z)*Z'
mata: MZ=I(rows(PZ))-PZ


mata: X1=Xe[.,1]
mata: X2=Xe[.,2]

mata: gamma1=PZ * X1
*mata: rows(gamma1)
mata: resX1 = MZ * X1

mata: VCV1 = PZ * (resX1 * resX1' :* cluster) * PZ'
mata: VCV1 = VCV1[|1,1\16,16|]

mata: F1 = (gamma1[.,1..Niv]'*invsym(VCV1)*gamma1[.,1..Niv])/Niv
*/

mata {

// 2SLS: VCV
V = J(K,K, 0)
nonzero = 0
ind = 0
pos = 0

AVCVb_fs_1 = J(Nie,Nie, 0) 		// -------------------------- KP 
AVCVb_fs = J(Nie,Nie, 0)   		// -------------------------- KP 

// values 
a = .01745329
c = 6371
pi = 3.141593

Idunique = uniqrows(id_vec)
NId = rows(Idunique)
l_cols = cols(links)

st_local("NId", strofreal(NId))
st_local("l_cols", strofreal(l_cols))

}

if `NId' != `l_cols' {
	disp as error "The number of columns in the links matrix is different than the number of individuals"
exit 498
}

mata {


				//************************************************************
				// __ Creating Distances from links
				if (distcutoff_s>0) {
				// __ a) From NTxN to NxN
					
					distance = J(N,NId, 0)
					
					if (distcutoff_s==1) {
						distance = links		
					}
					else {
			
						B_ind = 0
						NN_dist = J(NId,NId, 0)
						NN_links = J(NId,NId, 0)

						for (i = 1; i <= NId; i++){
							B_rows_ni = id_vec:==Idunique[i,1] 
							
							B_time1 = select(time, B_rows_ni)
							B_t1 = length(B_time1)
							
							first_ind_line = B_ind + 1
							NN_links[i,.] = links[first_ind_line,.]
							
							B_ind = B_ind + B_t1	
						}
			
				// __ b) Taking power of a matrix
				
				
						NN_links_pow = NN_links
						NN_dist = NN_links
						for (k = 1; k <= 100; k++){
				//powers 	
							if (distcutoff_s>k) {
								NN_links_pow = NN_links_pow * NN_links 
								NN_links_pow_ind = (NN_links_pow:!= 0) :* (k+1) :* (NN_dist :== 0)
								NN_dist = NN_dist + NN_links_pow_ind 
							}
						}

					// __ c) Form NxN to NTxN 
						B_ind = 0
						for (i = 1; i <= NId; i++){
							B_rows_ni = id_vec:==Idunique[i,1] 
							B_time1 = select(time, B_rows_ni)
							B_t1 = length(B_time1)
							
							for (t = 1; t <= B_t1; t++){
								ind_line = B_ind + t
								distance[ind_line,.] = NN_dist[i,.]
							}
							B_ind = B_ind + B_t1	
						}
					}
				}
				//************************************************************

if ("`storeweights'" == "storeweights"){
weigg = J(N,N, 0)
				
for (i = 1; i <= NId; i++){

	rows_ni = id_vec:==Idunique[i,1] 
	
	// __ Get subsets of variables for ID i (without changing original matrix)
	time1 = select(time, rows_ni)
	t1 = length(time1)
	
	// __ Weights ID i vector
	w = J(N,1, 0)
	distance_i = J(N,1, 0)
	
	// __ Indicator variables (start, end)
	s = ind + 1
	e = ind + t1
	
	// __ Vector of weights (different ID)
		if (distcutoff_s>0) {
	
		// a) Computing Distance vector		
			
			distance_i = distance[.,i]
			
			*lon_scale = cos(lat[s,1]*pi()/180)*111 
			*lat_scale = 111
			*distance_i = ((lat_scale*(lat[s,1]:-lat[.,1])):^2 + /// 	
			*		  (lon_scale*(lon[s,1]:-lon[.,1])):^2):^0.5
		}
		
	for (t = 1; t <= t1; t++){
	
	// __ Indicator variables (position in the vector)
	pos  = ind + t		
	if (distcutoff_s>0) {	
	// a) Computing Weights
		time_dis_gap_i = abs(time1[t,1] :- time[.,1])
		weight_dis = (1 :- time_dis_gap_i :/ (lagdistcutoff_s +1)) :* (time_dis_gap_i :<= lagdistcutoff_s) :* (distance_i :<= distcutoff_s) :* (distance_i :!= 0)
		w[.,1] = weight_dis
	}
	if (lagcutoff_s>0) {
	// __ Vector of weights (same ID)
		time_gap_i = abs(time1[t,1] :- time1)
		time_gap_cut_i = time_gap_i :<= lagcutoff_s
		weight = (1 :- time_gap_i :/ (lagcutoff_s +1)):* (time_gap_i :<= lagcutoff_s)
		w[s..e,1] = weight
	}
	else {
	w[s..e,1] = J(t1,1,0)
	w[pos,1] = 1
	}
	// __ VCV	
		wz = w :> 0
		nonzero = nonzero + sum(wz) 
		V1 =  P * (res :* res[pos,1] * w[.,1]) * (P[.,pos])'
		V = V + V1
		weigg[.,pos] = w[.,1]
		AVCVb_fs_1 = (I(Nend)#SzN) * ((vec(u) * u[pos,.]) :* (J(Nend,1, 1)# w[.,1])) * (I(Nend)#SzN[.,pos])' // -------------------------- KP 
		AVCVb_fs =  AVCVb_fs + AVCVb_fs_1																	 // -------------------------- KP
	}
	ind = ind + t1
}

*
st_matrix("weightsmat", weigg)
}
else {
for (i = 1; i <= NId; i++){
	rows_ni = id_vec:==Idunique[i,1] 
	
	// __ Get subsets of variables for ID i (without changing original matrix)
	time1 = select(time, rows_ni)
	t1 = length(time1)
	
	// __ Weights ID i vector
	w = J(N,1, 0)
	distance_i = J(N,1, 0)
	
	// __ Indicator variables (start, end)
	s = ind + 1
	e = ind + t1
	
	// __ Vector of weights (different ID)
		if (distcutoff_s>0) {
	
		// a) Computing Distance vector
			
			distance_i = distance[.,i]
			
			*lon_scale = cos(lat[s,1]*pi()/180)*111 
			*lat_scale = 111
			*distance_i = ((lat_scale*(lat[s,1]:-lat[.,1])):^2 + /// 	
			*		  (lon_scale*(lon[s,1]:-lon[.,1])):^2):^0.5
		}
		
	for (t = 1; t <= t1; t++){
	
	// __ Indicator variables (position in the vector)
	pos  = ind + t		
	if (distcutoff_s>0) {	
	// a) Computing Weights
		time_dis_gap_i = abs(time1[t,1] :- time[.,1])
		weight_dis = (1 :- time_dis_gap_i :/ (lagdistcutoff_s +1)) :* (time_dis_gap_i :<= lagdistcutoff_s) :* (distance_i :<= distcutoff_s) :* (distance_i :!= 0)
		w[.,1] = weight_dis
	}
	if (lagcutoff_s>0) {
	// __ Vector of weights (same ID)
		time_gap_i = abs(time1[t,1] :- time1)
		time_gap_cut_i = time_gap_i :<= lagcutoff_s
		weight = (1 :- time_gap_i :/ (lagcutoff_s +1)):* (time_gap_i :<= lagcutoff_s)
		w[s..e,1] = weight
	}
	else {
	w[s..e,1] = J(t1,1,0)
	w[pos,1] = 1
	}
	// __ VCV	
		wz = w :> 0
		nonzero = nonzero + sum(wz) 
		V1 =  P * (res :* res[pos,1] * w[.,1]) * (P[.,pos])'
		V = V + V1	
		AVCVb_fs_1 = (I(Nend)#SzN) * ((vec(u) * u[pos,.]) :* (J(Nend,1, 1)# w[.,1])) * (I(Nend)#SzN[.,pos])' // -------------------------- KP 
		AVCVb_fs =  AVCVb_fs + AVCVb_fs_1																	 // -------------------------- KP
	}
	ind = ind + t1
}
*
}
*
//*mata: V[1..5,1..5]

_makesymmetric(V)

}

end


*********************************************************************************************
*********************************************************************************************
*     Program to compute corrected standard errors for IV Spatial and Network Databases	    *
*		   		  Copyright: F. Colella, R. Lalive, S.O. Sakalli, M. Thoenig			    *
*											  												*
*			Beta Version, please do not circulate - This Version: November 2017			    *
*********************************************************************************************
*********************************************************************************************

capt program drop acreg_netw_links_bart
program acreg_netw_links_bart, eclass
	version 12
	syntax  [, storeweights ] 

mata {	
X=(X, J(rows(Y),1,1))
Z=(Z, J(rows(Y),1,1))
K = cols(X)

// 2SLS: parameters
W=invsym(Z'Z)
P=invsym(X'Z * W * Z'X)* X'Z * W *Z'
b=P * Y
res = Y-X*b
N=rows(res)

Nend = cols(KY) 	// -------------------------- KP
Niv = cols(KZ) 		// -------------------------- KP
Nie = Nend*Niv		// -------------------------- KP  

*------------------------------------------------------------------------
*        -------------------------- KP --------------------------	 	*
* Partial out X, p refers to partialling out
KX = (KX, J(rows(Y),1,1))

Zp1 = KX'*KZ
Zp2 = KX*invsym(KX'KX)*Zp1
Zp = KZ - Zp2

Yp1 = KX'*KY
Yp2 = KX*invsym(KX'KX)*Yp1
Yp = KY - Yp2

yp1 = KX'*Y
yp2 = KX*invsym(KX'KX)*yp1
yp = Y - yp2

* VCV first stage parameters
mata: u1 = (invsym(Zp'Zp)*Zp') * Yp

u1 = (invsym(Zp'Zp)*Zp') * Yp
u2 = Zp * u1
u = Yp - u2 

Sz = 1/sqrt(N)*Zp'
SzN = Sz

*------------------------------------------------------------------------
}
*
/*
* First stage
mata: PZ=Z*invsym(Z'Z)*Z'
mata: MZ=I(rows(PZ))-PZ


mata: X1=Xe[.,1]
mata: X2=Xe[.,2]

mata: gamma1=PZ * X1
*mata: rows(gamma1)
mata: resX1 = MZ * X1

mata: VCV1 = PZ * (resX1 * resX1' :* cluster) * PZ'
mata: VCV1 = VCV1[|1,1\16,16|]

mata: F1 = (gamma1[.,1..Niv]'*invsym(VCV1)*gamma1[.,1..Niv])/Niv
*/

mata {

// 2SLS: VCV
V = J(K,K, 0)
nonzero = 0
ind = 0
pos = 0

AVCVb_fs_1 = J(Nie,Nie, 0) 		// -------------------------- KP 
AVCVb_fs = J(Nie,Nie, 0)   		// -------------------------- KP 

// values 
a = .01745329
c = 6371
pi = 3.141593

Idunique = uniqrows(id_vec)
NId = rows(Idunique)
l_cols = cols(links)

st_local("NId", strofreal(NId))
st_local("l_cols", strofreal(l_cols))

}

if `NId' != `l_cols' {
	disp as error "The number of columns in the links matrix is different than the number of individuals"
exit 498
}

mata {
				//************************************************************
				// __ Creating Distances from links
				if (distcutoff_s>0) {
				// __ a) Form NTxN to NxN
					
					distance = J(N,NId, 0)
					
					if (distcutoff_s==1) {
						distance = links		
					}
					else {
			
						B_ind = 0
						NN_dist = J(NId,NId, 0)
						NN_links = J(NId,NId, 0)

						for (i = 1; i <= NId; i++){
							B_rows_ni = id_vec:==Idunique[i,1] 
							
							B_time1 = select(time, B_rows_ni)
							B_t1 = length(B_time1)
							
							first_ind_line = B_ind + 1
							NN_links[i,.] = links[first_ind_line,.]
							
							B_ind = B_ind + B_t1	
						}
			
				// __ b) Taking power of a matrix
				
				
						NN_links_pow = NN_links
						NN_dist = NN_links
						for (k = 1; k <= 100; k++){
				//powers 	
							if (distcutoff_s>k) {
								NN_links_pow = NN_links_pow * NN_links 
								NN_links_pow_ind = (NN_links_pow:!= 0) :* (k+1) :* (NN_dist :== 0)
								NN_dist = NN_dist + NN_links_pow_ind 
							}
						}

					// __ c) Form NxN to NTxN 
						B_ind = 0
						for (i = 1; i <= NId; i++){
							B_rows_ni = id_vec:==Idunique[i,1] 
							B_time1 = select(time, B_rows_ni)
							B_t1 = length(B_time1)
							
							for (t = 1; t <= B_t1; t++){
								ind_line = B_ind + t
								distance[ind_line,.] = NN_dist[i,.]
							}
							B_ind = B_ind + B_t1	
						}
					}
				}
				//************************************************************


if ("`storeweights'" == "storeweights"){
weigg = J(N,N, 0)
for (i = 1; i <= NId; i++){

	rows_ni = id_vec:==Idunique[i,1] 
	
	// __ Get subsets of variables for ID i (without changing original matrix)
	time1 = select(time, rows_ni)
	t1 = length(time1)
	
	// __ Weights ID i vector
	w = J(N,1, 0)
	distance_i = J(N,1, 0)
	
	// __ Indicator variables (start, end)
	s = ind + 1
	e = ind + t1
	
	// __ Vector of weights (different ID)
		if (distcutoff_s>0) {
	
		// a) Computing Distance vector
			distance_i = distance[.,i]
		}
		
	for (t = 1; t <= t1; t++){
	
	// __ Indicator variables (position in the vector)
	pos  = ind + t		
	if (distcutoff_s>0) {
	// a) Computing Weights
		time_dis_gap_i = abs(time1[t,1] :- time[.,1])
		weight_dis = (1 :- time_dis_gap_i :/ (lagdistcutoff_s +1)):*(1:-abs(distance_i :/ distcutoff_s)) :* ( (time_dis_gap_i :<= lagdistcutoff_s) :* (distance_i :<= distcutoff_s)) :* (distance_i :!= 0)	
		w[.,1] = weight_dis	
	}
	if (lagcutoff_s>0) {	
	// __ Vector of weights (same ID)
		time_gap_i = abs(time1[t,1] :- time1)
		time_gap_cut_i = time_gap_i :<= lagcutoff_s
		weight = (1 :- time_gap_i :/ (lagcutoff_s +1)):* (time_gap_i :<= lagcutoff_s)
		w[s..e,1] = weight
	}
	else {
	w[s..e,1] = J(t1,1,0)
	w[pos,1] = 1
	}
	// __ VCV	
		wz = w :> 0
		nonzero = nonzero + sum(wz)
		V1 =  P * (res :* res[pos,1] * w[.,1]) * (P[.,pos])'
		V = V + V1
		weigg[.,pos] = w[.,1]
		AVCVb_fs_1 = (I(Nend)#SzN) * ((vec(u) * u[pos,.]) :* (J(Nend,1, 1)# w[.,1])) * (I(Nend)#SzN[.,pos])' // -------------------------- KP
		AVCVb_fs =  AVCVb_fs + AVCVb_fs_1																	 // -------------------------- KP
	}	
	
	ind = ind + t1
}

*
st_matrix("weightsmat", weigg)
}
else {
for (i = 1; i <= NId; i++){

	rows_ni = id_vec:==Idunique[i,1] 
	
	// __ Get subsets of variables for ID i (without changing original matrix)
	time1 = select(time, rows_ni)
	t1 = length(time1)
	
	// __ Weights ID i vector
	w = J(N,1, 0)
	distance_i = J(N,1, 0)
	
	// __ Indicator variables (start, end)
	s = ind + 1
	e = ind + t1
	
	// __ Vector of weights (different ID)
		if (distcutoff_s>0) {
	
		// a) Computing Distance vector
			distance_i = distance[.,i]
		}
		
	for (t = 1; t <= t1; t++){
	
	// __ Indicator variables (position in the vector)
	pos  = ind + t		
	if (distcutoff_s>0) {
	// a) Computing Weights
		time_dis_gap_i = abs(time1[t,1] :- time[.,1])
		weight_dis = (1 :- time_dis_gap_i :/ (lagdistcutoff_s +1)):*(1:-abs(distance_i :/ distcutoff_s)) :* ( (time_dis_gap_i :<= lagdistcutoff_s) :* (distance_i :<= distcutoff_s)) :* (distance_i :!= 0)	
		w[.,1] = weight_dis	
	}
	if (lagcutoff_s>0) {	
	// __ Vector of weights (same ID)
		time_gap_i = abs(time1[t,1] :- time1)
		time_gap_cut_i = time_gap_i :<= lagcutoff_s
		weight = (1 :- time_gap_i :/ (lagcutoff_s +1)):* (time_gap_i :<= lagcutoff_s)
		w[s..e,1] = weight
	}
	else {
	w[s..e,1] = J(t1,1,0)
	w[pos,1] = 1
	}
	// __ VCV	
		wz = w :> 0
		nonzero = nonzero + sum(wz)
		V1 =  P * (res :* res[pos,1] * w[.,1]) * (P[.,pos])'
		V = V + V1
		AVCVb_fs_1 = (I(Nend)#SzN) * ((vec(u) * u[pos,.]) :* (J(Nend,1, 1)# w[.,1])) * (I(Nend)#SzN[.,pos])' // -------------------------- KP
		AVCVb_fs =  AVCVb_fs + AVCVb_fs_1																	 // -------------------------- KP
	}	
	
	ind = ind + t1
}

*
}
*
//*mata: V[1..5,1..5]

_makesymmetric(V)

}

end


*********************************************************************************************
*********************************************************************************************
*     Program to compute corrected standard errors for IV Spatial and Network Databases	    *
*		   		  Copyright: F. Colella, R. Lalive, S.O. Sakalli, M. Thoenig			    *
*											  												*
*			Beta Version, please do not circulate - This Version: November 2017			    *
*********************************************************************************************
*********************************************************************************************

capt program drop acreg_netw_dist_no_bart
program acreg_netw_dist_no_bart, eclass
	version 12
	syntax  [, storeweights ] 


mata {	
X=(X, J(rows(Y),1,1))
Z=(Z, J(rows(Y),1,1))
K = cols(X)

// 2SLS: parameters
W=invsym(Z'Z)
P=invsym(X'Z * W * Z'X)* X'Z * W *Z'
b=P * Y
res = Y-X*b
N=rows(res)

Nend = cols(KY) 	// -------------------------- KP
Niv = cols(KZ) 		// -------------------------- KP
Nie = Nend*Niv		// -------------------------- KP 

*------------------------------------------------------------------------
*        -------------------------- KP --------------------------	 	*
* Partial out X, p refers to partialling out
KX = (KX, J(rows(Y),1,1))

Zp1 = KX'*KZ
Zp2 = KX*invsym(KX'KX)*Zp1
Zp = KZ - Zp2

Yp1 = KX'*KY
Yp2 = KX*invsym(KX'KX)*Yp1
Yp = KY - Yp2

yp1 = KX'*Y
yp2 = KX*invsym(KX'KX)*yp1
yp = Y - yp2

* VCV first stage parameters
mata: u1 = (invsym(Zp'Zp)*Zp') * Yp

u1 = (invsym(Zp'Zp)*Zp') * Yp
u2 = Zp * u1
u = Yp - u2 

Sz = 1/sqrt(N)*Zp'
SzN = Sz

*------------------------------------------------------------------------
}
*
/*
* First stage
mata: PZ=Z*invsym(Z'Z)*Z'
mata: MZ=I(rows(PZ))-PZ


mata: X1=Xe[.,1]
mata: X2=Xe[.,2]

mata: gamma1=PZ * X1
*mata: rows(gamma1)
mata: resX1 = MZ * X1

mata: VCV1 = PZ * (resX1 * resX1' :* cluster) * PZ'
mata: VCV1 = VCV1[|1,1\16,16|]

mata: F1 = (gamma1[.,1..Niv]'*invsym(VCV1)*gamma1[.,1..Niv])/Niv
*/

mata {

// 2SLS: VCV
V = J(K,K, 0)
nonzero = 0
ind = 0
pos = 0

AVCVb_fs_1 = J(Nie,Nie, 0) 		// -------------------------- KP 
AVCVb_fs = J(Nie,Nie, 0)   		// -------------------------- KP

// values 
a = .01745329
c = 6371
pi = 3.141593

Idunique = uniqrows(id_vec)
NId = rows(Idunique)
d_cols = cols(distance)

st_local("NId", strofreal(NId))
st_local("d_cols", strofreal(d_cols))

}

if `NId' != `d_cols' {
	disp as error "The number of columns in the distance matrix is different than the number of individuals"
exit 498
}

mata {

if ("`storeweights'" == "storeweights"){
weigg = J(N,N, 0)
for (i = 1; i <= NId; i++){

	rows_ni = id_vec:==Idunique[i,1] 
	
	// __ Get subsets of variables for ID i (without changing original matrix)
	time1 = select(time, rows_ni)
	t1 = length(time1)
	
	// __ Weights ID i vector
	w = J(N,1, 0)
	distance_i = J(N,1, 0)
	
	// __ Indicator variables (start, end)
	s = ind + 1
	e = ind + t1
	
	// __ Vector of weights (different ID)
		if (distcutoff_s>0) {
	
		// a) Computing Distance vector
			
			distance_i = distance[.,i]
			
		}
		
	for (t = 1; t <= t1; t++){
	
	// __ Indicator variables (position in the vector)
	pos  = ind + t		
	if (distcutoff_s>0) {	
	// a) Computing Weights
		time_dis_gap_i = abs(time1[t,1] :- time[.,1])
		weight_dis = (1 :- time_dis_gap_i :/ (lagdistcutoff_s +1)) :* (time_dis_gap_i :<= lagdistcutoff_s) :* (distance_i :<= distcutoff_s) :* (distance_i :!= 0)
		w[.,1] = weight_dis
	}
	if (lagcutoff_s>0) {
	// __ Vector of weights (same ID)
		time_gap_i = abs(time1[t,1] :- time1)
		time_gap_cut_i = time_gap_i :<= lagcutoff_s
		weight = (1 :- time_gap_i :/ (lagcutoff_s +1)):* (time_gap_i :<= lagcutoff_s)
		w[s..e,1] = weight
	}
	else {
	w[s..e,1] = J(t1,1,0)
	w[pos,1] = 1
	}
	// __ VCV	
		wz = w :> 0
		nonzero = nonzero + sum(wz) 
		V1 =  P * (res :* res[pos,1] * w[.,1]) * (P[.,pos])'
		V = V + V1
		weigg[.,pos] = w[.,1]
		AVCVb_fs_1 = (I(Nend)#SzN) * ((vec(u) * u[pos,.]) :* (J(Nend,1, 1)# w[.,1])) * (I(Nend)#SzN[.,pos])' // -------------------------- KP 
		AVCVb_fs =  AVCVb_fs + AVCVb_fs_1																	 // -------------------------- KP
	}
	ind = ind + t1
}

*
st_matrix("weightsmat", weigg)
}
else {
for (i = 1; i <= NId; i++){
	rows_ni = id_vec:==Idunique[i,1] 
	
	// __ Get subsets of variables for ID i (without changing original matrix)
	time1 = select(time, rows_ni)
	t1 = length(time1)
	
	// __ Weights ID i vector
	w = J(N,1, 0)
	distance_i = J(N,1, 0)
	
	// __ Indicator variables (start, end)
	s = ind + 1
	e = ind + t1
	
	// __ Vector of weights (different ID)
		if (distcutoff_s>0) {
	
		// a) Computing Distance vector
			
			distance_i = distance[.,i]
		}
		
	for (t = 1; t <= t1; t++){
	
	// __ Indicator variables (position in the vector)
	pos  = ind + t		
	if (distcutoff_s>0) {	
	// a) Computing Weights
		time_dis_gap_i = abs(time1[t,1] :- time[.,1])
		weight_dis = (1 :- time_dis_gap_i :/ (lagdistcutoff_s +1)) :* (time_dis_gap_i :<= lagdistcutoff_s) :* (distance_i :<= distcutoff_s) :* (distance_i :!= 0)
		w[.,1] = weight_dis
	}
	if (lagcutoff_s>0) {
	// __ Vector of weights (same ID)
		time_gap_i = abs(time1[t,1] :- time1)
		time_gap_cut_i = time_gap_i :<= lagcutoff_s
		weight = (1 :- time_gap_i :/ (lagcutoff_s +1)):* (time_gap_i :<= lagcutoff_s)
		w[s..e,1] = weight
	}
	else {
	w[s..e,1] = J(t1,1,0)
	w[pos,1] = 1
	}
	// __ VCV	
		wz = w :> 0
		nonzero = nonzero + sum(wz) 
		V1 =  P * (res :* res[pos,1] * w[.,1]) * (P[.,pos])'
		V = V + V1	
		AVCVb_fs_1 = (I(Nend)#SzN) * ((vec(u) * u[pos,.]) :* (J(Nend,1, 1)# w[.,1])) * (I(Nend)#SzN[.,pos])' // -------------------------- KP 
		AVCVb_fs =  AVCVb_fs + AVCVb_fs_1																	 // -------------------------- KP
	}
	ind = ind + t1
}
*
}
*

_makesymmetric(V)

}

end


*********************************************************************************************
*********************************************************************************************
*     Program to compute corrected standard errors for IV Spatial and Network Databases	    *
*		   		  Copyright: F. Colella, R. Lalive, S.O. Sakalli, M. Thoenig			    *
*											  												*
*			Beta Version, please do not circulate - This Version: November 2017			    *
*********************************************************************************************
*********************************************************************************************

capt program drop acreg_netw_dist_bart
program acreg_netw_dist_bart, eclass 
	version 12
	syntax [,  storeweights ] 

	
mata {	
X=(X, J(rows(Y),1,1))
Z=(Z, J(rows(Y),1,1))
K = cols(X)

// 2SLS: parameters
W=invsym(Z'Z)
P=invsym(X'Z * W * Z'X)* X'Z * W *Z'
b=P * Y
res = Y-X*b
N=rows(res)

Nend = cols(KY) 	// -------------------------- KP
Niv = cols(KZ) 		// -------------------------- KP
Nie = Nend*Niv		// -------------------------- KP 

*------------------------------------------------------------------------
*        -------------------------- KP --------------------------	 	*
* Partial out X, p refers to partialling out
KX = (KX, J(rows(Y),1,1))

Zp1 = KX'*KZ
Zp2 = KX*invsym(KX'KX)*Zp1
Zp = KZ - Zp2

Yp1 = KX'*KY
Yp2 = KX*invsym(KX'KX)*Yp1
Yp = KY - Yp2

yp1 = KX'*Y
yp2 = KX*invsym(KX'KX)*yp1
yp = Y - yp2

* VCV first stage parameters
mata: u1 = (invsym(Zp'Zp)*Zp') * Yp

u1 = (invsym(Zp'Zp)*Zp') * Yp
u2 = Zp * u1
u = Yp - u2 

Sz = 1/sqrt(N)*Zp'
SzN = Sz

*------------------------------------------------------------------------
}
*
/*
* First stage
mata: PZ=Z*invsym(Z'Z)*Z'
mata: MZ=I(rows(PZ))-PZ


mata: X1=Xe[.,1]
mata: X2=Xe[.,2]

mata: gamma1=PZ * X1
*mata: rows(gamma1)
mata: resX1 = MZ * X1

mata: VCV1 = PZ * (resX1 * resX1' :* cluster) * PZ'
mata: VCV1 = VCV1[|1,1\16,16|]

mata: F1 = (gamma1[.,1..Niv]'*invsym(VCV1)*gamma1[.,1..Niv])/Niv
*/

mata {

// 2SLS: VCV
V = J(K,K, 0)
nonzero = 0
ind = 0
pos = 0

AVCVb_fs_1 = J(Nie,Nie, 0) 		// -------------------------- KP 
AVCVb_fs = J(Nie,Nie, 0)   		// -------------------------- KP 

// values 
a = .01745329
c = 6371
pi = 3.141593

Idunique = uniqrows(id_vec)
NId = rows(Idunique)
d_cols = cols(distance)

st_local("NId", strofreal(NId))
st_local("d_cols", strofreal(d_cols))

}

if `NId' != `d_cols' {
	disp as error "The number of columns in the distance matrix is different than the number of individuals"
exit 498
}

mata {

if ("`storeweights'" == "storeweights"){
weigg = J(N,N, 0)
for (i = 1; i <= NId; i++){

	rows_ni = id_vec:==Idunique[i,1] 
	
	// __ Get subsets of variables for ID i (without changing original matrix)
	time1 = select(time, rows_ni)
	t1 = length(time1)
	
	// __ Weights ID i vector
	w = J(N,1, 0)
	distance_i = J(N,1, 0)
	
	// __ Indicator variables (start, end)
	s = ind + 1
	e = ind + t1
	
	// __ Vector of weights (different ID)
		if (distcutoff_s>0) {
	
		// a) Computing Distance vector
			distance_i = distance[.,i]
			
		}
		
	for (t = 1; t <= t1; t++){
	
	// __ Indicator variables (position in the vector)
	pos  = ind + t		
	if (distcutoff_s>0) {
	// a) Computing Weights
		time_dis_gap_i = abs(time1[t,1] :- time[.,1])
		weight_dis = (1 :- time_dis_gap_i :/ (lagdistcutoff_s +1)):*(1:-abs(distance_i :/ distcutoff_s)) :* ( (time_dis_gap_i :<= lagdistcutoff_s) :* (distance_i :<= distcutoff_s)) :* (distance_i :!= 0)	
		w[.,1] = weight_dis	
	}
	if (lagcutoff_s>0) {	
	// __ Vector of weights (same ID)
		time_gap_i = abs(time1[t,1] :- time1)
		time_gap_cut_i = time_gap_i :<= lagcutoff_s
		weight = (1 :- time_gap_i :/ (lagcutoff_s +1)):* (time_gap_i :<= lagcutoff_s)
		w[s..e,1] = weight
	}
	else {
	w[s..e,1] = J(t1,1,0)
	w[pos,1] = 1
	}
	// __ VCV	
		wz = w :> 0
		nonzero = nonzero + sum(wz)
		V1 =  P * (res :* res[pos,1] * w[.,1]) * (P[.,pos])'
		V = V + V1
		weigg[.,pos] = w[.,1]
		AVCVb_fs_1 = (I(Nend)#SzN) * ((vec(u) * u[pos,.]) :* (J(Nend,1, 1)# w[.,1])) * (I(Nend)#SzN[.,pos])' // -------------------------- KP 
		AVCVb_fs =  AVCVb_fs + AVCVb_fs_1																	 // -------------------------- KP
	}	
	
	ind = ind + t1
}

*
st_matrix("weightsmat", weigg)
}
else {
for (i = 1; i <= NId; i++){

	rows_ni = id_vec:==Idunique[i,1] 
	
	// __ Get subsets of variables for ID i (without changing original matrix)
	time1 = select(time, rows_ni)
	t1 = length(time1)
	
	// __ Weights ID i vector
	w = J(N,1, 0)
	distance_i = J(N,1, 0)
	
	// __ Indicator variables (start, end)
	s = ind + 1
	e = ind + t1
	
	// __ Vector of weights (different ID)
		if (distcutoff_s>0) {
	
		// a) Computing Distance vector
			distance_i = distance[.,i]
			
		}
		
	for (t = 1; t <= t1; t++){
	
	// __ Indicator variables (position in the vector)
	pos  = ind + t		
	if (distcutoff_s>0) {
	// a) Computing Weights
		time_dis_gap_i = abs(time1[t,1] :- time[.,1])
		weight_dis = (1 :- time_dis_gap_i :/ (lagdistcutoff_s +1)):*(1:-abs(distance_i :/ distcutoff_s)) :* ( (time_dis_gap_i :<= lagdistcutoff_s) :* (distance_i :<= distcutoff_s)) :* (distance_i :!= 0)	
		w[.,1] = weight_dis	
	}
	if (lagcutoff_s>0) {	
	// __ Vector of weights (same ID)
		time_gap_i = abs(time1[t,1] :- time1)
		time_gap_cut_i = time_gap_i :<= lagcutoff_s
		weight = (1 :- time_gap_i :/ (lagcutoff_s +1)):* (time_gap_i :<= lagcutoff_s)
		w[s..e,1] = weight
	}
	else {
	w[s..e,1] = J(t1,1,0)
	w[pos,1] = 1
	}
	// __ VCV	
		wz = w :> 0
		nonzero = nonzero + sum(wz)
		V1 =  P * (res :* res[pos,1] * w[.,1]) * (P[.,pos])'
		V = V + V1
		AVCVb_fs_1 = (I(Nend)#SzN) * ((vec(u) * u[pos,.]) :* (J(Nend,1, 1)# w[.,1])) * (I(Nend)#SzN[.,pos])' // -------------------------- KP 
		AVCVb_fs =  AVCVb_fs + AVCVb_fs_1																	 // -------------------------- KP
	}	
	
	ind = ind + t1
}

*
}
*
//*mata: V[1..5,1..5]

_makesymmetric(V)

}

end


*! ranktest 1.4.01  18aug2015
*! author mes, based on code by fk
*! see end of file for version comments
capt program drop nwacRanktest

if c(version) < 12 {
* ranktest uses livreg2 Mata library.
* Ensure Mata library is indexed if new install.
* Not needed for Stata 12+ since ssc.ado does this when installing.
	capture mata: mata drop m_calckw()
	capture mata: mata drop m_omega()
	capture mata: mata drop ms_vcvorthog()
	capture mata: mata drop s_vkernel()
	mata: mata mlib index
}


	capture mata: mata drop s_rkstat()
	capture mata: mata drop cholqrsolve()

program define nwacRanktest, rclass sortpreserve

	local lversion 01.4.01

	if _caller() < 11 {
		ranktest9 `0'
		return add						//  otherwise all the ranktest9 results are zapped
		return local ranktestcmd		ranktest9
		return local cmd				ranktest
		return local version			`lversion'
		exit
	}
	version 11.2

	if substr("`1'",1,1)== "," {
		if "`2'"=="version" {
			di in ye "`lversion'"
			return local version `lversion'
			exit
		}
		else {
di as err "invalid syntax"
			exit 198
		}
	}

* If varlist 1 or varlist 2 have a single element, parentheses optional

	if substr("`1'",1,1)=="(" {
		GetVarlist `0'
		local y `s(varlist)'
		local 0 `"`s(rest)'"'
		sret clear
	}
	else {
		local y `1'
		mac shift 1
		local 0 `"`*'"'
	}

	if substr("`1'",1,1)=="(" {
		GetVarlist `0'
		local z `s(varlist)'
		local 0 `"`s(rest)'"'
		sret clear
	}
	else {
		local z `1'
		mac shift 1
* Need to reinsert comma before options (if any) for -syntax- command to work
		local 0 `", `*'"'
	}

// Note that y or z could be a varlist, e.g., "y1-y3", so they need to be unab-ed.
//	tsunab y : `y'
		prog_fv_unab `y' 
		local y `r(ts_varlist)'
	local K : word count `y'
//	tsunab z : `z'
		prog_fv_unab `z' 
		local z `r(ts_varlist)'
	local L : word count `z'
*XXX*
* Option version ignored here if varlists were provided
	syntax [if] [in] [aw fw pw iw/]				///
		[,										///
		vb(string)	          					///
		partial(varlist ts)						///
		fwl(varlist ts)							///
		NOConstant								///
		wald									///
		ALLrank									///
		NULLrank								///
		FULLrank								///
		ROBust									///
		cluster(varlist)						///
		BW(string)								///
		kernel(string)							///
		Tvar(varname)							///
		Ivar(varname)							///
		sw										///
		psd0									///
		psda									///
		version									///
		dofminus(integer 0)						///
		]

	local partial		"`partial' `fwl'"
	local partial		: list retokenize partial

	local cons		= ("`noconstant'"=="")
*XXX*
//	mata: st_view(bVCVb=., ., "`vb'")
//	mata: st_view(VCVb=., ., `vb')
mat VCVb=`vb'
	
	if "`wald'"~="" {
		local LMWald "Wald"
	}
	else {
		local LMWald "LM"
	}
	
	local optct : word count `allrank' `nullrank' `fullrank'
	if `optct' > 1 {
di as err "Incompatible options: `allrank' `nullrank' `fullrank'"
		error 198
	}
	else if `optct' == 0 {
* Default
		local allrank "allrank"
	}

	local optct : word count `psd0' `psda'
	if `optct' > 1 {
di as err "Incompatible options: `psd0' `psda'"
		error 198
	}
	local psd	"`psd0' `psda'"
	local psd	: list retokenize psd

* Note that by tsrevar-ing here, subsequent disruption to the sort doesn't matter
* for TS operators.
	tsrevar `y'
	local vl1 `r(varlist)'
	tsrevar `z'
	local vl2 `r(varlist)'
	tsrevar `partial'
	local partial `r(varlist)'

	foreach vn of varlist `vl1' {
		tempvar tv
		qui gen double `tv' = .
		local tempvl1 "`tempvl1' `tv'"
	}
	foreach vn of varlist `vl2' {
		tempvar tv
		qui gen double `tv' = .
		local tempvl2 "`tempvl2' `tv'"
	}

	marksample touse
	markout `touse' `vl1' `vl2' `partial' `cluster', strok

* Stock-Watson and cluster imply robust.
	if "`sw'`cluster'" ~= "" {
		local robust "robust"
	}

	tempvar wvar
	if "`weight'" == "fweight" | "`weight'"=="aweight" {
		local wtexp `"[`weight'=`exp']"'
		gen double `wvar'=`exp'
	}
	if "`fsqrt(wf)*(wvar^0.5):*'" == "fweight" & "`kernel'" !="" {
		di in red "fweights not allowed (data are -tsset-)"
		exit 101
	}
	if "`weight'" == "fweight" & "`sw'" != "" {
		di in red "fweights currently not supported with -sw- option"
		exit 101
	}
	if "`weight'" == "iweight" {
		if "`robust'`cluster'`bw'" !="" {
			di in red "iweights not allowed with robust, cluster, AC or HAC"
			exit 101
		}
		else {
			local wtexp `"[`weight'=`exp']"'
			gen double `wvar'=`exp'
		}
	}
	if "`weight'" == "pweight" {
		local wtexp `"[aweight=`exp']"'
		gen double `wvar'=`exp'
		local robust "robust"
	}
	if "`weight'" == "" {
* If no weights, define neutral weight variable
		qui gen byte `wvar'=1
	}


* Every time a weight is used, must multiply by scalar wf ("weight factor")
* wf=1 for no weights, fw and iw, wf = scalar that normalizes sum to be N if aw or pw
		sum `wvar' if `touse' `wtexp', meanonly
* Weight statement
		if "`weight'" ~= "" {
di in gr "(sum of wgt is " %14.4e `r(sum_w)' ")"
		}
		if "`weight'"=="" | "`weight'"=="fweight" | "`weight'"=="iweight" {
* If weight is "", weight var must be column of ones and N is number of rows.
* With fw and iw, effective number of observations is sum of weight variable.
			local wf=1
			local N=r(sum_w)
		}
		else if "`weight'"=="aweight" | "`weight'"=="pweight" {
* With aw and pw, N is number of obs, unadjusted.
			local wf=r(N)/r(sum_w)
			local N=r(N)
		}
		else {
* Should never reach here
di as err "ranktest error - misspecified weights"
			exit 198
		}

* HAC estimation.
* If bw is omitted, default `bw' is empty string.
* If bw or kernel supplied, check/set `kernel'.
* Macro `kernel' is also used for indicating HAC in use.
	if "`bw'" == "" & "`kernel'" == "" {
		local bw=0
	}
	else {
* Need tvar for markout with time-series stuff
* Data must be tsset for time-series operators in code to work
* User-supplied tvar checked if consistent with tsset
		capture tsset
		if "`r(timevar)'" == "" {
di as err "must tsset data and specify timevar"
			exit 5
		}
		if "`tvar'" == "" {
			local tvar "`r(timevar)'"
		}
		else if "`tvar'"!="`r(timevar)'" {
di as err "invalid tvar() option - data already -tsset-"
			exit 5
		}
* If no panel data, ivar will still be empty
		if "`ivar'" == "" {
			local ivar "`r(panelvar)'"
		}
		else if "`ivar'"!="`r(panelvar)'" {
di as err "invalid ivar() option - data already -tsset-"
			exit 5
		}
		local tdelta `r(tdelta)'
		tsreport if `touse', panel
		if `r(N_gaps)' != 0 {
di in gr "Warning: time variable " in ye "`tvar'" in gr " has " /*
	*/ in ye "`r(N_gaps)'" in gr " gap(s) in relevant range"
		}

* Check it's a valid kernel and replace with unabbreviated kernel name; check bw.
* Automatic kernel selection allowed by ivreg2 but not ranktest so must trap.
* s_vkernel is in livreg2 mlib.
		if "`bw'"=="auto" {
di as err "invalid bandwidth in option bw() - must be real > 0"
			exit 198
		}
		mata: s_vkernel("`kernel'", "`bw'", "`ivar'")
		local kernel `r(kernel)'
		local bw = `r(bw)'
	}

* tdelta missing if version 9 or if not tsset			
	if "`tdelta'"=="" {
		local tdelta=1
	}

	if "`sw'"~="" {
		capture xtset
		if "`ivar'" == "" {
			local ivar "`r(panelvar)'"
		}
		else if "`ivar'"!="`r(panelvar)'" {
di as err "invalid ivar() option - data already tsset or xtset"
			exit 5
		}
* Exit with error if ivar is neither supplied nor tsset nor xtset
		if "`ivar'"=="" {
di as err "Must -xtset- or -tsset- data or specify -ivar- with -sw- option"
			exit 198
		}
		qui describe, short varlist
		local sortlist "`r(sortlist)'"
		tokenize `sortlist'
		if "`ivar'"~="`1'" {
di as err "Error - dataset must be sorted on panel var with -sw- option"
			exit 198
		}
	}

* Create variable used for getting lags etc. in Mata
	tempvar tindex
	qui gen `tindex'=1 if `touse'
	qui replace `tindex'=sum(`tindex') if `touse'

********** CLUSTER SETUP **********************************************

* Mata code requires data are sorted on (1) the first var cluster if there
* is only one cluster var; (2) on the 3rd and then 1st if two-way clustering,
* unless (3) two-way clustering is combined with kernel option, in which case
* the data are tsset and sorted on panel id (first cluster variable) and time
* id (second cluster variable).
* Second cluster var is optional and requires an identifier numbered 1..N_clust2,
* unless combined with kernel option, in which case it's the time variable.
* Third cluster var is the intersection of 1 and 2, unless combined with kernel
* opt, in which case it's unnecessary.
* Sorting on "cluster3 cluster1" means that in Mata, panelsetup works for
* both, since cluster1 nests cluster3.
* Note that it is possible to cluster on time but not panel, in which case
* cluster1 is time, cluster2 is empty and data are sorted on panel-time.
* Note also that if data are sorted here but happen to be tsset, will need
* to be re-tsset after estimation code concludes.


// No cluster options or only 1-way clustering
// but for Mata and other purposes, set N_clust vars =0
	local N_clust=0
	local N_clust1=0
	local N_clust2=0
	if "`cluster'"!="" {
		local clopt "cluster(`cluster')"
		tokenize `cluster'
		local cluster1 "`1'"
		local cluster2 "`2'"
		if "`kernel'"~="" {
* kernel requires either that cluster1 is time var and cluster2 is empty
* or that cluster1 is panel var and cluster2 is time var.
* Either way, data must be tsset and sorted for panel data.
			if "`cluster2'"~="" {
* Allow backwards order
				if "`cluster1'"=="`tvar'" & "`cluster2'"=="`ivar'" {
					local cluster1 "`2'"
					local cluster2 "`1'"
				}
				if "`cluster1'"~="`ivar'" | "`cluster2'"~="`tvar'" {
di as err "Error: cluster kernel-robust requires clustering on tsset panel & time vars."
di as err "       tsset panel var=`ivar'; tsset time var=`tvar'; cluster vars=`cluster1',`cluster2'"
					exit 198
				}
			}
			else {
				if "`cluster1'"~="`tvar'" {
di as err "Error: cluster kernel-robust requires clustering on tsset time variable."
di as err "       tsset time var=`tvar'; cluster var=`cluster1'"
					exit 198
				}
			}
		}
* Simple way to get quick count of 1st cluster variable without disrupting sort
* clusterid1 is numbered 1.._Nclust1.
		tempvar clusterid1
		qui egen `clusterid1'=group(`cluster1') if `touse'
		sum `clusterid1' if `touse', meanonly
		if "`cluster2'"=="" {
			local N_clust=r(max)
			local N_clust1=`N_clust'
			if "`kernel'"=="" {
* Single level of clustering and no kernel-robust, so sort on single cluster var.
* kernel-robust already sorted via tsset.
				sort `cluster1'
			}
		}
		else {
			local N_clust1=r(max)
			if "`kernel'"=="" {
				tempvar clusterid2 clusterid3
* New cluster id vars are numbered 1..N_clust2 and 1..N_clust3
				qui egen `clusterid2'=group(`cluster2') if `touse'
				qui egen `clusterid3'=group(`cluster1' `cluster2') if `touse'
* Two levels of clustering and no kernel-robust, so sort on cluster3/nested in/cluster1
* kernel-robust already sorted via tsset.
				sort `clusterid3' `cluster1'
				sum `clusterid2' if `touse', meanonly
				local N_clust2=r(max)
			}
			else {
* Need to create this only to count the number of clusters
				tempvar clusterid2
				qui egen `clusterid2'=group(`cluster2') if `touse'
				sum `clusterid2' if `touse', meanonly
				local N_clust2=r(max)
* Now replace with original variable
				local clusterid2 `cluster2'
			}

			local N_clust=min(`N_clust1',`N_clust2')

		}		// end 2-way cluster block
	}		// end cluster block

************************************************************************************************

* Note that bw is passed as a value, not as a string
	mata: s_rkstat(						///
					"`vl1'",			///
					"`vl2'",			///
					"`partial'",		///
					"`wvar'",			///
					"`weight'",			///
					`wf',				///
					`N',				///
					`cons',				///
					"`touse'",			///
					"`LMWald'",			///
					"`allrank'",		///
					"`nullrank'",		///
					"`fullrank'",		///
					"`robust'",			///
					"`clusterid1'",		///
					"`clusterid2'",		///
					"`clusterid3'",		///
					`bw',				///
					"`tvar'",			///
					"`ivar'",			///
					"`tindex'",			///
					`tdelta',			///
					`dofminus',			///
					"`kernel'",			///
					"`sw'",				///
					"`psd'",			///
					"`tempvl1'",		///
					"`tempvl2'",		///
					"`vb'"		///
					)

	tempname rkmatrix chi2 df df_r p rank ccorr eval
	mat `rkmatrix'=r(rkmatrix)
	mat `ccorr'=r(ccorr)
	mat `eval'=r(eval)
	mat colnames `rkmatrix' = "rk" "df" "p" "rank" "eval" "ccorr"
	
di
di "Kleibergen-Paap rk `LMWald' test of rank of matrix"
	if "`robust'"~="" & "`kernel'"~= "" & "`cluster'"=="" {
di "  Test statistic robust to heteroskedasticity and autocorrelation"
di "  Kernel: `kernel'   Bandwidth: `bw'"
	}
	else if "`kernel'"~="" & "`cluster'"=="" {
di "  Test statistic robust to autocorrelation"
di "  Kernel: `kernel'   Bandwidth: `bw'"
	}
	else if "`cluster'"~="" {
di "  Test statistic robust to heteroskedasticity and clustering on `cluster'"
		if "`kernel'"~="" {
di "  and kernel-robust to common correlated disturbances"
di "  Kernel: `kernel'   Bandwidth: `bw'"
		}
	}
	else if "`robust'"~="" {
di "  Test statistic robust to heteroskedasticity"
	}
	else if "`LMWald'"=="LM" {
di "  Test assumes homoskedasticity (Anderson canonical correlations test)"
	}
	else {
di "  Test assumes homoskedasticity (Cragg-Donald test)"
	}
		
	local numtests = rowsof(`rkmatrix')
	forvalues i=1(1)`numtests' {
di "Test of rank=" %3.0f `rkmatrix'[`i',4] "  rk=" %8.2f `rkmatrix'[`i',1] /*
	*/	"  Chi-sq(" %3.0f `rkmatrix'[`i',2] ") pvalue=" %8.6f `rkmatrix'[`i',3]
	}
	scalar `chi2' = `rkmatrix'[`numtests',1]
	scalar `p' = `rkmatrix'[`numtests',3]
	scalar `df' = `rkmatrix'[`numtests',2]
	scalar `rank' = `rkmatrix'[`numtests',4]
	local N `r(N)'
	return scalar df = `df'
	return scalar chi2 = `chi2'
	return scalar p = `p'
	return scalar rank = `rank'
	if "`cluster'"~="" {
		return scalar N_clust = `N_clust'
	}
	if "`cluster2'"~="" {
		return scalar N_clust1 = `N_clust1'
		return scalar N_clust2 = `N_clust2'
	}
	return scalar N = `N'
	return matrix rkmatrix `rkmatrix'
	return matrix ccorr `ccorr'
	return matrix eval `eval'
//	return matrix bCVCb `bVCVb'
	
	tempname S V Omega Snew
	if `K' > 1 {
		foreach en of local y {
* Remove "." from equation name
			local en1 : subinstr local en "." "_", all
			foreach vn of local z {
				local cn "`cn' `en1':`vn'"
			}
		}
	}
	else {
		foreach vn of local z {
		local cn "`cn' `vn'"
		}
	}

	mat `V'=r(V)
	matrix colnames `V' = `cn'
	matrix rownames `V' = `cn'
	return matrix V `V' 
	mat `S'=r(S)
	mat `Snew'=r(Snew)
	matrix colnames `S' = `cn'
	matrix rownames `S' = `cn'
//	matrix colnames `Snew' = `cn'
//	matrix rownames `Snew' = `cn'
	return matrix S `S'
	return matrix Snew `Snew'

	return local cmd		"ranktest"
	return local version	`lversion'
end

* Adopted from -canon-
capt program drop GetVarlist
program define GetVarlist, sclass 
	version 11.2
	sret clear
	gettoken open 0 : 0, parse("(") 
	if `"`open'"' != "(" {
		error 198
	}
	gettoken next 0 : 0, parse(")")
	while `"`next'"' != ")" {
		if `"`next'"'=="" { 
			error 198
		}
		local list `list'`next'
		gettoken next 0 : 0, parse(")")
	}
	sret local rest `"`0'"'
	tokenize `list'
	local 0 `*'
	sret local varlist "`0'"
end

********************* EXIT IF STATA VERSION < 11 ********************************

* When do file is loaded, exit here if Stata version calling program is < 11.
* Prevents loading of rest of program file (would cause e.g. Stata 10 to crash at Mata).

if c(stata_version) < 11 {
	exit
}

******************** END EXIT IF STATA VERSION < 9 *****************************

*******************************************************************************
*************************** BEGIN MATA CODE ***********************************
*******************************************************************************

version 11.2
mata:

// ********* MATA CODE SHARED BY ivreg2 AND ranktest       *************** //
// ********* 1. struct ms_vcvorthog                        *************** //
// ********* 2. m_omega                                    *************** //
// ********* 3. m_calckw                                   *************** //
// ********* 4. s_vkernel                                  *************** //
// *********************************************************************** //

// For reference:
// struct ms_vcvorthog {
// 	string scalar	ename, Znames, touse, weight, wvarname
// 	string scalar	robust, clustvarname, clustvarname2, clustvarname3, kernel
// 	string scalar	sw, psd, ivarname, tvarname, tindexname
// 	real scalar		wf, N, bw, tdelta, dofminus
//  real scalar		center
// 	real matrix		ZZ
// 	pointer matrix	e
// 	pointer matrix	Z
// 	pointer matrix	wvar
// }

void s_rkstat(	string scalar vl1,
				string scalar vl2,
				string scalar partial,
				string scalar wvarname,
				string scalar weight,
				scalar wf,
				scalar N,
				scalar cons,
				string scalar touse,
				string scalar LMWald,
				string scalar allrank,
				string scalar nullrank,
				string scalar fullrank,
				string scalar robust,
				string scalar clustvarname,
				string scalar clustvarname2,
				string scalar clustvarname3,
				bw,
				string scalar tvarname,
				string scalar ivarname,
				string scalar tindexname,
				tdelta,
				dofminus,
				string scalar kernel,
				string scalar sw,
				string scalar psd,
				string scalar tempvl1,
				string scalar tempvl2,
				string scalar vb)
{

// iid flag used below
	iid = ((kernel=="") & (robust=="") & (clustvarname==""))

// tempx, tempy and tempz are the Stata names of temporary variables that will be changed by s_rkstat
	tempy=tokens(tempvl1)
	tempz=tokens(tempvl2)
	tempx=tokens(partial)

	st_view(y=.,.,tokens(vl1),touse)
	st_view(z=.,.,tokens(vl2),touse)
	st_view(yhat=.,.,tempy,touse)
	st_view(zhat=.,.,tempz,touse)
	if (partial~="") {
		st_view(x=.,.,tempx,touse)
	}
	st_view(mtouse=.,.,tokens(touse),touse)
	st_view(wvar=.,.,tokens(wvarname),touse)
	noweight=(st_vartype(wvarname)=="byte")

	K=cols(y)							//  count of vars in first varlist
	L=cols(z)							//  count of vars in second varlist
	P=cols(x)							//  count of vars to be partialled out (excluding constant)

// Note that we now use wf*wvar instead of wvar
// because wvar is raw weighting variable and
// wf*wvar normalizes so that sum(wf*wvar)=N.

// Partial out the X variables.
// Note that this includes demeaning if there is a constant,
//   i.e., variables are centered.
	if (cons & P>0) {					//  Vars to partial out including constant
		ymeans = mean(y,wf*wvar)
		zmeans = mean(z,wf*wvar)
		xmeans = mean(x,wf*wvar)
		xy = quadcrossdev(x, xmeans, wf*wvar, y, ymeans)
		xz = quadcrossdev(x, xmeans, wf*wvar, z, zmeans)
		xx = quadcrossdev(x, xmeans, wf*wvar, x, xmeans)
	}
	else if (!cons & P>0) {				//  Vars to partial out NOT including constant
		xy = quadcross(x, wf*wvar, y)
		xz = quadcross(x, wf*wvar, z)
		xx = quadcross(x, wf*wvar, x)
	}
	else {								//  Only constant to partial out = demean
		ymeans = mean(y,wf*wvar)
		zmeans = mean(z,wf*wvar)
	}
//	Partial-out coeffs. Default Cholesky; use QR if not full rank and collinearities present.
//	Not necessary if no vars other than constant
	if (P>0) {
		by = cholqrsolve(xx, xy)
		bz = cholqrsolve(xx, xz)
	}
//	Replace with residuals
	if (cons & P>0) {					//  Vars to partial out including constant
		yhat[.,.] = (y :- ymeans) - (x :- xmeans)*by
		zhat[.,.] = (z :- zmeans) - (x :- xmeans)*bz
	}
	else if (!cons & P>0) {				//  Vars to partial out NOT including constant
		yhat[.,.] = y - x*by
		zhat[.,.] = z - x*bz
	}
	else if (cons) {					//  Only constant to partial out = demean
		yhat[.,.] = (y :- ymeans)
		zhat[.,.] = (z :- zmeans)
	}
	else {								//  no transformations required
		yhat[.,.] = y
		zhat[.,.] = z
	}

	zhzh = quadcross(zhat, wf*wvar, zhat)
	zhyh = quadcross(zhat, wf*wvar, yhat)
	yhyh = quadcross(yhat, wf*wvar, yhat)

//	pihat = invsym(zhzh)*zhyh
	pihat = cholqrsolve(zhzh, zhyh)

// rzhat is F in paper (p. 103)
// iryhat is G in paper (p. 103)
	ryhat=cholesky(yhyh)
	rzhat=cholesky(zhzh)
	iryhat=luinv(ryhat')
	irzhat=luinv(rzhat')
	that=rzhat'*pihat*iryhat

// cc is canonical correlations.  Squared cc is eigenvalues.
	fullsvd(that, ut, cc, vt)
	vt=vt'
	vecth=vec(that)
	ev = cc:^2
// S matrix in paper (p. 100).  Not used in code below.
//	smat=fullsdiag(cc, rows(that)-cols(that))

	if (abs(1-cc[1,1])<1e-10) {
printf("\n{text:Warning: collinearities detected between (varlist1) and (varlist2)}\n")
	}
	if ((missing(ryhat)>0) | (missing(iryhat)>0) | (missing(rzhat)>0) | (missing(irzhat)>0)) {
printf("\n{error:Error: non-positive-definite matrix. May be caused by collinearities.}\n")
		exit(error(3351))
	}

// If Wald, yhat is residuals
	if (LMWald=="Wald") {
		yhat[.,.]=yhat-zhat*pihat
		yhyh = quadcross(yhat, wvar, yhat)
	}

// Covariance matrices
// vhat is W in paper (eqn below equation 17, p. 103)
// shat is V in paper (eqn below eqn 15, p. 103)

//shatnew=VCVb
shatnew=st_matrix(vb)
// shatnew=cholesky(shatnew)
// ************************************************************************************* //
// shat calculated using struct and programs m_omega, m_calckw shared with ivreg2        //

struct ms_vcvorthog scalar vcvo
	vcvo.ename			= tempy		// ivreg2 has = ename //
	vcvo.Znames			= tempz		// ivreg2 has = Znames //
	vcvo.touse			= touse
	vcvo.weight			= weight
	vcvo.wvarname		= wvarname
	vcvo.robust			= robust
	vcvo.clustvarname	= clustvarname
	vcvo.clustvarname2	= clustvarname2
	vcvo.clustvarname3	= clustvarname3
	vcvo.kernel			= kernel
	vcvo.sw				= sw
	vcvo.psd			= psd
	vcvo.ivarname		= ivarname
	vcvo.tvarname		= tvarname
	vcvo.tindexname		= tindexname
	vcvo.wf				= wf
	vcvo.N				= N
	vcvo.bw				= bw
	vcvo.tdelta			= tdelta
	vcvo.dofminus		= dofminus
	vcvo.ZZ				= zhzh		// ivreg2 has = st_matrix(ZZmatrix) //
	
	vcvo.e		= &yhat				// ivreg2 has = &e	//
	vcvo.Z		= &zhat				// ivreg2 has = &Z //
	vcvo.wvar	= &wvar

	shat=m_omega(vcvo)

		
// ***************************************************************************************


// prepare to start collecting test stats
	if (allrank~="") {
		firstrank=1
		lastrank=min((K,L))
	}
	else if (nullrank~="") {
		firstrank=1
		lastrank=1
	}
	else if (fullrank~="") {
		firstrank=min((K,L))
		lastrank=min((K,L))
	}
	else {
// should never reach this point
printf("ranktest error\n")
		exit
	}

// where results will go
	rkmatrix=J(lastrank-firstrank+1,6,.)

// ***************************************************************************************
// Calculate vector of canonical correlations test statistics.
// All we need if iid case.
	rkvec = ev									//  Initialize vector with individual eigenvalues.
	if (LMWald~="LM") {							//  LM is sum of min evals, Wald is sum of eval/(1-eval)
		rkvec = rkvec :/ (1 :- rkvec)
	}
	for (i=(rows(rkvec)-1); i>=1; i--) {		//  Now loop through and sum the eigenvalues.
		rkvec[i,1] = rkvec[i+1,1] + rkvec[i,1]
	}
	rkvec = N*rkvec								//  Multiply by N to get the test statistics.

// ***************************************************************************************

// Finally, calcluate vhat	
	if ((LMWald=="LM") & (iid)) {
// Homoskedastic, iid LM case means vcv is identity matrix
// Generates canonical correlation stats.  Default.
		vhat=I(L*K,L*K)/N
	}
	else {
		vhat=(iryhat'#irzhat')*shatnew*(iryhat'#irzhat')' * N
		_makesymmetric(vhat)
// Homoskedastic iid Wald case means vcv has block-diag identity matrix structure.
// Enforce this by setting ~0 entries to 0.  If iid, vhat not used in calcs, for reporting only.
		if ((LMWald=="Wald") & (iid)) {
			vhat = vhat :* (J(K,K,1)#I(L))
		}
	}

// ***************************************************************************************
// Loop through ranks and collect test stats, dfs, p-values, ranks, evs and ev^2 (=ccs)

	for (i=firstrank; i<=lastrank; i++) {
		if (iid) {							//  iid case = canonical correlations test
			rk = rkvec[i,1]
			}
		else {								//  non-iid case
			if (i>1) {
				u12=ut[(1::i-1),(i..L)]
				v12=vt[(1::i-1),(i..K)]
			}
			u22=ut[(i::L),(i..L)]
			v22=vt[(i::K),(i..K)]
			
			symeigensystem(u22*u22', evec, eval)
			u22v=evec
			u22d=diag(eval)
			u22h=u22v*(u22d:^0.5)*u22v'
	
			symeigensystem(v22*v22', evec, eval)
			v22v=evec
			v22d=diag(eval)
			v22h=v22v*(v22d:^0.5)*v22v'
	
			if (i>1) {
				aq=(u12 \ u22)*luinv(u22)*u22h
				bq=v22h*luinv(v22')*(v12 \ v22)'
			}
			else {
				aq=u22*luinv(u22)*u22h
				bq=v22h*luinv(v22')*v22'
			}
	
// lab is lambda_q in paper (eqn below equation 21, p. 104)
// vlab is omega_q in paper (eqn 19 in paper, p. 104)
			lab=(bq#aq')*vecth
			vlab=(bq#aq')*vhat*(bq#aq')'
	
// Symmetrize if numerical inaccuracy means it isn't
			_makesymmetric(vlab)
			vlabinv=invsym(vlab)
// rk stat Assumption 2: vlab (omega_q in paper) is nonsingular.  Detected by a zero on the diagonal,
// since when returning a generalized inverse, Stata/Mata choose the generalized inverse that
// sets entire column(s)/row(s) to zeros.
			if (diag0cnt(vlabinv)>0) {
			rk=.
								// rk=lab'*vlabinv*lab
printf("\n{text:Warning: covariance matrix omega_%f}", i-1)
printf("{text: not full rank; test of rank %f}", i-1)
printf("{text: unavailable}\n")
			}
// Note not multiplying by N - already incorporated in vhat.
			else {
				rk=lab'*vlabinv*lab
			}
		}												//  end non-iid case
// at this point rk has value of test stat
// fill out rest of row of rkmatrix
// save df, rank, etc. even if test stat not available.
		df=(L-i+1)*(K-i+1)
		pvalue=chi2tail(df, rk)
		rkmatrix[i-firstrank+1,1]=rk
		rkmatrix[i-firstrank+1,2]=df
		rkmatrix[i-firstrank+1,3]=pvalue
		rkmatrix[i-firstrank+1,4]=i-1
		rkmatrix[i-firstrank+1,5]=ev[i-firstrank+1,1]
		rkmatrix[i-firstrank+1,6]=cc[i-firstrank+1,1]
// end of test loop
	}

// ***************************************************************************************
// Finish up and return results

	st_matrix("r(rkmatrix)", rkmatrix)
	st_matrix("r(ccorr)", cc')
	st_matrix("r(eval)",ev')
// Save V matrix as in paper, without factor of 1/N
	vhat=N*vhat*wf
	st_matrix("r(V)", vhat)
// Save S matrix as in ivreg2, with factor of 1/N
	st_matrix("r(S)", shat)
	st_matrix("r(Snew)", shatnew)
	st_numscalar("r(N)", N)
	if (clustvarname~="") {
		st_numscalar("r(N_clust)", N_clust)
	}
	if (clustvarname2~="") {
		st_numscalar("r(N_clust2)", N_clust2)
	}
// end of program
}

// Mata utility for sequential use of solvers
// Default is cholesky;
// if that fails, use QR;
// if overridden, use QR.

function cholqrsolve (	numeric matrix A,
						numeric matrix B,
						| real scalar useqr)
{
	if (args()==2) useqr = 0
	
	real matrix C

	if (!useqr) {
		C = cholsolve(A, B)
		if (C[1,1]==.) {
			C = qrsolve(A, B)
		}
	}
	else {
		C = qrsolve(A, B)
	}

	return(C)

}

end

***************************************************************************
capt program drop prog_fv_unab
program prog_fv_unab, rclass
	syntax varlist(numeric fv)
	local temp_vt  : word count `varlist'
	forval j=1/`temp_vt' {
		local this_var `: word `j' of `varlist''
		if substr("`this_var'", 1, 2) == "i." {
			fvrevar `this_var', list
			local this_var = "`r(varlist)'"
			return local this_var `"`this_var'"'
			tsunab this_var : `this_var'
			local this_var = "i.`this_var'"
		}
		else {
		tsunab this_var : `this_var'
		}
		local ts_varlist `ts_varlist' `this_var' 
	}
	return local ts_varlist `"`ts_varlist'"'
end 

* Version notes
* 1.0.00  First distributed version
* 1.0.01  With iweights, rkstat truncates N to mimic official Stata treatment of noninteger iweights
*         Added warning if shat/vhat/vlab not of full rank.
* 1.0.02  Added NULLrank option
*         Added eq names to saved V and S matrices
* 1.0.03  Added error catching for collinearities between varlists
*         Not saving S matrix; V matrix now as in paper (without 1/N factor)
*         Statistic, p-value etc set to missing if vcv not of full rank (Assumpt 2 in paper fails)
* 1.0.04  Fixed touse bug - was treating missings as touse-able
*         Change some cross-products in robust loops to quadcross
* 1.0.05  Fixed bug with col/row names and ts operators.  Added eval to saved matrices.
* 1.1.00  First ssc-ideas version.  Added version 9.2 prior to Mata compiled section.
* 1.1.01  Allow non-integer bandwidth
* 1.1.02  Changed calc of yhat, zhat and pihat to avoid needlessly large intermediate matrices
*         and to use more accurate qrsolve instead of inverted X'X.
* 1.1.03  Fixed touse bug that didn't catch missing cluster variable
*         Fixed cluster bug - data needed to be sorted by cluster for Mata panel functions to work properly
* 1.2.00  Changed reporting so that gaps between panels are not reported as such.
*         Added support for tdelta in tsset data.
*         Changed tvar and ivar setup so that data must be tsset or xtset.
*         Removed unnecessary loops through panel data with spectral kernels
*         shat vcv now also saved.
*         Added support for Thompson/Cameron-Gelbach-Miller 2-level cluster-robust vcvv
*         Added support for Stock-Watson vcv - but requires data to have FEs partialled out, & doesn't support fweights
*         Removed mimicking of Stata mistake of truncated N with iweights to nearest integer
*         Fixed small bug with quadratic kernel (wasn't using negative weights)
*         Optimised code dealing with time-series data
* 1.2.01  Fixed bug that always used Stock-Watson spectral decomp to create invertible shat
*         instead of only when (undocumented) spsd option is called.
* 1.2.02  Fixed bug that did not allow string cluster variables
* 1.2.03  Fixed bug in code for cluster+kernel robust (typo in imported code from ivreg2=>crash)
* 1.2.04  Replaced code for S with ivreg2 code modified to support e matrix (cols > 1)
*         Code block (m_omega, m_calckw, struct definition) now shared by ranktest and ivreg2.
*         Renamed spsd option to psd following ivreg2 3.0.07
*         Added wf ("weight factor") and statement about sum of weights, as in ivreg2
*         Added dofminus option, as in ivreg2
*         Fixed minor reporting bug - was reporting gaps in entire panel, not just touse-d portion
*         Recoded kernel & bw checks to use shared ivreg2 subroutine vkernel
* 1.2.05  Fixed weighting bug introduced in 1.2.04.  All weights were affected.
*         Was result of incompatibility of code shared with ivreg2.
* 1.3.01  First ranktest version with accompanying Mata library (shared with -ivreg2-).
*         Mata library includes struct ms_vcvorthog, m_omega, m_calckw, s_vkernel.
*         Fixed bug in 2-way cluster code (now in m_omega in Mata library) - would crash if K>1.
* 1.3.02  Improved partialling out and matrix inversion - switched from qrsolve to invsym.
*         Use _makesymmetric() instead of symmetrizing by hand.
* 1.3.03  01Jan14. Fixed reporting bug with 2-way clustering and kernel-robust that would give
*         wrong count for 2nd cluster variable.
* 1.3.04  24Aug14. Fixed bug in markout - would include obs where some vars were missing
* 1.3.05  22Jan15. Promotion to version 11.2; forks to ranktest9 if version<=10; requires
*         capture before "version 11.2" in Mata section since must load before forking.
*         Renamed subroutine rkstat to s_rkstat.
* 1.4.01  16Aug15.  Pass cons flag to Mata code.  Added cholqrsolve() utility (use qr if chol fails).
*         Partial code rewritten to use centering and cholqrsolve.  pihat uses cholqrsolve.
*         Separate code for iid and non-iid cases (faster, more accurate for iid case).
*         Fixed bug in naming rows/cols of saved V and S matrices (wasn't unab-ing the varlists).
*         Updated undocumented psd options psd0 and psda.  Tweaked cluster count code to match ivreg2.
*         Added r(version) and r(cmd) macros.

		
	
	
