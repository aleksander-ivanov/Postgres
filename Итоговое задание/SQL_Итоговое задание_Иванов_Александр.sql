--�������� ������ ������ �.�.
-- ������������ ��������� ��������� �� ������

--1 � ����� ������� ������ ������ ���������?
select
	city,
	count(city)
from
	airports a
group by
	city
having
	count(city) > 1;

--2 � ����� ���������� ���� �����, ����������� ��������� � ������������ ���������� ��������? 
--���������
select distinct departure_airport 
from flights f where aircraft_code = (
	select aircraft_code from aircrafts a order by "range" desc limit 1)

--3 ������� 10 ������ � ������������ �������� �������� ������ 
--�������� LIMIT
select *, actual_departure - scheduled_departure delay_time 
from flights
where actual_departure is not null 
	and actual_departure != scheduled_departure
order by delay_time desc
limit 10

--���� ��� ��� �������� ������� delay_time:
select *
from flights
where actual_departure is not null 
	and actual_departure != scheduled_departure
order by actual_departure - scheduled_departure desc
limit 10

--4 ���� �� �����, �� ������� �� ���� �������� ���������� ������?
-- ������ ��� JOIN
select case 
         when exists (
         	select t.book_ref, bp.ticket_no from tickets t 
			left join boarding_passes bp on bp.ticket_no = t.ticket_no 
			where bp.ticket_no is null) then '���� �����, �� ������� �� ���� �������� ���������� ������'
         else '�����, �� ������� �� ���� �������� ���������� ������ �� �������'
       end


--5 ������� ��������� ����� ��� ������� �����, �� % ��������� � ������ ���������� ���� � ��������.
--�������� ������� � ������������� ������ - ��������� ���������� ���������� ���������� ���������� �� ������� ��������� �� ������ ����. 
--�.�. � ���� ������� ������ ���������� ������������� ����� - ������� ������� ��� �������� �� ������� ��������� �� ���� ��� ����� ������ ������ �� ����.
-- ������� �������
-- ���������� ��� CTE

with all_seats_count_per_flight as (
		select f.flight_id, count(s.seat_no), f.departure_airport, f.actual_departure 
		from flights f
		join aircrafts a on a.aircraft_code = f.aircraft_code
		join seats s on s.aircraft_code = a.aircraft_code
		group by f.flight_id
	),	
	booked_seats_count as (
	    select 
	    	f.flight_id, 
	    	count(bp.seat_no)
		from flights f
		join boarding_passes bp on bp.flight_id = f.flight_id
		where f.actual_departure is not null
		group by f.flight_id
	)
select 
	a.flight_id,
	a.count "����� ����",  
	b.count "�������������",
	(a.count - b.count) "���-�� ��������� ����",
	round(((a.count - b.count) * 100. / a.count), 2) || '%'  "% � ������ ���������� ����",
	sum(b.count) over (partition by departure_airport, date_trunc('day', a.actual_departure) order by a.actual_departure) "���������� ���������� ����������"
from all_seats_count_per_flight a
join booked_seats_count b on b.flight_id = a.flight_id
			
--6 ������� ���������� ����������� ��������� �� ����� ��������� �� ������ ����������.
-- ���������
-- �������� ROUND

select 
	aircraft_code "��� ��������", 
	round(count * 100. / (select count(f.flight_id) from flights f limit 1), 2) || '%' "���������� ����������� ���������"
from (
	select 
		f.flight_id,
		f.aircraft_code,
		count(f.flight_id) over (partition by f.aircraft_code)
	from flights f
) f
group by aircraft_code, count

--7 ���� �� ������, � ������� ����� ��������� ������ - ������� �������, ��� ������-������� � ������ ��������?
-- CTE ���� ��� ���������

with flight_amount_by_fare_conditions as (
	select flight_id, fare_conditions, min(amount) amount -- ���� ������ ����� ������������� � ������ �������, ����� �����������
	from ticket_flights tf2
	group by flight_id, fare_conditions
),
amount_by_city as (
select distinct a.city, fa.fare_conditions, fa.amount 
from airports a
join flights f on f.arrival_airport = a.airport_code
join flight_amount_by_fare_conditions fa on f.flight_id = fa.flight_id
)
select c1.city, c1.amount business_amount, c2.amount economy_amount 
from amount_by_city c1
inner join amount_by_city c2 on c2.city = c1.city
where c1.amount < c2.amount and c1.fare_conditions = 'Business' and c2.fare_conditions = 'Economy'
	
--8 ����� ������ �������� ��� ������ ������?
-- ��������� ������������ � ����������� FROM
-- �������������� ��������� �������������
-- �������� EXCEPT

create or replace view exist_city_pairs as 
(
   select distinct a1.city city1, a2.city city2 from flights f 
   join airports a1 on a1.airport_code = f.departure_airport
   join airports a2 on a2.airport_code = f.arrival_airport
);
create or replace view all_city_pairs as 
(
  with cities as (
   		select city from airports a 
   )
   	select c1.city city1, c2.city city2 
   	from cities c1 
   	cross join cities c2
   	where c1.city != c2.city
 );
select * from all_city_pairs except select * from exist_city_pairs    
   
   
--9 ��������� ���������� ����� �����������, ���������� ������� �������, �������� � ���������� ������������ ���������� ���������  � ���������, ������������� ��� ����� *
-- �������� RADIANS ��� ������������� sind/cosd
--* - � �������� ���� ���������� ��������� � ������� airports_data.coordinates - ���������, ��� � ��������. � ��������� ���� ���������� ��������� � �������� airports.longitude � airports.latitude.
-- - ���������� ���������� ����� ����� ������� A � B �� ������ ����������� (���� ������� �� �� �����) ������������ ������������:
--d = arccos {sin(latitude_a)�sin(latitude_b) + cos(latitude_a)�cos(latitude_b)�cos(longitude_a - longitude_b)}, ��� latitude_a � latitude_b � ������, longitude_a, longitude_b � ������� ������ �������, d � ���������� ����� �������� ���������� � �������� ������ ���� �������� ����� ������� ����.
--���������� ����� ��������, ���������� � ����������, ������������ �� �������:
--L = d�R, ��� R = 6371 �� � ������� ������ ������� ����.
-- ��������� ����� �������� CASE � ������� '������' ��� '������'


select 
	departure_airport,
	arrival_airport,
	round(acos(sin(radians(a1.latitude)) * sin(radians(a2.latitude)) + cos(radians(a1.latitude)) * cos(radians(a2.latitude)) * cos(radians(a1.longitude) - radians(a2.longitude)))::numeric * 6371, 2) distance,
	ac."range" aircraft_max_range
from flights f
join airports a1 on a1.airport_code = f.departure_airport 
join airports a2 on a2.airport_code = f.arrival_airport
join aircrafts ac on ac.aircraft_code = f.aircraft_code
group by departure_airport, arrival_airport, distance, aircraft_max_range












