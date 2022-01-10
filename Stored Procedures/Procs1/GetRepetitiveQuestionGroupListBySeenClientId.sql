-- =============================================
-- Author:			Sunil Vaghasiya
-- Create date:	17-Apr-2017
-- Description:	<Description,,GetRepetitiveQuestionGroupListBySeenClientId>
-- Call SP    :		GetRepetitiveQuestionGroupListBySeenClientId 1898
-- =============================================
CREATE PROCEDURE dbo.GetRepetitiveQuestionGroupListBySeenClientId @SeenClientId BIGINT
AS
    BEGIN
        SELECT  QuestionsGroupNo ,
                QuestionsGroupName
        FROM    dbo.SeenClientQuestions
        WHERE   SeenClientId = @SeenClientId
                AND ISNULL(IsRepetitive, 0) = 1
				AND IsDeleted =0
        GROUP BY QuestionsGroupNo ,
                QuestionsGroupName;
    END;
