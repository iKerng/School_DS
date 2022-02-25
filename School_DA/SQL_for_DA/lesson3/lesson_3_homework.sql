--����� ��: https://docs.google.com/document/d/1NVORWgdwlKepKq_b8SPRaSpraltxoMg2SIusTEN6mEQ/edit?usp=sharing

--task1
--�������: ��� ������� ������ ���������� ����� �������� ����� ������, ����������� � ���������. �������: ����� � ����� ����������� ��������.

select c."class", count(o."result") from classes c join ships s on s."class" = c."class" left join outcomes o on o.ship = s."name" and o."result" = 'sunk'
group by c."class"


--task2
--�������: ��� ������� ������ ���������� ���, ����� ��� ������ �� ���� ������ ������� ����� ������. ���� ��� ������ �� ���� ��������� ������� ����������, ���������� ����������� ��� ������ �� ���� �������� ����� ������. �������: �����, ���.

select 
	c."class"
	, min(launched) as launched_year 
from 
	classes c 
	join ships s on s."class" = c."class" 
group by c."class" 
order by min(launched)

--task3
--�������: ��� �������, ������� ������ � ���� ����������� �������� � �� ����� 3 �������� � ���� ������, ������� ��� ������ � ����� ����������� ��������.

select c."class", count(o."result") 
from 
	classes c 
	join ships s on s."class" = c."class" 
	left join outcomes o on o.ship = s."name" and o."result" = 'sunk'
group by c."class"
having count(o."result") > 3


--task4
--�������: ������� �������� ��������, ������� ���������� ����� ������ ����� ���� �������� ������ �� ������������� (������ ������� �� ������� Outcomes).
with ship_name as (select coalesce(s."name", o.ship) as ship, coalesce (s."class", o.ship) as "class" from outcomes o full join ships s on s."name" = o.ship) 
select sn.ship, sn."class", c.numguns, c.displacement from classes c right join ship_name sn on sn."class" = c."class" 
where 
	(c.numguns, c.displacement) in (select max(numguns) as numguns, c.displacement from classes c group by displacement )
order by c.displacement desc, c.numguns 

--task5
--������������ �����: ������� �������������� ���������, ������� ���������� �� � ���������� ������� RAM � � ����� ������� ����������� ����� ���� ��, ������� ���������� ����� RAM. �������: Maker

select maker from 
	product p 
	join pc on pc.model = p.model and (pc.ram, pc.speed) = (select min(ram), max(speed) from pc group by ram order by min(ram) limit 1)