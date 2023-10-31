
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

use "$data\wardlevel_data_fin_1", clear
mer 1:1 wardcode using "$data\hre_chitown_eptown_dbase_tome.dta"
keep if _mer == 3
drop _mer
*Create a variable identifying constituency of each ward in 2008
g constituency = "Budiriro" if wardpcod_1 == 192143 | wardpcod_1 == 192133
replace constituency = "Glen View South" if wardpcod_1  == 192132 | wardpcod_1 == 192131
replace constituency = "Glen View North" if wardpcod_1 == 192130
replace constituency = "Glen Norah" if wardpcod_1 == 192128	| wardpcod_1 == 192127
replace constituency = "Highfield East" if wardpcod_1 == 192124 | wardpcod_1 == 192125
replace constituency = "Highfield West" if wardpcod_1 == 192126 | wardpcod_1 == 192129
replace constituency = "Chitungwiza North" if wardpcod_1 == 192217 | wardpcod_1 == 192219 ///
| wardpcod_1 == 192221 
replace constituency = "Chitungwiza South" if wardpcod_1 == 192218 | wardpcod_1 == 192222 ///
| wardpcod_1 == 192223 | wardpcod_1 == 192224
replace constituency = "Dzivarasekwa " if wardpcod_1 == 192139 | wardpcod_1 == 192140
replace constituency = "Epworth" if wardpcod_1 == 192301 | wardpcod_1 == 192302 ///
| wardpcod_1 == 192303 | wardpcod_1 == 192304 | wardpcod_1 == 192305 | wardpcod_1 == 192306 ///
| wardpcod_1 == 192307
replace constituency = "Harare Central" if wardpcod_1 == 192102 | wardpcod_1 == 192106
replace constituency =  "Harare East" if wardpcod_1 == 192108 | wardpcod_1 == 192109 ///
| wardpcod_1 ==192146
replace constituency = "Harare North" if wardpcod_1 == 192118 | wardpcod_1 == 192142 
replace constituency = "Harare West" if wardpcod_1 == 192116 | wardpcod_1 == 192141 
replace constituency = "Hatfield" if wardpcod_1 == 192122 | wardpcod_1 ==  192123
replace constituency = "Kambuzuma" if wardpcod_1 == 192114 | wardpcod_1 == 192136
replace constituency = "Kuwadzana" if wardpcod_1 == 192138 | wardpcod_1 == 192144 ///
| wardpcod_1 == 192145
replace constituency = "Kuwadzana East" if wardpcod_1 == 192137
replace constituency = "Mabvuku_Tafara" if wardpcod_1 == 192119 | wardpcod_1 == 192120 ///
| wardpcod_1 == 192121
replace constituency = "Mbare" if wardpcod_1 == 192103 | wardpcod_1 == 192104
replace constituency = "Mt Pleasant" if wardpcod_1 == 192107 | wardpcod_1 == 192117
replace constituency = "Mufakose" if wardpcod_1 == 192134 | wardpcod_1 == 192135
replace constituency = "Southerton" if wardpcod_1 == 192111 | wardpcod_1 == 192113
replace constituency = "St Mary’s" if wardpcod_1 == 192201 | wardpcod_1 == 192202 ///
| wardpcod_1 == 192203 | wardpcod_1 == 192204 | wardpcod_1 == 192205 | wardpcod_1 == 192208
replace constituency = "Sunningdale" if wardpcod_1 == 192110 | wardpcod_1 == 192112
replace constituency = "Warren Park" if wardpcod_1 == 192115 | wardpcod_1 == 192105
replace constituency = "Zengeza East" if wardpcod_1 == 192213 | wardpcod_1 == 192214 ///
| wardpcod_1 == 192215 | wardpcod_1 == 192216 | wardpcod_1 == 192220
replace constituency = "Zengeza West" if wardpcod_1 == 192206 | wardpcod_1 == 192207 ///
| wardpcod_1 == 192209 | wardpcod_1 == 192210 | wardpcod_1 == 192211 | wardpcod_1 == 192212
replace constituency = "Harare South" if wardpcod_1 == 190101
***
*Data preparation for rent space chart
egen resource_workers = rowtotal(pd_empl_ag pd_empl_mi)
lab var resource_workers "Workers in resource sector"

egen magicians =  rowtotal(pd_empl_in informal_i informal_1)
lab var magicians "manufacturing and industry employees"

g powerbrokers = pd_empl_sr
lab var powerbrokers "work in telecomms, utilities and other infrastructure"

egen workhorses = rowtotal( actwrk_srv actwrk_agr actwrk_a_1 actwrk_ind informal_a informal_s)
lab var workhorses "work as own account and low tier informal enterprises"
***
mer m:1 constituency using "$data\constituency_tomer", nogen
xtile density = popdens12, nq(3)
lab val density density
lab def density 1 "Low density" 2 "Medium density" 3 "High density"
replace marginofvictory = abs(marginofvictory)
preserve
keep wardcode pd_empl_12 pd_empl_11 pd_empl__9 paid_em_14 paid_em_13 paid_em_11 ///
prop_elec_acc12 prop_sanit_acc12 prop_waterimp_acc12 prop_elec_acc02 ///
prop_sanit_acc02 prop_waterimp_acc02 marginofvictory tertiary tertiary02 ///
areakm2_12 areakm2_02 x_centroid y_centroid 
save "$data\political_settlements_infr_emp", replace
restore
***
mer 1:1 wardcode using "$data/wardnames.dta"
drop if _mer == 2
drop _mer
replace wardname = "Harare Rural" if wardcode == "ZW190101"
	
	
**	
*Generate growth rates
g pop_growth = ((pop-pop02)/pop02)*100
g pode_growth = ((popdens12-popdens02)/popdens02)*100  /*pop density growth*/
g emp_ag_ind_gwth = ((pd_empl_12-paid_em_14)/paid_em_14)*100 /*agro-ind growth*/
g emp_man_gwth = ((pd_empl_11-paid_em_13)/paid_em_13)*100 /*man emp growth*/
g emp_serv_grwth = ((pd_empl__9-paid_em_11)/paid_em_11)*100 /*serv growth*/
*Informal employment
g infemp_agind_grwth = ((informal_1-informal_5)/informal_5)*100 /*in agr-ind growth*/
g infemp_man_grwth = ((informal_i-informal_4)/informal_4)*100 /* inf in man*/
g infemp_serv_grwth = ((informal_s-informal_2)/informal_2)*100 /* inf serv growth*/

	
**
egen tot_emp_form12 =  rowtotal(pd_empl_12 pd_empl_11 pd_empl__9)
egen tot_emp_form02 = rowtotal(paid_em_14 paid_em_13 paid_em_11)
egen tot_emp_inf12 =  rowtotal(informal_1 informal_i informal_s)
egen tot_emp_inf02 = rowtotal(informal_5 informal_4 informal_2)
foreach var in  pd_empl_12 pd_empl_11 pd_empl__9 {
g shr_`var' = `var'/tot_emp_form12
}
lab var shr_pd_empl_12 "Share of employment in agro-industry"
lab var shr_pd_empl_11 "Share of employment in manufacturing"
lab var shr_pd_empl__9 "Share of employment in services"
foreach var in  paid_em_14 paid_em_13 paid_em_11 {
g shr02_`var' = `var'/tot_emp_form02
}
lab var shr02_paid_em_14 "Share of employment in agro-industry"
lab var shr02_paid_em_13 "Share of employment in manufacturing" 
lab var shr02_paid_em_11 "Share of employment in services"

foreach var in informal_1 informal_i informal_s { 
g shr_`var' = `var'/tot_emp_inf12
}
lab var shr_informal_1 "Share of informal employment in agro-industry"
lab var shr_informal_i "Share of informal employment in manufacturing" 
lab var shr_informal_s "Share of informal employment in services"

foreach var in informal_5 informal_4 informal_2 {
g shr02_`var' = `var'/tot_emp_inf02 
}
lab var shr02_informal_5 "Share of informal employment in agro-industry"
lab var shr02_informal_4 "Share of informal employment in manufacturing"
lab var shr02_informal_2 "Share of informal employment in services"
ren (shr_pd_empl_12 shr_pd_empl_11 shr_pd_empl__9) (agro_industry manufacturing services)
ren (shr02_paid_em_14 shr02_paid_em_13 shr02_paid_em_11) (agro_industry02 manu02 services02)

g shr_growth_agro = ((agro_industry-agro_industry02)/agro_industry02)*100
g shr_growth_man = ((manufacturing-manu02)/manu02)*100
g shr_growth_serv = ((services-services02)/services02)*100

g shr_gwth_agro_inf = ((shr_informal_1-shr02_informal_5)/shr02_informal_5)*100
g shr_gwth_man_inf = ((shr_informal_i-shr02_informal_4)/shr02_informal_4)*100
g shr_gwth_serv_inf = ((shr_informal_s-shr02_informal_2)/shr02_informal_2)*100

*Growth in female employment
g formal_emp_fem_ser12 = pd_empl__1
egen inf_emp_fe_ser12 = rowtotal(actwrk_s_1 unpd_fam_1)
g formal_emp_fem_ind12 = pd_empl__3
egen inf_emp_fe_ind12 = rowtotal(actwrk_i_1 unpd_fam_5)
g formal_emp_fem_agro12 = pd_empl__5
egen inf_emp_fe_agro12 = rowtotal(actwrk_a_3 unpd_fam_7)
*2002
g formal_emp_fem_ser02 = paid_empl1
egen inf_emp_fe_ser02 = rowtotal(actwrk_s_4 unpaid_f_1)
g formal_emp_fem_ind02 = paid_emp_4
egen inf_emp_fe_ind02 = rowtotal(actwrk_i_4 unpaid_f_5)
g formal_emp_fem_agro02 = paid_emp_6
egen inf_emp_fe_agro02 = rowtotal(actwrk_a_9 unpaid_f_7)

*Formal growth
g growth_ser_fem = ((formal_emp_fem_ser12-formal_emp_fem_ser02)/formal_emp_fem_ser02)*100
g growth_ind_fem = ((formal_emp_fem_ind12-formal_emp_fem_ind02)/formal_emp_fem_ind02)*100
g growth_agro_fem = ((formal_emp_fem_agro12-formal_emp_fem_agro02)/formal_emp_fem_agro02)*100
*Informal growth
g igrowth_ser_fem = ((inf_emp_fe_ser12-inf_emp_fe_ser02)/inf_emp_fe_ser02)*100
g igrowth_ind_fem = ((inf_emp_fe_ind12-inf_emp_fe_ind02)/inf_emp_fe_ind02)*100
g igrowth_agro_fem = ((inf_emp_fe_agro12-inf_emp_fe_agro02)/inf_emp_fe_agro02)*100

foreach var in agro_industry manufacturing services agro_industry02 manu02 services02 {
replace `var' = `var'*100
}

for var emp_ag_ind_gwth emp_man_gwth emp_serv_grwth infemp_agind_grwth ///
infemp_man_grwth infemp_serv_grwth: replace X = . if wardcode == "ZW190101"
for var emp_ag_ind_gwth emp_man_gwth emp_serv_grwth infemp_agind_grwth ///
infemp_man_grwth infemp_serv_grwth: sum X, d
winsor2 emp_ag_ind_gwth if emp_ag_ind_gwth!=., replace cuts(1 90)
winsor2 emp_man_gwth if emp_man_gwth!=., replace cuts(1 95)
winsor2 emp_serv_grwth if emp_serv_grwth!=., replace cuts(1 90)
winsor2 infemp_agind_grwth if infemp_agind_grwth!=., replace cuts(1 90)
winsor2 infemp_man_grwth if infemp_man_grwth!=., replace cuts(1 95)
winsor2 infemp_serv_grwth if infemp_serv_grwth!=., replace cuts(1 95)
**
winsor2 shr_growth_agro if shr_growth_agro!=., replace cuts(1 90)
winsor2 growth_ser_fem if growth_ser_fem!=., replace cuts(5 90)
winsor2 growth_ind_fem if growth_ser_fem!=., replace cuts(5 95)
winsor2 growth_agro_fem if growth_agro_fem!=., replace cuts(5 90)
winsor2 igrowth_ser_fem if igrowth_ser_fem!=., replace cuts(5 90)
winsor2 igrowth_ind_fem if igrowth_ind_fem!=., replace cuts(5 90)
winsor2 igrowth_agro_fem if igrowth_agro_fem!=., replace cuts(10 90)

preserve
keep pop_growth-infemp_serv_grwth shr_growth_agro shr_growth_man shr_growth_serv ///
growth_ser_fem growth_ind_fem growth_agro_fem igrowth_ser_fem igrowth_ind_fem ///
igrowth_agro_fem shr_gwth_agro_inf shr_gwth_man_inf shr_gwth_serv_inf
save "$data\growthrates", replace
restore



//cd "C:\Users\Mahofa\OneDrive - University of Cape Town\CurrentWork\UNU_WIDER_African_Cities\data"
*Across region spatial distribution of changes in employment by sector

replace emp_ag_ind_gwth = round(emp_ag_ind_gwth,1)
colorpalette viridis, n(12) nograph reverse
local colors `r(p)'
set scheme white_tableau
spmap emp_ag_ind_gwth using "$data\hre_chitown_eptown_coor.dta", id(_ID) ///
	clmethod(quantile) cln(10) /// draw choropleth map using quintiles
	fcolor("`colors'") ocolor(white ..) osize(0.05 ..) /// use same colour scheme as before
	legend(pos(4) size(2.8) region(fcolor(gs15))) ///
	/*ocolor(none) osize(vvthin)*/  ///
	legorder(hilo) ///
	legstyle(2) ///
	label(data("$data\wardlabels.dta") xcoord(x_centroid) ycoord(y_centroid) ///
	label(wardname) size(*0.55 ..)) ///
	legtitle(Agro-Industry)
	
replace emp_man_gwth = round(emp_man_gwth,1)
colorpalette viridis, n(12) nograph reverse
local colors `r(p)'
set scheme white_tableau
spmap emp_man_gwth using "$data\hre_chitown_eptown_coor.dta", id(_ID) ///
	clmethod(quantile) cln(10) /// draw choropleth map using quintiles
	fcolor("`colors'") ocolor(white ..) osize(0.05 ..) /// use same colour scheme as before
	legend(pos(4)) ///
	legorder(hilo) ///
	label(data("$data\wardlabels.dta") xcoord(x_centroid) ycoord(y_centroid) ///
	label(wardname) size(*0.55 ..)) ///
	legtitle(Manufacturing)

replace emp_serv_grwth = round(emp_serv_grwth,1)
colorpalette viridis, n(12) nograph reverse
local colors `r(p)'
set scheme white_tableau
spmap emp_serv_grwth using "$data\hre_chitown_eptown_coor.dta", id(_ID) ///
	clmethod(quantile) cln(10) /// draw choropleth map using quintiles
	fcolor("`colors'") ocolor(white ..) osize(0.05 ..) /// use same colour scheme as before
	legend(pos(4)) ///
	legorder(hilo) ///
	label(data("$data\wardlabels.dta") xcoord(x_centroid) ycoord(y_centroid) ///
	label(wardname) size(*0.55 ..)) ///
	legtitle(Services)

	replace infemp_agind_grwth = round(infemp_agind_grwth,1)
colorpalette viridis, n(12) nograph reverse
local colors `r(p)'
set scheme white_tableau
spmap infemp_agind_grwth using "$data\hre_chitown_eptown_coor.dta", id(_ID) ///
	clmethod(quantile) cln(10) /// draw choropleth map using quintiles
	fcolor("`colors'") ocolor(white ..) osize(0.05 ..) /// use same colour scheme as before
	legend(pos(4)) ///
	legorder(hilo) ///
	label(data("$data\wardlabels.dta") xcoord(x_centroid) ycoord(y_centroid) ///
	label(wardname) size(*0.55 ..)) ///
	legtitle(Agro-Industry)
	
	replace infemp_man_grwth = round(infemp_man_grwth,1)
colorpalette viridis, n(12) nograph reverse
local colors `r(p)'
set scheme white_tableau
spmap infemp_man_grwth using "$data\hre_chitown_eptown_coor.dta", id(_ID) ///
	clmethod(quantile) cln(10) /// draw choropleth map using quintiles
	fcolor("`colors'") ocolor(white ..) osize(0.05 ..) /// use same colour scheme as before
	legend(pos(4)) ///
	legorder(hilo) ///
	label(data("$data\wardlabels.dta") xcoord(x_centroid) ycoord(y_centroid) ///
	label(wardname) size(*0.55 ..)) ///
	legtitle(Manufacturing)
	
	replace infemp_serv_grwth = round(infemp_serv_grwth,1)
colorpalette viridis, n(12) nograph reverse
local colors `r(p)'
set scheme white_tableau
spmap infemp_serv_grwth using "$data\hre_chitown_eptown_coor.dta", id(_ID) ///
	clmethod(quantile) cln(10) /// draw choropleth map using quintiles
	fcolor("`colors'") ocolor(white ..) osize(0.05 ..) /// use same colour scheme as before
	legend(pos(4)) ///
	legorder(hilo) ///
	label(data("$data\wardlabels.dta") xcoord(x_centroid) ycoord(y_centroid) ///
	label(wardname) size(*0.55 ..)) ///
	legtitle(Services)


graph bar agro_industry02 manu02 services02, over(density) scheme(scheme-svg) ///
legend(position(3) col(1) lab(1 "Agro-Industry") lab(2 "Manufacturing") lab(3 "Services")) ///
ytitle("Share of Employment (%)") stack saving(mygraph, replace)
graph bar agro_industry manufacturing services, over(density) scheme(scheme-svg) ///
legend(position(3) col(1) lab(1 "Agro-Industry") lab(2 "Manufacturing") lab(3 "Services")) ///
ytitle("Share of Employment (%)") stack saving(mygraph1, replace)

ren(shr_informal_1 shr_informal_i shr_informal_s shr02_informal_5 ///
shr02_informal_4 shr02_informal_2) (inf_agro_ind inf_manu inf_services inf_agr_ind02 ///
inf_man02 inf_services02)
foreach var in inf_agro_ind inf_manu inf_services inf_agr_ind02 inf_man02 ///
inf_services02 { 
replace `var' = `var'*100
}
*Informal Employment
graph bar inf_agr_ind02 inf_man02 inf_services02, over(density) scheme(scheme-svg) ///
legend(position(3) col(1) lab(1 "Agro-Industry") lab(2 "Manufacturing") lab(3 "Services")) ///
ytitle("Share of Employment (%)") stack saving(mygraph2, replace)
graph bar inf_agro_ind inf_manu inf_services, over(density) scheme(scheme-svg) ///
legend(position(3) col(1) lab(1 "Agro-Industry") lab(2 "Manufacturing") lab(3 "Services")) ///
ytitle("Share of Employment (%)") stack saving(mygraph3, replace)
foreach var in pd_empl_12 pd_empl_11 pd_empl__9 paid_em_14 paid_em_13 paid_em_11 {
egen mean_`var' = mean(`var')
}
g rel_ag_ind = pd_empl_12/mean_pd_empl_12
g rel_manu = pd_empl_11/mean_pd_empl_11
g rel_services = pd_empl__9/mean_pd_empl__9

g rel_ag_ind02 = paid_em_14/mean_paid_em_14
g rel_manu02 = paid_em_13/mean_paid_em_13
g rel_services02 = paid_em_11/mean_paid_em_11
keep wardcode rel_ag_ind-rel_services02
ren (rel_ag_ind rel_manu rel_services rel_ag_ind02 rel_manu02 rel_services02) ///
(ag2012 manu2012 services2012 ag2002 manu2002 services2002)
reshape long ag manu services, i(wardcode) j(year)
*Kdensity
kdensity ag, nogr gen(x fx)
kdensity ag if year == 2002, nogr gen(fx0) at(x)
kdensity ag if year == 2012, nogr gen(fx1) at(x)
lab var fx0 "2002"
lab var fx1 "2012"
line fx0 fx1 x, sort lpattern("l" "-") ytitle(Density) xtitle(x) ///
legend(lab(1 "kdensityrelagind02") lab(2 "kdensityrelagind12")) saving(agroind, replace)
drop fx x fx0 fx1

kdensity manu, nogr gen(x fx)
kdensity manu if year == 2002, nogr gen(fx0) at(x)
kdensity manu if year == 2012, nogr gen(fx1) at(x)
lab var fx0 "2002"
lab var fx1 "2012"
line fx0 fx1 x, sort lpattern("l" "-") ytitle(Density) xtitle(x) ///
legend(lab(1 "kdensityrelmanu02") lab(2 "kdensityrelmanu12")) saving(manu, replace)
drop fx x fx0 fx1

kdensity services, nogr gen(x fx)
kdensity services if year == 2002, nogr gen(fx0) at(x)
kdensity services if year == 2012, nogr gen(fx1) at(x)
lab var fx0 "2002"
lab var fx1 "2012"
line fx0 fx1 x, sort lpattern("l" "-") ytitle(Density) xtitle(x) ///
legend(lab(1 "kdensityrelservices02") lab(2 "kdensityrelservices12")) saving(services, replace)
drop fx x fx0 fx1
*****
*World bank enterprise data
use "C:\Users\Mahofa\OneDrive - University of Cape Town\CurrentWork\AERC\AERC_Growth_Fragile\data\firm_obstacles.dta", clear
keep if region==2
keep ele_obstacle panelid year telecomms transport customs e30 g30a i30 j30a ///
j30b j30c j30e corru h30 l30a l30b k30
ren (ele_obstacle telecomms transport customs e30 g30a i30 j30a j30b j30c j30e ///
corru h30 l30a l30b k30) (obst obst1 obst2 obst3 obst4 obst5 obst6 obst7 obst8 ///
obst9 obst10 obst11 obst12 obst13 obst14 obst15)
for var obst-obst14: recode X (0/2=0) (3/4=1)
ren obst obst0
reshape long obst, i( panelid year) j(j)
replace obst = 0 if obst == -9 | obst == -7

lab val j j
lab def j 0 "Access to electricity" 1 "Access to telcomms" 2 "Transportation" 3 ///
 "Customs and Trade" 4 "Informal sector competition" 5 "Access to land" ///
 6 "Crime, Theft and Disorder" 7 "Tax rates" 8 "Tax adminstration" ///
 9 "Business Licensing and Permits" 10 "Political Instability" 11 "Corruption" ///
 12 "Courts" 13 "Labour regulations" 14 "Lack of skills"
 lab def j 15 "Access to finance", add

tostring obst, g(obst1)
drop obst
g obst = real(obst1)
drop obst1
replace obst = obst*100
 graph hbar obst, over(year) over(j) ytitle(Percent of firms) asyvars scheme(scheme-svg)
***
 use "$data\political_settlements_infr_emp", clear
 mer 1:1 wardcode using "$data\shares", nogen
 ren (pd_empl__9 pd_empl_11 pd_empl_12 paid_em_11 paid_em_13 paid_em_14 tertiary tertiary02) ///
 (services2012 manu2012 agro2012 services2002 manu2002 agro2002 tertiary2012 tertiary2002)
 ren (prop_elec_acc12 prop_sanit_acc12 prop_waterimp_acc12 prop_elec_acc02 ///
 prop_sanit_acc02 prop_waterimp_acc02) (elec2012 sanit2012 water2012 elec2002 ///
 sanit2002 water2002)
 ren (areakm2_12 areakm2_02) (areakm22012 areakm22002)
 ren (agro_industry manufacturing services agro_industry02 manu02 services02) ///
 (agroshr2012 manushr2012 svsshre2012 agroshr2002 manushr2002 svsshre2002)
 ren (shr_informal_1 shr_informal_i shr_informal_s shr02_informal_5 shr02_informal_4 shr02_informal_2) ///
 (agr_i_shr2012 man_i_shr2012 svs_i_shr2012 agr_i_shr2002 man_i_shr2002 svs_i_shr2002)
 reshape long areakm2 manu agro services elec sanit water tertiary agroshr ///
 manushr svsshre agr_i_shr man_i_shr svs_i_shr, i(wardcode) j(year)
 ren marginofvictory marginv2008
 
 
 
 *SCATTER PLOTS
 //twoway (scatter  manu marginv2008) (lfit manu marginv2008) if year==2012
 
twoway (scatter  manu marginv2008, ms(oh)) (lfit manu marginv2008) if year==2012,  ///
ytitle("Employment in manufacturing", size(medsmall)) xtitle("Margin of Victory(%)") legend(off) /*scheme(scheme-svg)*/ saving(poli_comp, replace)

twoway (scatter  manushr marginv2008, ms(oh)) (lfit manushr marginv2008) if year==2012,  ///
ytitle("Share of employment in manufacturing", size(medsmall)) xtitle("Margin of Victory(%)") legend(off) /*scheme(scheme-svg)*/ saving(poli_comp, replace)

twoway (scatter  svsshre marginv2008, ms(oh)) (lfit svsshre marginv2008) if year==2012,  ///
ytitle("Share of employment in Services", size(medsmall)) xtitle("Margin of Victory(%)") legend(off) /*scheme(scheme-svg)*/ saving(poli_comp_svs, replace)

twoway (scatter  services marginv2008, ms(oh)) (lfit services marginv2008) if year==2012,  ///
ytitle("Employment in Services", size(medsmall)) xtitle("Margin of Victory(%)") legend(off) /*scheme(scheme-svg)*/ saving(poli_comp_svs, replace)

twoway (scatter  agro marginv2008, ms(oh)) (lfit agro marginv2008) if year==2012,  ///
ytitle("Employment in Agro-Industry", size(medsmall)) xtitle("Margin of Victory(%)") legend(off) /*scheme(scheme-svg)*/ saving(poli_comp_agro, replace)

twoway (scatter  agroshr marginv2008, ms(oh)) (lfit agroshr marginv2008) if year==2012,  ///
ytitle("Employment in Agro-Industry", size(medsmall)) xtitle("Margin of Victory(%)") legend(off) /*scheme(scheme-svg)*/ saving(poli_comp_agro, replace)

egen water_sanit = rowmean(sanit water)
drop sanit water
twoway (scatter  water_sanit marginv2008, ms(oh)) (lfit water_sanit marginv2008) if year==2012,  ///
ytitle("Water and Sanitation", size(medsmall)) legend(off) /*scheme(scheme-svg)*/ saving(poli_comp_water_sanit, replace) 

twoway (scatter  elec marginv2008, ms(oh)) (lfit elec marginv2008) if year==2012,  ///
ytitle("Electricity", size(medsmall)) xtitle("Margin of Victory(%)") legend(off) /*scheme(scheme-svg)*/ saving(poli_comp_water_sanit, replace) 

for var elec water_sanit tertiary: replace X = X*100
*Access to electricity
twoway (scatter agro elec, ms(oh)) (lfit agro elec) ,  ///
ytitle("Employment in agro-industry", size(medsmall)) xtitle("Access to electricity(%)") legend(off) /*scheme(scheme-svg)*/  

twoway (scatter agroshr elec, ms(oh)) (lfit agroshr elec) ,  ///
ytitle("Share of employment in agro-industry", size(medsmall)) xtitle("Access to electricity(%)") legend(off) /*scheme(scheme-svg)*/  

twoway (scatter services elec, ms(oh)) (lfit services elec) ,  ///
ytitle("Employment in services", size(medsmall)) xtitle("Access to electricity(%)") legend(off) /*scheme(scheme-svg)*/  

twoway (scatter svsshre elec, ms(oh)) (lfit svsshre elec) ,  ///
ytitle("Share of employment in services", size(medsmall)) xtitle("Access to electricity(%)") legend(off) /*scheme(scheme-svg)*/  

twoway (scatter manushr elec, ms(oh)) (lfit manushr elec),  ///
ytitle("Share of employment in manufacturing", size(medsmall)) xtitle("Access to electricity(%)") legend(off) /*scheme(scheme-svg)*/  

*Access to water and sanitation
twoway (scatter agro water_sanit, ms(oh)) (lfit agro water_sanit) ,  ///
ytitle("Employment in agro-industry", size(medsmall)) xtitle("Access to water and Sanitation(%)") legend(off) /*scheme(scheme-svg)*/  

twoway (scatter agroshr water_sanit, ms(oh)) (lfit agroshr water_sanit) ,  ///
ytitle("Share of employment in agro-industry", size(medsmall)) xtitle("Access to water and Sanitation(%)") legend(off) /*scheme(scheme-svg)*/  

twoway (scatter services water_sanit, ms(oh)) (lfit services water_sanit) ,  ///
ytitle("Employment in services", size(medsmall)) xtitle("Access to water and Sanitation(%)") legend(off) /*scheme(scheme-svg)*/  

twoway (scatter svsshre water_sanit, ms(oh)) (lfit svsshre water_sanit) ,  ///
ytitle("Share of employment in services", size(medsmall)) xtitle("Access to water and Sanitation(%)") legend(off) /*scheme(scheme-svg)*/  
 
twoway (scatter manu water_sanit, ms(oh)) (lfit manu water_sanit) ,  ///
ytitle("Employment in manufacturing", size(medsmall)) xtitle("Access to water and Sanitation(%)") legend(off) /*scheme(scheme-svg)*/  

twoway (scatter manushr water_sanit, ms(oh)) (lfit manushr water_sanit) ,  ///
ytitle("Share of employment in manufacturing", size(medsmall)) xtitle("Access to water and Sanitation(%)") legend(off) /*scheme(scheme-svg)*/  

*Education
twoway (scatter agro tertiary, ms(oh)) (lfit agro tertiary) ,  ///
ytitle("Employment in agro-industry", size(medsmall)) xtitle("Access to tertiary education(%)") legend(off) /*scheme(scheme-svg)*/  

twoway (scatter agroshr tertiary, ms(oh)) (lfit agroshr tertiary) ,  ///
ytitle("Share of employment in agro-industry", size(medsmall)) xtitle("Access to tertiary education(%)") legend(off) /*scheme(scheme-svg)*/  

twoway (scatter manu tertiary, ms(oh)) (lfit manu tertiary) ,  ///
ytitle("Employment in manufacturing", size(medsmall)) xtitle("Access to tertiary education(%)") legend(off) /*scheme(scheme-svg)*/  

twoway (scatter manushr tertiary, ms(oh)) (lfit manushr tertiary) ,  ///
ytitle("Share of employment in manufacturing", size(medsmall)) xtitle("Access to tertiary education(%)") legend(off) /*scheme(scheme-svg)*/  


twoway (scatter services tertiary, ms(oh)) (lfit services tertiary) ,  ///
ytitle("Employment in services", size(medsmall)) xtitle("Access to tertiary education(%)") legend(off) /*scheme(scheme-svg)*/  

twoway (scatter svsshre tertiary, ms(oh)) (lfit svsshre tertiary) ,  ///
ytitle("Share of employment in services", size(medsmall)) xtitle("Access to tertiary education(%)") legend(off) /*scheme(scheme-svg)*/  


egen wardcode1 = group(wardcode)
xtset wardcode1 year
for var services manu agro tertiary: g lnX = ln(1+X)
for var areakm2 elec water_sanit marginv2008: g lnX = ln(X)
eststo: qui xtreg lnagro lntertiary lnelec lnwater_sanit lnareakm2 i.year, fe cluster(wardcode)
eststo: qui xtreg lnmanu lntertiary lnelec lnwater_sanit lnareakm2 i.year, fe cluster(wardcode)
eststo: qui xtreg lnservices lntertiary lnelec lnwater_sanit lnareakm2 i.year, fe cluster(wardcode)
esttab using "$output\regression.doc", se rtf replace starlevels( * 0.10 ** 0.05 *** 0.010) nodep ///
stats(N r2)  title({\b Table 2 :}{Panel regression analysis of employment and infrastructure}) ///
varlabels(lntertiary "Log of tertiary education" ///
lnelec "Log of access to electricity" ///
lnwater_sanit "Log of access to water and improved sanitation" ///
lnareakm2 "Log of area in km2")
eststo clear
****
*Productivity Analysis
use "C:\Users\Mahofa\OneDrive - University of Cape Town\CurrentWork\AERC\AERC_Growth_Fragile\data\firm_analysis.dta", clear
 winsor2 lp if lp!=., replace cuts(1 85)
 
 inspect lp
 g ln_lp = ln(lp)
kdensity ln_lp, nogr gen(x fx)
kdensity ln_lp if year == 2011, nogr gen(fx0) at(x)
kdensity ln_lp if year == 2016, nogr gen(fx1) at(x)
lab var fx0 "2011"
lab var fx1 "2016"
line fx0 fx1 x, sort lpattern("l" "-") ytitle(Density) xtitle(x) ///
legend(lab(1 "kdensitylp11") lab(2 "kdensitylp16")) saving(productivity, replace)
drop fx x fx0 fx1

