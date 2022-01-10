

-- =============================================
-- Author:		<Author,,ADMIN>
-- Create date: <Create Date,, 18 Oct 2014>
-- Description:	<Description,,GetEmailLogAll>
-- Call SP    :	SearchEmailLog 1, 1, '', ''
-- =============================================
CREATE PROCEDURE [dbo].[SearchEmailLog]
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
              RelaventId BIGINT ,
              ModuleId BIGINT NOT NULL ,
              ModuleName NVARCHAR(MAX) ,
              MailContent NVARCHAR(MAX) NOT NULL ,
              MailTo NVARCHAR(MAX) NOT NULL ,
              CC NVARCHAR(MAX) ,
              BCC NVARCHAR(MAX) ,
              SentOn DATETIME NOT NULL
            )

        SET @Sql = ' SELECT * FROM ( SELECT ROW_NUMBER() OVER (ORDER BY '
            + @Sort
            + ') as RowNum, * FROM (SELECT  dbo.[EmailLog].[Id] AS Id , dbo.[EmailLog].[RelaventId] AS RelaventId , dbo.[EmailLog].[ModuleId] AS ModuleId , dbo.[Module].ModuleName, dbo.[EmailLog].[MailContent] AS MailContent , dbo.[EmailLog].[MailTo] AS MailTo , dbo.[EmailLog].[CC] AS CC , dbo.[EmailLog].[BCC] AS BCC , dbo.[EmailLog].[SentOn] AS SentOn '
        SET @Table_Definition = ' FROM dbo.[EmailLog] 
INNER JOIN dbo.[Module] ON dbo.[Module].Id = dbo.[EmailLog].ModuleId  WHERE dbo.[EmailLog].IsDeleted = 0 ' 

        SET @Filter = ' AND ( ISNULL(dbo.[EmailLog].[RelaventId], '''') like ''%'
            + @Search + '%'' OR  dbo.[Module].ModuleName like ''%' + @Search
            + '%'' OR ISNULL(dbo.[EmailLog].[MailContent], '''') like ''%'
            + @Search
            + '%'' OR ISNULL(dbo.[EmailLog].[MailTo], '''') like ''%'
            + @Search + '%'' OR ISNULL(dbo.[EmailLog].[CC], '''') like ''%'
            + @Search + '%'' OR ISNULL(dbo.[EmailLog].[BCC], '''') like ''%'
            + @Search
            + '%'' OR ISNULL(dbo.[EmailLog].[SentOn], '''') like ''%'
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