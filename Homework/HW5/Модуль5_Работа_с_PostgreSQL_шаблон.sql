--=============== МОДУЛЬ 5. РАБОТА С POSTGRESQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Cделайте запрос к таблице payment. 
--Пронумеруйте все продажи от 1 до N по дате продажи.

select * from(
	select 
		payment_id,
		payment_date,
		row_number() over (order by payment_date)
	from payment) rn
where rn.row_number <= 10

--ЗАДАНИЕ №2
--Используя оконную функцию добавьте колонку с порядковым номером
--продажи для каждого покупателя,
--сортировка платежей должна быть по дате платежа.

select * from(
	select 
		payment_id,
		payment_date,
		customer_id ,
		row_number() over (partition by customer_id order by payment_date)
	from payment) rn
where rn.row_number <= 10

--ЗАДАНИЕ №3
--Для каждого пользователя посчитайте нарастающим итогом сумму всех его платежей,
--сортировка платежей должна быть по дате платежа.

select 
	customer_id ,
	payment_id,
	payment_date,
	amount,
	sum(amount) over (partition by customer_id order by payment_date) sum_amount
from payment

--ЗАДАНИЕ №4
--Для каждого покупателя выведите данные о его последней оплате аренде.

select 
	customer_id,
	payment_id,
	payment_date,
	amount 
from (
	select 
		customer_id,
		payment_id,
		payment_date,
		amount,
		row_number() over (partition by customer_id order by payment_date desc)
	from payment
	order by customer_id) l 
where row_number = 1
order by customer_id 


--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--С помощью оконной функции выведите для каждого сотрудника магазина
--стоимость продажи из предыдущей строки со значением по умолчанию 0.0
--с сортировкой по дате продажи

select 
	staff_id ,
	payment_id,
	payment_date,
	amount,
	lag(amount) over (partition by staff_id order by payment_date)
from payment

--ЗАДАНИЕ №2
--С помощью оконной функции выведите для каждого сотрудника сумму продаж за март 2007 года
--с нарастающим итогом по каждому сотруднику и по каждой дате продажи (дата без учета времени)
--с сортировкой по дате продажи

select 
	staff_id,
	pd,
	sum_amount,
	sum(sum_amount) over(partition by staff_id order by pd) 
from (select 
			staff_id, 
			payment_date::date as pd, 
			sum(amount) sum_amount
		from payment
		where extract(month from payment_date) = 3 and extract(year from payment_date) = 2007
		group by staff_id, pd 
		order by staff_id, pd) p 


--ЗАДАНИЕ №3
--Для каждой страны определите и выведите одним SQL-запросом покупателей, которые попадают под условия:
-- 1. покупатель, арендовавший наибольшее количество фильмов
-- 2. покупатель, арендовавший фильмов на самую большую сумму
-- 3. покупатель, который последним арендовал фильм

		Тут не победил (:
		Несколько дней борьбы не привели к успеху, очень надеюсь разберём на вебинаре.



