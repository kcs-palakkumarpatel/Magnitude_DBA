-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,30 May 2015>
-- Description:	<Description,,>
-- Call SP:		[UpdatePositionForQuestions] '22457,22484,22485,22486,22487,22885,22892,22886,22887,22888,22897,22901,22917', 'Questionnaire'
-- =============================================
CREATE PROCEDURE dbo.UpdatePositionForQuestions
    @QuestionId NVARCHAR(MAX),
    @TableName NVARCHAR(20)
AS
BEGIN
    DECLARE @QuestionTable TABLE
    (
        QuestionPosition INT IDENTITY,
        QuestionId BIGINT
    );

    INSERT INTO @QuestionTable
    SELECT Data
    FROM dbo.Split(@QuestionId, ',');


    DECLARE @COUNT INT = 1;
    DECLARE @RowCount INT;
    SET @RowCount =
    (
        SELECT COUNT(QuestionPosition) FROM @QuestionTable
    );

    IF (@TableName = 'Questionnaire')
    BEGIN
        SELECT q.Id,
               b.Position AS NewPosition,
               ROW_NUMBER() OVER (PARTITION BY b.Position
                                  ORDER BY b.QuestionPosition,
                                           QT.QuestionPosition
                                 ) AS ChildPosition
        INTO #temp
        FROM dbo.Questions q
            INNER JOIN
            (
                SELECT *,
                       ROW_NUMBER() OVER (ORDER BY A.QuestionPosition) AS Position
                FROM
                (
                    SELECT MIN(Id) AS Id,
                           MIN(QT.QuestionPosition) AS QuestionPosition,
                           ISNULL(QuestionsGroupNo, 0) AS QuestionsGroupNo,
                           MIN(ISNULL(UpdatedOn, CreatedOn)) AS CreatedOn
                    FROM dbo.Questions q
                        INNER JOIN @QuestionTable QT
                            ON q.Id = QT.QuestionId
                               AND ISNULL(q.QuestionsGroupNo, 0) <> 0
                    GROUP BY ISNULL(q.QuestionsGroupNo, 0)
                    UNION ALL
                    SELECT Id,
                           QT.QuestionPosition,
                           ISNULL(QuestionsGroupNo, 0) AS QuestionsGroupNo,
                           ISNULL(UpdatedOn, CreatedOn) AS CreatedOn
                    FROM dbo.Questions q
                        INNER JOIN @QuestionTable QT
                            ON q.Id = QT.QuestionId
                               AND ISNULL(q.QuestionsGroupNo, 0) = 0
                ) A
            ) b
                ON b.QuestionsGroupNo = ISNULL(q.QuestionsGroupNo, 0)
            INNER JOIN @QuestionTable QT
                ON q.Id = QT.QuestionId
                   AND ISNULL(q.QuestionsGroupNo, 0) <> 0
        UNION
        SELECT q.Id,
               b.rOWnUM,
               1
        FROM dbo.Questions q
            INNER JOIN
            (
                SELECT *,
                       ROW_NUMBER() OVER (ORDER BY QuestionPosition) AS rOWnUM
                FROM
                (
                    SELECT MIN(Id) AS Id,
                           MIN(QT.QuestionPosition) AS QuestionPosition,
                           ISNULL(q.QuestionsGroupNo, 0) AS QuestionsGroupNo,
                           MIN(ISNULL(UpdatedOn, CreatedOn)) AS CreatedOn
                    FROM dbo.Questions q
                        INNER JOIN @QuestionTable QT
                            ON q.Id = QT.QuestionId
                               AND ISNULL(q.QuestionsGroupNo, 0) <> 0
                    GROUP BY ISNULL(q.QuestionsGroupNo, 0)
                    UNION ALL
                    SELECT Id,
                           QT.QuestionPosition,
                           ISNULL(q.QuestionsGroupNo, 0) AS QuestionsGroupNo,
                           ISNULL(UpdatedOn, CreatedOn) AS CreatedOn
                    FROM dbo.Questions q
                        INNER JOIN @QuestionTable QT
                            ON q.Id = QT.QuestionId
                               AND ISNULL(q.QuestionsGroupNo, 0) = 0
                ) A
            ) b
                ON b.Id = q.Id
                   AND ISNULL(q.QuestionsGroupNo, 0) = 0;

        UPDATE q
        SET q.Position = t.NewPosition,
            q.ChildPosition = t.ChildPosition
        FROM #temp t
            INNER JOIN dbo.Questions q
                ON q.Id = t.Id;

    END;
    ELSE IF (@TableName = 'SeenClient')
    BEGIN
        SELECT q.Id,
               b.Position AS NewPosition,
               ROW_NUMBER() OVER (PARTITION BY b.Position
                                  ORDER BY b.QuestionPosition,
                                           QT.QuestionPosition
                                 ) AS ChildPosition
        INTO #temp1
        FROM dbo.SeenClientQuestions q
            INNER JOIN
            (
                SELECT *,
                       ROW_NUMBER() OVER (ORDER BY A.QuestionPosition) AS Position
                FROM
                (
                    SELECT MIN(Id) AS Id,
                           MIN(QT.QuestionPosition) AS QuestionPosition,
                           ISNULL(QuestionsGroupNo, 0) AS QuestionsGroupNo,
                           MIN(ISNULL(UpdatedOn, CreatedOn)) AS CreatedOn
                    FROM dbo.SeenClientQuestions q
                        INNER JOIN @QuestionTable QT
                            ON q.Id = QT.QuestionId
                               AND ISNULL(q.QuestionsGroupNo, 0) <> 0
                    GROUP BY ISNULL(q.QuestionsGroupNo, 0)
                    UNION ALL
                    SELECT Id,
                           QT.QuestionPosition,
                           ISNULL(QuestionsGroupNo, 0) AS QuestionsGroupNo,
                           ISNULL(UpdatedOn, CreatedOn) AS CreatedOn
                    FROM dbo.SeenClientQuestions q
                        INNER JOIN @QuestionTable QT
                            ON q.Id = QT.QuestionId
                               AND ISNULL(q.QuestionsGroupNo, 0) = 0
                ) A
            ) b
                ON b.QuestionsGroupNo = ISNULL(q.QuestionsGroupNo, 0)
            INNER JOIN @QuestionTable QT
                ON q.Id = QT.QuestionId
                   AND ISNULL(q.QuestionsGroupNo, 0) <> 0
        UNION
        SELECT q.Id,
               b.rOWnUM,
               1
        FROM dbo.SeenClientQuestions q
            INNER JOIN
            (
                SELECT *,
                       ROW_NUMBER() OVER (ORDER BY QuestionPosition) AS rOWnUM
                FROM
                (
                    SELECT MIN(Id) AS Id,
                           MIN(QT.QuestionPosition) AS QuestionPosition,
                           ISNULL(q.QuestionsGroupNo, 0) AS QuestionsGroupNo,
                           MIN(ISNULL(UpdatedOn, CreatedOn)) AS CreatedOn
                    FROM dbo.SeenClientQuestions q
                        INNER JOIN @QuestionTable QT
                            ON q.Id = QT.QuestionId
                               AND ISNULL(q.QuestionsGroupNo, 0) <> 0
                    GROUP BY ISNULL(q.QuestionsGroupNo, 0)
                    UNION ALL
                    SELECT Id,
                           QT.QuestionPosition,
                           ISNULL(q.QuestionsGroupNo, 0) AS QuestionsGroupNo,
                           ISNULL(UpdatedOn, CreatedOn) AS CreatedOn
                    FROM dbo.SeenClientQuestions q
                        INNER JOIN @QuestionTable QT
                            ON q.Id = QT.QuestionId
                               AND ISNULL(q.QuestionsGroupNo, 0) = 0
                ) A
            ) b
                ON b.Id = q.Id
                   AND ISNULL(q.QuestionsGroupNo, 0) = 0;

        UPDATE q
        SET q.Position = t.NewPosition,
            q.ChildPosition = t.ChildPosition
        FROM #temp1 t
            INNER JOIN dbo.SeenClientQuestions q
                ON q.Id = t.Id;

        --Section Update - Start
        SELECT q.Id,
               b.Position AS NewPosition,
               ROW_NUMBER() OVER (PARTITION BY b.Position
                                  ORDER BY b.QuestionPosition,
                                           QT.QuestionPosition
                                 ) AS ChildPosition
        INTO #temp2
        FROM dbo.SeenClientQuestions q
            INNER JOIN
            (
                SELECT *,
                       ROW_NUMBER() OVER (ORDER BY A.QuestionPosition) AS Position
                FROM
                (
                    SELECT MIN(Id) AS Id,
                           MIN(QT.QuestionPosition) AS QuestionPosition,
                           ISNULL(SectionNo, 0) AS SectionNo,
                           MIN(ISNULL(UpdatedOn, CreatedOn)) AS CreatedOn
                    FROM dbo.SeenClientQuestions q
                        INNER JOIN @QuestionTable QT
                            ON q.Id = QT.QuestionId
                               AND ISNULL(q.SectionNo, 0) <> 0
                    GROUP BY ISNULL(q.SectionNo, 0)
                    UNION ALL
                    SELECT Id,
                           QT.QuestionPosition,
                           ISNULL(SectionNo, 0) AS SectionNo,
                           ISNULL(UpdatedOn, CreatedOn) AS CreatedOn
                    FROM dbo.SeenClientQuestions q
                        INNER JOIN @QuestionTable QT
                            ON q.Id = QT.QuestionId
                               AND ISNULL(q.SectionNo, 0) = 0
                ) A
            ) b
                ON b.SectionNo = ISNULL(q.SectionNo, 0)
            INNER JOIN @QuestionTable QT
                ON q.Id = QT.QuestionId
                   AND ISNULL(q.SectionNo, 0) <> 0
        UNION
        SELECT q.Id,
               b.rOWnUM,
               1
        FROM dbo.SeenClientQuestions q
            INNER JOIN
            (
                SELECT *,
                       ROW_NUMBER() OVER (ORDER BY QuestionPosition) AS rOWnUM
                FROM
                (
                    SELECT MIN(Id) AS Id,
                           MIN(QT.QuestionPosition) AS QuestionPosition,
                           ISNULL(q.SectionNo, 0) AS SectionNo,
                           MIN(ISNULL(UpdatedOn, CreatedOn)) AS CreatedOn
                    FROM dbo.SeenClientQuestions q
                        INNER JOIN @QuestionTable QT
                            ON q.Id = QT.QuestionId
                               AND ISNULL(q.SectionNo, 0) <> 0
                    GROUP BY ISNULL(q.SectionNo, 0)
                    UNION ALL
                    SELECT Id,
                           QT.QuestionPosition,
                           ISNULL(q.SectionNo, 0) AS SectionNo,
                           ISNULL(UpdatedOn, CreatedOn) AS CreatedOn
                    FROM dbo.SeenClientQuestions q
                        INNER JOIN @QuestionTable QT
                            ON q.Id = QT.QuestionId
                               AND ISNULL(q.SectionNo, 0) = 0
                ) A
            ) b
                ON b.Id = q.Id
                   AND ISNULL(q.SectionNo, 0) = 0;

        UPDATE q
        SET q.Position = t.NewPosition,
            q.ChildPosition = t.ChildPosition
        FROM #temp2 t
            INNER JOIN dbo.SeenClientQuestions q
                ON q.Id = t.Id
                   AND q.IsSection = 1;
    --Section Update - End

    END;
    ELSE IF (@TableName = 'Contact')
    BEGIN
        DECLARE @OldQPos INT;


        WHILE @COUNT <= @RowCount
        BEGIN
            SET @OldQPos =
            (
                SELECT Position
                FROM ContactQuestions
                WHERE Id =
                (
                    SELECT QuestionId FROM @QuestionTable WHERE QuestionPosition = @COUNT
                )
            );
            IF (@OldQPos != @COUNT)
            BEGIN
                UPDATE dbo.ContactQuestions
                SET Position =
                    (
                        SELECT QuestionPosition
                        FROM @QuestionTable
                        WHERE @COUNT = QuestionPosition
                    ),
                    UpdatedOn = GETUTCDATE()
                WHERE dbo.ContactQuestions.Id =
                (
                    SELECT QuestionId FROM @QuestionTable WHERE @COUNT = QuestionPosition
                );
            END;
            SET @COUNT = @COUNT + 1;
        END;
    END;
    RETURN @COUNT;
END;
