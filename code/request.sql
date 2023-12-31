
-- 1. Отримати список клієнтів та інформацію про їх контракти
SELECT 
    c.name AS client_name,
    c.surname AS client_surname,
    c.address AS client_address,
    c.telephone AS client_telephone,
    c.email AS client_email,
    contract_data.contract_id, 
    contract_data.start_date, 
    contract_data.end_date, 
    contract_data.total_cost
FROM client c
JOIN (
    SELECT 
        co.contract_id, 
        co.start_date, 
        co.end_date, 
        co.total_cost, 
        co.client_id
    FROM contract co
) AS contract_data ON c.client_id = contract_data.client_id;


-- 2. Запит на визначення середньої кількості товарів на складі для кожної категорії 
SELECT 
    p.category,
    ROUND(AVG(p.stock_quantity)) AS average_stock_quantity,
    COUNT(DISTINCT pr.provider_id) AS number_of_providers
FROM product p
JOIN provider pr ON p.provider_id = pr.provider_id
GROUP BY p.category;


-- 3. Запит на виведення інформації про контракти з найбільшою та найменшою вартістю
SELECT c.client_id, c.name, c.surname, 
       co.total_cost
FROM contract co
JOIN client c ON co.client_id = c.client_id
WHERE co.total_cost = (SELECT MAX(total_cost) FROM contract)
   OR co.total_cost = (SELECT MIN(total_cost) FROM contract);


-- 4. Запит на визначення кількості клієнтів, які зробили замовлення та середньої вартості 1 замовлення за кожен місяць
SELECT
    TO_CHAR(MIN("order".order_date)::DATE, 'Mon YYYY') || ' - ' || TO_CHAR(MAX("order".order_date)::DATE, 'Mon YYYY') AS month_interval,
    COUNT(DISTINCT client.client_id) AS unique_client_count,
    ROUND(AVG("order".total_cost), 2) AS average_order_cost
FROM "order"
JOIN client ON "order".client_id = client.client_id
GROUP BY TO_CHAR("order".order_date, 'YYYY-MM')
ORDER BY MIN("order".order_date);


-- 5. Запит про виведення усіх клієнтів, котрі з запізненням оплатили контракт
SELECT cl.client_id, cl.name, cl.surname, 
       co.contract_id, co.start_date AS contract_start_date, 
       pa.payment_date
FROM client cl
JOIN contract co ON cl.client_id = co.client_id
JOIN payment pa ON co.contract_id = pa.payment_id
WHERE pa.payment_date > co.start_date;


-- 6. Запит на визначення кількості та загальної вартості укладених контрактів для кожного постачальника
SELECT
    pr.provider_id,
    pr.name AS provider_name,
    COUNT(co.contract_id) AS contract_count,
    SUM(co.total_cost) AS total_contract_cost,
    MAX(co.total_cost) AS most_expensive_contract
FROM provider pr
LEFT JOIN contract co ON pr.provider_id = co.provider_id
GROUP BY pr.provider_id, pr.name
ORDER BY pr.provider_id;


-- 7. Запит на визначення кількості відгуків та середньої оцінки для кожного провайдера
SELECT
    pr.provider_id,
    pr.name AS provider_name,
    COUNT(rv.review_id) AS review_count,
    ROUND(AVG(rv.rating), 2) AS average_rating
FROM provider pr
LEFT JOIN review rv ON pr.provider_id = rv.provider_id
GROUP BY pr.provider_id, pr.name
ORDER BY pr.provider_id;


-- 8. Запит на виведення лише тих рев'ю, в котрих присутній коментар
SELECT
    r.review_id, r.comment,
    c.name AS client_name,
    p.name AS provider_name
FROM review r
RIGHT JOIN client c ON r.client_id = c.client_id
RIGHT JOIN provider p ON r.provider_id = p.provider_id
WHERE r.comment IS NOT NULL;

-- 9. Запит на виведення переможця кожного тендеру
SELECT
    t.tender_id, t.start_date, t.end_date, t.current_bid AS final_price,
    MAX(b.amount) AS bid_count,
    p.name AS provider_name,
    p.surname AS provider_surname
FROM tender t
LEFT JOIN bid b ON t.tender_id = b.tender_id
LEFT JOIN provider p ON b.provider_id = p.provider_id
GROUP BY t.tender_id, p.provider_id
ORDER BY t.tender_id;


-- 10. Запит на виведення списку послуг, доступних у певному районі обслуговування
SELECT
    s.service_id,
    s.name AS service_name,
    s.description,
    s.price,
    s.availability,
    p.name AS provider_name,
    p.service_area
FROM service s
JOIN provider p ON s.provider_id = p.provider_id
WHERE p.service_area = 'Asia'
ORDER BY provider_name;


-- 11. Запит для виведення контрактів, котрі в найближчий місяць стануть не дійсні
SELECT
    c.contract_id,
    c.end_date,
    c.total_cost,
    cl.name AS client_name,
    cl.surname AS client_surname,
    p.name AS provider_name,
    p.surname AS provider_surname
FROM contract c
JOIN client cl ON c.client_id = cl.client_id
JOIN provider p ON c.provider_id = p.provider_id
WHERE c.end_date > CURRENT_DATE AND c.end_date <= CURRENT_DATE + INTERVAL '1 month';


-- 12. Запит для виведення найбільш активних клієнтів за сумою, витраченою на замовлення
SELECT 
    cl.name AS client_name, 
    cl.surname AS client_surname,
    MAX(o.total_cost) AS highest_order_cost
FROM client cl
JOIN "order" o ON cl.client_id = o.client_id
GROUP BY cl.client_id
ORDER BY highest_order_cost DESC
LIMIT 10;


-- 13. Запит для визначення середньої вартості контрактів по кожному постачальнику
SELECT 
    pr.name AS provider_name,
    pr.telephone AS phone_number, 
    ROUND(AVG(co.total_cost), 2) AS average_contract_cost,
    MIN(co.total_cost) AS least_expensive_contract,
    MAX(co.total_cost) AS most_expensive_contract
FROM provider pr
JOIN contract co ON pr.provider_id = co.provider_id
GROUP BY pr.provider_id;


-- 14. Запит для отримання інформації про всі сервіси, які надаються вибраними провайдерами
SELECT 
    s.name AS service_name, 
    s.description, 
    p.name AS provider_name
FROM service s
JOIN provider p ON s.provider_id = p.provider_id
WHERE p.provider_id IN (SELECT provider_id FROM provider WHERE name IN ('Sloan')); 


-- 15. Запит на виведення контрактів, вартість яких становить більше 950 тисяч
SELECT
    c.name AS client_name,
    pr.name AS provider_name,
    co.contract_id,
    pa.cost AS cost,
    co.start_date AS contract_start_date,
    co.end_date AS contract_end_date
FROM client c
JOIN contract co ON c.client_id = co.client_id
JOIN provider pr ON co.provider_id = pr.provider_id
JOIN payment pa ON co.contract_id = pa.payment_id
WHERE pa.cost > 950000;


-- 16. Запит для визначення провайдерів, які надають товари в певній категорії
SELECT
    pr.name AS provider_name,
    pr.address AS provider_address,
    pr.telephone AS provider_telephone,
    p.name AS product_name,
    p.price,
    p.category
FROM provider pr
JOIN product p ON pr.provider_id = p.provider_id
WHERE p.category = 'electronic'
ORDER BY pr.name;


-- 17. Запит на виведення всіх рев'ю для конктерного провайдера
SELECT
    c.name AS client_name,
    c.surname AS client_surname,
    r.rating,
    r.comment
FROM client c
JOIN review r ON c.client_id = r.client_id
WHERE r.provider_id = (SELECT provider_id FROM provider WHERE name = 'Sloan');


-- 18. Запит на виведення к-сті оплат кожним способ та найціннішого клієнта з його оплатою
WITH PaymentInfo AS (
  SELECT
    p.payment_method,
    MAX(o.total_cost) AS max_payment,
    COUNT(o.order_id) AS usage_count
  FROM payment p
  JOIN "order" o ON p.payment_id = o.payment_id
  GROUP BY p.payment_method
)

SELECT
  pi.payment_method,
  c.name AS most_valuable_client,
  pi.max_payment,
  pi.usage_count
FROM PaymentInfo pi
JOIN client c ON c.client_id IN (
  SELECT
    o.client_id
  FROM "order" o
  JOIN payment p ON o.payment_id = p.payment_id AND o.total_cost = pi.max_payment
)
GROUP BY pi.payment_method, c.name, pi.max_payment, pi.usage_count;


-- 19. Запит на виведення інформації про певний спосіб оплати
SELECT
  p.payment_id,
  p.payment_method,
  o.total_cost AS cost,
  c.name AS client_name
FROM payment p
JOIN "order" o ON p.payment_id = o.payment_id
JOIN client c ON o.client_id = c.client_id
WHERE p.payment_method = 'Cash';


-- 20. Запит на виведення лише доступних на даний момент послуг
SELECT
  s.service_id,
  s.name AS service_name,
  s.description,
  s.price,
  p.name AS provider_name
FROM service s
JOIN provider p ON s.provider_id = p.provider_id
WHERE s.availability = 'available'
ORDER BY provider_name;
