-- =============================================
-- Author:		Disha Patel
-- Create date: 17-JUN-2015
-- Description:	Get all details from establishment, appuser, answermaster for mobi form by answermasterid
-- Call SP    :	GetCustomerFormDetails 88781,0, 0,1
-- =============================================
CREATE PROCEDURE [dbo].[GetCustomerFormDetails]
    @SeenClientAnswerMasterId BIGINT ,
    @EstablishmentId BIGINT,
	@SeenclientChildId BIGINT = 0,
	@IsOut NVARCHAR(5)
AS
    BEGIN
        DECLARE @Url NVARCHAR(500);
        SELECT  @Url = KeyValue + 'Themes/'
        FROM    dbo.AAAAConfigSettings
        WHERE   KeyName = 'DocViewerRootFolderPathCMS';

		 --SELECT  @Url = KeyValue + 'UploadFiles/Themes/'
   --     FROM    dbo.AAAAConfigSettings
   --     WHERE   KeyName = 'DocViewerRootFolderPath';

        IF @SeenClientAnswerMasterId > 0
		    BEGIN
        IF (@IsOut = '1')
        BEGIN
		PRINT 1
            SELECT @EstablishmentId = EstablishmentId
            FROM dbo.SeenClientAnswerMaster
            WHERE Id = @SeenClientAnswerMasterId;
        END;
        ELSE
        BEGIN
		PRINT 0
            SELECT @EstablishmentId = EstablishmentId
            FROM dbo.AnswerMaster
            WHERE Id = @SeenClientAnswerMasterId;
        END;
    END;
	 IF (@IsOut = '1')
	 BEGIN
        SELECT  E.Id AS EstablishmentId ,
                ISNULL(SAM.Id, 0) AS SeenClientAnswerMasterId ,
                ISNULL(U.Id, 0) AS AppUserId ,
                G.ThemeId ,
                ISNULL(( SELECT TOP 1
                                @Url + CONVERT(NVARCHAR(10), TI.ThemeId)
                                + '/ThemeMDPI/CMSLogo.png'
                         FROM   dbo.ThemeImage TI
                         WHERE  TI.ThemeId = G.ThemeId
                                AND TI.[FileName] = 'CMSLogo.png'
                                AND TI.Resolution = 'ThemeMDPI'
                       ), '') AS CMSLogoPath ,
                ISNULL(( SELECT TOP 1
                                @Url + CONVERT(NVARCHAR(10), TI.ThemeId)
                                + '/ThemeMDPI/mainbg.png'
                         FROM   dbo.ThemeImage TI
                         WHERE  TI.ThemeId = G.ThemeId
                                AND TI.[FileName] = 'mainbg.png'
                                AND TI.Resolution = 'ThemeMDPI'
                       ), '') AS MainBgPath ,
                Eg.QuestionnaireId ,
                E.EstablishmentName ,
                CASE E.ShowIntroductoryOnMobi
                  WHEN 1 THEN case when @SeenClientAnswerMasterId > 0 then dbo.IntroductoryMessage(ISNULL(SAM.Id, 0),@SeenclientChildId) else E.IntroductoryMessage end 
                  ELSE '' 
                END AS IntroductoryMessage ,
                E.ShowIntroductoryOnMobi ,
                E.ShowSeenClientDetailsOnMobi ,
                ISNULL(U.Name, '') AS NAME ,
                E.TimeOffSet ,
                ISNULL(E.ThankYouMessage, '') AS ThankYouMessage ,
				ISNULL(( SELECT TOP 1
                                @Url + CONVERT(NVARCHAR(10), TI.ThemeId)
                                + '/ThemeMDPI/CMSFeedbackResponse.png'
                         FROM   dbo.ThemeImage TI
                         WHERE  TI.ThemeId = G.ThemeId
                                AND TI.[FileName] = 'CMSFeedbackResponse.png'
                                AND TI.Resolution = 'ThemeMDPI'
                       ), '') AS ThankYouImage ,
					   ISNULL(( SELECT TOP 1
                                @Url + CONVERT(NVARCHAR(10), TI.ThemeId)
                                + '/ThemeMDPI/CMSFeedbackResponseNegative.png'
                         FROM   dbo.ThemeImage TI
                         WHERE  TI.ThemeId = G.ThemeId
                                AND TI.[FileName] = 'CMSFeedbackResponseNegative.png'
                                AND TI.Resolution = 'ThemeMDPI'
                       ), '') AS ThankYouNagetiveImage ,
					   ISNULL(( SELECT TOP 1
                                @Url + CONVERT(NVARCHAR(10), TI.ThemeId)
                                + '/ThemeMDPI/CMSFeedbackResponsePositive.png'
                         FROM   dbo.ThemeImage TI
                         WHERE  TI.ThemeId = G.ThemeId
                                AND TI.[FileName] = 'CMSFeedbackResponsePositive.png'
                                AND TI.Resolution = 'ThemeMDPI'
                       ), '') AS ThankYouPositiveImage ,
                E.FeedbackRedirectURL ,
                E.mobiFormDisplayFields,
				E.ThankyouPageMessage AS ThankyouPageMessage,
				e.CommonIntroductoryMessage AS CommonIndrocutoryMessage,
				e.ThankyoumessageforLessthanPI AS ThankYouMessageForNegativePI,
				e.ThankyoumessageforGretareThanPI AS ThankYouMessageForPositivePI,
				e.FeedbackOnce AS FeedbackOnce,
				eg.QuestionnaireId AS QuestionnaireId,
				Eg.CustomerQuestion AS CustomerFormDisplayFields,
				Eg.ShowQueastionCustomer AS ShowQueastionCustomer,
				Eg.EstablishmentGroupName AS EstablishmentGroupName,
				SAM.PI AS PI,
				IsNull(Eg.DirectRespondentForm,0) AS DirectRespondentForm,
				IsNull(Eg.InFormRefNumber,0) AS InFormRefNumber,
				ISNUll(Eg.ShowHideChatforCustomer, 0) AS ShowHideChat,
				dbo.ChangeDateFormat(DATEADD(MINUTE, SAM.TimeOffSet,
                                             SAM.CreatedOn),
                                     'dd/MMM/yyyy HH:mm AM/PM') AS CaptureDate ,
				 U.Name + ' To ' + CASE WHEN ISNULL(SAM.ContactGroupId,0) > 0 THEN ISNULL((SELECT ContactGropName FROM dbo.ContactGroup WHERE id = SAM.ContactGroupId),'') ELSE (SELECT LEFT(ISNULL((select dbo.ConcateString ('ContactSummary',SAM.ContactMasterId)),0), CHARINDEX(',', ISNULL((select dbo.ConcateString ('ContactSummary',SAM.ContactMasterId)),0)) - 0)) end AS UserName 
        FROM    dbo.Establishment AS E
                INNER JOIN dbo.EstablishmentGroup AS Eg ON E.EstablishmentGroupId = Eg.Id
                INNER JOIN dbo.[Group] AS G ON Eg.GroupId = G.Id
                LEFT OUTER JOIN dbo.SeenClientAnswerMaster AS SAM ON SAM.EstablishmentId = E.Id
                                                              AND SAM.Id = @SeenClientAnswerMasterId
                                                              AND SAM.EstablishmentId = @EstablishmentId
                LEFT OUTER JOIN dbo.AppUser AS U ON SAM.AppUserId = U.Id
        WHERE   E.Id = @EstablishmentId;
		END
		ELSE
		BEGIN
		 SELECT  E.Id AS EstablishmentId ,
                ISNULL(SAM.Id, 0) AS SeenClientAnswerMasterId ,
                ISNULL(U.Id, 0) AS AppUserId ,
                G.ThemeId ,
                ISNULL(( SELECT TOP 1
                                @Url + CONVERT(NVARCHAR(10), TI.ThemeId)
                                + '/ThemeMDPI/CMSLogo.png'
                         FROM   dbo.ThemeImage TI
                         WHERE  TI.ThemeId = G.ThemeId
                                AND TI.[FileName] = 'CMSLogo.png'
                                AND TI.Resolution = 'ThemeMDPI'
                       ), '') AS CMSLogoPath ,
                ISNULL(( SELECT TOP 1
                                @Url + CONVERT(NVARCHAR(10), TI.ThemeId)
                                + '/ThemeMDPI/mainbg.png'
                         FROM   dbo.ThemeImage TI
                         WHERE  TI.ThemeId = G.ThemeId
                                AND TI.[FileName] = 'mainbg.png'
                                AND TI.Resolution = 'ThemeMDPI'
                       ), '') AS MainBgPath ,
                Eg.QuestionnaireId ,
                E.EstablishmentName ,
                CASE E.ShowIntroductoryOnMobi
                  WHEN 1 THEN case when @SeenClientAnswerMasterId > 0 then dbo.IntroductoryMessage(ISNULL(SAM.Id, 0),@SeenclientChildId) else E.IntroductoryMessage end 
                  ELSE '' 
                END AS IntroductoryMessage ,
                E.ShowIntroductoryOnMobi ,
                E.ShowSeenClientDetailsOnMobi ,
                ISNULL(U.Name, '') AS NAME ,
                E.TimeOffSet ,
                ISNULL(E.ThankYouMessage, '') AS ThankYouMessage ,
				ISNULL(( SELECT TOP 1
                                @Url + CONVERT(NVARCHAR(10), TI.ThemeId)
                                + '/ThemeMDPI/CMSFeedbackResponse.png'
                         FROM   dbo.ThemeImage TI
                         WHERE  TI.ThemeId = G.ThemeId
                                AND TI.[FileName] = 'CMSFeedbackResponse.png'
                                AND TI.Resolution = 'ThemeMDPI'
                       ), '') AS ThankYouImage ,
					   ISNULL(( SELECT TOP 1
                                @Url + CONVERT(NVARCHAR(10), TI.ThemeId)
                                + '/ThemeMDPI/CMSFeedbackResponseNegative.png'
                         FROM   dbo.ThemeImage TI
                         WHERE  TI.ThemeId = G.ThemeId
                                AND TI.[FileName] = 'CMSFeedbackResponseNegative.png'
                                AND TI.Resolution = 'ThemeMDPI'
                       ), '') AS ThankYouNagetiveImage ,
					   ISNULL(( SELECT TOP 1
                                @Url + CONVERT(NVARCHAR(10), TI.ThemeId)
                                + '/ThemeMDPI/CMSFeedbackResponsePositive.png'
                         FROM   dbo.ThemeImage TI
                         WHERE  TI.ThemeId = G.ThemeId
                                AND TI.[FileName] = 'CMSFeedbackResponsePositive.png'
                                AND TI.Resolution = 'ThemeMDPI'
                       ), '') AS ThankYouPositiveImage ,
                E.FeedbackRedirectURL ,
                E.mobiFormDisplayFields,
				E.ThankyouPageMessage AS ThankyouPageMessage,
				e.CommonIntroductoryMessage AS CommonIndrocutoryMessage,
				e.ThankyoumessageforLessthanPI AS ThankYouMessageForNegativePI,
				e.ThankyoumessageforGretareThanPI AS ThankYouMessageForPositivePI,
				e.FeedbackOnce AS FeedbackOnce,
				eg.QuestionnaireId AS QuestionnaireId,
				Eg.CustomerQuestion AS CustomerFormDisplayFields,
				Eg.ShowQueastionCustomer AS ShowQueastionCustomer,
				Eg.EstablishmentGroupName AS EstablishmentGroupName,
				SAM.PI AS PI,
				IsNull(Eg.DirectRespondentForm,0) AS DirectRespondentForm,
				IsNull(Eg.InFormRefNumber,0) AS InFormRefNumber,
				ISNUll(Eg.ShowHideChatforCustomer, 0) AS ShowHideChat,
				dbo.ChangeDateFormat(DATEADD(MINUTE, SAM.TimeOffSet,
                                             SAM.CreatedOn),
                                     'dd/MMM/yyyy HH:mm AM/PM') AS CaptureDate ,
				 U.Name AS UserName 
        FROM    dbo.Establishment AS E
                INNER JOIN dbo.EstablishmentGroup AS Eg ON E.EstablishmentGroupId = Eg.Id
                INNER JOIN dbo.[Group] AS G ON Eg.GroupId = G.Id
                LEFT OUTER JOIN dbo.AnswerMaster AS SAM ON SAM.EstablishmentId = E.Id
                                                              AND SAM.Id = @SeenClientAnswerMasterId
                                                              AND SAM.EstablishmentId = @EstablishmentId
                LEFT OUTER JOIN dbo.AppUser AS U ON SAM.AppUserId = U.Id
        WHERE   E.Id = @EstablishmentId;
		END
    END;
