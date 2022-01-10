-- =============================================  
-- Author:			Sunil Vaghasiya
-- Create date:	11-Mar-2017
-- Description:	Get Contacts Questions Details For Mass Upload.
-- Call SP:			dbo.GetImportContactsQuestionsByGroupId 171
-- =============================================
CREATE PROCEDURE [dbo].[GetImportContactsQuestionsByGroupId_20Sept2021] @GroupId BIGINT
AS
    BEGIN  
        DECLARE @ContactId BIGINT = 0;

        SELECT  @ContactId = ContactId
        FROM    dbo.[Group]
        WHERE   Id = @GroupId;

        SELECT  Id AS QuestionId ,
                QuestionTypeId ,
                QuestionTitle ,
                ShortName ,
                [Required] ,
                IsDisplayInSummary ,
                IsDisplayInDetail ,
                [MaxLength] ,
                IsDecimal ,
                IsCommentCompulsory ,
                ContactId ,
                Position
        FROM    dbo.ContactQuestions
        WHERE   ContactId = @ContactId
                AND NOT EXISTS (select  QuestionTypeId from dbo.ContactQuestions where  QuestionTypeId = 16 OR QuestionTypeId = 17 OR  QuestionTypeId = 23 OR  QuestionTypeId = 25 OR  QuestionTypeId = 1 )
                AND IsDeleted = 0
        ORDER BY Position ASC;
  
    END;  
