clear
clear matrix
set scheme s1color
set more off

cd $dir1

use dates_election.dta, clear

* graph elections
format date_election %d
drop if date_election<d(1jan1985) | date_election>d(1jan2010)

sort id_city date_election
gen date_next_theo_election=date_election+(365*5) if date_election<d(27mar1993) & date_election!=.
replace date_next_theo_election=date_election+(365*4) if date_election>=d(27mar1993) & date_election<=d(28sep2001)
replace date_next_theo_election=date_election+(365*5) if date_election>d(28sep2001) & date_election!=.
format date_next_theo_election %d
sort id_city date_election
bysort id_city: gen date_next_theo_election_lag=date_next_theo_election[_n-1] if date_next_theo_election[_n-1]!=.
format date_next_theo_election_lag %d
gen anticipate1993=date_election<d(27mar1993) & date_next_theo_election_lag>=d(27mar1993) if date_election!=. & date_next_theo_election_lag!=.
gen anticipate1993_reelected=anticipate1993
replace anticipate1993_reelected=0 if n_terms==1 & anticipate1993!=.
gen posticipate1993=date_election>=d(27mar1993) & date_next_theo_election_lag<d(27mar1993) if date_election!=. & date_next_theo_election_lag!=.
gen posticipate1993_reelected=posticipate1993
replace posticipate1993_reelected=0 if n_terms==1 & posticipate1993!=.
format date_election %tdmon-YY
label var date_election "Election month"

twoway (histogram date_election, freq width(30) lwidth(thin) lcolor(khaki) fcolor(khaki)) /*
*/ , ytitle("Frequency") xline(12140, lcolor(blue) lwidth(medthick)) xline(14620, lcolor(red) lwidth(medthick)) xline(16790, lcolor(red) lwidth(medthick)) legend(off) xlabel(9132 12140 14620 16790 17897, labsize(small)) ylabel(0 2000 4000 6000)
graph save FigA4.gph, replace
graph export FigA4.eps, replace fontface(Times)
