[33mcommit 60ba091a929e895e626a5c6f7708732548be6264[m[33m ([m[1;36mHEAD[m[33m -> [m[1;32mmain[m[33m, [m[1;31morigin/main[m[33m)[m
Author: Your Name <109754949+singhsaurabh88@users.noreply.github.com>
Date:   Sun Mar 23 18:57:24 2025 -0400

    Add SAS and Excel files for KPI and Card Monthly Report analysis

[1mdiff --git a/Appropriateness_Weekly_KPI_Report_Dummy_Data.xlsx b/Appropriateness_Weekly_KPI_Report_Dummy_Data.xlsx[m
[1mnew file mode 100644[m
[1mindex 0000000..f63618d[m
Binary files /dev/null and b/Appropriateness_Weekly_KPI_Report_Dummy_Data.xlsx differ
[1mdiff --git a/Appropriateness_Weekly_KPI_Report_Dummy_Data_Analysis.sas b/Appropriateness_Weekly_KPI_Report_Dummy_Data_Analysis.sas[m
[1mnew file mode 100644[m
[1mindex 0000000..b405df0[m
[1m--- /dev/null[m
[1m+++ b/Appropriateness_Weekly_KPI_Report_Dummy_Data_Analysis.sas[m
[36m@@ -0,0 +1,209 @@[m
[32m+[m
[32m+[m[32m/* Step 1: Import the Datasets */[m
[32m+[m[32m/* Import the Sales dataset */[m
[32m+[m[32mPROC IMPORT DATAFILE="/home/u1558213/sasuser.v94/case_stuy/Appropriateness_Weekly_KPI_Report_Dummy_Data.xlsx"[m
[32m+[m[32m            OUT=work.sales[m
[32m+[m[32m            DBMS=xlsx[m
[32m+[m[32m            REPLACE;[m
[32m+[m[32m    SHEET="Sales";         /* Specify the sheet name */[m
[32m+[m[32m    GETNAMES=YES;          /* Use the first row as variable names */[m
[32m+[m[32mRUN;[m
[32m+[m
[32m+[m[32m/* Print the first few rows to verify the data import */[m
[32m+[m[32mproc print data=work.sales (obs=5);[m
[32m+[m[32mrun;[m
[32m+[m
[32m+[m[32m/* checking data in work.sales after import */[m
[32m+[m[32mproc contents data=work.sales;[m
[32m+[m[32mrun;[m
[32m+[m
[32m+[m[32m/* Import the Notes dataset */[m
[32m+[m[32mPROC IMPORT DATAFILE="/home/u1558213/sasuser.v94/case_stuy/Appropriateness_Weekly_KPI_Report_Dummy_Data.xlsx"[m
[32m+[m[32m            OUT=work.notes[m
[32m+[m[32m            DBMS=xlsx[m
[32m+[m[32m            REPLACE;[m
[32m+[m[32m    SHEET="Notes";         /* Specify the sheet name */[m
[32m+[m[32m    GETNAMES=YES;          /* Use the first row as variable names */[m
[32m+[m[32mRUN;[m
[32m+[m
[32m+[m[32m/* Print the first few rows to verify the data import */[m
[32m+[m[32mproc print data=work.notes (obs=5);[m
[32m+[m[32mrun;[m
[32m+[m
[32m+[m[32m/* checking data in work.notes after import */[m
[32m+[m[32mproc contents data=work.notes;[m
[32m+[m[32mrun;[m
[32m+[m
[32m+[m[32m/* Import the Regions dataset */[m
[32m+[m[32mPROC IMPORT DATAFILE="/home/u1558213/sasuser.v94/case_stuy/Appropriateness_Weekly_KPI_Report_Dummy_Data.xlsx"[m
[32m+[m[32m            OUT=work.regions[m
[32m+[m[32m            DBMS=xlsx[m
[32m+[m[32m            REPLACE;[m
[32m+[m[32m    SHEET="Regions";         /* Specify the sheet name */[m
[32m+[m[32m    GETNAMES=YES;          /* Use the first row as variable names */[m
[32m+[m[32mRUN;[m
[32m+[m
[32m+[m[32m/* Print the first few rows to verify the data import */[m
[32m+[m[32mproc print data=work.regions (obs=5);[m
[32m+[m[32mrun;[m
[32m+[m
[32m+[m
[32m+[m[32m/* checking data in work.regions after import */[m
[32m+[m[32mproc contents data=work.regions;[m
[32m+[m[32mrun;[m
[32m+[m
[32m+[m[32m/* Step 2: Filter Eligible Transaction Types */[m
[32m+[m[32m/* a.	Across eligible transaction types (new account, new credit card, new term purchase) */[m
[32m+[m[32m/* Filter Sales for eligible transaction types */[m
[32m+[m[32mproc sql;[m
[32m+[m[32m    create table sales_filtered as[m
[32m+[m[32m    select *[m
[32m+[m[32m    from work.sales[m
[32m+[m[32m    where sale_transaction_type in ('New Account', 'New Credit Card', 'New Term Purchase');[m
[32m+[m[32mquit;[m
[32m+[m
[32m+[m
[32m+[m[32m/* Step 3: Join Sales with Regions */[m
[32m+[m[32m/* b.	Across select regions (Greater Toronto, BC & Yukon, Atlantic Provinces) */[m
[32m+[m[32m/* Left Join Sales with Regions to add region_name */[m
[32m+[m[32mproc sql;[m
[32m+[m[32m    create table sales_with_region as[m
[32m+[m[32m    select s.*, r.region_name[m
[32m+[m[32m    from sales_filtered s[m
[32m+[m[32m    left join work.regions r[m
[32m+[m[32m    on s.transit_id = r.transit_id;[m
[32m+[m[32mquit;[m
[32m+[m
[32m+[m[32m/*[m
[32m+[m[32mIssue Identified:[m
[32m+[m
[32m+[m[32m1. In the Sales dataset, sale_ocif_id values start with "000000" (such as 000000881406140),[m[41m [m
[32m+[m[32mindicating that they are stored as character strings with leading zeros and for padding[m
[32m+[m
[32m+[m[32m2. In the Notes dataset, note_ocif_id values are numeric-like (such as 585886457), without leading zeros,[m[41m [m
[32m+[m[32mpossibly stored as a numeric field or a character field without padding.[m
[32m+[m
[32m+[m[32m3. This mismatch means a direct join on sale_ocif_id = note_ocif_id will fail because 000000881406140 does not equal 881406140,[m[41m [m
[32m+[m[32meven though they likely represent the same identifier after removing the leading zeros.[m
[32m+[m
[32m+[m[32m*/[m
[32m+[m
[32m+[m[32m/* Step 4: Clean sale_ocif_id */[m
[32m+[m
[32m+[m[32mproc sql;[m
[32m+[m[32m    create table sales_with_cleaned as[m
[32m+[m[32m    select *,[m
[32m+[m[32m           substr(sale_ocif_id, 7) as sale_ocif_id_cleaned length=9[m
[32m+[m[32m    from sales_with_region;[m
[32m+[m[32mquit;[m
[32m+[m
[32m+[m[32m/* Display the result to verify */[m
[32m+[m[32mproc print data=sales_with_cleaned;[m
[32m+[m[32m    var sale_ocif_id sale_ocif_id_cleaned;[m
[32m+[m[32m    title "Sales Data with Cleaned sale_ocif_id (Positions 7 to 15)";[m
[32m+[m[32mrun;[m
[32m+[m
[32m+[m[32m/* Verify the length of sale_ocif_id_cleaned */[m
[32m+[m[32mproc contents data=sales_with_cleaned;[m
[32m+[m[32mrun;[m
[32m+[m
[32m+[m[32m/* Step 5: Join Sales with Notes */[m
[32m+[m
[32m+[m[32m/* Join sales_with_cleaned with work.notes */[m
[32m+[m[32mproc sql;[m
[32m+[m[32m    create table sales_notes_joined as[m
[32m+[m[32m    select s.*,[m
[32m+[m[32m           put(n.note_ocif_id, 9.) as note_ocif_id_cleaned length=9,[m
[32m+[m[32m           n.appropriateness_completion_flag,[m
[32m+[m[32m           n.note_id,[m
[32m+[m[32m           n.note_transaction_type,[m
[32m+[m[32m           n.note_create_date[m
[32m+[m[32m    from sales_with_cleaned s[m
[32m+[m[32m    left join work.notes n[m
[32m+[m[32m    on s.sale_ocif_id_cleaned = put(n.note_ocif_id, 9.);[m
[32m+[m[32mquit;[m
[32m+[m
[32m+[m[32m/* QA Check: Verify the join success */[m
[32m+[m[32mproc sql;[m
[32m+[m[32m    create table unmatched_sales as[m
[32m+[m[32m    select count(*) as unmatched_sales[m
[32m+[m[32m    from sales_notes_joined[m
[32m+[m[32m    where note_ocif_id_cleaned is null;[m
[32m+[m[32mquit;[m
[32m+[m
[32m+[m[32m/* Display a sample of the joined table */[m
[32m+[m[32mproc print data=sales_notes_joined (obs=5);[m
[32m+[m[32m    var sale_ocif_id sale_ocif_id_cleaned note_ocif_id_cleaned appropriateness_completion_flag;[m
[32m+[m[32m    title "Sample of Joined Sales and Notes Data";[m
[32m+[m[32mrun;[m
[32m+[m
[32m+[m
[32m+[m[32m/* Step 6: Create has_note_flag[m
[32m+[m[32mPurpose: Create a binary flag has_note_flag to indicate whether a sale has an appropriate note:[m
[32m+[m
[32m+[m[32m1 if appropriateness_completion_flag = 'Yes'.[m
[32m+[m[32m0 if appropriateness_completion_flag = 'No', null, or blank.[m[41m [m
[32m+[m[32m*/[m
[32m+[m[32mproc sql;[m
[32m+[m[32m    create table sales_notes_with_flag as[m
[32m+[m[32m    select *,[m
[32m+[m[32m           case[m[41m [m
[32m+[m[32m               when appropriateness_completion_flag = 'Yes' then 1[m
[32m+[m[32m               when appropriateness_completion_flag = 'No' or appropriateness_completion_flag is null or appropriateness_completion_flag = '' then 0[m
[32m+[m[32m               else .[m
[32m+[m[32m           end as has_note_flag[m
[32m+[m[32m    from sales_notes_joined;[m
[32m+[m[32mquit;[m
[32m+[m
[32m+[m
[32m+[m[32m/* Step 7: Assign Weekly Periods */[m
[32m+[m
[32m+[m[32mdata sales_notes_with_weeks;[m
[32m+[m[32m    set sales_notes_with_flag;[m
[32m+[m[32m    week_start_date = intnx('week.6', sale_date, 0, 'B');[m
[32m+[m[32m    if sale_date < week_start_date then week_start_date = intnx('week.6', sale_date, -1, 'B');[m
[32m+[m[32m    week_number = intck('week', '03JUN2022'd, week_start_date) + 1;[m
[32m+[m[32m    week_label = cats("Week ", week_number, ": ", put(week_start_date, yymmdd10.), " to ", put(intnx('day', week_start_date, 6), yymmdd10.));[m
[32m+[m[32mrun;[m
[32m+[m
[32m+[m[32m/* Step 8: Create the Weekly Report */[m
[32m+[m[32mproc sql;[m
[32m+[m[32m    create table weekly_report as[m
[32m+[m[32m    select[m[41m [m
[32m+[m[32m        week_label,[m
[32m+[m[32m        sale_transaction_type,[m
[32m+[m[32m        region_name,[m
[32m+[m[32m        count(*) as total_sales,[m
[32m+[m[32m        sum(has_note_flag) as sales_with_notes,[m
[32m+[m[32m        (sum(has_note_flag) / count(*)) as completion_rate format=percent8.1[m
[32m+[m[32m    from sales_notes_with_weeks[m
[32m+[m[32m    where region_name in ('Greater Toronto (GT)', 'BC & Yukon (BCY)', 'Atlantic Provinces (AP)')[m
[32m+[m[32m    group by week_label, sale_transaction_type, region_name[m
[32m+[m[32m    order by week_label, sale_transaction_type, region_name;[m
[32m+[m[32mquit;[m
[32m+[m
[32m+[m[32m/* Step 9: Create the Aggregated Report */[m
[32m+[m[32mproc sql;[m
[32m+[m[32m    create table aggregated_report as[m
[32m+[m[32m    select[m[41m [m
[32m+[m[32m        'Since Inception' as period,[m
[32m+[m[32m        sale_transaction_type,[m
[32m+[m[32m        region_name,[m
[32m+[m[32m        count(*) as total_sales,[m
[32m+[m[32m        sum(has_note_flag) as sales_with_notes,[m
[32m+[m[32m        (sum(has_note_flag) / count(*)) as completion_rate format=percent8.1[m
[32m+[m[32m    from sales_notes_with_weeks[m
[32m+[m[32m    where region_name in ('Greater Toronto (GT)', 'BC & Yukon (BCY)', 'Atlantic Provinces (AP)')[m
[32m+[m[32m    group by sale_transaction_type, region_name[m
[32m+[m[32m    order by sale_transaction_type, region_name;[m
[32m+[m[32mquit;[m
[32m+[m
[32m+[m
[32m+[m[32m/* Step 10: Display the Reports */[m
[32m+[m[32mproc print data=weekly_report;[m
[32m+[m[32m    title "Weekly Appropriateness Completion Report";[m
[32m+[m[32mrun;[m
[32m+[m
[32m+[m[32mproc print data=aggregated_report;[m
[32m+[m[32m    title "Aggregated Appropriateness Completion Report (Since Inception)";[m
[32m+[m[32mrun;[m
[1mdiff --git a/Output_summary_appropriateness_report.xlsx b/Output_summary_appropriateness_report.xlsx[m
[1mnew file mode 100644[m
[1mindex 0000000..18e6fd8[m
Binary files /dev/null and b/Output_summary_appropriateness_report.xlsx differ
[1mdiff --git a/SB_Card_Monthly_Report_Dummy_Data.sas b/SB_Card_Monthly_Report_Dummy_Data.sas[m
[1mnew file mode 100644[m
[1mindex 0000000..f9e1ea6[m
[1m--- /dev/null[m
[1m+++ b/SB_Card_Monthly_Report_Dummy_Data.sas[m
[36m@@ -0,0 +1,302 @@[m
[32m+[m
[32m+[m[32m/* Step 1: Import the Excel file into a SAS dataset */[m
[32m+[m
[32m+[m[32mPROC IMPORT DATAFILE="/home/u1558213/sasuser.v94/case_stuy/SB_Card_Monthly_Report_Dummy_Data.xlsx"[m
[32m+[m[32m            OUT=work.sb_card_data[m
[32m+[m[32m            DBMS=xlsx[m
[32m+[m[32m            REPLACE;[m
[32m+[m[32m    SHEET="Sheet1"; /* Specify the sheet name */[m
[32m+[m[32m    GETNAMES=YES; /* Use the first row as variable names */[m
[32m+[m[32mRUN;[m
[32m+[m
[32m+[m[32m/* Print the first few rows to verify the data import */[m
[32m+[m[32mproc print data=work.sb_card_data (obs=5);[m
[32m+[m[32mrun;[m
[32m+[m
[32m+[m[32m/*Check the data type of all Columns */[m
[32m+[m[32mproc contents data=work.sb_card_data;[m
[32m+[m[32mrun;[m
[32m+[m
[32m+[m
[32m+[m[32m/*-----------Final Solution -------------------*/[m
[32m+[m[32m/* Step 1: Remove test data */[m
[32m+[m[32mproc sql;[m
[32m+[m[32m   create table sb_card_data_cleaned as[m
[32m+[m[32m   select *[m
[32m+[m[32m   from work.sb_card_data[m
[32m+[m[32m   where upcase(customer_name) not like '%TEST%';[m
[32m+[m[32mquit;[m
[32m+[m[32m/* Total records after Step 1 =995 */[m
[32m+[m
[32m+[m[32m/* Step 2: Include only July open_date (already satisfied, but included for clarity) */[m
[32m+[m[32mproc sql;[m
[32m+[m[32m   create table sb_card_data_cleaned_july as[m
[32m+[m[32m   select *[m
[32m+[m[32m   from sb_card_data_cleaned[m
[32m+[m[32m   where open_date between '01JUL2022'd and '31JUL2022'd;[m
[32m+[m[32mquit;[m
[32m+[m
[32m+[m[32m/* Total records after Step 2 =995 */[m
[32m+[m
[32m+[m[32m/* Step 3: Remove closed accounts (only those with closed_date in July or August 2022) */[m
[32m+[m[32mproc sql;[m
[32m+[m[32m   create table sb_card_data_open as[m
[32m+[m[32m   select *[m
[32m+[m[32m   from sb_card_data_cleaned_july[m
[32m+[m[32m   where closed_date is null[m
[32m+[m[32m      or closed_date not between '01JUL2022'd and '31AUG2022'd;[m
[32m+[m[32mquit;[m
[32m+[m[32m/* Total records after Step 3 =990 */[m
[32m+[m
[32m+[m[32m/* Step 3.5: Calculate missing values after Step 3 */[m
[32m+[m[32mproc sql;[m
[32m+[m[32m    create table missing_data_flags as[m
[32m+[m[32m    select *,[m
[32m+[m[32m           case when employee_id is null or employee_id = '' then 1 else 0 end as missing_employee_id,[m
[32m+[m[32m           case when transit_id = '' or transit_id = '0' then 1 else 0 end as missing_transit_id,[m
[32m+[m[32m           case when customer_id is null then 1 else 0 end as missing_customer_id,[m
[32m+[m[32m           case when entity_type is null then 1 else 0 end as missing_entity_type[m
[32m+[m[32m    from sb_card_data_open;[m
[32m+[m[32mquit;[m
[32m+[m
[32m+[m[32mproc sql;[m
[32m+[m[32m   create table missing_data_summary as[m
[32m+[m[32m   select sum(missing_employee_id) as total_missing_employee_id,[m
[32m+[m[32m          sum(missing_transit_id) as total_missing_transit_id,[m
[32m+[m[32m          sum(missing_customer_id) as total_missing_customer_id,[m
[32m+[m[32m          sum(missing_entity_type) as total_missing_entity_type[m
[32m+[m[32m   from missing_data_flags;[m
[32m+[m[32mquit;[m
[32m+[m
[32m+[m[32m/* Total records after Step 3.5 =990 */[m
[32m+[m
[32m+[m[32m/* Step 4: Remove records with missing employee_id and customer_type */[m
[32m+[m[32mproc sql;[m
[32m+[m[32m   create table sb_card_data_final as[m
[32m+[m[32m   select *[m
[32m+[m[32m   from missing_data_flags[m
[32m+[m[32m   where customer_type is not null[m
[32m+[m[32m     and customer_type <> ''[m
[32m+[m[32m     and missing_employee_id = 0; /* Using the flag from missing_data_flags */[m
[32m+[m[32mquit;[m
[32m+[m[32m/* Total records after Step 4=839 */[m
[32m+[m
[32m+[m[32m/* Step 5: Identify Existing and New customers and apply audit criteria */[m
[32m+[m[32mproc sql;[m
[32m+[m[32m   create table audit_scope as[m
[32m+[m[32m   select *,[m
[32m+[m[32m          case[m[41m [m
[32m+[m[32m             when customer_type = 'Existing' then 1[m
[32m+[m[32m             when customer_type = 'New' then 2[m
[32m+[m[32m             else 0[m
[32m+[m[32m          end as customer_category, /* 1 = Existing, 2 = New, 0 = Missing (already excluded) */[m
[32m+[m[32m          case[m[41m [m
[32m+[m[32m             when customer_type = 'Existing' then 1 /* 5% will be selected later */[m
[32m+[m[32m             when customer_type = 'New' then 1 /* 100% in scope */[m
[32m+[m[32m             else 0[m
[32m+[m[32m          end as in_scope_flag[m
[32m+[m[32m   from sb_card_data_final;[m
[32m+[m[32mquit;[m
[32m+[m
[32m+[m[32m/* Total records after Step 5=839 */[m
[32m+[m
[32m+[m[32m/* Step 6: Calculate the volume in scope for audit */[m
[32m+[m[32m/* For Existing customers, randomly select 5% using a DATA step */[m
[32m+[m[32mdata audit_scope_selected;[m
[32m+[m[32m   set audit_scope;[m
[32m+[m[32m   /* Generate a random number for Existing customers to select 5% */[m
[32m+[m[32m   if customer_category = 1 then do;[m
[32m+[m[32m      random_num = ranuni(123); /* Random number between 0 and 1 */[m
[32m+[m[32m      if random_num <= 0.05 then in_scope_flag = 1; /* 5% chance of being selected */[m
[32m+[m[32m      else in_scope_flag = 0;[m
[32m+[m[32m   end;[m
[32m+[m[32mrun;[m
[32m+[m[32m/* Total records after Step  =839 */[m
[32m+[m
[32m+[m[32m/* Step 7: Count the total applications in scope */[m
[32m+[m[32mproc sql;[m
[32m+[m[32m   create table final_volume as[m
[32m+[m[32m   select sum(case when customer_category = 1 and in_scope_flag = 1 then 1 else 0 end) as existing_in_scope,[m
[32m+[m[32m          sum(case when customer_category = 2 and in_scope_flag = 1 then 1 else 0 end) as new_in_scope,[m
[32m+[m[32m          sum(in_scope_flag) as total_in_scope[m
[32m+[m[32m   from audit_scope_selected;[m
[32m+[m[32mquit;[m
[32m+[m[32m/* Total records after Step 7=238 */[m
[32m+[m
[32m+[m[32m/* Display the final volume */[m
[32m+[m[32mproc print data=final_volume;[m
[32m+[m[32m    title "Volume of Applications in Scope for Audit (Shared with Operations)";[m
[32m+[m[32mrun;[m
[32m+[m[32m/*-------------Final Solution Closed------------------*/[m
[32m+[m
[32m+[m[32m/*****************************************************************************************************************/[m
[32m+[m[32m/*------------------------------Additional/Other Random Calculations Start---------------------------------------------------------*/[m
[32m+[m[32m/****************************************************************************************************************/[m
[32m+[m[32m/* 1.1 Checking the closed date column values  */[m
[32m+[m[32mproc sql;[m
[32m+[m[32m   create table closed_date_july_august as[m
[32m+[m[32m   select *,[m
[32m+[m[32m          closed_date as closed_date_formatted format=date9.[m
[32m+[m[32m   from work.sb_card_data[m
[32m+[m[32m   where closed_date is not null[m
[32m+[m[32m     and closed_date between '01JUL2022'd and '31AUG2022'd;[m
[32m+[m[32mquit;[m
[32m+[m
[32m+[m[32mproc print data=closed_date_july_august;[m
[32m+[m[32m    title "Records with closed_date in July or August 2022";[m
[32m+[m[32mrun;[m
[32m+[m
[32m+[m
[32m+[m[32m/*---------------------------------------------------------------------------------------*/[m
[32m+[m
[32m+[m
[32m+[m[32m/* Check for test data names in customer_name column */[m
[32m+[m[32mproc sql;[m
[32m+[m[32m   /* Create a table with a flag for test data names */[m
[32m+[m[32m   create table customer_name_test_check as[m
[32m+[m[32m   select *,[m
[32m+[m[32m          case when upcase(customer_name) like '%TEST%' then 1 else 0 end as is_test_data[m
[32m+[m[32m   from work.sb_card_data;[m
[32m+[m
[32m+[m[32m   /* Summarize the count and percentage of test data names */[m
[32m+[m[32m   create table test_data_summary as[m
[32m+[m[32m   select sum(is_test_data) as total_test_data_rows,[m
[32m+[m[32m          count(*) as total_rows,[m
[32m+[m[32m          calculated total_test_data_rows / calculated total_rows * 100 as percent_test_data[m
[32m+[m[32m   from customer_name_test_check;[m
[32m+[m
[32m+[m[32m   /* List the records with test data names */[m
[32m+[m[32m   create table test_data_records as[m
[32m+[m[32m   select card_number, customer_name, open_date, closed_date, card_application_system,[m[41m [m
[32m+[m[32m          employee_id, transit_id, customer_id, customer_type, entity_type[m
[32m+[m[32m   from customer_name_test_check[m
[32m+[m[32m   where is_test_data = 1;[m
[32m+[m[32mquit;[m
[32m+[m
[32m+[m[32m/* Display the summary */[m
[32m+[m[32mproc print data=test_data_summary;[m
[32m+[m[32m    title "Summary of Test Data Names in customer_name";[m
[32m+[m[32mrun;[m
[32m+[m
[32m+[m[32m/* Display the records with test data names */[m
[32m+[m[32mproc print data=test_data_records;[m
[32m+[m[32m    title "Records with Test Data Names in customer_name";[m
[32m+[m[32mrun;[m
[32m+[m
[32m+[m[32m/*---------------------------------------------------------------------------------------*/[m
[32m+[m
[32m+[m[32m/* 1.1 : Data Filterng: Checking the range of values in open_date column (All in July 2022) */[m
[32m+[m[32mproc sql;[m
[32m+[m[32m    create table open_date_check as[m
[32m+[m[32m    select open_date format=date9.,[m[41m [m
[32m+[m[32m           min(open_date) as min_open_date format=date9.,[m
[32m+[m[32m           max(open_date) as max_open_date format=date9.,[m
[32m+[m[32m           count(*) as total_rows,[m
[32m+[m[32m           sum(case when open_date between '01JUL2022'd and '31JUL2022'd then 1 else 0 end) as rows_in_july_2022[m
[32m+[m[32m    from work.sb_card_data;[m
[32m+[m[32mquit;[m
[32m+[m
[32m+[m[32mproc sql;[m
[32m+[m[32m    create table open_date_check1 as[m
[32m+[m[32m    select a.*,[m
[32m+[m[32m           /* Format open_date as date9. (already a SAS date) */[m
[32m+[m[32m           open_date format=date9.,[m[41m [m
[32m+[m[32m           /* Summary statistics computed over the entire dataset */[m
[32m+[m[32m            open_date format=date9.,[m[41m [m
[32m+[m[32m           min(open_date) as min_open_date format=date9.,[m
[32m+[m[32m           max(open_date) as max_open_date format=date9.,[m
[32m+[m[32m           count(*) as total_rows,[m
[32m+[m[32m           sum(case when open_date between '01JUL2022'd and '31JUL2022'd then 1 else 0 end) as rows_in_july_2022[m
[32m+[m[32m    from work.sb_card_data a;[m
[32m+[m[32mquit;[m
[32m+[m
[32m+[m
[32m+[m[32m/* Display the results */[m
[32m+[m[32mproc print data=open_date_check1;[m
[32m+[m[32m   title "Open Date Range Analysis";[m
[32m+[m[32mrun;[m
[32m+[m
[32m+[m[32m/* Step 2: Data Distribution */[m
[32m+[m[32m/* 2.1: calculating missing values for (employee_id,transit_id, customer_id,entity_type) */[m
[32m+[m
[32m+[m[32mproc sql;[m
[32m+[m[32m    create table missing_data_flags as[m
[32m+[m[32m    select *,[m
[32m+[m[32m           case when employee_id is null or employee_id = '' then 1 else 0 end as missing_employee_id,[m
[32m+[m[32m           case when transit_id = '' or transit_id = '0' then 1 else 0 end as missing_transit_id,[m
[32m+[m[32m           case when customer_id is null then 1 else 0 end as missing_customer_id,[m
[32m+[m[32m           case when entity_type is null then 1 else 0 end as missing_entity_type[m
[32m+[m[32m    from work.sb_card_data;[m
[32m+[m[32mquit;[m
[32m+[m
[32m+[m
[32m+[m[32m/* Step 6: Summarize missing data issues */[m
[32m+[m[32mproc sql;[m
[32m+[m[32m   create table missing_data_summary as[m
[32m+[m[32m   select sum(missing_employee_id) as total_missing_employee_id,[m
[32m+[m[32m          sum(missing_transit_id) as total_missing_transit_id,[m
[32m+[m[32m          sum(missing_customer_id) as total_missing_customer_id,[m
[32m+[m[32m          sum(missing_entity_type) as total_missing_entity_type[m
[32m+[m[32m   from missing_data_flags;[m
[32m+[m[32mquit;[m
[32m+[m
[32m+[m
[32m+[m[32mproc print data=missing_data_summary;[m
[32m+[m[32m   title "Summary of Missing Mandatory Fields";[m
[32m+[m[32mrun;[m
[32m+[m
[32m+[m[32m/*----------Right code for searching missing value-----------------------------*/[m
[32m+[m
[32m+[m[32m/* Check for missing values in all columns */[m
[32m+[m[32mproc sql;[m
[32m+[m[32m   create table missing_values_summary as[m
[32m+[m[32m   select 'card_number' as column_name,[m
[32m+[m[32m          sum(case when card_number is null then 1 else 0 end) as missing_count[m
[32m+[m[32m   from work.sb_card_data[m
[32m+[m[32m   union[m
[32m+[m[32m   select 'open_date' as column_name,[m
[32m+[m[32m          sum(case when open_date is null then 1 else 0 end) as missing_count[m
[32m+[m[32m   from work.sb_card_data[m
[32m+[m[32m   union[m
[32m+[m[32m   select 'closed_date' as column_name,[m
[32m+[m[32m          sum(case when closed_date is null then 1 else 0 end) as missing_count[m
[32m+[m[32m   from work.sb_card_data[m
[32m+[m[32m   union[m
[32m+[m[32m   select 'card_application_system' as column_name,[m
[32m+[m[32m          sum(case when card_application_system is null or card_application_system = '' then 1 else 0 end) as missing_count[m
[32m+[m[32m   from work.sb_card_data[m
[32m+[m[32m   union[m
[32m+[m[32m   select 'employee_id' as column_name,[m
[32m+[m[32m          sum(case when employee_id is null or employee_id = '' then 1 else 0 end) as missing_count[m
[32m+[m[32m   from work.sb_card_data[m
[32m+[m[32m   union[m
[32m+[m[32m   select 'transit_id' as column_name,[m
[32m+[m[32m          sum(case when transit_id is null or transit_id = '' or transit_id = '0' then 1 else 0 end) as missing_count[m
[32m+[m[32m   from work.sb_card_data[m
[32m+[m[32m   union[m
[32m+[m[32m   select 'customer_id' as column_name,[m
[32m+[m[32m          sum(case when customer_id is null then 1 else 0 end) as missing_count[m
[32m+[m[32m   from work.sb_card_data[m
[32m+[m[32m   union[m
[32m+[m[32m   select 'customer_name' as column_name,[m
[32m+[m[32m          sum(case when customer_name is null or customer_name = '' then 1 else 0 end) as missing_count[m
[32m+[m[32m   from work.sb_card_data[m
[32m+[m[32m   union[m
[32m+[m[32m   select 'customer_type' as column_name,[m
[32m+[m[32m          sum(case when customer_type is null or customer_type = '' then 1 else 0 end) as missing_count[m
[32m+[m[32m   from work.sb_card_data[m
[32m+[m[32m   union[m
[32m+[m[32m   select 'entity_type' as column_name,[m
[32m+[m[32m          sum(case when entity_type is null or entity_type = '' then 1 else 0 end) as missing_count[m
[32m+[m[32m   from work.sb_card_data;[m
[32m+[m[32mquit;[m
[32m+[m
[32m+[m[32m/* Display the summary of missing values */[m
[32m+[m[32mproc print data=missing_values_summary;[m
[32m+[m[32m    title "Summary of Missing Values in Each Column";[m
[32m+[m[32mrun;[m
[32m+[m
[32m+[m
[32m+[m[32m/*****************************************************************************************************************/[m
[32m+[m[32m/*------------------------------Additional/Other Random Calculations Closed---------------------------------------------------------*/[m
[32m+[m[32m/****************************************************************************************************************/[m
\ No newline at end of file[m
