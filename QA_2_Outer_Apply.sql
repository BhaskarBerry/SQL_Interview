-- Create Table
CREATE TABLE product_status_history (
    id INT PRIMARY KEY,
    product_id INT NOT NULL,
    status_id INT NOT NULL,
    reason_id INT NULL,
    status_date DATE NOT NULL
);

-- Load Sample Data
INSERT INTO product_status_history (
    id,
    product_id,
    status_id,
    reason_id,
    status_date
)
VALUES
    (1, 1, 10, 14, '2022-01-01'),
    (2, 1, 10, NULL, '2022-01-02'),
    (3, 1, 4, 3, '2022-01-01'),
    (4, 1, 4, NULL, '2022-01-02'),
    (5, 2, 10, 11, '2022-01-01'),
    (6, 2, 10, NULL, '2022-01-02'),
    (7, 2, 10, NULL, '2022-01-03'),
    (8, 3, 4, NULL, '2022-01-01'),
    (9, 3, 4, 7, '2022-01-02'),
    (10, 3, 4, NULL, '2022-01-03');
------------------------------------------
/*
input:
id	product_id	status_id	reason_id	status_date
1	1	10	14	2022-01-01
2	1	10	NULL	2022-01-02
3	1	4	3	2022-01-01
4	1	4	NULL	2022-01-02
5	2	10	11	2022-01-01
6	2	10	NULL	2022-01-02
7	2	10	NULL	2022-01-03
8	3	4	NULL	2022-01-01
9	3	4	7	2022-01-02
10	3	4	NULL	2022-01-03


-- Result
id	product_id	status_id	reason_id	status_date
1	1	10	14	2022-01-01
2	1	10	14	2022-01-02
3	1	4	3	2022-01-01
4	1	4	3	2022-01-02
5	2	10	11	2022-01-01
6	2	10	11	2022-01-02
7	2	10	11	2022-01-03
8	3	4	NULL	2022-01-01
9	3	4	7	2022-01-02
10	3	4	7	2022-01-03
*/
----- Query Solution--------
select * from  product_status_history ;

select t.id,  t.product_id, t.status_id, x.reason_id, t.status_date 
from product_status_history as t 
outer apply (
 select top (1) reason_id from product_status_history as p
 where t.product_id = p.product_id
 AND t.status_id = p.status_id
 AND p.reason_id is not null
 AND p.status_date <= t.status_date
 order by p.status_date desc
 ) x
 order by t.id ASC


