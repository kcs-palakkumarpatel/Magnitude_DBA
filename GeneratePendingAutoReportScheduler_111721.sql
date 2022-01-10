
-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,29 Oct 2015>
-- Description:	<Description,,>
-- Call SP:		GeneratePendingAutoReportScheduler
-- =============================================
CREATE PROCEDURE [dbo].[GeneratePendingAutoReportScheduler_111721]
AS
    BEGIN
	
        DECLARE @ServerDate DATETIME = GETUTCDATE() ,
            @TimeOffSet INT = 120;
		
        --SELECT  @ServerDate ,
        --        DATENAME(WEEKDAY, @ServerDate);

        INSERT  INTO dbo.PendingAutoReportingScheduler
                ( EstablishmentGroupId ,
                  AutoReportSchedulerId ,
                  FromDate ,
                  ToDate ,
                  ScheduleDate ,
                  EmailId
                )
                SELECT  Eg.Id AS ActivityId ,
                        RS.Id AS SchedulerId ,
                        CAST(ISNULL(( SELECT TOP 1
                                                ToDate
                                      FROM      PendingAutoReportingScheduler
                                      WHERE     EstablishmentGroupId = Eg.Id
                                      ORDER BY  CreatedOn DESC
                                    ), RS.StartDate) AS DATE) AS FromDate ,
                        CAST(@ServerDate AS DATE) AS ToDate ,
                        --CAST(dbo.ChangeDateFormat(@ServerDate, 'dd MMM yyyy')
						CAST(dbo.ChangeDateFormat(GETDATE(), 'dd MMM yyyy')
                        + ' ' + dbo.ChangeDateFormat(DATEADD(MINUTE,
                                                              (DATEDIFF(MINUTE,DATEADD(MINUTE,@TimeOffSet,GETUTCDATE()),GETDATE())),
                                                             RS.ScheduleTime),
                                                     'hh:mm AM/PM') AS DATETIME) AS ScheduleTime ,
                        Eg.ReportingToEmail
                FROM    dbo.EstablishmentGroup AS Eg
                        INNER JOIN dbo.AutoReportScheduler AS RS ON RS.Id = Eg.AutoReportSchedulerId
                        OUTER APPLY ( SELECT TOP 1
                                                *
                                      FROM      dbo.PendingAutoReportingScheduler
                                      WHERE     AutoReportSchedulerId = Eg.AutoReportSchedulerId
                                                AND EstablishmentGroupId = Eg.Id
                                      ORDER BY  CreatedOn DESC
                                    ) AS PRS
                WHERE   Eg.IsDeleted = 0
                        AND RS.IsDeleted = 0
                        AND Eg.AutoReportEnable = 1
                        AND RS.FreqTypeId = 1
                        AND CAST(GETUTCDATE() AS DATE) BETWEEN RS.StartDate
                                                       AND    ISNULL(RS.EndDate,
                                                              GETUTCDATE())
                        AND DATEDIFF(DAY, ISNULL(PRS.ToDate, RS.StartDate),
                                     @ServerDate) >= RS.FreqInterval
						AND CAST(DATEADD(MINUTE, -@TimeOffSet, RS.ScheduleTime) AS TIME) <= CAST(@ServerDate AS TIME)
                        --AND CAST(DATEADD(MINUTE, @TimeOffSet, RS.ScheduleTime) AS TIME) <= CAST(@ServerDate AS TIME)
                        AND CAST(ISNULL(PRS.CreatedOn, RS.StartDate) AS DATE) <> CAST(@ServerDate AS DATE);

        INSERT  INTO dbo.PendingAutoReportingScheduler
                ( EstablishmentGroupId ,
                  AutoReportSchedulerId ,
                  FromDate ,
                  ToDate ,
                  ScheduleDate ,
                  EmailId
                )
                SELECT  Eg.Id AS ActivityId ,
                        RS.Id AS SchedulerId ,
                        CAST(ISNULL(( SELECT TOP 1
                                                ToDate
                                      FROM      PendingAutoReportingScheduler
                                      WHERE     EstablishmentGroupId = Eg.Id
                                      ORDER BY  CreatedOn DESC
                                    ), RS.StartDate) AS DATE) AS FromDate ,
                        CAST(@ServerDate AS DATE) AS ToDate ,
                        CAST(dbo.ChangeDateFormat(@ServerDate, 'dd MMM yyyy')
                        + ' ' + dbo.ChangeDateFormat(DATEADD(MINUTE,
                                                             -@TimeOffSet,
                                                             RS.ScheduleTime),
                                                     'hh:mm AM/PM') AS DATETIME) AS ScheduleTime ,
                        Eg.ReportingToEmail
                FROM    dbo.EstablishmentGroup AS Eg
                        INNER JOIN dbo.AutoReportScheduler AS RS ON RS.Id = Eg.AutoReportSchedulerId
                        OUTER APPLY dbo.Split(RS.DayOrDate, ',') AS D
                        OUTER APPLY ( SELECT TOP 1
                                                *
                                      FROM      dbo.PendingAutoReportingScheduler
                                      WHERE     AutoReportSchedulerId = Eg.AutoReportSchedulerId
                                                AND EstablishmentGroupId = Eg.Id
                                                AND DATENAME(WEEKDAY,
                                                             DATEADD(MINUTE,
                                                              @TimeOffSet,
                                                              ToDate)) = DATENAME(WEEKDAY,
                                                              DATEADD(MINUTE,
                                                              -@TimeOffSet,
                                                              @ServerDate))
                                      ORDER BY  CreatedOn DESC
                                    ) AS PRS
                WHERE   Eg.IsDeleted = 0
                        AND RS.IsDeleted = 0
                        AND Eg.AutoReportEnable = 1
                        AND RS.FreqTypeId = 2
                        AND CAST(GETUTCDATE() AS DATE) BETWEEN RS.StartDate
                                                       AND    ISNULL(RS.EndDate,
                                                              GETUTCDATE())
                        AND D.Data = DATENAME(WEEKDAY,
                                              DATEADD(MINUTE, -@TimeOffSet,
                                                      @ServerDate))
                        AND DATEDIFF(WEEK, ISNULL(PRS.ToDate, RS.StartDate),
                                     @ServerDate) > RS.FreqInterval
                        AND CAST(DATEADD(MINUTE, -@TimeOffSet, RS.ScheduleTime) AS TIME) <= CAST(@ServerDate AS TIME)
                        AND CAST(ISNULL(PRS.CreatedOn, RS.StartDate) AS DATE) <> CAST(@ServerDate AS DATE);

        INSERT  INTO dbo.PendingAutoReportingScheduler
                ( EstablishmentGroupId ,
                  AutoReportSchedulerId ,
                  FromDate ,
                  ToDate ,
                  ScheduleDate ,
                  EmailId
                )
                SELECT  Eg.Id AS ActivityId ,
                        RS.Id AS SchedulerId ,
                        CAST(ISNULL(( SELECT TOP 1
                                                ToDate
                                      FROM      PendingAutoReportingScheduler
                                      WHERE     EstablishmentGroupId = Eg.Id
                                      ORDER BY  CreatedOn DESC
                                    ), RS.StartDate) AS DATE) AS FromDate ,
                        CAST(@ServerDate AS DATE) AS ToDate ,
                        CAST(dbo.ChangeDateFormat(@ServerDate, 'dd MMM yyyy')
                        + ' ' + dbo.ChangeDateFormat(DATEADD(MINUTE,
                                                             -@TimeOffSet,
                                                             RS.ScheduleTime),
                                                     'hh:mm AM/PM') AS DATETIME) AS ScheduleTime ,
                        Eg.ReportingToEmail
                FROM    dbo.EstablishmentGroup AS Eg
                        INNER JOIN dbo.AutoReportScheduler AS RS ON RS.Id = Eg.AutoReportSchedulerId
                        OUTER APPLY dbo.Split(RS.DayOrDate, ',') AS D
                        OUTER APPLY ( SELECT TOP 1
                                                *
                                      FROM      dbo.PendingAutoReportingScheduler
                                      WHERE     AutoReportSchedulerId = Eg.AutoReportSchedulerId
                                                AND EstablishmentGroupId = Eg.Id
                                                AND DATEPART(DAY,
                                                             DATEADD(MINUTE,
                                                              @TimeOffSet,
                                                              ToDate)) = DATEPART(DAY,
                                                              DATEADD(MINUTE,
                                                              -@TimeOffSet,
                                                              @ServerDate))
                                      ORDER BY  CreatedOn DESC
                                    ) AS PRS
                WHERE   Eg.IsDeleted = 0
                        AND RS.IsDeleted = 0
                        AND Eg.AutoReportEnable = 1
                        AND RS.FreqTypeId = 3
                        AND CAST(GETUTCDATE() AS DATE) BETWEEN RS.StartDate
                                                       AND    ISNULL(RS.EndDate,
                                                              GETUTCDATE())
                        AND D.Data = DATEPART(DAY,
                                              DATEADD(MINUTE, -@TimeOffSet,
                                                      @ServerDate))
                        AND DATEDIFF(DAY, ISNULL(PRS.ToDate, RS.StartDate),
                                     @ServerDate) > RS.FreqInterval
                        AND CAST(DATEADD(MINUTE, -@TimeOffSet, RS.ScheduleTime) AS TIME) <= CAST(@ServerDate AS TIME)
                        AND CAST(ISNULL(PRS.CreatedOn, RS.StartDate) AS DATE) <> CAST(@ServerDate AS DATE);

    END;
