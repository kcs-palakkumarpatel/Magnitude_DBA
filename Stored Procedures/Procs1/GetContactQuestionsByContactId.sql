-- =============================================
-- Author:		<Author,,GD>
-- Create date: 03-Mar-2017
-- Description:	<Description,,GetContactQuestionsById>
-- Call SP    :	GetContactQuestionsByContactId 4
-- =============================================
CREATE PROCEDURE [dbo].[GetContactQuestionsByContactId] @ContactId BIGINT
AS
    BEGIN
        DECLARE @Url NVARCHAR(150);
        SELECT  @Url = KeyValue + 'ContactQuestions/'
        FROM    dbo.AAAAConfigSettings
        WHERE   KeyName = 'DocViewerRootFolderPathCMS';

        SELECT  dbo.[ContactQuestions].[Id] AS Id ,
                dbo.[ContactQuestions].[ContactId] AS ContactId ,
                dbo.[ContactQuestions].[Position] AS Position ,
                dbo.[ContactQuestions].[QuestionTypeId] AS QuestionTypeId ,
                dbo.[QuestionType].QuestionTypeName ,
                dbo.[ContactQuestions].[QuestionTitle] AS QuestionTitle ,
                dbo.[ContactQuestions].[ShortName] AS ShortName ,
                dbo.[ContactQuestions].[Required] AS Required ,
                dbo.[ContactQuestions].[IsDisplayInSummary] AS IsDisplayInSummary ,
                dbo.[ContactQuestions].[IsDisplayInDetail] AS IsDisplayInDetail ,
                dbo.[ContactQuestions].[MaxLength] AS MaxLength ,
                dbo.[ContactQuestions].[Hint] AS Hint ,
                dbo.[ContactQuestions].[EscalationRegex] AS EscalationRegex ,
                dbo.[ContactQuestions].[KeyName] AS KeyName ,
                dbo.[ContactQuestions].[GroupId] AS GroupId ,
                dbo.[ContactQuestions].[OptionsDisplayType] AS OptionsDisplayType ,
                dbo.[ContactQuestions].[IsGroupField] AS IsGroupField ,
                dbo.[ContactQuestions].IsTitleBold ,
                dbo.[ContactQuestions].IsTitleItalic ,
                dbo.[ContactQuestions].IsTitleUnderline ,
                dbo.[ContactQuestions].TitleTextColor ,
                dbo.[ContactQuestions].TableGroupName ,
                dbo.[ContactQuestions].Margin ,
                dbo.[ContactQuestions].FontSize ,
                ISNULL(( SELECT COUNT(1)
                         FROM   SeenClientQuestions
                         WHERE  ContactQuestionId = ContactQuestions.Id
                                AND IsDeleted = 0
                       ), 0) AS ReferenceId ,
                ISNULL(ImagePath, '') AS ImagePath,
				IsCommentCompulsory AS IsCommentCompulsory,
				IsDecimal AS AllowDecimal
        FROM    dbo.[ContactQuestions]
                INNER JOIN dbo.[Contact] ON dbo.[Contact].Id = dbo.[ContactQuestions].ContactId
                INNER JOIN dbo.[QuestionType] ON dbo.[QuestionType].Id = dbo.[ContactQuestions].QuestionTypeId
        WHERE   dbo.[ContactQuestions].IsDeleted = 0
                AND [ContactId] = @ContactId
        ORDER BY Position;
    END;
