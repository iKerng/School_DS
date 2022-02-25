--����� ��: https://docs.google.com/document/d/1NVORWgdwlKepKq_b8SPRaSpraltxoMg2SIusTEN6mEQ/edit?usp=sharing
--colab/jupyter: https://colab.research.google.com/drive/1j4XdGIU__NYPVpv74vQa9HUOAkxsgUez?usp=sharing

create or replace view all_products_price as 
	(
		select pro.maker, pro."type", mo.*from 
			product pro
			join 
			(
				SELECT model, price FROM pc
				union all
				SELECT model, price FROM printer p 
				union all
				SELECT model, price FROM laptop
			) mo on mo.model = pro.model
	)

--task13 (lesson3)
--������������ �����: ������� ������ ���� ��������� � ������������� � ��������� ���� �������� (pc, printer, laptop). �������: model, maker, type
with query_models as 
	(
		SELECT model, 'PC' as "type" FROM pc
		union
		SELECT model, 'Printer' FROM printer p 
		union
		SELECT model, 'Laptop' FROM laptop
	)
select pro.maker, qm.* from product pro join query_models qm on qm.model = pro.model

--task14 (lesson3)
--������������ �����: ��� ������ ���� �������� �� ������� printer ������������� ������� ��� ���, � ���� ���� ����� ������� PC - "1", � ��������� - "0"

SELECT pr.*, case when pr.price > (select avg(price) from printer) then 1 else 0 end as more_avg FROM printer pr

--task15 (lesson3)
--�������: ������� ������ ��������, � ������� class ����������� (IS NULL)

select * from ships s where s."class" is null

--task16 (lesson3)
--�������: ������� ��������, ������� ��������� � ����, �� ����������� �� � ����� �� ����� ������ �������� �� ����.

select "name" from battles b where to_number(to_char(b."date", 'YYYY'), '9999') <> any (select launched from ships s)

--task17 (lesson3)
--�������: ������� ��������, � ������� ����������� ������� ������ Kongo �� ������� Ships.

select b."name" from outcomes o join battles b on b."name"  = o.battle join ships s on s."name" = o.ship and s."class" = 'Kongo'

--task1  (lesson4)
-- ������������ �����: ������� view (�������� all_products_flag_300) ��� ���� ������� (pc, printer, laptop) � ������, ���� ��������� ������ > 300. �� view ��� �������: model, price, flag

create view all_products_flag_300 as 
	(
		select
			model
			, price
			, case when price > 300 then 1 else 0 end as flag
		from 
			(
				SELECT model, price FROM pc
				union
				SELECT model, price FROM printer p 
				union
				SELECT model, price FROM laptop
			)
	)

--task2  (lesson4)
-- ������������ �����: ������� view (�������� all_products_flag_avg_price) ��� ���� ������� (pc, printer, laptop) � ������, ���� ��������� ������ c������ . �� view ��� �������: model, price, flag

create view all_products_flag_avg_price as 
	(
		with models_price as 
			(
				SELECT model, price FROM pc
				union
				SELECT model, price FROM printer p 
				union
				SELECT model, price FROM laptop
			)
		select
			model
			, price
			, case when price > (select avg(price) from models_price) then 1 else 0 end as flag
		from 
			models_price
	)
	
		
--task3  (lesson4)
-- ������������ �����: ������� ��� �������� ������������� = 'A' �� ���������� ���� ������� �� ��������� ������������� = 'D' � 'C'. ������� model

select ap.model from all_products_price ap 
where 
	ap.maker = 'A'
	and ap."type" = 'Printer'
	and ap.price > (select avg(price) from all_products_price app where app.maker in ('D', 'C') and app."type" = 'Printer')
	
--	
--task4 (lesson4)
-- ������������ �����: ������� ��� ������ ������������� = 'A' �� ���������� ���� ������� �� ��������� ������������� = 'D' � 'C'. ������� model

select * from all_products_price app
where 
	app.maker = 'A'
	and app.price > (select avg(price) from all_products_price app1 where app1.maker in ('D', 'C') and app1."type" = 'Printer')

	
	
--task5 (lesson4)
-- ������������ �����: ����� ������� ���� ����� ���������� ��������� ������������� = 'A' (printer & laptop & pc)

select avg(price) from (select distinct model, price from all_products_price app where maker = 'A')	b
;
--task6 (lesson4)
-- ������������ �����: ������� view � ����������� ������� (�������� count_products_by_makers) �� ������� �������������. �� view: maker, count
create view count_products_by_makers as 
	(select maker, count(*) as count from all_products_price app group by maker)
;
--task7 (lesson4)
-- �� ����������� view (count_products_by_makers) ������� ������ � colab (X: maker, y: count)

/*
 * see at lesson_4_homework.py
 * */

--task8 (lesson4)
-- ������������ �����: ������� ����� ������� printer (�������� printer_updated) � ������� �� ��� ��� �������� ������������� 'D'

-- 1 variant
create table printer_updated as 
	(select * from printer where model not in (select model from all_products_price where "type" = 'Printer' and maker = 'D'));
-- 2 variant
drop table printer_updated;
create table printer_updated as (select * from printer);
delete from printer_update where model in (select model from all_products_price where "type" = 'Printer' and maker = 'D'));
	
--task9 (lesson4)
-- ������������ �����: ������� �� ���� ������� (printer_updated) view � �������������� �������� ������������� (�������� printer_updated_with_makers)

create or replace view printer_updated_with_makers as 
	(select distinct pu.*, pro.maker from printer_updated pu join product pro on pro.model = pu.model )

--task10 (lesson4)
-- �������: ������� view c ����������� ����������� �������� � ������� ������� (�������� sunk_ships_by_classes). �� view: count, class (���� �������� ������ ���/IS NULL, �� �������� �� 0)

create or replace view sunk_ships_by_classes as 
	(		
		select 
			coalesce (s."class", '0') as "ship_class",
			count(*) as quantity
		from 
			outcomes o  
			left join ships s on s."name" = o.ship  
		where o."result" = 'sunk' 
		group by s."class"
	);
	
--task11 (lesson4)
-- �������: �� ����������� view (sunk_ships_by_classes) ������� ������ � colab (X: class, Y: count)

/*
 * see at lesson_4_homework.py
 * */


--task12 (lesson4)
-- �������: ������� ����� ������� classes (�������� classes_with_flag) � �������� � ��� flag: ���� ���������� ������ ������ ��� ����� 9 - �� 1, ����� 0

create table classes_with_flag as 
	(select c.*, case when numguns >= 9 then 1 else 0 end as flag from classes c)

--task13 (lesson4)
-- �������: ������� ������ � colab �� ������� classes � ����������� ������� �� ������� (X: country, Y: count)

/*
 * see at lesson_4_homework.py
 * */

--task14 (lesson4)
-- �������: ������� ���������� ��������, � ������� �������� ���������� � ����� "O" ��� "M".

	select count(regexp_match(s."name", '^(O|M)')) from ships s
		
--task15 (lesson4)
-- �������: ������� ���������� ��������, � ������� �������� ������� �� ���� ����.
	
	select count(*) from ships s where s."name" like '% %'
	
--task16 (lesson4)
-- �������: ��������� ������ � ����������� ���������� �� ���� �������� � ����� ������� (X: year, Y: count)

/*
 * see at lesson_4_homework.py
 * */
	