-- This file contain a selected set of queries to manage and handling information in the Sakila Database (https://dev.mysql.com/doc/sakila/en/).

-- -----------------------------------------SQL Queries - Lesson 2.5 
-- Operators, Functions, DateTime and Logical Order of Processing
-- Finished

use sakila;

-- 5.1 Select all the actors with the first name ‘Scarlett’.
select * from sakila.actor
where first_name = "SCARLETT";
-- There are two actors with the name  "SCARLETT"

-- 5.2 How many films (movies) are available for rent and how many films have been rented?
select count(*) from sakila.film; -- 1000
select count(*) from sakila.rental; -- 1604


-- 5.3 What are the shortest and longest movie duration? Name the values max_duration and min_duration.
select max(rental_duration) as max_duration, min(rental_duration) as min_duration
from sakila.film;
-- Shortest film: 3 minutes; largest film 7 minutes


-- 5.4 What's the average movie duration expressed in format (hours, minutes)?
select floor(avg(length) / 60) as hours, round(avg(length) % 60) as minutes
from sakila.film;
-- 1 hour, 55 minutes


-- 5.5 How many distinct (different) actors' last names are there?
select count(distinct last_name)
from actor;
-- There are 121 actors with different last names

-- 5.6 Since how many days has the company been operating (check DATEDIFF() function)?
select datediff(max(rental_date), min(rental_date)) as active_days
from rental;
-- Since 266 days


-- 5.7 how rental info with additional columns month and weekday. Get 20 results.
select *, date_format(rental_date, "%M") as month , date_format(rental_date, "%W") as weekday
from rental
limit 20;



-- 5.8 Add an additional column day_type with values 'weekend' and 'workday' depending on the rental day of the week.
select *, case when date_format(rental_date, "%W") in ("Saturday", "Sunday")
          then "weekend"
          else "workday" end as day_type
from rental;


-- 5.9 How many rentals were in the last month of activity?
select date(max(rental_date))
from rental;
select *, date_format("rental_date", "%M") as Month_,
date_format("rental_date", "%Y") as Year_
from rental
having Month_ = "October" and Year_ = 2020;
-- There were 0 rentals in the last month of activity


-- -----------------------------------------SQL Queries - Lesson  2.06 
-- Data Cleaning, Operators & Main clauses 
-- Finished


use sakila;

-- 6.1 Get release years.
select distinct release_year from sakila.film;
-- 2006


-- 6.2 Get all films with ARMAGEDDON in the title.
select title from sakila.film
where title like '%ARMAGEDDON%';
-- There are 6 films with ARMAGEDDON in the title


-- 6.3 Get all films which title ends with APOLLO.
-- (option 1)
select title from sakila.film
where title like '%APOLLO';

-- select title from sakila.film
-- where title REGEXP 'APOLLO$';

-- There are 5 films with Apollo in the end of the title


-- 6.4 Get 10 the longest films. 
select title from sakila.film
order by length desc
limit 10;
-- 


-- 6.5 How many films include Behind the Scenes content?
select count(*) from sakila.film
where special_features like '%Behind the Scenes%';
-- 538


-- 6.6 Drop column picture from staff.
alter table skila.staff drop column picture;


-- 6.7 A new person is hired to help Jon. Her name is TAMMY SANDERS, and she is a customer. 
-- Update the database accordingly. (Shimanshu explanation!!)
 
-- to check if such an entry already exists
select * from sakila.customer
where first_name = 'TAMMY' and last_name = 'SANDERS';
insert into sakila.staff(first_name, last_name, email, address_id, store_id, username)
values('TAMMY','SANDERS', 'TAMMY.SANDERS@sakilacustomer.org', 640, 2, 'tammy');



-- 6.8 Add rental for movie "Academy Dinosaur" by Charlotte Hunter from Mike Hillyer at Store
-- (Shimanshu explanation amd approach!!)
-- get customer_id
select customer_id from sakila.customer where first_name = 'CHARLOTTE' and last_name = 'HUNTER';
-- expected customer_id = 130
-- get film_id
select film_id from sakila.film where title = 'ACADEMY DINOSAUR';
-- expected film_id = 1
-- get inventory_id
select inventory_id from sakila.inventory where film_id = 1;
-- expected inventory_id = 1
-- get staff_id
select * from sakila.staff;
-- expected staff_id = 1
insert into sakila.rental(rental_date, inventory_id, customer_id, staff_id)
values (curdate(), 1, 130, 1);
select curdate();


-- 6.9 Delete non-active users, but first, create a backup table deleted_users to store 
-- customer_id, email, and the date for the users that would be deleted.
-- (Shimanshu explanation amd approach!!)

-- check the current number of inactive users
select * from sakila.customer
where active = 0;

drop table if exists deleted_users;

CREATE TABLE deleted_users (
customer_id int UNIQUE NOT NULL,
email varchar(255) UNIQUE NOT NULL,
delete_date date
);
insert into deleted_users
select customer_id, email, curdate()
from sakila.customer
where active = 0;

select * from deleted_users;

delete from sakila.customer where active = 0;

-- check how many inactive users there are now
select * from sakila.customer
where active = 0;
-- There are 15 inactive users



-- -----------------------------------------SQL Queries - Lesson 2.07
-- DDL extended, Normalization, Aggregations, Window Functions
-- Finished 

Use sakila;


    -- 7.1 In the table actor, which are the actors whose last names are not repeated? 
    -- For example if you would sort the data in the table actor by last_name, 
    -- you would see that there is Christian Arkoyd, Kirsten Arkoyd, and Debbie Arkoyd. 
    -- These three actors have the same last name. 
    -- So we do not want to include this last name in our output. Last name "Astaire" is present only one time with actor "Angelina Astaire", hence we would want this in our output list.
  
select * from sakila.actor;
select distinct last_name from sakila.actor;

select last_name from sakila.actor
group by last_name
having count(*) = 1;

     -- 7.2 Which last names appear more than once? We would use the same logic as in the previous question but this time we want to include the last names of the actors where the last name was present more than once

select last_name from sakila.actor
group by last_name
having count(*) > 1;  
    
    -- 7.3 Using the rental table, find out how many rentals were processed by each employee.
   
select staff_id, count(*) from sakila.rental
group by staff_id;
   -- employee 1 : 8041; employee 2: 8004
   
   -- 7.4 Using the film table, find out how many films were released each year.
    
select release_year, count(*) as num_films from sakila.film
group by release_year
order by release_year;
-- 2006: 1000


-- 7.5 Using the film table, find out for each rating how many films were there.
  
select rating, count(*) as num_films from sakila.film
group by rating;
  
 -- 7.6 What is the mean length of the film for each rating type. 
 -- Round off the average lengths to two decimal places
  
select rating, avg(length) as avg_duration from sakila.film
group by rating
order by avg_duration desc;

-- 7.7 Which kind of movies (rating) have a mean duration of more than two hours?

select rating, round(avg(length),2) as avg_duration from sakila.film
group by rating
having avg_duration > 120
order by avg_duration desc;
-- PG-13. avg: 120:44 minutes



-- -----------------------------------------SQL Queries - Lesson 2.08
-- Rank & Intro to Joins
-- Finished 

use sakila;

-- 8.1 Rank films by length (filter out the rows that have nulls or 0s in length column). 
-- In your output, only select the columns title, length, and the rank.
select  title, length, rank() over (order by length desc) as "Rank" from sakila.film
where length is not null and length > 0
order by "Rank";
-- The longest film is 'CHICAGO NORTH', '185', '1'
 
 -- 8.2 Rank films by length within the rating category (filter out the rows that have nulls or 0s in length column). In your output, only select the columns title, length, rating and the rank.
select  title, length, rating, rank() over (order by rating) as "Rank" from sakila.film
where length is not null and length > 0
order by rating asc;
-- The film ranked with the highest rating was 'ACE GOLDFINGER', '48', 'G', '1'


-- 8.3 How many films are there for each of the categories in the category table. 
-- Use appropriate join to write this query

select name as category_name, count(*) as num_films
from sakila.category as cats 
inner join sakila.film_category film_cats
on cats.category_id = film_cats.category_id
group by category_name
order by num_films desc;
-- The category with more films is Sports

-- to count without the category name 
select count(*), fc.category_id 
from sakila.film_category as fc
left join sakila.film as f
on fc.film_id = f.film_id
group by fc.category_id
order by fc.category_id;

-- 4 Which actor has appeared in the most films?
select actor.actor_id, actor.first_name, actor.last_name,
count(actor_id) as film_count
from sakila.actor join sakila.film_actor using (actor_id)
group by actor.actor_id
order by film_count desc
limit 1;
-- The  actor that appeared in the most films is Gina Degeneres

-- 5 Most active customer (the customer that has rented the most number of films)
select customer.*,
count(rental_id) as rental_count
from sakila.customer join sakila.rental using (customer_id)
group by customer_id
order by rental_count desc
limit 1;
-- The customer that has rented the most number of films is Eleanor Hunt

-- Bonus: Which is the most rented film? 
select film.title, count(rental_id) as rental_count
from sakila.film inner join sakila.inventory using (film_id)
inner join sakila.rental using (inventory_id)
group by film_id
order by rental_count desc
limit 1;
-- The most rented film is Bucket Brother.


-- -----------------------------------------SQL Queries Lesson 2.09
-- Python/SQL Connection & Classification Models

-- Finished

use sakila;

-- 9.1 Create a table rentals_may to store the data from rental table with information for the month of May.

CREATE TABLE rentals_may (
   rental_id int NOT NULL AUTO_INCREMENT,
   rental_date datetime NOT NULL,
  inventory_id mediumint unsigned NOT NULL,
  customer_id smallint unsigned NOT NULL,
  return_date datetime DEFAULT NULL,
  staff_id tinyint unsigned NOT NULL,
  last_update timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
   PRIMARY KEY (rental_id)
);


-- 9.2 Insert values in the table rentals_may using the table rental, filtering values only for the month of May.
insert into rentals_may
select rental_id, rental_date, inventory_id, customer_id, return_date, staff_id, last_update
from sakila.rental
where rental_date between '2005-05-01' and '2005-05-31'
or return_date between '2005-05-01' and '2005-05-31';


-- 9.3 Create a table rentals_june to store the data from rental table with information for the month of June.


CREATE TABLE rentals_june (
   rental_id int NOT NULL AUTO_INCREMENT,
   rental_date datetime NOT NULL,
  inventory_id mediumint unsigned NOT NULL,
  customer_id smallint unsigned NOT NULL,
  return_date datetime DEFAULT NULL,
  staff_id tinyint unsigned NOT NULL,
  last_update timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
   PRIMARY KEY (rental_id)
);



-- 9.4 Insert values in the table rentals_june using the table rental, filtering values only for the month of June. 

insert into rentals_june
select rental_id, rental_date, inventory_id, customer_id, return_date, staff_id, last_update
from sakila.rental
where rental_date between "2005-06-01" and "2005-06-30";

select * from rentals_june;


-- 9.5 Check the number of rentals for each customer for May.
select customer_ID, count(*) from sakila.rentals_may
group by customer_ID
order by  count(*) desc;
-- Costumer number 197 hast 8 rents in may

-- 9.6 Check the number of rentals for each customer for June.
select customer_ID, count(*) from sakila.rentals_june
group by customer_ID
order by  count(*) desc;
-- Costumer number 31 hast 11 rents in may

select * from rentals_may;

-- 9.7 Create a Python connection with SQL database and retrieve the results of the last two queries as dataframes
-- See python file Lab 2.9


-- -----------------------------------------SQL Queries Lesson 3.01
--  Keys & Joins
-- Finished


use sakila;

 -- 1   List number of films per category.
  
select count(fc.category_id) as NumberFilms,
fc.category_id,
 cat.name
 from sakila.film as f
 inner join sakila.film_category as fc
 on f.film_id = fc.film_id
 inner join sakila.category as cat
 on fc.category_id = cat.category_id
 group by fc.category_id; 
 
 
 -- 2   Display the first and last names, as well as the address, of each staff member.
 
select st.last_name, st.first_name, ad.address
from sakila.staff as st
inner join sakila.address as ad
on st.address_id = ad.address_id
order by st.last_name;
 
 -- 3   Display the total amount rung up by each staff member in August of 2005.
 
select p.amount as StaffAmount, st.staff_id, p.payment_date
-- payment_date(convert(date,date), "%Y, %m") as PaymentDate
from sakila.staff as st
inner join sakila.payment as p
on st.staff_id = p.staff_id;
-- where p.payment_date = 2005-08
-- group by st.staff_id;
 


-- -----------------------------------------SQL Queries Lesson 3.02
--  Joins on multiple tables
-- Finished


use sakila;

--  1  Write a query to display for each store its store ID, city, and country.
select * from sakila.store;
select * from sakila.staff;

select * from sakila.country as country
inner join sakila.city as city
on country.country_id = city.country_id
join sakila.address as address
on city.city_id = address.city_id
join sakila.store as store
on address.address_id = store.address_id;


-- There are two stores: Candada, Lethbridge, store_id: 1; 

-- second option creating temporary tables

create temporary table country_and_city
select country.country, country.country_id,
city.city, city.city_id
from sakila.country as country
inner join sakila.city as city 
on country.country_id = city.country_id;

select * from sakila.country_and_city;

create temporary table address_and_store
select address.address, address.address_id, address.district,
store.store_id 
from sakila.address as address
join sakila.store as store
on address.address_id = store.address_id;

select * from sakila.address_and_store;
-- select * from sakila.address_and_store;


-- 2   Write a query to display how much business, in dollars, each store brought in.

select sum(payment.amount), staff.store_id
from sakila.payment as payment
inner join sakila.staff as staff
on payment.staff_id = staff.staff_id
group by staff.store_id;
-- $ 33489.47, in store 1
-- $ 33927.04, in store 2



--  3  What is the average running time of films by category?
select avg(f.length) as avg_duration, ca.name
from sakila.film as f
join sakila.film_category as fc
on f.film_id = fc.film_id
join sakila.category as ca
on fc.category_id = ca.category_id
group by ca.name, f.title
order by avg_duration desc;



-- 4   Which film categories are longest?
select avg(f.length) as avg_duration, ca.name
from sakila.film as f
join sakila.film_category as fc
on f.film_id = fc.film_id
join sakila.category as ca
on fc.category_id = ca.category_id
group by ca.name
order by avg_duration desc;
-- sports has the longest avg_duration with 128..2027 min.


-- 5   Display the most frequently rented movies in descending order.

select sum(r.inventory_id) as rented_movies,
f.title from sakila.rental as r
inner join sakila.inventory as i
on r.inventory_id = i.inventory_id
inner join sakila.film as f
on i.film_id = f.film_id
group by f.title
order by rented_movies desc;
--  'ZORRO ARK' is the most rented film with '141905' times.



-- 6   List the top five genres in gross revenue in descending order.

select sum(p.amount) as revenue, ca.name, fc.category_id 
from sakila.payment  as p
inner join sakila.rental as r
on p.rental_id = r.rental_id
inner join sakila.inventory as i
on r.inventory_id = i.inventory_id
inner join sakila.film as f
on i.film_id = f.film_id
inner join sakila.film_category as fc
on f.film_id = fc.film_id
inner join sakila.category as ca
on fc.category_id = ca.category_id
group by ca.name, fc.category_id 
order by revenue desc
limit 5;
-- Sports, Sci-Fi, Animation, Drama, Comedy


-- 7   Is "Academy Dinosaur" available for rent from Store 1?


select f.title, r.rental_id, r.inventory_id, r.rental_date, r.return_date, s.store_id
from sakila.film  as f
inner join sakila.inventory as i
on f.film_id = i.film_id
inner join sakila.rental as r
on i.inventory_id = r.inventory_id
inner join sakila.store as s
on i.store_id = s.store_id
where f.title = "Academy Dinosaur" and s.store_id = 1;
-- Yes, 12 copies of "Academy Dinosaur" are available for rent in Store 1?



-- -----------------------------------------SQL Queries Lesson 3.03
-- Cross self-joins
-- Finished


select sakila;

-- 1    Get all pairs of actors that worked together.

select * from (
select fa1.film_id , fa1.actor_id as actor1, fa2.actor_id as actor2
from film_actor fa1
join film_actor fa2
on fa1.`actor_id` <> fa2.actor_id and fa1.film_id = fa2.film_id 
where fa1.film_id =1)sub
where actor1 > actor2
order by actor1, actor2; 



-- 2    Get all pairs of customers that have rented the same film more than 3 times.

select
t1.customer_id as customer_id1,
t2.customer_id as customer_id2,
count(*) as coincidences
from
(select rt.customer_id, inv.film_id from sakila.rental as rt join sakila.inventory as inv using (inventory_id)) as t1
join
(select	rt.customer_id, inv.film_id from sakila.rental as rt join sakila.inventory as inv using (inventory_id)) as t2
on t1.film_id = t2.film_id
and t1.customer_id != t2.customer_id
and t1.customer_id > t2.customer_id
group by t1.customer_id, t2.customer_id
having coincidences > 3
order by coincidences desc
;


