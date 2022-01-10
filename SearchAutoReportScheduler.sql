-- =============================================
-- Author:			Sunil Vaghasiya
-- Create date:	11-May-2017
-- Description:	<Description,,GetAutoReportSchedulerAll>
-- Call SP    :	SearchAutoReportScheduler 100, 1, '', 'CreatedOn asc',30
-- =============================================
CREATE PROCEDURE [dbo].[SearchAutoReportScheduler]
    @Rows INT ,
    @Page INT ,
    @Search NVARCHAR(500) ,
    @Sort NVARCHAR(50) ,
	@UserID INT
AS
    BEGIN
        DECLARE @Start AS INT ,
            @End INT,
			@AdminRole bigint ,
			@UserRole bigint ,
			@PageID bigint;

        SET @Start = ( ( @Page * @Rows ) - @Rows ) + 1;
        SET @End = @Page + @Rows; 

		SELECT TOP 1 @AdminRole = Id FROM [dbo].[Role] WHERE RoleName = 'Admin'
		SELECT TOP 1 @UserRole = RoleId FROM dbo.[User] WHERE Id = @UserID
		SELECT TOP 1 @PageID = Id FROM dbo.Page WHERE PageName = 'Common'

        DECLARE @Sql NVARCHAR(MAX);

		IF @AdminRole = @UserRole
		BEGIN

			SELECT  RowNum ,
					ISNULL(Total, 0) AS Total ,
					Id ,
					SchedulerName ,
					Description ,
					FreqTypeId ,
					CASE FreqTypeId
					  WHEN 1 THEN 'Daily'
					  WHEN 2 THEN 'Weekly'
					  WHEN 3 THEN 'Monthly'
					  ELSE 'Yearly'
					END AS FreqType ,
					FreqInterval ,
					dbo.ChangeDateFormat(StartDate, 'dd/MMM/yyyy') AS StartDate ,
					dbo.ChangeDateFormat(EndDate, 'dd/MMM/yyyy') AS EndDate ,
					dbo.ChangeDateFormat(ScheduleTime, 'HH:mm AM/PM') AS ScheduleTime ,
					DayOrDate ,
					RRule
			FROM    ( SELECT    dbo.[AutoReportScheduler].[Id] AS Id ,
								dbo.[AutoReportScheduler].[SchedulerName] AS SchedulerName ,
								dbo.[AutoReportScheduler].[Description] AS Description ,
								dbo.[AutoReportScheduler].[FreqTypeId] AS FreqTypeId ,
								dbo.[AutoReportScheduler].[FreqInterval] AS FreqInterval ,
								dbo.[AutoReportScheduler].[StartDate] AS StartDate ,
								dbo.[AutoReportScheduler].[EndDate] AS EndDate ,
								dbo.[AutoReportScheduler].[ScheduleTime] AS ScheduleTime ,
								dbo.[AutoReportScheduler].[DayOrDate] AS DayOrDate ,
								dbo.[AutoReportScheduler].[RRule] AS RRule ,
								COUNT(*) OVER ( PARTITION BY 1 ) AS Total ,
								ROW_NUMBER() OVER ( ORDER BY CASE WHEN @Sort = 'Id Asc'
																  THEN dbo.[AutoReportScheduler].[Id]
															 END , CASE
																  WHEN @Sort = 'Id DESC'
																  THEN dbo.[AutoReportScheduler].[Id]
																  END DESC, CASE
																  WHEN @Sort = 'SchedulerName Asc'
																  THEN dbo.[AutoReportScheduler].[SchedulerName]
																  END ASC, CASE
																  WHEN @Sort = 'SchedulerName DESC'
																  THEN dbo.[AutoReportScheduler].[SchedulerName]
																  END DESC, CASE
																  WHEN @Sort = 'Description Asc'
																  THEN dbo.[AutoReportScheduler].[Description]
																  END ASC, CASE
																  WHEN @Sort = 'Description DESC'
																  THEN dbo.[AutoReportScheduler].[Description]
																  END DESC, CASE
																  WHEN @Sort = 'FreqTypeId Asc'
																  THEN dbo.[AutoReportScheduler].[FreqTypeId]
																  END ASC, CASE
																  WHEN @Sort = 'FreqTypeId DESC'
																  THEN dbo.[AutoReportScheduler].[FreqTypeId]
																  END DESC, CASE
																  WHEN @Sort = 'FreqInterval Asc'
																  THEN dbo.[AutoReportScheduler].[FreqInterval]
																  END ASC, CASE
																  WHEN @Sort = 'FreqInterval DESC'
																  THEN dbo.[AutoReportScheduler].[FreqInterval]
																  END DESC, CASE
																  WHEN @Sort = 'StartDate Asc'
																  THEN dbo.[AutoReportScheduler].[StartDate]
																  END ASC, CASE
																  WHEN @Sort = 'StartDate DESC'
																  THEN dbo.[AutoReportScheduler].[StartDate]
																  END DESC, CASE
																  WHEN @Sort = 'EndDate Asc'
																  THEN dbo.[AutoReportScheduler].[EndDate]
																  END ASC, CASE
																  WHEN @Sort = 'EndDate DESC'
																  THEN dbo.[AutoReportScheduler].[EndDate]
																  END DESC, CASE
																  WHEN @Sort = 'ScheduleTime Asc'
																  THEN dbo.[AutoReportScheduler].[ScheduleTime]
																  END ASC, CASE
																  WHEN @Sort = 'ScheduleTime DESC'
																  THEN dbo.[AutoReportScheduler].[ScheduleTime]
																  END DESC, CASE
																  WHEN @Sort = 'DayOrDate Asc'
																  THEN dbo.[AutoReportScheduler].[DayOrDate]
																  END ASC, CASE
																  WHEN @Sort = 'DayOrDate DESC'
																  THEN dbo.[AutoReportScheduler].[DayOrDate]
																  END DESC, CASE
																  WHEN @Sort = 'RRule Asc'
																  THEN dbo.[AutoReportScheduler].[RRule]
																  END ASC, CASE
																  WHEN @Sort = 'RRule DESC'
																  THEN dbo.[AutoReportScheduler].[RRule]
																  END DESC, CASE
																  WHEN @Sort = 'CreatedOn Asc'
																  THEN dbo.[AutoReportScheduler].CreatedOn
																  END ASC, CASE
																  WHEN @Sort = 'CreatedOn DESC'
																  THEN dbo.[AutoReportScheduler].CreatedOn
																  END DESC ) AS RowNum
					  FROM      dbo.[AutoReportScheduler]
					  WHERE     dbo.[AutoReportScheduler].IsDeleted = 0
								AND ( ISNULL(dbo.[AutoReportScheduler].[SchedulerName],
											 '') LIKE '%' + @Search + '%'
									  OR ISNULL(dbo.[AutoReportScheduler].[Description],
												'') LIKE '%' + @Search + '%'
									  OR ISNULL(dbo.[AutoReportScheduler].[FreqTypeId],
												'') LIKE '%' + @Search + '%'
									  OR ISNULL(dbo.[AutoReportScheduler].[FreqInterval],
												'') LIKE '%' + @Search + '%'
									  OR ISNULL(dbo.ChangeDateFormat(dbo.[AutoReportScheduler].[StartDate],
																  'dd/MMM/yyyy'),
												'') LIKE '%' + @Search + '%'
									  OR ISNULL(dbo.ChangeDateFormat(dbo.[AutoReportScheduler].[EndDate],
																  'dd/MMM/yyyy'),
												'') LIKE '%' + @Search + '%'
									  OR ISNULL(dbo.ChangeDateFormat(dbo.[AutoReportScheduler].[ScheduleTime],
																  'dd/MMM/yyyy'),
												'') LIKE '%' + @Search + '%'
									  OR ISNULL(dbo.[AutoReportScheduler].[DayOrDate],
												'') LIKE '%' + @Search + '%'
									  OR ISNULL(dbo.[AutoReportScheduler].[RRule],
												'') LIKE '%' + @Search + '%'
									)
					) AS T
			WHERE   RowNum BETWEEN @Start AND @End
			ORDER BY Id DESC;
		END
		ELSE
		BEGIN

					SELECT  RowNum ,
					ISNULL(Total, 0) AS Total ,
					Id ,
					SchedulerName ,
					Description ,
					FreqTypeId ,
					CASE FreqTypeId
					  WHEN 1 THEN 'Daily'
					  WHEN 2 THEN 'Weekly'
					  WHEN 3 THEN 'Monthly'
					  ELSE 'Yearly'
					END AS FreqType ,
					FreqInterval ,
					dbo.ChangeDateFormat(StartDate, 'dd/MMM/yyyy') AS StartDate ,
					dbo.ChangeDateFormat(EndDate, 'dd/MMM/yyyy') AS EndDate ,
					dbo.ChangeDateFormat(ScheduleTime, 'HH:mm AM/PM') AS ScheduleTime ,
					DayOrDate ,
					RRule
			FROM    ( SELECT    dbo.[AutoReportScheduler].[Id] AS Id ,
								dbo.[AutoReportScheduler].[SchedulerName] AS SchedulerName ,
								dbo.[AutoReportScheduler].[Description] AS Description ,
								dbo.[AutoReportScheduler].[FreqTypeId] AS FreqTypeId ,
								dbo.[AutoReportScheduler].[FreqInterval] AS FreqInterval ,
								dbo.[AutoReportScheduler].[StartDate] AS StartDate ,
								dbo.[AutoReportScheduler].[EndDate] AS EndDate ,
								dbo.[AutoReportScheduler].[ScheduleTime] AS ScheduleTime ,
								dbo.[AutoReportScheduler].[DayOrDate] AS DayOrDate ,
								dbo.[AutoReportScheduler].[RRule] AS RRule ,
								COUNT(*) OVER ( PARTITION BY 1 ) AS Total ,
								ROW_NUMBER() OVER ( ORDER BY CASE WHEN @Sort = 'Id Asc'
																  THEN dbo.[AutoReportScheduler].[Id]
															 END ASC, CASE
																  WHEN @Sort = 'Id DESC'
																  THEN dbo.[AutoReportScheduler].[Id]
																  END DESC, CASE
																  WHEN @Sort = 'SchedulerName Asc'
																  THEN dbo.[AutoReportScheduler].[SchedulerName]
																  END ASC, CASE
																  WHEN @Sort = 'SchedulerName DESC'
																  THEN dbo.[AutoReportScheduler].[SchedulerName]
																  END DESC, CASE
																  WHEN @Sort = 'Description Asc'
																  THEN dbo.[AutoReportScheduler].[Description]
																  END ASC, CASE
																  WHEN @Sort = 'Description DESC'
																  THEN dbo.[AutoReportScheduler].[Description]
																  END DESC, CASE
																  WHEN @Sort = 'FreqTypeId Asc'
																  THEN dbo.[AutoReportScheduler].[FreqTypeId]
																  END ASC, CASE
																  WHEN @Sort = 'FreqTypeId DESC'
																  THEN dbo.[AutoReportScheduler].[FreqTypeId]
																  END DESC, CASE
																  WHEN @Sort = 'FreqInterval Asc'
																  THEN dbo.[AutoReportScheduler].[FreqInterval]
																  END ASC, CASE
																  WHEN @Sort = 'FreqInterval DESC'
																  THEN dbo.[AutoReportScheduler].[FreqInterval]
																  END DESC, CASE
																  WHEN @Sort = 'StartDate Asc'
																  THEN dbo.[AutoReportScheduler].[StartDate]
																  END ASC, CASE
																  WHEN @Sort = 'StartDate DESC'
																  THEN dbo.[AutoReportScheduler].[StartDate]
																  END DESC, CASE
																  WHEN @Sort = 'EndDate Asc'
																  THEN dbo.[AutoReportScheduler].[EndDate]
																  END ASC, CASE
																  WHEN @Sort = 'EndDate DESC'
																  THEN dbo.[AutoReportScheduler].[EndDate]
																  END DESC, CASE
																  WHEN @Sort = 'ScheduleTime Asc'
																  THEN dbo.[AutoReportScheduler].[ScheduleTime]
																  END ASC, CASE
																  WHEN @Sort = 'ScheduleTime DESC'
																  THEN dbo.[AutoReportScheduler].[ScheduleTime]
																  END DESC, CASE
																  WHEN @Sort = 'DayOrDate Asc'
																  THEN dbo.[AutoReportScheduler].[DayOrDate]
																  END ASC, CASE
																  WHEN @Sort = 'DayOrDate DESC'
																  THEN dbo.[AutoReportScheduler].[DayOrDate]
																  END DESC, CASE
																  WHEN @Sort = 'RRule Asc'
																  THEN dbo.[AutoReportScheduler].[RRule]
																  END ASC, CASE
																  WHEN @Sort = 'RRule DESC'
																  THEN dbo.[AutoReportScheduler].[RRule]
																  END DESC, CASE
																  WHEN @Sort = 'CreatedOn Asc'
																  THEN dbo.[AutoReportScheduler].CreatedOn
																  END ASC, CASE
																  WHEN @Sort = 'CreatedOn DESC'
																  THEN dbo.[AutoReportScheduler].CreatedOn
																  END DESC ) AS RowNum
					  FROM      dbo.[AutoReportScheduler]
					  --INNER JOIN dbo.UserRolePermissions ON dbo.UserRolePermissions.PageID = @PageID
						 --AND dbo.UserRolePermissions.ActualID = dbo.AutoReportScheduler.Id
					  WHERE     dbo.[AutoReportScheduler].IsDeleted = 0 
								AND Createdby = @UserID
								AND ( ISNULL(dbo.[AutoReportScheduler].[SchedulerName],
											 '') LIKE '%' + @Search + '%'
									  OR ISNULL(dbo.[AutoReportScheduler].[Description],
												'') LIKE '%' + @Search + '%'
									  OR ISNULL(dbo.[AutoReportScheduler].[FreqTypeId],
												'') LIKE '%' + @Search + '%'
									  OR ISNULL(dbo.[AutoReportScheduler].[FreqInterval],
												'') LIKE '%' + @Search + '%'
									  OR ISNULL(dbo.ChangeDateFormat(dbo.[AutoReportScheduler].[StartDate],
																  'dd/MMM/yyyy'),
												'') LIKE '%' + @Search + '%'
									  OR ISNULL(dbo.ChangeDateFormat(dbo.[AutoReportScheduler].[EndDate],
																  'dd/MMM/yyyy'),
												'') LIKE '%' + @Search + '%'
									  OR ISNULL(dbo.ChangeDateFormat(dbo.[AutoReportScheduler].[ScheduleTime],
																  'dd/MMM/yyyy'),
												'') LIKE '%' + @Search + '%'
									  OR ISNULL(dbo.[AutoReportScheduler].[DayOrDate],
												'') LIKE '%' + @Search + '%'
									  OR ISNULL(dbo.[AutoReportScheduler].[RRule],
												'') LIKE '%' + @Search + '%'
									)
					) AS T
			WHERE   RowNum BETWEEN @Start AND @End
			ORDER BY Id DESC;

		END
    END;
