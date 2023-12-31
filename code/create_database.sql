
CREATE DATABASE trading_platform;

CREATE TABLE client(
    client_id BIGSERIAL NOT NULL PRIMARY KEY,
    name VARCHAR(30) NOT NULL,
    surname VARCHAR(30) NOT NULL,
    address TEXT NOT NULL,
    telephone VARCHAR(20) NOT NULL,
    email VARCHAR(50)
);

CREATE TABLE provider(
    provider_id BIGSERIAL NOT NULL PRIMARY KEY,
    name VARCHAR(30) NOT NULL,
    surname VARCHAR(30) NOT NULL,
    address TEXT NOT NULL,
    telephone VARCHAR(20) NOT NULL,
    email VARCHAR(50),
    rating SMALLINT NOT NULL,
    service_area TEXT NOT NULL
);

CREATE TABLE contract(
    contract_id BIGSERIAL NOT NULL PRIMARY KEY,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_cost NUMERIC(19, 2) NOT NULL,
    client_id  BIGINT NOT NULL REFERENCES client(client_id),
    provider_id  BIGINT NOT NULL REFERENCES provider(provider_id)
);

CREATE TABLE service(
    service_id BIGSERIAL NOT NULL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    description TEXT NOT NULL,
    price NUMERIC(19, 2) NOT NULL,
    availability VARCHAR(20) NOT NULL,
    provider_id  BIGINT NOT NULL REFERENCES provider(provider_id)
);

CREATE TABLE product(
    product_id BIGSERIAL NOT NULL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    category VARCHAR(50) NOT NULL,
    price NUMERIC(19, 2) NOT NULL,
    stock_quantity INT NOT NULL,
    provider_id  BIGINT NOT NULL REFERENCES provider(provider_id)
);

CREATE TABLE tender(
    tender_id BIGSERIAL NOT NULL PRIMARY KEY,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    starting_bid INT NOT NULL,
    current_bid INT NOT NULL
);

CREATE TABLE bid(
    bid_id BIGSERIAL NOT NULL PRIMARY KEY,
    amount INT NOT NULL,
    tender_id  BIGINT NOT NULL REFERENCES tender(tender_id),
    provider_id  BIGINT NOT NULL REFERENCES provider(provider_id)
);

CREATE TABLE review(
    review_id BIGSERIAL NOT NULL PRIMARY KEY,
    rating SMALLINT NOT NULL,
    comment TEXT,
    review_date DATE NOT NULL,
    client_id  BIGINT NOT NULL REFERENCES client(client_id),
    provider_id  BIGINT NOT NULL REFERENCES provider(provider_id)
);

CREATE TABLE payment(
    payment_id BIGSERIAL NOT NULL PRIMARY KEY,
    cost INT NOT NULL,
    payment_date DATE NOT NULL,
    payment_method VARCHAR(50) NOT NULL
);

CREATE TABLE "order"(
    order_id BIGSERIAL NOT NULL PRIMARY KEY,
    total_cost NUMERIC(19, 2) NOT NULL,
    order_date DATE NOT NULL,
    client_id  BIGINT NOT NULL REFERENCES client(client_id),
    payment_id BIGINT NOT NULL REFERENCES payment(payment_id)
);