--SearchUserLog 1, 1, '', ''
-- =============================================
-- Author:		<Author,,ADMIN>
-- Create date: <Create Date,, 18 Oct 2014>
-- Description:	<Description,,GetUserLogAll>
-- Call SP    	SearchUserLog 1, 1, '', ''
-- =============================================
CREATE PROCEDURE [dbo].[SearchUserLog]
    @Rows INT ,
    @Page INT ,
    @Search NVARCHAR(500) ,
    @Sort NVARCHAR(50)
AS 
    BEGIN
        SET @Search = REPLACE(@Search, '''', '''''');
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
              UserId BIGINT NOT NULL ,
              UserName NVARCHAR(MAX) ,
              PageId BIGINT NOT NULL ,
              Action NVARCHAR(200) NOT NULL ,
              IpAddress NVARCHAR(50) NOT NULL ,
              AccessType NVARCHAR(50) NOT NULL ,
              Location NVARCHAR(50) NOT NULL ,
              AccessOn NVARCHAR(50) NOT NULL ,
              CreatedOn DATETIME NOT NULL
            )

        SET @Sql = ' SELECT * FROM ( SELECT ROW_NUMBER() OVER (ORDER BY '
            + @Sort
            + ') as RowNum, * FROM (SELECT  dbo.[UserLog].[Id] AS Id , dbo.[UserLog].[UserId] AS UserId , dbo.[User].UserName, dbo.[UserLog].[PageId] AS PageId , dbo.[UserLog].[Action] AS Action , dbo.[UserLog].[IpAddress] AS IpAddress , dbo.[UserLog].[AccessType] AS AccessType , dbo.[UserLog].[Location] AS Location , dbo.[UserLog].[AccessOn] AS AccessOn,  [UserLog].CreatedOn )'
        SET @Table_Definition = ' FROM dbo.[UserLog] 
INNER JOIN dbo.[User] ON dbo.[User].Id = dbo.[UserLog].UserId  WHERE dbo.[UserLog].IsDeleted = 0 ' 

        SET @Filter = ' AND (  dbo.[User].UserName like ''%' + @Search
            + '%'' OR ISNULL(dbo.[UserLog].[PageId], '''') like ''%' + @Search
            + '%'' OR ISNULL(dbo.[UserLog].[Action], '''') like ''%' + @Search
            + '%'' OR ISNULL(dbo.[UserLog].[IpAddress], '''') like ''%'
            + @Search
            + '%'' OR ISNULL(dbo.[UserLog].[AccessType], '''') like ''%'
            + @Search
            + '%'' OR ISNULL(dbo.[UserLog].[Location], '''') like ''%'
            + @Search
            + '%'' OR ISNULL(dbo.[UserLog].[AccessOn], '''') like ''%'
            + @Search
            + '%'' OR ISNULL(dbo.ChangeDateFormat([UserLog].[CreatedOn], ''dd/MM/yyyy''), '''') like ''%'
            + @Search + '%'')'

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

       

    END;