////////////////////////////////////////////////////////////////////////////////
/*						MEXICO:	FS, RD & Falsification						  */
////////////////////////////////////////////////////////////////////////////////

clear
set more off, permanently
global geo "Capital Ciudad1960 landquality"
global controls "Capital Ciudad1960 landquality logpop1940 primary_schooling1940 university1940 battles_noncentroid share_basin share_ind"

// ---------------------------------------------------------------------------//
// 								FS, RD & Falsification						  //	
// ---------------------------------------------------------------------------//

clear
use "$MEX"

acreg corr_cam4060 index_mean i.state, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512)
outreg2 using Results/FS_RD_FE_p1.tex, keep(index_mean) ctitle("1") replace nocons label dec(3) noaster

acreg totalpcviolencia index_mean i.state,  id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512)
outreg2 using Results/FS_RD_FE_p1.tex, keep(index_mean) ctitle("2") append nocons label dec(3) noaster

acreg corr_cam3040 index_mean i.state, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512)
outreg2 using Results/FS_RD_FE_p1.tex, keep(index_mean) ctitle("3") append nocons label dec(3) noaster

acreg corr_cam2040 index_mean i.state, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512)
outreg2 using Results/FS_RD_FE_p1.tex, keep(index_mean) ctitle("4") append nocons label dec(3) noaster

acreg share_20_39 index_mean i.state, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512)
outreg2 using Results/FS_RD_FE_p1.tex, keep(index_mean) ctitle("5") append nocons label dec(3) noaster

acreg literacy3040 index_mean i.state, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512)
outreg2 using Results/FS_RD_FE_p1.tex, keep(index_mean) ctitle("6") append nocons label dec(3) noaster

acreg battles_centroid index_mean i.state, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512)
outreg2 using Results/FS_RD_FE_p1.tex, keep(index_mean) ctitle("7") append nocons label dec(3) noaster

// ---------------------------------------------------------------------------//
// 						FS, RD & Falsification with controls				  //	
// ---------------------------------------------------------------------------//

global controls "Capital Ciudad1960 landquality logpop1940 primary_schooling1940 university1940 battles_centroid share_basin share_ind"

acreg corr_cam4060 index_mean i.state $controls, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512)
outreg2 using Results/FS_RD_FE_p2.tex, keep(index_mean) ctitle("1") replace nocons label dec(3) noaster

acreg totalpcviolencia index_mean i.state $controls,  id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512)
outreg2 using Results/FS_RD_FE_p2.tex, keep(index_mean) ctitle("2") append nocons label dec(3) noaster

acreg corr_cam3040 index_mean i.state $controls, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512)
outreg2 using Results/FS_RD_FE_p2.tex, keep(index_mean) ctitle("3") append nocons label dec(3) noaster

acreg corr_cam2040 index_mean i.state $controls, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512)
outreg2 using Results/FS_RD_FE_p2.tex, keep(index_mean) ctitle("4") append nocons label dec(3) noaster

acreg share_20_39 index_mean i.state $controls, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512)
outreg2 using Results/FS_RD_FE_p2.tex, keep(index_mean) ctitle("5") append nocons label dec(3) noaster

acreg literacy3040 index_mean i.state $controls, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512)
outreg2 using Results/FS_RD_FE_p2.tex, keep(index_mean) ctitle("6") append nocons label dec(3) noaster

global controls "Capital Ciudad1960 landquality logpop1940 primary_schooling1940 university1940 share_basin share_ind"
acreg battles_centroid index_mean i.state $controls, id(muncluster)  latitude(lat) spatial longitude(lon) dist(35.9512)
outreg2 using Results/FS_RD_FE_p2.tex, keep(index_mean) ctitle("7") append nocons label dec(3) noaster

cap erase Results/FS_RD_FE_p1.txt
cap erase Results/FS_RD_FE_p2.txt



