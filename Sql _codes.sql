
-- 1. Total number of listings
SELECT COUNT(*) AS total_listings
FROM listings;

-- 2. Count listings by room type
SELECT room_type, COUNT(*) AS total
FROM listings
GROUP BY room_type;

-- 3. Average price by neighbourhood
SELECT neighbourhood, AVG(price) AS avg_price
FROM listings
GROUP BY neighbourhood
ORDER BY avg_price DESC;

-- 4. Listings with price > 500 and availability > 300
SELECT id, name, price, availability_365
FROM listings
WHERE price > 500 AND availability_365 > 300;

-- 5. Most reviewed listings (Top 10)
SELECT id, name, number_of_reviews
FROM listings
ORDER BY number_of_reviews DESC
LIMIT 10;

-- 6. Join listings and calendar to calculate avg price per listing
SELECT c.listing_id, l.name, AVG(c.price) AS avg_price
FROM calendar c
JOIN listings l ON c.listing_id = l.id
WHERE c.price IS NOT NULL
GROUP BY c.listing_id, l.name
ORDER BY avg_price DESC;

-- 7. Count available days per listing
SELECT listing_id, COUNT(*) AS available_days
FROM calendar
WHERE available = 't'
GROUP BY listing_id
ORDER BY available_days DESC;

-- 8. Average reviews per neighbourhood
SELECT neighbourhood, AVG(number_of_reviews) AS avg_reviews
FROM listings
GROUP BY neighbourhood
ORDER BY avg_reviews DESC;

-- 9. Listings with more reviews than neighbourhood average
SELECT l.*
FROM listings l
WHERE number_of_reviews > (
    SELECT AVG(number_of_reviews)
    FROM listings
    WHERE neighbourhood = l.neighbourhood
);

-- 10. Rank listings by price within neighbourhood
SELECT id, name, neighbourhood, price,
       RANK() OVER (PARTITION BY neighbourhood ORDER BY price DESC) AS price_rank
FROM listings;

-- 11. Top 3 reviewed listings per neighbourhood
SELECT *
FROM (
    SELECT id, name, neighbourhood, number_of_reviews,
           RANK() OVER (PARTITION BY neighbourhood ORDER BY number_of_reviews DESC) AS rnk
    FROM listings
) ranked
WHERE rnk <= 3;

-- 12. Listings that were available during Christmas week
SELECT DISTINCT c.listing_id, l.name
FROM calendar c
JOIN listings l ON c.listing_id = l.id
WHERE c.date BETWEEN '2018-12-24' AND '2018-12-31'
  AND c.available = 't';

-- 13. View: Price & availability summary per listing
CREATE VIEW listing_price_summary AS
SELECT l.id, l.name, l.neighbourhood,
       AVG(c.price) AS avg_calendar_price,
       COUNT(CASE WHEN c.available = 't' THEN 1 END) AS available_days
FROM listings l
JOIN calendar c ON l.id = c.listing_id
GROUP BY l.id, l.name, l.neighbourhood;

-- 14. Count number of reviews per month
SELECT DATE_TRUNC('month', date) AS review_month,
       COUNT(*) AS total_reviews
FROM reviews
GROUP BY review_month
ORDER BY review_month;

-- 15. Estimate total potential revenue per listing (price × availability)
SELECT l.id, l.name, l.price, l.availability_365,
       (l.price * l.availability_365) AS potential_revenue
FROM listings l
ORDER BY potential_revenue DESC
LIMIT 10;
