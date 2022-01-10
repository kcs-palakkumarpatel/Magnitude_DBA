-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,22 Jun 2015>
-- Description:	<Description,,>
-- Call SP:		WSGetContactDetailsByContactMasterId 11
-- =============================================
CREATE PROCEDURE [dbo].[WSGetContactDetailsByContactMasterId]
    @ContactMasterId BIGINT
AS
    BEGIN
        --SELECT  ContactQuestionId AS QuestionId ,
        --        QuestionTypeId ,
        --        Detail
        --FROM    dbo.ContactDetails AS CD
        --WHERE   CD.IsDeleted = 0
        --        AND ContactMasterId = @ContactMasterId;
		SELECT  ContactQuestionId AS QuestionId ,
                CD.QuestionTypeId ,
				CQ.QuestionTitle,
                CONVERT(NVARCHAR(50), ISNULL(Detail, '')) AS Detail,
				CQ.IsDisplayInDetail
        FROM    dbo.ContactDetails AS CD
		LEFT JOIN dbo.ContactQuestions CQ ON CQ.Id = CD.ContactQuestionId
        WHERE   CD.IsDeleted = 0
                AND ContactMasterId = @ContactMasterId;
    END;