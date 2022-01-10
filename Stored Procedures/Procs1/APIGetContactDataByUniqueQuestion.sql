-- =============================================
-- Author:			Developer D3
-- Create date:	31-MAY-2017
-- Description:	Get Contact Answers Data from for Web API Using MerchantKey(GroupId)
-- Call:					dbo.APIGetContactDataByUniqueQuestion 534,99700068,3245,0
-- =============================================
CREATE PROCEDURE [dbo].[APIGetContactDataByUniqueQuestion]
    (
	  @GroupId BIGINT = 0,
	  @SearchText NVARCHAR(100) ='',
	  @formId  BIGINT = 0,
	  @isCapture BIT
	)
AS
BEGIN
    SET NOCOUNT OFF;
	DECLARE @ContactMasterId BIGINT = 0;
    SET @ContactMasterId = (Select top 1 ContactMasterID from ContactDetails where Lower(Detail) = Lower(@SearchText) and IsDeleted = 0);
IF (@ContactMasterId > 0 )
BEGIN
IF(@isCapture = 0 )
BEGIN
Select  DISTINCT
				
					Q.id as QuestionId,
					CD.Detail As Answer
					FROM 
					Answers A LEFT JOIN Questions Q  ON A.QuestionId = Q.ContactQuestionIdRef
					LEFT JOIN ContactDetails CD ON CD.ContactQuestionId = Q.ContactQuestionIdRef
					LEFT JOIN ContactMaster CM ON CM.Id = CD.ContactMasterId
					WHERE 
					Q.QuestionnaireId = @formId
					and Q.ContactQuestionIdRef > 0
					AND CM.ID = @ContactMasterId
					AND CD.IsDeleted = 0
					AND Q.IsDeleted = 0
					AND CM.IsDeleted = 0
					AND CD.Detail != @SearchText
					AND CM.GroupId = @GroupId			
					ORDER BY Q.Id ASC
END
ELSE
BEGIN
					SELECT 
					SCQ.id as QuestionId,
					SCA.Detail As Answer
					FROM 
					SeenClientAnswers SCA LEFT JOIN SeenClientQuestions SCQ ON SCA.QuestionId = SCQ.id
					LEFT JOIN ContactDetails CD ON CD.ContactQuestionId = SCQ.ContactQuestionId
					LEFT JOIN ContactMaster CM ON CM.Id = CD.ContactMasterId
					WHERE 
					SCQ.SeenClientId = @formId
					and SCQ.ContactQuestionId > 0
					AND CM.ID = @ContactMasterId
					AND CD.IsDeleted = 0
					AND SCQ.IsDeleted = 0
					AND CM.IsDeleted = 0
						AND CD.Detail != @SearchText
					AND CM.GroupId = @GroupId		
					ORDER BY SCQ.Id ASC
END
END;
END


