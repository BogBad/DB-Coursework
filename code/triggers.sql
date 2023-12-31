
-- 1.1 Перевірка унікальності при вставленні нового клієнта
CREATE OR REPLACE FUNCTION check_client_uniqueness()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM client WHERE email = NEW.email) THEN
        RAISE EXCEPTION 'Email % already exists for a client', NEW.email;
    END IF;

    IF EXISTS (SELECT 1 FROM client WHERE telephone = NEW.telephone) THEN
        RAISE EXCEPTION 'Telephone number % already exists for a client', NEW.telephone;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_insert_client
BEFORE INSERT ON client
FOR EACH ROW 
EXECUTE FUNCTION check_client_uniqueness();

INSERT INTO client (name, surname, address, telephone, email)
VALUES ('John', 'Doe', '123 Main Street, Cityville', '555-1234', 'lwle0@biloe.ne.jp');


-- 1.2 Перевірка унікальності при вставленні нового провайдера
CREATE OR REPLACE FUNCTION check_provider_uniqueness()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM provider WHERE email = NEW.email) THEN
        RAISE EXCEPTION 'Email % already exists for a provider', NEW.email;
    END IF;

    IF EXISTS (SELECT 1 FROM provider WHERE telephone = NEW.telephone) THEN
        RAISE EXCEPTION 'Telephone number % already exists for a provider', NEW.telephone;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_insert_provider
BEFORE INSERT ON provider
FOR EACH ROW 
EXECUTE FUNCTION check_provider_uniqueness();

INSERT INTO provider (name, surname, address, telephone, email, rating, service_area)
VALUES ('ProviderFirstName', 'ProviderLastName', '456 Oak Street, Townsville', '555-5678', 'slinda0@lycos.com', 4, 'Service Area Details');


-- 2. Оновити рейтинг провадера при написанні нового відгуку
CREATE OR REPLACE FUNCTION update_provider_rating()
RETURNS TRIGGER AS $$
DECLARE
    average_rating NUMERIC;
BEGIN
    
    SELECT AVG(rating) INTO average_rating
    FROM review
    WHERE provider_id = NEW.provider_id;

    UPDATE provider
    SET rating = ROUND(average_rating)
    WHERE provider_id = NEW.provider_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_insert_review
AFTER INSERT ON review
FOR EACH ROW
EXECUTE FUNCTION update_provider_rating();

INSERT INTO review (rating, comment, review_date, client_id, provider_id)
VALUES (100, 'Excellent service!', '2023-12-29', 1, 1);


-- 3. Перевірка зміни рейтингу провайдера
CREATE OR REPLACE FUNCTION check_rating_change()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.rating <> NEW.rating THEN
        RAISE NOTICE 'Rating for provider % has changed from % to %', NEW.name, OLD.rating, NEW.rating;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_update_provider
BEFORE UPDATE OF rating ON provider
FOR EACH ROW EXECUTE FUNCTION check_rating_change();


-- 4. Видалення постачальника з високим рейтингом
CREATE OR REPLACE FUNCTION prevent_delete_high_rated_provider()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.rating >= 80 THEN
        RAISE EXCEPTION 'Cannot delete provider with high rating (%).', OLD.rating;
    END IF;

    DELETE FROM contract WHERE provider_id = OLD.provider_id;

    DELETE FROM service WHERE provider_id = OLD.provider_id;

    DELETE FROM product WHERE provider_id = OLD.provider_id;

    DELETE FROM bid WHERE provider_id = OLD.provider_id;

    DELETE FROM review WHERE provider_id = OLD.provider_id;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER prevent_delete_high_rated_provider
BEFORE DELETE ON provider
FOR EACH ROW
EXECUTE FUNCTION prevent_delete_high_rated_provider();

DELETE FROM provider WHERE provider_id = 2;


-- 5. Оновлення рейтингу після видалення відгуку
CREATE OR REPLACE FUNCTION update_provider_rating_after_delete()
RETURNS TRIGGER AS $$
DECLARE
    average_rating NUMERIC;
BEGIN
    
    SELECT COALESCE(AVG(rating), 0) INTO average_rating
    FROM review
    WHERE provider_id = OLD.provider_id;

    UPDATE provider
    SET rating = ROUND(average_rating)
    WHERE provider_id = OLD.provider_id;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_delete_review
AFTER DELETE ON review
FOR EACH ROW
EXECUTE FUNCTION update_provider_rating_after_delete();

DELETE FROM review WHERE review_id = 4;
