-- =============================================  
-- Author:			Sunil Vaghasiya
-- Create date:	22-Sep-2017
-- Description:	Get Contacts Questions Details For Mass Upload.
-- Call SP:			dbo.GetImportTaskTypeQuestionsByActivityId 8743
-- =============================================
CREATE PROCEDURE dbo.GetImportTaskTypeQuestionsByActivityId_Anant @ActivityId BIGINT
AS
BEGIN
    DECLARE @Table1 TABLE
    (
        ID INT,
        Value VARCHAR(MAX),
        QuestionId VARCHAR(500),
        QuestionTypeId VARCHAR(500),
        IsRequired BIT
    );

    INSERT INTO @Table1
    (
        ID,
        Value,
        QuestionId,
        QuestionTypeId,
        IsRequired
    )
    SELECT SCQ.SeenClientId,
           SCQ.QuestionTitle,
           CAST(SCQ.Id AS VARCHAR(500)),
           CAST(SCQ.QuestionTypeId AS VARCHAR(500)),
           SCQ.Required
    FROM dbo.SeenClientQuestions SCQ
        INNER JOIN dbo.EstablishmentGroup EG
            ON EG.SeenClientId = SCQ.SeenClientId
    WHERE EG.Id = @ActivityId
          AND ISNULL(SCQ.IsDeleted, 0) = 0
          AND SCQ.QuestionTypeId <> 17;

    SELECT ISNULL(t.ID, 0) AS ContactId,
           STUFF(
                    (
                        SELECT ',' + CAST(Value AS VARCHAR(MAX)) [text()]
                        FROM @Table1
                        WHERE ID = t.ID
                        FOR XML PATH(''), TYPE
                    ).value('.', 'NVARCHAR(MAX)'),
                    1,
                    1,
                    ''
                ) QuestionTitle,
           STUFF(
                    (
                        SELECT ',' + CAST(QuestionId AS VARCHAR(MAX)) [text()]
                        FROM @Table1
                        WHERE ID = t.ID
                        FOR XML PATH(''), TYPE
                    ).value('.', 'NVARCHAR(MAX)'),
                    1,
                    1,
                    ''
                ) QuestionId,
           STUFF(
                    (
                        SELECT ',' + CAST(QuestionTypeId AS VARCHAR(MAX)) [text()]
                        FROM @Table1
                        WHERE ID = t.ID
                        FOR XML PATH(''), TYPE
                    ).value('.', 'NVARCHAR(MAX)'),
                    1,
                    1,
                    ''
                ) QuestionTypeId,
           STUFF(
                    (
                        SELECT ',' + CAST(IsRequired AS VARCHAR(MAX)) [text()]
                        FROM @Table1
                        WHERE ID = t.ID
                        FOR XML PATH(''), TYPE
                    ).value('.', 'NVARCHAR(MAX)'),
                    1,
                    1,
                    ''
                ) IsRequired,
           STUFF(
                    (
                        SELECT ',' + CAST(Name AS VARCHAR(MAX)) [text()]
                        FROM dbo.SeenClientOptions
                        WHERE QuestionId IN
                              (
                                  SELECT QuestionId FROM @Table1 WHERE QuestionTypeId = 21 
                              ) AND Value <> '-- Select --'
                        FOR XML PATH(''), TYPE
                    ).value('.', 'NVARCHAR(MAX)'),
                    1,
                    1,
                    ''
                ) Options
    FROM @Table1 t
    GROUP BY ID;
END;
