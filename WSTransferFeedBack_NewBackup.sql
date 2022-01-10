-- =============================================
-- Author:			Sunil Vaghasiya
-- Create date:	14-03-2017
-- Description:	
-- Call SP:		WSTransferFeedBack 126897, 4570, 4565, 1, 20397
-- =============================================
CREATE PROCEDURE [dbo].[WSTransferFeedBack_NewBackup]
    @AnswerMasterId BIGINT ,
    @NewAppUserId BIGINT ,
    @AppUserId BIGINT ,
    @IsOut BIT ,
    @EstablishmentId BIGINT
AS
    BEGIN
        DECLARE @AMId BIGINT, @NewAppUserName VARCHAR(100), @FromAppUserName VARCHAR(100), @Notification NVARCHAR(500);
	
		SELECT @NewAppUserName = [Name] FROM dbo.AppUser  WHERE Id = @NewAppUserId
		SELECT @FromAppUserName = [Name] FROM dbo.AppUser  WHERE Id = @AppUserId

        SET  @Notification = 'New Form transferred from ' + @FromAppUserName + ' to ' + @NewAppUserName;

        IF @IsOut = 0
            BEGIN
               -- IF ( SELECT IsTransferred
                 --    FROM   dbo.AnswerMaster
                   --  WHERE  Id = @AnswerMasterId
                   --         AND IsDeleted = 0
                   --) = 1
                    --BEGIN
                     --   SET @AMId = -1;
                      --  SELECT  ISNULL(@AMId, 0) AS InstertedId;
                       -- RETURN -1;
                    --END;
                IF EXISTS ( SELECT  *
                            FROM    dbo.AnswerMaster
                            WHERE   AnswerMasterId = @AnswerMasterId
                                    AND IsDeleted = 0 )
                    BEGIN
                        SET @AMId = -1;
                        SELECT  ISNULL(@AMId, 0) AS InstertedId;
                        RETURN -1;
                    END;
                
                INSERT  INTO dbo.AnswerMaster
                        ( EstablishmentId ,
                          QuestionnaireId ,
                          AppUserId ,
                          IsOutStanding ,
                          ReadBy ,
                          Latitude ,
                          Longitude ,
                          TimeOffSet ,
                          IsPositive ,
                          EscalationSendDate ,
                          ImportTypeId ,
                          EI ,
                          PI ,
                          SeenClientAnswerMasterId ,
                          IsResolved ,
                          IsTransferred ,
                          AnswerMasterId ,
                          CreatedBy 
	                    )
                        SELECT  @EstablishmentId ,
                                QuestionnaireId ,
                                @NewAppUserId ,
                                1 ,
                                NULL ,
                                Latitude ,
                                Longitude ,
                                TimeOffSet ,
                                IsPositive ,
                                NULL ,
                                ImportTypeId ,
                                EI ,
                                PI ,
                                SeenClientAnswerMasterId ,
                                IsResolved ,
                                1 ,
                                @AnswerMasterId ,
                                @NewAppUserId
                        FROM    AnswerMaster
                        WHERE   ( Id = @AnswerMasterId );
                SELECT  @AMId = SCOPE_IDENTITY();

                UPDATE  dbo.AnswerMaster
                SET     IsDeleted = 1 ,
                        DeletedOn = GETUTCDATE() ,
                        DeletedBy = @AppUserId
                WHERE   Id = @AnswerMasterId;

                INSERT  INTO dbo.Answers
                        ( AnswerMasterId ,
                          QuestionId ,
                          OptionId ,
                          QuestionTypeId ,
                          Detail ,
                          Weight ,
						  QPI,
						  CreatedBy,
						  RepetitiveGroupId,
						  RepetitiveGroupName,
						  RepeatCount
		                )
                        SELECT  @AMId ,
                                QuestionId ,
                                OptionId ,
                                QuestionTypeId ,
                                Detail ,
                                Weight ,
								QPI,
                                @NewAppUserId,
								RepetitiveGroupId,
								RepetitiveGroupName,
								RepeatCount
                        FROM    Answers
                        WHERE   ( AnswerMasterId = @AnswerMasterId
                                  AND IsDeleted = 0
                                );

                UPDATE  dbo.Answers
                SET     IsDeleted = 1 ,
                        DeletedOn = GETUTCDATE() ,
                        DeletedBy = @AppUserId
                WHERE   AnswerMasterId = @AnswerMasterId;

            END;
        ELSE
            BEGIN
              --  IF ( SELECT IsTransferred
                --     FROM   dbo.SeenClientAnswerMaster
               --      WHERE  Id = @AnswerMasterId
                --            AND IsDeleted = 0
                --   ) = 1
                 --   BEGIN
                  --      SET @AMId = -1;
                 --       SELECT  ISNULL(@AMId, 0) AS InstertedId;
                  --      RETURN -1;
                --    END;
                IF EXISTS ( SELECT  *
                            FROM    dbo.SeenClientAnswerMaster
                            WHERE   SeenClientAnswerMasterId = @AnswerMasterId
                                    AND IsDeleted = 0 )
                    BEGIN
                        SET @AMId = -1;
                        SELECT  ISNULL(@AMId, 0) AS InstertedId;
                        RETURN -1;
                    END;

                INSERT  INTO dbo.SeenClientAnswerMaster
                        ( EstablishmentId ,
                          SeenClientId ,
                          AppUserId ,
                          IsOutStanding ,
                          ReadBy ,
                          Latitude ,
                          Longitude ,
                          TimeOffSet ,
                          ContactMasterId ,
                          IsSubmittedForGroup ,
                          ContactGroupId ,
                          EI ,
                          PI ,
                          IsPositive ,
                          IsResolved ,
                          IsTransferred ,
                          SeenClientAnswerMasterId ,
                          IsActioned ,
                          CreatedBy 
				        )
                        SELECT  @EstablishmentId ,
                                SeenClientId ,
                                @NewAppUserId ,
                                1 ,
                                NULL ,
                                Latitude ,
                                Longitude ,
                                TimeOffSet ,
                                ContactMasterId ,
                                IsSubmittedForGroup ,
                                ContactGroupId ,
                                EI ,
                                PI ,
                                IsPositive ,
                                IsResolved ,
                                1 ,
                                @AnswerMasterId ,
                                0 ,
                                @NewAppUserId
                        FROM    SeenClientAnswerMaster
                        WHERE   ( Id = @AnswerMasterId );

					 SELECT  @AMId = SCOPE_IDENTITY();
				
				UPDATE dbo.AnswerMaster
				SET SeenClientAnswerMasterId = @AMId 
				WHERE SeenClientAnswerMasterId = @AnswerMasterId

					
                INSERT  INTO dbo.SeenClientAnswerChild
                        ( SeenClientAnswerMasterId ,
                          ContactMasterId ,
                          SenderCellNo
				        )
                        SELECT  @AMId ,
                                ContactMasterId ,
                                SenderCellNo
                        FROM    dbo.SeenClientAnswerChild
                        WHERE   SeenClientAnswerMasterId = @AnswerMasterId




                INSERT  INTO dbo.SeenClientAnswers
                        ( SeenClientAnswerMasterId ,
                          QuestionId ,
                          OptionId ,
                          QuestionTypeId ,
                          Detail ,
                          Weight ,  
						  QPI,
						  CreatedBy,
						  RepetitiveGroupId,
						  RepetitiveGroupName,
						  RepeatCount
		                )
                        SELECT  @AMId ,
                                QuestionId ,
                                OptionId ,
                                QuestionTypeId ,
                                Detail ,
                                Weight ,
								QPI,
								@NewAppUserId,
								RepetitiveGroupId,
								RepetitiveGroupName,
								RepeatCount
                                
                        FROM    SeenClientAnswers
                        WHERE   ( SeenClientAnswerMasterId = @AnswerMasterId
                                  AND IsDeleted = 0
                                );

				UPDATE  dbo.SeenClientAnswerMaster
                SET     IsDeleted = 1 ,
                        DeletedOn = GETUTCDATE() ,
                        DeletedBy = @AppUserId
                WHERE   Id = @AnswerMasterId;

                UPDATE  dbo.SeenClientAnswers
                SET     IsDeleted = 1 ,
                        DeletedOn = GETUTCDATE() ,
                        DeletedBy = @AppUserId
                WHERE   SeenClientAnswerMasterId = @AnswerMasterId;

				 IF EXISTS
						(
							SELECT StatusIconEstablishment
							FROM dbo.Establishment
							WHERE Id = @EstablishmentId
						)
				      BEGIN

						DECLARE
						@StatusId BIGINT,
						@CurrentStatusIconImageId BIGINT,
						@CurrentStatusHistoryId BIGINT,
						@Offset INT = 0,
						@SHLat NVARCHAR(50),
						@ShLong NVARCHAR(50);

						Select @CurrentStatusHistoryId = StatusHistoryId, @Offset = TimeOffSet,  @SHLat = Latitude, @ShLong = Longitude from SeenClientAnswerMaster where Id = @AnswerMasterId;
						
						Select @CurrentStatusIconImageId = ES.StatusIconImageId From StatusHistory SH LEFT JOIN EstablishmentStatus ES ON SH.EstablishmentStatusId = ES.Id 
						where SH.Id = @CurrentStatusHistoryId
				
						
							INSERT INTO dbo.StatusHistory
							(
								ReferenceNo,
								EstablishmentStatusId,
								UserId,
								StatusDateTime,
								Latitude,
								IsOut,
								Longitude,
								CreatedOn,
								CreatedBy,
								UpdatedOn,
								UpdatedBy,
								DeletedOn,
								DeletedBy,
								IsDeleted
							)
							VALUES
							(   
								@AMId,                                      -- ReferenceNo - bigint
							    ISNULL(
										(
										SELECT Id
										FROM dbo.EstablishmentStatus
										WHERE StatusIconImageId = @CurrentStatusIconImageId
										AND EstablishmentId = @EstablishmentId
										AND IsDeleted = 0
										),
										(
								    SELECT Id
									FROM dbo.EstablishmentStatus
									WHERE EstablishmentId = @EstablishmentId
										  AND DefaultStartStatus = 1
										  AND IsDeleted = 0
							     )),										-- EstablishmentStautId - bigint							                          
								@AppUserId,                                 -- UserId - bigint
								DATEADD(MINUTE, @Offset, GETUTCDATE()),     -- StatusDateTime   
								@SHLat,                                     -- Latitude - nvarchar(50)
								1,                                          -- IsOut - bit
								@ShLong,                                    -- Longitude - nvarchar(50)
								GETUTCDATE(),                               -- CreatedOn - datetime
								@AppUserId,                                 -- CreatedBy - bigint
								NULL,                                       -- UpdatedOn - datetime
								0,                                          -- UpdatedBy - bigint
								NULL,                                       -- DeletedOn - datetime
								0,                                          -- DeletedBy - bigint
								0                                           -- IsDeleted - bit		
							);
				SELECT @StatusId = ISNULL(CAST(SCOPE_IDENTITY() AS BIGINT), 0);

				UPDATE dbo.SeenClientAnswerMaster
				SET StatusHistoryId = @StatusId
				WHERE Id = @AMId;
			END;
END;


        IF EXISTS ( 
		SELECT  1
                    FROM    dbo.AppUserEstablishment
                    WHERE   AppUserId = @NewAppUserId
                            AND EstablishmentId = @EstablishmentId
                            AND IsDeleted = 0
                            AND NotificationStatus = 1 )
            BEGIN
			
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
                        SELECT DISTINCT
                                CASE @IsOut
                                  WHEN 0 THEN 7
                                  ELSE 8
                                END AS MoudleId ,
                                ISNULL(@Notification, 'Form Transfered'),
                                TokenId ,
                                0 ,
                                NULL ,
                                GETUTCDATE() ,
                                @AMId ,
                                T.AppUserId ,
                                DeviceTypeId,
								@AppUserId
                        FROM   dbo.AppUser AS U 
                                INNER JOIN dbo.UserTokenDetails AS T ON U.Id = T.AppUserId
                        WHERE   LEN(TokenId) > 10
                                AND T.AppUserId = @NewAppUserId;
		
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
                                  WHEN 0 THEN 7
                                  ELSE 8
                                END AS ModuleId ,
                                ISNULL(@Notification, 'Form Transfered'),
                                0 ,
                                GETUTCDATE() ,
                                @AMId ,
                                U.Id ,
                                GETUTCDATE(),
								@AppUserId
                        FROM   dbo.AppUser AS U 
                        WHERE  U.Id = @NewAppUserId;

                DECLARE @SendTransferFormSMS BIT ,
                    @SendTransferFormEmail BIT ,
                    @TransferFormSMSText VARCHAR(1000) ,
                    @TransferFormEmailSubject VARCHAR(1000) ,
                    @TransferFormEmailText VARCHAR(2000) ,
                    @TransferFromRefNo VARCHAR(50) ,
                    @TransferToRefNo VARCHAR(50) ,
                    @TransferFromUsername VARCHAR(100) ,
                    @TransferToUsername VARCHAR(100) ,
                    @TransferFromEstablishment VARCHAR(500) ,
                    @TransferToEstablishment VARCHAR(500) ,
                    @TransferToMobile VARCHAR(15) ,
                    @TransferToEmail VARCHAR(100)

                SELECT  @SendTransferFormSMS = SendTransferFormSMS ,
                        @SendTransferFormEmail = SendTransferFormEmail ,
                        @TransferFormSMSText = TransferFormSMS ,
                        @TransferFormEmailSubject = TransferFormEmailSubject ,
                        @TransferFormEmailText = TransferFormEmail ,
                        @TransferToEstablishment = EstablishmentName
                FROM    dbo.Establishment
                WHERE   Id = @EstablishmentId

                IF @IsOut = 0
                    BEGIN
                        SELECT  @TransferFromEstablishment = E.EstablishmentName
                        FROM    dbo.Establishment E
                                INNER JOIN dbo.AnswerMaster AM ON AM.EstablishmentId = E.Id
                        WHERE   AM.Id = @AnswerMasterId
                    END
                ELSE
                    BEGIN
                        SELECT  @TransferFromEstablishment = E.EstablishmentName
                        FROM    dbo.Establishment E
                                INNER JOIN dbo.SeenClientAnswerMaster SAM ON SAM.EstablishmentId = E.Id
                        WHERE   SAM.Id = @AnswerMasterId
                    END

                SELECT  @TransferFromUsername = [Name]
                FROM    dbo.AppUser
                WHERE   Id = @AppUserId

                SELECT  @TransferToUsername = [Name] ,
                        @TransferToMobile = Mobile ,
                        @TransferToEmail = Email
                FROM    dbo.AppUser
                WHERE   Id = @NewAppUserId

                SET @TransferFromRefNo = CAST(LEFT(REPLICATE(0,
                                                             10
                                                             - LEN(@AnswerMasterId))
                                                   + CAST(@AnswerMasterId AS VARCHAR(50)),
                                                   10) AS VARCHAR(50))
                SET @TransferToRefNo = CAST(LEFT(REPLICATE(0, 10 - LEN(@AMId))
                                                 + CAST(@AMId AS VARCHAR(50)),
                                                 10) AS VARCHAR(50))

                IF @SendTransferFormSMS = 1
                    AND ISNULL(@TransferFormSMSText, '') <> ''
                    BEGIN
                        IF ISNULL(@TransferToMobile, '') <> ''
                            BEGIN
                                SET @TransferFormSMSText = REPLACE(@TransferFormSMSText,
                                                              '##[fromrefno]##',
                                                              @TransferFromRefNo);
                                SET @TransferFormSMSText = REPLACE(@TransferFormSMSText,
                                                              '##[torefno]##',
                                                              @TransferToRefNo);
                                SET @TransferFormSMSText = REPLACE(@TransferFormSMSText,
                                                              '##[fromusername]##',
                                                              @TransferFromUsername);
                                SET @TransferFormSMSText = REPLACE(@TransferFormSMSText,
                                                              '##[tousername]##',
                                                              @TransferToUsername);
                                SET @TransferFormSMSText = REPLACE(@TransferFormSMSText,
                                                              '##[fromestablishment]##',
                                                              @TransferFromEstablishment);
                                SET @TransferFormSMSText = REPLACE(@TransferFormSMSText,
                                                              '##[toestablishment]##',
                                                              @TransferToEstablishment);

                                INSERT  INTO dbo.PendingSMS
                                        ( ModuleId ,
                                          MobileNo ,
                                          SMSText ,
                                          IsSent ,
                                          ScheduleDateTime ,
                                          RefId ,
                                          CreatedOn ,
                                          CreatedBy 
				                        )
                                        SELECT  CASE WHEN @IsOut = 0 THEN 7
                                                     ELSE 8
                                                END ,
                                                @TransferToMobile ,
                                                @TransferFormSMSText ,
                                                0 ,
                                                GETUTCDATE() ,
                                                @AnswerMasterId ,
                                                GETUTCDATE() ,
                                                @AppUserId
                                        
                            END

                    END

                IF @SendTransferFormEmail = 1
                    AND ISNULL(@TransferFormEmailText, '') <> ''
                    BEGIN
                        IF ISNULL(@TransferToEmail, '') <> ''
                            BEGIN
                                IF ISNULL(@TransferFormEmailSubject, '') = ''
                                    BEGIN
                                        SET @TransferFormEmailSubject = 'New Form transferred From '
                                            + @TransferFromUsername
                                    END
                                ELSE
                                    BEGIN
                                        SET @TransferFormEmailSubject = REPLACE(@TransferFormEmailSubject,
                                                              '##[fromrefno]##',
                                                              @TransferFromRefNo);
                                        SET @TransferFormEmailSubject = REPLACE(@TransferFormEmailSubject,
                                                              '##[torefno]##',
                                                              @TransferToRefNo);
                                        SET @TransferFormEmailSubject = REPLACE(@TransferFormEmailSubject,
                                                              '##[fromusername]##',
                                                              @TransferFromUsername);
                                        SET @TransferFormEmailSubject = REPLACE(@TransferFormEmailSubject,
                                                              '##[tousername]##',
                                                              @TransferToUsername);
                                        SET @TransferFormEmailSubject = REPLACE(@TransferFormEmailSubject,
                                                              '##[fromestablishment]##',
                                                              @TransferFromEstablishment);
                                        SET @TransferFormEmailSubject = REPLACE(@TransferFormEmailSubject,
                                                              '##[toestablishment]##',
                                                              @TransferToEstablishment);

                                        SET @TransferFormEmailText = REPLACE(@TransferFormEmailText,
                                                              '##[fromrefno]##',
                                                              @TransferFromRefNo);
                                        SET @TransferFormEmailText = REPLACE(@TransferFormEmailText,
                                                              '##[torefno]##',
                                                              @TransferToRefNo);
                                        SET @TransferFormEmailText = REPLACE(@TransferFormEmailText,
                                                              '##[fromusername]##',
                                                              @TransferFromUsername);
                                        SET @TransferFormEmailText = REPLACE(@TransferFormEmailText,
                                                              '##[tousername]##',
                                                              @TransferToUsername);
                                        SET @TransferFormEmailText = REPLACE(@TransferFormEmailText,
                                                              '##[fromestablishment]##',
                                                              @TransferFromEstablishment);
                                        SET @TransferFormEmailText = REPLACE(@TransferFormEmailText,
                                                              '##[toestablishment]##',
                                                              @TransferToEstablishment);
                                    END

                                INSERT  INTO dbo.PendingEmail
                                        ( ModuleId ,
                                          EmailId ,
                                          EmailText ,
                                          EmailSubject ,
                                          RefId ,
										  Counter,
                                          ScheduleDateTime ,
                                          CreatedBy 						        
                                        )
                                        SELECT  CASE WHEN @IsOut = 0 THEN 7
                                                     ELSE 8
                                                END ,
                                                @TransferToEmail ,
                                                @TransferFormEmailText ,
                                                @TransferFormEmailSubject ,
                                                @AnswerMasterId ,
												dbo.EmailBlackListCheck(@TransferToEmail),
                                                GETUTCDATE() ,
                                                @AppUserId

                            END
                    END

				

                

            END
        

		/*-----------------Disha - 05-OCT-2016 - Add Actions of Old User to New User-----------------------------*/
        IF @IsOut = 0
            BEGIN
                INSERT  INTO dbo.CloseLoopAction
                        ( AnswerMasterId ,
                          SeenClientAnswerMasterId ,
                          AppUserId ,
                          Conversation ,
                          IsReminderSet ,
                          CreatedOn,
						  Attachment
					    )
                        SELECT  @AMId ,
                                SeenClientAnswerMasterId ,
                                AppUserId ,
                                Conversation ,
                                IsReminderSet ,
                                GETUTCDATE(),
								Attachment
                        FROM    dbo.CloseLoopAction
                        WHERE   AnswerMasterId = @AnswerMasterId
                        ORDER BY CONVERT(NVARCHAR(50), CreatedOn, 109) ASC
            END
        ELSE
            BEGIN
                INSERT  INTO dbo.CloseLoopAction
                        ( AnswerMasterId ,
                          SeenClientAnswerMasterId ,
                          AppUserId ,
                          Conversation ,
                          IsReminderSet ,
                          CreatedOn,
						  Attachment
				        )
                        SELECT  AnswerMasterId ,
                                @AMId ,
                                AppUserId ,
                                Conversation ,
                                IsReminderSet ,
                                GETUTCDATE(),
								Attachment
                        FROM    dbo.CloseLoopAction
                        WHERE   SeenClientAnswerMasterId = @AnswerMasterId
                        ORDER BY CONVERT(NVARCHAR(50), CreatedOn, 109) ASC
            END
		/*-------------------------------------------------------------------------------------------------------*/

        EXEC dbo.InsertCloseLoopAction @AppUserId = @AppUserId, -- bigint
            @Conversation = @Notification , -- nvarchar(2000)
            @ReportId = @AMId, -- bigint
            @IsOut = @IsOut, -- bit
            @ReminderDate = '',
			@Attachment = '',
			@lgCustomerUserId = 0,
			@CustomerName = NULL;

        SELECT  ISNULL(@AMId, 0) AS InstertedId;
    END
