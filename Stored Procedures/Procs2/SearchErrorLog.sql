

-- =============================================
-- Author:		<Author,,ADMIN>
-- Create date: <Create Date,, 18 Oct 2014>
-- Description:	<Description,,GetErrorLogAll>
-- Call SP    :	SearchErrorLog 1, 1, '', ''
-- =============================================
CREATE PROCEDURE [dbo].[SearchErrorLog]
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
              PageId BIGINT NOT NULL ,
              PageName NVARCHAR(MAX) ,
              MethodName NVARCHAR(200) NOT NULL ,
              ErrorType NVARCHAR(MAX) NOT NULL ,
              ErrorMessage NVARCHAR(MAX) NOT NULL ,
              ErrorDetails NVARCHAR(MAX) ,
              ErrorDate DATETIME NOT NULL ,
              UserId BIGINT NOT NULL ,
              UserName NVARCHAR(50) ,
              Solution NVARCHAR(MAX)
            )

        SET @Sql = ' SELECT * FROM ( SELECT ROW_NUMBER() OVER (ORDER BY '
            + @Sort
            + ') as RowNum, * FROM (SELECT  dbo.[ErrorLog].[Id] AS Id , dbo.[ErrorLog].[PageId] AS PageId , dbo.[Page].PageName, dbo.[ErrorLog].[MethodName] AS MethodName , dbo.[ErrorLog].[ErrorType] AS ErrorType , dbo.[ErrorLog].[ErrorMessage] AS ErrorMessage , dbo.[ErrorLog].[ErrorDetails] AS ErrorDetails , dbo.[ErrorLog].[ErrorDate] AS ErrorDate , dbo.[ErrorLog].[UserId] AS UserId, dbo.[User].UserName as UserName, dbo.[ErrorLog].[Solution] AS Solution '
        SET @Table_Definition = ' FROM dbo.[ErrorLog] 
INNER JOIN dbo.[Page] ON dbo.[Page].Id = dbo.[ErrorLog].PageId
LEFT OUTER JOIN dbo.[User] ON dbo.[User].Id = dbo.[ErrorLog].UserId  WHERE dbo.[ErrorLog].IsDeleted = 0 ' 

        SET @Filter = ' AND (  dbo.[Page].PageName like ''%' + @Search
            + '%'' OR ISNULL(dbo.[ErrorLog].[MethodName], '''') like ''%'
            + @Search
            + '%'' OR ISNULL(dbo.[ErrorLog].[ErrorType], '''') like ''%'
            + @Search
            + '%'' OR ISNULL(dbo.[ErrorLog].[ErrorMessage], '''') like ''%'
            + @Search
            + '%'' OR ISNULL(dbo.[ErrorLog].[ErrorDetails], '''') like ''%'
            + @Search
            + '%'' OR ISNULL(dbo.[ErrorLog].[ErrorDate], '''') like ''%'
            + @Search
            + '%'' OR ISNULL(dbo.[ErrorLog].[UserId], '''') like ''%'
            + @Search
            + '%'' OR ISNULL(dbo.[ErrorLog].[Solution], '''') like ''%'
            + @Search + '%'
            + '%'' OR ISNULL(dbo.[User].[UserName], '''') like ''%' + @Search
            + ')'

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