-- =============================================
-- Author:			Developer D3
-- Create date:	29-09-2016
-- Description:	Get Contact Answers Table for Web API Using AnswerMasterId
-- Call:					dbo.APIInsertOrUpdateContactAnswersByAnswerMasterId 293
-- =============================================
CREATE PROCEDURE [dbo].[APIInsertContactQuestionAnswersByReferenceId]
    (
      @SeenClientAnswerMasterId BIGINT = 0 ,
	  @SeenClientAnswerChildId BIGINT = 0 ,
      @ContactMasterID BIGINT = 0 ,
      @AppUserId BIGINT = 0
	)
AS
    BEGIN
	INSERT  INTO dbo.[SeenClientAnswers]
                ( [SeenClientAnswerMasterId] ,
                  [SeenClientAnswerChildId] ,
                  [QuestionId] ,
                  [OptionId] ,
                  [QuestionTypeId] ,
                  [Detail] ,
                  [Weight] ,
                  [QPI] ,
                  [CreatedOn] ,
                  [CreatedBy] ,
                  [IsDeleted] ,
                  [IsDisabled] ,
                  [RepetitiveGroupId] ,
                  [RepetitiveGroupName] ,
                  [RepeatCount]
                )
	Select 
	@SeenClientAnswerMasterId,
	@SeenClientAnswerChildId,
	SCQ.Id as QuestionId,
	ISNULL(SCO.Id, NULL) as OptionId,
	SCQ.QuestionTypeId as QuestionTypeId,
	cd.Detail as Detail,
	SCQ.Weight,
	0.00,
	SCAM.CreatedOn,
	@AppUserId,
	  0 ,
                  0 ,
                  0 ,
                  NULL ,
                  0
	FROM    dbo.ContactDetails AS cd
            LEFT JOIN dbo.SeenClientQuestions AS SCQ ON SCQ.ContactQuestionId = cd.ContactQuestionId
			LEFT JOIN SeenClientAnswerMaster SCAM ON SCAM.SeenClientId = SCQ.SeenClientId
			LEFT JOIN SeenClientOptions SCO ON SCO.QuestionId = SCQ.Id
			WHERE SCAM.Id = @SeenClientAnswerMasterId
			and cd.ContactMasterId = @ContactMasterID
	END
