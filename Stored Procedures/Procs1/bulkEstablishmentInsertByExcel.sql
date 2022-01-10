/*
 =============================================
 Author:		<Author,,Name>
 Create date: <Create Date,,>
 Description:	<Description,,>
 Call: bulkEstablishmentInsertByExcel
 Updated Date: Updated by Disha - 22-OCT-2016 - Addititon of 6 newly added columns for Escalation
 =============================================
*/

CREATE PROCEDURE [dbo].[bulkEstablishmentInsertByExcel]
AS
    BEGIN
        IF EXISTS ( SELECT  1
                    FROM    EstablishmentImport )
            BEGIN
                UPDATE  EstablishmentImport
                SET     MainId = ISNULL(Id, 0)
                FROM    dbo.Establishment
                WHERE   Establishment.EstablishmentName = EstablishmentImport.MainEstablishment;

                UPDATE  dbo.EstablishmentImport
                SET     UniqSMSKeyWord = ''
                FROM    dbo.Establishment E
                        INNER JOIN dbo.EstablishmentImport EI ON E.Id = EI.MainId
                        INNER JOIN dbo.EstablishmentGroup EG ON EG.Id = E.EstablishmentGroupId
                                                              AND EG.EstablishmentGroupType = 'Sales'
                WHERE   E.Id = EI.MainId;

            END;

        DECLARE @tempTable AS TABLE
            (
              UniqueSMSKeyword NVARCHAR(50) ,
              CommonSMSKeyword NVARCHAR(50) ,
              GroupKeyword NVARCHAR(50)
            );

        DECLARE @EstablishmentName NVARCHAR(50) ,
            @Start BIGINT = 1 ,
            @End BIGINT ,
            @main BIGINT ,
            @UserId BIGINT ,
            @UniqSMSKeyword NVARCHAR(50) ,
            @InEscalationEmails VARCHAR(2000) ,
            @InEscalationMobiles VARCHAR(2000) ,
            @InEscalationEmailSubject VARCHAR(2000) ,
            @OutEscalationEmails VARCHAR(2000) ,
            @OutEscalationMobiles VARCHAR(2000) ,
            @OutEscalationEmailSubject VARCHAR(2000)


        SELECT  @End = COUNT(1)
        FROM    dbo.EstablishmentImport;

        WHILE ( @Start <= @End )
            BEGIN
                SELECT  @EstablishmentName = Establishment ,
                        @main = ISNULL(MainId, 0) ,
                        @UniqSMSKeyword = ISNULL(UniqSMSKeyWord, '') ,
                        @InEscalationEmails = InEscalationEmails ,
                        @InEscalationMobiles = InEscalationMobiles ,
                        @InEscalationEmailSubject = InEscalationEmailSubject ,
                        @OutEscalationEmails = OutEscalationEmails ,
                        @OutEscalationMobiles = OutEscalationMobiles ,
                        @OutEscalationEmailSubject = OutEscalationEmailSubject
                FROM    EstablishmentImport
                WHERE   SNo = @Start;

                IF ( @UniqSMSKeyword != '' )
                    BEGIN
                        INSERT  INTO @tempTable
                                EXEC dbo.IsUniqAndCommonKeywordExists @Id = 0, -- bigint
                                    @UniqSMSKeyword = @UniqSMSKeyword, -- nvarchar(50)
                                    @IsUniq = 1; -- bit
                    END
                            
                PRINT @UniqSMSKeyword;
                IF NOT EXISTS ( SELECT  1
                                FROM    dbo.Establishment E
                                        INNER JOIN dbo.EstablishmentImport EI ON E.Id = EI.MainId
                                        INNER JOIN dbo.EstablishmentGroup EG ON EG.Id = E.EstablishmentGroupId
                                                              AND EG.EstablishmentGroupType = 'Customer'
                                WHERE   EI.SNo = @Start
                                        AND ( EI.UniqSMSKeyWord = ''
                                              OR EI.UniqSMSKeyWord IS NULL
                                            ) )
                    BEGIN
                        IF NOT EXISTS ( SELECT  1
                                        FROM    @tempTable )
                            BEGIN
                                IF NOT EXISTS ( SELECT  1
                                                FROM    dbo.Establishment
                                                WHERE   EstablishmentName = @EstablishmentName
                                                        AND IsDeleted = 0
                                                        AND @main > 0 )
                                    BEGIN
                                        INSERT  INTO dbo.Establishment
                                                ( GroupId ,
                                                  EstablishmentGroupId ,
                                                  EstablishmentName ,
                                                  GeographicalLocation ,
                                                  TimeOffSetId ,
                                                  TimeOffSet ,
                                                  IncludedMonthlyReports ,
                                                  UniqueSMSKeyword ,
                                          --CommonSMSKeyword ,
                                                  AutoResponseMessage ,
                                                  SendThankYouSMS ,
                                                  ThankYouMessage ,
                                                  SendSeenClientSMS ,
                                                  SeenClientAutoSMS ,
                                                  SendSeenClientEmail ,
                                                  SeenClientAutoEmail ,
                                                  SeenClientEmailSubject ,
                                                  SeenClientAutoNotification ,
                                                  SeenClientEscalationTime ,
                                                  SeenClientSchedulerTime ,
                                                  SeenClientSchedulerTimeString ,
                                                  ShowIntroductoryOnMobi ,
                                                  IntroductoryMessage ,
                                                  EscalationEmailSubject ,
                                                  EscalationEmails ,
                                                  EscalationMobile ,
                                                  EscalationTime ,
                                                  EscalationSchedulerTime ,
                                                  EscalationSchedulerTimeString ,
                                                  EscalationSchedulerDay ,
                                                  FeedbackTimeSpan ,
                                                  ShowSeenClientDetailsOnMobi ,
                                                  SendNotificationAlertForAll ,
                                                  SendFeedbackSMSAlert ,
                                                  FeedbackSMSAlert ,
                                                  SendFeedbackEmailAlert ,
                                                  FeedbackEmailAlert ,
                                                  FeedbackEmailSubject ,
                                                  FeedbackNotificationAlert ,
                                                  FeedbackRedirectURL ,
                                                  FeedbackOnce ,
                                                  mobiFormDisplayFields ,
                                                  CreatedOn ,
                                                  CreatedBy ,
                                                  UpdatedOn ,
                                                  UpdatedBy ,
                                                  DeletedOn ,
                                                  DeletedBy ,
                                                  IsDeleted ,
                                                  ThankyouPageMessage ,
                                                  OutEscalationEmailSubject ,
                                                  OutEscalationEmails ,
                                                  OutEscalationMobile ,
                                                  OutEscalationTime ,
                                                  OutEscalationSchedulerTime ,
                                                  OutEscalationSchedulerTimeString ,
                                                  OutEscalationSchedulerDay ,
                                                  SendOutNotificationAlertForAll ,
                                                  SendCaptureSMSAlert ,
                                                  CaptureSMSAlert ,
                                                  SendCaptureEmailAlert ,
                                                  CaptureEmailAlert ,
                                                  CaptureEmailSubject ,
                                                  CaptureNotificationAlert ,
                                                  CommonIntroductoryMessage ,
                                                  ResolutionFeedbackQuestion ,
                                                  ResolutionFeedbackSMS ,
                                                  ResolutionFeedbackEmail ,
                                                  ResolutionFeedbackEmailSubject ,
                                                  IsMultipleRouting ,
                                                  MultipleRoutingValue ,
                                                  ThankyoumessageforLessthanPI ,
                                                  ThankyoumessageforGretareThanPI
                                                )
                                                SELECT  GroupId ,
                                                        EstablishmentGroupId ,
                                                        @EstablishmentName ,
                                        --( SELECT    Establishment
                                        --  FROM      EstablishmentImport
                                        --  WHERE     SNo = @Start
                                        --) ,
                                                        GeographicalLocation ,
                                                        TimeOffSetId ,
                                                        TimeOffSet ,
                                                        IncludedMonthlyReports ,
                                                        @UniqSMSKeyword ,
                                               -- CommonSMSKeyword ,
                                                        AutoResponseMessage ,
                                                        SendThankYouSMS ,
                                                        ThankYouMessage ,
                                                        SendSeenClientSMS ,
                                                        SeenClientAutoSMS ,
                                                        SendSeenClientEmail ,
                                                        SeenClientAutoEmail ,
                                                        SeenClientEmailSubject ,
                                                        SeenClientAutoNotification ,
                                                        SeenClientEscalationTime ,
                                                        SeenClientSchedulerTime ,
                                                        SeenClientSchedulerTimeString ,
                                                        ShowIntroductoryOnMobi ,
                                                        IntroductoryMessage ,
                                                        @InEscalationEmailSubject ,
                                                        @InEscalationEmails ,
                                                        @InEscalationMobiles ,
                                                        EscalationTime ,
                                                        EscalationSchedulerTime ,
                                                        EscalationSchedulerTimeString ,
                                                        EscalationSchedulerDay ,
                                                        FeedbackTimeSpan ,
                                                        ShowSeenClientDetailsOnMobi ,
                                                        SendNotificationAlertForAll ,
                                                        SendFeedbackSMSAlert ,
                                                        FeedbackSMSAlert ,
                                                        SendFeedbackEmailAlert ,
                                                        FeedbackEmailAlert ,
                                                        FeedbackEmailSubject ,
                                                        FeedbackNotificationAlert ,
                                                        FeedbackRedirectURL ,
                                                        FeedbackOnce ,
                                                        mobiFormDisplayFields ,
                                                        CreatedOn ,
                                                        CreatedBy ,
                                                        UpdatedOn ,
                                                        UpdatedBy ,
                                                        DeletedOn ,
                                                        DeletedBy ,
                                                        IsDeleted ,
                                                        ThankyouPageMessage ,
                                                        @OutEscalationEmailSubject ,
                                                        @OutEscalationEmails ,
                                                        @OutEscalationMobiles ,
                                                        OutEscalationTime ,
                                                        OutEscalationSchedulerTime ,
                                                        OutEscalationSchedulerTimeString ,
                                                        OutEscalationSchedulerDay ,
                                                        SendOutNotificationAlertForAll ,
                                                        SendCaptureSMSAlert ,
                                                        CaptureSMSAlert ,
                                                        SendCaptureEmailAlert ,
                                                        CaptureEmailAlert ,
                                                        CaptureEmailSubject ,
                                                        CaptureNotificationAlert ,
                                                        CommonIntroductoryMessage ,
                                                        ResolutionFeedbackQuestion ,
                                                        ResolutionFeedbackSMS ,
                                                        ResolutionFeedbackEmail ,
                                                        ResolutionFeedbackEmailSubject ,
                                                        IsMultipleRouting ,
                                                        MultipleRoutingValue ,
                                                        ThankyoumessageforLessthanPI ,
                                                        ThankyoumessageforGretareThanPI
                                                FROM    dbo.Establishment
                                                WHERE   Id = @main;
                                        DECLARE @id BIGINT
                                        SET @id = @@IDENTITY

                                        INSERT  dbo.UserRolePermissions
                                                ( PageID ,
                                                  ActualID ,
                                                  UserID ,
                                                  CreatedOn ,
                                                  CreatedBy ,
                                                  IsDeleted
							                    )
                                                SELECT  26 ,
                                                        @id ,
                                                        CreatedBy ,
                                                        CreatedOn ,
                                                        CreatedBy ,
                                                        0
                                                FROM    dbo.Establishment
                                                WHERE   Id = @main

                                        UPDATE  EstablishmentImport
                                        SET     [Status] = 1
                                        WHERE   [SNo] = @Start
                                                AND MainId > 0;
                                    END;
                                ELSE
                                    BEGIN
                                        UPDATE  EstablishmentImport
                                        SET     [Status] = 2
                                        WHERE   [SNo] = @Start
                                                AND MainId > 0;
                                    END;
                            END;
                        ELSE
                            BEGIN
                                DELETE  FROM @tempTable;
                                UPDATE  EstablishmentImport
                                SET     [Status] = 3
                                WHERE   [SNo] = @Start
                                        AND MainId > 0;

							
                            END;
                    END
                ELSE
                    BEGIN
                        DELETE  FROM @tempTable;
                        UPDATE  EstablishmentImport
                        SET     [Status] = 4
                        WHERE   [SNo] = @Start
                                AND MainId > 0;
                    END
                	
                SET @Start = @Start + 1;
				
            END;

        SELECT  Establishment ,
                CASE [Status]
                  WHEN 1 THEN 'Success'
                  WHEN 2
                  THEN 'Establishment already Exists OR Main Establishment is Not Exists'
                  WHEN 3 THEN 'Uniq Keyword Exists'
                  WHEN 4 THEN 'Uniq Keyword Is Not Blank'
                  ELSE 'Problem In Upload'
                END AS [Import Status]
        FROM    dbo.EstablishmentImport
        UNION ALL
        SELECT TOP 100
                '' AS Establishment ,
                '' [Import Status]
        FROM    dbo.AnswerMaster;

--DELETE FROM establishmentimport 
--DBCC CHECKIDENT ('establishmentimport', RESEED, 0)
    END;