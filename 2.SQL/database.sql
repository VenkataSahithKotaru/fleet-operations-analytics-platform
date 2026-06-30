create database fleet_management_system;

use fleet_management_system;

create table customers
(
customer_id int primary key,
customer_name varchar(250) not null,
phone_num varchar(250) not null,
city varchar(200),
customer_type varchar(200));

create table drivers
(
driver_id int primary key,
driver_name varchar(250) not null,
phone_num varchar(250) not null,
license_num varchar(200) unique,
license_expiry date,
joining_day date,
salary int,
status varchar(200));


create table vehicles 
(
vehicle_id int primary key,
vehicle_number varchar(250) unique,
vehicle_type varchar(200),
brand varchar(200),
model varchar(200),
seating_capacity int,
fuel_type text,
purchase_date date,
vehicle_status text,
travelled_km int);


create table trips 
(
trip_id int primary key,
customer_id int not null,
vehicle_id int not null,
driver_id int not null,
pickup_city text not null,
drop_city text,
distance_to_travel int not null,
tourism_type text,
trip_category text,
trip_start_date datetime,
trip_end_date datetime,
trip_status text,
booking_amount int,
advance_paid int,
payment_status text,
foreign key (customer_id) references customers(customer_id),
foreign key (vehicle_id) references vehicles(vehicle_id),
foreign key (driver_id) references drivers(driver_id));


create table vehicle_documents
(
document_id int primary key,
vehicle_id int,
doc_type text,
expiry_date date,
foreign key (vehicle_id) references vehicles(vehicle_id));


create table trip_expenses
(
expense_id int primary key,
trip_id int,
fuel_cost int,
toll_cost int,
food_cost int,
parking_cost int,
misc_expenses int,
foreign key (trip_id) references trips(trip_id));


create table payments
(
payment_id int primary key,
trip_id int,
payment_date date,
amount_paid int,
payment_method text,
foreign key (trip_id) references trips(trip_id));


create table fuel_logs
(
fuel_log_id int primary key,
vehicle_id int,
fuel_date date,
literes int,
fuel_cost int,
odometer_reading int,
foreign key (vehicle_id) references vehicles(vehicle_id));



create table maintenance_logs
(
maintenance_log_id int primary key,
vehicle_id int,
service_date date,
service_type text,
cost int,
next_service_due date,
foreign key (vehicle_id) references vehicles(vehicle_id));


