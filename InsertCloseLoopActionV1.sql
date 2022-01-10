-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,02 Jul 2015>
-- Description:	<Description,,>
-- Call SP:		InsertCloseLoopActionV1 314,'@Parsana Gym User,‍ Test2dddd',42751,1,'11/17/2016 03:17 PM',314

-- =============================================
CREATE PROCEDURE [dbo].[InsertCloseLoopActionV1]
    @AppUserId BIGINT ,
    @Conversation NVARCHAR(2000) ,
    @ReportId BIGINT ,
    @IsOut BIT ,
    @ReminderDate NVARCHAR(50),
	@AlertUserId NVARCHAR(500)
AS
    BEGIN
        DECLARE @EstablishmentId BIGINT ,
            @Id BIGINT ,
            @TimeOfSet INT,
			@EstablishmentName NVARCHAR(100),
			@UserName NVARCHAR(50),
			@Message NVARCHAR(500)

			
        IF @IsOut = 1
            BEGIN
                SELECT  @EstablishmentId = EstablishmentId ,
                        @TimeOfSet = TimeOffSet
                FROM    dbo.SeenClientAnswerMaster
                WHERE   Id = @ReportId;

                INSERT  INTO dbo.CloseLoopAction
                        ( AnswerMasterId ,
                          SeenClientAnswerMasterId ,
                          AppUserId ,
                          [Conversation] 
                        )
                VALUES  ( NULL , -- AnswerMasterId - bigint
                          @ReportId , -- SeenClientAnswerMasterId - bigint
                          @AppUserId , -- AppUserId - bigint
                          (SELECT dbo.StripHTML(dbo.udf_StripHTML(@Conversation)))
                        );

                SELECT  @Id = SCOPE_IDENTITY();

                UPDATE  dbo.SeenClientAnswerMaster
                SET     IsActioned = 1
                WHERE   Id = @ReportId;

				UPDATE dbo.CloseLoopAction SET [Conversation] = REPLACE(REPLACE(@Conversation,'&nbsp;',''),'‍ ',' ') WHERE id = @Id
            END;
        ELSE
            BEGIN
                SELECT  @EstablishmentId = EstablishmentId ,
                        @TimeOfSet = TimeOffSet
                FROM    dbo.AnswerMaster
                WHERE   Id = @ReportId;

                INSERT  INTO dbo.CloseLoopAction
                        ( AnswerMasterId ,
                          SeenClientAnswerMasterId ,
                          AppUserId ,
                          [Conversation] 
                        )
                VALUES  ( @ReportId , -- AnswerMasterId - bigint
                          NULL , -- SeenClientAnswerMasterId - bigint
                          @AppUserId , -- AppUserId - bigint
                          @Conversation  -- Conversation - nvarchar(2000)
                        );

                SELECT  @Id = SCOPE_IDENTITY();

                UPDATE  dbo.AnswerMaster
                SET     IsActioned = 1
                WHERE   Id = @ReportId;

				UPDATE dbo.CloseLoopAction SET [Conversation] = REPLACE(REPLACE(@Conversation,'&nbsp;',''),'‍ ',' ') WHERE id = @Id
            END;

        IF @ReminderDate <> ''
            AND @ReminderDate IS NOT NULL
            BEGIN
                
					SELECT @EstablishmentName = EstablishmentName FROM dbo.Establishment WHERE id = @EstablishmentId
				SELECT @UserName = UserName FROM dbo.AppUser WHERE id = @AppUserId

                UPDATE  dbo.CloseLoopAction
                SET     IsReminderSet = 1,
						--Conversation = 'Establishment: ' + @EstablishmentName + CHAR(13) + CHAR(10) +'User: ' + @UserName + CHAR(13) + CHAR(10) + @Conversation + ' - Remind Me on ' + @ReminderDate 
						Conversation = @Conversation + ' - Remind Me on ' + @ReminderDate
                WHERE   Id = @Id;

				SET @Message = 'Reminder '+ CHAR(13) + CHAR(10) 
										+'Establishment: ' + @EstablishmentName + CHAR(13) + CHAR(10)
										+'User: ' + @UserName + CHAR(13) + CHAR(10) 
										+'Action: ' + (SELECT dbo.StripHTML(dbo.udf_StripHTML(@Conversation)))

                INSERT  INTO dbo.PendingNotification
                        ( ModuleId ,
                          [Message] ,
                          TokenId ,
                          [Status] ,
                          SentDate ,
                          ScheduleDate ,
                          RefId ,
                          AppUserId ,
                          DeviceType,
						  CreatedBy
                        )
                        SELECT  CASE @IsOut
                                  WHEN 0 THEN 5
                                  ELSE 6
                                END AS MoudleId ,
                                CASE  WHEN LEN(@Message) > 197 THEN LEFT(@Message,197) + '...' ELSE @Message END ,
								-- @Conversation,
                                TokenId ,
                                0 ,
                                NULL ,
                                DATEADD(MINUTE, -@TimeOfSet, @ReminderDate) ,
                                @ReportId ,
                                T.AppUserId ,
                                DeviceTypeId,
								@AppUserId
                        FROM    dbo.AppUserEstablishment AS UE
                                INNER JOIN dbo.AppUser AS U ON UE.AppUserId = U.Id
                                INNER JOIN dbo.UserTokenDetails AS T ON UE.AppUserId = T.AppUserId
                                INNER JOIN dbo.Establishment AS E ON UE.EstablishmentId = E.Id
                        WHERE   UE.IsDeleted = 0
                                AND E.IsDeleted = 0
                                AND E.Id = @EstablishmentId
                                AND UE.NotificationStatus = 1
                                AND LEN(TokenId) > 10
                                AND T.AppUserId = @AppUserId
							

                INSERT  INTO dbo.PendingNotificationWeb
                        ( ModuleId ,
                          [Message] ,
                          IsRead ,
                          ScheduleDate ,
                          RefId ,
                          AppUserId ,
                          CreatedOn,
						  CreatedBy
                        )
                        SELECT  DISTINCT
                                CASE @IsOut
                                  WHEN 0 THEN 5
                                  ELSE 6
                                END AS ModuleId ,
                                @Conversation ,
                                0 ,
                                DATEADD(MINUTE, -@TimeOfSet, @ReminderDate) ,
                                @ReportId ,
                                UE.AppUserId ,
                                GETUTCDATE(),
								@AppUserId
                        FROM    dbo.AppUserEstablishment AS UE
                                INNER JOIN dbo.AppUser AS U ON UE.AppUserId = U.Id
                                INNER JOIN dbo.Establishment AS E ON UE.EstablishmentId = E.Id
                        WHERE   UE.IsDeleted = 0
                                AND E.IsDeleted = 0
                                AND E.Id = @EstablishmentId
                                AND U.Id = @AppUserId;
            END;

			SELECT TOP 1 @EstablishmentName = EstablishmentGroupName FROM dbo.Establishment INNER JOIN dbo.EstablishmentGroup ON EstablishmentGroup.Id = Establishment.EstablishmentGroupId WHERE dbo.Establishment.Id = @EstablishmentId
			SELECT @UserName = UserName FROM dbo.AppUser WHERE Id = @AppUserId

				SET @Message = 'Activity: ' + @EstablishmentName + '; User: ' + @UserName +'; Action: ' + (SELECT dbo.StripHTML(dbo.udf_StripHTML(@Conversation)))

				SET @Message =  REPLACE(REPLACE(REPLACE(@Message,'&nbsp;',''),'nbsp;',''),'‍ ',' ')

                INSERT  INTO dbo.PendingNotification
                        ( ModuleId ,
                          [Message] ,
                          TokenId ,
                          [Status] ,
                          SentDate ,
                          ScheduleDate ,
                          RefId ,
                          AppUserId ,
                          DeviceType,
						  CreatedBy
                        )
                        SELECT  CASE @IsOut
                                  WHEN 0 THEN 11
                                  ELSE 12
                                END AS MoudleId ,
                                CASE  WHEN LEN(@Message) > 197 THEN LEFT(@Message,197) + '...' ELSE @Message END ,
                                TokenId ,
                                0 ,
                                NULL ,
                                DATEADD(MINUTE, -@TimeOfSet, GETUTCDATE()) ,
                                @ReportId ,
                                T.AppUserId ,
                                DeviceTypeId,
								@AppUserId
                        FROM    dbo.AppUserEstablishment AS UE
                                INNER JOIN dbo.AppUser AS U ON UE.AppUserId = U.Id
                                INNER JOIN dbo.UserTokenDetails AS T ON UE.AppUserId = T.AppUserId
                                INNER JOIN dbo.Establishment AS E ON UE.EstablishmentId = E.Id
                        WHERE   UE.IsDeleted = 0
                                AND E.IsDeleted = 0
                                AND E.Id = @EstablishmentId
                                AND UE.NotificationStatus = 1
                                AND LEN(TokenId) > 10
                                AND T.AppUserId != @AppUserId;

                INSERT  INTO dbo.PendingNotificationWeb
                        ( ModuleId ,
                          [Message] ,
                          IsRead ,
                          ScheduleDate ,
                          RefId ,
                          AppUserId ,
                          CreatedOn,
						  CreatedBy
                        )
                        SELECT  DISTINCT
                                CASE @IsOut
                                  WHEN 0 THEN 11
                                  ELSE 12
                                END AS ModuleId ,
                                @Conversation ,
                                0 ,
                                DATEADD(MINUTE, -@TimeOfSet, GETUTCDATE()) ,
                                @ReportId ,
                                UE.AppUserId ,
                                GETUTCDATE(),
								@AppUserId
                        FROM    dbo.AppUserEstablishment AS UE
                                INNER JOIN dbo.AppUser AS U ON UE.AppUserId = U.Id
                                INNER JOIN dbo.Establishment AS E ON UE.EstablishmentId = E.Id
                        WHERE   UE.IsDeleted = 0
                                AND E.IsDeleted = 0
                                AND E.Id = @EstablishmentId
                                AND U.Id != @AppUserId;


								 INSERT  INTO dbo.PendingNotification
                        ( ModuleId ,
                          [Message] ,
                          TokenId ,
                          [Status] ,
                          SentDate ,
                          ScheduleDate ,
                          RefId ,
                          AppUserId ,
                          DeviceType,
						  CreatedBy
                        )
                        SELECT  CASE @IsOut
                                  WHEN 0 THEN 11
                                  ELSE 12
                                END AS MoudleId ,
                                CASE  WHEN LEN(@Message) > 197 THEN LEFT(@Message,197) + '...' ELSE @Message END ,
                                TokenId ,
                                0 ,
                                NULL ,
                                DATEADD(MINUTE, -@TimeOfSet, GETUTCDATE()) ,
                                @ReportId ,
                                UE.Data,
                                DeviceTypeId,
								@AppUserId
                        FROM    dbo.Split(@AlertUserId,',') AS UE
                                INNER JOIN dbo.AppUser AS U ON UE.Data = U.Id
                                INNER JOIN dbo.UserTokenDetails AS T ON UE.Data = T.AppUserId
                                WHERE LEN(TokenId) > 10
                                AND T.AppUserId != @AppUserId;

                INSERT  INTO dbo.PendingNotificationWeb
                        ( ModuleId ,
                          [Message] ,
                          IsRead ,
                          ScheduleDate ,
                          RefId ,
                          AppUserId ,
                          CreatedOn,
						  CreatedBy
                        )
                        SELECT  DISTINCT
                                CASE @IsOut
                                  WHEN 0 THEN 11
                                  ELSE 12
                                END AS ModuleId ,
                                @Conversation ,
                                0 ,
                                DATEADD(MINUTE, -@TimeOfSet, GETUTCDATE()) ,
                                @ReportId ,
                                UE.Data ,
                                GETUTCDATE(),
								@AppUserId
                        FROM    dbo.Split(@AlertUserId,',') AS UE
                                INNER JOIN dbo.AppUser AS U ON UE.Data = U.Id
                        WHERE   U.Id != @AppUserId;

        RETURN 1;          
    END;



