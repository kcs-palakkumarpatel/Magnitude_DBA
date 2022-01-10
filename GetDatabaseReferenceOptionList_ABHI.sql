-- =============================================
-- Author:      <Author, , Abhishek>
-- Create Date: <Create Date, , 02 jul-2019>
-- Description: <Description, , get Database refernce option List >
-- Call : EXEC GetDatabaseReferenceOptionList_ABHI 60941,'WRENT BELT',100,1,1
-- =============================================
CREATE PROCEDURE dbo.GetDatabaseReferenceOptionList_ABHI
    @QuestionsId BIGINT,
    @Search NVARCHAR(500),
    @Rows INT,
    @Page INT,
    @IsMobi BIT
AS
BEGIN
SET NOCOUNT ON;
SET DEADLOCK_PRIORITY NORMAL;
	
BEGIN TRY

	DECLARE @SearchQuery NVARCHAR(MAX) = '';
    IF @Rows = 0
    BEGIN
        SET @Rows = 100;
    END;
    SET @Rows = 100;
    SET @Search = ISNULL(@Search, '');
    IF @Search <> ''
    BEGIN
		
		DECLARE @TempSearch TABLE (
			text NVARCHAR(MAX)
		);
		INSERT INTO @TempSearch
		(
		    text
		)
		SELECT 'O.Name LIKE ''%'+Data +'%'' OR' FROM dbo.Split(@Search,' ');
		DECLARE @TempData NVARCHAR(MAX) = '';
		--WHILE (SELECT COUNT(1) FROM @TempSearch) > 0
		--BEGIN
		--	SET @TempData = (SELECT TOP 1 text FROM @TempSearch);
		--	SET @SearchQuery =  @SearchQuery + 'O.Name LIKE ''%' + @TempData +'%'' OR '; 
		--	DELETE FROM @TempSearch WHERE text = @TempData;
		--END
		SELECT @SearchQuery = STRING_AGG(text, ' ') FROM @TempSearch;
		SET @SearchQuery = 'AND (' + LEFT(@SearchQuery, LEN(@SearchQuery)-3) +')';
		PRINT @SearchQuery;
        SET @Rows = 100;
    END;
    IF (@IsMobi = 0)
    BEGIN
        PRINT 1;
        EXEC ('SELECT CASE (COUNT(1) OVER (PARTITION BY 1)) /'+ @Rows+'
                   WHEN 0 THEN
                       1
                   ELSE
            ((COUNT(1) OVER (PARTITION BY 1)) / '+@Rows+') + 1
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
        WHERE Q.Id = '+ @QuestionsId +'
              AND O.IsDeleted = 0
              AND Q.IsDeleted = 0
              '+ @SearchQuery+'
        ORDER BY O.Name ASC OFFSET (('+@Page + '- 1) * '+@Rows+') ROWS FETCH NEXT '+ @Rows +' ROWS ONLY');

    END;

    ELSE
    BEGIN
        PRINT 2;
        EXEC('SELECT CASE (COUNT(1) OVER (PARTITION BY 1)) /'+ @Rows+'
                   WHEN 0 THEN
                       1
                   ELSE
            ((COUNT(1) OVER (PARTITION BY 1)) / '+@Rows+') + 1
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
        WHERE Q.Id = '+ @QuestionsId +'
              AND O.IsDeleted = 0
              AND Q.IsDeleted = 0
                '+ @SearchQuery+'
        ORDER BY O.Name ASC OFFSET (('+@Page + '- 1) * '+@Rows+') ROWS FETCH NEXT '+ @Rows +' ROWS ONLY');
    END;
	END TRY

BEGIN CATCH
	INSERT INTO dbo.ErrorLog
        (
            PageId,
            MethodName,
            ErrorType,
            ErrorMessage,
            ErrorDetails,
            ErrorDate,
            UserId,
            Solution,
            CreatedOn,
            CreatedBy
        )
        VALUES
        (ERROR_LINE(),
         'dbo.GetDatabaseReferenceOptionList',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         N'',
         @QuestionsId+','+@Search+','+@Rows+','+@Page+','+@IsMobi,
         GETUTCDATE(),
         N''
        );
END CATCH
	SET NOCOUNT OFF;
END;
