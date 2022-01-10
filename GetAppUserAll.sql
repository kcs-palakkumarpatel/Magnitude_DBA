-- =============================================
-- Author:		<Author,,ADMIN>
-- Create date: <Create Date,, 09 Jun 2015>
-- Description:	<Description,,GetAppUserAll>
-- Call SP    :	GetAppUserAll
-- =============================================
CREATE PROCEDURE [dbo].[GetAppUserAll]
AS 
    BEGIN
        SELECT  dbo.[AppUser].[Id] AS Id ,
                dbo.[AppUser].[Name] AS Name ,
                dbo.[AppUser].[Email] AS Email ,
                dbo.[AppUser].[Mobile] AS Mobile ,
                dbo.[AppUser].[IsAreaManager] AS IsAreaManager ,
                ISNULL(dbo.[AppUser].[SupplierId], 0) AS SupplierId ,
                dbo.[AppUser].[UserName] AS UserName ,
                dbo.[AppUser].[Password] AS Password ,
                dbo.[AppUser].[GroupId] AS GroupId,
				dbo.[AppUser].[IsActive] AS IsActive
        FROM    dbo.[AppUser]
        WHERE   dbo.[AppUser].IsDeleted = 0
    END