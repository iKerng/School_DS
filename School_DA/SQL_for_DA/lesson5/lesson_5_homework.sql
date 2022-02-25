--����� ��: https://docs.google.com/document/d/1NVORWgdwlKepKq_b8SPRaSpraltxoMg2SIusTEN6mEQ/edit?usp=sharing
--colab/jupyter: https://colab.research.google.com/drive/1j4XdGIU__NYPVpv74vQa9HUOAkxsgUez?usp=sharing

--task1 (lesson5)
-- ������������ �����: ������� view (pages_all_products), � ������� ����� ������������ �������� ���� ��������� (�� ����� ���� ��������� �� ����� ��������). 
-- �����: ��� ������ �� laptop, ����� ��������, ������ ���� �������

SELECT 
	p.maker
	, l.*
	, round((ROW_NUMBER() over() + 1)/2) AS page 
	, count(*) OVER()/2 pages
FROM 
	product p 
	JOIN laptop l ON l.model = p.model

--task1 (lesson5) � ����������
	
SELECT 
	app.maker
	, model 
	, REPLACE('list'||to_char(round((ROW_NUMBER() over(ORDER BY maker) + 1)/2), '999'),' ', '') AS page 
	, count(*) OVER()/2 AS count_pages
FROM 
	all_products_price app 

	
--task2 (lesson5)
-- ������������ �����: ������� view (distribution_by_type), � ������ �������� ����� ���������� ����������� ���� ������� �� ���� ����������. �����: �������������,
CREATE OR REPLACE VIEW distribution_by_type AS 
(SELECT * FROM (SELECT "type", (count(*) OVER(PARTITION BY "type")*100/count(*) over()) AS percent_all FROM all_products_price app ORDER BY maker) a 
GROUP BY 1,2)
	
--task3 (lesson5)
-- ������������ �����: ������� �� ���� ����������� view ������ - �������� ���������

SELECT * from distribution_by_type

--task4 (lesson5)
-- �������: ������� ����� ������� ships (ships_two_words), �� � �������� ������� ������ �������� �� ���� ����
CREATE TABLE ships_two_words AS 
(
	SELECT * FROM ships s WHERE "name" LIKE '% %' 
);


--task5 (lesson5)
-- �������: ������� ������ ��������, � ������� class ����������� (IS NULL) � �������� ���������� � ����� "S"
CREATE OR REPLACE VIEW all_ships AS 
select 
	COALESCE (o."ship", s."name") AS ship_name
	, s."class"
from 
	outcomes o  
	left join ships s on s."name" = o.ship;  

SELECT * FROM all_ships als 
WHERE 
	als."class" IS NULL AND als.ship_name LIKE 'S%' 

--task6 (lesson5)
-- ������������ �����: ������� ��� �������� ������������� = 'A' �� ���������� ���� ������� �� ��������� ������������� = 'C' 
--� ��� ����� ������� (����� ������� �������). ������� model

SELECT * FROM 	
	(
		SELECT 
			*
			, row_number() OVER(ORDER BY price) AS rn
		FROM 
			all_products_price app 
		WHERE 
			maker = 'A' 
			AND "type" = 'Printer' 
			AND price > (SELECT COALESCE (avg(price), 0) FROM all_products_price app2 WHERE maker = '�' AND app2."type" = 'Printer')
	) a
WHERE 
	rn < 4;
