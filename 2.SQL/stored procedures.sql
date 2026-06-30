use fleet_management_system;

-- 1. stored procedure for bussiness summary

DELIMITER //

CREATE PROCEDURE business_summary()
BEGIN
    DECLARE total_trips INT;
    DECLARE total_revenue DECIMAL(15,2);
    DECLARE total_maintenance DECIMAL(15,2);
    DECLARE total_salary DECIMAL(15,2);
    DECLARE total_profit DECIMAL(15,2);
    DECLARE pending_amount DECIMAL(15,2);

    -- Completed Trips
    SELECT COUNT(*)
    INTO total_trips
    FROM trips
    WHERE trip_status = 'Completed';

    -- Revenue (Booking Amount - Trip Expenses)
    SELECT COALESCE((select SUM(booking_amount) from trips where trip_status='completed')
    -(select sum(expenses) from total_expenses),0)
    INTO total_revenue;

    -- Maintenance Cost
    SELECT COALESCE(SUM(cost),0)
    INTO total_maintenance
    FROM maintenance_logs;

    -- Salary Expense
    SELECT 
        SUM(
            TIMESTAMPDIFF(
                MONTH,
                joining_day,
                CURDATE()
            ) * salary
        )
    
    INTO total_salary
    FROM drivers;

    -- Pending Amount
    SELECT COALESCE(SUM(booking_amount),0)
    INTO pending_amount
    FROM trips
    WHERE payment_status = 'Pending';

    -- Net Profit
    SET total_profit =
        total_revenue
        - total_maintenance
        - total_salary;

    -- Business Summary Output
    SELECT
        FORMAT(total_trips,0) AS completed_trips,
        FORMAT(total_revenue,2) AS revenue,
        FORMAT(total_maintenance,2) AS maintenance_cost,
        FORMAT(total_salary,2) AS salary_expense,
        FORMAT(pending_amount,2) AS pending_amount,
        FORMAT(total_profit,2) AS net_profit;

END //

DELIMITER ;


--  stored procedure for customer_statement

DELIMITER //

CREATE PROCEDURE customer_statement(
    IN c_id int
)
BEGIN
select c.customer_id,c.customer_name,count(t.trip_id) as trips_completed,format(sum(case 
when t.payment_status='paid' then t.booking_amount else 0 end),0)as amount_spent
, format(SUM(
            CASE WHEN t.payment_status = 'pending' THEN t.booking_amount
                ELSE 0 END
        ),0) as amount_pending from customers c join trips t on 
c.customer_id=t.customer_id where c_id=c.customer_id group by c.customer_id,c.customer_name;
    -- logic

END

DELIMITER //

-- 3.stored procedure for driver_performance

DELIMITER //
CREATE PROCEDURE driver_performence(
in d_id int)
begin
select d.driver_id,d.driver_name,timestampdiff(year,d.joining_day,curdate())
 as experience,count(t.trip_id) as trips_completed,format(sum(tr.revenue),0)
 as revenue_generated from drivers d join trips t on d.driver_id=t.driver_id 
 join total_revenue tr on t.trip_id=tr.trip_id where d_id=d.driver_id group by d.driver_id,d.driver_name;
end
DELIMITER //


-- 4.stored procedure for vehicle_performance

DELIMITER //
CREATE PROCEDURE vehicle_performance(
    IN v_id INT
)
BEGIN

    SELECT
        v.vehicle_id,
        CONCAT(v.brand,'-',v.model) AS vehicle,
        v.travelled_km,
        COALESCE(f.fuel_used,0) AS fuel_used,
        COALESCE(r.vehicle_revenue,0) AS vehicle_revenue,
        COALESCE(t.trips_completed,0) AS trips_completed,
        COALESCE(m.maintenance_spent,0) AS maintenance_spent
    FROM vehicles v

    LEFT JOIN (
        SELECT
            vehicle_id,
            format(SUM(literes),0) AS fuel_used
        FROM fuel_logs
        GROUP BY vehicle_id
    ) f ON v.vehicle_id = f.vehicle_id

    LEFT JOIN (
        SELECT
            vehicle_id,
            format(SUM(revenue),0) AS vehicle_revenue
        FROM total_revenue
        GROUP BY vehicle_id
    ) r ON v.vehicle_id = r.vehicle_id

    LEFT JOIN (
        SELECT
            vehicle_id,
            COUNT(*) AS trips_completed
        FROM trips
        GROUP BY vehicle_id
    ) t ON v.vehicle_id = t.vehicle_id

    LEFT JOIN (
        SELECT
            vehicle_id,
            format(SUM(cost),0) AS maintenance_spent
        FROM maintenance_logs
        GROUP BY vehicle_id
    ) m ON v.vehicle_id = m.vehicle_id

    WHERE v.vehicle_id = v_id;

END
DELIMITER //