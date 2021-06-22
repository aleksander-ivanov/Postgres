Отличие ' ' от " "

' ' - строка
" " - название сущности базы данных (название таблицы, столбца)

select pg_typeof('100')

alter table a add column b int

select *
from a

delete from a

insert into a(b)
values (100.34)

insert into a(test)
values (100.34)

insert into a(b)
values ('100a')

Зарезервированные слова

select l."name", select
from "language" l

логический порядок инструкции SELECT

FROM
ON
JOIN
WHERE
GROUP BY
WITH CUBE или WITH ROLLUP
HAVING
SELECT <-- объявляем алиасы (псевдонимы)
DISTINCT
ORDER BY

select tc.table_name, tc.constraint_name
from information_schema.table_constraints as tc
join information_schema.key_column_usage as kcu on kcu.table_name = tc.table_name
where tc.constraint_type = 'PRIMARY KEY'

select t.actor_id
from (select a.actor_id from actor as a) t

select 
from (отфильтрованные данные)
join (отфильтрованные данные)


название_схемы.название_таблицы --from
название_таблицы.название_столбца --select

Область видимости алиасов, где их указывать необходимо, а где нет.



1. Получите атрибуты: id фильма, название, описание, год релиза из таблицы фильмы.
Переименуйте поля так, чтобы все они начинались со слова Film (FilmTitle вместо title и тп)
- используйте ER - диаграмму, чтобы найти подходящую таблицу
- as - для задания синонимов 

--
/* вот этот фрагмент */

https://www.sqlstyle.guide/ru/

select film_id, title, description, release_year
from film 

select film_id as Filmfilm_id, title as Filmtitle, description Filmdescription, 
	release_year Filmrelease_year
from film

select film_id as "Filmfilm_id", title as "Filmtitle", description "Filmdescription", 
	release_year "Год выпуска фильма"
from film

2. В одной из таблиц есть два атрибута:
rental_duration - длина периода аренды в днях  
rental_rate - стоимость аренды фильма на этот промежуток времени. 
Для каждого фильма из данной таблицы получите стоимость его аренды в день,
задайте вычисленному столбцу псевдоним cost_per_day
- используйте ER - диаграмму, чтобы найти подходящую таблицу
- стоимость аренды в день - отношение rental_rate к rental_duration
- as - для задания синонимов 

select title, rental_rate/rental_duration cost_per_day
from film 

select title, pg_typeof(rental_duration), pg_typeof(rental_rate)
from film 

select title, pg_typeof(rental_rate/rental_duration)
from film 

2*
- арифметические действия
- оператор round

select title, rental_rate / rental_duration cost_per_day, 
	rental_rate + rental_duration cost_per_day, 
	rental_rate - rental_duration cost_per_day, 
	rental_rate * rental_duration cost_per_day
from film 

select power(2, 3)

select title, round(rental_rate / rental_duration, 2)
from film 

- integer, numeric, float (double precision и real)

int2 = smallint 0-65535 -32000+32000
int = int4 = integer 0-4294836225 от -2млрд до + 2млрд
int8 = bigint 0-18445618199572250625

numeric(10,2) 99999999,99 = decimal

float

select (2.49999 + 2.50001)

SELECT x,
  round(x::numeric) AS num_round,
  round(x::double precision) AS dbl_round
FROM generate_series(-3.5, 3.5, 1) as x;

select round(1/2)

3.1 Отсортировать список фильмов по убыванию стоимости за день аренды (п.2)
- используйте order by (по умолчанию сортирует по возрастанию)
- desc - сортировка по убыванию

select title, rental_rate/rental_duration cost_per_day
from film 
order by cost_per_day desc

select title, rental_rate/rental_duration cost_per_day
from film 
order by 2 --asc

select title, rental_rate/rental_duration cost_per_day
from film 
order by cost_per_day desc, title

3.1* Отсортируйте таблицу платежей по возрастанию суммы платежа (amount)
- используйте ER - диаграмму, чтобы найти подходящую таблицу
- используйте order by 
- asc - сортировка по возрастанию 

select payment_id, amount
from payment 
where amount > 0
order by amount

3.2 Вывести топ-10 самых дорогих фильмов по стоимости за день аренды
- используйте limit

select title, rental_rate/rental_duration cost_per_day
from film 
order by cost_per_day desc
limit 10

3.3 Вывести топ-10 самых дорогих фильмов по стоимости аренды за день, начиная с 58-ой позиции
- воспользуйтесь Limit и offset

select title, rental_rate/rental_duration cost_per_day
from film 
order by cost_per_day desc
limit 10
offset 57

select title, rental_rate/rental_duration cost_per_day
from film 
order by cost_per_day desc
offset 57
limit 10

3.3* Вывести топ-15 самых низких платежей, начиная с позиции 14000
- воспользуйтесь Limit и Offset

select payment_id, amount
from payment 
where amount > 0
order by amount
offset 13999
limit 15
	
4. Вывести все уникальные годы выпуска фильмов
- воспользуйтесь distinct

select distinct f.release_year
from film f

4* Вывести уникальные имена покупателей
- используйте ER - диаграмму, чтобы найти подходящую таблицу
- воспользуйтесь distinct

select c.first_name
from customer c

select count(1)
from customer 

select distinct c.first_name
from customer c

select count(distinct first_name)
from customer 

select count(distinct customer_id)
from customer

5.1. Вывести весь список фильмов, имеющих рейтинг 'PG-13', в виде: "название - год выпуска"
- используйте ER - диаграмму, чтобы найти подходящую таблицу
- "||" - оператор конкатенации, отличие от concat
- where - конструкция фильтрации
- "=" - оператор сравнения

select title, release_year, rating
from film 
where rating = 'PG-13'

select title || ' ' || release_year, rating
from film 
where rating = 'PG-13'

select concat(title, ' ', release_year), rating
from film 
where rating = 'PG-13'

select concat_ws(' ', title, release_year, description, rental_duration), rating
from film 
where rating = 'PG-13'

select 'Hello' || 'world!' || null

select concat('Hello', 'world!', null)

select null = null

5.2 Вывести весь список фильмов, имеющих рейтинг, начинающийся на 'PG'
- cast(название столбца as тип) - преобразование
- like - поиск по шаблону
- ilike - регистронезависимый поиск
- lower
- upper
- length

select title, release_year, rating
from film 
where rating::text like 'PG%'

select title, release_year, rating
from film 
where cast(rating as text) like 'PG%'

select title, release_year, rating
from film 
where cast(rating as text) like '%-%'

select title, release_year, rating
from film 
where cast(rating as text) like '%17'

select title, release_year, rating
from film 
where cast(rating as text) like 'PG___'

select E'\''

select title, release_year, rating
from film 
where cast(rating as text) ilike 'pg%'

select title, release_year, rating
from film 
where upper(rating::text) like 'PG%'

select title, release_year, rating
from film 
where lower(rating::text) like 'pg%'

select title, release_year, rating
from film 
where rating::text ilike 'pg%' and char_length(rating::text) = 5

-- regexp_match()

5.2* Получить информацию по покупателям с именем содержашим подстроку'jam' (независимо от регистра написания), в виде: "имя фамилия" - одной строкой.
- "||" - оператор конкатенации
- where - конструкция фильтрации
- ilike - регистронезависимый поиск
- strpos
- character_length
- overlay
- substring
- split_part

select first_name
from customer 
where first_name ilike '%jam%'

select strpos('Hello world!', 'world')

select char_length('Hello world!')

select length('Hello world!')

select overlay('Hello world!' placing 'Max' from 7 for 5)

select substring('Hello world!' from 7 for 5)

select overlay('Hello world!' placing 'Max' from 
	(select strpos('Hello world!', 'world')) for (select char_length('world')))
	
select split_part('Hello world!', ' ', 1)	

select split_part('Hello world!', ' ', 2)	

6. Получить id покупателей, арендовавших фильмы в срок с 27-05-2005 по 28-05-2005 включительно
- используйте ER - диаграмму, чтобы найти подходящую таблицу
- between - задает промежуток (аналог ... >= ... and ... <= ...)
- date_part()
- date_trunc()
- interval
- extract

date 
timestamp 
timestamptz 

select customer_id, rental_date
from rental 
where rental_date >= '27/05/2005' and rental_date <= '28-05-2005'
order by rental_date desc

select customer_id, rental_date
from rental 
where rental_date between '2005-05-27 00:00:00' and '28-05-2005 00:00:00'
order by rental_date desc

select customer_id, rental_date
from rental 
where rental_date::date between '2005-05-27' and '28-05-2005'
order by rental_date desc

select customer_id, rental_date
from rental 
where rental_date between '2005-05-27' and '28-05-2005'::date + interval '1 day'
order by rental_date desc

select customer_id, pg_typeof(rental_date)
from rental 

select '2005-05-27'::date + interval '3 weeks'

select '2005-05-27'::date + interval '100 days'

select extract(year from '2005-05-27'::date)

select extract(month from '2005-05-27'::date)

select extract(day from '2005-05-27'::date)

select date_part('year', '2005-05-27'::date)

select date_part('month', '2005-05-27'::date)

select date_part('day', '2005-05-27'::date)

select date_part('hour', '2005-05-27 04:34:23'::timestamp)

select date_trunc('year', '2005-05-27'::date)

select date_trunc('month', '2005-05-27'::date)

select date_trunc('day', '2005-05-27'::date)

select date_trunc('year', '2005-05-27'::date) - interval '1 year'

select now()

год-месяц-число

6* Вывести платежи поступившие после 30-04-2007
- используйте ER - диаграмму, чтобы найти подходящую таблицу
- > - строгое больше (< - строгое меньше)

select payment_id, amount, payment_date
from payment 
where payment_date::date > '30-04-2007'

select payment_id, amount, payment_date
from payment 
where date(payment_date) > '30-04-2007'

7 Получить количество дней с '30-04-2007' по сегодняшний день.
Получить количество месяцев с '30-04-2007' по сегодняшний день.
Получить количество лет с '30-04-2007' по сегодняшний день.

--дни:
select date_part('day', now() - '30-04-2007')

select  now() - '30-04-2007'

select  age(now(), '30-04-2007')

--Месяцы:
select date_part('year', age(now(), '30-04-2007'))*12 + date_part('month', age(now(), '30-04-2007'))

--Года:
select date_part('year', age(now(), '30-04-2007'))

Дополнительные задания домашней работы:
Задание 1. Выведите одним запросом информацию о фильмах, у которых рейтинг “R” и стоимость аренды указана 
от 0.00 до 3.00 включительно, а также фильмы c рейтингом “PG-13” и стоимостью аренды больше или равной 4.00.
Ожидаемый результат запроса: https://ibb.co/Dk4PjJn

select title, rating, rental_rate
from film
where (rating = 'R' and rental_rate between 0. and 3.) or 
	(rating = 'PG-13' and rental_rate >= 4.)

Задание 2. Получите информацию о трёх фильмах с самым длинным описанием фильма.
Ожидаемый результат запроса: https://ibb.co/pfMHBs0

select title, char_length(description)
from film 
order by 2 desc
limit 3

Задание 3. Выведите Email каждого покупателя, разделив значение Email на 2 отдельных колонки: 
в первой колонке должно быть значение, указанное до @, во второй колонке должно быть значение, указанное после @.
Ожидаемый результат запроса: https://ibb.co/SJng6qd

select concat(last_name, ' ', first_name), split_part(email, '@', 1), split_part(email, '@', 2)
from customer 

Задание 4. Доработайте запрос из предыдущего задания, скорректируйте значения в новых колонках:
первая буква должна быть заглавной, остальные строчными.
Ожидаемый результат запроса: https://ibb.co/vv0k9b6

select concat(last_name, ' ', first_name), 
	concat(upper(left(split_part(email, '@', 1), 1)), substring(split_part(email, '@', 1), 2)),
	concat(upper(left(split_part(email, '@', 2), 1)), substring(split_part(email, '@', 2), 2))
from customer 

select trim('   Hello world   ')
