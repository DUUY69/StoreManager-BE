-- =============================================
-- Fix Unicode text columns (VARCHAR -> NVARCHAR)
-- Dùng khi DB cũ tạo sai kiểu cột hoặc seed sai encoding.
-- Lưu ý: Nếu dữ liệu đã bị hỏng (C� ph�) thì không thể tự khôi phục lại đúng tiếng Việt.
-- Cách đúng: chạy 01_Schema.sql (tạo lại DB) + 02_SeedData.sql sau khi đảm bảo UTF-8.
-- =============================================

USE AdminDashboard;
GO

SET NOCOUNT ON;
GO

-- Helper: chỉ ALTER khi cột đang là varchar/char/text (không đụng nvarchar/nchar/ntext)
DECLARE @sql NVARCHAR(MAX) = N'';

;WITH cols AS (
    SELECT
        s.name  AS SchemaName,
        t.name  AS TableName,
        c.name  AS ColumnName,
        ty.name AS TypeName,
        c.max_length,
        c.is_nullable
    FROM sys.columns c
    INNER JOIN sys.tables t ON t.object_id = c.object_id
    INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
    INNER JOIN sys.types ty ON ty.user_type_id = c.user_type_id
    WHERE s.name = N'dbo'
      AND t.is_ms_shipped = 0
      AND ty.name IN (N'varchar', N'char', N'text')
)
SELECT @sql = @sql +
    N'PRINT N''Fix Unicode: ' + QUOTENAME(SchemaName) + N'.' + QUOTENAME(TableName) + N'.' + QUOTENAME(ColumnName) + N' (' + TypeName + N')'';' + CHAR(13) + CHAR(10) +
    N'ALTER TABLE ' + QUOTENAME(SchemaName) + N'.' + QUOTENAME(TableName) +
    N' ALTER COLUMN ' + QUOTENAME(ColumnName) + N' NVARCHAR(' +
        CASE
            WHEN TypeName = N'text' THEN N'MAX'
            WHEN max_length <= 0 THEN N'MAX'
            ELSE CAST(CASE WHEN max_length = -1 THEN -1 ELSE (max_length) END AS NVARCHAR(20))
        END +
    N') ' + CASE WHEN is_nullable = 1 THEN N'NULL' ELSE N'NOT NULL' END + N';' + CHAR(13) + CHAR(10)
FROM cols;

IF (@sql = N'')
BEGIN
    PRINT N'No VARCHAR/CHAR/TEXT columns found. Nothing to fix.';
END
ELSE
BEGIN
    EXEC sp_executesql @sql;
    PRINT N'Unicode column fix completed.';
END
GO

