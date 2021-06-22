--=============== МОДУЛЬ 4. УГЛУБЛЕНИЕ В SQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--База данных: если подключение к облачной базе, то создаете новые таблицы в формате:
--таблица_фамилия, 
--если подключение к контейнеру или локальному серверу, то создаете новую схему и в ней создаете таблицы.


-- Спроектируйте базу данных для следующих сущностей:
-- 1. язык (в смысле английский, французский и тп)
-- 2. народность (в смысле славяне, англосаксы и тп)
-- 3. страны (в смысле Россия, Германия и тп)


--Правила следующие:
-- на одном языке может говорить несколько народностей
-- одна народность может входить в несколько стран
-- каждая страна может состоять из нескольких народностей

 
--Требования к таблицам-справочникам:
-- идентификатор сущности должен присваиваться автоинкрементом
-- наименования сущностей не должны содержать null значения и не должны допускаться дубликаты в названиях сущностей
 
 create schema homework4
 
--СОЗДАНИЕ ТАБЛИЦЫ ЯЗЫКИ
create table language (
		language_id serial primary key,
		name varchar (100) unique not null
		)


--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ ЯЗЫКИ
INSERT INTO homework4."language" ("name")
VALUES ('русский'), ('английский'), ('французский'),('испанский'),('итальянский')


--СОЗДАНИЕ ТАБЛИЦЫ НАРОДНОСТИ
create table nationality (
		nationality_id serial primary key,
		name varchar (100) unique not null
		)


--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ НАРОДНОСТИ
INSERT INTO homework4."nationality" ("name")
VALUES ('Восточные Славяне'), ('Западные Германцы'), ('Галло-романцы'),('Иберо-романцы'),('Итало-романцы')


--СОЗДАНИЕ ТАБЛИЦЫ СТРАНЫ
create table country (
		country_id serial primary key,
		name varchar (100) unique not null
		)


--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ СТРАНЫ
INSERT INTO homework4.country ("name")
VALUES ('Россия'), ('Англия'), ('Франция'),('Испания'),('Италия')


--СОЗДАНИЕ ПЕРВОЙ ТАБЛИЦЫ СО СВЯЗЯМИ
create table language_nationality (
		language_id int not null,
  		nationality_id int not null,
		primary key (language_id, nationality_id),
		foreign key (language_id)
      		references language (language_id),
  		foreign key (nationality_id)
      		references nationality (nationality_id)
		)


--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ СО СВЯЗЯМИ
INSERT INTO homework4.language_nationality (language_id, nationality_id)
VALUES (1,1), (1,2), (2,1),(1,3),(1,4)


--СОЗДАНИЕ ВТОРОЙ ТАБЛИЦЫ СО СВЯЗЯМИ
create table nationality_country (
		nationality_id int not null,
  		country_id int not null,
		primary key (nationality_id, country_id),
		foreign key (nationality_id)
      		references nationality (nationality_id),
  		foreign key (country_id)
      		references country (country_id)
		)


--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ СО СВЯЗЯМИ
INSERT INTO homework4.nationality_country (nationality_id, country_id)
VALUES (1,1), (1,2), (2,1),(1,3),(1,4)


--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============


--ЗАДАНИЕ №1 
--Создайте новую таблицу film_new со следующими полями:
--·   	film_name - название фильма - тип данных varchar(255) и ограничение not null
--·   	film_year - год выпуска фильма - тип данных integer, условие, что значение должно быть больше 0
--·   	film_rental_rate - стоимость аренды фильма - тип данных numeric(4,2), значение по умолчанию 0.99
--·   	film_duration - длительность фильма в минутах - тип данных integer, ограничение not null и условие, что значение должно быть больше 0
--Если работаете в облачной базе, то перед названием таблицы задайте наименование вашей схемы.
create table homework4.film_new (
	film_id serial primary key,
	film_name varchar (255) not null,
	film_year int CHECK (film_year > 0),
	film_rental_rate numeric(4,2) default 0.99,
	film_duration int not null CHECK (film_duration > 0)
	)


--ЗАДАНИЕ №2 
--Заполните таблицу film_new данными с помощью SQL-запроса, где колонкам соответствуют массивы данных:
--·       film_name - array['The Shawshank Redemption', 'The Green Mile', 'Back to the Future', 'Forrest Gump', 'Schindlers List']
--·       film_year - array[1994, 1999, 1985, 1994, 1993]
--·       film_rental_rate - array[2.99, 0.99, 1.99, 2.99, 3.99]
--·   	  film_duration - array[142, 189, 116, 142, 195]
insert into homework4.film_new(film_name, film_year, film_rental_rate, film_duration)
select 
	unnest(array['The Shawshank Redemption', 'The Green Mile', 'Back to the Future', 'Forrest Gump', 'Schindler’s List']),
	unnest(array[1994, 1999, 1985, 1994, 1993]),
	unnest(array[2.99, 0.99, 1.99, 2.99, 3.99]),
	unnest(array[142, 189, 116, 142, 195])


--ЗАДАНИЕ №3
--Обновите стоимость аренды фильмов в таблице film_new с учетом информации, 
--что стоимость аренды всех фильмов поднялась на 1.41
update homework4.film_new
set film_rental_rate = film_rental_rate * 1.41


--ЗАДАНИЕ №4
--Фильм с названием "Back to the Future" был снят с аренды, 
--удалите строку с этим фильмом из таблицы film_new
delete from homework4.film_new
where film_name = 'Back to the Future'


--ЗАДАНИЕ №5
--Добавьте в таблицу film_new запись о любом другом новом фильме
insert into homework4.film_new(film_name, film_year, film_rental_rate, film_duration)
values ('Mortal Combat', 1995, 6.34, 205)


--ЗАДАНИЕ №6
--Напишите SQL-запрос, который выведет все колонки из таблицы film_new, 
--а также новую вычисляемую колонку "длительность фильма в часах", округлённую до десятых
select *, (
round(film_duration::decimal / 60, 1) 
) "длительность фильма в часах"
from homework4.film_new


--ЗАДАНИЕ №7 
--Удалите таблицу film_new
drop table homework4.film_new