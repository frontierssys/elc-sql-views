SELECT
    s.name AS schema_name,
    v.name AS view_name,
    m.definition AS view_ddl
FROM sys.views AS v
INNER JOIN sys.schemas AS s
    ON s.schema_id = v.schema_id
INNER JOIN sys.sql_modules AS m
    ON m.object_id = v.object_id
WHERE v.is_ms_shipped = 0
  AND m.definition IS NOT NULL
ORDER BY s.name, v.name;