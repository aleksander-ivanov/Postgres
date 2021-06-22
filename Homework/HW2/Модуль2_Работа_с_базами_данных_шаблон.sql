--=============== ������ 2. ������ � ������ ������ =======================================
--= �������, ��� ���������� ���������� ������ ���������� � ������� ����� PUBLIC===========
SET search_path TO public;

--======== �������� ����� ==============

--������� �1
--�������� ���������� �������� �������� �� ������� �������
select distinct district from address




--������� �2
--����������� ������ �� ����������� �������, ����� ������ ������� ������ �� �������, 
--�������� ������� ���������� �� "K" � ������������� �� "a", � �������� �� �������� ��������
select distinct district from address where district like 'K%' and district like '%a' and district not like '% %'




--������� �3
--�������� �� ������� �������� �� ������ ������� ���������� �� ��������, ������� ����������� 
--� ���������� � 17 ����� 2007 ���� �� 19 ����� 2007 ���� ������������, 
--� ��������� ������� ��������� 1.00.
--������� ����� ������������� �� ���� �������.
select payment_id, payment_date, amount from payment p 
where payment_date::date between '2007-03-17' AND '2007-03-19' and amount > 1.00
order by payment_date




--������� �4
-- �������� ���������� � 10-�� ��������� �������� �� ������ �������.
select payment_id, payment_date, amount from payment p
order by payment_date desc
limit 10




--������� �5
--�������� ��������� ���������� �� �����������:
--  1. ������� � ��� (� ����� ������� ����� ������)
--  2. ����������� �����
--  3. ����� �������� ���� email
--  4. ���� ���������� ���������� ������ � ���������� (��� �������)
--������ ������� ������� ������������ �� ������� �����.
select 
	first_name||' '||last_name as "������� � ���", 
	email as "����������� �����", 
	length(email) as "����� Email", 
	date(last_update) as "����"
from customer




--������� �6
--�������� ����� �������� �������� �����������, ����� ������� Kelly ��� Willie.
--��� ����� � ������� � ����� �� ������� �������� ������ ���� ���������� � ������� �������.
select upper(last_name), upper(first_name) 
from customer
where first_name = 'Kelly' or first_name = 'Willie' and active = 1




--======== �������������� ����� ==============

--������� �1
--�������� ����� �������� ���������� � �������, � ������� ������� "R" 
--� ��������� ������ ������� �� 0.00 �� 3.00 ������������, 
--� ����� ������ c ��������� "PG-13" � ���������� ������ ������ ��� ������ 4.00.
select film_id, title, description, rating, rental_rate 
from film
where 
(rating = 'R' and rental_rate between 0.00 and 3.00) 
or 
(rating = 'PG-13' and rental_rate >= 4.00)




--������� �2
--�������� ���������� � ��� ������� � ����� ������� ��������� ������.
select film_id, title, description 
from film
order by length(description) desc
limit 3




--������� �3
-- �������� Email ������� ����������, �������� �������� Email �� 2 ��������� �������:
--� ������ ������� ������ ���� ��������, ��������� �� @, 
--�� ������ ������� ������ ���� ��������, ��������� ����� @.
select 
	customer_id, 
	email as "Email", 
	substring(email,0,position('@' in email)) as "Email before @", 
	substring(email,position('@' in email)+1) as "Email after @"
from customer c 
order by customer_id 




--������� �4
--����������� ������ �� ����������� �������, �������������� �������� � ����� ��������: 
--������ ����� ������ ���� ���������, ��������� ���������.
select 
	customer_id, 
	email as "Email",	
	upper(left(left(email,position('@' in email)-1),1)) 
	|| substring(email,2, position('@' in email)-2) as "Email before @",	
	upper(left(right(email,length(email) - position('@' in email)),1)) 
	|| right(email,length(email) - position('@' in email)-1) as "Email after @"	
from customer c 
order by customer_id 



