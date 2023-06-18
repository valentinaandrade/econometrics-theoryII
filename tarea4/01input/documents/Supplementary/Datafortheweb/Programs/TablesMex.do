texdoc init  Results/TablesMex.tex, replace 

/*tex
\begin{table}
\caption{Mexico: Descriptive statistics}
\begin{center}
\scalebox{0.6}{
\begin{tabular}{lcccc}
\hline \hline
  &  &  & \multicolumn{2}{c}{\parbox{4cm}{\center \ \\ \center \underline{By declines in baseline modified predicted mortality (malaria suitability)}}} \\
 & Year & Base sample & \parbox{2cm}{\center Above median}  & \parbox{2cm}{\center Below median} \\ 
Variable & (1) & (2) & (3) & (4)  \\
 \hline \\
tex*/
texdoc stlog
texdoc stlog close

foreach var_name in totalpcviolencia nr_pc notnr_pc totalpcnoviolenta battles_centroid corr_logpop1920 corr_logpop1930 corr_logpop1940 corr_logpop1960 young2_1940 young2_1960 adults2_1940 adults2_1960 index_mean drought_nonharvest5 drought_harvest5 literacy1940 literacy1960 literacy1940_15to39 literacy1960_15to39 primary_schooling1940 primary_schooling1960 {
clear all
use "$MEX"

replace index_mean = abs(index_mean) // = Change in predicted Mortality!

egen median = median(index_mean)
gen above = cond(index_mean>=median,1,0)
gen below = cond(index_mean<median,1,0)
gen n = 1


 
// overall 
tabstat `var_name', by(n) stat(mean sd) nototal save

global meany1 : di %5.3f el(r(Stat1),1,1)
global sdy1 : di %5.3f el(r(Stat1),2,1) 

texdoc local meany1  "$meany1"
texdoc local sdy1  "$sdy1"

// Above

tabstat `var_name' if above==1, by(n) stat(mean sd) nototal save

global meany1_a : di %5.3f el(r(Stat1),1,1)
global sdy1_a : di %5.3f el(r(Stat1),2,1) 

texdoc local meany1_a  "$meany1_a"
texdoc local sdy1_a  "$sdy1_a"

// Below

tabstat `var_name' if below==1, by(n) stat(mean sd) nototal save

global meany1_b : di %5.3f el(r(Stat1),1,1)
global sdy1_b : di %5.3f el(r(Stat1),2,1) 

texdoc local meany1_b  "$meany1_b"
texdoc local sdy1_b  "$sdy1_b"


preserve
describe `var_name', replace clear
global var_label = varlab
texdoc local var_label "$var_label"
restore 


/*-------- Social Conflict -------------- */ 

if "`var_name'"=="totalpcviolencia" {
		/*tex
		\multicolumn{4}{c}{\bf \underline{Social Conflict}} \\ \\	
		tex*/
}
    
if "`var_name'"=="totalpcviolencia" | "`var_name'"=="nr_pc" | "`var_name'"=="notnr_pc" | "`var_name'"=="totalpcnoviolenta" {
		/*tex
		`var_label'  & 1960 & $ `meany1' $ & $ `meany1_a' $ & $ `meany1_b' $   \\
					   &  & $ (`sdy1') $ & $ (`sdy1_a') $ & $ (`sdy1_b')$  \\ \\
		tex*/

}
if "`var_name'"=="battles_centroid" | "`var_name'"=="battles_noncentroid" {

		/*tex
		`var_label'  & 1860-1940 & $ `meany1' $ & $ `meany1_a' $ & $ `meany1_b' $   \\
					   &  & $ (`sdy1') $ & $ (`sdy1_a') $ & $ (`sdy1_b')$  \\ \\
		tex*/
}

/*-------- Population -------------- */ 
if "`var_name'"=="corr_logpop1920" {
		/*tex
		\multicolumn{4}{c}{\bf \underline{Population}} \\ \\	

		`var_label'  & 1920 & $ `meany1' $ & $ `meany1_a' $ & $ `meany1_b' $   \\
					   &  & $ (`sdy1') $ & $ (`sdy1_a') $ & $ (`sdy1_b')$  \\ \\
		tex*/
}
if "`var_name'"=="corr_logpop1930"{
		/*tex
		`var_label'  & 1930 & $ `meany1' $ & $ `meany1_a' $ & $ `meany1_b' $   \\
					   &  & $ (`sdy1') $ & $ (`sdy1_a') $ & $ (`sdy1_b')$  \\ \\
		tex*/
}
if "`var_name'"=="corr_logpop1940" | "`var_name'"=="young2_1940" | "`var_name'"=="adults2_1940" {
		/*tex
		`var_label'  & 1940 & $ `meany1' $ & $ `meany1_a' $ & $ `meany1_b' $   \\
					   &  & $ (`sdy1') $ & $ (`sdy1_a') $ & $ (`sdy1_b')$  \\ \\
		tex*/
}

if "`var_name'"=="young2_1960" | "`var_name'"=="adults2_1960" | "`var_name'"=="corr_logpop1960"{
		/*tex
		`var_label'  & 1960 & $ `meany1' $ & $ `meany1_a' $ & $ `meany1_b' $   \\
					   &  & $ (`sdy1') $ & $ (`sdy1_a') $ & $ (`sdy1_b')$  \\ \\
		tex*/
}

/*-------- Disease -------------- */ 
if "`var_name'"=="index_mean"{
		/*tex
		\multicolumn{4}{c}{\bf \underline{Disease}} \\ \\	
		`var_label'  & 1960 & $ `meany1' $ & $ `meany1_a' $ & $ `meany1_b' $   \\
					   &  & $ (`sdy1') $ & $ (`sdy1_a') $ & $ (`sdy1_b')$  \\ \\
		tex*/
}
/*-------- Droughts -------------- */ 
 if "`var_name'"=="drought_nonharvest5" {
		/*tex
		\multicolumn{4}{c}{\bf \underline{Droughts}} \\ \\	
		tex*/
}
 
if "`var_name'"=="drought_nonharvest5" | "`var_name'"=="drought_harvest5" {

		/*tex
		`var_label'  & 1960 & $ `meany1' $ & $ `meany1_a' $ & $ `meany1_b' $   \\
					   &  & $ (`sdy1') $ & $ (`sdy1_a') $ & $ (`sdy1_b')$  \\ \\
		tex*/
}
/*-------- Education -------------- */ 

 if "`var_name'"=="literacy1940" {
		/*tex
		\multicolumn{4}{c}{\bf \underline{Education}} \\ \\	
		tex*/
 
 }
if "`var_name'"=="literacy1940" | "`var_name'"=="literacy1940_15to39" | "`var_name'"=="primary_schooling1940" {
		/*tex
		`var_label'  & 1940 & $ `meany1' $ & $ `meany1_a' $ & $ `meany1_b' $   \\
					   &  & $ (`sdy1') $ & $ (`sdy1_a') $ & $ (`sdy1_b')$  \\ \\
		tex*/
}
if "`var_name'"=="literacy1960" | "`var_name'"=="literacy1960_15to39" | "`var_name'"=="primary_schooling1960" {
		/*tex
		`var_label'  & 1960 & $ `meany1' $ & $ `meany1_a' $ & $ `meany1_b' $   \\
					   &  & $ (`sdy1') $ & $ (`sdy1_a') $ & $ (`sdy1_b')$  \\ \\
		tex*/
}
 
}
/*tex
\\ \hline

\multicolumn{5}{l}{\footnotesize{\parbox{15cm}{Notes: Municipal-level information. 
The table reports the mean values of variables in the samples described in the
column heading, with standard deviations in parentheses. Malaria suitability is temperature suitability for Malaria from not suitable (zero) to maximum suitability in Mexico (one). Protests are counts of news stories about protests during the 1960s, expressed as a fraction of baseline population (per 100,000 people).
 Historical conflicts are battles fought in each municipality from 1816 to 1940.
 Municipal and state level includes all battles, assigning proportionally to municipalities in the state battles that can only be located at the state level. Municipal level only counts battles that can be precisely geolocated in each municipality. 
  Columns 3 and 4 report descriptive statistics for subsamples in which malaria suitability was above or below the median value in the base sample (0.39)
See the text and Appendix Table \ref{sources} for more details and definitions.}}}
\end{tabular}
}
\end{center}
\end{table}
tex*/







