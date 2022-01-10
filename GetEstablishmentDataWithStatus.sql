-- =============================================
-- Author:		<Author,,Mittal Patel>
-- Create date: <Create Date,, 07 January 2020>
-- Description:	<Description,,GetEstablishmentById>
-- Call SP    :	GetEstablishmentDataWithStatus 1357
-- =============================================
CREATE PROCEDURE [dbo].[GetEstablishmentDataWithStatus] @EstablishmentId BIGINT
AS
BEGIN
    --Get Establishment Details by establishmentid
    SELECT TOP 1
        dbo.[Establishment].[Id] AS Id,
        dbo.[Establishment].[GroupId] AS GroupId,
        dbo.[Establishment].[EstablishmentGroupId] AS EstablishmentGroupId,
        [EstablishmentName] AS EstablishmentName,
        [GeographicalLocation] AS GeographicalLocation,
        [TimeOffSetId] AS TimeOffSetId,
        [TimeOffSet] AS TimeOffSet,
        [IncludedMonthlyReports] AS IncludedMonthlyReports,
        [UniqueSMSKeyword] AS UniqueSMSKeyword,
        [CommonSMSKeyword] AS CommonSMSKeyword,
        [SendThankYouSMS] AS SendThankYouSMS,
        [ThankYouMessage] AS ThankYouMessage,
        [SendSeenClientSMS] AS SendSeenClientSMS,
        [SeenClientAutoSMS] AS SeenClientAutoSMS,
        [SendSeenClientEmail] AS SendSeenClientEmail,
        [SeenClientAutoEmail] AS SeenClientAutoEmail,
        [SeenClientAutoNotification] AS SeenClientAutoNotification,
        [SeenClientEscalationTime] AS SeenClientEscalationTime,
        [SeenClientSchedulerTime] AS SeenClientSchedulerTime,
        [SeenClientSchedulerTimeString] AS SeenClientSchedulerTimeString,
        [ShowIntroductoryOnMobi] AS ShowIntroductoryOnMobi,
        [IntroductoryMessage] AS IntroductoryMessage,
        [EscalationEmails] AS EscalationEmails,
        [EscalationMobile] AS EscalationMobile,
        [EscalationTime] AS EscalationTime,
        [EscalationSchedulerTime] AS EscalationSchedulerTime,
        [EscalationSchedulerTimeString] AS EscalationSchedulerTimeString,
        [EscalationSchedulerDay] AS EscalationSchedulerDay,
        [FeedbackTimeSpan] AS FeedbackTimeSpan,
        [ShowSeenClientDetailsOnMobi] AS ShowSeenClientDetailsOnMobi,
        [SendNotificationAlertForAll] AS SendNotificationAlertForAll,
        [SendFeedbackSMSAlert] AS SendFeedbackSMSAlert,
        [FeedbackSMSAlert] AS FeedbackSMSAlert,
        [SendFeedbackEmailAlert] AS SendFeedbackEmailAlert,
        [FeedbackEmailAlert] AS FeedbackEmailAlert,
        [FeedbackNotificationAlert] AS FeedbackNotificationAlert,
        [FeedbackRedirectURL] AS FeedbackRedirectURL,
        Eg.QuestionnaireId,
        Eg.SeenClientId,
        Eg.EstablishmentGroupType,
        ISNULL(
        (
            SELECT TOP 1
                Id
            FROM dbo.AnswerMaster
            WHERE EstablishmentId = @EstablishmentId
        ),
        0
              ) AS FeedBackCount,
        ISNULL(   CAST(CASE ISNULL(Eg.EstablishmentGroupId, 0)
                           WHEN 0 THEN
                               1
                           ELSE
                               0
                       END AS BIT),
                  0
              ) AS IsTellUs,
        [SeenClientEmailSubject],
        [EscalationEmailSubject],
        [FeedbackEmailSubject],
        [FeedbackOnce],
        [mobiFormDisplayFields],
        AutoResponseMessage,
        ISNULL(ThankyouPageMessage, '') AS ThankYouPageMessage,
        SendOutNotificationAlertForAll,
        SendCaptureSMSAlert,
        CaptureSMSAlert,
        SendCaptureEmailAlert,
        CaptureEmailAlert,
        CaptureEmailSubject,
        CaptureNotificationAlert,
        OutEscalationEmailSubject,
        OutEscalationEmails,
        OutEscalationMobile,
        OutEscalationTime,
        OutEscalationSchedulerTime,
        OutEscalationSchedulerTimeString,
        OutEscalationSchedulerDay,
        CommonIntroductoryMessage,
        ResolutionFeedbackQuestion,
        ResolutionFeedbackSMS,
        ResolutionFeedbackEmail,
        ResolutionFeedbackEmailSubject,
        IsMultipleRouting,
        MultipleRoutingValue,
        ISNULL(ThankyoumessageforLessthanPI, '') AS ThankyoumessageforLessthanPI,
        ISNULL(ThankyoumessageforGretareThanPI, '') AS ThankyoumessageforGretareThanPI,
        SendTransferFormEmail,
        TransferFormEmailSubject,
        TransferFormEmail,
        SendTransferFormSMS,
        TransferFormSMS,
        DisplayGroupKeyword,
        EstablishmentSequence,
        Eg.SMSReminder AS IsSubmitAndNotify,
        dbo.Establishment.DynamicSaveButtonText AS [DynamicSaveButtonText],
        dbo.Establishment.HeaderImage AS [HeaderImage],
        ISNULL(dbo.Establishment.InEscalationOnce, 0) AS [InEscalationOnce],
        ISNULL(dbo.Establishment.OutEscalationOnce, 0) AS [OutEscalationOnce],
        ISNULL(dbo.Establishment.ISAdditionalCaptureEmail, 0) AS ISAdditionalCaptureEmail,
        ISNULL(dbo.Establishment.AdditionalCaptureEmails, '') AS AdditionalCaptureEmails,
        ISNULL(dbo.Establishment.AdditionalCaptureEmailSubject, '') AS AdditionalCaptureEmailSubject,
        ISNULL(dbo.Establishment.AdditionalCaptureEmailBody, '') AS AdditionalCaptureEmailBody,
        ISNULL(dbo.Establishment.ISAdditionalCaptureSMS, 0) AS [ISAdditionalCaptureSMS],
        ISNULL(dbo.Establishment.AdditionalCaptureMobile, '') AS AdditionalCaptureMobile,
        ISNULL(dbo.Establishment.AdditionalCaptureSMSBody, '') AS AdditionalCaptureSMSBody,
        ISNULL(dbo.Establishment.ISAdditionalFeedbackEmail, 0) AS ISAdditionalFeedbackEmail,
        ISNULL(dbo.Establishment.AdditionalFeedbackEmails, '') AS AdditionalFeedbackEmails,
        ISNULL(dbo.Establishment.AdditionalFeedbackEmailSubject, '') AS AdditionalFeedbackEmailSubject,
        ISNULL(dbo.Establishment.AdditionalFeedbackEmailBody, '') AS AdditionalFeedbackEmailBody,
        ISNULL(dbo.Establishment.ISAdditionalFeedbackSMS, 0) AS ISAdditionalFeedbackSMS,
        ISNULL(dbo.Establishment.AdditionalFeedbackMobile, '') AS AdditionalFeedbackMobile,
        ISNULL(dbo.Establishment.AdditionalFeedbackSMSBody, '') AS AdditionalFeedbackSMSBody,
        ISNULL(dbo.Establishment.StatusIconEstablishment, 0) AS StatusIconEstablishment,
        ISNULL(dbo.Establishment.ReminderNotificationCapture, 0) AS ReminderNotificationCapture,
        ISNULL(dbo.Establishment.ReminderNotificationFeedback, 0) AS ReminderNotificationFeedback,
		ISNULL(dbo.Establishment.InitiatorAsRespondent,0) AS InitiatorAsRespondent,
		ISNULL(ReleaseDateValidationMessage,'') AS ReleaseDateValidationMessage,
		ISNULL(MobiExpiredValidationMessage,'') AS MobiExpiredValidationMessage,
		ISNULL(CaptureReminderAlert,'') AS CaptureReminderAlert,
		ISNULL(FeedBackReminderAlert,'') AS FeedBackReminderAlert,
		ISNULL(CaptureUnallocatedNotificationAlert,'') AS CaptureUnallocatedNotificationAlert,
		HideClickHereButton,
		MobiLoadingPageSplashImage,
		ThankYouPageSplashImage
    FROM dbo.[Establishment]
        INNER JOIN dbo.EstablishmentGroup AS Eg
            ON dbo.Establishment.EstablishmentGroupId = Eg.Id
    WHERE dbo.[Establishment].[Id] = @EstablishmentId;

    --Get EstablishmentReminders from CaptureTaskTable
    SELECT TOP 1
        [TimeOfReminder],
        [RecurrenceType],
        [RunOn],
        [StartDate],
        [EndDate],
        [IsActive],
        [IsDeleted]
    FROM [dbo].[EstablishmentRemindersCaptureTaskTable]
    WHERE EstablishmentId = @EstablishmentId
          AND IsDeleted = 0;

    --Get EstablishmentReminders from FeedbackTaskTable
    SELECT TOP 1
        [RecurrenceType],
        [IntervalSad],
        [IntervalNeutral],
        [IntervalHappy],
        [IntervalAll],
        [IsActive]
    FROM [dbo].[EstablishmentRemindersFeedbackTaskTable]
    WHERE EstablishmentId = @EstablishmentId;

    -- Get Establishment status by establishmentid
    SELECT [Id],
           [EstablishmentId],
           [StatusName],
           [StatusIconImageId],
           [DefaultStartStatus],
           [DefaultEndStatus],
           [IsActive]
    FROM EstablishmentStatus
    WHERE EstablishmentId = @EstablishmentId
          AND IsDeleted = 0
		  ORDER BY Id ASC;
END;
