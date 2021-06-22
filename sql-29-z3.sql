Задание 1. Создайте новую таблицу film_new со следующими полями:
· film_name — название фильма — тип данных varchar(255) и ограничение not null;
· film_year — год выпуска фильма — тип данных integer, условие, что значение должно быть больше 0;
· film_rental_rate — стоимость аренды фильма — тип данных numeric(4,2), значение по умолчанию 0.99;
· film_duration — длительность фильма в минутах — тип данных integer, ограничение not null и условие, что значение должно быть больше 0.

create table film_new (
	film_id serial primary key,
	film_name varchar(255) not null,
	film_year integer not null check (film_year > 0),
	film_rental_rate numeric(4,2) default 0.99,
	film_duration integer not null check (film_duration > 0)
)

Если работаете в облачной базе, то перед названием таблицы задайте наименование вашей схемы.

2.5 + 2.5 = 2.49999 + 2.50001

xx.xx

Задание 2. Заполните таблицу film_new данными с помощью SQL-запроса, где колонкам соответствуют массивы данных:
· film_name — array[The Shawshank Redemption, The Green Mile, Back to the Future, Forrest Gump, Schindler’s List];
· film_year — array[1994, 1999, 1985, 1994, 1993];
· film_rental_rate — array[2.99, 0.99, 1.99, 2.99, 3.99];
· film_duration — array[142, 189, 116, 142, 195].

insert into film_new (film_name, film_year, film_rental_rate, film_duration)
select unnest(array['The Shawshank Redemption', 'The Green Mile', 'Back to the Future', 'Forrest Gump', 'Schindler’s List']),
	unnest(array[1994, 1999, 1985, 1994, 1993]),
	unnest(array[2.99, 0.99, 1.99, 2.99, 3.99]),
	unnest(array[142, 189, 116, 142, 195])
	
select * from film_new

Задание 3. Обновите стоимость аренды фильмов в таблице film_new с учётом информации, что стоимость аренды всех фильмов поднялась на 1.41.

update film_new
set film_rental_rate = film_rental_rate + 1.41

Задание 4. Фильм с названием Back to the Future был снят с аренды, удалите строку с этим фильмом из таблицы film_new.

delete from film_new
where film_name = 'Back to the Future'

Задание 5. Добавьте в таблицу film_new запись о любом другом новом фильме.

Задание 6. Напишите SQL-запрос, который выведет все колонки из таблицы film_new, а также новую вычисляемую колонку «длительность фильма в часах», округлённую до десятых.

select *, round(film_duration / 60., 1)
from film_new

Задание 7. Удалите таблицу film_new.

drop table film_new

explain analyze
select *
from actor a
full join film_actor fa on fa.actor_id = a.actor_id
where fa.film_id < 100

select sum(distinct amount ) / 20
from payment p

select distinct amount
from payment p

create table payment_new (like payment including defaults) partition by range (amount)

create table payment_low partition of payment_new for values from (minvalue) to (9)

create table payment_high partition of payment_new for values from (9) to (maxvalue)

insert into payment_new
select * from "dvd-rental".payment

explain analyze
select * from payment_new

select * from payment_low

explain analyze
select * from payment_high

drop table payment

alter table payment_new rename to payment


create table payment_low like payment 

alter table payment_low inherits payment

create table payment_high like payment 

alter table payment_high inherits payment

create rule payment_new on insert 


Задание 1. С помощью оконной функции выведите для каждого сотрудника магазина стоимость продажи из предыдущей строки со значением по умолчанию 0.0 
с сортировкой по дате.
Ожидаемый результат запроса:https://postimg.cc/s1MY5m2c

select p.staff_id, p.payment_id, p.payment_date, p.amount,
	lag(p.amount, 1, 0.) over (partition by staff_id order by payment_date)
from payment p

with c as (
	select p.staff_id, p.payment_id, row_number () over (partition by p.staff_id order by p.payment_date)
	from payment p
)
select *
from c 
where row_number = 10

Задание 2. С помощью оконной функции выведите для каждого сотрудника сумму продаж за март 2007 года с нарастающим итогом по каждому сотруднику 
и по каждой дате продажи (без учёта времени) с сортировкой по дате.
Ожидаемый результат запроса: https://postimg.cc/hz5VHz2T

select p.staff_id, date(p.payment_date), sum(p.amount),
	sum(sum(p.amount)) over (partition by p.staff_id order by date(p.payment_date))
from payment p
where extract(year from p.payment_date) = 2007 and extract(month from p.payment_date) = 3
group by p.staff_id, date(p.payment_date)

Задание 3. Для каждой страны определите и выведите одним SQL-запросом покупателей, которые попадают под условия:
· покупатель, арендовавший наибольшее количество фильмов;
· покупатель, арендовавший фильмов на самую большую сумму;
· покупатель, который последним арендовал фильм.
Ожидаемый результат запроса: https://prnt.sc/13q0be2*/

explain analyze
with c1 as (
	select c.customer_id, c3.country_id, count(i.film_id), sum(p.amount), max(r.rental_date)
	from customer c
	join rental r on r.customer_id = c.customer_id
	join inventory i on i.inventory_id = r.inventory_id
	join payment p on p.rental_id = r.rental_id
	join address a on a.address_id = c.address_id
	join city c2 on c2.city_id = a.city_id
	join country c3 on c3.country_id = c2.country_id
	group by c.customer_id, c3.country_id),
c2 as (
	select customer_id, country_id,
		row_number () over (partition by country_id order by count desc) cf,
		row_number () over (partition by country_id order by sum desc) sa,
		row_number () over (partition by country_id order by max desc) md
	from c1
)
select c.country, c_1.customer_id, c_2.customer_id, c_3.customer_id
from country c
left join c2 c_1 on c_1.country_id = c.country_id and c_1.cf = 1
left join c2 c_2 on c_2.country_id = c.country_id and c_2.sa = 1
left join c2 c_3 on c_3.country_id = c.country_id and c_3.md = 1
order by 1

explain analyze
with c as (
	with c1 as (
		select c.customer_id, c3.country_id, count(i.film_id), sum(p.amount), max(r.rental_date),
		max(count(i.film_id)) over (partition by c3.country_id) mc, 
		max(sum(p.amount)) over (partition by c3.country_id) ma, 
		max(max(r.rental_date)) over (partition by c3.country_id) md,
		c3.country
		from customer c
		join rental r on r.customer_id = c.customer_id
		join inventory i on i.inventory_id = r.inventory_id
		join payment p on p.rental_id = r.rental_id
		join address a on a.address_id = c.address_id
		join city c2 on c2.city_id = a.city_id
		join country c3 on c3.country_id = c2.country_id
		group by c.customer_id, c3.country_id)
	select country_id, country,
		case 
			when count = mc then customer_id
		end a,
		case 
			when sum = ma then customer_id
		end b,
		case 
			when max = md then customer_id
		end c
	from c1)
select country.country, string_agg(a::text, ', '), string_agg(b::text, ', '), string_agg(c::text, ', ')
from country 
left join c on c.country_id = country.country_id
group by country.country


select p.customer_id, string_agg(payment_id::text, ', ')
from payment p
where p.customer_id < 5
group by p.customer_id

select customer_id, payment_id
from payment p
where p.customer_id < 5

with recursive r as (
	select 65 as i, chr(65)
	union
	select i + 1 as i, chr(i + 1)
	from r
	where i < 75
)
select *
from r