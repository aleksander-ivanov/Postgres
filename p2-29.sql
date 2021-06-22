������� ' ' �� " "

' ' - ������
" " - �������� �������� ���� ������ (�������� �������, �������)

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

����������������� �����

select l."name", select
from "language" l

���������� ������� ���������� SELECT

FROM
ON
JOIN
WHERE
GROUP BY
WITH CUBE ��� WITH ROLLUP
HAVING
SELECT <-- ��������� ������ (����������)
DISTINCT
ORDER BY

select tc.table_name, tc.constraint_name
from information_schema.table_constraints as tc
join information_schema.key_column_usage as kcu on kcu.table_name = tc.table_name
where tc.constraint_type = 'PRIMARY KEY'

select t.actor_id
from (select a.actor_id from actor as a) t

select 
from (��������������� ������)
join (��������������� ������)


��������_�����.��������_������� --from
��������_�������.��������_������� --select

������� ��������� �������, ��� �� ��������� ����������, � ��� ���.



1. �������� ��������: id ������, ��������, ��������, ��� ������ �� ������� ������.
������������ ���� ���, ����� ��� ��� ���������� �� ����� Film (FilmTitle ������ title � ��)
- ����������� ER - ���������, ����� ����� ���������� �������
- as - ��� ������� ��������� 

--
/* ��� ���� �������� */

https://www.sqlstyle.guide/ru/

select film_id, title, description, release_year
from film 

select film_id as Filmfilm_id, title as Filmtitle, description Filmdescription, 
	release_year Filmrelease_year
from film

select film_id as "Filmfilm_id", title as "Filmtitle", description "Filmdescription", 
	release_year "��� ������� ������"
from film

2. � ����� �� ������ ���� ��� ��������:
rental_duration - ����� ������� ������ � ����  
rental_rate - ��������� ������ ������ �� ���� ���������� �������. 
��� ������� ������ �� ������ ������� �������� ��������� ��� ������ � ����,
������� ������������ ������� ��������� cost_per_day
- ����������� ER - ���������, ����� ����� ���������� �������
- ��������� ������ � ���� - ��������� rental_rate � rental_duration
- as - ��� ������� ��������� 

select title, rental_rate/rental_duration cost_per_day
from film 

select title, pg_typeof(rental_duration), pg_typeof(rental_rate)
from film 

select title, pg_typeof(rental_rate/rental_duration)
from film 

2*
- �������������� ��������
- �������� round

select title, rental_rate / rental_duration cost_per_day, 
	rental_rate + rental_duration cost_per_day, 
	rental_rate - rental_duration cost_per_day, 
	rental_rate * rental_duration cost_per_day
from film 

select power(2, 3)

select title, round(rental_rate / rental_duration, 2)
from film 

- integer, numeric, float (double precision � real)

int2 = smallint 0-65535 -32000+32000
int = int4 = integer 0-4294836225 �� -2���� �� + 2����
int8 = bigint 0-18445618199572250625

numeric(10,2) 99999999,99 = decimal

float

select (2.49999 + 2.50001)

SELECT x,
  round(x::numeric) AS num_round,
  round(x::double precision) AS dbl_round
FROM generate_series(-3.5, 3.5, 1) as x;

select round(1/2)

3.1 ������������� ������ ������� �� �������� ��������� �� ���� ������ (�.2)
- ����������� order by (�� ��������� ��������� �� �����������)
- desc - ���������� �� ��������

select title, rental_rate/rental_duration cost_per_day
from film 
order by cost_per_day desc

select title, rental_rate/rental_duration cost_per_day
from film 
order by 2 --asc

select title, rental_rate/rental_duration cost_per_day
from film 
order by cost_per_day desc, title

3.1* ������������ ������� �������� �� ����������� ����� ������� (amount)
- ����������� ER - ���������, ����� ����� ���������� �������
- ����������� order by 
- asc - ���������� �� ����������� 

select payment_id, amount
from payment 
where amount > 0
order by amount

3.2 ������� ���-10 ����� ������� ������� �� ��������� �� ���� ������
- ����������� limit

select title, rental_rate/rental_duration cost_per_day
from film 
order by cost_per_day desc
limit 10

3.3 ������� ���-10 ����� ������� ������� �� ��������� ������ �� ����, ������� � 58-�� �������
- �������������� Limit � offset

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

3.3* ������� ���-15 ����� ������ ��������, ������� � ������� 14000
- �������������� Limit � Offset

select payment_id, amount
from payment 
where amount > 0
order by amount
offset 13999
limit 15
	
4. ������� ��� ���������� ���� ������� �������
- �������������� distinct

select distinct f.release_year
from film f

4* ������� ���������� ����� �����������
- ����������� ER - ���������, ����� ����� ���������� �������
- �������������� distinct

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

5.1. ������� ���� ������ �������, ������� ������� 'PG-13', � ����: "�������� - ��� �������"
- ����������� ER - ���������, ����� ����� ���������� �������
- "||" - �������� ������������, ������� �� concat
- where - ����������� ����������
- "=" - �������� ���������

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

5.2 ������� ���� ������ �������, ������� �������, ������������ �� 'PG'
- cast(�������� ������� as ���) - ��������������
- like - ����� �� �������
- ilike - ������������������� �����
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

5.2* �������� ���������� �� ����������� � ������ ���������� ���������'jam' (���������� �� �������� ���������), � ����: "��� �������" - ����� �������.
- "||" - �������� ������������
- where - ����������� ����������
- ilike - ������������������� �����
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

6. �������� id �����������, ������������ ������ � ���� � 27-05-2005 �� 28-05-2005 ������������
- ����������� ER - ���������, ����� ����� ���������� �������
- between - ������ ���������� (������ ... >= ... and ... <= ...)
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

���-�����-�����

6* ������� ������� ����������� ����� 30-04-2007
- ����������� ER - ���������, ����� ����� ���������� �������
- > - ������� ������ (< - ������� ������)

select payment_id, amount, payment_date
from payment 
where payment_date::date > '30-04-2007'

select payment_id, amount, payment_date
from payment 
where date(payment_date) > '30-04-2007'

7 �������� ���������� ���� � '30-04-2007' �� ����������� ����.
�������� ���������� ������� � '30-04-2007' �� ����������� ����.
�������� ���������� ��� � '30-04-2007' �� ����������� ����.

--���:
select date_part('day', now() - '30-04-2007')

select  now() - '30-04-2007'

select  age(now(), '30-04-2007')

--������:
select date_part('year', age(now(), '30-04-2007'))*12 + date_part('month', age(now(), '30-04-2007'))

--����:
select date_part('year', age(now(), '30-04-2007'))

�������������� ������� �������� ������:
������� 1. �������� ����� �������� ���������� � �������, � ������� ������� �R� � ��������� ������ ������� 
�� 0.00 �� 3.00 ������������, � ����� ������ c ��������� �PG-13� � ���������� ������ ������ ��� ������ 4.00.
��������� ��������� �������: https://ibb.co/Dk4PjJn

select title, rating, rental_rate
from film
where (rating = 'R' and rental_rate between 0. and 3.) or 
	(rating = 'PG-13' and rental_rate >= 4.)

������� 2. �������� ���������� � ��� ������� � ����� ������� ��������� ������.
��������� ��������� �������: https://ibb.co/pfMHBs0

select title, char_length(description)
from film 
order by 2 desc
limit 3

������� 3. �������� Email ������� ����������, �������� �������� Email �� 2 ��������� �������: 
� ������ ������� ������ ���� ��������, ��������� �� @, �� ������ ������� ������ ���� ��������, ��������� ����� @.
��������� ��������� �������: https://ibb.co/SJng6qd

select concat(last_name, ' ', first_name), split_part(email, '@', 1), split_part(email, '@', 2)
from customer 

������� 4. ����������� ������ �� ����������� �������, �������������� �������� � ����� ��������:
������ ����� ������ ���� ���������, ��������� ���������.
��������� ��������� �������: https://ibb.co/vv0k9b6

select concat(last_name, ' ', first_name), 
	concat(upper(left(split_part(email, '@', 1), 1)), substring(split_part(email, '@', 1), 2)),
	concat(upper(left(split_part(email, '@', 2), 1)), substring(split_part(email, '@', 2), 2))
from customer 

select trim('   Hello world   ')
