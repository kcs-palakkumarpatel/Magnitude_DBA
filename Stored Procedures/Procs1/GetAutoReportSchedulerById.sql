-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,, 20 Oct 2015>
-- Description:	<Description,,GetAutoReportSchedulerById>
-- Call SP    :	GetAutoReportSchedulerById
-- =============================================
CREATE PROCEDURE [dbo].[GetAutoReportSchedulerById] @Id BIGINT
AS
    BEGIN        SELECT  [Id] AS Id ,
                [SchedulerName] AS SchedulerName ,
                [Description] AS Description ,
                [FreqTypeId] AS FreqTypeId ,
                [FreqInterval] AS FreqInterval ,
                [StartDate] AS StartDate ,
                [EndDate] AS EndDate ,
                [ScheduleTime] AS ScheduleTime ,
                [DayOrDate] AS DayOrDate ,
                [RRule] AS RRule
        FROM    dbo.[AutoReportScheduler]
        WHERE   [Id] = @Id;    END;