
-- Детальна інформація про контракти
CREATE VIEW contract_details AS
SELECT 
    c.contract_id,
    cl.name AS client_name,
    pr.name AS provider_name,
    c.start_date,
    c.end_date,
    c.total_cost
FROM contract c
JOIN client cl ON c.client_id = cl.client_id
JOIN provider pr ON c.provider_id = pr.provider_id;


-- Представлення для відслідковування тендерів з їх поточним статусом
CREATE VIEW tender_status AS
SELECT 
    t.tender_id,
    t.start_date,
    t.end_date,
    t.starting_bid,
    t.current_bid,
    CASE 
        WHEN CURRENT_DATE > t.end_date THEN 'Closed'
        ELSE 'Open'
    END AS status
FROM tender t;


-- Детальна інформація про рев'ю
CREATE VIEW provider_reviews AS
SELECT 
    pr.name AS provider_name,
    r.rating,
    r.comment,
    r.review_date
FROM provider pr
JOIN review r ON pr.provider_id = r.provider_id;


-- Найкращі провайдери за сумою прибутку від укладених контрактів
CREATE VIEW top_10_providers_by_contract_value AS
SELECT 
    pr.provider_id,
    pr.name AS provider_name,
    SUM(co.total_cost) AS total_contract_value
FROM provider pr
JOIN contract co ON pr.provider_id = co.provider_id
GROUP BY pr.provider_id, pr.name
ORDER BY total_contract_value DESC
LIMIT 10;
