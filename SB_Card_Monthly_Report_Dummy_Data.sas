
/* Step 1: Import the Excel file into a SAS dataset */

PROC IMPORT DATAFILE="/home/u1558213/sasuser.v94/case_stuy/SB_Card_Monthly_Report_Dummy_Data.xlsx"
            OUT=work.sb_card_data
            DBMS=xlsx
            REPLACE;
    SHEET="Sheet1"; /* Specify the sheet name */
    GETNAMES=YES; /* Use the first row as variable names */
RUN;

/* Print the first few rows to verify the data import */
proc print data=work.sb_card_data (obs=5);
run;

/*Check the data type of all Columns */
proc contents data=work.sb_card_data;
run;


/*-----------Final Solution -------------------*/
/* Step 1: Remove test data */
proc sql;
   create table sb_card_data_cleaned as
   select *
   from work.sb_card_data
   where upcase(customer_name) not like '%TEST%';
quit;
/* Total records after Step 1 =995 */

/* Step 2: Include only July open_date (already satisfied, but included for clarity) */
proc sql;
   create table sb_card_data_cleaned_july as
   select *
   from sb_card_data_cleaned
   where open_date between '01JUL2022'd and '31JUL2022'd;
quit;

/* Total records after Step 2 =995 */

/* Step 3: Remove closed accounts (only those with closed_date in July or August 2022) */
proc sql;
   create table sb_card_data_open as
   select *
   from sb_card_data_cleaned_july
   where closed_date is null
      or closed_date not between '01JUL2022'd and '31AUG2022'd;
quit;
/* Total records after Step 3 =990 */

/* Step 3.5: Calculate missing values after Step 3 */
proc sql;
    create table missing_data_flags as
    select *,
           case when employee_id is null or employee_id = '' then 1 else 0 end as missing_employee_id,
           case when transit_id = '' or transit_id = '0' then 1 else 0 end as missing_transit_id,
           case when customer_id is null then 1 else 0 end as missing_customer_id,
           case when entity_type is null then 1 else 0 end as missing_entity_type
    from sb_card_data_open;
quit;

proc sql;
   create table missing_data_summary as
   select sum(missing_employee_id) as total_missing_employee_id,
          sum(missing_transit_id) as total_missing_transit_id,
          sum(missing_customer_id) as total_missing_customer_id,
          sum(missing_entity_type) as total_missing_entity_type
   from missing_data_flags;
quit;

/* Total records after Step 3.5 =990 */

/* Step 4: Remove records with missing employee_id and customer_type */
proc sql;
   create table sb_card_data_final as
   select *
   from missing_data_flags
   where customer_type is not null
     and customer_type <> ''
     and missing_employee_id = 0; /* Using the flag from missing_data_flags */
quit;
/* Total records after Step 4=839 */

/* Step 5: Identify Existing and New customers and apply audit criteria */
proc sql;
   create table audit_scope as
   select *,
          case 
             when customer_type = 'Existing' then 1
             when customer_type = 'New' then 2
             else 0
          end as customer_category, /* 1 = Existing, 2 = New, 0 = Missing (already excluded) */
          case 
             when customer_type = 'Existing' then 1 /* 5% will be selected later */
             when customer_type = 'New' then 1 /* 100% in scope */
             else 0
          end as in_scope_flag
   from sb_card_data_final;
quit;

/* Total records after Step 5=839 */

/* Step 6: Calculate the volume in scope for audit */
/* For Existing customers, randomly select 5% using a DATA step */
data audit_scope_selected;
   set audit_scope;
   /* Generate a random number for Existing customers to select 5% */
   if customer_category = 1 then do;
      random_num = ranuni(123); /* Random number between 0 and 1 */
      if random_num <= 0.05 then in_scope_flag = 1; /* 5% chance of being selected */
      else in_scope_flag = 0;
   end;
run;
/* Total records after Step  =839 */

/* Step 7: Count the total applications in scope */
proc sql;
   create table final_volume as
   select sum(case when customer_category = 1 and in_scope_flag = 1 then 1 else 0 end) as existing_in_scope,
          sum(case when customer_category = 2 and in_scope_flag = 1 then 1 else 0 end) as new_in_scope,
          sum(in_scope_flag) as total_in_scope
   from audit_scope_selected;
quit;
/* Total records after Step 7=238 */

/* Display the final volume */
proc print data=final_volume;
    title "Volume of Applications in Scope for Audit (Shared with Operations)";
run;
/*-------------Final Solution Closed------------------*/

/*****************************************************************************************************************/
/*------------------------------Additional/Other Random Calculations Start---------------------------------------------------------*/
/****************************************************************************************************************/
/* 1.1 Checking the closed date column values  */
proc sql;
   create table closed_date_july_august as
   select *,
          closed_date as closed_date_formatted format=date9.
   from work.sb_card_data
   where closed_date is not null
     and closed_date between '01JUL2022'd and '31AUG2022'd;
quit;

proc print data=closed_date_july_august;
    title "Records with closed_date in July or August 2022";
run;


/*---------------------------------------------------------------------------------------*/


/* Check for test data names in customer_name column */
proc sql;
   /* Create a table with a flag for test data names */
   create table customer_name_test_check as
   select *,
          case when upcase(customer_name) like '%TEST%' then 1 else 0 end as is_test_data
   from work.sb_card_data;

   /* Summarize the count and percentage of test data names */
   create table test_data_summary as
   select sum(is_test_data) as total_test_data_rows,
          count(*) as total_rows,
          calculated total_test_data_rows / calculated total_rows * 100 as percent_test_data
   from customer_name_test_check;

   /* List the records with test data names */
   create table test_data_records as
   select card_number, customer_name, open_date, closed_date, card_application_system, 
          employee_id, transit_id, customer_id, customer_type, entity_type
   from customer_name_test_check
   where is_test_data = 1;
quit;

/* Display the summary */
proc print data=test_data_summary;
    title "Summary of Test Data Names in customer_name";
run;

/* Display the records with test data names */
proc print data=test_data_records;
    title "Records with Test Data Names in customer_name";
run;

/*---------------------------------------------------------------------------------------*/

/* 1.1 : Data Filterng: Checking the range of values in open_date column (All in July 2022) */
proc sql;
    create table open_date_check as
    select open_date format=date9., 
           min(open_date) as min_open_date format=date9.,
           max(open_date) as max_open_date format=date9.,
           count(*) as total_rows,
           sum(case when open_date between '01JUL2022'd and '31JUL2022'd then 1 else 0 end) as rows_in_july_2022
    from work.sb_card_data;
quit;

proc sql;
    create table open_date_check1 as
    select a.*,
           /* Format open_date as date9. (already a SAS date) */
           open_date format=date9., 
           /* Summary statistics computed over the entire dataset */
            open_date format=date9., 
           min(open_date) as min_open_date format=date9.,
           max(open_date) as max_open_date format=date9.,
           count(*) as total_rows,
           sum(case when open_date between '01JUL2022'd and '31JUL2022'd then 1 else 0 end) as rows_in_july_2022
    from work.sb_card_data a;
quit;


/* Display the results */
proc print data=open_date_check1;
   title "Open Date Range Analysis";
run;

/* Step 2: Data Distribution */
/* 2.1: calculating missing values for (employee_id,transit_id, customer_id,entity_type) */

proc sql;
    create table missing_data_flags as
    select *,
           case when employee_id is null or employee_id = '' then 1 else 0 end as missing_employee_id,
           case when transit_id = '' or transit_id = '0' then 1 else 0 end as missing_transit_id,
           case when customer_id is null then 1 else 0 end as missing_customer_id,
           case when entity_type is null then 1 else 0 end as missing_entity_type
    from work.sb_card_data;
quit;


/* Step 6: Summarize missing data issues */
proc sql;
   create table missing_data_summary as
   select sum(missing_employee_id) as total_missing_employee_id,
          sum(missing_transit_id) as total_missing_transit_id,
          sum(missing_customer_id) as total_missing_customer_id,
          sum(missing_entity_type) as total_missing_entity_type
   from missing_data_flags;
quit;


proc print data=missing_data_summary;
   title "Summary of Missing Mandatory Fields";
run;

/*----------Right code for searching missing value-----------------------------*/

/* Check for missing values in all columns */
proc sql;
   create table missing_values_summary as
   select 'card_number' as column_name,
          sum(case when card_number is null then 1 else 0 end) as missing_count
   from work.sb_card_data
   union
   select 'open_date' as column_name,
          sum(case when open_date is null then 1 else 0 end) as missing_count
   from work.sb_card_data
   union
   select 'closed_date' as column_name,
          sum(case when closed_date is null then 1 else 0 end) as missing_count
   from work.sb_card_data
   union
   select 'card_application_system' as column_name,
          sum(case when card_application_system is null or card_application_system = '' then 1 else 0 end) as missing_count
   from work.sb_card_data
   union
   select 'employee_id' as column_name,
          sum(case when employee_id is null or employee_id = '' then 1 else 0 end) as missing_count
   from work.sb_card_data
   union
   select 'transit_id' as column_name,
          sum(case when transit_id is null or transit_id = '' or transit_id = '0' then 1 else 0 end) as missing_count
   from work.sb_card_data
   union
   select 'customer_id' as column_name,
          sum(case when customer_id is null then 1 else 0 end) as missing_count
   from work.sb_card_data
   union
   select 'customer_name' as column_name,
          sum(case when customer_name is null or customer_name = '' then 1 else 0 end) as missing_count
   from work.sb_card_data
   union
   select 'customer_type' as column_name,
          sum(case when customer_type is null or customer_type = '' then 1 else 0 end) as missing_count
   from work.sb_card_data
   union
   select 'entity_type' as column_name,
          sum(case when entity_type is null or entity_type = '' then 1 else 0 end) as missing_count
   from work.sb_card_data;
quit;

/* Display the summary of missing values */
proc print data=missing_values_summary;
    title "Summary of Missing Values in Each Column";
run;


/*****************************************************************************************************************/
/*------------------------------Additional/Other Random Calculations Closed---------------------------------------------------------*/
/****************************************************************************************************************/