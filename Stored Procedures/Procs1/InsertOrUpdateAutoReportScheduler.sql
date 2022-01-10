-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,, 20 Oct 2015>
-- Description:	<Description,,InsertOrUpdateAutoReportScheduler>
-- Call SP    :	InsertOrUpdateAutoReportScheduler
-- =============================================
CREATE PROCEDURE [dbo].[InsertOrUpdateAutoReportScheduler]
    @Id BIGINT ,
    @SchedulerName NVARCHAR(500) ,
    @Description NVARCHAR(50) ,
    @FreqTypeId INT ,
    @FreqInterval INT ,
    @StartDate DATETIME ,
    @EndDate DATETIME ,
    @ScheduleTime DATETIME ,
    @DayOrDate NVARCHAR(50) ,
    @RRule NVARCHAR(500) ,
    @UserId BIGINT ,
    @PageId BIGINT
AS
    BEGIN        IF ( @Id = 0 )
            BEGIN                INSERT  INTO dbo.[AutoReportScheduler]
                        ( [SchedulerName] ,
                          [Description] ,
                          [FreqTypeId] ,
                          [FreqInterval] ,
                          [StartDate] ,
                          [EndDate] ,
                          [ScheduleTime] ,
                          [DayOrDate] ,
                          [RRule] ,
                          [CreatedOn] ,
                          [CreatedBy] ,
                          [IsDeleted]
                        )
                VALUES  ( @SchedulerName ,
                          @Description ,
                          @FreqTypeId ,
                          @FreqInterval ,
                          @StartDate ,
                          @EndDate ,
                          @ScheduleTime ,
                          @DayOrDate ,
                          @RRule ,
                          GETDATE() ,
                          @UserId ,
                          0
                        );                SELECT  @Id = SCOPE_IDENTITY();                INSERT  INTO dbo.ActivityLog
                        ( UserId ,
                          PageId ,
                          AuditComments ,
                          TableName ,
                          RecordId ,
                          CreatedOn ,
                          CreatedBy ,
                          IsDeleted
                        )
                VALUES  ( @UserId ,
                          @PageId ,
                          'Insert record in table AutoReportScheduler' ,
                          'AutoReportScheduler' ,
                          @Id ,
                          GETDATE() ,
                          @UserId ,
                          0
                        );						
				INSERT INTO dbo.[UserRolePermissions]
				(  [PageID]   ,
				  [ActualID]  ,
				  [UserID]	  ,
				  [CreatedOn] ,
				  [CreatedBy] ,
				  [UpdatedOn] ,
				  [UpdatedBy] ,
				  [DeletedOn] ,
				  [DeletedBy] ,
				  [IsDeleted] 
				)
				VALUES ( @PageId ,
						 @Id ,
						 @UserId ,
						 GETUTCDATE() ,
						 @UserId ,
						 NULL,
						 NULL,
						 NULL,
						 NULL,
						 0
				);            END;        ELSE
            BEGIN                UPDATE  dbo.[AutoReportScheduler]
                SET     [SchedulerName] = @SchedulerName ,
                        [Description] = @Description ,
                        [FreqTypeId] = @FreqTypeId ,
                        [FreqInterval] = @FreqInterval ,
                        [StartDate] = @StartDate ,
                        [EndDate] = @EndDate ,
                        [ScheduleTime] = @ScheduleTime ,
                        [DayOrDate] = @DayOrDate ,
                        [RRule] = @RRule ,
                        [UpdatedOn] = GETDATE() ,
                        [UpdatedBy] = @UserId
                WHERE   [Id] = @Id;                INSERT  INTO dbo.ActivityLog
                        ( UserId ,
                          PageId ,
                          AuditComments ,
                          TableName ,
                          RecordId ,
                          CreatedOn ,
                          CreatedBy ,
                          IsDeleted
                        )
                VALUES  ( @UserId ,
                          @PageId ,
                          'Update record in table AutoReportScheduler' ,
                          'AutoReportScheduler' ,
                          @Id ,
                          GETDATE() ,
                          @UserId ,
                          0
                        );            END;        SELECT  ISNULL(@Id, 0) AS InsertedId;    END;