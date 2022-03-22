--data cleaning & arranging:

--Create a reservation ID coulmn as PK:

ALTER TABLE hotel_booking
ADD Reservation_ID int Identity (1,1)

ALTER TABLE hotel_booking
ADD PRIMARY KEY (Reservation_ID)

-- Replacing null values with 0 or unknown in various columns:

UPDATE hotel_booking
SET agent=ISNULL (agent, 0)

UPDATE hotel_booking
SET company=ISNULL (company, 0)

UPDATE hotel_booking
SET country=ISNULL (country, 'unknown')

-- Renaming columns:

EXEC sp_rename 'hotel_booking.arrival_date_year', 'arrival_year', 'column'

EXEC sp_rename 'hotel_booking.arrival_date_month', 'arrival_Month', 'column'

EXEC sp_rename 'hotel_booking.arrival_date_week_number', 'arrival_week_number', 'column'

EXEC sp_rename 'hotel_booking.arrival_date_day_of_month', 'arrival_day_date', 'column'

EXEC sp_rename 'hotel_booking.is_repeated_guest', 'repeated_guest', 'column'


--Data Exploration: 

--1. Yearly revenue & net profit:

--Yearly revenue for 2015,2016, 2017 at city hotel:
create view revenue_city_hotel as 
select 
hotel, 
arrival_year, 
sum ((stays_in_week_nights + stays_in_weekend_nights )* adr) as revenue 
from hotel_booking 
where arrival_year in (2015, 2016, 2017) and hotel = 'City Hotel' 
group by hotel, arrival_year

-- Finding the net profit: calculating the daliy net profit on rooms from 2015 to 2017 at city hotel:
--Daily net profit on rooms for all years at city hotel:
create view net_profit_city as
select 
hotel,
a.arrival_year,
a.market_segment as way_of_reservation,
a.adr, 
c.Cost,
b.discount,
a.adr+c.Cost-(b.discount*a.adr) as net_daily_profit_on_room_per_day
from hotel_booking a
join market_segment b on a.market_segment=b.market_segment
join meal_cost c on a.meal=c.meal
where arrival_year in (2015,2016, 2017) and hotel='City Hotel'
 
--comparing the sum of revenue and sum of net profit in each year for city hotel:
select
b.arrival_year,
sum (a.revenue) as revenue,
sum (net_daily_profit_on_room_per_day) as net_profit
from revenue_city_hotel a
join net_profit_city b on a.arrival_year=b.arrival_year
group by b.arrival_year, revenue
order by b.arrival_year 

--Finding the sum of revenue and net profit in Resort hotel in order to compare it with city hotel:

--revenue:
create view revenue_resort as
select 
hotel,
arrival_year,
sum ((stays_in_week_nights+stays_in_weekend_nights)*adr) as revenue
from hotel_booking
where arrival_year in (2015,2016,2017) and hotel='resort Hotel'
group by hotel, arrival_year

--Daily net profit on rooms for resort hotel:
create view net_profit_resort as
select 
hotel,
a.arrival_year,
a.market_segment as way_of_reservation,
a.adr, 
c.Cost,
b.discount,
a.adr+c.Cost-(b.discount*a.adr) as net_daily_profit_on_room_per_day
from hotel_booking a
join market_segment b on a.market_segment=b.market_segment
join meal_cost c on a.meal=c.meal
where hotel='resort hotel' and arrival_year in (2015,2016,2017)
 
--comparing resort hotel sum of revenue and sum of net profit:
select
a.hotel,
b.arrival_year,
a.revenue as revenue,
sum (net_daily_profit_on_room_per_day) as net_profit
from revenue_resort a
join net_profit_resort b on a.arrival_year=b.arrival_year
group by a.hotel, b.arrival_year,  revenue
order by b.arrival_year 

--comparing the two hotels:
select
a.hotel,
b.arrival_year,
a.revenue  as revenue,
sum (net_daily_profit_on_room_per_day) as net_profit
from revenue_city_hotel a
join net_profit_city b on a.arrival_year=b.arrival_year
group by b.arrival_year,  revenue, a.hotel
union 
select
a.hotel,
b.arrival_year,
a.revenue as revenue,
sum (net_daily_profit_on_room_per_day) as net_profit
from revenue_resort a
join net_profit_resort b on a.arrival_year=b.arrival_year
group by b.arrival_year,  revenue, a.hotel
order by b.arrival_year 

--2.Ranking monthly revenue (for both hotels), comparing revenue increase and justifying revenue increase (for resort hotel).

--Ranking the months of the year by monthly revenue in each year at resort hotel:
--2015:
create view Monthly_revenue_2015_resort_hotel as
select
hotel,
arrival_year,
arrival_month,
SUM ((stays_in_week_nights+stays_in_weekend_nights)*adr) as Monthly_revenue,
RANK () over (Order by sum ((stays_in_week_nights+stays_in_weekend_nights)*adr) desc) as months_rank_by_monthly_revenue
from hotel_booking
where arrival_year=2015 and hotel='resort Hotel'
group by hotel, arrival_month, arrival_year

--2016:
create view Monthly_revenue_2016_resort_hotel as
select
hotel,
arrival_year,
arrival_month,
SUM ((stays_in_week_nights+stays_in_weekend_nights)*adr) as Monthly_revenue,
RANK () over (Order by sum ((stays_in_week_nights+stays_in_weekend_nights)*adr) desc) as months_rank_by_monthly_revenue
from hotel_booking
where arrival_year=2016 and hotel='resort Hotel'
group by hotel, arrival_month, arrival_year

--2017:
create view Monthly_revenue_2017_resort_hotel as
select
hotel,
arrival_year,
arrival_month,
SUM ((stays_in_week_nights+stays_in_weekend_nights)*adr) as Monthly_revenue,
RANK () over (Order by sum ((stays_in_week_nights+stays_in_weekend_nights)*adr) desc) as months_rank_by_monthly_revenue
from hotel_booking
where arrival_year=2017 and hotel='resort Hotel'
group by hotel, arrival_month, arrival_year


--Ranking the months of the year by monthly revenue in each year for city hotel:

--2015:
create view Monthly_revenue_2015_city_hotel as
select
hotel,
arrival_year,
arrival_month,
SUM ((stays_in_week_nights+stays_in_weekend_nights)*adr) as Monthly_revenue,
RANK () over (Order by sum ((stays_in_week_nights+stays_in_weekend_nights)*adr) desc) as months_rank_by_monthly_revenue
from hotel_booking
where arrival_year=2015 and hotel='city Hotel'
group by hotel, arrival_month, arrival_year


--2016:
create view Monthly_revenue_2016_city_hotel as
select
hotel,
arrival_year,
arrival_month,
SUM ((stays_in_week_nights+stays_in_weekend_nights)*adr) as Monthly_revenue,
RANK () over (Order by sum ((stays_in_week_nights+stays_in_weekend_nights)*adr) desc) as months_rank_by_monthly_revenue
from hotel_booking
where arrival_year=2016 and hotel='city Hotel'
group by hotel, arrival_month,arrival_year

--2017:
create view Monthly_revenue_2017_city_hotel as
select
hotel,
arrival_year,
arrival_month,
SUM ((stays_in_week_nights+stays_in_weekend_nights)*adr) as Monthly_revenue,
RANK () over (Order by sum ((stays_in_week_nights+stays_in_weekend_nights)*adr) desc) as months_rank_by_monthly_revenue
from hotel_booking
where arrival_year=2017 and hotel='city Hotel'
group by hotel, arrival_month, arrival_year

--looking for the month with the highest revenue increase in % from 2016 to 2017 for resort hotel:

-- finding the top 3 months of 2017 at resort hotel:
select top 3
* 
from Monthly_revenue_2017_resort_hotel

--calculating the increased % percentage in revenue from 2016 to 2017 in those top 3 months:
select 
a.hotel,
b.arrival_month,
format (a.Monthly_revenue, 'N') as Monthly_revenue_2016,
format (b.Monthly_revenue, 'N') as Monthly_revenue_2017,
format (((b.Monthly_revenue-a.Monthly_revenue)/a.Monthly_revenue), 'P') as increased_percentage
from Monthly_revenue_2016_resort_hotel a
join Monthly_revenue_2017_resort_hotel b on a.arrival_month=b.arrival_month
where a.arrival_month in ('august', 'july', 'june')
--note*: we can see from the query above that the month with the highest increase in revenu is july with 42%. let's find out why:

-- first let's check if in july 17' there's an increase in reservation that justifise the 42% increase in revenu: 
select 
hotel, 
arrival_year,
arrival_Month,
count (reservation_ID) as num_of_reservation
from hotel_booking 
where arrival_year in (2016,2017) and arrival_Month='july' and hotel='resort hotel'
group by hotel, arrival_year, arrival_Month
--note*:We can see that between july 16' to 17' there's an increase in the number of reservation (313 more reservation in 17'), which by itself can't count for a 42% increase in revenu, so let's keep looking.

--comparing the avg of the ADR (average daily revenue) of rooms in july 16' and 17':

select 
arrival_year,
arrival_Month,
avg (adr) as avg_revenue_by_room
from hotel_booking
where arrival_year in (2016, 2017) and arrival_Month='july' and hotel='resort hotel'
group by arrival_year, arrival_Month
--note*:We can see that there's a big increase (22$) in the ADR (average daily revenue) of rooms between july 16' to 17'. let's search what can justify that difference:

--comparing the num of type of customers and finding the avg ADR (average daily revenue) for each type in every year:
select distinct
arrival_year,
customer_type,
count (customer_type) num_of_customers,
avg (adr) as avg_of_daily_revenue_by_room
from hotel_booking
where hotel='resort hotel' and arrival_year in (2016,2017) and arrival_Month='july'
group by arrival_year, customer_type
order by num_of_customers
--note*: This query shows that not only there were more reservations for each type of customers in 2017 but in addition that every type of customers has a higher ADR (average daily revenue) in 2017.

--3.Advertisement:

--Advertisement: looking for the most profitable repeated guests to send them advertisement emails:

--First create a view table that contains the a daily profit on room column for all repeated guests.
create view daily_profit_on_room_repeated_guests as
select 
hotel,
arrival_year,
arrival_Month,
adr-(c.Discount*adr)+b.Cost as daily_profit_on_room,
name,
email
from hotel_booking a
join meal_cost b on a.meal=b.meal
join market_segment c on a.market_segment=c.market_segment
where a.repeated_guest>0

--second find the avg of the daily profit on rooms of repeated guests.
select 
avg (daily_profit_on_room) as avg_of_daily_profit_on_room_repeated_guests
from daily_profit_on_room_repeated_guests

--third select all of the repeated guests that exceed the avg of daily profit on rooms (in this case 67$) and send them advertisement emails. 
select 
hotel,
arrival_year,
arrival_Month,
name,
email,
adr-(c.Discount*adr)+b.Cost as daily_profit_on_room
from hotel_booking a
join meal_cost b on a.meal=b.meal
join market_segment c on a.market_segment=c.market_segment
where adr-(c.Discount*adr)+b.Cost>67 and repeated_guest>0




