/****
Project: CHCF NAS
Written by: Marni Epstein

Purpose: Merge driving distance times and distances for counties from the 9 separate CSVs. Output combined data.

Notes:
	- Time in seconds, distance in meters
	
Margin of errors and CIs computed in the nas_moe program

******/

set type double
cd "D:\Users\MEpstein\Box Sync\2017 OUD NAS CHCF\3 Data\SAMHSA OTP provider locations\Created datafiles"

gl excel "D:\Users\MEpstein\Box Sync\2017 OUD NAS CHCF\5 Treatment gaps\Tables\County Final Report Tables"


*Read in data with incidence rates
use "ca_cty", clear

*Merge bup
tempfile temp1
save "`temp1'"
import delimited using "cty_bup_geodrive.csv", varnames(1) clear
merge 1:m pcounty using "`temp1'"
sort pcounty period
drop _m

*Merge otp
tempfile temp2
save "`temp2'"
import delimited using "cty_otp_geodrive.csv", varnames(1) clear
merge 1:m pcounty using "`temp2'"
sort pcounty period
drop _m

*Merge inpatient
tempfile temp3
save "`temp3'"
import delimited using "cty_ip_geodrive.csv", varnames(1) clear
merge 1:m pcounty using "`temp3'"
sort pcounty period
drop _m

*Merge residential
tempfile temp4
save "`temp4'"
import delimited using "cty_res_geodrive.csv", varnames(1) clear
merge 1:m pcounty using "`temp4'"
sort pcounty period
drop _m

*Merge pregnancy
tempfile temp5
save "`temp5'"
import delimited using "cty_preg_geodrive.csv", varnames(1) clear
merge 1:m pcounty using "`temp5'"
sort pcounty period
drop _m

*Merge outpatient
tempfile temp6
save "`temp6'"
import delimited using "cty_op_geodrive.csv", varnames(1) clear
merge 1:m pcounty using "`temp6'"
sort pcounty period
drop _m

*Merge pregnancy - residential
tempfile temp7
save "`temp7'"
import delimited using "cty_preg_res_geodrive.csv", varnames(1) clear
merge 1:m pcounty using "`temp7'"
sort pcounty period
drop _m

*Merge pregnancy - otp
tempfile temp8
save "`temp8'"
import delimited using "cty_preg_otp_geodrive.csv", varnames(1) clear
merge 1:m pcounty using "`temp8'"
sort pcounty period
drop _m

*Merge pregnancy - outpatient
tempfile temp9
save "`temp9'"
import delimited using "cty_preg_op_geodrive.csv", varnames(1) clear
merge 1:m pcounty using "`temp9'"
sort pcounty period
drop _m



order pcounty period nas_a nas_b nas_ab nas_a_brt nas_b_brt nas_ab_brt drug_ed drug_ip drugdep births newborns state stfips cfips pop clat clon


* NAS rates
gen a_brthrt = nas_a / births * 1000 
gen b_brthrt = nas_b / births * 1000
gen ab_brthrt = nas_ab / births * 1000

gen a_newbrnrt = nas_a / newborns * 1000
gen b_newbrnrt = nas_b / newborns * 1000
gen ab_newbrnrt = nas_ab / newborns * 1000

gen drug_ed_rt = drug_ed / pop * 1000
gen drug_ip_rt = drug_ip / pop * 1000
gen drugdep_rt = drugdep / births * 1000

label variable a_brthrt "nas_a (ICD 779.5 or P961) / 1000 births"
label variable b_brthrt "nas_b (ICD 770.72 or P04.49) / 1000 births"
label variable ab_brthrt "nas_a or nas_b / 1000 births"
label variable a_newbrnrt "nas_a (ICD 779.5 or P961) / 1000 newborn hospitalizations"
label variable b_newbrnrt "nas_b (ICD 770.72 or P04.49) / 1000 newborn hospitalizations"
label variable ab_newbrnrt "nas_a or nas_b / 1000 newborn hospitalizations"
label variable drug_ed_rt "ER OUD Incidence / 1000 women 15-44" 
label variable drug_ip_rt "IP OUD Incidence / 1000 women 15-44" 
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
	label variable `var' "Minutes"
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
	label variable `var' "Miles"
}



*Sort on nas_a rate / births and export all nas rates
*sort a_brthrt pcounty
*export excel pcounty a_brthrt b_brthrt ab_brthrt a_newbrnrt b_newbrnrt ab_newbrnrt drug_ed_rt drug_ip_rt drugdep_rt using "NAS rates.xlsx", firstrow(varlabels) sheetmodify

/*************
Add in how many bup prescribers are at the 3 closest bup locations
*************/
*keep pcounty closelat1_bup closelat2_bup closelat3_bup closelon1_bup closelon2_bup closelon3_bup closest1_bup closest2_bup closest3_bup closetreatid1 closetreatid2 closetreatid3

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


/**************************************
Save final file with all time periods
****************************************/
drop if pcounty == "Out of State/Homeless"


save "ca_cty_geodrive.dta", replace
export delimited "ca_cty_geodrive.csv", replace

/***************************************************
Margins of error/CIs computer in the nas_moe program (saved in the folder, written by Anuj)
***************************************************/
use "ca_cty_geodrive_CI_UPD.dta", clear


*Sort on county, 4 year period, 5 year period, 10 year period. Export county list and copy and paste into final table, since we can't use putexcel with a string variable
gen sortvar = 1 if period == "2005-2008"
replace sortvar = 2 if period == "2009-2012"
replace sortvar = 3 if period == "2013-2016"
replace sortvar = 4 if period == "2005-2010"
replace sortvar = 5 if period == "2011-2016"
replace sortvar = 6 if period == "2005-2016"

gen periodyrs = 4 if inlist(sortvar, 1, 2, 3)
replace periodyrs = 5 if inlist(sortvar, 4, 5)
replace periodyrs = 10 if sortvar == 6

sort pcounty sortvar
export excel pcounty period periodyrs using "${excel}/county names ordered by period.xlsx", sheetmodify sheet("all periods")


/****************************************
Output NAS rates to table
****************************************/
gl exceloutput "${excel}\County Treatment Distances v6.xlsx"

putexcel set "$exceloutput", modify sheet("NAS")

*Replace missing CIs as missing instead of "(.,.)
foreach var in a_brthrt_ci b_brthrt_ci ab_brthrt_ci a_newbrnrt_ci b_newbrnrt_ci ab_newbrnrt_ci {
	replace `var' = "" if `var' == "(.,.)"
}

*Can't use putexcel with string variables, so use export excel and copy into the main table
	export excel pcounty period periodyrs nas_ab nas_a nas_b births newborns ab_brthrt ab_brthrt_ci a_brthrt a_brthrt_ci b_brthrt b_brthrt_ci ab_newbrnrt ab_newbrnrt_ci a_newbrnrt a_newbrnrt_ci b_newbrnrt b_newbrnrt_ci ///
		using "${excel}\NAS vars.xlsx", replace firstrow(varlabels)



/****************************************
*Output driving times and miles to table
****************************************/

*Only keep NAS rate for full time period
keep if period == "2005-2016"

export excel pcounty period using "${excel}/county names ordered by period.xlsx", sheetmodify sheet("one periods")

*Print all categories
foreach cat in  res ip otp op preg preg_res preg_otp preg_op {

	putexcel set "$exceloutput", modify sheet("`cat'")

	*Average of the three closest facilities
	egen lowtimeavg_`cat' = rowmean(lowtime1_`cat' lowtime2_`cat' lowtime3_`cat')
	egen lowdistavg_`cat' = rowmean(lowdist1_`cat' lowdist2_`cat' lowdist3_`cat')
	
	*mkmat pcounty 
	mkmat lowtime1_`cat'
	mkmat lowdist1_`cat'	
	mkmat lowtime2_`cat'
	mkmat lowdist2_`cat'
	mkmat lowtime3_`cat'
	mkmat lowdist3_`cat'
	mkmat lowtimeavg_`cat'
	mkmat lowdistavg_`cat'
		  
	mat def outtable_`cat' = (lowtime1_`cat', lowdist1_`cat', lowtime2_`cat', lowdist2_`cat', lowtime3_`cat', lowdist3_`cat', lowtimeavg_`cat', lowdistavg_`cat')
	putexcel B5 = matrix(outtable_`cat')
}                                                 
                                                  
* Bup
foreach cat in bup  {

	putexcel set "$exceloutput", modify sheet("`cat'")

	*Average of the three closest facilities
	egen lowtimeavg_`cat' = rowmean(lowtime1_`cat' lowtime2_`cat' lowtime3_`cat')
	egen lowdistavg_`cat' = rowmean(lowdist1_`cat' lowdist2_`cat' lowdist3_`cat')
	
	*mkmat pcounty 
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
		  
	mat def outtable_`cat' = (lowtime1_`cat', lowdist1_`cat', numbupprx1, lowtime2_`cat', lowdist2_`cat', numbupprx2, ///
							lowtime3_`cat', lowdist3_`cat', numbupprx3, lowtimeavg_`cat', lowdistavg_`cat')
	putexcel B5 = matrix(outtable_`cat')
}                                                 
                                                  

												  
												  
												  
export delimited "ca_cty_tomap.csv", replace



/*
		  
/***********************************************
Export table for Maternal Taskforce Meeting
***********************************************/		  

gl excelmaternal "D:\Users\MEpstein\Box Sync\2017 OUD NAS CHCF\5 Treatment gaps\Tables\County summary table Maternal Taskforce.xlsx"
putexcel set "$excelmaternal", modify

*Turn each variable into matrix
foreach var in ab_brthrt lowtimeavg_preg lowtimeavg_preg_otp lowtimeavg_preg_res lowtimeavg_preg_op lowtimeavg_bup {
	mkmat `var'
}

*Create matrix to print
mat def sumtable = (ab_brthrt, lowtimeavg_preg, lowtimeavg_preg_otp, lowtimeavg_preg_res, lowtimeavg_preg_op, lowtimeavg_bup)
		  
*Print to excel
putexcel B5 = matrix(sumtable)



/****************************
Add in transit
****************************/
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

                                        
                                                  
                                                  
                                                  






















