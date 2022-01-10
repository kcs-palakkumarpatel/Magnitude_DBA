
-- =============================================
-- Author:		<Author,,ADMIN>
-- Create date: <Create Date,, 26 May 2015>
-- Description:	<Description,,GetQuestionsById>
-- Call SP    :	GetQuestionsById
-- =============================================
CREATE PROCEDURE [dbo].[GetQuestionsById] @Id BIGINT
AS
    BEGIN
        SELECT  [Id] AS Id ,
                [QuestionnaireId] AS QuestionnaireId ,
                [Position] AS Position ,
                [QuestionTypeId] AS QuestionTypeId ,
                [QuestionTitle] AS QuestionTitle ,
                [ShortName] AS ShortName ,
                [IsActive] AS IsActive ,
                [Required] AS Required ,
                [IsDisplayInSummary] AS IsDisplayInSummary ,
                [IsDisplayInDetail] AS IsDisplayInDetail ,
                [MaxLength] AS MaxLength ,
                [Hint] AS Hint ,
                [EscalationRegex] AS EscalationRegex ,
                [OptionsDisplayType] AS OptionsDisplayType ,
                [SeenClientQuestionIdRef] AS SeenClientQuestionIdRef ,
                IsTitleBold ,
                IsTitleItalic ,
                IsTitleUnderline ,
                TitleTextColor ,
                TableGroupName ,
                Margin ,
                FontSize ,
                ISNULL(ImagePath, '') AS ImagePath,
				IsCommentCompulsory AS IsCommentCompulsory,
				IsAnonymous AS IsAnonymous
        FROM    dbo.[Questions]
        WHERE   [Id] = @Id;
    END;