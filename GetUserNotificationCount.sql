
-- =============================================
-- Author:			D2
-- Create date:	06-Sep-2017
-- Description:	
-- Call:					dbo.GetUserNotificationCount 5195
-- =============================================
CREATE PROCEDURE [dbo].[GetUserNotificationCount] @AppUserId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
    DECLARE @ActivityId VARCHAR(MAX) = '0',
            @ActivityId1 VARCHAR(MAX) = '0',
            @listStr VARCHAR(MAX),
            @listStr1 VARCHAR(MAX);

    IF (@ActivityId = '0')
    BEGIN
        SELECT @listStr = COALESCE(@listStr + ', ', '') + CONVERT(NVARCHAR(50), ES.EstablishmentGroupId)
        FROM dbo.Establishment AS ES WITH (NOLOCK)
            INNER JOIN dbo.AppUserEstablishment WITH (NOLOCK)
                ON AppUserEstablishment.EstablishmentId = ES.Id
        WHERE dbo.AppUserEstablishment.AppUserId = @AppUserId
        GROUP BY ES.EstablishmentGroupId;
        SET @ActivityId = @listStr;

        SELECT @listStr1 = COALESCE(@listStr1 + ', ', '') + CONVERT(NVARCHAR(50), ES.EstablishmentGroupId)
        FROM dbo.Establishment AS ES WITH (NOLOCK)
            INNER JOIN dbo.AppUserReminder WITH (NOLOCK)
                ON AppUserReminder.EstablishmentId = ES.Id
        WHERE dbo.AppUserReminder.AppUserId = @AppUserId
        GROUP BY ES.EstablishmentGroupId;

        SET @ActivityId1 = @listStr1;
    END;
    DECLARE @IsPasswordExpired BIT
        =   (
                SELECT TOP (1)
                    IIF(
                        (
                            G.[PWExpireNowOn] IS NOT NULL
                            AND AUPL.CreatedOn IS NULL
                        )
                        OR G.[PWExpireNowOn] > AUPL.CreatedOn
                        OR (
                               G.[PWExpiredDays] > 0
                               AND (
                                       AUPL.CreatedOn IS NULL
                                       OR DATEADD(DAY, G.[PWExpiredDays], AUPL.CreatedOn) < GETUTCDATE()
                                   )
                           ),
                        1,
                        0) AS IsPasswordExpired
                FROM dbo.AppUser AU WITH (NOLOCK)
                    JOIN dbo.[Group] AS G WITH (NOLOCK)
                        ON G.Id = AU.GroupId
                    LEFT JOIN dbo.AppUserPasswordLog AS AUPL WITH (NOLOCK)
                        ON AUPL.UserId = AU.Id
                WHERE AU.Id = @AppUserId
                ORDER BY AUPL.CreatedOn DESC
            );
    SELECT
        (
            SELECT COUNT(1)
            FROM
            (
                SELECT P.Id AS NotificationCount
                FROM dbo.PendingNotificationWeb P WITH (NOLOCK)
                    LEFT JOIN dbo.AnswerMaster AM WITH (NOLOCK)
                        ON P.RefId = AM.Id
                           AND (
                                   P.ModuleId = 2
                                   OR P.ModuleId = 5
                                   OR P.ModuleId = 7
                                   OR P.ModuleId = 11
                               )
                           AND AM.IsDeleted = 0
                    LEFT JOIN dbo.SeenClientAnswerMaster SAM WITH (NOLOCK)
                        ON P.RefId = SAM.Id
                           AND (
                                   P.ModuleId = 3
                                   OR P.ModuleId = 6
                                   OR P.ModuleId = 8
                                   OR P.ModuleId = 12
                               )
                           AND SAM.IsDeleted = 0
                    LEFT JOIN dbo.Establishment E WITH (NOLOCK)
                        ON E.Id = AM.EstablishmentId
                           OR E.Id = SAM.EstablishmentId
                    INNER JOIN dbo.AppUser A WITH (NOLOCK)
                        ON P.AppUserId = A.Id
                WHERE P.IsRead = 0
                      AND P.IsDeleted = 0
                      AND E.IsDeleted = 0
                      AND P.AppUserId = @AppUserId
                      AND P.ScheduleDate <= GETUTCDATE()
                      AND E.EstablishmentGroupId IN (
                                                        SELECT Data FROM Split(@ActivityId, ',')
                                                    )
                UNION ALL
                SELECT Id
                FROM
                (
                    SELECT P.Id,
                           ROW_NUMBER() OVER (PARTITION BY P.EstablishmentId,
                                                           P.AppUserId,
                                                           CAST(P.SentDate AS DATE)
                                              ORDER BY P.SentDate DESC
                                             ) RNum
                    FROM dbo.PendingEstablishmentReminder P WITH (NOLOCK)
                        LEFT JOIN dbo.Establishment E WITH (NOLOCK)
                            ON E.Id = P.EstablishmentId
                        INNER JOIN dbo.AppUser A WITH (NOLOCK)
                            ON P.AppUserId = A.Id
                    WHERE P.IsRead = 0
                          AND P.IsDeleted = 0
                          AND E.IsDeleted = 0
                          AND P.AppUserId = @AppUserId
                          --AND P.ScheduleDate <= GETUTCDATE()
                          AND E.EstablishmentGroupId IN (
                                                            SELECT Data FROM dbo.Split(@ActivityId1, ',')
                                                        )
                ) b
                WHERE b.RNum = 1
            ) a
        ) AS NotificationCount,
        (@IsPasswordExpired) AS IsPasswordExpired;
		END TRY

BEGIN CATCH
	INSERT INTO dbo.ErrorLog
        (
            PageId,
            MethodName,
            ErrorType,
            ErrorMessage,
            ErrorDetails,
            ErrorDate,
            UserId,
            Solution,
            CreatedOn,
            CreatedBy
        )
        VALUES
        (ERROR_LINE(),
         'dbo.GetUserNotificationCount',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         ISNULL(@AppUserId,0),
         @AppUserId,
         GETUTCDATE(),
         ISNULL(@AppUserId,0)
        );
END CATCH
    SET NOCOUNT OFF;
END;
