cd 

*Location Qoutient: explaining patterns of regional specialisation.
egen employment12 =  rowtotal(pd_empl_10 pd_empl__9 pd_empl_11 pd_empl_12) /* creating total employment for 2012-across all sectors*/
egen employment02 = rowtotal(paid_em_12 paid_em_13 paid_em_11 paid_em_14)  /*creating total employment for 2002-across all sectors*/
egen tot_emp = total(employment12) /*total emp12-for all the regions/wards */
egen tot_em = total(employment02) /*total emp02-for all the regions/wards */
	
*Total employment for each sector across all the regions	
	foreach x in pd_empl_10 pd_empl__9 pd_empl_11 pd_empl_12 paid_em_12 paid_em_13 paid_em_11 paid_em_14 {
	egen `x'_tot = total(`x')
	}
	
g shre_agr = pd_empl_10/pd_empl_10_tot	/*share of region i's agricultural employment in 2012  */
g shre_emp = employment12/tot_emp /*share of region i's employment */
g lq_agr = shre_agr/shre_emp /*location quotient (lq) for agriculture */
*
g shre_manu = pd_empl_11/pd_empl_11_tot /*share of region i's manufacturing employment in 2012 */
g lq_man12 = shre_manu/shre_emp /*lq for manufacturing */
*
g shre_serv = pd_empl__9/pd_empl__9_tot /* share of region i's services employment in 2012  */
g lq_serv12 = shre_serv/shre_emp /*lq for manufacturing*/
***

*Lq for 2002
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
*Bar graphs-commands
*Note-you have to save scheme-svg file into the directory you are wotking from or in STATA folder
graph bar agro_industry02 manu02 services02, over(density) scheme(scheme-svg) ///
legend(position(3) col(1) lab(1 "Agro-Industry") lab(2 "Manufacturing") lab(3 "Services")) ///
ytitle("Share of Employment (%)") stack saving(mygraph, replace)
graph bar agro_industry manufacturing services, over(density) scheme(scheme-svg) ///
legend(position(3) col(1) lab(1 "Agro-Industry") lab(2 "Manufacturing") lab(3 "Services")) ///
ytitle("Share of Employment (%)") stack saving(mygraph1, replace)
**
*Generate variables to be used in kernel density-normalise by across region mean
foreach var in pd_empl_12 pd_empl_11 pd_empl__9 paid_em_14 paid_em_13 paid_em_11 {
egen mean_`var' = mean(`var')
} /*across region means for each variable*/

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
**

