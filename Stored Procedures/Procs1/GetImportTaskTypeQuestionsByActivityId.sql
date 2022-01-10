-- =============================================  
-- Author:			Krishna Panchal
-- Create date:	 28-Sep-2017
-- Description:	Get Contacts Questions Details For Mass Upload.
-- Call SP:			dbo.GetImportTaskTypeQuestionsByActivityId 7361
-- =============================================
CREATE PROCEDURE dbo.GetImportTaskTypeQuestionsByActivityId @ActivityId BIGINT
AS
BEGIN
    DECLARE @Table1 TABLE
    (
        AutoId INT PRIMARY KEY IDENTITY(1, 1),
        ID INT,
        Value VARCHAR(MAX),
        QuestionId VARCHAR(MAX),
        QuestionTypeId VARCHAR(2000),
        IsRequired BIT,
        SeenClientId BIGINT
    );

    INSERT INTO @Table1
    (
        ID,
        Value,
        QuestionId,
        QuestionTypeId,
        IsRequired,
        SeenClientId
    )
    SELECT SCQ.SeenClientId,
           SCQ.QuestionTitle,
           CAST(SCQ.Id AS VARCHAR(500)),
           CAST(SCQ.QuestionTypeId AS VARCHAR(500)),
           SCQ.Required,
           SCQ.SeenClientId
    FROM dbo.SeenClientQuestions SCQ
        INNER JOIN dbo.EstablishmentGroup EG
            ON EG.SeenClientId = SCQ.SeenClientId
    WHERE EG.Id = @ActivityId
          AND ISNULL(SCQ.IsDeleted, 0) = 0
		  AND SCQ.IsActive = 1
          AND SCQ.QuestionTypeId NOT IN ( 16, 17, 23, 25 )
    ORDER BY SCQ.Position ASC;

    SELECT TOP 1 ISNULL(t.ID, 0) AS ContactId,
           STUFF(
                    (
                        SELECT ',' + CAST(Value AS VARCHAR(MAX)) [text()]
                        FROM @Table1
                        WHERE ID = t.ID
                        ORDER BY AutoId
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
                        ORDER BY AutoId
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
                        ORDER BY AutoId
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
                        ORDER BY AutoId
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
                                  SELECT QuestionId FROM @Table1 WHERE QuestionTypeId IN ( 21, 18, 6, 5, 1 )
                              )
                              AND Value <> '-- Select --'
                        ORDER BY AutoId
                        FOR XML PATH(''), TYPE
                    ).value('.', 'NVARCHAR(MAX)'),
                    1,
                    1,
                    ''
                ) Options,
           ISNULL(t.SeenClientId, 0) AS SeenClientId
    FROM @Table1 t
    GROUP BY ID,
             SeenClientId,t.AutoId;
END;
