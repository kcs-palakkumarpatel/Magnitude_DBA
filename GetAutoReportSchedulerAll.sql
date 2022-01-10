-- =============================================
-- Author:		<Author,,ADMIN>
-- Create date: <Create Date,, 20 Oct 2015>
-- Description:	<Description,,GetAutoReportSchedulerAll>
-- Call SP    :	GetAutoReportSchedulerAll 74
-- =============================================
CREATE PROCEDURE [dbo].[GetAutoReportSchedulerAll]
	@UserID INT
AS
    BEGIN
	
		DECLARE @AdminRole bigint ,
		@UserRole bigint ,
		@PageID bigint

		SELECT TOP 1 @AdminRole = Id FROM [dbo].[Role] WHERE RoleName = 'Admin'
		SELECT TOP 1 @UserRole = RoleId FROM dbo.[User] WHERE Id = @UserId
		SELECT TOP 1 @PageID = Id FROM dbo.Page WHERE PageName = 'Common'

		IF @AdminRole = @UserRole
		BEGIN
			SELECT  dbo.[AutoReportScheduler].[Id] AS Id ,
					dbo.[AutoReportScheduler].[SchedulerName] AS SchedulerName ,
					ISNULL(dbo.[AutoReportScheduler].[Description],'') AS Description ,
					dbo.[AutoReportScheduler].[FreqTypeId] AS FreqTypeId ,
					dbo.[AutoReportScheduler].[FreqInterval] AS FreqInterval ,
					dbo.[AutoReportScheduler].[StartDate] AS StartDate ,
					dbo.[AutoReportScheduler].[EndDate] AS EndDate ,
					dbo.[AutoReportScheduler].[ScheduleTime] AS ScheduleTime ,
					dbo.[AutoReportScheduler].[DayOrDate] AS DayOrDate ,
					dbo.[AutoReportScheduler].[RRule] AS RRule
			FROM    dbo.[AutoReportScheduler]
			WHERE   dbo.[AutoReportScheduler].IsDeleted = 0;
		END
		ELSE
		BEGIN

			SELECT  dbo.[AutoReportScheduler].[Id] AS Id ,
					dbo.[AutoReportScheduler].[SchedulerName] AS SchedulerName ,
					ISNULL(dbo.[AutoReportScheduler].[Description],'') AS Description ,
					dbo.[AutoReportScheduler].[FreqTypeId] AS FreqTypeId ,
					dbo.[AutoReportScheduler].[FreqInterval] AS FreqInterval ,
					dbo.[AutoReportScheduler].[StartDate] AS StartDate ,
					dbo.[AutoReportScheduler].[EndDate] AS EndDate ,
					dbo.[AutoReportScheduler].[ScheduleTime] AS ScheduleTime ,
					dbo.[AutoReportScheduler].[DayOrDate] AS DayOrDate ,
					dbo.[AutoReportScheduler].[RRule] AS RRule
			FROM    dbo.[AutoReportScheduler]
				--LEFT JOIN dbo.UserRolePermissions ON dbo.UserRolePermissions.PageID = @PageID
				--AND dbo.UserRolePermissions.ActualID = dbo.AutoReportScheduler.Id
				--AND dbo.UserRolePermissions.UserID = dbo.AutoReportScheduler.CreatedBy
				--AND 
			WHERE   dbo.[AutoReportScheduler].IsDeleted = 0 and CreatedBy = @UserID;

		END
    END;