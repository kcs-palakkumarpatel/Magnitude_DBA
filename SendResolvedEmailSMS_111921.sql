
-- =============================================
-- Author:		<Vasu Patel>
-- Create date: <24 Mar 2016>
-- Description:	<Resolved Email and SMS.>
-- SendResolvedEmailSMS 14470,'AA'
-- =============================================
CREATE PROCEDURE	 [dbo].[SendResolvedEmailSMS_111921]
    @ReportId BIGINT ,
    @EncriptyId NVARCHAR(25)
AS
    BEGIN
        DECLARE @MobileNo NVARCHAR(15) ,
            @EmailId NVARCHAR(50) ,
            @SendSMS BIT ,
            @SendEmail BIT ,
            @SMSText NVARCHAR(MAX) ,
            @EmailText NVARCHAR(MAX) ,
            @EmailSubject NVARCHAR(MAX);


        IF EXISTS ( SELECT  *
                    FROM    dbo.EstablishmentGroup
                    WHERE   Id = ( SELECT   EstablishmentGroupId
                                   FROM     dbo.Establishment
                                   WHERE    Id = ( SELECT   EstablishmentId
                                                   FROM     dbo.AnswerMaster
                                                   WHERE    Id = @ReportId
                                                 )
                                 ) )
            BEGIN
			SET @EmailId = ''
			SET @MobileNo = ''
        /*        SELECT  @EmailId = Email ,
                        @MobileNo = Mobile
                FROM    dbo.AppUser
                WHERE   Id = ( SELECT   AppUserId
                               FROM     dbo.AnswerMaster
                               WHERE    Id = @ReportId
                             );
		PRINT '11' + @MobileNo*/

                IF ( ISNULL(@EmailId,'') = '' OR @EmailId = NULL )
                    BEGIN
                        SELECT  @EmailId = Detail
                        FROM    dbo.Answers
                        WHERE   AnswerMasterId = @ReportId
                                AND QuestionTypeId = 10;
                    END;
                IF ( ISNULL(@MobileNo,'')= '' OR  @MobileNo = NULL )
                    BEGIN
                        SELECT  @MobileNo = Detail
                        FROM    dbo.Answers
                        WHERE   AnswerMasterId = @ReportId
                                AND QuestionTypeId = 11;
                    END;
            END;
        ELSE
            BEGIN
                SELECT  @MobileNo = Detail
                FROM    dbo.Answers
                WHERE   AnswerMasterId = @ReportId
                        AND QuestionTypeId = 11;
                SELECT  @EmailId = Detail
                FROM    dbo.Answers
                WHERE   AnswerMasterId = @ReportId
                        AND QuestionTypeId = 10;
            END;
                
        SELECT  @SMSText = SMSText ,
                @EmailText = EmailText ,
                @EmailSubject = EmailSubject
        FROM    GetResolvedSMSEmailText(@ReportId, @EncriptyId);

		PRINT @SMSText
		PRINT @MobileNo

        IF @SMSText <> ''
            AND @SMSText IS NOT NULL
            BEGIN
                IF @MobileNo <> ''
                    AND @MobileNo IS NOT NULL
                    BEGIN
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
                                SELECT  2 ,
                                        @MobileNo ,
                                        @SMSText ,
                                        0 ,
                                        GETUTCDATE() ,
                                        @ReportId ,
                                        GETUTCDATE() ,
                                        0;
                    END;
            END;
                    

        IF @EmailText <> ''
            AND @EmailText IS NOT NULL
            BEGIN
                IF @EmailId <> ''
                    AND @EmailId IS NOT NULL
                    BEGIN
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
                                SELECT  2 ,
                                        @EmailId ,
                                        @EmailText ,
                                        @EmailSubject ,
                                        @ReportId ,
										dbo.EmailBlackListCheck(@EmailId), 
                                        GETUTCDATE() ,
                                        0;
                    END; 



            END;
    END;
