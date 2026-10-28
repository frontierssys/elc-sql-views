CREATE view PV_PRICE_DATES as
WITH cte AS (
    SELECT ROW_NUMBER() OVER (
        ORDER BY (
            SELECT NULL)) - 1 AS Incrementor
    FROM sys.all_objects
)
SELECT DATEADD(DAY, Incrementor, '2020-07-01') AS REPORT_DATE
FROM cte
WHERE DATEADD(DAY, Incrementor, '2020-07-01') < GETDATE();
