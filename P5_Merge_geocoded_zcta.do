/****
Project: CHCF NAS
Written by: Marni Epstein

Purpose: Merge driving distance times and distances for ZCTAs from the 9 separate CSVs. Output combined data.

Notes:
	- Time in seconds, distance in meters
	- Driving distances/times are by ZCTA. Original NAS data comes in by zip code.
******/

set type double
cd "D:\Users\MEpstein\Box Sync\2017 OUD NAS CHCF\3 Data\SAMHSA OTP provider locations\Created datafiles"

gl excel "D:\Users\MEpstein\Box Sync\2017 OUD NAS CHCF\5 Treatment gaps\Tables\ZCTA Final Report Tables"


*Read in data with incidence rates
use "ca_zcta.dta", clear

*1 Merge bup
tempfile temp1
save "`temp1'"
import delimited using "zcta_bup_geodrive.csv", varnames(1) clear
merge 1:m zcta using "`temp1'"
sort zcta period
drop _m

*2 Merge otp
tempfile temp2
save "`temp2'"
import delimited using "zcta_otp_geodrive.csv", varnames(1) clear
merge 1:m zcta using "`temp2'"
sort zcta period
drop _m

*3 Merge inpatient
tempfile temp3
save "`temp3'"
import delimited using "zcta_ip_geodrive.csv", varnames(1) clear
merge 1:m zcta using "`temp3'"
sort zcta period
drop _m

*4 Merge residential
tempfile temp4
save "`temp4'"
import delimited using "zcta_res_geodrive.csv", varnames(1) clear
merge 1:m zcta using "`temp4'"
sort zcta period
drop _m

*5 Merge pregnancy
tempfile temp5
save "`temp5'"
import delimited using "zcta_preg_geodrive.csv", varnames(1) clear
merge 1:m zcta using "`temp5'"
sort zcta period
drop _m

*6 Merge outpatient
tempfile temp6
save "`temp6'"
import delimited using "zcta_op_geodrive.csv", varnames(1) clear
merge 1:m zcta using "`temp6'"
sort zcta period
drop _m

*7 Merge pregnancy - residential
tempfile temp7
save "`temp7'"
import delimited using "zcta_preg_res_geodrive.csv", varnames(1) clear
merge 1:m zcta using "`temp7'"
sort zcta period
drop _m

*8 Merge pregnancy - otp
tempfile temp8
save "`temp8'"
import delimited using "zcta_preg_otp_geodrive.csv", varnames(1) clear
merge 1:m zcta using "`temp8'"
sort zcta period
drop _m

*9 Merge pregnancy - outpatient
tempfile temp9
save "`temp9'"
import delimited using "zcta_preg_op_geodrive.csv", varnames(1) clear
merge 1:m zcta using "`temp9'"
sort zcta period
drop _m

order zcta period nas_a nas_b nas_ab nas_a_brt nas_b_brt nas_ab_brt drug_ed drug_ip drugdep births newborns zlat zlon

label variable zlat "ZCTA centroid latitude"
label variable zlon "ZCTA centroid longitude"

*Keep all time period data

* NAS rates
gen a_brthrt = nas_a / births * 1000 
gen b_brthrt = nas_b / births * 1000
gen ab_brthrt = nas_ab / births * 1000

gen a_newbrnrt = nas_a / newborns * 1000
gen b_newbrnrt = nas_b / newborns * 1000
gen ab_newbrnrt = nas_ab / newborns * 1000

// gen drug_ed_rt = drug_ed / pop * 1000
// gen drug_ip_rt = drug_ip / pop * 1000
gen drugdep_rt = drugdep / births * 1000

label variable a_brthrt "nas_a (ICD 779.5 or P961) / 1000 births"
label variable b_brthrt "nas_b (ICD 770.72 or P04.49) / 1000 births"
label variable ab_brthrt "nas_a or nas_b / 1000 births"
label variable a_newbrnrt "nas_a (ICD 779.5 or P961) / 1000 newborn hospitalizations"
label variable b_newbrnrt "nas_b (ICD 770.72 or P04.49) / 1000 newborn hospitalizations"
label variable ab_newbrnrt "nas_a or nas_b / 1000 newborn hospitalizations"
// label variable drug_ed_rt "ER OUD Incidence / 1000 women 15-44" 
// label variable drug_ip_rt "IP OUD Incidence / 1000 women 15-44" 
label variable drugdep_rt "Maternal drug dependency / 1000 births"


*Convert driving distances from meters to miles and time from secons to minutes

foreach var of varlist lowtime1_preg lowtime2_preg lowtime3_preg ///
						lowtime1_res lowtime2_res lowtime3_res ///
						lowtime1_ip lowtime2_ip lowtime3_ip ///
						lowtime1_otp lowtime2_otp lowtime3_otp ///
						lowtime1_bup lowtime2_bup lowtime3_bup ///
						lowtime1_op lowtime2_op lowtime3_op ///
						lowtime1_preg_res lowtime2_preg_res lowtime3_preg_res ///
						lowtime1_preg_otp lowtime2_preg_otp lowtime3_preg_otp ///
						lowtime1_preg_op lowtime2_preg_op lowtime3_preg_op {
	replace `var' = `var' / 60 //seconds to minutes
}

foreach var of varlist lowdist1_preg lowdist2_preg lowdist3_preg ///
						lowdist1_res lowdist2_res lowdist3_res ///
						lowdist1_ip lowdist2_ip lowdist3_ip ///
						lowdist1_otp lowdist2_otp lowdist3_otp ///
						lowdist1_bup lowdist2_bup lowdist3_bup ///
						lowdist1_op lowdist2_op lowdist3_op ///
						lowdist1_preg_res lowdist2_preg_res lowdist3_preg_res ///
						lowdist1_preg_otp lowdist2_preg_otp lowdist3_preg_otp ///
						lowdist1_preg_op lowdist2_preg_op lowdist3_preg_op {
	replace `var' = `var' / 1609.344 // meters to miles
}



*Sort on nas_a rate / births and export all nas rates
*sort a_brthrt pcounty
*export excel pcounty a_brthrt b_brthrt ab_brthrt a_newbrnrt b_newbrnrt ab_newbrnrt drug_ed_rt drug_ip_rt drugdep_rt using "NAS rates.xlsx", firstrow(varlabels) sheetmodify

/*************
Add in how many bup prescribers are at the 3 closest bup locations
*************/

*Closest 1
rename closetreatid1 treatid

merge m:1 treatid using "bup_trt_loc_with_id"
keep if _m==3
drop _m

rename treatid closetreatid1 
rename numbupprx numbupprx1

*Closest 2
rename closetreatid2 treatid

merge m:1 treatid using "bup_trt_loc_with_id"
keep if _m==3
drop _m

rename treatid closetreatid2
rename numbupprx numbupprx2

*Closest 3
rename closetreatid3 treatid

merge m:1 treatid using "bup_trt_loc_with_id"
keep if _m==3
drop _m

rename treatid closetreatid3
rename numbupprx numbupprx3

*Label numbupprx variables
label variable numbupprx1 "Number of bup prescribers at the closest facility"
label variable numbupprx2 "Number of bup prescribers at the second closest facility"
label variable numbupprx3 "Number of bup prescribers at the third closest facility"

label variable closetreatid1 "TreatID of the closest bup facility"
label variable closetreatid2 "TreatID of the second closest bup facility"
label variable closetreatid3 "TreatID of the third closest bup facility"

*Drop latitude/longitude variables from the bup file. THese are lat/longs of the prescribers
drop latitude longitude 

/*********************************************
Merge ZCTA to county crosswalk
*********************************************/
tempfile temp1
save "`temp1'"

gl crosswalk "D:\Users\MEpstein\Box Sync\2017 OUD NAS CHCF\3 Data\Geographic Crosswalks"

use "${crosswalk}/zip_zcta_county_crosswalk.dta", clear
rename zcta_name zcta
destring  zcta, replace

*Collapse to ZCTA level, it comes in at the zip code level
duplicates drop zcta county, force

*Check if there's any duplicate ZCTAs
duplicates report zcta

*Merge with our NAS/driving data
merge 1:m zcta using "`temp1'"

keep if _m==3
drop _m

*Drop variables from the crosswalk that we don't need anymore
drop ZIP_CODE splitZCTA Zip_join_type ZPOPPCT 
rename COUNTY countyfips
label variable countyname "County name"


*Save final file with all years periods
save "ca_zcta_geodrive.dta", replace
export delimited "ca_zcta_geodrive.csv", replace


/********************************
Print tables of driving distances
*********************************/
use "ca_zcta_geodrive.dta", clear

*Only keep the longest period, since we aren't showing NAS rates and it will keep the most ZCTAs in
keep if period == "2005-2016"

*Sort on county and zcta. Export zip list and copy and paste into final table, since we can't use matrices with a string variable
sort countyname zcta 
*export excel countyname zcta  using "${excel}/county-zcta ordered.xlsx", replace firstrow(variables)



/****************************************
*Output driving times and miles to table
****************************************/

gl exceloutput "${excel}/ZCTA driving distances v1.xlsx"

set matsize 2000

*Print all but bup
foreach cat in  res ip otp op preg preg_res preg_otp preg_op {

	putexcel set "$exceloutput", modify sheet("`cat'")

	*Average of the three closest facilities
	egen lowtimeavg_`cat' = rowmean(lowtime1_`cat' lowtime2_`cat' lowtime3_`cat')
	egen lowdistavg_`cat' = rowmean(lowdist1_`cat' lowdist2_`cat' lowdist3_`cat')
	
	*mkmat pcounty 
	mkmat zcta
	mkmat lowtime1_`cat'
	mkmat lowdist1_`cat'	
	mkmat lowtime2_`cat'
	mkmat lowdist2_`cat'
	mkmat lowtime3_`cat'
	mkmat lowdist3_`cat'
	mkmat lowtimeavg_`cat'
	mkmat lowdistavg_`cat'
		  
	mat def outtable_`cat' = (zcta, lowtime1_`cat', lowdist1_`cat', lowtime2_`cat', lowdist2_`cat', lowtime3_`cat', lowdist3_`cat', lowtimeavg_`cat', lowdistavg_`cat')
	putexcel B5 = matrix(outtable_`cat')
}                                                 
                                                  
* Bup
foreach cat in bup  {

	putexcel set "$exceloutput", modify sheet("`cat'")

	*Average of the three closest facilities
	egen lowtimeavg_`cat' = rowmean(lowtime1_`cat' lowtime2_`cat' lowtime3_`cat')
	egen lowdistavg_`cat' = rowmean(lowdist1_`cat' lowdist2_`cat' lowdist3_`cat')
	
	*mkmat pcounty 
	mkmat zcta
	mkmat lowtime1_`cat'
	mkmat lowdist1_`cat'
	mkmat numbupprx1
	mkmat lowtime2_`cat'
	mkmat lowdist2_`cat'
	mkmat numbupprx2
	mkmat lowtime3_`cat'
	mkmat lowdist3_`cat'
	mkmat numbupprx3
	mkmat lowtimeavg_`cat'
	mkmat lowdistavg_`cat'
		  
	mat def outtable_`cat' = (zcta, lowtime1_`cat', lowdist1_`cat', numbupprx1, lowtime2_`cat', lowdist2_`cat', numbupprx2, ///
							lowtime3_`cat', lowdist3_`cat', numbupprx3, lowtimeavg_`cat', lowdistavg_`cat')
	putexcel B5 = matrix(outtable_`cat')
}                                                 
                                                  
/***************************************************
Save with avg driving time/distance of the top 3, and only one entry per ZCTA to map
****************************************************/
export delimited "ca_zcta_tomap.csv", replace


		  
/***********************************************
Export table for Maternal Taskforce Meeting
***********************************************/		  
/*

*Sort on county. Export county list and copy and paste into final table, since we can't use putexcel with a string variable
sort countyname ab_brthrt 
export excel countyname patzip ab_brthrt using "${excel}/county-zips ordered ab_brthrt.xlsx", replace firstrow(variables)

set matsize 2000

gl excelmaternal "D:\Users\MEpstein\Box Sync\2017 OUD NAS CHCF\5 Treatment gaps\Tables\Zip summary table Maternal Taskforce.xlsx"
putexcel set "$excelmaternal", modify

*Turn each variable into matrix
foreach var in ab_brthrt lowtimeavg_preg lowtimeavg_preg_otp lowtimeavg_preg_res lowtimeavg_preg_op lowtimeavg_bup {
	mkmat `var'
}

*Create matrix to print
mat def sumtable = (ab_brthrt, lowtimeavg_preg, lowtimeavg_preg_otp, lowtimeavg_preg_res, lowtimeavg_preg_op, lowtimeavg_bup)
		  
*Print to excel
putexcel C5 = matrix(sumtable)
		  
		  
		  
		  
	  

/****************************
Add in transit
****************************/

/*

*Merge bup
tempfile temp1
save "`temp1'"
import delimited using "cty_bup_geotransit.csv", varnames(1) clear
merge 1:m pcounty using "`temp1'"
sort pcounty period
drop _m

*Merge otp
tempfile temp2
save "`temp2'"
import delimited using "cty_otp_geotransit.csv", varnames(1) clear
merge 1:m pcounty using "`temp2'"
sort pcounty period
drop _m

*Merge inpatient
tempfile temp3
save "`temp3'"
import delimited using "cty_ip_geotransit.csv", varnames(1) clear
merge 1:m pcounty using "`temp3'"
sort pcounty period
drop _m

*Merge residential
tempfile temp4
save "`temp4'"
import delimited using "cty_res_geotransit.csv", varnames(1) clear
merge 1:m pcounty using "`temp4'"
sort pcounty period
drop _m

*Merge pregnancy
tempfile temp5
save "`temp5'"
import delimited using "cty_preg_geotransit.csv", varnames(1) clear
merge 1:m pcounty using "`temp5'"
sort pcounty period
drop _m

                                        
                                                  
                                                  
                                                  






















