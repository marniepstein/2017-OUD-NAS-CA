/******
Project: OUD NAS CHCF
Date: April 6, 2018

Purpose: Calculate the "as the crow flies" distance from county centroids to treatment locations.
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
******/

*global data = // "D:\Users\AGangopadhyaya\Dropbox\projects\chcf-nas\data"
*global do = // "D:\Users\AGangopadhyaya\Dropbox\projects\chcf-nas\do"
*global wd "D:\Users\AGangopadhyaya\Dropbox\projects\chcf-nas\wd"

*cd $wd

global bup D:\Users\MEpstein\Box Sync\2017 OUD NAS CHCF\3 Data\NTIS DEA\Created Datasets

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

keep treatid latitude longitude county cat_res cat_ip cat_preg cat_otp cat_preg_otp cat_preg_op cat_preg_res cat_op
save "trt_loc_with_id", replace
export delimited "trt_loc_with_id.csv", replace

	
	
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

keep treatid latitude longitude numbupprx
save "bup_trt_loc_with_id", replace
export delimited "bup_trt_loc_with_id.csv", replace




/*** Pull in county centroid data and calculate 10 shortest crow-flies distances between each centroid and the treatment locations of each type ***/
use "ca_cty", clear

keep if period=="2005-2016"

* Loop through all categories except bup *

foreach samp in res ip preg otp op preg_res preg_otp preg_op {
	
	*Calculate crow-flies distance from each centroid to each of the treatment facilities
	preserve
	local `samp'_count = rowsof(loc_cat_`samp')
		forvalues j=1/``samp'_count'{
			scalar trt_lat = loc_cat_`samp'[`j',2]
			scalar trt_lon = loc_cat_`samp'[`j',3]
			local trt_id = loc_cat_`samp'[`j',1]
			geodist clat clon trt_lat trt_lon,miles gen(dist`trt_id')
			}
		
	*Rank the distance to the treatment facilities and only keep 20 closest crow-flies distances
	reshape long dist, i(pcounty) j(treatid)
	bys pcounty: egen distrank = rank(dist), unique
	keep if distrank<=20
	sort pcounty distrank

	*Merge back onto larger dataset to get the lat/longs of each of the closest 20 treatment facilities so that we can look at driving distance
	merge m:1 treatid using trt_loc_with_id
	keep if _merge==3
	drop _merge

	*Reshape to be more easily read into R for geocoding driving distances
	keep pcounty clat clon latitude longitude distrank
	reshape wide latitude longitude, i(pcounty) j(distrank)
	save "cty_`samp'", replace
	export delimited "cty_`samp'.csv", replace 
	restore

}


*CA_BUP*
preserve
local res_count = rowsof(loc_cat_bup)
	forvalues j=1/`res_count'{
		scalar trt_lat = loc_cat_bup[`j',2]
		scalar trt_lon = loc_cat_bup[`j',3]
		local trt_id = loc_cat_bup[`j',1]
		geodist clat clon trt_lat trt_lon,miles gen(dist`trt_id')
		}
	
reshape long dist, i(pcounty) j(treatid)
bys pcounty: egen distrank = rank(dist), unique
keep if distrank<=20
sort pcounty distrank

merge m:1 treatid using bup_trt_loc_with_id
keep if _merge==3
drop _merge

keep pcounty clat clon latitude longitude distrank treatid //keep treatid for bup to merge back on later
reshape wide latitude longitude treatid, i(pcounty) j(distrank)
save "cty_bup", replace
export delimited "cty_bup.csv", replace 
restore
