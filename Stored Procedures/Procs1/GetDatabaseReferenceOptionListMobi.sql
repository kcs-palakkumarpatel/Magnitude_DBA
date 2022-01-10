-- =============================================
-- Author:      <Author, , Anant>
-- Create Date: <Create Date, , 02 jul-2019>
-- Description: <Description, , get Database refernce option List >
-- Call : EXEC GetDatabaseReferenceOptionList 43783,'',100,1
-- =============================================
CREATE PROCEDURE [dbo].[GetDatabaseReferenceOptionListMobi]
    @QuestionsId BIGINT,
    @Search NVARCHAR(500),
    @Rows INT,
    @Page INT
AS
BEGIN
    IF @Rows = 0
    BEGIN
        SET @Rows = 100;
    END;
    SET @Search = ISNULL(@Search, '');
    SELECT CASE (COUNT(1) OVER (PARTITION BY 1)) / @Rows
               WHEN 0 THEN
                   1
               ELSE
        ((COUNT(1) OVER (PARTITION BY 1)) / @Rows) + 1
           END AS Total,
           ROW_NUMBER() OVER (ORDER BY O.[Id] ASC) AS RowNum,
           (COUNT(1) OVER (PARTITION BY 1)) AS TotalRows,
            O.Id AS OptionId ,
                RTRIM(LTRIM(O.Name)) AS OptionName ,
                O.DefaultValue AS IsDefaultValue,
                Q.Id AS QuestionId,
                RTRIM(LTRIM(O.Value)) AS OptionValue,
				ISNULL(O.IsHTTPHeader,0) AS IsHTTPHeader,
		        ISNULL(O.ReferenceQuestionId,0) AS ReferenceQuestionId,
		        ISNULL(O.FromRef,0) AS FromRef
        FROM    dbo.Options AS O
                INNER JOIN dbo.Questions AS Q ON O.QuestionId = Q.Id
        WHERE   Q.Id = @QuestionsId
                AND O.IsDeleted = 0
                AND Q.IsDeleted = 0
				AND O.Name LIKE '%'+@Search+'%'
        ORDER BY Q.ID ASC   
	 OFFSET ((@Page - 1) * @Rows) ROWS FETCH NEXT @Rows ROWS ONLY;
END;
