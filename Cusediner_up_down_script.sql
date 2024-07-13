if not exists(select * from sys.databases where name='cusediner')
    create database cusediner
GO

use cusediner
GO
-- DOWN script
if exists(select * from sys.objects where name='driver_ratings')
	drop table driver_ratings
if exists(select * from sys.objects where name='item_ratings')
	drop table item_ratings
if exists(select * from sys.objects where name='orders')
	drop table orders
if exists(select * from sys.objects where name='payments')
	drop table payments
if exists(select * from sys.objects where name='creditcards')
	drop table creditcards
if exists(select * from sys.objects where name='drivers')
	drop table drivers
if exists(select * from sys.objects where name='addresses')
	drop table addresses
if exists(select * from sys.objects where name='customers')
	drop table customers
if exists(select * from sys.objects where name='state_tax_lookup')
	drop table state_tax_lookup
if exists(select * from sys.objects where name='delivery_type_lookup')
	drop table delivery_type_lookup
if exists(select * from sys.objects where name='payment_type_lookup')
	drop table payment_type_lookup
if exists(select * from sys.objects where name='menu_item_lookup')
	drop table menu_item_lookup
if exists(select * from sys.objects where name='food_category_lookup')
	drop table food_category_lookup

GO

-- UP Script
CREATE TABLE food_category_lookup(
	category_id int identity not null,
    category varchar(50) not null,
    constraint pk_food_category_lookup_category primary key (category)
)
GO
CREATE TABLE menu_item_lookup(
	item_id int identity not null,
    item_category varchar(50) not null,
    item_name varchar(100) not null,
    item_description varchar(200),
    item_price money not null,
    constraint pk_menu_item_lookup_item_id primary key (item_id),
    constraint fk_menu_item_lookup_category
		foreign key (item_category) references food_category_lookup(category)
)
GO
CREATE TABLE payment_type_lookup(
	payment_type_id int identity not null,
    payment_type_name varchar(50) not null,
    constraint pk_payment_type_lookup_payment_type_id primary key (payment_type_id)
)
GO
CREATE TABLE delivery_type_lookup(
    delivery_type_id int identity not null,
    delivery_type_name varchar(50) not null,
    delivery_waittime varchar(50) not null,
    delivery_charge money,
    constraint pk_delivery_type_lookup_delivery_type_id primary key (delivery_type_id)
)
GO
CREATE TABLE state_tax_lookup(
    state_id int identity not null,
    state_code char(2) not null,
    state_tax_percent decimal(5,4),
    constraint pk_state_tax_lookup_state_id primary key (state_id),
    constraint ck_valid_tax_percent check (state_tax_percent>=0 AND state_tax_percent<=1)
)
GO
CREATE TABLE customers(
    customer_id int identity not null,
    customer_firstname varchar(50) not null,
    customer_lastname varchar(50) not null,
    customer_email varchar(50) not null,
    customer_contact varchar(15) not null,
    customer_password varchar(20) not null,
    constraint pk_customers_customer_id primary key (customer_id),
    constraint u_customer_email unique(customer_email)
)
GO
CREATE TABLE addresses(
    address_id int identity not null,
    address_customer_id int not null,
    address_primary_street varchar(50) not null,
    address_secondary_street varchar(50),
    address_city varchar(50) not null,
    address_state char(2) not null,
    address_postal_code varchar(10) not null,
    constraint pk_addresses_address_id primary key(address_id),
    constraint fk_addresses_customer_id 
        foreign key (address_customer_id) references customers(customer_id)
)
GO 
CREATE TABLE drivers(
    driver_id int identity not null,
    driver_firstname varchar(50) not null,
    driver_lastname varchar(50) not null,
    driver_contact varchar(15) not null,
    constraint pk_drivers_driver_id primary key (driver_id)
)
GO
CREATE TABLE creditcards(
    creditcard_id int identity not null,
    creditcard_number varchar(50) not null,
    creditcard_expdate varchar(20) not null,
    constraint pk_creditcards_creditcard_id primary key (creditcard_id)
)
GO
CREATE TABLE payments(
    payment_id int identity not null,
    payment_type_id int not null,
    payment_card_id int,
    payment_total money not null,
    payment_subtotal money not null,
    payment_tax money not null,
    constraint pk_payments_payment_id primary key (payment_id),
    constraint fk_payments_payment_type_id foreign key (payment_type_id) references payment_type_lookup(payment_type_id),
    constraint fk_payments_payment_card_id foreign key (payment_card_id) references creditcards(creditcard_id)
)
GO
CREATE TABLE orders(
    order_id int identity not null,
    order_customer_id int not NULL,
    order_address_id int not null,
    order_payment_id int not null,
    order_delivery_type_id int not null,
    order_driver_id int not null,
    order_items varchar(100) not null,
    order_status char(1) default 'C' not null,
    order_date datetime not null,
    constraint pk_orders_order_id primary key (order_id),
    constraint fk_orders_order_customer_id foreign key (order_customer_id) references customers(customer_id),
    constraint fk_orders_order_address_id foreign key (order_address_id) references addresses(address_id),
    constraint fk_orders_order_payment_id foreign key (order_payment_id) references payments(payment_id),
    constraint fk_orders_order_delivery_type_id foreign key (order_delivery_type_id) references delivery_type_lookup(delivery_type_id),
    constraint fk_orders_driver_id foreign key (order_driver_id) references drivers(driver_id)
)
GO
CREATE TABLE item_ratings(
    item_rating_id int identity not null,
    rating_by_cust_id int not null,
    rating_for_item_id int not null,
    rating_value int not null,
    rating_comment varchar(200),
    constraint item_ratings_item_rating_id primary key (item_rating_id),
    constraint item_ratings_rating_by_cust_id foreign key (rating_by_cust_id) references customers(customer_id),
    constraint item_ratings_rating_for_item_id foreign key (rating_for_item_id) references menu_item_lookup(item_id),
    constraint ck_rating_value_range check (rating_value>0 AND rating_value<=5)
)
GO
CREATE TABLE driver_ratings(
    driver_rating_id int identity not null,
    driver_rating_by_cust_id int not null,
    rating_for_driver_id int not null,
    driver_rating_value int not null,
    driver_rating_comment varchar(200),
    constraint driver_ratings_driver_rating_id primary key (driver_rating_id),
    constraint driver_ratings_rating_by_cust_id foreign key (driver_rating_by_cust_id) references customers(customer_id),
    constraint driver_ratings_rating_for_item_id foreign key (rating_for_driver_id) references drivers(driver_id),
    constraint ck_driver_rating_value_range check (driver_rating_value>0 AND driver_rating_value<=5)
)
GO

-- Data insertion script

INSERT INTO food_category_lookup (category) VALUES
	('Fast Food'),
	('Chicken'),
	('Drinks'),
	('Burgers'),
	('Snacks'),
	('Desserts'),
	('Sandwiches'),
	('Salad'),
	('Mexican'),
	('Pizza');
GO
INSERT INTO menu_item_lookup (item_category, item_name, item_description, item_price) VALUES
	('Fast Food','Cheeseburger','A combination of tastes and textures – hamburger topped with cheese',4.42),
	('Fast Food','French Fries','Made from deep-fried potatoes', 2.18),
	('Fast Food','Spicy Chicken Sandwich','A juicy chicken breast with pickle slices and spicy mayo',4.59),
	('Fast Food','8pc Nuggets','8 bite sized chicken nuggets fried until golden brown',4.25),
	('Fast Food','Chilli','Perfectly seasoned and positively irresistable',4.36),
	('Chicken','Chicken Teriyaki','Chicken with vegetable teriyaki sauce',19.85),
	('Chicken','Sesame Chicken','Spicy chicken served with fried rice and pork egg roll',11.50),
	('Chicken','Chicken with Broccoli','Spicy chicken and veg broccoli served with fried rice and pork egg roll',11.50),
	('Chicken','Jerk Chicken Rasta','Tossed with vegetables and jerk sauce and parmesan cheese',18.00),
	('Drinks','Dr Pepper','',2.99),
	('Drinks','Coke Cherry','',2.49),
	('Drinks','Starbust Fruit Punch','',1.00),
	('Burgers','Big Bacon BBQ','Beef patties with bacon and cheddar cheese',19.19),
	('Burgers','BBQ Brisket Burger','Brisket with house BBQ along with cheddar and pickles',15.49),
	('Snacks','Munchies','Flaming hot munchies',1.99),
	('Snacks','Tostitos','Salt and crispy',2.05),
	('Desserts','Triple Chocolate','Buttery cookie with triple serving of gooey chocolate',5.00),
	('Desserts','Fat Cow Sundae','Choice of icecream with hot fudge and peanut butter',9.00),
	('Desserts','Ice Cream Sandwich','An assortment of chocolate, vanilla and twist made daily',6.15),
	('Sandwiches','Oven Roasted Turkey','Thin sliced oven roasted turkey with crisp veggies on hearty multigrain bread',7.19),
	('Sandwiches','Steak & Cheese','Delicious steak with melty cheesiness along with veggies and sauce',7.79),
	('Sandwiches','Meatball Marinara','Sandwich drenched in marinara sauce and sprinkled with parmesan cheese',6.49),
	('Salad','Keto Salad Bowl','Lettuce and brown rice with black beans topped with veggies',11.05),
	('Salad','Vegan Bowl','Brown rice with black beans and roasted chilli corn salsa',11.05),
	('Mexican','Nacho Fries','Crisp nacho fries seasoned with bold mexican spices and nacho cheese',2.43),
	('Mexican','Baja Tacos','Shredded chicken or ground beef tacos with lettuce and shredded cheese',16.00),
	('Pizza','Chicago Style Pizza','Large pizza topped with fresh basil and loads of cheese with choice of meat',15.39);
GO
INSERT INTO payment_type_lookup (payment_type_name) VALUES
	('Credit/Debit Card'),
	('Google Pay');
GO
INSERT INTO delivery_type_lookup (delivery_type_name,delivery_waittime,delivery_charge) VALUES
	('Express','57-72 min',2.99),
	('Standard','62-77 min',null);
GO
INSERT INTO state_tax_lookup (state_code,state_tax_percent) VALUES
	('NY',0.12),
	('NJ',0.25),
	('CO',0.19),
	('AK',0.42),
	('LA',0.35),
	('CA',0.11),
	('SC',0.15),
	('TX',0.17),
	('UT',0.19),
	('WI',0.11);
GO
INSERT INTO customers (customer_firstname,customer_lastname,customer_email,customer_contact,customer_password) VALUES
	('Dan','Hooks','danhooks987@gmail.com','315-984-0987','Bhdbbbsa@12'),
	('Arie','Banks','ariebanks64@gmail.com','314-004-0965','Jnhcnhs@455'),
	('Mike','Woody','mikewoody009@gmail.com','315-084-0237','Khaud@19023'),
	('Danny','Brown','dannybrown12@gmail.com','315-984-0187','Lobs#134'),
	('Liz','Mon','lizmon23@gmail.com','315-914-1987','Mnskq0$738'),
	('Minnie','Arthur','minniearthur009@gmail.com','315-904-0211','Pawqyr$12');
GO
INSERT INTO addresses (address_customer_id,address_primary_street,address_secondary_street,address_city,address_state,address_postal_code) VALUES
	(1,'105 Concord Pl','','Syracuse','NY','13210'),
	(2,'420 Westcott','Apt 1','Syracuse','NY','13210'),
	(1,'205 Ostrom Ave','','Syracuse','NY','13209'),
	(3,'307 Redfield Pl','','Syracuse','NY','13210'),
	(3,'908 Maryland','','Syracuse','NY','13210'),
	(4,'876 Ackerman Aev','','Syracuse','NY','13210'),
	(6,'198 Concord Pl','','Syracuse','NY','13210'),
	(6,'650 Sumner Ave','','Syracuse','NY','13210');
GO
INSERT INTO drivers (driver_firstname,driver_lastname,driver_contact) VALUES
	('Connie','Cooper','315-093-0032'),
	('Rob','Adams','315-693-9832'),
	('Miley','Bayer','315-123-4567'),
	('James','Bond','315-452-1298');
GO
INSERT INTO creditcards (creditcard_number,creditcard_expdate) VALUES
	('4356','12/29'),
	('9032','09/24'),
	('8902','03/28'),
	('9912','11/25'),
	('3456','12/22');
GO
INSERT INTO payments (payment_type_id,payment_card_id,payment_total,payment_subtotal,payment_tax) VALUES
	(1,2,45,40,5),
	(1,5,91,80,11),
	(1,4,115,100,15),
	(1,1,280,240,40),
	(1,3,36,34,2),
	(2,NULL,11,10,1),
	(2,NULL,45,40,5),
	(2,NULL,70,60,10);
GO
INSERT INTO orders (order_customer_id,order_address_id,order_payment_id,order_delivery_type_id,order_driver_id,order_items,order_status,order_date) VALUES
	(2,2,1,2,3,'13,23,24','C','2022-08-09'),
	(1,3,2,2,2,'13,23,24,9,7','C','2022-10-09'),
	(2,2,3,2,1,'13,21,7,9','C','2022-02-08'),
	(4,6,4,2,3,'12,14,23','C','2022-09-19'),
	(6,7,5,2,4,'13,14,25','C','2022-08-29'),
	(3,5,6,2,1,'1,5,7,8','C','2022-07-09'),
	(6,8,7,2,3,'8,13,14','C','2022-08-09'),
	(3,5,8,2,4,'13,23,24,15,17','C','2022-08-09');
GO
INSERT INTO item_ratings (rating_by_cust_id,rating_for_item_id,rating_value,rating_comment) VALUES
	(1,23,4,'Good taste liked it'),
	(1,13,3,'Delicious but okay'),
	(2,23,4,'Good taste liked it'),
	(1,9,2,'Okay'),
	(3,8,4,'Good taste liked it'),
	(6,13,5,'Lovin it'),
	(4,12,1,'Not worth'),
	(3,6,4,'Good taste liked it'),
	(1,7,3,'Okay'),
	(2,21,5,'Lovin it');
GO
INSERT INTO driver_ratings (driver_rating_by_cust_id,rating_for_driver_id,driver_rating_value,driver_rating_comment) VALUES
	(2,3,4,'Good Service'),
	(1,2,3,'Delayed delivery'),
	(2,1,4,'Good Service'),
	(4,3,2,'Spilled food'),
	(6,4,4,'Good Service'),
	(3,1,5,'Timely delivery and friendly person'),
	(6,3,1,'Did not deliver properly'),
	(3,4,4,'Good service');
GO
-- verification scripts
select * from food_category_lookup
select * from menu_item_lookup
select * from payment_type_lookup
select * from delivery_type_lookup
select * from state_tax_lookup
select * from customers
select * from addresses
select * from drivers
select * from creditcards
select * from payments
select * from orders
select * from item_ratings
select * from driver_ratings

-- stored procedure 1
DROP PROCEDURE IF EXISTS p_insert_details_on_signup
GO
CREATE PROCEDURE p_insert_details_on_signup(
    @first_name varchar(50),
    @lastname varchar(50),
	@email varchar(50),
	@password varchar(20),
	@phone varchar(15),
	@primary_street varchar(50),
	@secondary_street varchar(50),
	@city varchar(50),
	@state char(2),
	@postal_code varchar(10)
) 
AS 
	BEGIN
		BEGIN TRY
			BEGIN TRANSACTION
				IF EXISTS (select * from customers where customer_email=@email)
					THROW 50001, 'Customer with this email id already exists',1
				ELSE BEGIN
					INSERT INTO customers (customer_firstname,customer_lastname,customer_email,customer_contact,customer_password) VALUES
						(@first_name,@lastname,@email,@phone,@password);
					DECLARE @temp_id INT = (SELECT MAX(customer_id) FROM customers)
					INSERT INTO addresses (address_customer_id,address_primary_street,address_secondary_street,address_city,address_state,address_postal_code) VALUES
						(@temp_id,@primary_street,@secondary_street,@city,@state,@postal_code);
					COMMIT
				END
		END TRY
		BEGIN CATCH
        	ROLLBACK
        	;
        	THROW
    	END CATCH
END
GO
/*execute p_insert_details_on_signup @first_name='Sai', @lastname='Reddy', @email='saireddy12@gmail.com', @password='Lohbhbc@345', @phone='314-606-1236', 
	@primary_street='1028 Columbus Ave', @secondary_street='', @city='Syracuse', @state='NY', @postal_code='13210'
GO 
select * from customers
select * from addresses*/

-- stored procedure 2
DROP PROCEDURE IF EXISTS p_rate_food_items
GO
CREATE PROCEDURE p_rate_food_items(
    @rating_by_cust_id int,
    @rating_for_item_id int,
	@rating_value int,
	@rating_comment varchar(200)
) 
AS 
	BEGIN
		BEGIN TRY
			BEGIN TRANSACTION
				if(@rating_value >5)
                	THROW 50001, 'Rating value should be between 1 and 5',1
            	if(@rating_value <1)
                	THROW 50002, 'Rating value should be between 1 and 5',1
            	insert into item_ratings (rating_by_cust_id, rating_for_item_id, rating_value, rating_comment)
            		values (@rating_by_cust_id, @rating_for_item_id, @rating_value, @rating_comment) 
            	commit
        END TRY
        BEGIN CATCH
            ROLLBACK
            ;
            THROW
        END CATCH
END
GO
/*execute p_rate_food_items @rating_by_cust_id=2, @rating_for_item_id=13, @rating_value=5, @rating_comment='Loved the taste'
GO 
select * from item_ratings
GO*/

-- stored procedure 3
DROP PROCEDURE IF EXISTS p_rate_drivers
GO
CREATE PROCEDURE p_rate_drivers(
    @driver_rating_by_cust_id int,
    @rating_for_driver_id int,
	@driver_rating_value int,
	@driver_rating_comment varchar(200)
) 
AS 
	BEGIN
		BEGIN TRY
			BEGIN TRANSACTION
				if(@rating_value >5)
                	THROW 50001, 'Rating value should be between 1 and 5',1
            	if(@rating_value <1)
                	THROW 50002, 'Rating value should be between 1 and 5',1
            	insert into driver_ratings (driver_rating_by_cust_id, rating_for_driver_id, driver_rating_value, driver_rating_comment)
            		values (@driver_rating_by_cust_id, @rating_for_driver_id, @driver_rating_value, @driver_rating_comment) 
            	commit
        END TRY
        BEGIN CATCH
            ROLLBACK
            ;
            THROW
        END CATCH
END
GO
/*execute p_rate_drivers @driver_rating_by_cust_id=2, @rating_for_driver_id=13, @driver_rating_value=5, @driver_rating_comment='excellent'
GO */

--- stored procedure 4
DROP PROCEDURE IF EXISTS p_confirm_order
GO
CREATE PROCEDURE p_confirm_order(
	@creditcard_number varchar(20),
	@creditcard_expdate varchar(10),
	@payment_type_id int,
	@payment_total money,
	@payment_subtotal money,
    @customer_id int,
	@cust_address_id int,
	@delivery_type_id int,
	@driver_id int,
	@order_items varchar(50)
) 
AS 
	BEGIN
		BEGIN TRY
			BEGIN TRANSACTION
				IF(@payment_type_id != 2) BEGIN
					insert into creditcards (creditcard_number,creditcard_expdate) values (@creditcard_number,@creditcard_expdate);
					declare @payment_card_id int = (Select max(creditcard_id) from creditcards);
				END	
				declare @payment_tax money = @payment_total - @payment_subtotal;
				insert into payments (payment_type_id,payment_card_id,payment_total,payment_subtotal,payment_tax) 
					values (@payment_type_id,@payment_card_id,@payment_total,@payment_subtotal,@payment_tax);
				declare @temp_id int = (select max(payment_id) from payments);
				insert into orders (order_customer_id,order_address_id,order_payment_id,order_delivery_type_id,order_driver_id,order_items,order_date) 
					values (@customer_id,@cust_address_id,@temp_id,@delivery_type_id,@driver_id,@order_items,getdate())
				COMMIT

        END TRY
        BEGIN CATCH
            ROLLBACK
            ;
            THROW
        END CATCH
END
GO
/*execute p_confirm_order @creditcard_number='2342', @creditcard_expdate='10/29', @payment_type_id=1, @payment_total=120, @payment_subtotal=99, @customer_id=1,
@cust_address_id=1, @delivery_type_id=1, @driver_id=3, @order_items='12,4,8,1,7'
GO
select * from creditcards
select * from payments
select * from orders*/

GO

--- view to get the highest rater name for each item with their rating value
DROP VIEW IF EXISTS v_item_rating
GO
CREATE VIEW v_item_rating AS
	select c.customer_firstname + ' ' + c.customer_lastname as highest_rater, m.item_name, i.rating_comment,
		FIRST_VALUE(i.rating_value) over (partition by i.rating_for_item_id order by i.rating_value desc) as highest_rating,
		FIRST_VALUE(i.rating_by_cust_id) over (partition by i.rating_for_item_id order by i.rating_value desc) as highest_rater_user_id
		from item_ratings i
		join customers c on c.customer_id=i.rating_by_cust_id 
		join menu_item_lookup m on m.item_id=i.rating_for_item_id

GO
SELECT * from v_item_rating


























