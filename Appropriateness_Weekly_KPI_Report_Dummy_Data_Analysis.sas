
/* Step 1: Import the Datasets */
/* Import the Sales dataset */
PROC IMPORT DATAFILE="/home/u1558213/sasuser.v94/case_stuy/Appropriateness_Weekly_KPI_Report_Dummy_Data.xlsx"
            OUT=work.sales
            DBMS=xlsx
            REPLACE;
    SHEET="Sales";         /* Specify the sheet name */
    GETNAMES=YES;          /* Use the first row as variable names */
RUN;

/* Print the first few rows to verify the data import */
proc print data=work.sales (obs=5);
run;

/* checking data in work.sales after import */
proc contents data=work.sales;
run;

/* Import the Notes dataset */
PROC IMPORT DATAFILE="/home/u1558213/sasuser.v94/case_stuy/Appropriateness_Weekly_KPI_Report_Dummy_Data.xlsx"
            OUT=work.notes
            DBMS=xlsx
            REPLACE;
    SHEET="Notes";         /* Specify the sheet name */
    GETNAMES=YES;          /* Use the first row as variable names */
RUN;

/* Print the first few rows to verify the data import */
proc print data=work.notes (obs=5);
run;

/* checking data in work.notes after import */
proc contents data=work.notes;
run;

/* Import the Regions dataset */
PROC IMPORT DATAFILE="/home/u1558213/sasuser.v94/case_stuy/Appropriateness_Weekly_KPI_Report_Dummy_Data.xlsx"
            OUT=work.regions
            DBMS=xlsx
            REPLACE;
    SHEET="Regions";         /* Specify the sheet name */
    GETNAMES=YES;          /* Use the first row as variable names */
RUN;

/* Print the first few rows to verify the data import */
proc print data=work.regions (obs=5);
run;


/* checking data in work.regions after import */
proc contents data=work.regions;
run;

/* Step 2: Filter Eligible Transaction Types */
/* a.	Across eligible transaction types (new account, new credit card, new term purchase) */
/* Filter Sales for eligible transaction types */
proc sql;
    create table sales_filtered as
    select *
    from work.sales
    where sale_transaction_type in ('New Account', 'New Credit Card', 'New Term Purchase');
quit;


/* Step 3: Join Sales with Regions */
/* b.	Across select regions (Greater Toronto, BC & Yukon, Atlantic Provinces) */
/* Left Join Sales with Regions to add region_name */
proc sql;
    create table sales_with_region as
    select s.*, r.region_name
    from sales_filtered s
    left join work.regions r
    on s.transit_id = r.transit_id;
quit;

/*
Issue Identified:

1. In the Sales dataset, sale_ocif_id values start with "000000" (such as 000000881406140), 
indicating that they are stored as character strings with leading zeros and for padding

2. In the Notes dataset, note_ocif_id values are numeric-like (such as 585886457), without leading zeros, 
possibly stored as a numeric field or a character field without padding.

3. This mismatch means a direct join on sale_ocif_id = note_ocif_id will fail because 000000881406140 does not equal 881406140, 
even though they likely represent the same identifier after removing the leading zeros.

*/

/* Step 4: Clean sale_ocif_id */

proc sql;
    create table sales_with_cleaned as
    select *,
           substr(sale_ocif_id, 7) as sale_ocif_id_cleaned length=9
    from sales_with_region;
quit;

/* Display the result to verify */
proc print data=sales_with_cleaned;
    var sale_ocif_id sale_ocif_id_cleaned;
    title "Sales Data with Cleaned sale_ocif_id (Positions 7 to 15)";
run;

/* Verify the length of sale_ocif_id_cleaned */
proc contents data=sales_with_cleaned;
run;

/* Step 5: Join Sales with Notes */

/* Join sales_with_cleaned with work.notes */
proc sql;
    create table sales_notes_joined as
    select s.*,
           put(n.note_ocif_id, 9.) as note_ocif_id_cleaned length=9,
           n.appropriateness_completion_flag,
           n.note_id,
           n.note_transaction_type,
           n.note_create_date
    from sales_with_cleaned s
    left join work.notes n
    on s.sale_ocif_id_cleaned = put(n.note_ocif_id, 9.);
quit;

/* QA Check: Verify the join success */
proc sql;
    create table unmatched_sales as
    select count(*) as unmatched_sales
    from sales_notes_joined
    where note_ocif_id_cleaned is null;
quit;

/* Display a sample of the joined table */
proc print data=sales_notes_joined (obs=5);
    var sale_ocif_id sale_ocif_id_cleaned note_ocif_id_cleaned appropriateness_completion_flag;
    title "Sample of Joined Sales and Notes Data";
run;


/* Step 6: Create has_note_flag
Purpose: Create a binary flag has_note_flag to indicate whether a sale has an appropriate note:

1 if appropriateness_completion_flag = 'Yes'.
0 if appropriateness_completion_flag = 'No', null, or blank. 
*/
proc sql;
    create table sales_notes_with_flag as
    select *,
           case 
               when appropriateness_completion_flag = 'Yes' then 1
               when appropriateness_completion_flag = 'No' or appropriateness_completion_flag is null or appropriateness_completion_flag = '' then 0
               else .
           end as has_note_flag
    from sales_notes_joined;
quit;


/* Step 7: Assign Weekly Periods */

data sales_notes_with_weeks;
    set sales_notes_with_flag;
    week_start_date = intnx('week.6', sale_date, 0, 'B');
    if sale_date < week_start_date then week_start_date = intnx('week.6', sale_date, -1, 'B');
    week_number = intck('week', '03JUN2022'd, week_start_date) + 1;
    week_label = cats("Week ", week_number, ": ", put(week_start_date, yymmdd10.), " to ", put(intnx('day', week_start_date, 6), yymmdd10.));
run;

/* Step 8: Create the Weekly Report */
proc sql;
    create table weekly_report as
    select 
        week_label,
        sale_transaction_type,
        region_name,
        count(*) as total_sales,
        sum(has_note_flag) as sales_with_notes,
        (sum(has_note_flag) / count(*)) as completion_rate format=percent8.1
    from sales_notes_with_weeks
    where region_name in ('Greater Toronto (GT)', 'BC & Yukon (BCY)', 'Atlantic Provinces (AP)')
    group by week_label, sale_transaction_type, region_name
    order by week_label, sale_transaction_type, region_name;
quit;

/* Step 9: Create the Aggregated Report */
proc sql;
    create table aggregated_report as
    select 
        'Since Inception' as period,
        sale_transaction_type,
        region_name,
        count(*) as total_sales,
        sum(has_note_flag) as sales_with_notes,
        (sum(has_note_flag) / count(*)) as completion_rate format=percent8.1
    from sales_notes_with_weeks
    where region_name in ('Greater Toronto (GT)', 'BC & Yukon (BCY)', 'Atlantic Provinces (AP)')
    group by sale_transaction_type, region_name
    order by sale_transaction_type, region_name;
quit;


/* Step 10: Display the Reports */
proc print data=weekly_report;
    title "Weekly Appropriateness Completion Report";
run;

proc print data=aggregated_report;
    title "Aggregated Appropriateness Completion Report (Since Inception)";
run;
