-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,22 Jun 2015>
-- Description:	<Description,,>
-- Call SP:		WSUpdateNotificationStatus
-- =============================================
CREATE PROCEDURE [dbo].[WSUpdateNotificationStatus]
    @strActivityOnId NVARCHAR(MAX) ,
    @strActivityOffId NVARCHAR(MAX) ,
    @AppUserId BIGINT
AS
    BEGIN
        UPDATE  UE
        SET     NotificationStatus = 1, UE.UpdatedOn = GETUTCDATE()
        FROM    dbo.AppUserEstablishment AS UE
                INNER JOIN dbo.Establishment AS E ON UE.EstablishmentId = E.Id
        WHERE   E.EstablishmentGroupId IN (
                SELECT  Data
                FROM    dbo.Split(@strActivityOnId, ',') )
                AND E.IsDeleted = 0
                AND UE.IsDeleted = 0
                AND UE.AppUserId = @AppUserId;
        
        UPDATE  UE
        SET     NotificationStatus = 0, UE.UpdatedOn = GETUTCDATE()
        FROM    dbo.AppUserEstablishment AS UE
                INNER JOIN dbo.Establishment AS E ON UE.EstablishmentId = E.Id
        WHERE   E.EstablishmentGroupId IN (
                SELECT  Data
                FROM    dbo.Split(@strActivityOffId, ',') )
                AND E.IsDeleted = 0
                AND UE.IsDeleted = 0
                AND UE.AppUserId = @AppUserId;
        RETURN 1;
    END;