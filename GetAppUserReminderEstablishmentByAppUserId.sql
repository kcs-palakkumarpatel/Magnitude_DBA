-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,, 25,Nov 2019>
-- Description:	<Description,,GetAppUserReminderByAppUserId>
-- Call SP    :	GetAppUserReminderEstablishmentByAppUserId 4515, 488, 'Customer,Sales',2
-- =============================================
CREATE PROCEDURE [dbo].[GetAppUserReminderEstablishmentByAppUserId]
    @AppUserId BIGINT,
    @GroupId BIGINT,
    @GroupType NVARCHAR(50),
    @UserID INT
AS
BEGIN
    SELECT E.Id AS EstablishmentId,
           E.EstablishmentName,
           ISNULL(UE.EstablishmentType, EstablishmentGroupType) AS EstablishmentType,
           EstablishmentGroupType,
           E.EstablishmentGroupId,
           ISNULL(UE.Id, 0) AS Id
    FROM dbo.Establishment AS E
        INNER JOIN dbo.EstablishmentGroup AS EG
            ON E.EstablishmentGroupId = EG.Id
        LEFT OUTER JOIN dbo.AppUserReminder AS UE
            ON E.Id = UE.EstablishmentId
               AND UE.AppUserId = @AppUserId
               AND ISNULL(UE.IsDeleted, 0) = 0
    WHERE E.IsDeleted = 0
          AND (ISNULL(UE.EstablishmentType, EstablishmentGroupType) 
		  IN (
              SELECT Data FROM dbo.Split(@GroupType, ',')
              )
              )
          AND (EG.GroupId = @GroupId)
    ORDER BY EG.EstablishmentGroupType,
             EstablishmentName,
             E.EstablishmentGroupId;
END;
