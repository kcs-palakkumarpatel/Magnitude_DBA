

-- =============================================
-- Author:		<Author,,ADMIN>
-- Create date: <Create Date,, 18 Oct 2014>
-- Description:	<Description,,GetRoleAll>
-- Call SP    :	SearchRole 1, 1, '', ''
-- =============================================
CREATE PROCEDURE [dbo].[SearchRole]
    @Rows INT ,
    @Page INT ,
    @Search NVARCHAR(500) ,
    @Sort NVARCHAR(50)
AS 
    BEGIN
        SET @Search = REPLACE(@Search, '''', '''''')
        DECLARE @Start AS INT ,
            @End INT ,
            @Total INT

        SET @Start = ( ( @Page - 1 ) * @Rows ) + 1
        SET @End = @Start + @Rows

        DECLARE @Parameter_Definition NVARCHAR(MAX) = N' @Count_out int OUTPUT '
        DECLARE @Sql NVARCHAR(MAX) ,
            @Filter NVARCHAR(MAX) ,
            @Table_Definition NVARCHAR(MAX)

        DECLARE @Result TABLE
            (
              RowNum INT NOT NULL ,
              Id BIGINT NOT NULL ,
              RoleName NVARCHAR(50) NOT NULL ,
              Description NVARCHAR(500)
            )

        SET @Sql = ' SELECT * FROM ( SELECT ROW_NUMBER() OVER (ORDER BY '
            + @Sort
            + ') as RowNum, * FROM (SELECT  dbo.[Role].[Id] AS Id , dbo.[Role].[RoleName] AS RoleName , dbo.[Role].[Description] AS Description '
        SET @Table_Definition = ' FROM dbo.[Role] 
 WHERE dbo.[Role].IsDeleted = 0 ' 

        SET @Filter = ' AND ( ISNULL(dbo.[Role].[RoleName], '''') like ''%'
            + @Search
            + '%'' OR ISNULL(dbo.[Role].[Description], '''') like ''%'
            + @Search + '%'' )'

        IF @Search <> '' 
            BEGIN
                SET @Sql += @Table_Definition + @Filter
                    + ') as T) as R WHERE R.RowNum >= '
                    + CONVERT(NVARCHAR(50), @Start) + '  AND R.RowNum < '
                    + CONVERT(NVARCHAR(50), @End) + ' '
                SET @Table_Definition += @Filter
            END
        ELSE 
            BEGIN
                SET @Sql += @Table_Definition
                    + ') as T) as R WHERE R.RowNum >= '
                    + CONVERT(NVARCHAR(50), @Start) + '  AND R.RowNum < '
                    + CONVERT(NVARCHAR(50), @End) + ' '
            END
        SET @Table_Definition = ' SELECT @Count_out = COUNT(*) '
            + @Table_Definition

        EXEC sp_executesql @Table_Definition, @Parameter_Definition,
            @Count_out = @Total OUTPUT

        INSERT  INTO @Result
                EXEC ( @Sql
                    )
        SELECT  * ,
                ISNULL(@Total, 0) AS Total
        FROM    @Result

    END