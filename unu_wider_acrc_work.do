
********************************************************************************
* START ************************************************************************
********************************************************************************

clear all
set more off

global root 	"C:\Users\Mahofa\OneDrive - University of Cape Town\CurrentWork\UNU_WIDER_African_Cities"
global rawdata 	"$root\rawdata"
global code 	"$root\code"
global data		"$root\data"
global output	"$root\output"
global gis 		"$root\GIS"
use "$rawdata\wards_data.dta", clear

drop wardpcode0 no_merged_ shape_leng shape_area wardpcod_2 wardpcod_3 district12 ///
district district02 districtpc  areakm2
so wardpcod_1
save "$data\wardlevel_data", replace
**
import excel using "$data\wards_data_11", firstrow clear
keep wardcode wardpcod_1
so wardpcod_1
mer 1:1 wardpcod_1 using "$data\wardlevel_data", nogen
so wardcode
**
*Creating variables normalised by population
replace pop = 113599 if wardcode == "ZW190101"

foreach x in totjobs12 pd_empl_11 pd_empl__9 pd_empl_12 informal_i informal_1 ///
informal_s {
g `x'_prop = `x'/pop 
}

foreach x in totjobs02 paid_em_13 paid_em_11 paid_em_14 informal_4 informal_5 ///
informal_2 {
g `x'_prop = `x'/pop02
}

save "$data\wardlevel_data_fin", replace

******
*MAPS
*****
*Extracting shape files to STATA
/* shp2dta using "$gis\harare_chitown_eptown.shp", database("hre_chitown_eptown_dbase.dta") coordinates("hre_chitown_eptown_coor.dta") ///
genid(_ID1) gencentroids(centroid) replace */

use "$data\hre_chitown_eptown_dbase.dta", clear

spmap using "$data\hre_chitown_eptown_coor.dta", id(_ID) /*Empty map*/
ren ADM3_PCODE wardcode
replace wardcode = "ZW190101" if wardcode == "ZW192401"
so wardcode
save "$data\hre_chitown_eptown_dbase_tome.dta", replace
mer 1:1 wardcode using "$data\wardlevel_data_fin"
keep if _mer == 3
drop _mer  
spmap pop using "$data\hre_chitown_eptown_coor.dta", id(_ID) /*populatin 2012 map*/

spmap totjobs12 using "$data\hre_chitown_eptown_coor.dta", ///
id(_ID) clmethod(quantile) cln(6) /// draw choropleth map using quintiles
	fcolor(Blues) /// use same colour scheme as before
	legend(pos(8)) ///
	legorder(lohi) ///
	legtitle(Total Jobs, 2012) /*jobs 2012 map*/
 
colorpalette viridis, n(12) nograph reverse
local colors `r(p)'
set scheme white_tableau
spmap pop using "$data\hre_chitown_eptown_coor.dta", ///
id(_ID) clmethod(quantile) cln(10) /// draw choropleth map using quintiles
	fcolor("`colors'") ocolor(white ..) osize(0.05 ..) /// use same colour scheme as before
	legend(pos(4)) ///
	legorder(hilo) ///
	label(data("$data\wardlabels.dta") xcoord(x_centroid) ycoord(y_centroid) ///
	label(wardname) size(*0.55 ..)) ///
	legtitle(Total Population, 2012) /*Total pop 2012 map*/
 
colorpalette viridis, n(12) nograph reverse
local colors `r(p)'
set scheme white_tableau
spmap pop02 using "$data\hre_chitown_eptown_coor.dta", ///
id(_ID) clmethod(quantile) cln(10) /// draw choropleth map using quintiles
	fcolor("`colors'") ocolor(white ..) osize(0.05 ..) /// use same colour scheme as before
	legend(pos(4)) ///
	legorder(hilo) ///
	label(data("$data\wardlabels.dta") xcoord(x_centroid) ycoord(y_centroid) ///
	label(wardname) size(*0.55 ..)) ///
	legtitle(Total Population, 2002) /*Total pop 2002 map*/
	
replace popdens12 = round(popdens12,1)
colorpalette viridis, n(12) nograph reverse
local colors `r(p)'
set scheme white_tableau
spmap popdens12 using "$data\hre_chitown_eptown_coor.dta", ///
id(_ID) clmethod(quantile) cln(10) /// draw choropleth map using quintiles
	fcolor("`colors'") ocolor(white ..) osize(0.05 ..) /// use same colour scheme as before
	legend(pos(4)) ///
	legorder(hilo) ///
	label(data("$data\wardlabels.dta") xcoord(x_centroid) ycoord(y_centroid) ///
	label(wardname) size(*0.55 ..)) ///
	legtitle(Population density, 2012) /*Total pop density 2012 map*/

replace popdens02 = round(popdens02,1)
colorpalette viridis, n(12) nograph reverse
local colors `r(p)'
set scheme white_tableau
spmap popdens02 using "$data\hre_chitown_eptown_coor.dta", ///
id(_ID) clmethod(quantile) cln(10) /// draw choropleth map using quintiles
	fcolor("`colors'") ocolor(white ..) osize(0.05 ..) /// use same colour scheme as before
	legend(pos(4)) ///
	legorder(hilo) ///
	label(data("$data\wardlabels.dta") xcoord(x_centroid) ycoord(y_centroid) ///
	label(wardname) size(*0.55 ..)) ///
	legtitle(Population density, 2002) /*Total pop density 2002 map*/

colorpalette viridis, n(12) nograph reverse
local colors `r(p)'
set scheme white_tableau
spmap pd_empl_12 using "$data\hre_chitown_eptown_coor.dta", ///
id(_ID) clmethod(quantile) cln(10) /// draw choropleth map using quintiles
	fcolor("`colors'") ocolor(white ..) osize(0.05 ..) /// use same colour scheme as before
	legend(pos(4)) ///
	legorder(hilo) ///
	label(data("$data\wardlabels.dta") xcoord(x_centroid) ycoord(y_centroid) ///
	label(wardname) size(*0.55 ..)) ///
	legtitle(Employment in agro-industry, 2012) /*Employment in agr 2012 map*/

colorpalette viridis, n(12) nograph reverse
local colors `r(p)'
set scheme white_tableau
spmap paid_em_14 using "$data\hre_chitown_eptown_coor.dta", ///
id(_ID) clmethod(quantile) cln(10) /// draw choropleth map using quintiles
	fcolor("`colors'") ocolor(white ..) osize(0.05 ..) /// use same colour scheme as before
	legend(pos(4)) ///
	legorder(hilo) ///
	label(data("$data\wardlabels.dta") xcoord(x_centroid) ycoord(y_centroid) ///
	label(wardname) size(*0.55 ..)) ///
	legtitle(Employment in agro-industry, 2002) /*Employment in agr 2002 map*/
	
colorpalette viridis, n(12) nograph reverse
local colors `r(p)'
set scheme white_tableau
spmap pd_empl_11 using "$data\hre_chitown_eptown_coor.dta", ///
id(_ID) clmethod(quantile) cln(10) /// draw choropleth map using quintiles
	fcolor("`colors'") ocolor(white ..) osize(0.05 ..) /// use same colour scheme as before
	legend(pos(4)) ///
	legorder(hilo) ///
	label(data("$data\wardlabels.dta") xcoord(x_centroid) ycoord(y_centroid) ///
	label(wardname) size(*0.55 ..)) ///
	legtitle(Employment in ind, 2012) /*Employment in ind 2012 map*/

colorpalette viridis, n(12) nograph reverse
local colors `r(p)'
set scheme white_tableau
spmap paid_em_13 using "$data\hre_chitown_eptown_coor.dta", ///
id(_ID) clmethod(quantile) cln(10) /// draw choropleth map using quintiles
	fcolor("`colors'")) ocolor(white ..) osize(0.05 ..) /// use same colour scheme as before
	legend(pos(4)) ///
	legorder(hilo) ///
	label(data("$data\wardlabels.dta") xcoord(x_centroid) ycoord(y_centroid) ///
	label(wardname) size(*0.55 ..)) ///
	legtitle(Employment in ind, 2002) /*Employment in ind 2002 map*/

colorpalette viridis, n(12) nograph reverse
local colors `r(p)'
set scheme white_tableau
spmap pd_empl__9 using "$data\hre_chitown_eptown_coor.dta", ///
id(_ID) clmethod(quantile) cln(10) /// draw choropleth map using quintiles
	fcolor("`colors'") ocolor(white ..) osize(0.05 ..) /// use same colour scheme as before
	legend(pos(4)) ///
	legorder(hilo) ///
	label(data("$data\wardlabels.dta") xcoord(x_centroid) ycoord(y_centroid) ///
	label(wardname) size(*0.55 ..)) ///
	legtitle(Employment in serv, 2012) /*Employment in services 2012 map*/

colorpalette viridis, n(12) nograph reverse
local colors `r(p)'
set scheme white_tableau
spmap paid_em_11 using "$data\hre_chitown_eptown_coor.dta", ///
id(_ID) clmethod(quantile) cln(10) /// draw choropleth map using quintiles
	fcolor("`colors'")) ocolor(white ..) osize(0.05 ..) /// use same colour scheme as before
	legend(pos(4)) ///
	legorder(hilo) ///
	label(data("$data\wardlabels.dta") xcoord(x_centroid) ycoord(y_centroid) ///
	label(wardname) size(*0.55 ..)) ///
	legtitle(Employment in serv, 2002) /*Employment in services 2002 map*/


	*Informal Employment
colorpalette viridis, n(12) nograph reverse
local colors `r(p)'
set scheme white_tableau
spmap informal_a using "$data\hre_chitown_eptown_coor.dta", ///
id(_ID) clmethod(quantile) cln(10) /// draw choropleth map using quintiles
	fcolor("`colors'") ocolor(white ..) osize(0.05 ..) /// use same colour scheme as before
	legend(pos(4)) ///
	legorder(hilo) ///
	label(data("$data\wardlabels.dta") xcoord(x_centroid) ycoord(y_centroid) ///
	label(wardname) size(*0.55 ..)) ///
	legtitle(Informal Emp in agri, 2012) 

colorpalette viridis, n(12) nograph reverse
local colors `r(p)'
set scheme white_tableau
spmap informal_3 using "$data\hre_chitown_eptown_coor.dta", ///
id(_ID) clmethod(quantile) cln(10) /// draw choropleth map using quintiles
	fcolor("`colors'") ocolor(white ..) osize(0.05 ..) /// use same colour scheme as before
	legend(pos(4)) ///
	legorder(hilo) ///
	label(data("$data\wardlabels.dta") xcoord(x_centroid) ycoord(y_centroid) ///
	label(wardname) size(*0.55 ..)) ///
	legtitle(Informal Emp in agri, 2002)

colorpalette viridis, n(12) nograph reverse
local colors `r(p)'
set scheme white_tableau
spmap informal_i using "$data\hre_chitown_eptown_coor.dta", ///
id(_ID) clmethod(quantile) cln(10) /// draw choropleth map using quintiles
	fcolor("`colors'") ocolor(white ..) osize(0.05 ..) /// use same colour scheme as before
	legend(pos(4)) ///
	legorder(hilo) ///
	label(data("$data\wardlabels.dta") xcoord(x_centroid) ycoord(y_centroid) ///
	label(wardname) size(*0.55 ..)) ///
	legtitle(Informal Emp in ind, 2012)

colorpalette viridis, n(12) nograph reverse
local colors `r(p)'
set scheme white_tableau
spmap informal_4 using "$data\hre_chitown_eptown_coor.dta", ///
id(_ID) clmethod(quantile) cln(10) /// draw choropleth map using quintiles
	fcolor("`colors'") ocolor(white ..) osize(0.05 ..) /// use same colour scheme as before
	legend(pos(4)) ///
	legorder(hilo) ///
	label(data("$data\wardlabels.dta") xcoord(x_centroid) ycoord(y_centroid) ///
	label(wardname) size(*0.55 ..)) ///
	legtitle(Informal Emp in ind, 2002)

colorpalette viridis, n(12) nograph reverse
local colors `r(p)'
set scheme white_tableau
spmap informal_1 using "$data\hre_chitown_eptown_coor.dta", ///
id(_ID) clmethod(quantile) cln(10) /// draw choropleth map using quintiles
	fcolor("`colors'") ocolor(white ..) osize(0.05 ..) /// use same colour scheme as before
	legend(pos(4)) ///
	legorder(hilo) ///
	label(data("$data\wardlabels.dta") xcoord(x_centroid) ycoord(y_centroid) ///
	label(wardname) size(*0.55 ..)) ///
	legtitle(Informal Emp in agro-ind, 2012)

colorpalette viridis, n(12) nograph reverse
local colors `r(p)'
set scheme white_tableau
spmap informal_5 using "$data\hre_chitown_eptown_coor.dta", ///
id(_ID) clmethod(quantile) cln(10) /// draw choropleth map using quintiles
	fcolor("`colors'") ocolor(white ..) osize(0.05 ..) /// use same colour scheme as before
	legend(pos(4)) ///
	legorder(hilo) ///
	label(data("$data\wardlabels.dta") xcoord(x_centroid) ycoord(y_centroid) ///
	label(wardname) size(*0.55 ..)) ///
	legtitle(Informal Emp in agro-ind, 2002)

colorpalette viridis, n(12) nograph reverse
local colors `r(p)'
set scheme white_tableau
spmap informal_s using "$data\hre_chitown_eptown_coor.dta", ///
id(_ID) clmethod(quantile) cln(10) /// draw choropleth map using quintiles
	fcolor("`colors'") ocolor(white ..) osize(0.05 ..) /// use same colour scheme as before
	legend(pos(4)) ///
	legorder(hilo) ///
	label(data("$data\wardlabels.dta") xcoord(x_centroid) ycoord(y_centroid) ///
	label(wardname) size(*0.55 ..)) ///
	legtitle(Informal Emp in serv, 2012)
	

colorpalette viridis, n(12) nograph reverse
local colors `r(p)'
set scheme white_tableau
spmap informal_2 using "$data\hre_chitown_eptown_coor.dta", ///
id(_ID) clmethod(quantile) cln(10) /// draw choropleth map using quintiles
	fcolor("`colors'") ocolor(white ..) osize(0.05 ..) /// use same colour scheme as before
	legend(pos(4)) ///
	legorder(hilo) ///
	label(data("$data\wardlabels.dta") xcoord(x_centroid) ycoord(y_centroid) ///
	label(wardname) size(*0.55 ..)) ///
	legtitle(Informal Emp in serv, 2002)

colorpalette viridis, n(12) nograph reverse
local colors `r(p)'
set scheme white_tableau
spmap pd_empl_12 using "$data\hre_chitown_eptown_coor.dta", ///
id(_ID) clmethod(quantile) cln(10) /// draw choropleth map using quintiles
	fcolor("`colors'") ocolor(white ..) osize(0.05 ..) /// use same colour scheme as before
	legend(pos(4)) ///
	legorder(hilo) ///
	label(data("$data\wardlabels.dta") xcoord(x_centroid) ycoord(y_centroid) ///
	label(wardname) size(*0.55 ..)) ///
	legtitle(Agro-Ind, 2012)

colorpalette viridis, n(12) nograph reverse
local colors `r(p)'
set scheme white_tableau
spmap paid_em_14 using "$data\hre_chitown_eptown_coor.dta", ///
id(_ID) clmethod(quantile) cln(10) /// draw choropleth map using quintiles
	fcolor("`colors'") ocolor(white ..) osize(0.05 ..) /// use same colour scheme as before
	legend(pos(4)) ///
	legorder(hilo) ///
	label(data("$data\wardlabels.dta") xcoord(x_centroid) ycoord(y_centroid) ///
	label(wardname) size(*0.55 ..)) ///
	legtitle(Agro-Ind, 2002)
	
	
	*INFRASTRUCTURE VARIABLES:CITY SYSTEMS
	egen elec_acc12 = rowtotal(acc_elec_m acc_elec_f)
	egen sanit_acc12 = rowtotal(acc_sant_m acc_sant_f)
	egen waterimp_acc12 =  rowtotal(wat_impr_m wat_impr_f)
	
	g prop_elec_acc12 = elec_acc12/pop
	g prop_sanit_acc12 = sanit_acc12/pop
	g prop_waterimp_acc12 = waterimp_acc12/pop
	**
	egen elec_acc02 = rowtotal(acc_elec_1 acc_elec_2)
	egen sanit_acc02 = rowtotal(acc_sant_1 acc_sant_2)
	egen waterimp_acc02 = rowtotal(wat_impr_1 wat_impr_2)
	
	g prop_elec_acc02 = elec_acc02/pop02
	g prop_sanit_acc02 = sanit_acc02/pop02
	g prop_waterimp_acc02 = waterimp_acc02/pop02
	*Education
	sum tertiary_e tot_m_f__3 /*pop with tertiary education*/
	g tertiary = tertiary_e/pop
	g tertiary02 = tot_m_f__3/pop02
	
	format prop_elec_acc12 %9.2g
colorpalette viridis, n(12) nograph reverse
local colors `r(p)'
set scheme white_tableau
spmap prop_elec_acc12 using "$data\hre_chitown_eptown_coor.dta", ///
id(_ID) clmethod(quantile) cln(10) /// draw choropleth map using quintiles
	fcolor("`colors'") ocolor(white ..) osize(0.05 ..) /// use same colour scheme as before
	legend(pos(4)) ///
	legorder(hilo) ///
	label(data("$data\wardlabels.dta") xcoord(x_centroid) ycoord(y_centroid) ///
	label(wardname) size(*0.55 ..)) ///
	legtitle(Access to ele, 2012)
	
	format prop_elec_acc02 %9.2g
colorpalette viridis, n(12) nograph reverse
local colors `r(p)'
set scheme white_tableau
spmap prop_elec_acc02 using "$data\hre_chitown_eptown_coor.dta", ///
id(_ID) clmethod(quantile) cln(10) /// draw choropleth map using quintiles
	fcolor("`colors'") ocolor(white ..) osize(0.05 ..) /// use same colour scheme as before
	legend(pos(4)) ///
	legorder(hilo) ///
	label(data("$data\wardlabels.dta") xcoord(x_centroid) ycoord(y_centroid) ///
	label(wardname) size(*0.55 ..)) ///
	legtitle(Access to ele, 2002)

	format prop_sanit_acc12 %9.2g
colorpalette viridis, n(12) nograph reverse
local colors `r(p)'
set scheme white_tableau
spmap prop_sanit_acc12 using "$data\hre_chitown_eptown_coor.dta", ///
id(_ID) clmethod(quantile) cln(10) /// draw choropleth map using quintiles
	fcolor("`colors'") ocolor(white ..) osize(0.05 ..) /// use same colour scheme as before
	legend(pos(4)) ///
	legorder(hilo) ///
	label(data("$data\wardlabels.dta") xcoord(x_centroid) ycoord(y_centroid) ///
	label(wardname) size(*0.55 ..)) ///
	legtitle(Access to san, 2012)
	**
	format prop_sanit_acc02 %9.2g
colorpalette viridis, n(12) nograph reverse
local colors `r(p)'
set scheme white_tableau
spmap prop_sanit_acc02 using "$data\hre_chitown_eptown_coor.dta", ///
id(_ID) clmethod(quantile) cln(10) /// draw choropleth map using quintiles
	fcolor("`colors'") ocolor(white ..) osize(0.05 ..) /// use same colour scheme as before
	legend(pos(4)) ///
	legorder(hilo) ///
	label(data("$data\wardlabels.dta") xcoord(x_centroid) ycoord(y_centroid) ///
	label(wardname) size(*0.55 ..)) ///
	legtitle(Access to san, 2002)
	**
	format prop_waterimp_acc12 %9.2g
colorpalette viridis, n(12) nograph reverse
local colors `r(p)'
set scheme white_tableau
spmap prop_waterimp_acc12 using "$data\hre_chitown_eptown_coor.dta", ///
id(_ID) clmethod(quantile) cln(10) /// draw choropleth map using quintiles
	fcolor("`colors'") ocolor(white ..) osize(0.05 ..) /// use same colour scheme as before
	legend(pos(4)) ///
	legorder(hilo) ///
	label(data("$data\wardlabels.dta") xcoord(x_centroid) ycoord(y_centroid) ///
	label(wardname) size(*0.55 ..)) ///
	legtitle(Access to impr_water, 2012)
	**
	
	format prop_waterimp_acc02 %9.2g
colorpalette viridis, n(12) nograph reverse
local colors `r(p)'
set scheme white_tableau
spmap prop_waterimp_acc02 using "$data\hre_chitown_eptown_coor.dta", ///
id(_ID) clmethod(quantile) cln(10) /// draw choropleth map using quintiles
	fcolor("`colors'") ocolor(white ..) osize(0.05 ..) /// use same colour scheme as before
	legend(pos(4)) ///
	legorder(hilo) ///
	label(data("$data\wardlabels.dta") xcoord(x_centroid) ycoord(y_centroid) ///
	label(wardname) size(*0.55 ..)) ///
	legtitle(Access to impr_water, 2002)
	**
	format tertiary %9.2g
colorpalette viridis, n(12) nograph reverse
local colors `r(p)'
set scheme white_tableau
spmap tertiary using "$data\hre_chitown_eptown_coor.dta", ///
id(_ID) clmethod(quantile) cln(10) /// draw choropleth map using quintiles
	fcolor("`colors'") ocolor(white ..) osize(0.05 ..) /// use same colour scheme as before
	legend(pos(4)) ///
	legorder(hilo) ///
	label(data("$data\wardlabels.dta") xcoord(x_centroid) ycoord(y_centroid) ///
	label(wardname) size(*0.55 ..)) ///
	legtitle(Tertiary edu, 2012)
	**
	
	format tertiary02 %9.2g
colorpalette viridis, n(12) nograph reverse
local colors `r(p)'
set scheme white_tableau
spmap tertiary02 using "$data\hre_chitown_eptown_coor.dta", ///
id(_ID) clmethod(quantile) cln(10) /// draw choropleth map using quintiles
	fcolor("`colors'") ocolor(white ..) osize(0.05 ..) /// use same colour scheme as before
	legend(pos(4)) ///
	legorder(hilo) ///
	label(data("$data\wardlabels.dta") xcoord(x_centroid) ycoord(y_centroid) ///
	label(wardname) size(*0.55 ..)) ///
	legtitle(Tertiary edu, 2002)
	**
	
	format mpiequalj_ %9.2g
colorpalette viridis, n(12) nograph reverse
local colors `r(p)'
set scheme white_tableau
spmap mpiequalj_ using "$data\hre_chitown_eptown_coor.dta", ///
id(_ID) clmethod(quantile) cln(10) /// draw choropleth map using quintiles
	fcolor("`colors'") ocolor(white ..) osize(0.05 ..) /// use same colour scheme as before
	legend(pos(4)) ///
	legorder(hilo) ///
	label(data("$data\wardlabels.dta") xcoord(x_centroid) ycoord(y_centroid) ///
	label(wardname) size(*0.55 ..)) ///
	legtitle(Market Potential)
	**
*Location Qoutient: explaining patterns of regional specialisation.
egen employment12 =  rowtotal(pd_empl_10 pd_empl__9 pd_empl_11 pd_empl_12)
egen employment02 = rowtotal(paid_em_12 paid_em_13 paid_em_11 paid_em_14)
egen tot_emp = total(employment12) /*total emp12*/
egen tot_em = total(employment02) /*total emp02*/
	
	*pd_empl_11 /*manu emp2012*/
	*paid_em_13 /*manu emp2002*/
	*pd_empl__9 /*services emp2012*/
	*paid_em_11 /*services emp2002*/
	
	foreach x in pd_empl_10 pd_empl__9 pd_empl_11 pd_empl_12 paid_em_12 paid_em_13 paid_em_11 paid_em_14 {
	egen `x'_tot = total(`x')
	}
	
g shre_agr = pd_empl_12/pd_empl_10_tot	
g shre_emp = employment12/tot_emp
g lq_agr = shre_agr/shre_emp
*
g shre_manu = pd_empl_11/pd_empl_11_tot
g lq_man12 = shre_manu/shre_emp
*
g shre_serv = pd_empl__9/pd_empl__9_tot
g lq_serv12 = shre_serv/shre_emp
***
g shre_agr02 = paid_em_14/paid_em_12_tot	
g shre_emp02 = employment02/tot_em
g lq_agr02 = shre_agr02/shre_emp02
*
g shre_manu02 = paid_em_13/paid_em_13_tot
g lq_man02 = shre_manu02/shre_emp02
*
g shre_serv02 = paid_em_11/paid_em_11_tot
g lq_serv02 = shre_serv02/shre_emp02
***
*Maps of location qoutient

format lq_agr %9.1g
colorpalette viridis, n(12) nograph reverse
local colors `r(p)'
set scheme white_tableau
spmap lq_agr using "$data\hre_chitown_eptown_coor.dta", ///
id(_ID) clmethod(quantile) cln(10) /// draw choropleth map using quintiles
	fcolor("`colors'") ocolor(white ..) osize(0.05 ..) /// use same colour scheme as before
	legend(pos(4)) ///
	legorder(hilo) ///
	label(data("$data\wardlabels.dta") xcoord(x_centroid) ycoord(y_centroid) ///
	label(wardname) size(*0.55 ..)) ///
	legtitle(LQ Agro-Industry, 2012)

format lq_agr02 %9.1g
colorpalette viridis, n(12) nograph reverse
local colors `r(p)'
set scheme white_tableau
spmap lq_agr02 using "$data\hre_chitown_eptown_coor.dta", ///
id(_ID) clmethod(quantile) cln(10) /// draw choropleth map using quintiles
	fcolor("`colors'") ocolor(white ..) osize(0.05 ..) /// use same colour scheme as before
	legend(pos(4)) ///
	legorder(hilo) ///
	label(data("$data\wardlabels.dta") xcoord(x_centroid) ycoord(y_centroid) ///
	label(wardname) size(*0.55 ..)) ///
	legtitle(LQ Agro-Industry, 2002)

format lq_man12 %9.1g
colorpalette viridis, n(12) nograph reverse
local colors `r(p)'
set scheme white_tableau
spmap lq_man12 using "$data\hre_chitown_eptown_coor.dta", ///
id(_ID) clmethod(quantile) cln(10) /// draw choropleth map using quintiles
	fcolor("`colors'") ocolor(white ..) osize(0.05 ..) /// use same colour scheme as before
	legend(pos(4)) ///
	legorder(hilo) ///
	label(data("$data\wardlabels.dta") xcoord(x_centroid) ycoord(y_centroid) ///
	label(wardname) size(*0.55 ..)) ///
	legtitle(LQ Manufacturing, 2012)

format lq_man02 %9.1g	
colorpalette viridis, n(12) nograph reverse
local colors `r(p)'
set scheme white_tableau
spmap lq_man02 using "$data\hre_chitown_eptown_coor.dta", ///
id(_ID) clmethod(quantile) cln(10) /// draw choropleth map using quintiles
	fcolor("`colors'") ocolor(white ..) osize(0.05 ..) /// use same colour scheme as before
	legend(pos(4)) ///
	legorder(hilo) ///
	label(data("$data\wardlabels.dta") xcoord(x_centroid) ycoord(y_centroid) ///
	label(wardname) size(*0.55 ..)) ///
	legtitle(LQ Manufacturing, 2002)

format lq_serv12 %9.1g	
colorpalette viridis, n(12) nograph reverse
local colors `r(p)'
set scheme white_tableau
spmap lq_serv12 using "$data\hre_chitown_eptown_coor.dta", ///
id(_ID) clmethod(quantile) cln(10) /// draw choropleth map using quintiles
	fcolor("`colors'") ocolor(white ..) osize(0.05 ..) /// use same colour scheme as before
	legend(pos(4)) ///
	legorder(hilo) ///
	label(data("$data\wardlabels.dta") xcoord(x_centroid) ycoord(y_centroid) ///
	label(wardname) size(*0.55 ..)) ///
	legtitle(LQ Services, 2012)

format lq_serv02 %9.1g	
colorpalette viridis, n(12) nograph reverse
local colors `r(p)'
set scheme white_tableau
spmap lq_serv02 using "$data\hre_chitown_eptown_coor.dta", ///
id(_ID) clmethod(quantile) cln(10) /// draw choropleth map using quintiles
	fcolor("`colors'") ocolor(white ..) osize(0.05 ..) /// use same colour scheme as before
	legend(pos(4)) ///
	legorder(hilo) ///
	label(data("$data\wardlabels.dta") xcoord(x_centroid) ycoord(y_centroid) ///
	label(wardname) size(*0.55 ..)) ///
	legtitle(LQ Services, 2002)

	save "$data\wardlevel_data_fin_1", replace

	
	
	
	
	
	


	
	
	
	
	
	
	
	



	


