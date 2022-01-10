-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,15 Jun 2015>
-- Description:	<Description,,>
-- Call SP:		WSGetAppUserByEmailAddress 'ghanshyam@kcs.net'
-- =============================================
CREATE PROCEDURE [dbo].[WSGetAppUserByEmailAddress]
    @EmailAddress NVARCHAR(100)
AS 
    BEGIN
        SELECT  dbo.AppUser.Id ,
                Name ,
                UserName ,
                [Password],
				Mobile,
				GroupName
        FROM    dbo.AppUser
				INNER JOIN dbo.[Group] ON [Group].Id = AppUser.GroupId
        WHERE   Email = @EmailAddress
    END