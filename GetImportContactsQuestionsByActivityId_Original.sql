-- =============================================  
-- Author:			Sunil Vaghasiya
-- Create date:	22-Sep-2017
-- Description:	Get Contacts Questions Details For Mass Upload.
-- Call SP:			dbo.GetImportContactsQuestionsByActivityId 449, 1177 ,201
-- =============================================
CREATE PROCEDURE dbo.GetImportContactsQuestionsByActivityId_Original
(
@AppUserId BIGINT,
@GroupId BIGINT,
@ActivityId BIGINT
)
AS
    BEGIN  
        DECLARE @ContactId BIGINT = 0, @ContactQuestionIds VARCHAR(2000) = '';
        SELECT  @ContactId = ContactId FROM    dbo.[Group] WHERE   Id = @GroupId;
		SELECT  @ContactQuestionIds =  ContactQuestion FROM    dbo.EstablishmentGroup WHERE   Id = @ActivityId;

        DECLARE @Table1 TABLE (
              ID INT ,
              Value VARCHAR(MAX) ,
              QuestionId VARCHAR(500) );

        INSERT  INTO @Table1 ( ID , Value , QuestionId )
        SELECT  ContactId , QuestionTitle , CAST(Id AS VARCHAR(500))
		FROM    dbo.ContactQuestions 
		WHERE   ContactId = @ContactId
                        AND QuestionTypeId NOT IN ( 16, 17, 23, 25, 1 )
						AND IsDeleted = 0
						AND Id IN (SELECT  Data FROM dbo.Split(@ContactQuestionIds, ','))
                ORDER BY Position ASC;

        SELECT  ISNULL(ID, 0) AS ContactId,
                STUFF((SELECT   ',' + CAST(Value AS VARCHAR(MAX)) [text()]
                       FROM     @Table1
                       WHERE    ID = t.ID
                FOR   XML PATH('') ,
                          TYPE)
        .value('.', 'NVARCHAR(MAX)'), 1, 1, '') QuestionTitle ,
                STUFF((SELECT   ',' + CAST(QuestionId AS VARCHAR(MAX)) [text()]
                       FROM     @Table1
                       WHERE    ID = t.ID
                FOR   XML PATH('') ,
                          TYPE)
        .value('.', 'NVARCHAR(MAX)'), 1, 1, '') QuestionId
        FROM    @Table1 t
        GROUP BY ID;
  
    END;
