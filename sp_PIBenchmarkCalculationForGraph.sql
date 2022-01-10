CREATE PROC [dbo].[sp_PIBenchmarkCalculationForGraph]  
    @ActivityId BIGINT,  
    @FromDate DATETIME,  
    @EndDate DATETIME,  
    @QuestionnaireId BIGINT,  
    @IsOut BIT,  
    @UserId NVARCHAR(MAX),  
    @EstablishmentId NVARCHAR(MAX),  
    @QuestionId BIGINT  
AS  
BEGIN  
    --IF OBJECT_ID('tempdb..#tbl', 'U') IS NOT NULL      
    --    DROP TABLE #tbl;      
  
    --IF OBJECT_ID('tempdb..#temp', 'U') IS NOT NULL      
    --    DROP TABLE #temp;      
    SET NOCOUNT ON;  
  
    SET @EndDate = CAST(CONVERT(CHAR(8), @EndDate, 112) + ' 23:59:59.99' AS DATETIME);  
    SET @FromDate = DATEADD(dd, DATEDIFF(dd, 0, @FromDate), 0);  
    CREATE TABLE #temp  
    (  
        [ReportId] BIGINT,  
        [Weight] DECIMAL(18, 2),  
        [TotalWeight1] INT,  
        [NonMandetoryWeight1] DECIMAL(18, 2),  
        [NonMandetoryWeight2] DECIMAL(18, 2),  
        [NonMandetoryWeight3] DECIMAL(18, 2),  
        [PI] DECIMAL(18, 2),  
        [COUNT] BIGINT,  
        Details DECIMAL(18, 2)  
    );  
  
  
    CREATE TABLE #tbl  
    (  
        Id BIGINT IDENTITY(1, 1),  
        ReportId BIGINT,  
        [PI] DECIMAL(18, 2),  
        [Count] BIGINT,  
        [Details] BIGINT  
    );  
  
    IF (@IsOut = 0 AND @QuestionId = 0)  
    BEGIN  
  
  
        INSERT INTO #tbl  
        (  
            ReportId,  
            PI,  
            Count  
        )  
        SELECT Am.ReportId,  
               0,  
               1  
        FROM dbo.View_AnswerMaster AS Am  
        WHERE ActivityId = @ActivityId  
              AND Am.CreatedOn  
              BETWEEN @FromDate AND @EndDate  
              AND ISNULL(Am.IsDisabled, 0) = 0;  
  
  
        INSERT INTO #temp  
        SELECT ReportId,  
               (  
                   SELECT SUM(x.Weight) AS weight  
                   FROM  
                   (  
                       SELECT AVG(A.Weight) AS Weight,  
                              A.AnswerMasterId  
                       FROM dbo.Answers AS A  
                           INNER JOIN dbo.Questions AS Q  
                               ON A.QuestionId = Q.Id  
                       WHERE A.AnswerMasterId = t.ReportId  
                             AND A.IsDeleted = 0  
                             AND Q.DisplayInGraphs = 1  
                       GROUP BY A.QuestionId,  
                                A.AnswerMasterId  
                   ) x  
               ) AS Weight,  
               (  
                   SELECT SUM(MaxWeight)  
                   FROM dbo.Questions  
                   WHERE QuestionnaireId = @QuestionnaireId  
                         AND IsDeleted = 0  
                         AND DisplayInGraphs = 1  
               ) AS TotalWeight1,  
               (  
                   SELECT ISNULL(SUM(R.TotalWeight), 0)  
                   FROM  
                   (  
                       SELECT CASE  
                                  WHEN Q.QuestionTypeId IN ( 1, 6, 21 ) THEN  
                                      MAX(O.Weight)  
                                  ELSE  
                                      SUM(O.Weight)  
                              END AS TotalWeight,  
                              A.AnswerMasterId  
                       FROM dbo.Questions AS Q  
                           LEFT JOIN dbo.Options AS O  
                               ON O.QuestionId = Q.Id  
                           INNER JOIN dbo.Answers AS A  
                               ON A.QuestionId = Q.Id  
                                  AND Q.[Required] = 0  
                                  AND ISNULL(A.Detail, '') = ''  
                           INNER JOIN dbo.AnswerMaster AS AM  
                               ON AM.Id = A.AnswerMasterId  
                       WHERE Q.QuestionnaireId = AM.QuestionnaireId  
                             AND Q.QuestionTypeId IN ( 1, 5, 6, 18, 21 )  
                             AND Q.IsDeleted = 0  
                             AND Q.IsActive = 1  
                             AND Q.DisplayInGraphs = 1  
                             AND A.RepetitiveGroupId = 0  
                             AND A.AnswerMasterId = t.reportId  
                       GROUP BY Q.Id,  
                                Q.QuestionTypeId,  
                                A.AnswerMasterId  
                   ) AS R  
               ) AS NonMandetoryWeight1,  
               (  
                   SELECT ISNULL(SUM(R.TotalWeight), 0)  
                   FROM  
                   (  
                       SELECT CASE  
                                  WHEN Q.WeightForYes > Q.WeightForNo THEN  
                                      Q.WeightForYes  
                                  ELSE  
                                      Q.WeightForNo  
                              END AS TotalWeight,  
                              A.AnswerMasterId  
                       FROM dbo.Questions AS Q  
                           INNER JOIN dbo.Answers AS A  
                               ON A.QuestionId = Q.Id  
                                  AND Q.[Required] = 0  
                                  AND ISNULL(A.Detail, '') = ''  
                                  AND Q.QuestionTypeId IN ( 7 )  
                                  AND Q.IsDeleted = 0  
                                  AND Q.IsActive = 1  
                                  AND Q.DisplayInGraphs = 1  
                           INNER JOIN dbo.AnswerMaster AS AM  
                               ON AM.Id = A.AnswerMasterId  
                                  AND A.AnswerMasterId = t.reportid  
                                  AND A.RepetitiveGroupId = 0  
                                  AND Q.QuestionnaireId = AM.QuestionnaireId  
                       GROUP BY Q.Id,  
                                Q.WeightForYes,  
                                Q.WeightForNo,  
                                A.AnswerMasterId  
                   ) AS R  
               ) AS NonMandetoryWeight2,  
               (  
                   SELECT CASE  
                              WHEN ISNULL(Details, '') != '' THEN  
                                  0  
                              ELSE  
                                  R.MaxWeight  
                          END  
                   FROM  
                   (  
                       SELECT MAX(A.Detail) AS Details,  
                              A.QuestionId,  
                              Q.MaxWeight,  
                              A.AnswerMasterId  
                       FROM dbo.Questions AS Q  
                           LEFT JOIN dbo.Options AS O  
                               ON O.QuestionId = Q.Id  
                           INNER JOIN dbo.Answers AS A  
                               ON A.QuestionId = Q.Id  
                       WHERE Q.QuestionTypeId IN ( 1, 5, 6, 18, 21, 7 )  
                             AND Q.IsDeleted = 0  
                             AND Q.IsActive = 1  
                             AND Q.DisplayInGraphs = 1  
                             AND A.AnswerMasterId = t.reportId  
                             AND A.RepetitiveGroupId != 0  
                       GROUP BY A.QuestionId,  
                                Q.MaxWeight,  
                                A.AnswerMasterId  
                   ) AS R  
               ) AS NonMandetoryWeight3,  
               PI,  
               Count,  
               0.00  
        FROM #tbl t  
        GROUP BY t.ReportId,  
                 t.PI,  
                 t.Count;  
  
  
  
  
  
    END;  
  
    ELSE IF (@IsOut = 1 AND @QuestionId = 0)  
    BEGIN  
        INSERT INTO #tbl  
        (  
            ReportId,  
            PI,  
            Count  
        )  
        SELECT Am.ReportId,  
               0,  
               CASE Am.IsSubmittedForGroup  
                   WHEN 0 THEN  
                       1  
                   ELSE  
               (  
                   SELECT COUNT(DISTINCT SeenClientAnswerChildId)  
                   FROM dbo.SeenClientAnswers  
                   WHERE SeenClientAnswerMasterId = Am.ReportId  
               )  
               END  
        FROM View_SeenClientAnswerMaster Am  
        WHERE ActivityId = @ActivityId  
              AND Am.CreatedOn  
              BETWEEN @FromDate AND @EndDate  
              AND ISNULL(Am.IsDisabled, 0) = 0;  
  
        INSERT INTO #temp  
        SELECT ReportId,  
               (  
                   SELECT SUM(T.Weight)  
                   FROM  
                   (  
                       SELECT AVG(A.Weight) AS Weight  
                       FROM dbo.SeenClientAnswers AS A  
                           INNER JOIN dbo.SeenClientQuestions AS Q  
                               ON A.QuestionId = Q.Id  
                       WHERE SeenClientAnswerMasterId = #tbl.ReportId  
                             AND A.IsDeleted = 0  
                             AND Q.DisplayInGraphs = 1  
                       GROUP BY A.SeenClientAnswerChildId,  
                                A.QuestionId  
                   ) AS T  
               ) AS Weight,  
               (  
                   SELECT SUM(MaxWeight)  
                   FROM dbo.SeenClientQuestions  
                   WHERE SeenClientId = @QuestionnaireId  
                         AND IsDeleted = 0  
                         AND DisplayInGraphs = 1  
                         AND IsActive = 1  
               ) AS TotalWeight1,  
               ISNULL(  
               (  
                   SELECT ISNULL(SUM(R.TotalWeight), 0)  
                   FROM  
                   (  
                       SELECT CASE  
                                  WHEN Q.QuestionTypeId IN ( 1, 6, 21 ) THEN  
                                      MAX(O.Weight)  
                                  ELSE  
                                      SUM(O.Weight)  
                              END AS TotalWeight  
                       FROM dbo.SeenClientQuestions AS Q  
                           LEFT JOIN dbo.SeenClientOptions AS O  
                               ON O.QuestionId = Q.Id  
                           INNER JOIN dbo.SeenClientAnswers AS SA  
                               ON SA.QuestionId = Q.Id  
                                  AND Q.[Required] = 0  
                                  AND ISNULL(SA.Detail, '') = ''  
                           INNER JOIN dbo.SeenClientAnswerMaster AS SCA  
                               ON SCA.Id = #tbl.ReportId  
                       WHERE Q.SeenClientId = SCA.SeenClientId  
                             AND Q.QuestionTypeId IN ( 1, 5, 6, 18, 21 )  
                             AND Q.IsDeleted = 0  
                             AND Q.IsActive = 1  
                             AND Q.DisplayInGraphs = 1  
                             AND SA.SeenClientAnswerMasterId = #tbl.ReportId  
                             AND SA.RepetitiveGroupId = 0  
                       GROUP BY Q.Id,  
                                Q.QuestionTypeId  
                   ) AS R  
               ),  
               0  
                     ) NonMandetoryWeight1,  
               ISNULL(  
               (  
                   SELECT ISNULL(SUM(R.TotalWeight), 0)  
                   FROM  
                   (  
                       SELECT CASE  
                                  WHEN Q.WeightForYes > Q.WeightForNo THEN  
                                      Q.WeightForYes  
                                  ELSE  
                                      Q.WeightForNo  
                              END AS TotalWeight  
                       FROM dbo.SeenClientQuestions AS Q  
                           INNER JOIN dbo.SeenClientAnswers AS SA  
                               ON SA.QuestionId = Q.Id  
                                  AND Q.[Required] = 0  
                                  AND ISNULL(SA.Detail, '') = ''  
                           INNER JOIN dbo.SeenClientAnswerMaster AS SCA  
                               ON SCA.Id = #tbl.ReportId  
                       WHERE Q.SeenClientId = SCA.SeenClientId  
                             AND Q.QuestionTypeId IN ( 7 )  
                             AND Q.IsDeleted = 0  
                             AND Q.IsActive = 1  
                            AND Q.DisplayInGraphs = 1  
                             AND SA.RepetitiveGroupId = 0  
                             AND SA.SeenClientAnswerMasterId = #tbl.ReportId  
                       GROUP BY Q.Id,  
                                Q.WeightForYes,  
                                Q.WeightForNo  
                   ) AS R  
               ),  
               0  
                     ) NonMandetoryWeight2,  
               ISNULL(  
               (  
                   SELECT CASE  
                              WHEN ISNULL(Details, '') != '' THEN  
                                  0  
                              ELSE  
                                  T.MaxWeight  
                          END  
                   FROM  
                   (  
                       SELECT MAX(SA.Detail) AS Details,  
                              SA.QuestionId,  
                              Q.MaxWeight  
                       FROM dbo.SeenClientQuestions AS Q  
                           LEFT JOIN dbo.SeenClientOptions AS O  
                               ON O.QuestionId = Q.Id  
                           INNER JOIN dbo.SeenClientAnswers AS SA  
                               ON SA.QuestionId = Q.Id  
                       WHERE Q.QuestionTypeId IN ( 1, 5, 6, 18, 21, 7 )  
                             AND Q.IsDeleted = 0  
                             AND Q.IsActive = 1  
                             AND Q.DisplayInGraphs = 1  
                             AND SA.SeenClientAnswerMasterId = #tbl.ReportId  
                             AND SA.RepetitiveGroupId != 0  
                       GROUP BY SA.QuestionId,  
                                Q.MaxWeight  
                   ) AS T  
               ),  
               0  
                     ) NonMandetoryWeight3,  
               PI,  
               Count,  
               0.00  
        FROM #tbl  
        GROUP BY ReportId,  
                 PI,  
                 Count;  
  
  
  
  
  
    END;  
  
    IF (@IsOut = 0 AND @QuestionId > 0)  
    BEGIN  
  
  
        INSERT INTO #tbl  
        (  
            ReportId,  
            PI,  
            Count  
        )  
        SELECT Am.ReportId,  
               0,  
               1  
        FROM dbo.View_AnswerMaster AS Am  
        WHERE ActivityId = @ActivityId  
              AND Am.CreatedOn  
              BETWEEN @FromDate AND @EndDate  
              AND ISNULL(Am.IsDisabled, 0) = 0;  
  
  
        INSERT INTO #temp  
        SELECT ReportId,  
               (  
                   SELECT SUM(TT.Weight)  
                   FROM  
                   (  
                       SELECT AVG(A.Weight) AS Weight  
                       FROM dbo.Answers AS A  
                           INNER JOIN dbo.Questions AS Q  
                               ON A.QuestionId = Q.Id  
                       WHERE A.AnswerMasterId = t.ReportId  
                             AND A.QuestionId = @QuestionId  
                             AND A.IsDeleted = 0  
                             AND Q.DisplayInGraphs = 1  
                       GROUP BY A.QuestionId  
                   ) AS TT  
               ) AS Weight,  
               (  
                   SELECT SUM(MaxWeight)  
                   FROM dbo.Questions  
                   WHERE Id = @QuestionId  
                         AND IsDeleted = 0  
                         AND DisplayInGraphs = 1  
                         AND IsActive = 1  
               ) AS TotalWeight1,  
               0,  
               0,  
               0,  
               PI,  
               Count,  
               (  
                   SELECT TOP 1  
                       D.Details  
                   FROM  
                   (  
                       SELECT CASE A.Detail  
                                  WHEN '' THEN  
                                      0  
                                  ELSE  
                                      1  
                              END Details  
                       FROM dbo.Answers AS A  
                           INNER JOIN dbo.Questions AS Q  
                               ON A.QuestionId = Q.Id  
                       WHERE AnswerMasterId = t.reportid  
                             AND A.QuestionId = @QuestionId  
                             AND A.IsDeleted = 0  
                             AND Q.DisplayInGraphs = 1  
                   ) D  
               ) AS Details  
        FROM #tbl t  
        GROUP BY t.ReportId,  
                 t.PI,  
                 t.Count;  
  
  
  
  
  
    END;  
  
    ELSE IF (@IsOut = 1 AND @QuestionId > 0)  
    BEGIN  
        INSERT INTO #tbl  
        (  
            ReportId,  
            PI,  
            Count  
        )  
        SELECT Am.ReportId,  
               0,  
               CASE Am.IsSubmittedForGroup  
                   WHEN 0 THEN  
                       1  
                   ELSE  
               (  
                   SELECT COUNT(DISTINCT SeenClientAnswerChildId)  
                   FROM dbo.SeenClientAnswers  
                   WHERE SeenClientAnswerMasterId = Am.ReportId  
               )  
               END  
        FROM View_SeenClientAnswerMaster Am  
        WHERE ActivityId = @ActivityId  
              AND Am.CreatedOn  
              BETWEEN @FromDate AND @EndDate  
              AND ISNULL(Am.IsDisabled, 0) = 0;  
  
        INSERT INTO #temp  
        SELECT ReportId,  
               (  
                   SELECT SUM(T.Weight)  
                   FROM  
                   (  
                       SELECT AVG(A.Weight) AS Weight  
                       FROM dbo.SeenClientAnswers AS A  
                           INNER JOIN dbo.SeenClientQuestions AS Q  
                               ON A.QuestionId = Q.Id  
                       WHERE SeenClientAnswerMasterId = #tbl.ReportId  
                             AND A.QuestionId = @QuestionId  
                             AND A.IsDeleted = 0  
                             AND Q.DisplayInGraphs = 1  
                       GROUP BY A.SeenClientAnswerChildId,  
                                A.QuestionId,  
                                SeenClientAnswerMasterId  
                   ) AS T  
               ) AS Weight,  
               (  
                   SELECT SUM(MaxWeight)  
                   FROM dbo.SeenClientQuestions  
                   WHERE Id = @QuestionId  
                         AND IsDeleted = 0  
                         AND DisplayInGraphs = 1  
               ) AS TotalWeight1,  
               0,  
               0,  
               0,  
               PI,  
               Count,  
               (  
                   SELECT TOP 1  
                       t.detail  
                   FROM  
                   (  
                       SELECT CASE A.Detail  
                                  WHEN '' THEN  
                                      0  
                                  ELSE  
                                      1  
                              END detail  
                       FROM dbo.SeenClientAnswers AS A  
                           INNER JOIN dbo.SeenClientQuestions AS Q  
                               ON A.QuestionId = Q.Id  
                       WHERE SeenClientAnswerMasterId = #tbl.ReportId  
                             AND A.QuestionId = @QuestionId  
                             AND A.IsDeleted = 0  
                             AND Q.DisplayInGraphs = 1  
                   ) t  
               ) AS Details  
        FROM #tbl  
        GROUP BY ReportId,  
                 PI,  
                 Count;  
  
  
  
  
  
    END;  
  
  
  
  
    IF (@IsOut = 0)  
    BEGIN  
        UPDATE #tbl  
        SET PI = ((Weight * 100  
                   / (CASE ISNULL(  
                                     (TotalWeight1  
                                      - (ISNULL(NonMandetoryWeight1, 0) + ISNULL(NonMandetoryWeight2, 0)  
                                         + ISNULL(NonMandetoryWeight3, 0)  
                                        )  
                                     ),  
                                     0  
                                 )  
                        WHEN 0 THEN  
                              1  
                          ELSE  
            (ISNULL(TotalWeight1, 0)  
             - ((ISNULL(NonMandetoryWeight1, 0) + ISNULL(NonMandetoryWeight2, 0) + ISNULL(NonMandetoryWeight3, 0)))  
            )  
                      END  
                     )  
                  ) / (CASE #tbl.Count  
                           WHEN 0 THEN  
                               1  
                           ELSE  
                               #tbl.Count  
                       END  
                      )  
                 )  
        FROM #tbl  
            INNER JOIN #temp  
                ON #tbl.ReportId = #temp.ReportId;  
  
        SELECT CAST(ROUND(   (ROUND((SUM([PI])), 0) / CASE COUNT(ReportId)  
                                                          WHEN 0 THEN  
                                                              1  
                                                          ELSE  
                                                              COUNT(ReportId)  
                                                      END  
                             ),  
                             0  
                         ) AS DECIMAL(18,2))  
        FROM #tbl;  
  
    END;  
    ELSE  
    BEGIN  
        UPDATE #tbl  
        SET PI = ((Weight * 100 / (CASE ISNULL((TotalWeight1), 0)  
                                       WHEN 0 THEN  
                                           1  
                                       ELSE  
            (ISNULL(TotalWeight1, 0))  
                                   END  
                                  )  
                  ) / (CASE #tbl.Count  
                           WHEN 0 THEN  
                               1  
                           ELSE  
                               #tbl.Count  
                       END  
                      )  
                 ),  
            Details = #temp.Details  
        FROM #tbl  
            INNER JOIN #temp  
                ON #tbl.ReportId = #temp.ReportId;  
  
        SELECT CAST(ROUND(   (ROUND((SUM([PI])), 0) / CASE SUM(Details)  
                                                          WHEN 0 THEN  
                                                              1  
                                                          ELSE  
                                                              SUM(Details)  
                                                      END  
                             ),  
                             0  
                         ) AS DECIMAL(18,2))  
        FROM #tbl;  
  
    END;  
  
    SET NOCOUNT OFF;  
END;  