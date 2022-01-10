-- =============================================
-- Author:			Sunil Vaghasiya
-- Create date:	13-June-2016
-- Description:	<Description,,>
-- Call :				dbo.GetReportDataToExport 70969, 1
-- =============================================
CREATE PROCEDURE [dbo].[GetReportDataToExport] @Id BIGINT, @IsOut BIT 
AS 
    BEGIN 
        DECLARE @ActivityId BIGINT , 
            @QuestionnaireId BIGINT , 
            @SeenClientId BIGINT , 
            @FromDate NVARCHAR(50) , 
            @ToDate NVARCHAR(50), 
			@ImageUriFeedback VARCHAR(255), 
			@ImageUriSeenclient VARCHAR(255); 
        SELECT  @ActivityId = PRS.EstablishmentGroupId , 
                @QuestionnaireId = Eg.QuestionnaireId , 
                @SeenClientId = Eg.SeenClientId , 
                @FromDate = dbo.ChangeDateFormat(PRS.FromDate, 'dd MMM yyyy') , 
                @ToDate = dbo.ChangeDateFormat(PRS.ToDate, 'dd MMM yyyy') 
        FROM    dbo.PendingAutoReportingScheduler AS PRS 
                INNER JOIN dbo.EstablishmentGroup AS Eg ON Eg.Id = PRS.EstablishmentGroupId 
        WHERE   PRS.Id = @Id; 

		SELECT TOP 1 @ImageUriFeedback = ', ' + ISNULL(KeyValue, '') + 'feedback/' FROM dbo.AAAAConfigSettings WHERE KeyName = 'DocViewerRootFolderPathWebApp' 
		SELECT TOP 1 @ImageUriSeenclient = ', ' + ISNULL(KeyValue, '') + 'SeenClient' FROM dbo.AAAAConfigSettings WHERE KeyName = 'DocViewerRootFolderPathWebApp' 

		--SELECT TOP 1 @ImageUriFeedback = ', ' + ISNULL(KeyValue, '') + 'UploadFiles/feedback/' FROM dbo.AAAAConfigSettings WHERE KeyName = 'WebAppUrl' 
		--SELECT TOP 1 @ImageUriSeenclient = ', ' + ISNULL(KeyValue, '') + 'UploadFiles/SeenClient' FROM dbo.AAAAConfigSettings WHERE KeyName = 'WebAppUrl' 

        DECLARE @cols AS NVARCHAR(MAX) , 
            @query AS NVARCHAR(MAX); 
        IF @IsOut = 0 
            BEGIN 
                SELECT  @cols = STUFF((SELECT DISTINCT 
                                                ',' 
                                                + QUOTENAME(Q.QuestionTitle) 
                                       FROM     dbo.Questions AS Q 
                                       WHERE    Q.IsDeleted = 0 
                                                AND Q.QuestionnaireId = @QuestionnaireId 
                                                AND Q.Id NOT IN ( 16, 17, 23 ) 
                                                AND Q.IsDisplayInDetail = 1 
                        FOR           XML PATH('') , 
                                          TYPE 
            ).value('.', 'NVARCHAR(MAX)'), 1, 1, ''); 
                SET @query = 'SELECT EstablishmentName AS [Establishment Name],dbo.ChangeDateFormat(CreatedOn, ''MM/dd/yyyy hh:mm AM/PM'') AS [Capture Date], PI, ' 
                    + @cols 
                    + ' 
             from  
             ( 
                SELECT    AM.ReportId, 
				AM.EstablishmentName, 
				
				CAST(CAST(ROUND(am.PI,0) AS DECIMAL(18,0)) AS VARCHAR(50)) + ''%'' as PI, 
				Am.CreatedOn, 
                    CASE Q.QuestionTypeId 
                            WHEN 8 
                            THEN ( CASE WHEN A.Detail IS NULL 
                                             OR A.Detail = '''' 
                                        THEN ISNULL(A.Detail, '''') 
                                        ELSE dbo.ChangeDateFormat(A.Detail, 
                                                              ''MM/dd/yyyy'') 
                                   END ) 
                            WHEN 9 
                            THEN ( CASE WHEN A.Detail IS NULL 
                                             OR A.Detail = '''' 
                                        THEN ISNULL(A.Detail, '''') 
                                        ELSE dbo.ChangeDateFormat(A.Detail, 
                                                              ''hh:mm AM/PM'') 
                                   END ) 
                            WHEN 22 
                            THEN ( CASE WHEN A.Detail IS NULL 
                                             OR A.Detail = '''' 
                                        THEN ISNULL(A.Detail, '''') 
                                        ELSE dbo.ChangeDateFormat(A.Detail, 
                                                              ''MM/dd/yyyy hh:mm AM/PM'') 
                                   END ) 
								   WHEN 1 
                  THEN dbo.GetOptionNameByQuestionId(Q.Id, A.Detail, 0) 
							WHEN 23 
							THEN ( 
									CASE WHEN ISNULL(A.Detail,'''') = '''' 
										THEN '''' 
										ELSE +REPLACE('''+@ImageUriFeedback+''','','','''')  + REPLACE(A.Detail,'','','''+ @ImageUriFeedback+''')  
										END 
									) 
							WHEN 23 
							THEN ( 
									CASE WHEN ISNULL(A.Detail,'''') = '''' 
										THEN '''' 
										ELSE +REPLACE('''+@ImageUriFeedback+''','','','''')  + REPLACE(A.Detail,'','','''+ @ImageUriFeedback+''')  
										END 
									) 
                            ELSE ISNULL(Detail, '''') 
                          END AS Detail , 
					Q.QuestionTitle 
          FROM      dbo.View_AnswerMaster AS AM 
                    INNER JOIN dbo.Questions AS Q ON Q.QuestionnaireId = Am.QuestionnaireId 
                    LEFT OUTER JOIN dbo.Answers AS A ON A.AnswerMasterId = AM.ReportId 
                                                        AND A.QuestionId = Q.Id 
          WHERE     A.IsDeleted = 0 
                    AND AM.ActivityId =  ' + CONVERT(NVARCHAR(10), @ActivityId) 
                    + ' 
					AND AM.CreatedOn BETWEEN ''' + @FromDate + ''' AND ''' 
                    + @ToDate 
                    + ''' 
                   AND A.Id IS NOT NULL 
					AND Q.IsDeleted = 0 AND Q.Id NOT IN (16, 17, 23) 
					AND Q.IsDisplayInDetail = 1 
					GROUP BY AM.ReportId, AM.EstablishmentName, A.Detail, Q.QuestionTitle, Q.QuestionTypeId, Q.Id, AM.PI, Am.CreatedOn 
            ) x 
            pivot ( max(Detail) for QuestionTitle in (' + @cols + ') ) p '; 
            END; 
        ELSE 
            BEGIN 
                SELECT  @cols = STUFF((SELECT DISTINCT 
                                                ',' 
                                                + QUOTENAME(Q.QuestionTitle) 
                                       FROM     dbo.SeenClientQuestions AS Q 
                                       WHERE    Q.IsDeleted = 0 
                                                AND Q.SeenClientId = @SeenClientId 
                                                AND Q.Id NOT IN ( 16, 17, 23 ) 
                        FOR           XML PATH('') , 
                                          TYPE 
            ).value('.', 'NVARCHAR(MAX)'), 1, 1, ''); 
                SET @query = 'SELECT EstablishmentName AS [Establishment Name],dbo.ChangeDateFormat(CreatedOn, ''MM/dd/yyyy hh:mm AM/PM'') AS [Capture Date], UserName, PI, ' 
                    + @cols 
                    + ' 
             from  
             ( 
                SELECT    AM.ReportId, AM.EstablishmentName, AM.UserName, CAST(CAST(ROUND(am.PI,0) AS DECIMAL(18,0)) AS VARCHAR(50)) + ''%'' as PI, AM.CreatedOn, 
                    CASE Q.QuestionTypeId 
                            WHEN 8 
                            THEN ( CASE WHEN A.Detail IS NULL 
                                             OR A.Detail = '''' 
                                        THEN ISNULL(A.Detail, '''') 
                                        ELSE dbo.ChangeDateFormat(A.Detail, 
                                                              ''MM/dd/yyyy'') 
                                   END ) 
                            WHEN 9 
                            THEN ( CASE WHEN A.Detail IS NULL 
                                             OR A.Detail = '''' 
                                        THEN ISNULL(A.Detail, '''') 
                                        ELSE dbo.ChangeDateFormat(A.Detail, 
                                                              ''hh:mm AM/PM'') 
                                   END ) 
                            WHEN 22 
                            THEN ( CASE WHEN A.Detail IS NULL 
                                             OR A.Detail = '''' 
                                        THEN ISNULL(A.Detail, '''') 
                                        ELSE dbo.ChangeDateFormat(A.Detail, 
                                                              ''MM/dd/yyyy hh:mm AM/PM'') 
                                   END ) 
								   WHEN 1 
									THEN dbo.GetOptionNameByQuestionId(Q.Id, A.Detail, 1) 
							WHEN 23 
							THEN ( 
									CASE WHEN ISNULL(A.Detail,'''') = '''' 
										THEN '''' 
										
										ELSE +REPLACE('''+@ImageUriSeenclient+''','','','''')  + REPLACE(A.Detail,'','','''+ @ImageUriSeenclient+''')  
										END 
									) 
							WHEN 17 
							THEN ( 
									CASE WHEN ISNULL(A.Detail,'''') = '''' 
										THEN '''' 
										ELSE +REPLACE('''+@ImageUriSeenclient+''','','','''')  + REPLACE(A.Detail,'','','''+ @ImageUriSeenclient+''')  
										END 
									) 
                            ELSE ISNULL(Detail, '''') 
                          END AS Detail , 
					Q.QuestionTitle 
          FROM      dbo.View_SeenClientAnswerMaster AS AM 
                    INNER JOIN dbo.SeenClientQuestions AS Q ON Q.SeenClientId = Am.SeenClientId 
                    LEFT OUTER JOIN dbo.SeenClientAnswers AS A ON A.SeenClientAnswerMasterId = AM.ReportId 
                                                        AND A.QuestionId = Q.Id 
          WHERE     A.IsDeleted = 0 
                    AND AM.ActivityId =  ' + CONVERT(NVARCHAR(10), @ActivityId) 
                    + ' 
					AND AM.CreatedOn BETWEEN ''' + @FromDate + ''' AND ''' 
                    + @ToDate 
                    + ''' 
                   AND A.Id IS NOT NULL 
					AND Q.IsDeleted = 0 AND Q.Id NOT IN (16, 17, 23) 
					AND Q.IsDisplayInDetail = 1 
					GROUP BY AM.ReportId, AM.EstablishmentName, A.Detail, Q.QuestionTitle, Q.QuestionTypeId, Q.Id, AM.EI, AM.UserName, AM.PI, AM.CreatedOn 
            ) x 
            pivot  
            ( 
                max(Detail) 
                for QuestionTitle in (' + @cols + ') 
            ) p '; 
            END; 
        PRINT   @query; 
        EXECUTE(@query); 
    END;
