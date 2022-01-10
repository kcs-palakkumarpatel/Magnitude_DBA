
-- =============================================
-- Author:      <Author, , Anant>
-- Create Date: <Create Date, , 02 jul-2019>
-- Description: <Description, , get Database refernce option List >
-- Call : EXEC GetDatabaseReferenceOptionList 56384,'Go Mobile',100,1,0
-- =============================================
CREATE PROCEDURE [dbo].[GetDatabaseReferenceOptionList_111721]
    @QuestionsId BIGINT,
    @Search NVARCHAR(500),
    @Rows INT,
    @Page INT,
    @IsMobi BIT
AS
BEGIN
SET NOCOUNT ON;
    IF @Rows = 0
    BEGIN
        SET @Rows = 100;
    END;
    SET @Rows = 100;
    SET @Search = ISNULL(@Search, '');
    IF @Search <> ''
    BEGIN
        SET @Rows = 100;
    END;
    IF (@IsMobi = 0)
    BEGIN
        PRINT 1;
        SELECT CASE (COUNT(1) OVER (PARTITION BY 1)) / @Rows
                   WHEN 0 THEN
                       1
                   ELSE
            ((COUNT(1) OVER (PARTITION BY 1)) / @Rows) + 1
               END AS Total,
               ROW_NUMBER() OVER (ORDER BY O.[Id] ASC) AS RowNum,
               (COUNT(1) OVER (PARTITION BY 1)) AS TotalRows,
               O.Id AS OptionId,
               RTRIM(LTRIM(REPLACE(O.Name, CHAR(10), ''))) AS OptionName,
               O.DefaultValue AS IsDefaultValue,
               Q.Id AS QuestionId,
               RTRIM(LTRIM(REPLACE(O.Value, CHAR(10), ''))) AS OptionValue,
               ISNULL(O.IsHTTPHeader, 0) AS IsHTTPHeader,
               ISNULL(O.ReferenceQuestionId, 0) AS ReferenceQuestionId,
               ISNULL(O.FromRef, 0) AS FromRef
        FROM dbo.SeenClientOptions AS O WITH (NOLOCK)
            INNER JOIN dbo.SeenClientQuestions AS Q WITH (NOLOCK)
                ON O.QuestionId = Q.Id
        WHERE Q.Id = @QuestionsId
              AND O.IsDeleted = 0
              AND Q.IsDeleted = 0
              AND O.Name LIKE '%' + @Search + '%'
        ORDER BY O.Name ASC OFFSET ((@Page - 1) * @Rows) ROWS FETCH NEXT @Rows ROWS ONLY;
    END;

    ELSE
    BEGIN
        PRINT 2;
        SELECT CASE (COUNT(1) OVER (PARTITION BY 1)) / @Rows
                   WHEN 0 THEN
                       1
                   ELSE
            ((COUNT(1) OVER (PARTITION BY 1)) / @Rows) + 1
               END AS Total,
               ROW_NUMBER() OVER (ORDER BY O.[Id] ASC) AS RowNum,
               (COUNT(1) OVER (PARTITION BY 1)) AS TotalRows,
               O.Id AS OptionId,
               RTRIM(LTRIM(REPLACE(O.Name, CHAR(10), ''))) AS OptionName,
               O.DefaultValue AS IsDefaultValue,
               Q.Id AS QuestionId,
               RTRIM(LTRIM(REPLACE(O.Value, CHAR(10), ''))) AS OptionValue,
               ISNULL(O.IsHTTPHeader, 0) AS IsHTTPHeader,
               ISNULL(O.ReferenceQuestionId, 0) AS ReferenceQuestionId,
               ISNULL(O.FromRef, 0) AS FromRef
        FROM dbo.Options AS O WITH (NOLOCK)
            INNER JOIN dbo.Questions AS Q WITH (NOLOCK)
                ON O.QuestionId = Q.Id
        WHERE Q.Id = @QuestionsId
              AND O.IsDeleted = 0
              AND Q.IsDeleted = 0
              AND O.Name LIKE '%' + @Search + '%'
        ORDER BY O.Name ASC OFFSET ((@Page - 1) * @Rows) ROWS FETCH NEXT @Rows ROWS ONLY;
    END;
	SET NOCOUNT OFF;
END;
