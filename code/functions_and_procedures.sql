
-- 1. Виведення відгуків до заданого провайдера
CREATE OR REPLACE FUNCTION Provider_feedback(given_provider_id BIGINT)
RETURNS TABLE (
    review_id BIGINT,
    rating SMALLINT,
    comment TEXT,
    review_date DATE,
    client_id BIGINT,
    provider_id BIGINT
)
AS $$
BEGIN
    RETURN QUERY
    SELECT *
    FROM review
    WHERE review.provider_id = given_provider_id
    ORDER BY rating DESC;
END;
$$ LANGUAGE PLPGSQL;

SELECT * FROM Provider_feedback(1);


-- 2. Обрахунок загальної вартості контрактів для заданого провайдера
CREATE OR REPLACE FUNCTION Total_contracts_cost(given_provider_id BIGINT)
RETURNS NUMERIC
AS $$
DECLARE
    total_cost NUMERIC;
BEGIN
    SELECT SUM(contract.total_cost) INTO total_cost
    FROM contract
    WHERE contract.provider_id = given_provider_id;

    RETURN COALESCE(total_cost, 0); 
END;
$$ LANGUAGE PLPGSQL;

SELECT Total_contracts_cost(1);


-- 3. Порівняння двох заданих типів оплат
CREATE OR REPLACE FUNCTION Compare_payment_methods(method1 VARCHAR(50), method2 VARCHAR(50))
RETURNS TABLE (
    method VARCHAR(50),
    payment_count BIGINT
)
AS $$
BEGIN
    RETURN QUERY
    SELECT
        payment_method AS method,
        COUNT(*) AS payment_count
    FROM payment
    WHERE payment_method IN (method1, method2)
    GROUP BY payment_method;
END;
$$ LANGUAGE PLPGSQL;

SELECT * FROM Compare_payment_methods('PayPal', 'Cash');


-- 4. Кількість провайдерів з ретингом більше заданного
CREATE OR REPLACE FUNCTION High_rated_providers(min_rating INTEGER)
RETURNS INTEGER
AS $$
DECLARE
    driver_count INTEGER;
BEGIN
    SELECT
        COUNT(*) INTO driver_count
    FROM provider
    WHERE rating > min_rating;

    RETURN driver_count;
END;
$$ LANGUAGE PLPGSQL;

SELECT High_rated_providers(80);


-- 5. Змінити номер телефону провайдера
CREATE OR REPLACE PROCEDURE Update_provider_phone(p_provider_id INTEGER, p_new_phone_number VARCHAR(20))
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE Provider
    SET telephone = p_new_phone_number
    WHERE provider_id = p_provider_id;
    RAISE NOTICE 'New phone number for provider % is %', p_provider_id, p_new_phone_number;
END;
$$;

CALL Update_provider_phone(1, '353-112-2952');


-- 6. Видалити певну послугу
CREATE OR REPLACE PROCEDURE Delete_service(input_service_id BIGINT)
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM service WHERE service_id = input_service_id) THEN
        RAISE EXCEPTION 'Service with specified service_id does not exist.';
    END IF;

    DELETE FROM service WHERE service_id = input_service_id;
    RAISE NOTICE 'Service #% deleted', input_service_id;
END;
$$ LANGUAGE PLPGSQL;

CALL Delete_service(2); 


-- 7. Підрахунок кількості контрактів для заданого провайдера
CREATE OR REPLACE FUNCTION Count_contracts_for_provider(given_provider_id BIGINT)
RETURNS INTEGER
AS $$
DECLARE
    contract_count INTEGER;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM provider WHERE provider_id = given_provider_id) THEN
        RAISE NOTICE 'No provider found with ID %', given_provider_id;
        RETURN 0;
    END IF;

    SELECT COUNT(*) INTO contract_count
    FROM contract
    WHERE provider_id = given_provider_id;

    RETURN contract_count;
END;
$$ LANGUAGE PLPGSQL;


SELECT Count_contracts_for_provider(2);


-- 8. Виведення деталей обраного тендеру
CREATE OR REPLACE FUNCTION Tender_details_and_bids(given_tender_id BIGINT)
RETURNS TABLE (
    tender_id BIGINT,
    start_date DATE,
    end_date DATE,
    starting_stake INT,
    end_stake INT,
    winner_provider_name VARCHAR(60),
    amount_of_stakes INT
)
AS $$
BEGIN
    RETURN QUERY
    SELECT t.tender_id, t.start_date, t.end_date, t.starting_bid, t.current_bid, p.name AS provider_name, b.amount
    FROM tender t
    LEFT JOIN bid b ON t.tender_id = b.tender_id
    LEFT JOIN provider p ON b.provider_id = p.provider_id
    WHERE t.tender_id = given_tender_id;
END;
$$ LANGUAGE PLPGSQL;

SELECT * FROM Tender_details_and_bids(1);


-- 9. Обраховує кількість провайдерів у заданому регіоні
CREATE OR REPLACE FUNCTION Providers_in_region(region TEXT)
RETURNS TABLE (
    provider_id BIGINT,
    name VARCHAR(30),
    surname VARCHAR(30),
    rating SMALLINT
)
AS $$
DECLARE
    provider_count INT;
BEGIN
    RETURN QUERY
    SELECT provider.provider_id, provider.name, provider.surname, provider.rating
    FROM provider
    WHERE provider.service_area = region
    ORDER BY provider.rating DESC;

    SELECT COUNT(*) INTO provider_count
    FROM provider
    WHERE provider.service_area = region;

    RAISE NOTICE 'Total providers in region %: %', region, provider_count;
END;
$$ LANGUAGE PLPGSQL;

SELECT * FROM Providers_in_region('Asia');


-- 10. Обрахувати потенційну виручку від певного продукту на складі
CREATE OR REPLACE FUNCTION CalculateInventoryValueForProduct(product_name VARCHAR(50))
RETURNS TABLE (
    owner_provider_name VARCHAR(60),
    provider_telephone VARCHAR(20),
    provider_region TEXT,
    total_product_value NUMERIC
)
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        CAST(pr.name || ' ' || pr.surname AS VARCHAR(60)) AS owner_provider_name,
        pr.telephone AS provider_telephone,
        pr.service_area AS provider_region,
        SUM(p.price * p.stock_quantity) AS total_product_value
    FROM provider pr
    JOIN product p ON pr.provider_id = p.provider_id
    WHERE p.name = product_name
    GROUP BY pr.provider_id, pr.name, pr.surname, pr.telephone, pr.service_area;
END;
$$ LANGUAGE PLPGSQL;

SELECT * FROM CalculateInventoryValueForProduct('Drone "SkyExplorer Pro"');
