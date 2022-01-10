-- =============================================
-- Author:			D2
-- Create date:	06-Sep-2017
-- Description:	
-- Call:					dbo.GetUserNotificationCount 467
-- =============================================
CREATE PROCEDURE [dbo].[GetUserNotificationCount_Original] @AppUserId BIGINT
AS
BEGIN
    DECLARE @ActivityId VARCHAR(MAX) = '0',
            @listStr VARCHAR(MAX);

    IF (@ActivityId = '0')
    BEGIN
        SELECT @listStr = COALESCE(@listStr + ', ', '') + CONVERT(NVARCHAR(50), ES.EstablishmentGroupId)
        FROM dbo.Establishment AS ES
            INNER JOIN dbo.AppUserEstablishment
                ON AppUserEstablishment.EstablishmentId = ES.Id
        WHERE dbo.AppUserEstablishment.AppUserId = @AppUserId
        GROUP BY ES.EstablishmentGroupId;

        SET @ActivityId = @listStr;
    END;

    SELECT COUNT(P.Id) AS NotificationCount
    FROM dbo.PendingNotificationWeb P
        LEFT JOIN dbo.AnswerMaster AM
            ON P.RefId = AM.Id
               AND (
                       P.ModuleId = 2
                       OR P.ModuleId = 5
                       OR P.ModuleId = 7
                       OR P.ModuleId = 11
                   )
               AND AM.IsDeleted = 0
        LEFT JOIN dbo.SeenClientAnswerMaster SAM
            ON P.RefId = SAM.Id
               AND (
                       P.ModuleId = 3
                       OR P.ModuleId = 6
                       OR P.ModuleId = 8
                       OR P.ModuleId = 12
                   )
               AND SAM.IsDeleted = 0
        LEFT JOIN dbo.Establishment E
            ON E.Id = AM.EstablishmentId
               OR E.Id = SAM.EstablishmentId
        INNER JOIN dbo.AppUser A
            ON P.AppUserId = A.Id
    WHERE P.IsRead = 0
          AND P.IsDeleted = 0
          AND E.IsDeleted = 0
          AND P.AppUserId = @AppUserId
          AND P.ScheduleDate <= GETUTCDATE()
          AND E.EstablishmentGroupId IN (
                                            SELECT Data FROM Split(@ActivityId, ',')
                                        );

END;
