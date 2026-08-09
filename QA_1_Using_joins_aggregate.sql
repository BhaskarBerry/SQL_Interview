CREATE TABLE people (
    id INT PRIMARY KEY,
    name VARCHAR(50),
    gender CHAR(1)
);

INSERT INTO people (id, name, gender) VALUES
(107, 'days', 'F'),
(145, 'hawbaker', 'M'),
(201, 'blackston', 'M'),
(206, 'nolf', 'M'),
(207, 'criss', 'F'),
(208, 'tong', 'M'),
(209, 'chatmon', 'F'),
(212, 'mozingo', 'M'),
(213, 'waugh', 'M');

CREATE TABLE relations (
    c_id INT,   -- Child ID
    p_id INT    -- Parent ID
);

INSERT INTO relations (c_id, p_id) VALUES
(145, 201),
(145, 107),
(212, 206),
(212, 207),
(213, 208),
(213, 209);

select* from people;
select * from relations;

--- Query..

select c.name as Name, 
  MAX(case when p.gender = 'F' then p.name end ) as Father, 
  MAX(case when p.gender = 'M' then p.name end ) as Mother
from people as c 
inner join relations as r on c.id = r.c_id
inner join people as p on r.p_id = p.id 
group by c.name
;

--- output----
/*
-------------------------
Name	 Father		Mother
-------------------------
hawbaker days		blackston
mozingo	 criss		nolf
waugh	 chatmon	tong
*/
