-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,10 Jun 2015>
-- Description:	<Description,,>
-- Call SP:		DeleteAppUserEstablishment
-- =============================================
CREATE PROCEDURE [dbo].[DeleteAppUserEstablishment]
    @AppUserId BIGINT ,
    @DeletedBy BIGINT
AS 
    BEGIN
        UPDATE  dbo.AppUserEstablishment
        SET     IsDeleted = 1 ,
                DeletedOn = GETUTCDATE() ,
                DeletedBy = @DeletedBy
        WHERE   AppUserId = @AppUserId
                AND IsDeleted = 0

		
         UPDATE dbo.AppManagerUserRights
         SET    IsDeleted = 1 ,
                DeletedOn = GETUTCDATE() ,
                DeletedBy = @DeletedBy
         WHERE  UserId = @AppUserId;
    END