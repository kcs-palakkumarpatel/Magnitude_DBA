-- =============================================
-- Author:			Sunil Vaghasiya
-- Create date:	17-Apr-2017
-- Description:	<Description,,>
-- Call SP:		GetSeenClientQuestionById 3
-- =============================================
CREATE PROCEDURE [dbo].[GetSeenClientQuestionById] @Id BIGINT
AS
    BEGIN        
        SELECT  Id ,
                SeenClientId ,
                Position ,
                QuestionTypeId ,
                QuestionTitle ,
                ShortName ,
                [Required] ,
                IsDisplayInSummary ,
                IsDisplayInDetail ,
                [MaxLength] ,
                ISNULL(Hint, '') AS Hint ,
                EscalationRegex ,
                KeyName ,
                GroupId ,
                ISNULL(OptionsDisplayType, '') AS OptionsDisplayType ,
                IsTitleBold ,
                IsTitleItalic ,
                IsTitleUnderline ,
                TitleTextColor ,
                Que.TableGroupName ,
                Margin ,
                FontSize ,
                ISNULL(ImagePath, '') AS ImagePath ,
                Que.Weight ,
                Que.WeightForYes ,
                Que.WeightForNo ,
                Que.DisplayInGraphs ,
                Que.DisplayInTableView ,
                Que.EscalationValue ,
                Que.IsCommentCompulsory,
				Que.IsDecimal,
				Que.IsRepetitive,
				Que.QuestionsGroupNo AS RepetitiveQuestionsGroupNo,
				Que.QuestionsGroupName AS RepetitiveQuestionsGroupName
        FROM    SeenClientQuestions AS Que
        WHERE   ( Id = @Id );
    END;
