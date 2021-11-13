/******
Project: OUD NAS CHCF
Date: April 6, 2018

Purpose: Calculate the "as the crow flies" distance from county ZCTAs to treatment locations.
	Select the top 20 to run through the geocoding program that will calculate driving/transit time and distance the Google matrix.


Notes:
 for egen rank, added in unique option. This says that when 2 values are equal in rank, arbitrarily assign one to be greater 
	(e.g. if they are tied for 2 and 3rd place, assign one to 2 and one to 3). 
 Otherwise they are both given the average rank (e.g. if tied for 2nd and 3rd place, they are both given 2.5)
 
We use 5 categories of treatment locations:
	1. OTPs, from the SAMHSA treatment custom pull
	2. Buprenorphine prescribers, from the DEA NTIS data
	3. Residential clinics, from the SAMHSA online treatment locator
	4. Inpatient clinics, from the SAMHSA online treatment locator
	5. Pregnancy-specific clinics, from the SAMHSA online treatment locator
	
Notes: Collapse all NAS counts to the ZCTA level. We have duplicate zip codes that collapse down to the same ZCTA	

******/

*cd $wd

global bup D:\Users\MEpstein\Box Sync\2017 OUD NAS CHCF\3 Data\NTIS DEA\Created Datasets
gl geocrosswalk "D:\Users\MEpstein\Box Sync\2017 OUD NAS CHCF\3 Data\Geographic Crosswalks"

cd "D:\Users\MEpstein\Box Sync\2017 OUD NAS CHCF\3 Data\SAMHSA OTP provider locations\Created datafiles" 

* Read in treatment locations from the SAMHSA online treatment locator (residential, inpatient, pregnancy)
use "treatment locations by cat",clear
gen treatid = _n
set matsize 2000

foreach samp in cat_res cat_ip cat_preg cat_otp cat_op cat_preg_res cat_preg_otp cat_preg_op {
	*De-duplicate
	duplicates report latitude longitude if  `samp'==1
	duplicates drop latitude longitude if  `samp'==1, force
	
	*Create matrix with lat, long and treatid, which is an identified for each unique lat/long pair
	mkmat treatid if  `samp'==1
	mkmat latitude if  `samp'==1
	mkmat longitude if  `samp'==1
	mat def loc_`samp' = (treatid,latitude,longitude)
	
	}

*Don't save - this is the same as in the county file
	
*Read in buprenorphine-waivered prescribers from DEA data
set type double
import delimited "${bup}/DEA Bup Prescribers CA - geocoded.csv",clear
rename lat latitude
rename lon longitude

* Generate variable with the number of bup prescribers per location. Check that it matches the values from duplicates. 
*Drop duplicate lat/longs, but keep variable with how many prescribers there are per lat/long
bys latitude longitude: egen numbupprx = count(name)
duplicates tag latitude longitude, gen(duptag)
tab numbupprx duptag
duplicates drop latitude longitude, force

* Gen treatid after de-duplicating
gen treatid = _n
set matsize 5000

format latitude %9.6f
format longitude %9.6f

foreach samp in cat_bup {
	mkmat treatid 
	mkmat latitude 
	mkmat longitude 
	mat def loc_`samp' = (treatid,latitude,longitude)
	}

*Don't save - this is the same as in the county file


*log using "D:\Users\MEpstein\Box Sync\2017 OUD NAS CHCF\5 Treatment gaps\logs and tabs\Missing NAS and centroids.log", replace

/*** Pull in county centroid data and calculate 10 shortest crow-flies distances between each centroid and the treatment locations of each type ***/
use "ca_zip", clear
*keep if period=="2005-2016" 

*Tab how many zip centroids and NAS variables are missing
gen miscentr = zlat == .
tab miscentr, m


*Mark which zips that have at least one non-missing NAS variable, since we already ran the programs for these zips
gen nasdata = !missing(nas_a) | !missing(nas_b) | !missing(nas_ab) | !missing(nas_a_brt) | !missing(nas_b_brt) | !missing(nas_ab_brt)
tab nasdata miscentr, m


*First merge zip code to ZCTA crosswalk. We want to collapse since centroids are by ZCTA

tempfile temp1
save "`temp1'"
import excel using "${geocrosswalk}/zip_to_zcta_2017.xlsx", clear firstrow
rename ZIP_CODE patzip
merge 1:m patzip using "`temp1'"
drop if _m==1
drop _m
rename ZCTA zcta


*NOTE: There are 143 zip codes with no matching ZCTA. This means we can't map them.
tab patzip if zcta == ""

* Check duplicate ZCTAs
replace Zip_join_type = "Zip matches ZCTA" if Zip_join_type == "Zip Matches ZCTA"

duplicates report zcta period
duplicates tag zcta period, gen(dupzcta)

*For an example, run:
list patzip zcta Zip_join_type period dupzcta if zcta == "90001"


/**************
Collapse to only have one copy of each ZCTA for mapping
**************/
collapse (sum) nas_a nas_b nas_ab nas_a_brt nas_b_brt nas_ab_brt drug_ed drug_ip drugdep births newborns, by(zcta period)


*Merge in zip centroids
gl zipcent "D:\Users\MEpstein\Box Sync\2017 OUD NAS CHCF\3 Data\Zip centroids"
destring zcta, replace
merge m:1 zcta using "${zipcent}/zip-2017-centroids.dta"

drop if _m == 2 //lat/long but no entry in NAS CA file
list if _m == 1 //entry in our data but missing zcta. These are for nas counts without a zcta attached
drop _m

rename lat zlat
rename lon zlon

*There are so many duplicate ZCTAs (6 for most) because of the different time periods. There are no duplicate ZCTAs wtihin the time periods
duplicates report zcta 
duplicates report zcta period

*Save final file with ZCTA NAS data
save "ca_zcta.dta", replace

*We want to keep only one copy per zcta for mapping purposes. We don't want multiple rows for different time periods
duplicates drop zcta, force



* Loop through all categories except bup *

foreach samp in res ip preg otp op preg_res preg_otp preg_op {
	 
	preserve
	local `samp'_count = rowsof(loc_cat_`samp')
		forvalues j=1/``samp'_count'{
			scalar trt_lat = loc_cat_`samp'[`j',2]
			scalar trt_lon = loc_cat_`samp'[`j',3]
			local trt_id = loc_cat_`samp'[`j',1]
			geodist zlat zlon trt_lat trt_lon,miles gen(dist`trt_id')
			}
		
	reshape long dist, i(zcta) j(treatid)
	bys zcta: egen distrank = rank(dist), unique
	keep if distrank<=20
	sort zcta distrank

	merge m:1 treatid using trt_loc_with_id
	keep if _merge==3
	drop _merge

	keep zcta zlat zlon latitude longitude distrank
	sort zcta distrank
	reshape wide latitude longitude, i(zcta) j(distrank)
	save "zcta_`samp'", replace
	export delimited "zcta_`samp'.csv", replace 
	restore

}



*CA_BUP*
preserve
local res_count = rowsof(loc_cat_bup)
	forvalues j=1/`res_count'{
		scalar trt_lat = loc_cat_bup[`j',2]
		scalar trt_lon = loc_cat_bup[`j',3]
		local trt_id = loc_cat_bup[`j',1]
		geodist zlat zlon trt_lat trt_lon,miles gen(dist`trt_id')
		}
	
reshape long dist, i(zcta) j(treatid)
bys zcta: egen distrank = rank(dist), unique
keep if distrank<=20
sort zcta distrank

merge m:1 treatid using bup_trt_loc_with_id
keep if _merge==3
drop _merge

keep zcta zlat zlon latitude longitude distrank treatid //keep treatid for bup to merge back on later
reshape wide latitude longitude treatid, i(zcta) j(distrank)
save "zcta_bup", replace
export delimited "zcta_bup.csv", replace 
restore








