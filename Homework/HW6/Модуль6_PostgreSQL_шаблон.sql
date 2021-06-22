--=============== ������ 6. POSTGRESQL =======================================
--= �������, ��� ���������� ���������� ������ ���������� � ������� ����� PUBLIC===========
SET search_path TO public;

--======== �������� ����� ==============

--������� �1
--�������� SQL-������, ������� ������� ��� ���������� � ������� 
--�� ����������� ��������� "Behind the Scenes".
--explain analyze
select film_id, title, special_features from film
where special_features @> '{"Behind the Scenes"}'
order by film_id 

--������� �2
--�������� ��� 2 �������� ������ ������� � ��������� "Behind the Scenes",
--��������� ������ ������� ��� ��������� ����� SQL ��� ������ �������� � �������.
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

--������� �3
--��� ������� ���������� ���������� ������� �� ���� � ������ ������� 
--�� ����������� ��������� "Behind the Scenes.

--������������ ������� ��� ���������� �������: ����������� ������ �� ������� 1, 
--���������� � CTE. CTE ���������� ������������ ��� ������� �������.
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


--������� �4
--��� ������� ���������� ���������� ������� �� ���� � ������ �������
-- �� ����������� ��������� "Behind the Scenes".

--������������ ������� ��� ���������� �������: ����������� ������ �� ������� 1,
--���������� � ���������, ������� ���������� ������������ ��� ������� �������.
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



--������� �5
--�������� ����������������� ������������� � �������� �� ����������� �������
--� �������� ������ ��� ���������� ������������������ �������������

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


--������� �6
--� ������� explain analyze ��������� ������ �������� ���������� ��������
-- �� ���������� ������� � �������� �� �������:

--1. ����� ���������� ��� �������� ����� SQL, ������������ ��� ���������� ��������� �������, 
--   ����� �������� � ������� ���������� �������
--2. ����� ������� ���������� �������� �������: 
--   � �������������� CTE ��� � �������������� ����������

1. ��������� ������ �������� � �������:
	 - where special_features @> '{"Behind the Scenes"}' - 92.25
	 - where 'Behind the Scenes' = any(special_features) - 102.25
	 - where array_to_string(special_features, ',') like '%Behind the Scenes%' - 69.02
	 - where special_features[2] like '%Behind the Scenes%' - 66.52
	 �����: ���������� �� ������� �������� ���������� ������� �����, ����� ��������� �������� - any()
 2. ����� ������� ���������� �������� �������: 
 	- � �������������� CTE - 1621.87
 	- � �������������� ���������� - 300.53
 	�����: ������ �������� ������� � �����������


--======== �������������� ����� ==============

--������� �1
--���������� ��� ������� � ����� ������ �� ����� ���������
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

-- ��������:
--����� ���������� ������� Execution Time: 63.300 ms. 
������ ������������, �� �������� ��� full outer join ������� ���������� ������ ������ ������ ��� ����������� ���� ���������� ��� ��� � ����������� ��������. ���� ������ ������������ �������, �� ������ ��������������� ���������� ������.
� ���������� ������� �-��� count ���������� ����� ��������.
����� ���������� ����� �������� ������� (4� �������) - Execution Time: 13.768 ms, ��������� �� �������� 1621.87
��� ��������:
1. ������� ����������� ������� film (Seq Scan) � ����� ����������� (Filter: (special_features @> '{"Behind the Scenes"}'::text[])). cost=0.00..66.50, actual time=0.013..0.476
2. ����� ���������� �� film_id, �������: cost=90.90..92.25, actual time=0.501..0.516
3. ����� ������������ ���������� cost=90.90..97.63, actual time=0.501..0.546
4. ������������ ������� inventory � � ���������� �� ������� i.film_id = f1.film_id. ���������: cost=97.63..97.63, actual time=0.616..0.617
5. ������������ ������� rental � ���������� Hash Cond: (r.inventory_id = i.inventory_id) cost=0.00..310.44, actual time=0.011..1.044
6. ���������� ������� rental Key: r.customer_id, r.rental_date desc. ���������: cost=1300.53..1323.05, actual time=9.315..9.853
7. ���������� ������� �-��� row_number(). ���������: cost=1300.53..1480.73, actual time=9.321..13.308
8. ����������� ����������. ���������: cost=1300.53..1621.87, actual time=9.333..14.256


--������� �2
--��������� ������� ������� �������� ��� ������� ����������
--�������� � ����� ������ ������� ����� ����������.

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


--������� �3
--��� ������� �������� ���������� � �������� ����� SQL-�������� ��������� ������������� ����������:
-- 1. ����, � ������� ���������� ������ ����� ������� (���� � ������� ���-�����-����)
-- 2. ���������� ������� ������ � ������ � ���� ����
-- 3. ����, � ������� ������� ������� �� ���������� ����� (���� � ������� ���-�����-����)
-- 4. ����� ������� � ���� ����




