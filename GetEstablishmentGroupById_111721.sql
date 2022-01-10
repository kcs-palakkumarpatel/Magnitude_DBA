
-- =============================================
-- Author:			Sunil Vaghasiya
-- Create date:	02-Mar-2017
-- Description:	<Description,,GetEstablishmentGroupById>
-- Call SP    :	dbo.GetEstablishmentGroupById 1
-- =============================================
CREATE PROCEDURE [dbo].[GetEstablishmentGroupById_111721] @Id BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @SeenClientAndId BIGINT,
            @AnsId BIGINT;

    SELECT TOP 1
        @AnsId = Id
    FROM dbo.AnswerMaster WITH (NOLOCK)
    WHERE QuestionnaireId IN (
                                 SELECT QuestionnaireId
                                 FROM dbo.EstablishmentGroup WITH (NOLOCK)
                                 WHERE Id = @Id
                             )
          AND IsDeleted = 0
          AND EstablishmentId IN (
                                     SELECT Id
                                     FROM dbo.Establishment WITH (NOLOCK)
                                     WHERE EstablishmentGroupId = @Id
                                           AND IsDeleted = 0
                                 );

    SELECT TOP 1
        @SeenClientAndId = Id
    FROM dbo.SeenClientAnswerMaster WITH (NOLOCK)
    WHERE SeenClientId IN (
                              SELECT SeenClientId
                              FROM dbo.EstablishmentGroup WITH (NOLOCK)
                              WHERE Id = @Id
                                    AND SeenClientId IS NOT NULL
                          )
          AND IsDeleted = 0
          AND EstablishmentId IN (
                                     SELECT Id
                                     FROM dbo.Establishment WITH (NOLOCK)
                                     WHERE EstablishmentGroupId = @Id
                                           AND IsDeleted = 0
                                 );

    SELECT Eg.[Id] AS Id,
           [GroupId] AS GroupId,
           [EstablishmentGroupName] AS EstablishmentGroupName,
           [EstablishmentGroupType] AS EstablishmentGroupType,
           [AboutEstablishmentGroup] AS AboutEstablishmentGroup,
           [QuestionnaireId] AS QuestionnaireId,
           [SeenClientId] AS SeenClientId,
           [HowItWorksId] AS HowItWorksId,
           [SMSReminder] AS SMSReminder,
           [EmailReminder] AS EmailReminder,
           [EstablishmentGroupId] AS EstablishmentGroupId,
           ISNULL(   CAST(CASE ISNULL(EstablishmentGroupId, 0)
                              WHEN 0 THEN
                                  1
                              ELSE
                                  0
                          END AS BIT),
                     0
                 ) AS IsTellUs,
           Eg.AllowToChangeDelayTime,
           Eg.DelayTime,
           Eg.AllowRecurring,
           ISNULL(@AnsId, 0) AS CanEditQuestionnaire,
           ISNULL(@SeenClientAndId, 0) AS CanEditSeenClient,
           [ThemeMDPI] AS ThemeMDPI,
           [ThemeHDPI] AS ThemeHDPI,
           [ThemeXHDPI] AS ThemeXHDPI,
           [ThemeXXHDPI] AS ThemeXXHDPI,
           [Theme640x960] AS Theme640x960,
           [Theme640x1136] AS Theme640x1136,
           [Theme768x1280] AS Theme768x1280,
           Eg.Theme750x1334,
           Eg.Theme1242x2208,
           Eg.SmileOn,
           Eg.SadFrom,
           Eg.SadTo,
           Eg.NeutralFrom,
           Eg.NeutralTo,
           Eg.HappyFrom,
           Eg.HappyTo,
           Eg.ReportingToEmail,
           Eg.ContactQuestion,
           Eg.AutoReportEnable,
           Eg.AutoReportSchedulerId,
           Eg.ActivitySmilePeriod,
           Eg.IsConfugureManualImage,
           Eg.ConfigureImagePath AS ImagePath,
           Eg.BackgroundColor,
           Eg.BorderColor,
           Eg.ConfigureImageName AS ImageName,
           Eg.IsAutoResolved AS AutoResolved,
           ISNULL(Eg.ConfigureImageSequence,0) AS [Sequence],
           ISNULL(Eg.DisplaySequence,0) AS [DisplaySequence],
           Eg.IsGroupKeyword AS [IsGroupKeyword],
           Eg.IsGroupSearch AS [IsGroupSearch],
           ISNULL(GP.ContactId, 0) AS ContactFormId,
           Eg.AttachmentLimit AS AttachmentLimit,
           Eg.AutoSaveLimit AS AutoSaveLimit,
           ISNULL(Eg.PIStatus,0) AS PIStatus,
           ISNULL(Eg.PIOutStatus,0) AS PIOutStatus,
           Eg.ActivityImagePath AS ActivityImagePath,
           ISNULL(Eg.CustomerSMSAlert, 0) AS CustomerSMSAlert,
           Eg.CustomerSMSText AS CustomerSMSText,
           ISNULL(Eg.CustomerEmailAlert, 0) AS CustomerEmailAlert,
           Eg.CustomerEmailSubject AS CustomerEmailSubject,
           Eg.CustomerEmailText AS CustomerEmailText,
           Eg.CustomerQuestion AS CustomerQuestion,
           Eg.ShowQueastionCustomer AS ShowQueastionCustomer,
           ISNULL(Eg.DirectRespondentForm, 0) AS DirectRespondentForm,
           ISNULL(Eg.IncludeEmailAttachments, 0) AS IncludeEmailAttachments,
           ISNULL(Eg.InFormRefNumber, 0) AS InFormRefNumber,
           ISNULL(Eg.ShowHideChatforCustomer, 0) AS ShowHideChat,
           Eg.InitiatorFormTitle,
           ISNULL(Eg.AllowToRefreshTheTaskDaily, 0) AS AllowToRefreshTheTaskDaily,
           ISNULL(Eg.AllowTaskAllocations, 0) AS AllowTaskAllocations
    FROM dbo.[EstablishmentGroup] AS Eg WITH (NOLOCK)
        INNER JOIN dbo.[Group] AS GP WITH (NOLOCK)
            ON GP.Id = Eg.GroupId
    WHERE Eg.[Id] = @Id;
END;
