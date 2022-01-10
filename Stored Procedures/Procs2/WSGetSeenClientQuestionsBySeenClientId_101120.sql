-- =============================================
-- Author:			Sunil Vaghasiya
-- Create date:	18-Apr-2017
-- Description:	Get Capture Form Questions List by Capture ID
-- =============================================
/*
drop procedure WSGetSeenClientQuestionsBySeenClientId_101120

Exec WSGetSeenClientQuestionsBySeenClientId_101120 655, 1109, 0, ''
*/
CREATE PROCEDURE [dbo].[WSGetSeenClientQuestionsBySeenClientId_101120]
	@SeenClientId BIGINT ,
	@ContactMasterId BIGINT ,
	@IsContactGroup BIT ,
	@ContactMasterIdList NVARCHAR(MAX)
AS
BEGIN
	
	DECLARE @Url NVARCHAR(150);

	SELECT  @Url = KeyValue + 'SeenClientQuestions/'
    FROM    dbo.AAAAConfigSettings
    WHERE   KeyName = 'DocViewerRootFolderPathCMS';

	SELECT  Q.Id AS QuestionId ,
        Q.QuestionTypeId ,
        Q.QuestionTitle ,
        Q.ShortName ,
        Q.[Required] ,
        Q.[MaxLength] ,
        ISNULL(Hint, '') AS Hint ,
        ISNULL(OptionsDisplayType, '') AS OptionsDisplayType ,
        Q.IsTitleBold ,
        Q.IsTitleItalic ,
        Q.IsTitleUnderline ,
        TitleTextColor ,
        Q.Position ,
        Q.EscalationRegex ,
        ISNULL(Q.ContactQuestionId, 0) AS ContactQuestionId ,
        CASE WHEN @ContactMasterIdList = '' THEN ISNULL(Cd.Detail, '')
         ELSE CASE WHEN Q.QuestionTypeId IN ( 4, 10, 11 )
         THEN ISNULL(dbo.ConcateString3Param('ContactGroupDetail',@ContactMasterId,Q.ContactQuestionId,@ContactMasterIdList),'')
              ELSE ISNULL(Cd.Detail, '') END
		END AS Detail ,
		Margin ,
		FontSize ,
		ISNULL(@Url + ImagePath, '') AS ImagePath,
		Q.IsDisplayInDetail AS DisplayInDetail,
		Q.IsRepetitive AS IsRepetitive,
		ISNULL(Q.QuestionsGroupNo, 0) AS QuestionsGroupNo,
		ISNULL(Q.QuestionsGroupName, '') AS QuestionsGroupName,
		Q.IsDisplayInSummary AS DisplayInList,
		Q.IsCommentCompulsory AS IsCommentCompulsory,
		Q.IsDecimal AS IsDecimal,
		Q.IsSignature AS IsSignature,
		Q.ImageHeight AS Imageheight,
		Q.ImageWidth AS ImageWidth,
		Q.ImageAlign AS ImageAlign,
		Q.isRoutingOnGroup AS isRoutingOnGroup,
		Q.ChildPosition AS ChildPosition,
		ISNULL(Q.IsValidateUsingQR,0) as isQRType
	FROM dbo.SeenClientQuestions AS Q
    LEFT OUTER JOIN dbo.ContactDetails Cd ON Cd.ContactQuestionId = Q.ContactQuestionId
		AND Cd.ContactMasterId = CASE WHEN @IsContactGroup = 0 THEN @ContactMasterId
              ELSE ( SELECT TOP 1 ContactMasterId FROM dbo.ContactGroupRelation
                     WHERE ContactGroupId = @ContactMasterId) END
	WHERE Q.IsDeleted = 0
    AND SeenClientId = @SeenClientId
    AND Q.IsActive = 1
    ORDER BY Q.Position, Q.ChildPosition ASC;
END;

