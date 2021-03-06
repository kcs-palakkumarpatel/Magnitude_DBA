--GetMobiFormDetails_New 654878,0, 0


-- =============================================  
-- Author:  Disha Patel  
-- Create date: 17-JUN-2015  
-- Description: Get all details from establishment, appuser, answermaster for mobi form by answermasterid  
-- Call SP    : GetMobiFormDetails 0,11646, 0  
-- =============================================  
CREATE PROCEDURE [dbo].[GetMobiFormDetails_New]  
	@SeenClientAnswerMasterId BIGINT,  
    @EstablishmentId BIGINT,  
    @SeenclientChildId BIGINT
	AS  
BEGIN  
    DECLARE @Url NVARCHAR(500);  
    SELECT @Url = KeyValue + 'Themes/'  
    FROM dbo.AAAAConfigSettings  
    WHERE KeyName = 'DocViewerRootFolderPathCMS';  
  
    DECLARE @HeaderUrl NVARCHAR(500);  
    SELECT @HeaderUrl = KeyValue + 'MobiHeaderImage/'  
    FROM dbo.AAAAConfigSettings  
    WHERE KeyName = 'DocViewerRootFolderPathCMS';  
  
    --SELECT  @Url = KeyValue + 'UploadFiles/Themes/'  
    --     FROM    dbo.AAAAConfigSettings  
    --     WHERE   KeyName = 'DocViewerRootFolderPath';  
  
    IF @SeenClientAnswerMasterId > 0  
    BEGIN  
        SELECT @EstablishmentId = EstablishmentId  
        FROM dbo.SeenClientAnswerMaster  
        WHERE Id = @SeenClientAnswerMasterId;  
    END;  
  
    SELECT E.Id AS EstablishmentId,  
           ISNULL(SAM.Id, 0) AS SeenClientAnswerMasterId,  
           ISNULL(U.Id, 0) AS AppUserId,  
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
           CASE E.ShowIntroductoryOnMobi  
               WHEN 1 THEN  
                   CASE  
                       WHEN @SeenClientAnswerMasterId > 0 THEN  
                           dbo.IntroductoryMessage(ISNULL(SAM.Id, 0), @SeenclientChildId)  
                       ELSE  
                           E.IntroductoryMessage  
                   END  
               ELSE  
                   ''  
           END AS IntroductoryMessage,  
           E.ShowIntroductoryOnMobi,  
           E.ShowSeenClientDetailsOnMobi,  
           ISNULL(U.Name, '') AS NAME,  
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
           ISNULL(  
           (  
               SELECT TOP 1  
                   @Url + CONVERT(NVARCHAR(10), TI.ThemeId) + '/ThemeMDPI/CMSFeedbackResponseNegative.png'  
               FROM dbo.ThemeImage TI  
               WHERE TI.ThemeId = G.ThemeId  
                     AND TI.[FileName] = 'CMSFeedbackResponseNegative.png'  
                     AND TI.Resolution = 'ThemeMDPI'  
           ),  
           ''  
                 ) AS ThankYouNagetiveImage,  
           ISNULL(  
           (  
               SELECT TOP 1  
                   @Url + CONVERT(NVARCHAR(10), TI.ThemeId) + '/ThemeMDPI/CMSFeedbackResponsePositive.png'  
               FROM dbo.ThemeImage TI  
               WHERE TI.ThemeId = G.ThemeId  
                     AND TI.[FileName] = 'CMSFeedbackResponsePositive.png'  
                     AND TI.Resolution = 'ThemeMDPI'  
           ),  
           ''  
                 ) AS ThankYouPositiveImage,  
           E.FeedbackRedirectURL,  
           E.mobiFormDisplayFields,  
           E.ThankyouPageMessage AS ThankyouPageMessage,  
           E.CommonIntroductoryMessage AS CommonIndrocutoryMessage,  
           E.ThankyoumessageforLessthanPI AS ThankYouMessageForNegativePI,  
           E.ThankyoumessageforGretareThanPI AS ThankYouMessageForPositivePI,  
           E.FeedbackOnce AS FeedbackOnce,  
           Eg.QuestionnaireId AS QuestionnaireId,  
           ISNULL(Q.ControlStyleId, 1) AS [ControlStyleId],  
           ISNULL(CS.ControlStyleName, 'Advance') AS [ControlStyleName],  
           E.DynamicSaveButtonText AS [DynamicSaveButtonText],  
           CASE E.HeaderImage  
               WHEN NULL THEN  
                   NULL  
               ELSE  
                   @HeaderUrl + E.HeaderImage  
           END AS [HeaderImage],  
     Eg.InitiatorFormTitle AS [InitiatorFormTitle]  
    FROM dbo.Establishment AS E  
        INNER JOIN dbo.EstablishmentGroup AS Eg  
            ON E.EstablishmentGroupId = Eg.Id  and E.Id = @EstablishmentId
        INNER JOIN dbo.[Group] AS G  
            ON Eg.GroupId = G.Id  
        INNER JOIN dbo.Questionnaire AS Q  
            ON Eg.QuestionnaireId = Q.Id  
        INNER JOIN dbo.ControlStyle AS CS  
            ON ISNULL(Q.ControlStyleId, 1) = CS.Id  
        LEFT OUTER JOIN dbo.SeenClientAnswerMaster AS SAM  
            ON SAM.Id = @SeenClientAnswerMasterId  
               AND SAM.EstablishmentId = @EstablishmentId  
        LEFT OUTER JOIN dbo.AppUser AS U  
            ON SAM.AppUserId = U.Id  
   ;  
  
--IF ( @SeenClientAnswerMasterId = 0 )   
--    BEGIN  
--        SELECT  E.Id AS EstablishmentId ,  
--                0 AS SeenClientAnswerMasterId ,  
--                0 AS AppUserId ,  
--                G.ThemeId ,  
--                ISNULL(( SELECT TOP 1  
--                                @Url  
--                                + CONVERT(NVARCHAR(10), TI.ThemeId)  
--                                + '/ThemeMDPI/CMSLogo.png'  
--                         FROM   dbo.ThemeImage TI  
--                         WHERE  TI.ThemeId = G.ThemeId  
--                                AND TI.[FileName] = 'CMSLogo.png'  
--                                AND TI.Resolution = 'ThemeMDPI'  
--                       ), '') AS CMSLogoPath ,  
--                ISNULL(( SELECT TOP 1  
--                                @Url  
--                                + CONVERT(NVARCHAR(10), TI.ThemeId)  
--                                + '/ThemeMDPI/mainbg.png'  
--                         FROM   dbo.ThemeImage TI  
--                         WHERE  TI.ThemeId = G.ThemeId  
--                                AND TI.[FileName] = 'mainbg.png'  
--                                AND TI.Resolution = 'ThemeMDPI'  
--                       ), '') AS MainBgPath ,  
--                EG.QuestionnaireId ,  
--                E.EstablishmentName ,  
--                ISNULL(E.IntroductoryMessage, '') AS IntroductoryMessage ,  
--                E.ShowIntroductoryOnMobi ,  
--                E.ShowSeenClientDetailsOnMobi ,  
--                '' AS Name  
--        FROM    dbo.Establishment E  
--                INNER JOIN dbo.EstablishmentGroup EG ON EG.Id = E.EstablishmentGroupId  
--                INNER JOIN dbo.[Group] G ON G.Id = E.GroupId  
--        WHERE   E.Id = @EstablishmentId  
--                AND E.IsDeleted = 0  
--                AND G.IsDeleted = 0  
--    END  
--ELSE   
--    BEGIN  
--        SELECT  SAM.EstablishmentId ,  
--                SAM.Id AS SeenClientAnswerMasterId ,  
--                SAM.AppUserId ,  
--                G.ThemeId ,  
--                ISNULL(( SELECT TOP 1  
--                                @Url  
--                                + CONVERT(NVARCHAR(10), TI.ThemeId)  
--                                + '/ThemeMDPI/CMSLogo.png'  
--                         FROM   dbo.ThemeImage TI  
--                         WHERE  TI.ThemeId = G.ThemeId  
--                                AND TI.[FileName] = 'CMSLogo.png'  
--                                AND TI.Resolution = 'ThemeMDPI'  
--                       ), '') AS CMSLogoPath ,  
--                ISNULL(( SELECT TOP 1  
--                                @Url  
--                                + CONVERT(NVARCHAR(10), TI.ThemeId)  
--                                + '/ThemeMDPI/mainbg.png'  
--                         FROM   dbo.ThemeImage TI  
--                         WHERE  TI.ThemeId = G.ThemeId  
--                                AND TI.[FileName] = 'mainbg.png'  
--                                AND TI.Resolution = 'ThemeMDPI'  
--                       ), '') AS MainBgPath ,  
--                EG.QuestionnaireId ,  
--                E.EstablishmentName ,  
--                ISNULL(E.IntroductoryMessage, '') AS IntroductoryMessage ,  
--                E.ShowIntroductoryOnMobi ,  
--                E.ShowSeenClientDetailsOnMobi ,  
--                ISNULL(AU.Name, '') AS Name  
--        FROM    dbo.Establishment E  
--                INNER JOIN dbo.EstablishmentGroup EG ON EG.Id = E.EstablishmentGroupId  
--                INNER JOIN dbo.[Group] G ON G.Id = E.GroupId  
--                INNER JOIN dbo.SeenClientAnswerMaster SAM ON SAM.EstablishmentId = E.Id  
--                LEFT OUTER JOIN dbo.AppUser AU ON SAM.AppUserId = AU.Id  
--                                                  AND AU.IsDeleted = 0  
--        WHERE   SAM.Id = @SeenClientAnswerMasterId  
--                AND E.IsDeleted = 0  
--                AND SAM.IsDeleted = 0  
--                AND G.IsDeleted = 0  
--    END  
  
  
END;  