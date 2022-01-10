-- =============================================
-- Author:			Sunil Vaghasiya
-- Create date:	10-Mar-2017
-- Description:	Get notification list for webapp by userid>
-- Call SP:			dbo.CountPendingNotificationWebByUserId 1445,2245
--					GetPendingNotificationWebListByUserId 313,919
-- =============================================
CREATE PROCEDURE [dbo].[CountPendingNotificationWebByUserId]
    @AppUserId BIGINT,
	@ActivityId BIGINT
AS
    BEGIN

	SELECT COUNT(1) AS NotificationCount FROM (SELECT  P.Id ,
                ModuleId ,
                [Message],
                dbo.ChangeDateFormat(ScheduleDate, 'MM/dd/yyyy hh:mm AM/PM') AS ScheduleDate ,
                RefId ,
                P.AppUserId ,
                IsRead ,
                E.EstablishmentGroupId ,
                dbo.ChangeDateFormat(DATEADD(MINUTE,
                                             CASE WHEN ( P.ModuleId = 2
                                                         OR P.ModuleId = 5
                                                         OR P.ModuleId = 7
														 OR p.ModuleId = 11
                                                       ) THEN AM.TimeOffSet
                                                  WHEN ( P.ModuleId = 3
                                                         OR P.ModuleId = 6
														  OR p.ModuleId = 8
														  OR p.ModuleId = 12
                                                       ) THEN SAM.TimeOffSet
                                                  ELSE AM.TimeOffSet
                                             END, P.CreatedOn), 'MM/dd/yyyy hh:mm AM/PM') AS CreatedDate ,
                CASE WHEN P.ModuleId = 2 THEN 'Feedback Alert'
                     WHEN P.ModuleId = 3 THEN 'Capture Alert'
                     WHEN P.ModuleId = 5 THEN 'Reminder for Feedback'
                     WHEN P.ModuleId = 6 THEN 'Reminder for Captured Feedback'
                     WHEN P.ModuleId = 7 THEN 'Form Transferred'
					 WHEN P.ModuleId = 8 THEN 'Form Transferred'
					 WHEN P.ModuleId = 11 THEN 'Action Alert'
					 WHEN P.ModuleId = 12 THEN 'Action Alert'
                     ELSE ''
                END AS AlertTitle,
				E.EstablishmentName,
				A.Name AS UserName,
				ISNULL((SELECT CASE P.CreatedBy WHEN 0 THEN 'Customer' ELSE Name END FROM dbo.AppUser WHERE Id=ISNULL(P.CreatedBy,0)), '') AS  OriginatorName
        FROM    dbo.PendingNotificationWeb P
                LEFT JOIN dbo.AnswerMaster AM ON P.RefId = AM.Id
                                                 AND ( P.ModuleId = 2
                                                       OR P.ModuleId = 5
                                                       OR P.ModuleId = 7
													    OR p.ModuleId = 11
                                                     )
                                                 AND AM.IsDeleted = 0
                LEFT JOIN dbo.SeenClientAnswerMaster SAM ON P.RefId = SAM.Id
                                                            AND ( P.ModuleId = 3
																OR p.ModuleId = 2
                                                              OR P.ModuleId = 6
															  OR p.ModuleId = 8
															   OR p.ModuleId = 12
                                                              )
                                                            AND SAM.IsDeleted = 0
                LEFT JOIN dbo.Establishment E ON E.Id = AM.EstablishmentId
                                                 OR E.Id = SAM.EstablishmentId
				INNER JOIN dbo.AppUser A ON p.AppUserId = A.Id
        WHERE   P.IsDeleted = 0
                AND E.IsDeleted = 0
                AND P.AppUserId = @AppUserId
                AND E.EstablishmentGroupId = @ActivityId
                AND P.ScheduleDate <= GETUTCDATE()) AS N WHERE N.IsRead = 0
        


    END;
