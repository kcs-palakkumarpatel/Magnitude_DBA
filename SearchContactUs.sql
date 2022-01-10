-- =============================================
-- Author:		<Author,,ADMIN>
-- Create date: <Create Date,, 27 May 2015>
-- Description:	<Description,,GetContactUsAll>
-- Call SP    :	SearchContactUs 1, 1, '', ''
-- =============================================
CREATE PROCEDURE [dbo].[SearchContactUs]
    @Rows INT ,
    @Page INT ,
    @Search NVARCHAR(500) ,
    @Sort NVARCHAR(50)
AS 
    BEGIN
        DECLARE @Start AS INT ,
            @End INT
        SET @Start = ( ( @Page * @Rows ) - @Rows ) + 1
        SET @End = @Page + @Rows 
        DECLARE @Sql NVARCHAR(MAX)
        SELECT  RowNum ,
                ISNULL(Total, 0) AS Total ,
                Id ,
                CustomerName ,
                Mobile ,
                Email ,
                Comment ,
                Status
        FROM    ( SELECT    dbo.[ContactUs].[ID] AS Id ,
                            dbo.[ContactUs].[CustomerName] AS CustomerName ,
                            dbo.[ContactUs].[Mobile] AS Mobile ,
                            dbo.[ContactUs].[Email] AS Email ,
                            dbo.[ContactUs].[Comment] AS Comment ,
                            dbo.[ContactUs].[Status] AS Status ,
                            COUNT(*) OVER ( PARTITION BY 1 ) AS Total ,
                            ROW_NUMBER() OVER ( ORDER BY CASE WHEN @Sort = 'ID Asc'
                                                              THEN dbo.[ContactUs].[ID]
                                                         END ASC, CASE
                                                              WHEN @Sort = 'ID DESC'
                                                              THEN dbo.[ContactUs].[ID]
                                                              END DESC, CASE
                                                              WHEN @Sort = 'CustomerName Asc'
                                                              THEN dbo.[ContactUs].[CustomerName]
                                                              END ASC, CASE
                                                              WHEN @Sort = 'CustomerName DESC'
                                                              THEN dbo.[ContactUs].[CustomerName]
                                                              END DESC, CASE
                                                              WHEN @Sort = 'Mobile Asc'
                                                              THEN dbo.[ContactUs].[Mobile]
                                                              END ASC, CASE
                                                              WHEN @Sort = 'Mobile DESC'
                                                              THEN dbo.[ContactUs].[Mobile]
                                                              END DESC, CASE
                                                              WHEN @Sort = 'Email Asc'
                                                              THEN dbo.[ContactUs].[Email]
                                                              END ASC, CASE
                                                              WHEN @Sort = 'Email DESC'
                                                              THEN dbo.[ContactUs].[Email]
                                                              END DESC, CASE
                                                              WHEN @Sort = 'Comment Asc'
                                                              THEN dbo.[ContactUs].[Comment]
                                                              END ASC, CASE
                                                              WHEN @Sort = 'Comment DESC'
                                                              THEN dbo.[ContactUs].[Comment]
                                                              END DESC, CASE
                                                              WHEN @Sort = 'Status Asc'
                                                              THEN dbo.[ContactUs].[Status]
                                                              END ASC, CASE
                                                              WHEN @Sort = 'Status DESC'
                                                              THEN dbo.[ContactUs].[Status]
                                                              END DESC ) AS RowNum
                  FROM      dbo.[ContactUs]
                  WHERE     dbo.[ContactUs].IsDeleted = 0
                            AND ( ISNULL(dbo.[ContactUs].[CustomerName], '') LIKE '%'
                                  + @Search + '%'
                                  OR ISNULL(dbo.[ContactUs].[Mobile], '') LIKE '%'
                                  + @Search + '%'
                                  OR ISNULL(dbo.[ContactUs].[Email], '') LIKE '%'
                                  + @Search + '%'
                                  OR ISNULL(dbo.[ContactUs].[Comment], '') LIKE '%'
                                  + @Search + '%'
                                  OR ISNULL(dbo.[ContactUs].[Status], '') LIKE '%'
                                  + @Search + '%'
                                )
                ) AS T
        WHERE   RowNum BETWEEN @Start AND @End
    END