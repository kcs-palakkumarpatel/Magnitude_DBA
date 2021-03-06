
CREATE PROCEDURE [dbo].[USP_UpdateStatisticsDev]

AS

BEGIN

DECLARE @tablename varchar(80),@shemaname varchar(80)
DECLARE @SQL AS NVARCHAR(200)
DECLARE TblName_cursor CURSOR FOR
SELECT t.name,s.name FROM sys.tables t join sys.schemas s
on s.schema_id=t.schema_id


OPEN TblName_cursor

FETCH NEXT FROM TblName_cursor
INTO @tablename,@shemaname

WHILE @@FETCH_STATUS = 0
BEGIN
SET @SQL = 'UPDATE STATISTICS '+@shemaname+'.[' + @TableName + '] WITH FULLSCAN ' ---+ CONVERT(varchar(3), @sample) + ' PERCENT'

EXEC sp_executesql @statement = @SQL
--SELECT @SQL


   FETCH NEXT FROM TblName_cursor
   INTO @tablename,@shemaname
END

CLOSE TblName_cursor
DEALLOCATE TblName_cursor

END