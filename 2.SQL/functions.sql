use fleet_management_system;

 -- function 1: trip_profit
 
  delimiter //
 create function trip_profit(p_trip_id int)
 returns decimal(10,2)
 deterministic
 begin
 declare profit decimal(10,2);
 select  t.booking_amount-te.expenses into profit from trips t join total_expenses te on t.trip_id=te.trip_id
 where p_trip_id=t.trip_id;
 return profit;
 end //
 
 delimiter ;
 
 -- function 2: driver_experience
 delimiter //
 
 CREATE FUNCTION driver_experience(d_id int) RETURNS int
    DETERMINISTIC
begin
declare experience int;
select timestampdiff(year,d.joining_day,curdate()) into experience from drivers d where d_id=d.driver_id;
return experience;
end
delimiter ;

-- function 3: vehicle_age
delimiter //

CREATE FUNCTION vehicle_age(v_id int) 
RETURNS int
    DETERMINISTIC
begin
declare age int;
select TIMESTAMPDIFF(YEAR, v.purchase_date, CURDATE()) into age from vehicles v where v_id=v.vehicle_id;
return age;
end
delimiter ;


-- function 4:vehicle_revenue

delimiter //
CREATE FUNCTION vehicle_revenue(v_id int) RETURNS decimal(10,2)
    DETERMINISTIC
begin
declare revenue decimal(10,2);
select sum(te.revenue) into revenue from trips t join total_revenue te on t.trip_id=te.trip_id
where v_id=t.vehicle_id group by t.vehicle_id;
return revenue;
end
delimiter ;


-- function 5: customer_lifetime_value

delimiter //
CREATE FUNCTION customer_ltv(c_id int) RETURNS decimal(10,2)
    DETERMINISTIC
begin
declare lifetime_value decimal(10,2);
select sum(te.revenue) into lifetime_value from customers c join 
trips t on c.customer_id=t.customer_id join total_revenue te on t.trip_Id=te.trip_id  where c_id=c.customer_id group by c.customer_id;
return lifetime_value;
end
delimiter ;


