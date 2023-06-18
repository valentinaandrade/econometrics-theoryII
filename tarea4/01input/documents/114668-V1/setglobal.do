clear
clear matrix
set scheme s1color
set more off
drop _all 

*Geo controls
global geog "pop_res dp* tar_eff_lav deficit deficit_miss"
global geog2 "pop_res dp* deficit deficit_miss"
*Time effects
global time " year2000 year2001 year2002 year2003 year2004"
global time2 "year2000 year2001 year2002 year2003 year2004 year2005 year2007 year2008 year2009 year2010 post"
*Auctions 
global auction "starting_value starting_value2 obj_work_road obj_work_school obj_work_build obj_work_house obj_work_art direct_nego_gr"
global auction2 "starting_value starting_value2 obj_work_const obj_work_renov obj_work_road obj_work_plumb obj_work_ground obj_work_elect obj_work_plant obj_work_env obj_work_secu obj_work_other open_part_gr"
global auction3 "                               obj_work_road obj_work_school obj_work_build obj_work_house obj_work_art direct_nego_gr"
global auction4 "starting_value starting_value2 																		 direct_nego_gr"
global auction5 "obj_work_road obj_work_school obj_work_build obj_work_house obj_work_art"
*Mayor
global mayor "gender age born_prov born_prov_miss office_before empl_not empl_not_miss empl_high empl_high_miss empl_low empl_low_miss secondary secondary_miss college college_miss"
*Political
global electoral "tt_party_cont last_year_off centerright_gr centerleft_gr "
*Pre-determined car.
global predeter "NW NE CE SOU IS pop_census1991 alt extension gender age born_reg secondary college empl_not empl_low empl_medium empl_high"



