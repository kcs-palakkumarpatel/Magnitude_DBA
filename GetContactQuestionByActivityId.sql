-- =============================================
-- Author:		<Vasu Patel>
-- Create date: <27 Feb 2017>
-- Description:	<Get Contact Question By Activity Id>
-- Call:					GetContactQuestionByActivityId 919
-- =============================================
CREATE PROCEDURE [dbo].[GetContactQuestionByActivityId] @ActivityId BIGINT
AS
    BEGIN
        DECLARE @Table1 TABLE
            (
              ID INT ,
              Value VARCHAR(100)
            );
        INSERT  INTO @Table1
                ( ID ,
                  Value
                )
                SELECT  ContactId ,
                        QuestionTitle
                FROM    dbo.ContactQuestions
                WHERE   Id IN (
                        SELECT  Data
                        FROM    dbo.Split(( SELECT  ContactQuestion
                                            FROM    dbo.EstablishmentGroup
                                            WHERE   Id = @ActivityId
                                          ), ',') ) ORDER BY Position ASC;

        SELECT  ID ,
                STUFF((SELECT   ',' + CAST(Value AS VARCHAR(100)) [text()]
                       FROM     @Table1
                       WHERE    ID = t.ID
                FOR   XML PATH('') ,
                          TYPE)
        .value('.', 'NVARCHAR(MAX)'), 1, 1, '') List_Output
        FROM    @Table1 t
        GROUP BY ID;
    END;

