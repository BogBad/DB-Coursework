
\COPY client(name, surname, address, telephone, email) FROM 'D:\data2\client.csv' DELIMITER ';' CSV HEADER;

\COPY provider(name, surname, address, telephone, email, rating, service_area) FROM 'D:\data2\provider.csv' DELIMITER ';' CSV HEADER;

\COPY contract(start_date, end_date, total_cost, client_id, provider_id) FROM 'D:\data2\contract.csv' DELIMITER ';' CSV HEADER;

\COPY service(name, description, price, availability, provider_id) FROM 'D:\data2\service.csv' DELIMITER ';' CSV HEADER;

\COPY product(name, category, price, stock_quantity, provider_id) FROM 'D:\data2\product.csv' DELIMITER ';' CSV HEADER;

\COPY tender(start_date, end_date, starting_bid, current_bid) FROM 'D:\data2\tender.csv' DELIMITER ';' CSV HEADER;

\COPY bid(amount, tender_id, provider_id) FROM 'D:\data2\bid.csv' DELIMITER ';' CSV HEADER;

\COPY review(rating, comment, review_date, client_id, provider_id) FROM 'D:\data2\review.csv' DELIMITER ';' CSV HEADER;

\COPY payment(cost, payment_date, payment_method) FROM 'D:\data2\payment.csv' DELIMITER ';' CSV HEADER;

\COPY "order"(total_cost, order_date, client_id, payment_id) FROM 'D:\data2\order.csv' DELIMITER ';' CSV HEADER;

DROP TABLE "order", payment, review, bid, tender, product, service, contract, provider, client;