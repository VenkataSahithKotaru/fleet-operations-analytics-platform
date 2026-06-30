use fleet_management_system;

-- 1.view for net_profit

CREATE OR REPLACE VIEW net_profit AS
    SELECT ((select sum(revenue) from total_revenue)
         - COALESCE((SELECT 
                        SUM(cost)
                    FROM
                        maintenance_logs),
                0) - (select  salary from salary_expenses))AS net_profit;
-- 2. view for salary_expenses

create or replace view salary_expenses as
(SELECT 
        SUM(
            TIMESTAMPDIFF(
                MONTH,
                joining_day,
                CURDATE()
            ) * salary) as salary
    FROM drivers);
    
-- 3.view for total_expenses

CREATE VIEW total_expenses AS
    SELECT 
        te.expense_id,
        te.trip_id,
        (te.fuel_cost + te.toll_cost + te.food_cost + te.parking_cost + te.misc_expenses) AS expenses
    FROM
        trip_expenses te
            JOIN
        trips t ON t.trip_id = te.trip_id
    WHERE
        t.trip_status = 'completed';
        
 -- 4. view for total_revenue
 
 CREATE VIEW total_revenue AS
SELECT
    tr.trip_id,
    tr.vehicle_id,
    tr.booking_amount -
    (
        t.fuel_cost +
        t.toll_cost +
        t.food_cost +
        t.parking_cost +
        t.misc_expenses
    ) AS revenue
FROM trips tr
JOIN trip_expenses t
ON tr.trip_id = t.trip_id
WHERE tr.trip_status = 'Completed';

-- 5. view for trip_season_view

CREATE VIEW trip_season_view AS
    SELECT *,CASE
WHEN MONTH(trip_start_date) IN (11 , 12, 1, 2) THEN 'Winter'
WHEN MONTH(trip_start_date) IN (3 , 4, 5, 6) THEN 'Summer'
WHEN MONTH(trip_start_date) IN (7 , 8, 9) THEN 'Monsoon'
ELSE 'Festival'END AS season FROM trips;

-- 6.view for vehicle_maintenances

CREATE VIEW vehicle_maintenance AS
SELECT
    vehicle_id,
    SUM(cost) AS maintenance_cost
FROM maintenance_logs
GROUP BY vehicle_id;