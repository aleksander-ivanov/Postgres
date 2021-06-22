--=============== МОДУЛЬ 6. POSTGRESQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Напишите SQL-запрос, который выводит всю информацию о фильмах 
--со специальным атрибутом "Behind the Scenes".
--explain analyze
select film_id, title, special_features from film
where special_features @> '{"Behind the Scenes"}'
order by film_id 

--ЗАДАНИЕ №2
--Напишите еще 2 варианта поиска фильмов с атрибутом "Behind the Scenes",
--используя другие функции или операторы языка SQL для поиска значения в массиве.
--explain analyze
select film_id, title, special_features from film
where 'Behind the Scenes' = any(special_features)
order by film_id 
--explain analyze
select film_id, title, special_features from film
where array_to_string(special_features, ',') like '%Behind the Scenes%'
order by film_id 
--explain analyze
select film_id, title, special_features from film
where special_features[2] like '%Behind the Scenes%'
order by film_id 

--ЗАДАНИЕ №3
--Для каждого покупателя посчитайте сколько он брал в аренду фильмов 
--со специальным атрибутом "Behind the Scenes.

--Обязательное условие для выполнения задания: используйте запрос из задания 1, 
--помещенный в CTE. CTE необходимо использовать для решения задания.
--explain analyze
with cte as (
	select film_id, title, special_features from film
	where special_features @> '{"Behind the Scenes"}'
	order by film_id
)
select 
	customer_id,	
	count(row_number)
from (
	select 
		customer_id,
		i.film_id,
		rental_date,
		row_number() over (partition by customer_id order by rental_date desc)
	from rental r
	join inventory i on i.inventory_id = r.inventory_id
	where i.film_id in (select film_id from cte)
	order by customer_id) rn 
group by customer_id


--ЗАДАНИЕ №4
--Для каждого покупателя посчитайте сколько он брал в аренду фильмов
-- со специальным атрибутом "Behind the Scenes".

--Обязательное условие для выполнения задания: используйте запрос из задания 1,
--помещенный в подзапрос, который необходимо использовать для решения задания.
explain analyze
select 
	customer_id,	
	count(row_number)
from (
	select 
		customer_id,
		i.film_id,
		rental_date,
		row_number() over (partition by customer_id order by rental_date desc)
	from rental r
	join inventory i on i.inventory_id = r.inventory_id
	where i.film_id in (select film_id from (
		select film_id, title, special_features from film
		where special_features @> '{"Behind the Scenes"}'
		order by film_id) f1)
	order by customer_id) rn 
group by customer_id



--ЗАДАНИЕ №5
--Создайте материализованное представление с запросом из предыдущего задания
--и напишите запрос для обновления материализованного представления

create materialized view films_per_customer as 
(
	select 
		customer_id,	
		count(row_number)
	from (
		select 
			customer_id,
			i.film_id,
			rental_date,
			row_number() over (partition by customer_id order by rental_date desc)
		from rental r
		join inventory i on i.inventory_id = r.inventory_id
		where i.film_id in (select film_id from (
			select film_id, title, special_features from film
			where special_features @> '{"Behind the Scenes"}'
			order by film_id) f1)
		order by customer_id) rn 
	group by customer_id
)


REFRESH MATERIALIZED VIEW films_per_customer;


--ЗАДАНИЕ №6
--С помощью explain analyze проведите анализ скорости выполнения запросов
-- из предыдущих заданий и ответьте на вопросы:

--1. Каким оператором или функцией языка SQL, используемых при выполнении домашнего задания, 
--   поиск значения в массиве происходит быстрее
--2. какой вариант вычислений работает быстрее: 
--   с использованием CTE или с использованием подзапроса

1. Стоимость поиска значения в массиве:
	 - where special_features @> '{"Behind the Scenes"}' - 92.25
	 - where 'Behind the Scenes' = any(special_features) - 102.25
	 - where array_to_string(special_features, ',') like '%Behind the Scenes%' - 69.02
	 - where special_features[2] like '%Behind the Scenes%' - 66.52
	 Вывод: фильтрация по индексу элемента происхожит быстрее всего, самый медленный оператор - any()
 2. какой вариант вычислений работает быстрее: 
 	- с использованием CTE - 1621.87
 	- с использованием подзапроса - 300.53
 	Вывод: Запрос работает быстрее с подзапросом


--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выполняйте это задание в форме ответа на сайте Нетологии
explain analyze
select distinct 
 	cu.first_name  || ' ' || cu.last_name as name, 
	count(ren.iid) over (partition by cu.customer_id)
from customer cu
full outer join 
	(select *, r.inventory_id as iid, inv.sf_string as sfs, r.customer_id as cid
	from rental r 
	full outer join 
		(select *, unnest(f.special_features) as sf_string
		from inventory i
		full outer join film f on f.film_id = i.film_id) as inv 
		on r.inventory_id = inv.inventory_id) as ren 
	on ren.cid = cu.customer_id 
where ren.sfs like '%Behind the Scenes%'
order by count desc

-- Описание:
--Время выполнения запроса Execution Time: 63.300 ms. 
Запрос неэффективен, тк содержит три full outer join которые возвращают полные наборы данных вне зависимости есть совпадения или нет в соединяемых таблицах. учше всегда ограничивать выборки, те делать предварительную фильтрацию данных.
В результате оконная ф-ция count ыполняется очень медленно.
Время выполнения моего варианта запроса (4е задание) - Execution Time: 13.768 ms, стоимость по ресурсам 1621.87
Его описание:
1. Сначала сканируется таблица film (Seq Scan) и сразу фильтруется (Filter: (special_features @> '{"Behind the Scenes"}'::text[])). cost=0.00..66.50, actual time=0.013..0.476
2. Далее сортировка по film_id, затраты: cost=90.90..92.25, actual time=0.501..0.516
3. Далее сканирование подзапроса cost=90.90..97.63, actual time=0.501..0.546
4. Сканирование таблицы inventory и её фильтрация по условию i.film_id = f1.film_id. Стоимость: cost=97.63..97.63, actual time=0.616..0.617
5. Сканирование таблицы rental и фильтрация Hash Cond: (r.inventory_id = i.inventory_id) cost=0.00..310.44, actual time=0.011..1.044
6. Сортировка таблицы rental Key: r.customer_id, r.rental_date desc. Стоимость: cost=1300.53..1323.05, actual time=9.315..9.853
7. Выполнение оконной ф-ции row_number(). Стоимость: cost=1300.53..1480.73, actual time=9.321..13.308
8. Группировка результата. Стоимость: cost=1300.53..1621.87, actual time=9.333..14.256


--ЗАДАНИЕ №2
--Используя оконную функцию выведите для каждого сотрудника
--сведения о самой первой продаже этого сотрудника.

with c as (
	select p.staff_id, p.payment_id, p.rental_id, p.customer_id, p.payment_date, p.amount, row_number () over (partition by p.staff_id order by p.payment_date)
	from payment p
)
select c.staff_id, i.film_id, f.title, c.amount, c.payment_date, c1.last_name, c1.first_name 
from c 
join rental r on r.rental_id = c.rental_id
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id 
join customer c1 on c1.customer_id = c.customer_id
where row_number = 1


--ЗАДАНИЕ №3
--Для каждого магазина определите и выведите одним SQL-запросом следующие аналитические показатели:
-- 1. день, в который арендовали больше всего фильмов (день в формате год-месяц-день)
-- 2. количество фильмов взятых в аренду в этот день
-- 3. день, в который продали фильмов на наименьшую сумму (день в формате год-месяц-день)
-- 4. сумму продажи в этот день




