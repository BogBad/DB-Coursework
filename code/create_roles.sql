
-- Створення ролей
CREATE ROLE data_analyst_role;
CREATE ROLE provider_manager_role;
CREATE ROLE client_manager_role;
CREATE ROLE accountant_role;

-- Надання привілеїв для ролі аналітика даних
GRANT SELECT ON ALL TABLES IN SCHEMA public TO data_analyst_role;

CREATE TEMPORARY TABLE p_copy (
        provider_id BIGSERIAL NOT NULL PRIMARY KEY,
        name VARCHAR(30) NOT NULL,
        surname VARCHAR(30) NOT NULL,
        address TEXT NOT NULL,
        telephone VARCHAR(20) NOT NULL,
        email VARCHAR(50),
        rating SMALLINT NOT NULL,
        service_area TEXT NOT NULL
);
INSERT INTO p_copy SELECT * FROM provider;


-- Надання привілеїв для ролі менеджера постачальників
GRANT SELECT, INSERT, UPDATE ON TABLE provider, contract, service, product TO provider_manager_role;
GRANT SELECT ON TABLE client TO provider_manager_role;

UPDATE provider
SET
  name = 'New Name',
  surname = 'New Surname',
  address = 'New Address',
  telephone = '+380999888777',
  rating = 100,
  service_area = 'Asia'
WHERE provider_id = 1;

UPDATE client
SET
  name = 'New Name',
  surname = 'New Surname',
  address = 'New Address',
  telephone = '+380999888777'
WHERE client_id = 1;


-- Надання привілеїв для ролі менеджера клієнтів
GRANT SELECT, INSERT, UPDATE ON TABLE client, contract, "order" TO client_manager_role;
GRANT SELECT ON TABLE provider TO client_manager_role;

UPDATE client
SET
  name = 'New Name',
  surname = 'New Surname',
  address = 'New Address',
  telephone = '+380999888777'
WHERE client_id = 1;

UPDATE provider
SET
  name = 'New Name',
  surname = 'New Surname',
  address = 'New Address',
  telephone = '+380999888777',
  rating = 100,
  service_area = 'Asia'
WHERE provider_id = 1;

-- Надання привілеїв для ролі бухгалтера
GRANT SELECT ON TABLE contract, "order", payment TO accountant_role;

\c trading_platform;

-- Створення користувачів
CREATE USER data_analyst WITH PASSWORD 'analys';
CREATE USER provider_manager WITH PASSWORD 'manager777';
CREATE USER client_manager WITH PASSWORD 'manager123';
CREATE USER accountant WITH PASSWORD '00877';

GRANT data_analyst_role TO data_analyst;
GRANT provider_manager_role TO provider_manager;
GRANT client_manager_role TO client_manager;
GRANT accountant_role TO accountant;
