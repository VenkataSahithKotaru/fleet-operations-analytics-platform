use fleet_management_system;

 
-- 1. Which vehicles are earning the most money? 
SELECT 
    v.vehicle_id,v.vehicle_type,CONCAT(v.brand, ' ', v.model) 
    AS model,FORMAT(SUM(t.revenue), 0) AS revenue
FROM
    vehicles v JOIN total_revenue t ON v.vehicle_id = t.vehicle_id
GROUP BY v.vehicle_id , v.vehicle_type , v.brand , v.model
ORDER BY SUM(revenue) DESC limit 5;


-- 2.Which tourism category gives highest revenue?

SELECT 
    tr.tourism_type, FORMAT(SUM(t.revenue), 2) AS profit
FROM
    trips tr
        JOIN
    total_revenue t ON tr.trip_id = t.trip_id
GROUP BY tr.tourism_type
ORDER BY SUM(t.revenue) DESC;


-- 3.Which routes are most frequently booked?

SELECT 
    CONCAT(pickup_city, '-', drop_city)
    AS trip_route,COUNT(*) AS booking_count
FROM trips
GROUP BY trip_route
ORDER BY booking_count DESC limit 5;


-- 4.Which customers bring the most revenue?

SELECT c.customer_name, format(sum(tr.revenue),0) 
as revenue FROM customers c JOIN
trips t ON c.customer_id = t.customer_id JOIN
total_revenue tr ON t.trip_id = tr.trip_id
group by c.customer_name ORDER BY sum(tr.revenue)
 DESC LIMIT 10;


-- 5.Which vehicle spends too much on maintenance?

SELECT v.vehicle_id,v.vehicle_type,CONCAT(v.brand, ' ',
 v.model) AS vehicle,FORMAT(SUM(m.cost), 2) AS 
 amount_spent FROM vehicles v JOIN maintenance_logs m 
ON v.vehicle_id = m.vehicle_id GROUP BY v.vehicle_id ,
 v.brand , v.model ORDER BY amount_spent DESC limit 5;

-- 6.How much salaries did we given to drivers until this month?

select format(sum(timestampdiff(month,joining_day,
curdate())*salary),0) as amt_spent_on_salaries from drivers;

-- how much revenue did we generated in this month?
SELECT monthname(t.trip_start_date) as month,year(t.trip_start_date) as year,format(sum(tr.revenue),0) as revenue
from trips t join total_revenue tr on t.trip_id=tr.trip_id
where  MONTH(t.trip_start_date)=MONTH(CURDATE())
AND YEAR(t.trip_start_date)=YEAR(CURDATE()) 
group by  monthname(t.trip_start_date),year(t.trip_start_date);


-- 7.How much money is still pending from customers?

SELECT 
    FORMAT(SUM(booking_amount - advance_paid),
        0) AS amount_pending
FROM trips
WHERE payment_status = 'Pending';
    

    
-- 8.Which drivers completed the most trips?

SELECT d.driver_name, COUNT(t.trip_id) 
AS trips_completed FROM drivers d JOIN
trips t ON d.driver_id = t.driver_id
WHERE t.trip_status = 'Completed'
GROUP BY d.driver_name,d.driver_id
ORDER BY trips_completed DESC LIMIT 5;

-- 9.Which trips had the highest expenses?


SELECT CONCAT(t.pickup_city, '-', t.drop_city) 
AS trip_route,FORMAT(tot.expenses, 0) AS 
expenses FROM total_expenses tot JOIN
trips t ON tot.trip_id = t.trip_id
ORDER BY tot.expenses DESC;

-- 10.Which vehicles are idle and not being used?

SELECT 
    CONCAT(v.brand, '-', v.model) AS vehicle,
    v.vehicle_type,
    v.travelled_km,
    COUNT(t.trip_id) AS trips_completed
FROM
    vehicles v
        JOIN
    trips t ON v.vehicle_id = t.vehicle_id
GROUP BY v.vehicle_id
ORDER BY trips_completed DESC;

--  INTERMEDIATE ANALYTICS QUESTIONS
-- 11.Which season gives highest devotional trip bookings?

select season,count(*) as bookings from trip_season_view
 where tourism_type='devotional' group by season;
 
-- 12.Top 5 most profitable routes.
SELECT CONCAT(t.pickup_city, '-', t.drop_city)
AS route,FORMAT(SUM(tr.revenue), 0) AS profit 
 FROM trips t JOIN total_revenue tr ON 
t.trip_id = tr.trip_id GROUP BY 
t.pickup_city , t.drop_city
ORDER BY profit DESC LIMIT 5;



-- 13.Which tourism type has highest cancellation rate?

SELECT tourism_type,
ROUND(COUNT(CASE
WHEN trip_status = 'Cancelled' THEN 1
END) * 100.0 / COUNT(*),2) AS 
cancellation_rate FROM trips
GROUP BY tourism_type
ORDER BY cancellation_rate DESC;

-- 14.Which drivers generate highest revenue?

SELECT d.driver_name, FORMAT(SUM(tr.revenue), 0)
as revenue FROM drivers d JOIN trips t ON 
d.driver_id = t.driver_id JOIN total_revenue tr
 ON t.trip_id = tr.trip_id GROUP BY d.driver_name 
 order by revenue desc limit 5; 

-- 15.What is the average fuel cost per vehicle type?

SELECT 
    v.vehicle_type, ROUND(AVG(f.fuel_cost), 2) AS avg_fuel_cost
FROM
    vehicles v
        JOIN
    fuel_logs f ON v.vehicle_id = f.vehicle_id
GROUP BY v.vehicle_type;

-- 16.Find top revenue-generating destinations.

SELECT 
    t.drop_city AS destination,
    FORMAT(SUM(tr.revenue), 0) AS revenue
FROM
    trips t
        JOIN
    total_revenue tr ON t.trip_id = tr.trip_id
GROUP BY t.drop_city , t.trip_id
ORDER BY sum(tr.revenue) DESC
LIMIT 5;

-- 17. Which customers are our most loyal customers?

SELECT 
    c.customer_id, c.customer_name, COUNT(t.trip_id) AS bookings
FROM
    customers c
        JOIN
    trips t ON c.customer_id = t.customer_id
GROUP BY c.customer_id , c.customer_name
ORDER BY bookings DESC limit 16;


-- 18. Which routes generate the lowest profit?

SELECT 
    CONCAT(t.pickup_city, '-', t.drop_city) AS route,
    FORMAT(SUM(tr.revenue), 2) AS net_profit
FROM
    trips t
        JOIN
    total_revenue tr ON t.trip_id = tr.trip_id
GROUP BY CONCAT(t.pickup_city, '-', t.drop_city) order by SUM(tr.revenue) asc;

-- 19.Which vehicles are underutilized?

select v.vehicle_id,v.vehicle_number,concat(v.brand,'-',v.model) as model,v.vehicle_type,count(t.trip_id) as routes_completed
from vehicles v join trips t on v.vehicle_id=t.vehicle_id group by v.vehicle_id,v.vehicle_number order  by routes_completed asc;


-- 20. What is the overall business profit?

SELECT 
    FORMAT(((SELECT 
                SUM(booking_amount)
            FROM
                trips
            WHERE
                trip_status = 'Completed') - (SELECT 
                SUM(fuel_cost + toll_cost + food_cost + parking_cost + misc_expenses)
            FROM
                trip_expenses) - (SELECT 
                SUM(cost)
            FROM
                maintenance_logs)) - (SELECT 
                SUM(TIMESTAMPDIFF(MONTH,
                        joining_day,
                        CURDATE()) * salary)
            FROM
                drivers
            WHERE
                status = 'active' OR status = 'inactive'),
        0) AS business_profit,
    CASE
        WHEN
            ((SELECT 
                    SUM(booking_amount)
                FROM
                    trips
                WHERE
                    trip_status = 'Completed') - (SELECT 
                    SUM(fuel_cost + toll_cost + food_cost + parking_cost + misc_expenses)
                FROM
                    trip_expenses) - (SELECT 
                    SUM(cost)
                FROM
                    maintenance_logs)) - (SELECT 
                    SUM(TIMESTAMPDIFF(MONTH,
                            joining_day,
                            CURDATE()) * salary)
                FROM
                    drivers
                WHERE
                    status = 'active' OR status = 'inactive') > 0
        THEN
            'profit'
        ELSE 'loss'
    END AS profit_or_loss;


-- advanced 

-- 21.how much revenue did we generated in this month?
SELECT monthname(t.trip_start_date) as month,year(t.trip_start_date) as year,format(sum(tr.revenue),0) as revenue
from trips t join total_revenue tr on t.trip_id=tr.trip_id
where  MONTH(t.trip_start_date)=MONTH(CURDATE())
AND YEAR(t.trip_start_date)=YEAR(CURDATE()) 
group by  monthname(t.trip_start_date),year(t.trip_start_date);

-- 22. Which tourism type contributes the most revenue?

SELECT 
    t.tourism_type,
    format(SUM(te.revenue),0) AS revenue,
    concat((SUM(te.revenue)/(SELECT 
            SUM(revenue)
        FROM
            total_revenue) ) * 100,'%') AS contribution
FROM
    trips t
        JOIN
    total_revenue te ON t.trip_id = te.trip_id
GROUP BY t.tourism_type order by contribution desc;

-- 23. Which months have the highest booking volume?

select rank() over(order by count(trip_id) desc) 
as ranking,MONTHNAME(trip_start_date) AS month,
COUNT(trip_id) AS total_trips FROM trips
GROUP BY MONTHname(trip_start_date);


-- 24. What percentage of customers are repeat customers?

with return_customers as (
SELECT c.customer_id, COUNT(t.trip_id) AS trips FROM
customers c JOIN trips t ON c.customer_id = t.customer_id
GROUP BY c.customer_id HAVING COUNT(t.trip_id) > 1
ORDER BY trips DESC)

SELECT CONCAT(((SELECT COUNT(*) FROM
return_customers) / COUNT(customer_id) * 100),
'%') AS repeation_percetage FROM customers;
    
-- 25. Which vehicle gives the best return on maintenance investment?

with maintenance_investment as ( select vehicle_id,sum(cost)
 as investment from maintenance_logs group by vehicle_id)

select v.vehicle_id,concat(v.brand,'-',v.model) as vehicle,v.vehicle_type,
format(mi.investment,0)as amt_invested,format(sum(tr.revenue),0) as 
return_amt,ROUND(SUM(tr.revenue) / mi.investment,2) AS roi from vehicles v 
join total_revenue tr on v.vehicle_id=tr.vehicle_id join 
maintenance_investment mi on tr.vehicle_id=mi.vehicle_id group by 
v.vehicle_id order by roi desc limit 1;

-- 26. Which pickup city generates the highest business?

select  rank() over( order by sum(tr.revenue)desc,count(t.trip_id)
 desc ) as ranking,t.pickup_city,format(sum(tr.revenue),0) as 
 business_generated,count(t.trip_id) as trips_generated from trips t join
 total_revenue tr on t.trip_id=tr.trip_id group by t.pickup_city limit 1 ;
 
 -- 27. vehicle utilization %

 select v.vehicle_id,concat(v.brand,'-',v.model) as vehicle,
  round((count(t.trip_id)/(select count(*) from trips))*100,2)
  as utilization from vehicles v join trips t on v.vehicle_id
  =t.vehicle_id group by v.vehicle_id order by utilization desc;
  
 -- 28. until now how much money spent on each vehicle for fuel filling?
 
 select v.vehicle_id,concat(v.brand,'-',v.model) as vehicle,
 format(sum(fl.fuel_cost),2)as amt_spent,format(sum(fl.literes),0) as 
 petrol_used_literes from vehicles v join fuel_logs fl on 
 v.vehicle_id=fl.vehicle_id group by v.vehicle_id order by amt_spent desc;
 


