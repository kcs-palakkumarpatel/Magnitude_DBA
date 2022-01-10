
-- =============================================
-- Author:		<Vasudev Patel>
-- Create date: <17 May 2017>
-- Description:	<Get Base Count>
-- Call:	GetBaseCount 18320
-- =============================================
CREATE PROCEDURE [dbo].[GetBaseCount_111721] @AppUserId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    --    SELECT  COUNT(1) AS BaseCount
    --    FROM    dbo.PendingNotificationWeb
    --    WHERE   AppUserId = @AppUserId
    --            AND IsRead = 0
    --AND IsDeleted = 0
    --            AND ModuleId IN ( 11, 12 	);
    -- DECLARE @AppUserId BIGINT = 1

    SELECT
        (
            SELECT COUNT(1)
            FROM dbo.PendingNotificationWeb AS PNW WITH (NOLOCK)
                INNER JOIN dbo.AppUser A WITH (NOLOCK)
                    ON A.Id = PNW.AppUserId
                INNER JOIN dbo.SeenClientAnswerMaster SA WITH (NOLOCK)
                    ON SA.Id = PNW.RefId
                INNER JOIN dbo.Establishment E WITH (NOLOCK)
                    ON E.Id = SA.EstablishmentId
            WHERE PNW.AppUserId = @AppUserId
                  AND IsRead = 0
                  AND PNW.IsDeleted = 0
                  AND ModuleId = 12
                  AND E.IsDeleted = 0
                  AND SA.IsDeleted = 0
                  AND (
                          A.IsAreaManager = 1
                          OR SA.AppUserId = PNW.AppUserId
                      )
        ) +
        (
            SELECT COUNT(1)
            FROM dbo.PendingNotificationWeb AS PNW WITH (NOLOCK)
                INNER JOIN dbo.AppUser A WITH (NOLOCK)
                    ON A.Id = PNW.AppUserId
                INNER JOIN dbo.AnswerMaster AM WITH (NOLOCK)
                    ON AM.Id = PNW.RefId
                INNER JOIN dbo.Establishment E WITH (NOLOCK)
                    ON E.Id = AM.EstablishmentId
            WHERE PNW.AppUserId = @AppUserId
                  AND IsRead = 0
                  AND PNW.IsDeleted = 0
                  AND AM.IsDeleted = 0
                  AND E.IsDeleted = 0
                  AND ModuleId = 11
                  AND (
                          AM.AppUserId = 0
                          OR A.IsAreaManager = 1
                          OR AM.AppUserId = PNW.AppUserId
                      )
        ) AS BaseCount,
        (
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
        ) AS IsPasswordExpired;

    SET NOCOUNT OFF;
END;
