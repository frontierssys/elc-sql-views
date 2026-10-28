CREATE view PV_PRICE_DATES_BAK260116 as
WITH cte AS
    (
        SELECT ROW_NUMBER() OVER (
            ORDER BY (
                SELECT 1)) - 1 AS [Incrementor]
        FROM   [master].[sys].[columns] sc1
        CROSS JOIN [master].[sys].[columns] sc2
    )
SELECT DATEADD(DAY, cte.[Incrementor], '2022-01-01') as REPORT_DATE
FROM   cte
WHERE  DATEADD(DAY, cte.[Incrementor], '2022-01-01') < GETDATE();
