-- =============================================
-- Author:			Sunil Vaghasiya
-- Create date:	12-Dec-2016
-- Description:	Send sms with Custom Message.
-- Call:					dbo.SendCustomMessageSms
-- =============================================
CREATE PROCEDURE [dbo].[SendCustomMessageSms]
    (
      @AppUserID BIGINT = 0 ,
      @AnswerMasterID BIGINT = 0 ,
      @EncryptedID NVARCHAR(500) = NULL ,
      @SMSText NVARCHAR(MAX) = NULL
	)
AS
    BEGIN
        DECLARE @SCOPEID INT = 0 ,
            @MobileNo NVARCHAR(15) ,
            @Url NVARCHAR(2000) ,
            @SendSMS BIT; 

        IF EXISTS ( SELECT  *
                    FROM    dbo.EstablishmentGroup
                    WHERE   Id = ( SELECT   EstablishmentGroupId
                                   FROM     dbo.Establishment
                                   WHERE    Id = ( SELECT   EstablishmentId
                                                   FROM     dbo.AnswerMaster
                                                   WHERE    Id = @AnswerMasterID
                                                 )
                                 ) )
            BEGIN
                SET @MobileNo = '';

                IF ( ISNULL(@MobileNo, '') = ''
                     OR @MobileNo = NULL
                   )
                    BEGIN
                        SELECT  @MobileNo = Detail
                        FROM    dbo.Answers
                        WHERE   AnswerMasterId = @AnswerMasterID
                                AND QuestionTypeId = 11;
                    END;
            END;
        ELSE
            BEGIN
                SELECT  @MobileNo = Detail
                FROM    dbo.Answers
                WHERE   AnswerMasterId = @AnswerMasterID
                        AND QuestionTypeId = 11;              
            END;

        SELECT  @Url = KeyValue + 'Fb/ResolvedForm?rid=' + @EncryptedID
        FROM    dbo.AAAAConfigSettings
        WHERE   KeyName = 'DocViewerRootFolderPathCMS';

		  --SELECT  @Url = KeyValue + 'Fb/ResolvedForm?rid=' + @EncryptedID
    --    FROM    dbo.AAAAConfigSettings
    --    WHERE   KeyName = 'DocViewerRootFolderPath';

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
                                        @SMSText + CHAR(13) + '--' + @Url ,
                                        0 ,
                                        GETUTCDATE() ,
                                        @AnswerMasterID ,
                                        GETUTCDATE() ,
                                        @AppUserID;
                        SET @SCOPEID = SCOPE_IDENTITY();
                        SELECT  @SCOPEID AS Response;
                    END;
                ELSE
                    BEGIN
                        SELECT  @SCOPEID AS Response;
                    END;					
            END;
        ELSE
            BEGIN
                SELECT  @SCOPEID AS Response;
            END;
    END;
