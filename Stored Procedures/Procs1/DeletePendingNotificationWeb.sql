
-- =============================================
-- Author:		<Disha Patel>
-- Create date: <27-JUL-2015>
-- Description:	<Delete Notifications>
-- Call SP    :	DeletePendingNotificationWeb
-- =============================================
CREATE PROCEDURE [dbo].[DeletePendingNotificationWeb] @IdList NVARCHAR(MAX)
AS
    BEGIN
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
        DECLARE @Start INT = 1 ,
            @Total INT ,
            @IsUsed BIT ,
            @Id BIGINT ,
            @Result NVARCHAR(MAX) = '' ,
            @Count INT = 0
        DECLARE @Tbl TABLE ( Id INT, Data INT )
        INSERT  INTO @Tbl
                ( Id ,
                  Data 
                )
                SELECT  Id ,
                        Data
                FROM    dbo.Split(@IdList, ',')
        SELECT  @Total = COUNT(1)
        FROM    @Tbl
        WHILE @Start <= @Total
            BEGIN
                SELECT  @Id = Data
                FROM    @Tbl
                WHERE   Id = @Start
                BEGIN
                    UPDATE  dbo.[PendingNotificationWeb]
                    SET     IsDeleted = 1 ,
                            DeletedOn = GETUTCDATE()
                    WHERE   [Id] = @Id

                    INSERT  INTO dbo.ActivityLog
                            ( UserId ,
                              PageId ,
                              AuditComments ,
                              TableName ,
                              RecordId ,
                              CreatedOn ,
                              CreatedBy ,
                              IsDeleted 
                            )
                    VALUES  ( ( SELECT  AppUserId
                                FROM    dbo.PendingNotificationWeb
                                WHERE   Id = @Id
                              ) ,
                              0 ,
                              'Delete record in table PendingNotificationWeb' ,
                              'PendingNotificationWeb' ,
                              @Id ,
                              GETUTCDATE() ,
                              ( SELECT  AppUserId
                                FROM    dbo.PendingNotificationWeb
                                WHERE   Id = @Id
                              ) ,
                              0
                            )
                END
                SET @Start += 1
            END
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
         'dbo.DeletePendingNotificationWeb',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         N'',
         @IdList,
         GETUTCDATE(),
         N''
        );
END CATCH

    END
