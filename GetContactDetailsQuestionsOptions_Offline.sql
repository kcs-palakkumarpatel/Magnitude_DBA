-- =============================================
-- Author:		<Author,,Amit>
-- Create date: <Create Date,,02 jun 2021>
-- Description:	<Description,,>
CREATE PROCEDURE [dbo].[GetContactDetailsQuestionsOptions_Offline] 
	@GroupId BIGINT,
	@AppUserId BIGINT,
    @QuestionnaireId BIGINT,  
    @LastServerDate DATETIME = '1970-01-01 00:00:00.00'
      
AS
BEGIN

	EXEC dbo.WsGetContactDetailsByGroupId_OfflineAPI @GroupId = @GroupId,                   -- bigint
										@AppUserId = @AppUserId,                              -- bigint
										@LastServerDate = @LastServerDate;                     -- datetime

	EXEC dbo.WSGetContactFormByGroupId_OfflineAPI @GroupId = @GroupId,                   -- bigint                                    
										@LastServerDate = @LastServerDate;                     -- datetime
    

    EXEC dbo.WSGetQuestionsByQuestionnaireId_OfflineAPI @QuestionnaireId = @QuestionnaireId,               -- bigint                                                               
                                                               @LastServerDate = @LastServerDate;    -- datetime

    EXEC dbo.WSGetOptionsByQuestionnaireId_OfflineAPI @QuestionnaireId = @QuestionnaireId,               -- bigint                                                               
                                                               @LastServerDate = @LastServerDate;    -- datetime

    

END;

