--=============== МОДУЛЬ 3. ОСНОВЫ SQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выведите для каждого покупателя его адрес проживания, 
--город и страну проживания.
select 
cst.last_name ||' '|| cst.first_name "Фамилия и имя",
a.address "Адрес",
c.city "Город",
ctr.country "Страна"
from customer cst 
join address a on a.address_id = cst.address_id 
join city c on c.city_id = a.city_id
join country ctr on ctr.country_id = c.country_id  




--ЗАДАНИЕ №2
--С помощью SQL-запроса посчитайте для каждого магазина количество его покупателей.
select store_id "ID магазина", count(customer_id) "Количество покупателей"
from customer
group by store_id




--Доработайте запрос и выведите только те магазины, 
--у которых количество покупателей больше 300-от.
--Для решения используйте фильтрацию по сгруппированным строкам 
--с использованием функции агрегации.
select store_id "ID магазина", count(customer_id) as "Количество покупателей"
from customer
group by 1
having count(customer_id) > 300




-- Доработайте запрос, добавив в него информацию о городе магазина, 
--а также фамилию и имя продавца, который работает в этом магазине.
select 
	cst.store_id "ID магазина", 
	count(customer_id) as "Количество покупателей", 
	c.city "Город магазина",
	concat_ws(' ', st.last_name, st.first_name) 
from customer cst
join store s on s.store_id = cst.store_id 
join address a on a.address_id = s.address_id
join city c on c.city_id = a.city_id 
join staff st on st.staff_id = s.manager_staff_id 
group by 1,3,4
having count(customer_id) > 300




--ЗАДАНИЕ №3
--Выведите ТОП-5 покупателей, 
--которые взяли в аренду за всё время наибольшее количество фильмов
select 
concat_ws(' ', cst.last_name, cst.first_name) "Фамилия и имя покупателя",
count(p.customer_id) "Количество фильмов"
from customer cst 
join payment p on p.customer_id = cst.customer_id
group by 1
order by "Количество фильмов" desc
limit 5




--ЗАДАНИЕ №4
--Посчитайте для каждого покупателя 4 аналитических показателя:
--  1. количество фильмов, которые он взял в аренду
--  2. общую стоимость платежей за аренду всех фильмов (значение округлите до целого числа)
--  3. минимальное значение платежа за аренду фильма
--  4. максимальное значение платежа за аренду фильма
select 
concat_ws(' ', cst.last_name, cst.first_name) "Фамилия и имя покупателя",
count(p.customer_id) "Количество фильмов",
round(sum(p.amount)) "Общая стоимость платежей",
min(p.amount) "Минимальная стоимость платежа",
max(p.amount) "Максимальная стоимость платежа"
from customer cst 
join payment p on p.customer_id = cst.customer_id
group by 1
order by "Количество фильмов" desc
limit 5




--ЗАДАНИЕ №5
--Используя данные из таблицы городов составьте одним запросом всевозможные пары городов таким образом,
 --чтобы в результате не было пар с одинаковыми названиями городов. 
 --Для решения необходимо использовать декартово произведение.
select c1.city, c2.city 
from city c1,city c2
where c1.city != c2.city

--OR
select c1.city, c2.city 
from city c1
cross join city c2
where c1.city != c2.city




--ЗАДАНИЕ №6
--Используя данные из таблицы rental о дате выдачи фильма в аренду (поле rental_date)
--и дате возврата фильма (поле return_date), 
--вычислите для каждого покупателя среднее количество дней, за которые покупатель возвращает фильмы.
 select
	customer_id "ID окупателя",
	round(avg(date_part('day', (return_date - rental_date)))::numeric, 2) "Среднее количество на возврат"
from rental r
group by customer_id
order by customer_id 




--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Посчитайте для каждого фильма сколько раз его брали в аренду и значение общей стоимости аренды фильма за всё время.
select 
	f.title "Название",
	f.rating "Рейтинг",
	c."name" "Жанр",
	f.release_year "Год выпуска",
	l."name" "Язык",
	count(r.inventory_id) "Количество аренд",
	sum(p.amount) "Общая сумма аренды"
from film f
join film_category fc on fc.film_id = f.film_id
join category c on c.category_id = fc.category_id 
join "language" l on l.language_id = f.language_id 
join inventory i on i.film_id = f.film_id
join rental r on r.inventory_id = i.inventory_id 
join payment p on p.rental_id = r.rental_id 
group by 1,2,3,4,5
order by f.title 




--ЗАДАНИЕ №2
--Доработайте запрос из предыдущего задания и выведите с помощью запроса фильмы, которые ни разу не брали в аренду.
select 
	f.title "Название",
	f.rating "Рейтинг",
	c."name" "Жанр",
	f.release_year "Год выпуска",
	l."name" "Язык",
	count(r.inventory_id) "Количество аренд",
	case when sum(p.amount) is not null THEN sum(p.amount) 
	else 0 
	end "Общая сумма аренды"
from film f
left join film_category fc on fc.film_id = f.film_id
left join category c on c.category_id = fc.category_id 
left join "language" l on l.language_id = f.language_id 
left join inventory i on i.film_id = f.film_id
left join rental r on r.inventory_id = i.inventory_id 
left join payment p on p.rental_id = r.rental_id 
group by 1,2,3,4,5
having count(r.inventory_id) = 0
order by f.title 




--ЗАДАНИЕ №3
--Посчитайте количество продаж, выполненных каждым продавцом. Добавьте вычисляемую колонку "Премия".
--Если количество продаж превышает 7300, то значение в колонке будет "Да", иначе должно быть значение "Нет".
select 
	s.staff_id "ID отрудника",
	count(p.staff_id) "Количество продаж",
	case when (count(p.staff_id) > 7300) THEN 'Да'
		else 'Нет'
		end "Премия"
from staff s 
join payment p on p.staff_id = s.staff_id 
group by s.staff_id 






