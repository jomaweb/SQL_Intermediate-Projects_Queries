-- This file contain a selected set of queries to manage and handling information in the 1999 Czech Financial Dataset. 


-- -----------------------------------------Activity 2.07
-- DDL extended, Normalization, Aggregations, Window Functions

-- -----------------------------------------Activity 2.07 1
use bank;

-- Excersice 1.
-- In the loan table (which is part of the bank database), there's column status A, B, C, and D.
-- Using the case statement we will create a new column with the values there with a brief description.
--    'A' : 'Good - Contract Finished'
--    'B' : 'Defaulter - Contract Finished'
--    'C' : 'Good - Contract Running'
--    'D' : 'In Debt - Contract Running'


select * from bank.loan; 

select loan_id, account_id,
case
when status = "A" then "Good - Contract Finished"
when status = "B" then "Defaulter - Contract Finished"
when status = "C" then "Good - Contract Running"
else "In Debt - Contract Running"
end as "Status_Description"
from bank.loan;

-- -----------------------------------------Activity 2.07 2

-- 2. You objective is to find the maximum and the minimum in each Status category from the Bank data file.

-- select avg(amount) as Average, status from bank.loan
-- group by Status
-- order by Average asc;

select max(amount) as max_status, min(amount) as min_status from bank.loan
where status = "a";
-- max_statu A = 323472
-- min_status A = 4980

select max(amount) as max_status, min(amount) as min_status from bank.loan
where status = "B";
-- max_statu B = 464520
-- min_status B = 29448

select max(amount) as max_status, min(amount) as min_status from bank.loan
where status = "c";
-- max_statu C = 590820
-- min_status C = 5148

select max(amount) as max_status, min(amount) as min_status from bank.loan
where status = "D";
-- max_statu D = 541200
-- min_status D = 36204

-- -----------------------------------------Activity 2.07 3

use bank;
-- 3.1 Find out how many cards of each type have been issued.
select type, count(*) from bank.card
group by type;
-- 'classic', '659'
-- 'junior', '145'
-- 'gold', '88'

-- other query for the same answer
select type as card_type, count(*) as num_issued
from bank.card
group by type
order by num_issued desc;


-- 3.2 Find out how many customers there are by the district.
select district_id, count(*) num_customers
from bank.client
group by district_id
order by num_customers desc;

-- 3.3 Find out average transaction value by type.
select avg(amount) as Average, type from bank.trans
group by type;
-- '6776.979795258786', 'PRIJEM'
-- '4344.6648939445', 'VYDAJ'
-- '12525.828413284133', 'VYBER'

-- other query for the same answer
select type, round(avg(amount),2) as avg_amount
from bank.trans
group by type
order by avg_amount desc;


-- 3.4 As you might have seen in the query shown below, 
-- there are 19 rows returned by this query. 
-- But there a few places where the column k_symbol is an empty string. 
-- Your task it to use a filter to remove those rows of data. 
-- After the filter gets applied, you would see that the number of rows have reduced.

select type, operation, k_symbol, round(avg(balance),2)
from bank.trans
group by type, operation, k_symbol
order by type, operation, k_symbol;

-- new query
select type, operation, k_symbol, round(avg(balance),2)
from bank.trans
where k_symbol <> "" and k_symbol <> " " 
group by type, operation, k_symbol
order by type, operation, k_symbol;
-- there are 9 rows without empty space


-- -----------------------------------------Activity 2.07 4

use bank;

-- 4.1 Find the districts with more than 100 clients.

select district_id, count(*) from bank.client
group by district_id
having count(*) > 100
order by "district_id";
-- 6 districts have more than 100 clients

-- 4.2 Find the transactions (type, operation) with a mean amount greater than 10000.

select avg(amount) as Average, type, operation 
from bank.trans
group by type, operation
having Average > 10000;
-- 3 transactions have mean amount greater than 10000.


-- -----------------------------------------Activity 2.08
-- Rank & Intro to Joins

-- -----------------------------------------Activity 2.08 2

use bank;
-- 1.1 In this activity, we will be using the table district from the bank database and
-- according to the description for the different columns:

--    A4: no. of inhabitants
--    A9: no. of cities
--    A10: the ratio of urban inhabitants
--    A11: average salary
--    A12: the unemployment rate
-- Rank districts by different variables. Do the same but group by region.

select *, rank() over (order by A4 desc) as "Rank"
from bank.district;

select *, rank() over (order by A9 desc) as "Rank"
from bank.district;

select *, rank() over (order by A10 desc) as "Rank"
from bank.district;

-- 1.2 Do the same but group by region A3.

select *, rank() over (partition by A3 order by A4 desc) as "Rank"
from bank.district;


-- -----------------------------------------Activity 2.08 2

use bank;

-- 2.1 Use the transactions table in the bank database to find the Top 20 account_ids based on the balances.
    
select *, rank() over (order by balance desc) as "Rank"
from bank.trans
limit 20;


-- 2.2 Illustrate the difference between Rank() and Dense_Rank().

-- Rank() 
select *, dense_rank() over (order by account_id desc) as "Rank"
from bank.trans;

-- Dense_Rank()
select *, rank() over (order by account_id desc) as "Rank"
from bank.trans;

-- -----------------------------------------Activity 2.08 3
-- Finished
use bank;

-- 3.1 Get a rank of districts ordered by the number of customers.
select district.A2 as district_name, count(*) as num_customers
from bank.client
inner join bank.district on client.district_id = district.A1
group by district.A2
order by num_customers desc;
-- The district with the most number of customers is Hl.M Praha - 663

-- 3.2 Get a rank of regions ordered by the number of customers.
select district.A3 as region_name, count(*) as num_customers
from bank.client inner join bank.district on client.district_id = district.A1
group by district.A3
order by num_customers desc;
-- The region with the most number of customers is South Moravia - 937


-- 3.3 Get the total amount borrowed by the district together with the average loan in that district.
select d.A2 , sum(l.amount), avg(l.amount)
from bank.account a 
inner join district d on a.`district_id` = d.A1
inner join loan l on l.account_id = a.account_id
group by d.A2;


-- 3.4 Get the number of accounts opened by district and year.

select d.A2 as district_name, date_format(convert(date, date),'%Y') as year, count(*) num_accounts
from bank.account a 
inner join bank.district d on a.district_id = d.A1
group by district_name, year
order by district_name, year;    




