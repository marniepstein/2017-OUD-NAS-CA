/*****************************
Project: OUD NAS CHCF
Date: April 6, 2018

Purpose: Subset provider location data from the SAMHSA treatment locator directory (https://findtreatment.samhsa.gov/)
		 Output to a csv to be mapped in R


*****************************/

cd "D:\Users\MEpstein\Box Sync\2017 OUD NAS CHCF\3 Data\SAMHSA OTP provider locations"

import excel using "Behavioral_Health_Treament_Facility_listing_2018_04_05_104951", firstrow clear
destring, replace

/*****************************************************************
Create provider/treatment facility classifications

Provider/treatment facility classifications:
1.	All methadone clinics: pulling this list from the SAMHSA OTP directory (152 locations).
2.	All buprenorphine-waivered physicians: from DEA CSA registries.
3.	All residential clinics providing at least 1 of the following services (from the SAMHSA treatment locator):
4.	All inpatient facilities providing at least 1 of the following services (from the SAMHSA treatment locator):
5.	All pregnancy-specific treatment facilities providing at least 1 of the following services (from the SAMHSA treatment locator; these centers will not be mutually exclusive from the top 4):

MAT defined as offering at least one of the following services:
	•	Buprenorphine maintenance (bum)
	•	Buprenorphine maintenance for predetermined time (bmw)
	•	Buprenorphine detox (db)
	•	Methadone maintenance (mm)
	•	Methadone maintenance for predetermined time (mmw)
	•	Methadone detox (dm)
	•	Outpatient methadone/buprenorphine or naltrexone(omb)
	•	Methadone used in treatment (mu)
	•	Buprenorphine used in treatment (bu)
	•	Methadone(meth)
	•	Buprenorphine sub-dermal implant (Probuphine®)(bsdm)
	•	Buprenorphine with naloxone (Suboxone®)(bwn)
	•	Buprenorphine without naloxone(bwon)


*********************************************************************/

gen cat_otp = .
gen cat_bup = .
gen cat_res = .
gen cat_ip = .
gen cat_op = .
gen cat_preg = .
gen cat_preg_res = .
gen cat_preg_otp = .
gen cat_preg_op = .


* (bum == 1 | bmw == 1 | db == 1 | mm == 1 | mmw == 1 | dm == 1)
replace cat_res = 1 if res == 1 & (bum == 1 | bmw == 1 | db == 1 | mm == 1 | mmw == 1 | dm == 1 | omb == 1 | mu == 1 | bu == 1 | meth == 1 | bsdm == 1 | bwn == 1 | bwon == 1)
replace cat_ip = 1 if hi == 1 & (bum == 1 | bmw == 1 | db == 1 | mm == 1 | mmw == 1 | dm == 1 | omb == 1 | mu == 1 | bu == 1 | meth == 1 | bsdm == 1 | bwn == 1 | bwon == 1)
replace cat_preg = 1 if pw == 1 & (bum == 1 | bmw == 1 | db == 1 | mm == 1 | mmw == 1 | dm == 1 | omb == 1 | mu == 1 | bu == 1 | meth == 1 | bsdm == 1 | bwn == 1 | bwon == 1)
replace cat_otp = 1 if otp == 1 & (bum == 1 | bmw == 1 | db == 1 | mm == 1 | mmw == 1 | dm == 1 | omb == 1 | mu == 1 | bu == 1 | meth == 1 | bsdm == 1 | bwn == 1 | bwon == 1)
replace cat_op = 1 if op == 1 & (bum == 1 | bmw == 1 | db == 1 | mm == 1 | mmw == 1 | dm == 1 | omb == 1 | mu == 1 | bu == 1 | meth == 1 | bsdm == 1 | bwn == 1 | bwon == 1)

replace cat_preg_res = 1 if (pw == 1 & res == 1) & (bum == 1 | bmw == 1 | db == 1 | mm == 1 | mmw == 1 | dm == 1 | omb == 1 | mu == 1 | bu == 1 | meth == 1 | bsdm == 1 | bwn == 1 | bwon == 1)
replace cat_preg_otp = 1 if (pw == 1 & otp == 1) & (bum == 1 | bmw == 1 | db == 1 | mm == 1 | mmw == 1 | dm == 1 | omb == 1 | mu == 1 | bu == 1 | meth == 1 | bsdm == 1 | bwn == 1 | bwon == 1)
replace cat_preg_op = 1 if (pw == 1 & op == 1) & (bum == 1 | bmw == 1 | db == 1 | mm == 1 | mmw == 1 | dm == 1 | omb == 1 | mu == 1 | bu == 1 | meth == 1 | bsdm == 1 | bwn == 1 | bwon == 1)

gen detox = 1 if db == 1 | dm == 1

tab cat_res, m
tab cat_ip, m
tab cat_otp, m
tab cat_op, m
tab cat_preg, m
tab cat_preg_res, m
tab cat_preg_otp, m
tab cat_preg_op, m


tab cat_res detox, m
tab cat_ip detox, m
tab cat_preg detox, m
tab cat_otp detox, m

tab cat_preg cat_preg_res, m
tab cat_preg cat_preg_otp, m
tab cat_preg_res cat_preg_otp, m



tab cat_preg res, m
tab cat_preg hi, m


save "Created datafiles\treatment locations by cat.dta", replace






