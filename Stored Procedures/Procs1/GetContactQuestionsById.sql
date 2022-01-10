-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,, 15 Jun 2015>
-- Description:	<Description,,GetContactQuestionsById>
-- Call SP    :	GetContactQuestionsById
-- =============================================
CREATE PROCEDURE [dbo].[GetContactQuestionsById] @Id BIGINT
AS
    BEGIN
        SELECT  [Id] AS Id ,
                [ContactId] AS ContactId ,
                [Position] AS Position ,
                [QuestionTypeId] AS QuestionTypeId ,
                [QuestionTitle] AS QuestionTitle ,
                [ShortName] AS ShortName ,
                [Required] AS Required ,
                [IsDisplayInSummary] AS IsDisplayInSummary ,
                [IsDisplayInDetail] AS IsDisplayInDetail ,
                [MaxLength] AS MaxLength ,
                [Hint] AS Hint ,
                [EscalationRegex] AS EscalationRegex ,
                [KeyName] AS KeyName ,
                [GroupId] AS GroupId ,
                ISNULL([OptionsDisplayType], '') AS OptionsDisplayType ,
                [IsGroupField] AS IsGroupField ,
                IsTitleBold ,
                IsTitleItalic ,
                IsTitleUnderline ,
                TitleTextColor ,
                TableGroupName ,
                Margin ,
                FontSize ,
                ISNULL(ImagePath, '') AS ImagePath,
				IsCommentCompulsory AS IsCommentCompulsory
        FROM    dbo.[ContactQuestions]
        WHERE   [Id] = @Id;
    END;