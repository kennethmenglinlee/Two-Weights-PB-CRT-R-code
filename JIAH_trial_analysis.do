*Primary analysis code for the Jharkand Initiative for Adolescent Health (JIAH) trial
	*Trial registration: ISRCTN17206016

*De-identified dataset for analysis of primary outcomes, including code for
	*(1)Coding and generating analysis variables using raw data
	*(2) Descriptive analyses for primary outcomes
	*(3) Modelling primary outcomes x3 
	*(4) Secondary outcomes x 12
	
*Created on 30 May 2022 by Komal Bhatia in advance of submitting the trial paper for publication

*Stata version 16
******

*Instruction to user: set local directory and start log file

set more off
*use "jiah_trial_dataset_stata16.dta", clear
use "C:\Users\kenny\OneDrive\Professional\#Education\Duke-NUS PhD\Thesis\Ideas\# Notes PB-CRT FE\Two Weights work\jiah_trial_dataset_stata16.dta", clear



*(1) CODING AND GENERATING ANLAYSIS VARIABLES

	*THREE PRIMARY OUTCOMES (y_p1, y_p2 and y_p3)

*y_p1 = diet_score (total score out of 10)

*generate 10 food groups and calculate diet score
	/*Note that 16 girls did not eat in the last 24 hours before the survey.
	Their missing data for food recall will be converted to 0 for all items 
	and will result in a diet score of 0, which is fine. */

rename ( _food_recalls1 _food_recalls2 _food_recalls3 _food_recalls4 _food_recalls5 _food_recalls6 _food_recalls7 _food_recalls8 ///
_food_recalls9 _food_recalls10 _food_recalls11 _food_recalls12 _food_recalls13 _food_recalls14 _food_recalls15 _food_recalls16 ///
_food_recalls17 _food_recalls18 _food_recalls19 _food_recalls20 _food_recalls21 _food_recalls22 _food_recalls23 _food_recalls24 ///
_food_recalls25 _food_recalls26 _food_recalls27) ///
(roti pumpkin soya roots leaf mango unripe otherveg otherfruit liver chicken pork egg fish dried shellfish mushroom beans ///
sunflower nuts cheese oil sugary sugar_drink condiment grubs other_bev)

capture drop foodgroup1
gen foodgroup1=.
replace foodgroup1=1 if roti==1 | roots==1
replace foodgroup1=0 if roti!=1 & roots!=1
label var foodgroup1 "Grains, white roots and tubers, and plantains"
label def foodgroup 0"No" 1"Yes"
label val foodgroup1 foodgroup
tab foodgroup1, m

capture drop foodgroup2
gen foodgroup2=.
replace foodgroup2=1 if soya==1 | beans==1
replace foodgroup2=0 if soya!=1 & beans!=1
label var foodgroup2 "Pulses (beans, peas and lentils)"
label val foodgroup2 foodgroup
tab foodgroup2, m

capture drop foodgroup3
gen foodgroup3=.
replace foodgroup3=1 if sunflower==1 | nuts==1
replace foodgroup3=0 if sunflower!=1 & nuts!=1
label var foodgroup3 "Nuts and seeds"
label val foodgroup3 foodgroup
tab foodgroup3, m

capture drop foodgroup4
gen foodgroup4=cheese
label var foodgroup4 "Dairy"
tab foodgroup4, m

capture drop foodgroup5
gen foodgroup5=.
replace foodgroup5=1 if liver==1 | chicken==1 | pork==1 | fish==1 | dried==1 | shellfish==1 | grubs==1
replace foodgroup5=0 if liver!=1 & chicken!=1 & pork!=1 & fish!=1 & dried!=1 & shellfish!=1 & grubs!=1
label var foodgroup5 "Meat, poultry and fish"
label val foodgroup5 foodgroup
tab foodgroup5, m

capture drop foodgroup6
gen foodgroup6=egg
label var foodgroup6 "Egg"
label val foodgroup6 foodgroup
tab foodgroup6, m

capture drop foodgroup7
gen foodgroup7=leaf
label var foodgroup7 "Dark leafy vegetables"
label val foodgroup7 foodgroup
tab foodgroup7, m

capture drop foodgroup8
gen foodgroup8=.
replace foodgroup8=1 if pumpkin==1 | mango==1
replace foodgroup8=0 if pumpkin!=1 & mango!=1
label var foodgroup8 "Other vitamin A-rich fruits and vegetables"
label val foodgroup8 foodgroup
tab foodgroup8, m

capture drop foodgroup9
gen foodgroup9=.
replace foodgroup9=1 if mushroom==1 | otherveg==1
replace foodgroup9=0 if mushroom!=1 & otherveg!=1
label var foodgroup9 "Other vegetables"
label val foodgroup9 foodgroup
tab foodgroup9, m

capture drop foodgroup10
gen foodgroup10=.
replace foodgroup10=1 if unripe==1 | otherfruit==1
replace foodgroup10=0 if unripe!=1 & otherfruit!=1
label var foodgroup10 "Other fruit"
label val foodgroup10 foodgroup
tab foodgroup10, m

capture drop diet_score
egen diet_score = anycount(foodgroup1 foodgroup2 foodgroup3 foodgroup4 foodgroup5 foodgroup6 foodgroup7 foodgroup8 foodgroup9 foodgroup10), values(1)
tab diet_score, m

*y_p2 =bpm_score Brief Problem Monitor-Youth Score at EL and BPC at endline


	*check missing data patterns
*Baseline BPC 
misstable pat bpcargue bpcdestroy bpcdisobey bpcguilty bpcworthless bpcselfconscious bpcstubborn bpctemper bpcthreaten bpcfearful bpcunhappy bpcworry if survey_round==0, freq
	// 6%, 193 who only had the K10 instrument. Need to leave these out of model
capture drop bpc_miss
egen bpc_miss = rowmiss(bpcargue bpcdestroy bpcdisobey bpcguilty bpcworthless bpcselfconscious bpcstubborn bpctemper bpcthreaten bpcfearful bpcunhappy bpcworry) if survey_round==0
tab bpc_miss

*Endline - BPM-Y
misstable pat bpctoo_young bpcargue bpcfail bpcattention bpcsit_still bpcdestroy bpcdisobey_parents bpcworthless bpcwithout_think bpcfearful bpcguilty bpcselfconscious bpcdistracted bpcstubborn bpctemper bpcthreaten bpcunhappy bpcworry bpcirritable bpcunwell if survey_round==1, freq
	// 0 missing.

	*Calculate total scores
*BPM-Y at endline (20 items - total score out of 40) 
	*KB: Many adolescents are not in school, so the item bpcdisobey_school is not included, as per our analysis plan.
capture drop bpm_score
egen bpm_score = rowtotal (bpctoo_young bpcargue bpcfail bpcattention bpcsit_still ///
bpcdestroy bpcdisobey_parents bpcworthless bpcwithout_think bpcfearful bpcguilty ///
bpcselfconscious bpcdistracted bpcstubborn bpctemper bpcthreaten bpcunhappy bpcworry bpcirritable bpcunwell) if survey_round==1
tab bpm_score

*BPC at baseline (12 items - total score out of 24) if tool was administered
capture drop bpc_score 
egen bpc_score = rowtotal (bpcargue bpcdestroy bpcdisobey bpcguilty bpcworthless ///
 bpcselfconscious bpcstubborn bpctemper bpcthreaten bpcfearful bpcunhappy bpcworry) if survey_round==0 & bpc_miss==0
tab bpc_score

tabstat bpm_score if survey_round==1, by(treat) stat(median sd p25 p75)
tabstat bpc_score if survey_round==0, by(treat) stat(median  sd p25 p75)


*Log transformed values: divide by number of items (12 or 20) and then log (x+1)
capture drop std_bpc_12
capture drop std_bpm_20
capture drop log_std_bpc_12
capture drop log_std_bpm_20

gen std_bpc_12 = bpc_score/12
gen std_bpm_20 = bpm_score/20
gen log_std_bpc_12=ln(1+std_bpc_12)
gen log_std_bpm_20=ln(1+std_bpm_20)


foreach var of varlist log_std_bpc_12 log_std_bpm_20{
tabstat `var' if survey_round==1, by(treat) stat(mean sd median p25 p75)
tabstat `var' if survey_round==0, by(treat) stat(mean sd median p25 p75)
}
*combine into one variable for the primary outcome model
capture drop mentalhealth
gen mentalhealth=log_std_bpm_20 if survey_round==1
replace mentalhealth=log_std_bpc_12 if survey_round==0

	
*y_p3 = in_school
capture drop in_school
gen in_school=.
replace in_school=1 if currently_attends_school==1 | currently_attends_school==2
replace in_school=0 if currently_attends_school==0
label def in_school 0"Not currently in school" 1"Currently in school or college"
label val in_school in_school
tab in_school
	
	
	* ADJUSTMENT & CLUSTERING VARIABLES

 *(age group, livelihood, survey round, strata and dummy vars)
	*note that asset quintile and livelhood variables are already coded to protect de-identification, and only converted to dummy var here as required

* Tribal status
capture drop tribal_status
recode tribe_caste (1=1 "Tribal") (2/4= 0 "Non-tribal"), gen(tribal_status)
tab tribal_status

*Age group
tabstat adolescent_age, stat(mean, sd)
label var adolescent_age "Adolescent's age"

capture drop age_group
gen age_group=.
replace age_group=0 if adolescent_age>=10 & adolescent_age<=14
replace age_group=1 if adolescent_age>=15 & adolescent_age<=19
label var age_group "Age"
label def age 0"10-14 years" 1"15-19 years"
label val age_group age
tab age_group

*Dummy variables for baseline and endline
tab survey_round, gen(survey)
rename survey1 baseline
rename survey2 endline
tab baseline endline

*dummy variables for strata (Note: can't use i.varname in mixed suite of commands)
tab strata, gen(strata)

*dummy variables for assetquintile
tab assetquintile, gen(assetquintile)


*(2) DESCRIPTIVE ANALYSES FOR PRIMARY OUTCOMES

*background characteristics at baseline
foreach var of varlist household_location tribal_status religion  ///
ado_married personal_mobile assetquintile livelihood_binary toilet age_group ///
toilet {
tab `var' treat if survey_round==0, col
}

*Table 1 at baseline
foreach var of varlist household_location tribe_caste which_tribe religion  ///
ado_married personal_mobile assetquintile livelihood_binary garden literacy age_group ///
toilet {
tab `var' treat if survey_round==0, col
}

*background characteristics at endline
foreach var of varlist household_location tribe_caste which_tribe religion ///
ado_married personal_mobile assetquintile livelihood_binary garden literacy toilet age_group {
tab `var' treat if survey_round==1, col
}

*compare full and reduced datasets at baseline by arm
foreach var of varlist household_location tribal_status religion  ///
ado_married personal_mobile assetquintile livelihood_binary toilet age_group ///
toilet {
tab `var' treat if survey_round==0 & matched_clusters==0, col
}
*check BL and EL balance by strata and cluster too

tab strata  survey_round, col

/* at EL, lower % from Strata 2, and higher % from Strata 4 and 5 compared
	to baseline proportions */

   *NB: categories in livelihood variables for BL and EL are not the same... 

* Primary outcomes by study arm at BASELINE 
	*continuous (denominator is 24 for mental health)
foreach var of varlist diet_score bpc_score{
tabstat `var' if survey_round==0, by(treat) stat(mean sd median iqr p25 p75)
} 
	*categorical

tab in_school treat if survey_round==0, col chi

  
* Primary outcomes by study arm at ENDLINE 
	*continuous (denominator is 40 for mental health)
foreach var of varlist diet_score bpm_score{
tabstat `var' if survey_round==1, by(treat) stat(mean sd median iqr p25 p75 count)
} 
count if diet_score!=. & survey_round==1 & treat==0
count if diet_score!=. & survey_round==1 & treat==1
count if bpm_score!=. & survey_round==1 & treat==0
count if bpm_score!=. & survey_round==1 & treat==1
	*categorical
tab in_school treat if survey_round==1, col chi

* Intracluster correlation coefficient
	*Confirm baseline values 
loneway diet_score idclus if baseline==1
loneway bpc_score idclus if baseline==1
loneway in_school idclus if baseline==1
	//all match values in protocol (0.03, 0.4, 0.39 for edu, dd, bpm)
	
	*Calculate endline values
loneway diet_score idclus if endline==1
loneway bpm_score idclus if endline==1
loneway in_school idclus if endline==1
	/* 
		coefficient, 95%CI
	diet 0.25 (0.13, 0.38)
	mental health 0.34 (0.19, 0.48)
	education 0.05 (0.01, 0.08)
	*/

	
*(3) MODELLING PRIMARY OUTCOMES

		*treatment variable coded 1 for endline values in intervention arm, and 0 otherwise
	capture drop treatment
	gen treatment=0
	replace treatment=1 if treat==1 & survey_round==1
	tab treatment

	//Syntax: mixed y baseline endline treat c* s*|| idclus: baseline endline, cov(exch) noconstant stddev

*Outcome 1.1 Dietary diversity (continuous) 
		
		*adjusted
mixed diet_score  treatment endline  assetquintile1-assetquintile4 tribal_status adolescent_age livelihood_binary strata1-strata4 || idclus: baseline endline, cov(exch) noconstant stddev
		*unadjusted
mixed diet_score  treatment endline || idclus: baseline endline, cov(exch) noconstant stddev

*Outcome 1.2 Brief Problem Monitor-Youth (continuous) 
	*adjusted
mixed mentalhealth treatment endline assetquintile1-assetquintile4 tribal_status adolescent_age livelihood_binary strata1-strata4 || idclus: baseline endline, cov(exch) noconstant stddev 

*exponentiate co-eff, CI
di (exp(.0245082)-1)
di exp(-.0697354)-1
di exp(.1187517)-1
	
	*unadjusted
mixed mentalhealth treatment endline|| idclus: baseline endline, cov(exch) noconstant stddev 

		*expo co-eff, CI
di (exp(.0274731)-1)
di exp(-.0654856)-1
di exp(.1204319)-1

*Outcome 1.3 School attendance (coded 0/1) 
	*adjusted
melogit in_school treatment endline  assetquintile1-assetquintile4 tribal_status adolescent_age livelihood_binary strata1-strata4 || idclus: baseline endline, cov(exch) noconstant or
	*unadjusted
melogit in_school treatment endline || idclus: baseline endline, cov(exch) noconstant or

*SECONDARY OUTCOMES

*2.1 % decision-making about food
capture drop food_dec_other
egen food_dec_other=anymatch(food_decision_making2 food_decision_making3 food_decision_making4 food_decision_making5), v(1)
label var food_dec_other "Others involved in food decision-making"
tab food_dec_other

capture drop food_dec 
gen food_dec=.
replace food_dec=1 if food_decision_making1==1 & food_dec_other==1
replace food_dec=0 if food_decision_making1==0 & food_dec_other==1
replace food_dec=0 if food_decision_making1==1 & food_dec_other==0
label var food_dec "Joint decision-making about food"
label define food_dec 1 "Yes" 0 "No"
label values food_dec food_dec

*exclude obs if unmarried participants have said yes to husband or in-law involvement
replace food_dec=. if (food_decision_making3==1 & ado_married==0) | (food_decision_making4==1 & ado_married==0)

bysort survey_round: tab food_dec treat, m col freq

melogit food_dec treatment endline assetquintile1-assetquintile4 tribal_status adolescent_age livelihood_binary strata1-strata4 || idclus: baseline endline, cov(exch) noconstant or
		*unadjusted
melogit food_dec treatment endline|| idclus: baseline endline, cov(exch) noconstant or


*2.2 Mean score on gender role attitudes index (sum of 7 items)
tab1 educating_boys girls_good_as_boys_study boys_domestic_work girls_teased husbands_permission girls_decide_marry husband_decision

** Egalitarian gender roles index
*** recode missing and reverse code some original variables so higher score relates to more egalitarian attitudes
capture drop norm_edu
gen norm_edu=educating_boys
replace norm_edu=1 if educating_boys==0
replace norm_edu=0 if educating_boys==1
replace norm_edu=. if educating_boys==99
label var norm_edu "Do you think that educating boys is more important than educating girls?"
label define norm_edul 0"Yes" 1"No"
label val norm_edu norm_edul
tab norm_edu

capture drop norm_study
gen norm_study=girls_good_as_boys_study
replace norm_study=. if girls_good_as_boys_study==99
label var norm_study "Do you think that girls are usually as good as boys in studies? "
label define norm_study 1"Yes" 0"No"
label val norm_study norm_study
tab norm_study

capture drop norm_domestic
gen norm_domestic=boys_domestic_work
replace norm_domestic=. if boys_domestic_work==99
label var norm_domestic "Do you think that boys should do as much domestic work as girls?"
label define norm_domestic 1"Yes" 0"No"
label val norm_domestic norm_domestic
tab norm_domestic

capture drop norm_teased
gen norm_teased=girls_teased
replace norm_teased=. if girls_teased==99
replace norm_teased=1 if girls_teased==0
replace norm_teased=0 if girls_teased==1
label var norm_teased "Do you think that girls who are teased deserve it if they are dressed provocatively? "
label define norm_teased 1"No" 0"Yes"
label val norm_teased norm_teased
tab norm_teased girls_teased

capture drop norm_permission
gen norm_permission=husbands_permission 
replace norm_permission=. if husbands_permission==99
replace norm_permission=1 if husbands_permission==0
replace norm_permission=0 if husbands_permission==1
label var norm_permission "Do you think that a woman should obtain her husband’s permission for most of the things? "
label define norm_permission 0"Yes" 1"No"
label val norm_permission norm_permission
tab norm_permission

capture drop norm_marry
gen norm_marry=girls_decide_marry 
replace norm_marry=. if girls_decide_marry==99
label var norm_marry "Do you think that girls should be allowed to decide when they want to marry? "
label define norm_marry 1 "Yes" 0"No"
label val norm_marry norm_marry
tab norm_marry

capture drop norm_money
gen norm_money=husband_decision
replace norm_money=1 if husband_decision==0
replace norm_money=0 if husband_decision==1
replace norm_money=. if husband_decision==99
label var norm_money "Do you think that the husband alone/mainly should decide how household money is to be spent?"
label define norm_moneyl 0"Yes" 1"No"
label val norm_money norm_moneyl
tab norm_money

** generate an egalitarian gender roles index
egen egal_index=rowtotal(norm_edu norm_study norm_domestic norm_teased norm_permission norm_marry norm_money)
tabstat egal_index, stat(mean, sd)
label var egal_index "Egalitarian gender roles index"
tab egal_index

bysort survey_round: tabstat egal_index, by (treat) stat (mean sd)

count if egal_index!=. & survey_round==1 & treat==0
count if egal_index!=. & survey_round==1 & treat==1
 
mixed egal_index treatment endline assetquintile1-assetquintile4 tribal_status adolescent_age livelihood_binary strata1-strata4 || idclus: baseline endline, cov(exch) noconstant stddev

		*unadjusted
mixed egal_index treatment endline || idclus: baseline endline, cov(exch) noconstant stddev

*2.3 % decision-making about friends, money and food
capture drop money_dec_other
egen money_dec_other=anymatch(money_decision2 money_decision3 money_decision4 money_decision5), v(1)
label var money_dec_other "Others involved in decision making about money"

capture drop friends_dec_other
egen friends_dec_other=anymatch(friends_decision2 friends_decision3 friends_decision4 friends_decision5), v(1)
label var friends_dec_other "Others involved in decision making about friends"

capture drop buying_dec_other
egen buying_dec_other=anymatch(buying_decision2 buying_decision3 buying_decision4 buying_decision5), v(1)
label var buying_dec_other "Others involved in decision making about buying"

capture drop money_dec
gen money_dec=.
replace money_dec=1 if money_decision1==1 & money_dec_other==1
replace money_dec=0 if money_decision1==0 & money_dec_other==1
replace money_dec=0 if money_decision1==1 & money_dec_other==0
label var money_dec "Joint decision-making about money"
label define money_dec 1"Yes" 0 "No"
label values money_dec money_dec

capture drop friends_dec
gen friends_dec=.
replace friends_dec=1 if friends_decision1==1 & friends_dec_other==1
replace friends_dec=0 if friends_decision1==0 & friends_dec_other==1
replace friends_dec=0 if friends_decision1==1 & friends_dec_other==0
label var friends_dec "Joint decision-making about friends"
label values friends_dec money_dec

capture drop buying_dec
gen buying_dec=.
replace buying_dec=1 if buying_decision1==1 & buying_dec_other==1
replace buying_dec=0 if buying_decision1==0 & buying_dec_other==1
replace buying_dec=0 if buying_decision1==1 & buying_dec_other==0
label var buying_dec "Joint decision-making about buying"
label values buying_dec money_dec

*exclude obs if unmarried participants have said yes to husband or in-law involvement
replace money_dec=. if (money_decision3==1 & ado_married==0) | (money_decision4==1 & ado_married==0)
replace friends_dec=. if (friends_decision3==1 & ado_married==0) | (friends_decision4==1 & ado_married==0)
replace buying_dec=. if (buying_decision3==1 & ado_married==0) | (buying_decision4==1 & ado_married==0)

bysort survey_round: tab money_dec treat, m col freq
bysort survey_round: tab friends_dec treat, m col freq
bysort survey_round: tab buying_dec treat, m col freq

melogit money_dec treatment endline assetquintile1-assetquintile4 tribal_status adolescent_age livelihood_binary strata1-strata4 || idclus: baseline endline, cov(exch) noconstant or
melogit friends_dec treatment endline assetquintile1-assetquintile4 tribal_status adolescent_age livelihood_binary strata1-strata4 || idclus: baseline endline, cov(exch) noconstant or
melogit buying_dec treatment endline assetquintile1-assetquintile4 tribal_status adolescent_age livelihood_binary strata1-strata4 || idclus: baseline endline, cov(exch) noconstant or

	*unadjusted
melogit money_dec treatment endline || idclus: baseline endline, cov(exch) noconstant or
melogit friends_dec treatment endline  || idclus: baseline endline, cov(exch) noconstant or
melogit buying_dec treatment endline || idclus: baseline endline, cov(exch) noconstant or
	

*2.4 Mean score on the Schwarzer General Self-Efficacy (GSE) Scale 
label define gse 1 "Not at all true" 2 "Somewhat true" 3 "Exactly true"
foreach v of varlist self_efficacy_1 self_efficacy_2 self_efficacy_3 self_efficacy_4 self_efficacy_5 self_efficacy_6 {
label values `v' gse
}
label var self_efficacy_1 "Self-efficacy 1: Find means to get what I want"
label var self_efficacy_2 "Self-efficacy 2: Stick to aims and accomplish goals"
label var self_efficacy_3 "Self-efficacy 3: Confidently deal with unexpected events"
label var self_efficacy_4 "Self-efficacy 4: Resources to handle unforeseen situations"
label var self_efficacy_5 "Self-efficacy 5: Rely on my coping abilities"
label var self_efficacy_6 "Self-efficacy 6: Handles whatever comes my way"

	*Total GSE score (between 6 and 18) - for endline only
capture drop gse_score
egen gse_score = rowtotal(self_efficacy_1 self_efficacy_2 self_efficacy_3 self_efficacy_4 self_efficacy_5 self_efficacy_6) if survey_round==1
label var gse_score "GSE Score"
tab gse_score
hist gse_score
	// normally distributed, no need for log transformation

tabstat gse_score if survey_round==1, by (treat) stat (mean sd)
tab gse_score treat
preserve
keep if survey_round==1
mixed gse_score treatment assetquintile1-assetquintile4 tribal_status adolescent_age livelihood_binary strata1-strata4 || idclus: endline, cov(exch) noconstant stddev
restore
		*unadjusted
preserve
keep if survey_round==1
mixed gse_score treatment || idclus: endline, cov(exch) noconstant stddev
restore

*2.5 Mean score on the Child and Youth Resilience Measure- Revised (CYRM-R)
label define cyrm 1 "No" 2 "Sometimes" 3 "Yes"
foreach v of varlist cyrm_1 cyrm_2 cyrm_3 cyrm_4 cyrm_5 cyrm_6 cyrm_7 cyrm_8 cyrm_9 cyrm_10 {
label values `v' cyrm
}
label var cyrm_1 "CYRM 1: I cooperate wth others"
label var cyrm_2 "CYRM 2: Education is important"
label var cyrm_3 "CYRM 3: Behave in social situations"
label var cyrm_4 "CYRM 4: People like to spend time with me"
label var cyrm_5 "CYRM 5: Feel supported by my friends"
label var cyrm_6 "CYRM 6: Belong at my school / college / community"
label var cyrm_7 "CYRM 7: Friends stand by me"
label var cyrm_8 "CYRM 8: Treated fairly in my community"
label var cyrm_9 "CYRM 9: Opportunities to show I am responsible"
label var cyrm_10 "CYRM 10: Opportunities to develop skills"

*Total CYRM-R score (range should be 10 to 30) - for endline only
capture drop cyrm_score
egen cyrm_score = rowtotal(cyrm_1 cyrm_2 cyrm_3 cyrm_4 cyrm_5 cyrm_6 cyrm_7 cyrm_8 cyrm_9 cyrm_10) if survey_round==1
label var cyrm_score "CYRM-R Score"
tab cyrm_score
hist cyrm_score 
	*Log score (since it is skewed and if we want it, but not mentioned in protocol)
capture drop log_cyrm_score
gen log_cyrm_score=ln(cyrm_score) 
label var log_cyrm_score "Log CYRM-R score"
hist log_cyrm_score

tabstat cyrm_score if survey_round==1, by (treat) stat (mean sd)
tab cyrm_score treatment

preserve
keep if survey_round==1
mixed cyrm_score treatment assetquintile1-assetquintile4 tribal_status adolescent_age livelihood_binary strata1-strata4 || idclus: endline, cov(exch) noconstant stddev
restore
	*unadjusted
preserve
keep if survey_round==1
mixed cyrm_score treatment || idclus: endline, cov(exch) noconstant stddev
restore

*2.6 % experienced emotional violence in the past 12 months

**replacing values for occurance in past year and don't know/can't say as missing - for baseline only
replace ev_cursed=0 if cursed_frequency==6 & survey_round==0
replace ev_cursed=. if cursed_frequency==99 & survey_round==0
replace ev_humiliated=0 if humiliated_frequency==6 & survey_round==0
replace ev_humiliated=. if humiliated_frequency==99 & survey_round==0
replace ev_scare=0 if scare_frequency==6 & survey_round==0
replace ev_scare=. if scare_frequency==99 & survey_round==0
replace ev_forced=0 if forced_frequency==6 & survey_round==0
replace ev_forced=. if forced_frequency==99 & survey_round==0
replace ev_madetowork=0 if made_to_work_frequency==6 & survey_round==0
replace ev_madetowork=. if made_to_work_frequency==99 & survey_round==0

capture drop ev_12m
egen ev_12m = anymatch (ev_cursed ev_humiliated ev_scare ev_forced ev_madetowork), v(1)
label variable ev_12 "Experienced emotional violence in the past year"
label define ev12 0 "No" 1 "Yes"
label values ev_12m ev12

bysort survey_round:tab ev_12m treat, m col freq

melogit ev_12m treatment endline assetquintile1-assetquintile4 tribal_status adolescent_age livelihood_binary strata1-strata4 || idclus: baseline endline, cov(exch) noconstant or

	*unadjusted
melogit ev_12m treatment endline || idclus: baseline endline, cov(exch) noconstant or

*2.7 % experienced physical violence in the past 12 months
**replacing values for occurance in past year and don't know/can't say as missing - for baseline only
replace pv_twisted=0 if twisted_frequency==6 & survey_round==0
replace pv_twisted=. if twisted_frequency==99 & survey_round==0
replace pv_threatened=0 if threatened_frequency==6 & survey_round==0
replace pv_threatened=. if threatened_frequency==99 & survey_round==0
replace pv_choked=0 if choked_frequency==6 & survey_round==0
replace pv_choked=. if choked_frequency==99 & survey_round==0
replace pv_punched=0 if punched_frequency==6 & survey_round==0
replace pv_punched=. if punched_frequency==99 & survey_round==0
replace pv_beaten=0 if beaten_frequency==6 & survey_round==0
replace pv_beaten=. if beaten_frequency==99 & survey_round==0

capture drop pv_12m
egen pv_12m = anymatch (pv_twisted pv_threatened pv_choked pv_punched pv_beaten), v(1)
label var pv_12m "Experienced physical violence in the past year"
label define pv12 0 "No" 1 "Yes"
label values pv_12m pv12

bysort survey_round:tab pv_12m treat, m col freq

melogit pv_12m treatment endline assetquintile1-assetquintile4 tribal_status adolescent_age livelihood_binary strata1-strata4 || idclus: baseline endline, cov(exch) noconstant or

		*unadjusted
melogit pv_12m treatment endline || idclus: baseline endline, cov(exch) noconstant or


*2.8 % intervening to reduce emotional violence in the past 12 months
label define ev 0 "No" 1 "Yes"
foreach v of varlist ev_cursing_bystander ev_humiliating_bystander ev_scaring_bystander ev_forcing_bystander ev_makingtowork_bystander {
replace `v' = . if `v'==99
label values `v' ev
}
label var ev_cursing_bystander "Bystander: cursing"
label var ev_humiliating_bystander "Bystander: humiliating"
label var ev_scaring_bystander "Bystander: scaring"
label var ev_forcing_bystander "Bystander: forcing"
label var ev_makingtowork_bystander "Bystander: made to work"

tab1 ev_cursing_bystander ev_humiliating_bystander ev_scaring_bystander ev_forcing_bystander ev_makingtowork_bystander

	*check item non-response pattern
misstable pattern ev_cursing_bystander ev_humiliating_bystander ev_scaring_bystander ev_forcing_bystander ev_makingtowork_bystander if survey_round==1
		//none with missing data on all. We will ignore item non-response, so it should be 1478 in the final var

	*Variable for any intervention
capture drop ev_bystander
egen ev_bystander=anymatch(ev_cursing_bystander ev_humiliating_bystander ev_scaring_bystander ev_forcing_bystander ev_makingtowork_bystander), v(1)
replace ev_bystander=. if ev_cursing_bystander==. & ev_humiliating_bystander==. & ev_scaring_bystander==. & ev_forcing_bystander==. & ///
ev_makingtowork_bystander==.
label var ev_bystander "Emotional violence: Any bystander intervention"
label values ev_bystander ev

tab ev_bystander treat if survey_round==1, m col freq

preserve
keep if survey_round==1
melogit ev_bystander treatment assetquintile1-assetquintile4 tribal_status adolescent_age livelihood_binary strata1-strata4 || idclus: endline, cov(exch) noconstant or
restore

			*unadjusted
preserve
keep if survey_round==1
melogit ev_bystander treatment || idclus: endline, cov(exch) noconstant or
restore

*2.9 % intervening to reduce physical violence in the past 12 months
label define pv 0 "No" 1 "Yes"
foreach v of varlist pv_twisting_bystander pv_threatening_bystander pv_choking_bystander pv_punching_bystander pv_beating_bystander {
replace `v' =. if `v'==99
label values `v' pv
}
label var pv_twisting_bystander "Bystander: twisting" 
label var pv_threatening_bystander "Bystander: threatening"
label var pv_choking_bystander "Bystander: choking"
label var pv_punching_bystander "Bystander: punching"
label var pv_beating_bystander "Bystander: beating"

tab1 pv_twisting_bystander pv_threatening_bystander pv_choking_bystander pv_punching_bystander pv_beating_bystander

misstable pattern pv_twisting_bystander pv_threatening_bystander pv_choking_bystander pv_punching_bystander pv_beating_bystander if survey_round==1
	//some are missing data on all five. Will ignore item non-response, but final var will have <1478 obs

	*Variable for any bystander intervention re. physical violence
capture drop pv_bystander
egen pv_bystander = anymatch(pv_twisting_bystander pv_threatening_bystander pv_choking_bystander pv_punching_bystander pv_beating_bystander), v(1)
replace pv_bystander=. if pv_twisting_bystander==. & pv_threatening_bystander==. & pv_choking_bystander==. & pv_punching_bystander==. ///
& pv_beating_bystander==.
label var pv_bystander "Physical violence: any bystander intervention"
label values pv_bystander pv
tab pv_bystander treat if survey_round==1, col freq
	//1477 obs
preserve
keep if survey_round==1
melogit pv_bystander treatment assetquintile1-assetquintile4 tribal_status adolescent_age livelihood_binary strata1-strata4 || idclus: endline, cov(exch) noconstant or
restore
	
		*unadjusted
preserve
keep if survey_round==1
melogit pv_bystander treatment || idclus: endline, cov(exch) noconstant or
restore


*2.10 % absence from school in the past 2 weeks
capture drop absence
recode absence_p2w (0=0 "No") (1=1 "Yes") (99=.), gen (absence)
label var absence "Absent from school in the past 2 weeks"

bysort survey_round: tab absence treat if currently_attends_school>=1, m col freq

preserve
keep if currently_attends_school>=1
melogit absence treatment endline  assetquintile1-assetquintile4 tribal_status adolescent_age livelihood_binary strata1-strata4 || idclus: baseline endline, cov(exch) noconstant or
restore

		*unadjusted
preserve
keep if currently_attends_school>=1
melogit absence treatment endline  || idclus: baseline endline, cov(exch) noconstant or
restore


*2.11 % accessing at least one school-related entitlement

	*at endline, 489 participants are not in school and therefore have "." for this indicator. Denominator is 989 obs.
			
recode _school_entitlements1 1=0 if _school_entitlements1==1 & (_school_entitlements2==1| _school_entitlements3==1| _school_entitlements4==1| ///
 _school_entitlements5==1)
capture drop any_school_entitlement
egen any_school_entitlement = anymatch (_school_entitlements2 _school_entitlements3 _school_entitlements4 _school_entitlements5), v(1)
replace any_school_entitlement=0 if _school_entitlements1==1
label var any_school_entitlement "At least one school-based entitlement"
label define schoolentitlement 1 "Yes" 0 "No"
label values any_school_entitlement schoolentitlement

tab any_school_entitlement treat if survey_round==1 & currently_attends_school>=1,m col freq

preserve
keep if survey_round==1 & currently_attends_school>=1
melogit any_school_entitlement treatment assetquintile1-assetquintile4 tribal_status adolescent_age livelihood_binary strata1-strata4 || idclus: endline, cov(exch) noconstant or
restore

	*unadjusted
preserve
keep if survey_round==1 & currently_attends_school>=1
melogit any_school_entitlement treatment || idclus: endline, cov(exch) noconstant or
restore

*2.12 % drank alcohol in the past month
capture drop alcohol_pm
recode number_alcoholic_drinks_l1m (0=0 "No") (1/5=1 "Yes"), gen(alcohol_pm)
label var alcohol_pm "Drank alcohol in the past month"

bysort survey_round: tab alcohol_pm treat if alcohol_ever==1, m col freq

preserve
keep if alcohol_ever==1
melogit alcohol_pm treatment endline  assetquintile1-assetquintile4 tribal_status adolescent_age livelihood_binary strata1-strata4 || idclus: baseline endline, cov(exch) noconstant or
restore

		*unadjusted
preserve
keep if alcohol_ever==1
melogit alcohol_pm treatment endline || idclus: baseline endline, cov(exch) noconstant or
restore

** END OF ANALYSES**

*Instruction to user: close log file

