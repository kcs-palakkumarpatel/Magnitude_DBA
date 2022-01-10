-- =============================================
-- Author:			Sunil Vaghasiya
-- Create date:	11-03-2017
-- Description:	<Get Contact Question By Group Id>
-- Call:					GetContactQuestionByGroupId 170
-- =============================================
CREATE PROCEDURE [dbo].[GetContactQuestionByGroupId] @GroupId BIGINT
AS
    BEGIN

        DECLARE @ContactId BIGINT = 0;

        SELECT  @ContactId = ContactId
        FROM    dbo.[Group]
        WHERE   Id = @GroupId;

        DECLARE @Table1 TABLE
            (
              ID INT ,
              Value VARCHAR(MAX) ,
              QuestionId VARCHAR(500)
            );
        INSERT  INTO @Table1
                ( ID ,
                  Value ,
                  QuestionId
                )
                SELECT  ContactId ,
                        QuestionTitle ,
                        CAST(Id AS VARCHAR(500))
                FROM    dbo.ContactQuestions
                WHERE   ContactId = @ContactId
                        AND QuestionTypeId NOT IN ( 16, 17, 23, 25, 1 )
						AND IsDeleted = 0
                ORDER BY Position ASC;

        SELECT  ID ,
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


