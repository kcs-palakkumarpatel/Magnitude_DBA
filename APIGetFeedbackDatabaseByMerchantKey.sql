-- =============================================
-- Author:			Developer D3
-- Create date:	29-09-2016
-- Description:	Get Feedback Database from for Web API Using MerchantKey(GroupId)
-- Call:					dbo.APIGetFeedbackDatabaseByMerchantKey 235
-- =============================================
CREATE PROCEDURE [dbo].[APIGetFeedbackDatabaseByMerchantKey]
    (
      @MerchantKey BIGINT = 0
	)
AS
    BEGIN
        SET NOCOUNT OFF;

        SELECT  EST.Id AS EstablishmentId ,
                ESTG.QuestionnaireId AS FeedbackId,
				QNE.QuestionnaireTitle AS FeedbackTitle,
				QNE.QuestionnaireFormType AS FeedbackFormType
        FROM    dbo.EstablishmentGroup AS ESTG
                LEFT OUTER JOIN dbo.Establishment AS EST ON EST.EstablishmentGroupId = ESTG.Id
				LEFT OUTER JOIN dbo.Questionnaire AS QNE ON QNE.Id = ESTG.QuestionnaireId
        WHERE   ESTG.GroupId = @MerchantKey
                AND ESTG.EstablishmentGroupId IS  NOT NULL;

    END;