
CREATE INDEX idx_client_telephone ON client(telephone);
CREATE INDEX idx_client_email ON client(email);
CREATE INDEX idx_client_name ON client(name);

CREATE INDEX idx_provider_telephone ON provider(telephone);
CREATE INDEX idx_provider_email ON provider(email);
CREATE INDEX idx_provider_name ON provider(name);

CREATE INDEX idx_contract_start_date ON contract(start_date);
CREATE INDEX idx_contract_end_date ON contract(end_date);

CREATE INDEX idx_review_comment ON review(comment);

CREATE INDEX idx_payment_payment_method ON payment(payment_method);


-- Перевірка роботи індексів

-- 1
EXPLAIN ANALYZE
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

-- 2
EXPLAIN ANALYZE
SELECT
    r.review_id, r.comment,
    c.name AS client_name,
    p.name AS provider_name
FROM review r
RIGHT JOIN client c ON r.client_id = c.client_id
RIGHT JOIN provider p ON r.provider_id = p.provider_id
WHERE r.comment IS NOT NULL;

-- 3
EXPLAIN ANALYZE
SELECT
  p.payment_id,
  p.payment_method,
  o.total_cost AS cost,
  c.name AS client_name
FROM payment p
JOIN "order" o ON p.payment_id = o.payment_id
JOIN client c ON o.client_id = c.client_id
WHERE p.payment_method = 'Cash';