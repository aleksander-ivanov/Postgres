--=============== ������ 5. ������ � POSTGRESQL =======================================
--= �������, ��� ���������� ���������� ������ ���������� � ������� ����� PUBLIC===========
SET search_path TO public;

--======== �������� ����� ==============

--������� �1
--C������� ������ � ������� payment. 
--������������ ��� ������� �� 1 �� N �� ���� �������.

select * from(
	select 
		payment_id,
		payment_date,
		row_number() over (order by payment_date)
	from payment) rn
where rn.row_number <= 10

--������� �2
--��������� ������� ������� �������� ������� � ���������� �������
--������� ��� ������� ����������,
--���������� �������� ������ ���� �� ���� �������.

select * from(
	select 
		payment_id,
		payment_date,
		customer_id ,
		row_number() over (partition by customer_id order by payment_date)
	from payment) rn
where rn.row_number <= 10

--������� �3
--��� ������� ������������ ���������� ����������� ������ ����� ���� ��� ��������,
--���������� �������� ������ ���� �� ���� �������.

select 
	customer_id ,
	payment_id,
	payment_date,
	amount,
	sum(amount) over (partition by customer_id order by payment_date) sum_amount
from payment

--������� �4
--��� ������� ���������� �������� ������ � ��� ��������� ������ ������.

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


--======== �������������� ����� ==============

--������� �1
--� ������� ������� ������� �������� ��� ������� ���������� ��������
--��������� ������� �� ���������� ������ �� ��������� �� ��������� 0.0
--� ����������� �� ���� �������

select 
	staff_id ,
	payment_id,
	payment_date,
	amount,
	lag(amount) over (partition by staff_id order by payment_date)
from payment

--������� �2
--� ������� ������� ������� �������� ��� ������� ���������� ����� ������ �� ���� 2007 ����
--� ����������� ������ �� ������� ���������� � �� ������ ���� ������� (���� ��� ����� �������)
--� ����������� �� ���� �������

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


--������� �3
--��� ������ ������ ���������� � �������� ����� SQL-�������� �����������, ������� �������� ��� �������:
-- 1. ����������, ������������ ���������� ���������� �������
-- 2. ����������, ������������ ������� �� ����� ������� �����
-- 3. ����������, ������� ��������� ��������� �����

		��� �� ������� (:
		��������� ���� ������ �� ������� � ������, ����� ������� ������� �� ��������.



