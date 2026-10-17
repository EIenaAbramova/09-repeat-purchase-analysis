-- SQLite 3. Assumption: Orders."sum" is a line amount BEFORE discount.
-- quantity is not multiplied: "sum" is already the line total.
-- All years present in Orders, including zero sales for a Paris manager.
WITH years AS (
    SELECT DISTINCT CAST(strftime('%Y', "date") AS INTEGER) AS order_year
    FROM Orders WHERE "date" IS NOT NULL
), manager_year AS (
    SELECT o.manager_id,
           CAST(strftime('%Y', o."date") AS INTEGER) AS order_year,
           SUM(o."sum" * l.discount) AS discount_amount,
           SUM(CASE WHEN l.loyalty_id IS NULL OR l.discount IS NULL
                    THEN 1 ELSE 0 END) AS unknown_discount_rows
    FROM Orders o
    LEFT JOIN Clients c ON c.client_id = o.client_id
    LEFT JOIN Loyalty l ON l.loyalty_id = c.loyalty_id
    GROUP BY o.manager_id, CAST(strftime('%Y', o."date") AS INTEGER)
)
SELECT m.manager_id, m.name, y.order_year,
       CASE WHEN a.unknown_discount_rows > 0 THEN NULL
            ELSE COALESCE(a.discount_amount, 0) END AS discount_amount,
       COALESCE(a.unknown_discount_rows, 0) AS unknown_discount_rows
FROM Managers m
CROSS JOIN years y
LEFT JOIN manager_year a
  ON a.manager_id = m.manager_id AND a.order_year = y.order_year
WHERE m.city = 'Paris'
ORDER BY m.name, m.manager_id, y.order_year;
