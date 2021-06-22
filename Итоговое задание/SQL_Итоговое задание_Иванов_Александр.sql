--Итоговая работа Иванов А.А.
-- Используется локальная установка из бекапа

--1 В каких городах больше одного аэропорта?
select
	city,
	count(city)
from
	airports a
group by
	city
having
	count(city) > 1;

--2 В каких аэропортах есть рейсы, выполняемые самолетом с максимальной дальностью перелета? 
--Подзапрос
select distinct departure_airport 
from flights f where aircraft_code = (
	select aircraft_code from aircrafts a order by "range" desc limit 1)

--3 Вывести 10 рейсов с максимальным временем задержки вылета 
--Оператор LIMIT
select *, actual_departure - scheduled_departure delay_time 
from flights
where actual_departure is not null 
	and actual_departure != scheduled_departure
order by delay_time desc
limit 10

--либо так без создания колонки delay_time:
select *
from flights
where actual_departure is not null 
	and actual_departure != scheduled_departure
order by actual_departure - scheduled_departure desc
limit 10

--4 Были ли брони, по которым не были получены посадочные талоны?
-- Верный тип JOIN
select case 
         when exists (
         	select t.book_ref, bp.ticket_no from tickets t 
			left join boarding_passes bp on bp.ticket_no = t.ticket_no 
			where bp.ticket_no is null) then 'были брони, по которым не были получены посадочные талоны'
         else 'брони, по которым не были получены посадочные талоны не найдены'
       end


--5 Найдите свободные места для каждого рейса, их % отношение к общему количеству мест в самолете.
--Добавьте столбец с накопительным итогом - суммарное накопление количества вывезенных пассажиров из каждого аэропорта на каждый день. 
--Т.е. в этом столбце должна отражаться накопительная сумма - сколько человек уже вылетело из данного аэропорта на этом или более ранних рейсах за день.
-- Оконная функция
-- Подзапросы или CTE

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
	a.count "Всего мест",  
	b.count "Забронировано",
	(a.count - b.count) "кол-во свободных мест",
	round(((a.count - b.count) * 100. / a.count), 2) || '%'  "% к общему количеству мест",
	sum(b.count) over (partition by departure_airport, date_trunc('day', a.actual_departure) order by a.actual_departure) "Количества вывезенных пассажиров"
from all_seats_count_per_flight a
join booked_seats_count b on b.flight_id = a.flight_id
			
--6 Найдите процентное соотношение перелетов по типам самолетов от общего количества.
-- Подзапрос
-- Оператор ROUND

select 
	aircraft_code "тип самолета", 
	round(count * 100. / (select count(f.flight_id) from flights f limit 1), 2) || '%' "процентное соотношение перелетов"
from (
	select 
		f.flight_id,
		f.aircraft_code,
		count(f.flight_id) over (partition by f.aircraft_code)
	from flights f
) f
group by aircraft_code, count

--7 Были ли города, в которые можно добраться бизнес - классом дешевле, чем эконом-классом в рамках перелета?
-- CTE одно или несколько

with flight_amount_by_fare_conditions as (
	select flight_id, fare_conditions, min(amount) amount -- цена билета может варьироваться в рамках перелёта, возмём минимальную
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
	
--8 Между какими городами нет прямых рейсов?
-- Декартово произведение в предложении FROM
-- Самостоятельно созданные представления
-- Оператор EXCEPT

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
   
   
--9 Вычислите расстояние между аэропортами, связанными прямыми рейсами, сравните с допустимой максимальной дальностью перелетов  в самолетах, обслуживающих эти рейсы *
-- Оператор RADIANS или использование sind/cosd
--* - В облачной базе координаты находятся в столбце airports_data.coordinates - работаете, как с массивом. В локальной базе координаты находятся в столбцах airports.longitude и airports.latitude.
-- - Кратчайшее расстояние между двумя точками A и B на земной поверхности (если принять ее за сферу) определяется зависимостью:
--d = arccos {sin(latitude_a)·sin(latitude_b) + cos(latitude_a)·cos(latitude_b)·cos(longitude_a - longitude_b)}, где latitude_a и latitude_b — широты, longitude_a, longitude_b — долготы данных пунктов, d — расстояние между пунктами измеряется в радианах длиной дуги большого круга земного шара.
--Расстояние между пунктами, измеряемое в километрах, определяется по формуле:
--L = d·R, где R = 6371 км — средний радиус земного шара.
-- Результат через оператор CASE и вывести 'больше' или 'меньше'


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












