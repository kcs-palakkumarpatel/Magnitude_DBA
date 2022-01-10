-- =============================================
-- Author:		<Author,,Vasudev Patel>
-- Create date: <Create Date,,29 Oct 2015>
-- Description:	<Description,,>
-- Call SP:		GeneratePendingReminderCaptureTaskScheduler

-- =============================================
CREATE PROCEDURE [dbo].[GeneratePendingReminderCaptureTaskScheduler]
AS
BEGIN

    DECLARE @ServerDate DATETIME = GETUTCDATE(),
            @TimeOffSet INT = 120;

    -- RecurrenceType = 1 (Daily)
    INSERT INTO dbo.PendingEstablishmentReminder
    (
        ModuleId,
        AppUserId,
        UserDeviceId,
        EstablishmentRemindersTaskId,
        EstablishmentId,
        IsOut,
        Message,
        SentDate,
        ScheduleDate,
        IsSent,
        FormCapturedbyUser,
        CreatedOn,
        CreatedBy,
        IsDeleted,
        AppVersion,
        IsRead,
        DeviceType
    )
    SELECT 13 AS ModuleId,
           AR.AppUserId,
           UD.TokenId,
           RS.Id,
           RS.EstablishmentId,
           CASE
               WHEN AR.EstablishmentType = 'Sales' THEN
                   1
               ELSE
                   0
           END AS IsOut,
           CASE
               WHEN AR.EstablishmentType = 'Sales' THEN
                   'Hi ' + A.Name + ', reminder to submit a new capture form in ' + E.EstablishmentName + '.'
               ELSE
                   'Hi ' + A.Name + ', reminder to submit feedback for ref in ' + E.EstablishmentName + '.'
           END AS Message,
           NULL,
           DATEADD(
                      DAY,
                      DATEDIFF(DAY, 0, GETDATE()),
                      FORMAT(
                                DATEADD(
                                           MINUTE,
                                           (DATEDIFF(MINUTE, DATEADD(MINUTE, E.TimeOffSet, GETUTCDATE()), GETDATE())),
                                           RS.TimeOfReminder
                                       ),
                                'hh:mm'
                            )
                  ) AS ScheduleDate,
           0,
           0,
           GETUTCDATE(),
           1,
           0,
           UD.AppVersion,
           0,
           UD.DeviceTypeId
    FROM dbo.EstablishmentRemindersCaptureTaskTable AS RS
        INNER JOIN dbo.Establishment E
            ON E.Id = RS.EstablishmentId
        INNER JOIN dbo.AppUserReminder AR
            ON AR.EstablishmentId = E.Id
        INNER JOIN dbo.AppUser A
            ON A.Id = AR.AppUserId
        INNER JOIN dbo.UserTokenDetails UD
            ON UD.AppUserId = A.Id
    --    OUTER APPLY
    --(
    --    SELECT TOP 1
    --        *
    --    FROM dbo.PendingEstablishmentReminder
    --    WHERE RS.Id = EstablishmentRemindersTaskId
    --          AND EstablishmentId = RS.EstablishmentId
    --    ORDER BY CreatedOn DESC
    --) AS PRS
    WHERE RS.IsDeleted = 0
          AND RS.IsActive = 1
          AND RS.RecurrenceType = 1
          AND CAST(GETUTCDATE() AS DATE)
          BETWEEN RS.StartDate AND ISNULL(RS.EndDate, @ServerDate)
          --   AND CAST(DATEADD(MINUTE, -@TimeOffSet, RS.TimeOfReminder) AS TIME) < CAST(@ServerDate AS TIME)
          -- AND ISNULL(PRS.FormCapturedbyUser, 0) = 0    
          AND DATEADD(
                         DAY,
                         DATEDIFF(DAY, 0, GETDATE()),
                         FORMAT(
                                   DATEADD(
                                              MINUTE,
                                              (DATEDIFF(MINUTE, DATEADD(MINUTE, E.TimeOffSet, GETUTCDATE()), GETDATE())),
                                              RS.TimeOfReminder
                                          ),
                                   'hh:mm'
                               )
                     ) >= GETUTCDATE()
          AND NOT EXISTS
    (
        SELECT 1
        FROM PendingEstablishmentReminder P1
        WHERE P1.UserDeviceId = UD.TokenId
              AND P1.ModuleId = 13
              AND P1.AppUserId = AR.AppUserId
              AND P1.EstablishmentRemindersTaskId = RS.Id
              AND P1.EstablishmentId = RS.EstablishmentId
              AND P1.ScheduleDate = DATEADD(
                                               DAY,
                                               DATEDIFF(DAY, 0, GETDATE()),
                                               FORMAT(
                                                         DATEADD(
                                                                    MINUTE,
                                                                    (DATEDIFF(
                                                                                 MINUTE,
                                                                                 DATEADD(
                                                                                            MINUTE,
                                                                                            E.TimeOffSet,
                                                                                            GETUTCDATE()
                                                                                        ),
                                                                                 GETDATE()
                                                                             )
                                                                    ),
                                                                    RS.TimeOfReminder
                                                                ),
                                                         'hh:mm'
                                                     )
                                           )
    );

    ---- RecurrenceType = 2 (Weekly)
    INSERT INTO dbo.PendingEstablishmentReminder
    (
        ModuleId,
        AppUserId,
        UserDeviceId,
        EstablishmentRemindersTaskId,
        EstablishmentId,
        IsOut,
        Message,
        SentDate,
        ScheduleDate,
        IsSent,
        FormCapturedbyUser,
        CreatedOn,
        CreatedBy,
        IsDeleted,
        AppVersion,
        IsRead,
        DeviceType
    )
    SELECT 13 AS ModuleId,
           AR.AppUserId,
           UD.TokenId,
           RS.Id,
           RS.EstablishmentId,
           CASE
               WHEN AR.EstablishmentType = 'Sales' THEN
                   1
               ELSE
                   0
           END AS IsOut,
           CASE
               WHEN AR.EstablishmentType = 'Sales' THEN
                   'Hi ' + A.Name + ', reminder to submit a new capture form in ' + E.EstablishmentName + '.'
               ELSE
                   'Hi ' + A.Name + ' , reminder to submit feedback for ref in ' + E.EstablishmentName + '.'
           END AS Message,
           NULL,
           DATEADD(
                      DAY,
                      DATEDIFF(DAY, 0, GETDATE()),
                      FORMAT(
                                DATEADD(
                                           MINUTE,
                                           (DATEDIFF(MINUTE, DATEADD(MINUTE, E.TimeOffSet, GETUTCDATE()), GETDATE())),
                                           RS.TimeOfReminder
                                       ),
                                'hh:mm'
                            )
                  ) AS ScheduleDate,
           0,
           0,
           GETUTCDATE(),
           1,
           0,
           UD.AppVersion,
           0,
           UD.DeviceTypeId
    FROM dbo.EstablishmentRemindersCaptureTaskTable AS RS
        INNER JOIN dbo.Establishment E
            ON E.Id = RS.EstablishmentId
        INNER JOIN dbo.AppUserReminder AR
            ON AR.EstablishmentId = E.Id
        INNER JOIN dbo.AppUser A
            ON A.Id = AR.AppUserId
        INNER JOIN dbo.UserTokenDetails UD
            ON UD.AppUserId = A.Id
        OUTER APPLY dbo.Split(RS.RunOn, ',') AS D
    --    OUTER APPLY
    --(
    --    SELECT TOP 1
    --        FormCapturedbyUser
    --    FROM dbo.PendingEstablishmentReminder PR
    --        LEFT OUTER JOIN EstablishmentRemindersCaptureTaskTable ET
    --            ON ET.Id = PR.EstablishmentRemindersTaskId
    --    WHERE RS.Id = EstablishmentRemindersTaskId
    --          AND PR.EstablishmentId = RS.EstablishmentId
    --          AND DATENAME(WEEKDAY, DATEADD(MINUTE, @TimeOffSet, ET.EndDate)) = DATENAME(
    --                                                                                        WEEKDAY,
    --                                                                                        DATEADD(
    --                                                                                                   MINUTE,
    --                                                                                                   -@TimeOffSet,
    --                                                                                                   @ServerDate
    --                                                                                               )
    --                                                                                    )
    --    ORDER BY PR.CreatedOn DESC
    --) AS PRS
    WHERE RS.IsDeleted = 0
          AND RS.IsActive = 1
          AND RS.RecurrenceType = 2
          AND CAST(GETUTCDATE() AS DATE)
          BETWEEN RS.StartDate AND ISNULL(RS.EndDate, GETUTCDATE())
          AND D.Data = DATENAME(WEEKDAY, DATEADD(MINUTE, -E.TimeOffSet, @ServerDate))
          --  AND CAST(DATEADD(MINUTE, -@TimeOffSet, RS.TimeOfReminder) AS TIME) < CAST(@ServerDate AS TIME)
          --AND ISNULL(PRS.FormCapturedbyUser, 0) = 0   
		  AND DATEADD(
		                        DAY,
		                        DATEDIFF(DAY, 0, GETDATE()),
		                        FORMAT(
		                                  DATEADD(
		                                             MINUTE,
		                                             (DATEDIFF(MINUTE, DATEADD(MINUTE, E.TimeOffSet, GETUTCDATE()), GETDATE())),
		                                             RS.TimeOfReminder
		                                         ),
		                                  'hh:mm'
		                              )
		                    ) >= GETUTCDATE()       
          AND NOT EXISTS
    (
        SELECT 1
        FROM PendingEstablishmentReminder P1
        WHERE P1.UserDeviceId = UD.TokenId
              AND P1.ModuleId = 13
              AND P1.AppUserId = AR.AppUserId
              AND P1.EstablishmentRemindersTaskId = RS.Id
              AND P1.EstablishmentId = RS.EstablishmentId
              AND P1.ScheduleDate = DATEADD(
                                               DAY,
                                               DATEDIFF(DAY, 0, GETDATE()),
                                               FORMAT(
                                                         DATEADD(
                                                                    MINUTE,
                                                                    (DATEDIFF(
                                                                                 MINUTE,
                                                                                 DATEADD(
                                                                                            MINUTE,
                                                                                            E.TimeOffSet,
                                                                                            GETUTCDATE()
                                                                                        ),
                                                                                 GETDATE()
                                                                             )
                                                                    ),
                                                                    RS.TimeOfReminder
                                                                ),
                                                         'hh:mm'
                                                     )
                                           )
    );


    -- RecurrenceType = 3 (Monthly)
    INSERT INTO dbo.PendingEstablishmentReminder
    (
        ModuleId,
        AppUserId,
        UserDeviceId,
        EstablishmentRemindersTaskId,
        EstablishmentId,
        IsOut,
        Message,
        SentDate,
        ScheduleDate,
        IsSent,
        FormCapturedbyUser,
        CreatedOn,
        CreatedBy,
        IsDeleted,
        AppVersion,
        IsRead,
        DeviceType
    )
    SELECT 13 AS ModuleId,
           AR.AppUserId,
           UD.TokenId,
           RS.Id,
           RS.EstablishmentId,
           CASE
               WHEN AR.EstablishmentType = 'Sales' THEN
                   1
               ELSE
                   0
           END AS IsOut,
           CASE
               WHEN AR.EstablishmentType = 'Sales' THEN
                   'Hi ' + A.Name + ', reminder to submit a new capture form in ' + E.EstablishmentName + '.'
               ELSE
                   'Hi ' + A.Name + ', reminder to submit feedback for ref in ' + E.EstablishmentName + '.'
           END AS Message,
           NULL,
           DATEADD(
                      DAY,
                      DATEDIFF(DAY, 0, GETDATE()),
                      FORMAT(
                                DATEADD(
                                           MINUTE,
                                           (DATEDIFF(MINUTE, DATEADD(MINUTE, E.TimeOffSet, GETUTCDATE()), GETDATE())),
                                           RS.TimeOfReminder
                                       ),
                                'hh:mm'
                            )
                  ) AS ScheduleDate,
           0,
           0,
           GETUTCDATE(),
           1,
           0,
           UD.AppVersion,
           0,
           UD.DeviceTypeId
    FROM dbo.EstablishmentRemindersCaptureTaskTable AS RS
        INNER JOIN dbo.Establishment E
            ON E.Id = RS.EstablishmentId
        INNER JOIN dbo.AppUserReminder AR
            ON AR.EstablishmentId = E.Id
        INNER JOIN dbo.AppUser A
            ON A.Id = AR.AppUserId
        INNER JOIN dbo.UserTokenDetails UD
            ON UD.AppUserId = A.Id
        OUTER APPLY dbo.Split(RS.RunOn, ',') AS D
    --    OUTER APPLY
    --(
    --    SELECT TOP 1
    --        FormCapturedbyUser
    --    FROM dbo.PendingEstablishmentReminder PR
    --        LEFT OUTER JOIN EstablishmentRemindersCaptureTaskTable ET
    --            ON ET.Id = PR.EstablishmentRemindersTaskId
    --    WHERE RS.Id = EstablishmentRemindersTaskId
    --          AND PR.EstablishmentId = RS.EstablishmentId
    --          AND DATEPART(DAY, DATEADD(MINUTE, @TimeOffSet, ET.EndDate)) = DATEPART(
    --                                                                                    DAY,
    --                                                                                    DATEADD(
    --                                                                                               MINUTE,
    --                                                                                               -@TimeOffSet,
    --                                                                                               @ServerDate
    --                                                                                           )
    --                                                                                )
    --    ORDER BY PR.CreatedOn DESC
    --) AS PRS
    WHERE RS.IsDeleted = 0
          AND RS.IsActive = 1
          AND RS.RecurrenceType = 3
          AND CAST(GETUTCDATE() AS DATE)
          BETWEEN RS.StartDate AND ISNULL(RS.EndDate, GETUTCDATE())
          AND D.Data = DATEPART(DAY, DATEADD(MINUTE, -E.TimeOffSet, @ServerDate))
          --  AND CAST(DATEADD(MINUTE, -@TimeOffSet, RS.TimeOfReminder) AS TIME) < CAST(@ServerDate AS TIME)
          -- AND ISNULL(PRS.FormCapturedbyUser, 0) = 0     
		  AND DATEADD(
		                        DAY,
		                        DATEDIFF(DAY, 0, GETDATE()),
		                        FORMAT(
		                                  DATEADD(
		                                             MINUTE,
		                                             (DATEDIFF(MINUTE, DATEADD(MINUTE, E.TimeOffSet, GETUTCDATE()), GETDATE())),
		                                             RS.TimeOfReminder
		                                         ),
		                                  'hh:mm'
		                              )
		                    ) >= GETUTCDATE()     
          AND NOT EXISTS
    (
        SELECT 1
        FROM PendingEstablishmentReminder P1
        WHERE P1.UserDeviceId = UD.TokenId
              AND P1.ModuleId = 13
              AND P1.AppUserId = AR.AppUserId
              AND P1.EstablishmentRemindersTaskId = RS.Id
              AND P1.EstablishmentId = RS.EstablishmentId
              AND P1.ScheduleDate = DATEADD(
                                               DAY,
                                               DATEDIFF(DAY, 0, GETDATE()),
                                               FORMAT(
                                                         DATEADD(
                                                                    MINUTE,
                                                                    (DATEDIFF(
                                                                                 MINUTE,
                                                                                 DATEADD(
                                                                                            MINUTE,
                                                                                            E.TimeOffSet,
                                                                                            GETUTCDATE()
                                                                                        ),
                                                                                 GETDATE()
                                                                             )
                                                                    ),
                                                                    RS.TimeOfReminder
                                                                ),
                                                         'hh:mm'
                                                     )
                                           )
    );

END;


