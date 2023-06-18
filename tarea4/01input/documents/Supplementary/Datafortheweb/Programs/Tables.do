texdoc init Results/Tables.tex, replace 

/*tex
\begin{table}
\caption{Descriptive statistics}
\begin{center}
\scalebox{0.78}{
\begin{tabular}{lccccccc}
\hline \hline
  &  &  & \multicolumn{3}{c}{\parbox{4cm}{\center \ \\ \center \underline{By initial income}}} &  \multicolumn{2}{c}{\parbox{4cm}{\center By declines \underline{in predicted mortality}}} \\
 & Year & Base sample & Rich &  Middle & Poor & \parbox{2cm}{\center Above median}  & \parbox{2cm}{\center Below median} \\ 
Variable & (1) & (2) & (3) & (4) & (5) & (6) & (7) \\
 \hline \\

tex*/
texdoc stlog
texdoc stlog close
foreach var_name in propconflictCOW2 propconflictU  propconflictFL logdeathpop40U propconflictNR propconflict logmaddpop compsjmhatit {
clear all 
use "$DATA"
gen start=.
replace start=1 if startrich==1
replace start=2 if startmedium==1
replace start=3 if startpoor==1

lab var propconflictCOW2 "Fraction of decade in conflict, COW" 
lab var propconflictU  "Fraction of decade in conflict, Uppsala"
lab var propconflictFL "Fraction of decade in conflict, Fearon-Laitin"
lab var logdeathpop40U "Log 1 + Battle Deaths/population, Uppsala"
lab var logmaddpop "Log of population" 
lab var predicted_mortality "Baseline predicted mortality"
lab var propconflictNR "Fraction of decade in conflict, natural-resourse"
lab var propconflict "Fraction of decade in conflict, non natural-resourse"
lab var compsjmhatit "Baseline predicted mortality"

local year_condition  "(year==1940 | year==1980)"

// overall 
tabstat `var_name' if newbasesample==1 & `year_condition', by(year) stat(mean sd) nototal save

global meany1 : di %5.3f el(r(Stat1),1,1)
global sdy1 : di %5.3f el(r(Stat1),2,1) 
global meany2 : di %5.3f el(r(Stat2),1,1)
global sdy2 : di %5.3f el(r(Stat2),2,1) 

texdoc local meany1  "$meany1"
texdoc local sdy1  "$sdy1"
texdoc local meany2  "$meany2"
texdoc local sdy2  "$sdy2"

// by startrich 

tabstat `var_name' if start==1 & newbasesample==1 & `year_condition', by(year) stat(mean sd) nototal save
global meany1_r : di %5.3f el(r(Stat1),1,1)
global sdy1_r : di %5.3f el(r(Stat1),2,1) 
global meany2_r : di %5.3f el(r(Stat2),1,1)
global sdy2_r : di %5.3f el(r(Stat2),2,1) 

texdoc local meany1_r  "$meany1_r"
texdoc local sdy1_r  "$sdy1_r"
texdoc local meany2_r  "$meany2_r"
texdoc local sdy2_r  "$sdy2_r"

tabstat `var_name' if start==2 & newbasesample==1 & `year_condition', by(year) stat(mean sd) nototal save

global meany1_m : di %5.3f el(r(Stat1),1,1)
global sdy1_m : di %5.3f el(r(Stat1),2,1) 
global meany2_m : di %5.3f el(r(Stat2),1,1)
global sdy2_m : di %5.3f el(r(Stat2),2,1) 


texdoc local meany1_m  "$meany1_m"
texdoc local sdy1_m  "$sdy1_m"
texdoc local meany2_m  "$meany2_m"
texdoc local sdy2_m  "$sdy2_m"
 
tabstat `var_name' if start==3 & newbasesample==1 & `year_condition', by(year) stat(mean sd) nototal save

global meany1_p : di %5.3f el(r(Stat1),1,1)
global sdy1_p : di %5.3f el(r(Stat1),2,1) 
global meany2_p : di %5.3f el(r(Stat2),1,1)
global sdy2_p : di %5.3f el(r(Stat2),2,1) 


texdoc local meany1_p  "$meany1_p"
texdoc local sdy1_p  "$sdy1_p"
texdoc local meany2_p  "$meany2_p"
texdoc local sdy2_p  "$sdy2_p"


// by mortality

tabstat `var_name' if newabove_medmort==1 & newbasesample==1 & `year_condition', by(year) stat(mean sd) nototal save

global meany1_t : di %5.3f el(r(Stat1),1,1)
global sdy1_t : di %5.3f el(r(Stat1),2,1) 
global meany2_t : di %5.3f el(r(Stat2),1,1)
global sdy2_t : di %5.3f el(r(Stat2),2,1) 


texdoc local meany1_t  "$meany1_t"
texdoc local sdy1_t  "$sdy1_t"
texdoc local meany2_t  "$meany2_t"
texdoc local sdy2_t  "$sdy2_t"
 
tabstat `var_name' if newabove_medmort==0 & newbasesample==1 & `year_condition', by(year) stat(mean sd) nototal save

global meany1_b : di %5.3f el(r(Stat1),1,1)
global sdy1_b : di %5.3f el(r(Stat1),2,1) 
global meany2_b : di %5.3f el(r(Stat2),1,1)
global sdy2_b : di %5.3f el(r(Stat2),2,1) 

texdoc local meany1_b  "$meany1_b"
texdoc local sdy1_b  "$sdy1_b"
texdoc local meany2_b  "$meany2_b"
texdoc local sdy2_b  "$sdy2_b"

preserve
describe `var_name', replace clear
global var_label = varlab
texdoc local var_label "$var_label"

restore 


//1900
		if "`var_name'"=="propconflictCOW2" | "`var_name'"=="logmaddpop" {
		
		
		local year_condition  "year==1900"


		// overall 
		tabstat `var_name' if newsample40_COW==1 & `year_condition', by(year) stat(mean sd) nototal save


		global meany3 : di %5.3f el(r(Stat1),1,1)
		global sdy3 : di %5.3f el(r(Stat1),2,1) 

		texdoc local meany3  "$meany3"
			texdoc local sdy3  "$sdy3"


		// by startrich 

		tabstat `var_name' if start==1 & newsample40_COW==1 & `year_condition', by(year) stat(mean sd) nototal save

		global meany3_r : di %5.3f el(r(Stat1),1,1)
		global sdy3_r : di %5.3f el(r(Stat1),2,1) 
	
		texdoc local meany3_r  "$meany3_r"
		texdoc local sdy3_r  "$sdy3_r"

		tabstat `var_name' if start==2 & newsample40_COW==1 & `year_condition', by(year) stat(mean sd) nototal save

		global meany3_m : di %5.3f el(r(Stat1),1,1)
		global sdy3_m : di %5.3f el(r(Stat1),2,1) 

		texdoc local meany3_m  "$meany3_m"
		texdoc local sdy3_m  "$sdy3_m"
 
 
		tabstat `var_name' if start==3 & newsample40_COW==1 & `year_condition', by(year) stat(mean sd) nototal save


		global meany3_p : di %5.3f el(r(Stat1),1,1)
		global sdy3_p : di %5.3f el(r(Stat1),2,1) 

		texdoc local meany3_p  "$meany3_p"
		texdoc local sdy3_p  "$sdy3_p"

		// by mortality

		tabstat `var_name' if newabove_medmort==1 & newsample40_COW==1 & `year_condition', by(year) stat(mean sd) nototal save

		global meany3_t : di %5.3f el(r(Stat1),1,1)
		global sdy3_t : di %5.3f el(r(Stat1),2,1) 

		texdoc local meany3_t  "$meany3_t"
		texdoc local sdy3_t  "$sdy3_t"
 
		tabstat `var_name' if newabove_medmort==0 & newsample40_COW==1 & `year_condition', by(year) stat(mean sd) nototal save

		global meany3_b : di %5.3f el(r(Stat1),1,1)
		global sdy3_b : di %5.3f el(r(Stat1),2,1) 

		texdoc local meany3_b  "$meany3_b"
		texdoc local sdy3_b  "$sdy3_b"
		
		/*tex
		`var_label'  & 1900 & $ `meany3' $ & $ `meany3_r' $ & $ `meany3_m' $  & $ `meany3_p' $  & $ `meany3_t' $ & $ `meany3_b'$ \\
					   &  & $ (`sdy3') $ & $ (`sdy3_r') $ & $ (`sdy3_m')$  & $ (`sdy3_p') $  & $ (`sdy3_t') $ & $ (`sdy3_b') $ \\ \\
		tex*/
		

		}
// 1940
		/*tex
		`var_label'  & 1940 & $ `meany1' $ & $ `meany1_r' $ & $ `meany1_m' $  & $ `meany1_p' $  & $ `meany1_t' $ & $ `meany1_b'$ \\
					   &  & $ (`sdy1') $ & $ (`sdy1_r') $ & $ (`sdy1_m')$  & $ (`sdy1_p') $  & $ (`sdy1_t') $ & $ (`sdy1_b') $ \\ \\
		tex*/
		

		if "`var_name'"!="compsjmhatit" {
// 1980

		/*tex
		`var_label'  & 1980 & $ `meany2' $ & $ `meany2_r' $ & $ `meany2_m' $  & $ `meany2_p' $  & $ `meany2_t' $ & $ `meany2_b'$ \\
					   &  & $ (`sdy2') $ & $ (`sdy2_r') $ & $ (`sdy2_m')$  & $ (`sdy2_p') $  & $ (`sdy2_t') $ & $ (`sdy2_b') $ \\ \\
		tex*/
		}



}
/*tex
\\ \hline

\multicolumn{8}{l}{\footnotesize{\parbox{22cm}{Notes: The table reports the mean values of variables in the samples described in the 
column heading, with standard deviations in parentheses. Initially rich countries had log GDP per capita over 8.4 in 1940, middle-income 
countries had log GDP per capita between 7.37 and 8.4, and low-income countries had log GDP per capita below 7.37 in 1940. Predicted mortality 
is measured per 100 per year. Columns 6 and 7 report descriptive statistics for subsamples in which change in predicted mortality between 1940 and 1980s 
was above or below the median value in the base sample (-0.405). Initially rich countries have no civil wars recorded in the COW dataset in the 1940s and 1980s, 
and no conflict incidence according to the Fearon and Laitin and Uppsala sources in the 1940s. 
See the text and Appendix Table 1 for details and definitions.}}}
\end{tabular}
}
\end{center}
\end{table}
tex*/

