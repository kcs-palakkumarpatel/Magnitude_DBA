-- =============================================
-- Author:		Disha Patel
-- Create date: 17-JUN-2015
-- Description:	Get all details from establishment, appuser, answermaster for mobi form by answermasterid
-- Call SP    :	GetNewMobiFormDetails 70100
-- =============================================
CREATE PROCEDURE [dbo].[GetNewMobiFormDetails] @AnswerMasterId BIGINT
AS
BEGIN
    DECLARE @Url NVARCHAR(500);

    SELECT @Url = KeyValue + N'Themes/'
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'DocViewerRootFolderPathCMS';

    --SELECT  @Url = KeyValue + 'UploadFiles/Themes/'
    --   FROM    dbo.AAAAConfigSettings
    --   WHERE   KeyName = 'DocViewerRootFolderPath';

    DECLARE @EstablishmentId BIGINT;

    IF @AnswerMasterId > 0
    BEGIN
        SELECT @EstablishmentId = EstablishmentId
        FROM dbo.AnswerMaster
        WHERE Id = @AnswerMasterId;
    END;

    SELECT E.Id AS EstablishmentId,
           G.ThemeId,
           ISNULL(
           (
               SELECT TOP 1
                      @Url + CONVERT(NVARCHAR(10), TI.ThemeId) + '/ThemeMDPI/CMSLogo.png'
               FROM dbo.ThemeImage TI
               WHERE TI.ThemeId = G.ThemeId
                     AND TI.[FileName] = 'CMSLogo.png'
                     AND TI.Resolution = 'ThemeMDPI'
           ),
           ''
                 ) AS CMSLogoPath,
           ISNULL(
           (
               SELECT TOP 1
                      @Url + CONVERT(NVARCHAR(10), TI.ThemeId) + '/ThemeMDPI/mainbg.png'
               FROM dbo.ThemeImage TI
               WHERE TI.ThemeId = G.ThemeId
                     AND TI.[FileName] = 'mainbg.png'
                     AND TI.Resolution = 'ThemeMDPI'
           ),
           ''
                 ) AS MainBgPath,
           Eg.QuestionnaireId,
           E.EstablishmentName,
           E.ShowIntroductoryOnMobi,
           E.ShowSeenClientDetailsOnMobi,
           E.TimeOffSet,
           ISNULL(E.ThankYouMessage, '') AS ThankYouMessage,
           ISNULL(
           (
               SELECT TOP 1
                      @Url + CONVERT(NVARCHAR(10), TI.ThemeId) + '/ThemeMDPI/CMSFeedbackResponse.png'
               FROM dbo.ThemeImage TI
               WHERE TI.ThemeId = G.ThemeId
                     AND TI.[FileName] = 'CMSFeedbackResponse.png'
                     AND TI.Resolution = 'ThemeMDPI'
           ),
           ''
                 ) AS ThankYouImage,
           E.FeedbackRedirectURL,
           E.mobiFormDisplayFields,
           E.ThankyouPageMessage AS ThankyouPageMessage,
           E.CommonIntroductoryMessage AS CommonIndrocutoryMessage,
           E.ResolutionFeedbackQuestion AS ResolutionFeedbackQuestion
    FROM dbo.Establishment AS E
        INNER JOIN dbo.EstablishmentGroup AS Eg
            ON E.EstablishmentGroupId = Eg.Id
        INNER JOIN dbo.[Group] AS G
            ON Eg.GroupId = G.Id
    WHERE E.Id = @EstablishmentId;
END;
