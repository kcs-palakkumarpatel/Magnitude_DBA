      
-- =============================================      
-- Author:  <Disha>      
-- Create date: <13-SEP-2014>      
-- Description: <get concated string values>      
-- Calls :select dbo.ConcateString ('Questions',1)     
-- =============================================      
CREATE FUNCTION [dbo].[ConcateString]  
    (  
      @Table NVARCHAR(50) = 'SeenClientAnswers' ,  
      @FilterValue BIGINT      
    )  
RETURNS NVARCHAR(MAX)  
AS  
    BEGIN      
        DECLARE @listStr NVARCHAR(MAX);    
        DECLARE @AppndChars NVARCHAR(10);      
        DECLARE @NewLineChar AS CHAR(2);       
        DECLARE @listStrQuestion NVARCHAR(MAX);    
    
        SET @NewLineChar = CHAR(13) + CHAR(10);  
        SET @AppndChars = '\n';      
      
              
        IF ( @Table = 'SeenClientAnswers' )  
            BEGIN      
                DECLARE @TempTable TABLE  
                    (  
                      QuestionId BIGINT ,  
                      QuestionTitle NVARCHAR(MAX) ,  
                      QuestionPosition INT  
                    );    
                INSERT  INTO @TempTable  
                        SELECT  Q.Id ,  
                                COALESCE(ShortName + ': '  
                                         + CASE Q.QuestionTypeId  
                                             WHEN 8  
                                             THEN ( CASE WHEN A.Detail IS NULL  
                                                              OR A.Detail = ''  
                                                         THEN ISNULL(A.Detail,  
                                                              '')  
                                                         ELSE dbo.ChangeDateFormat(A.Detail,  
                                                              'dd/MMM/yyyy')  
                                                    END )  
                                             WHEN 9  
                                             THEN ( CASE WHEN A.Detail IS NULL  
                                                              OR A.Detail = ''  
                                                         THEN ISNULL(A.Detail,  
                                                              '')  
                                                         ELSE dbo.ChangeDateFormat(A.Detail,  
                                                              'hh:mm AM/PM')  
                                                    END )  
                                             WHEN 22  
                                             THEN ( CASE WHEN A.Detail IS NULL  
                                                              OR A.Detail = ''  
                                                         THEN ISNULL(A.Detail,  
                                                              '')  
                                                         ELSE dbo.ChangeDateFormat(A.Detail,  
                                                              'dd/MMM/yyyy hh:mm AM/PM')  
                                                    END )  
                                             ELSE ISNULL(Detail, '')  
                                           END + @AppndChars, '') ,  
                                Q.Position  
                        FROM    dbo.SeenClientAnswerMaster AS AM  
                                INNER JOIN dbo.SeenClient AS Qr ON AM.SeenClientId = Qr.Id  
                                INNER JOIN dbo.SeenClientQuestions AS Q ON Qr.Id = Q.SeenClientId  
                                LEFT OUTER JOIN dbo.SeenClientAnswers AS A ON AM.Id = A.SeenClientAnswerMasterId  
                                                              AND Q.Id = A.QuestionId  
                        WHERE   Q.IsDisplayInSummary = 1  
                                AND AM.Id = @FilterValue  
                                AND ISNULL(A.IsDeleted, 0) = 0;  
  
                SELECT  @listStr = COALESCE(@listStr, '') + QuestionTitle  
                FROM    @TempTable  
                ORDER BY QuestionPosition ,  
                        QuestionId;  
            END;      
        ELSE  
            IF ( @Table = 'SeenClientAnswersDetail' )  
                BEGIN      
                    DECLARE @TempTableDtl TABLE  
                        (  
                          QuestionId BIGINT ,  
                          QuestionTitle NVARCHAR(MAX) ,  
                          QuestionPosition INT  
                        );    
                    INSERT  INTO @TempTableDtl  
                            SELECT  Q.Id ,  
                                    COALESCE(CASE Q.QuestionTypeId  
                                               WHEN 8  
                                               THEN ( CASE WHEN A.Detail IS NULL  
                                                              OR A.Detail = ''  
                                                           THEN ISNULL(A.Detail,  
                                                              '')  
                                                           ELSE dbo.ChangeDateFormat(A.Detail,  
                                                              'dd/MMM/yyyy')  
                                                      END )  
                                               WHEN 9  
                                               THEN ( CASE WHEN A.Detail IS NULL  
                                                              OR A.Detail = ''  
                                                           THEN ISNULL(A.Detail,  
                                                              '')  
                                                           ELSE dbo.ChangeDateFormat(A.Detail,  
                                                              'hh:mm AM/PM')  
                                                      END )  
                                               WHEN 22  
                                               THEN ( CASE WHEN A.Detail IS NULL  
                                                              OR A.Detail = ''  
                                                           THEN ISNULL(A.Detail,  
                                                              '')  
                                                           ELSE dbo.ChangeDateFormat(A.Detail,  
                                                              'dd/MMM/yyyy hh:mm AM/PM')  
                                                      END )  
                                               ELSE ISNULL(Detail, '')  
                                             END + '||', '') ,  
                                    Q.Position  
                            FROM    dbo.SeenClientAnswerMaster AS AM  
                                    INNER JOIN dbo.SeenClient AS Qr ON AM.SeenClientId = Qr.Id  
                                    INNER JOIN dbo.SeenClientQuestions AS Q ON Qr.Id = Q.SeenClientId  
                                    LEFT OUTER JOIN dbo.SeenClientAnswers AS A ON AM.Id = A.SeenClientAnswerMasterId  
                                                              AND Q.Id = A.QuestionId  
                            WHERE   Q.IsDisplayInDetail = 1  
                                    AND Q.QuestionTypeId <> 16  
                                    AND AM.Id = @FilterValue  
                                    AND ISNULL(A.IsDeleted, 0) = 0;  
  
                    SELECT  @listStr = COALESCE(@listStr, '') + QuestionTitle  
                    FROM    @TempTableDtl  
                    ORDER BY QuestionPosition ,  
                            QuestionId;  
                END;    
            ELSE  
                IF ( @Table = 'Answers' )  
                    BEGIN  
                        DECLARE @TempTableAnswers TABLE  
                            (  
                              QuestionId BIGINT ,  
                              QuestionTitle NVARCHAR(MAX) ,  
                              QuestionPosition INT  
                            );    
                        INSERT  INTO @TempTableAnswers  
                        SELECT  Q.Id ,  
                                        COALESCE(ShortName + ': '  
                                                 + CASE WHEN ( Q.QuestionTypeId = 10  
                                                              OR Q.QuestionTypeId = 11  
                                                             )  
                                                             AND ( A.Detail IS NULL  
                                                              OR A.Detail = ''  
                                                              )  
                                                        THEN ' (Anonymous) '  
                                                        ELSE ''  
                                                   END  
                                                 + CASE Q.QuestionTypeId  
                                                     WHEN 8  
                                                     THEN ( CASE  
                                                              WHEN A.Detail IS NULL  
                                                              OR A.Detail = ''  
                                                              THEN ISNULL(A.Detail,  
                                                              '')  
                                                              ELSE dbo.ChangeDateFormat(A.Detail,  
                                                              'dd/MMM/yyyy')  
                                                            END )  
                                                     WHEN 9  
                                                     THEN ( CASE  
                                                              WHEN A.Detail IS NULL  
                                                              OR A.Detail = ''  
                                                              THEN ISNULL(A.Detail,  
                                                              '')  
                                                              ELSE dbo.ChangeDateFormat(A.Detail,  
                                                              'hh:mm AM/PM')  
                                                            END )  
                                                     WHEN 22  
                                                     THEN ( CASE  
                                                              WHEN A.Detail IS NULL  
                                                              OR A.Detail = ''  
                                                              THEN ISNULL(A.Detail,  
                                                              '')  
                                                              ELSE dbo.ChangeDateFormat(A.Detail,  
                                                              'dd/MMM/yyyy hh:mm AM/PM')  
                                                            END )  
                                                     ELSE ISNULL(Detail, '')  
                                                   END + @AppndChars, '') ,  
                                        Q.Position  
                                FROM    dbo.AnswerMaster AS AM  
                                        INNER JOIN dbo.Questionnaire AS Qr ON AM.QuestionnaireId = Qr.Id  
                                        INNER JOIN dbo.Questions AS Q ON Qr.Id = Q.QuestionnaireId  
                                        LEFT OUTER JOIN dbo.Answers AS A ON AM.Id = A.AnswerMasterId  
                                                              AND Q.Id = A.QuestionId  
                                WHERE   Q.IsDisplayInSummary = 1  
                                        AND AM.Id = @FilterValue  
                                        AND ISNULL(A.IsDeleted, 0) = 0;  
  
                        SELECT  @listStr = COALESCE(@listStr, '')  
                                + QuestionTitle  
                        FROM    @TempTableAnswers  
                        ORDER BY QuestionPosition ,  
                                QuestionId;                                
                    END;      
                ELSE  
                    IF ( @Table = 'AnswersDetail' )  
                        BEGIN  
                            DECLARE @TempTableAnswersDtl TABLE  
                                (  
                                  QuestionId BIGINT ,  
                                  QuestionTitle NVARCHAR(MAX) ,  
                                  QuestionPosition INT  
                                );    
                            INSERT  INTO @TempTableAnswersDtl  
                                    SELECT  Q.Id ,  
                                            COALESCE(CASE Q.QuestionTypeId  
                                                       WHEN 8  
                                                       THEN ( CASE  
                                                              WHEN A.Detail IS NULL  
                                                              OR A.Detail = ''  
                                                              THEN ISNULL(A.Detail,  
                                                              '')  
                                                              ELSE dbo.ChangeDateFormat(A.Detail,  
                                                              'dd/MMM/yyyy')  
                                                              END )  
                                                       WHEN 9  
                                                       THEN ( CASE  
                                                              WHEN A.Detail IS NULL  
                                                              OR A.Detail = ''  
                                                              THEN ISNULL(A.Detail,  
                                                              '')  
                                                              ELSE dbo.ChangeDateFormat(A.Detail,  
                                                              'hh:mm AM/PM')  
                                                              END )  
                                                       WHEN 22  
                                                       THEN ( CASE  
                                                              WHEN A.Detail IS NULL  
                                                              OR A.Detail = ''  
                                                              THEN ISNULL(A.Detail,  
                                                              '')  
                                                              ELSE dbo.ChangeDateFormat(A.Detail,  
                                                              'dd/MMM/yyyy hh:mm AM/PM')  
                                                              END )  
                                                       ELSE ISNULL(Detail, '')  
                                                     END + '||', '') ,  
                                            Q.Position  
                                    FROM    dbo.AnswerMaster AS AM  
                                            INNER JOIN dbo.Questionnaire AS Qr ON AM.QuestionnaireId = Qr.Id  
                                            INNER JOIN dbo.Questions AS Q ON Qr.Id = Q.QuestionnaireId  
                                            LEFT OUTER JOIN dbo.Answers AS A ON AM.Id = A.AnswerMasterId  
                                                              AND Q.Id = A.QuestionId  
                                    WHERE   Q.IsDisplayInDetail = 1  
                                            AND Q.QuestionTypeId <> 16  
                                            AND AM.Id = @FilterValue  
                                            AND ISNULL(A.IsDeleted, 0) = 0;  
  
                            SELECT  @listStr = COALESCE(@listStr, '')  
                                    + QuestionTitle  
                            FROM    @TempTableAnswersDtl  
       ORDER BY QuestionPosition ,  
                                    QuestionId;                                
                        END;      
                    ELSE  
                        IF ( @Table = 'Questions' )  
                            BEGIN  
                                DECLARE @TempTableQuestions TABLE  
                                    (  
                                      QuestionId BIGINT ,  
                                      QuestionTitle NVARCHAR(MAX) ,  
                                      QuestionPosition INT  
                                    );    
                                INSERT  INTO @TempTableQuestions  
                                        SELECT  Q.Id ,  
                                                COALESCE(Q.QuestionTitle  
                                                         + '||', '') ,  
                                                Q.Position  
                                        FROM    dbo.AnswerMaster AS AM  
                                                INNER JOIN dbo.Questionnaire  
                                                AS Qr ON AM.QuestionnaireId = Qr.Id  
                                                INNER JOIN dbo.Questions AS Q ON Qr.Id = Q.QuestionnaireId  
                                        WHERE   Q.IsDisplayInDetail = 1  
                                                AND Q.QuestionTypeId <> 16  
                                                AND AM.Id = @FilterValue  
                                                AND Q.IsDeleted = 0  
                                                AND AM.IsDeleted = 0  
                                                AND Qr.IsDeleted = 0;  
  
                                SELECT  @listStr = COALESCE(@listStr, '')  
                                        + QuestionTitle  
                                FROM    @TempTableQuestions  
                                ORDER BY QuestionPosition ,  
                                        QuestionId;                                
                            END;      
                        ELSE  
                            IF ( @Table = 'SeenClientQuestions' )  
                                BEGIN  
                                    DECLARE @TempTableQuestionsSC TABLE  
                                        (  
                                          QuestionId BIGINT ,  
                                          QuestionTitle NVARCHAR(MAX) ,  
                                          QuestionPosition INT  
                                        );    
                                    INSERT  INTO @TempTableQuestionsSC  
                                            SELECT  Q.Id ,  
                                                    COALESCE(Q.QuestionTitle  
                                                             + '||', '') ,  
                                                    Q.Position  
                                            FROM    dbo.SeenClientAnswerMaster  
                                                    AS AM  
                                                    INNER JOIN dbo.SeenClient  
                                                    AS Qr ON AM.SeenClientId = Qr.Id  
                                                    INNER JOIN dbo.SeenClientQuestions  
                                                    AS Q ON Qr.Id = Q.SeenClientId  
                                            WHERE   Q.IsDisplayInDetail = 1  
                                                    AND Q.QuestionTypeId <> 16  
                                                    AND AM.Id = @FilterValue  
                                                    AND Q.IsDeleted = 0  
                                                    AND AM.IsDeleted = 0  
                                                    AND Qr.IsDeleted = 0;  
  
                                    SELECT  @listStr = COALESCE(@listStr, '')  
                                            + QuestionTitle  
                                    FROM    @TempTableQuestionsSC  
                                    ORDER BY QuestionPosition ,  
                                            QuestionId;                                
                                END;      
                            ELSE  
                                IF ( @Table = 'ResolutionComments' )  
                                    BEGIN    
                                        SELECT  @listStr = COALESCE(@listStr  
                                                              + ' ', '')  
                                                + ISNULL(ResolutionComments.Comments,  
                                                         '')  
                                        FROM    ( SELECT    ( CONVERT(NVARCHAR(50), ROW_NUMBER() OVER ( ORDER BY dbo.CloseLoopAction.Id ASC ))  
                                                              + ') '  
                                                              + dbo.AppUser.Name  
                                                              + ' - '  
                                                              + dbo.ChangeDateFormat(DATEADD(MINUTE,  
                                                              TimeOffSet,  
                                                              dbo.CloseLoopAction.CreatedOn),  
                                                              'dd/MMM/yyyy HH:mm AM/PM')  
                                                              + ' - '  
                                                              + REPLACE(REPLACE(ISNULL([Conversation],  
                                                              ''), CHAR(13),  
                                                              ' '), CHAR(10),  
                                                              ' ') ) AS Comments  
                                                  FROM      dbo.CloseLoopAction  
                                                            INNER JOIN dbo.AnswerMaster ON AnswerMaster.Id = CloseLoopAction.AnswerMasterId  
                                                            INNER JOIN dbo.AppUser ON CloseLoopAction.AppUserId = dbo.AppUser.Id  
                                                  WHERE     dbo.CloseLoopAction.AnswerMasterId = @FilterValue  
                                                ) AS ResolutionComments;  
                                    END;   
                                ELSE  
                                    IF ( @Table = 'ResolutionCommentsSeenClient' )  
                                        BEGIN    
                                            SELECT  @listStr = COALESCE(@listStr  
                                                              + ' ', '')  
                                                    + ISNULL(ResolutionComments.Comments,  
                                                             '')  
                                            FROM    ( SELECT  ( CONVERT(NVARCHAR(50), ROW_NUMBER() OVER ( ORDER BY dbo.CloseLoopAction.Id ASC ))  
                                                              + ') '  
                                                              + dbo.AppUser.Name  
                                                              + ' - '  
                                                              + dbo.ChangeDateFormat(DATEADD(MINUTE,  
                                                              TimeOffSet,  
                                                              dbo.CloseLoopAction.CreatedOn),  
                                                              'dd/MMM/yyyy HH:mm AM/PM')  
                                                              + ' - '  
                                                              + REPLACE(REPLACE(ISNULL([Conversation],  
                                                              ''), CHAR(13),  
                                                              ' '), CHAR(10),  
                                            ' ') ) AS Comments  
                                                      FROM    dbo.CloseLoopAction  
                                                              INNER JOIN dbo.SeenClientAnswerMaster ON SeenClientAnswerMaster.Id = CloseLoopAction.SeenClientAnswerMasterId  
                                                              INNER JOIN dbo.AppUser ON CloseLoopAction.AppUserId = dbo.AppUser.Id  
                                                      WHERE   dbo.CloseLoopAction.SeenClientAnswerMasterId = @FilterValue  
                                                    ) AS ResolutionComments;  
                                        END;   
                                    ELSE  
                                        IF ( @Table = 'ReprotSetting' )  
                                            BEGIN    
                                                SELECT  @listStr = COALESCE(@listStr  
                                                              + ',', '')  
                                                        + CONVERT(NVARCHAR(50), ISNULL(QuestionsID,  
                                                              ''))  
                                                FROM    ( SELECT  
                                                              Questions.Id AS QuestionsID  
                                                          FROM  
                                                              Questionnaire  
                                                              INNER JOIN Questions ON Questionnaire.Id = Questions.QuestionnaireId  
                                                          WHERE  
                                                              ( Questionnaire.QuestionnaireType = 'EI' )  
                                                              AND ( Questions.QuestionTypeId = 1 )  
                                                              AND ( Questionnaire.Id = @FilterValue )  
                                                              AND ( Questionnaire.IsDeleted = 0 )  
                                                        ) AS ProcurementPlanDetailsFund;    
                                            END;     
                                        ELSE  
                                            IF ( @Table = 'SeenClientReportSetting' )  
                                                BEGIN    
                                                    SELECT  @listStr = COALESCE(@listStr  
                                                              + ',', '')  
                                                            + CONVERT(NVARCHAR(50), ISNULL(QuestionsID,  
                                                              ''))  
                                                    FROM    ( SELECT  
                                                              Sq.Id AS QuestionsID  
                                                              FROM  
                                                              dbo.SeenClient  
                                                              AS S  
                                                              INNER JOIN dbo.SeenClientQuestions  
                                                              AS Sq ON S.Id = Sq.SeenClientId  
                                                              WHERE  
                                                              ( S.SeenClientType = 'EI' )  
                                                              AND ( Sq.QuestionTypeId = 1 )  
                                                              AND ( S.Id = @FilterValue )  
                                                              AND ( Sq.IsDeleted = 0 )  
                                                            ) AS ProcurementPlanDetailsFund;    
                                                END;      
                                            ELSE  
                 IF ( @Table = 'ContactDetailKeyName' )  
                                                    BEGIN    
                                                        SELECT  
                                                              @listStr = COALESCE(@listStr  
                                                              + ',', '')  
                                                              + CONVERT(NVARCHAR(50), ISNULL(KeyName,  
                                                              ''))  
                                                        FROM  ( SELECT  
                                                              KeyName  
                                                              FROM  
                                                              dbo.ContactDetail  
                                                              WHERE  
                                                              ContactId = @FilterValue  
                                                              ) AS KeyName;    
                                                    END;   
              
                                                ELSE  
                                                    IF ( @Table = 'ContactDetailKeyValue' )  
                                                        BEGIN    
                                                            SELECT  
                                                              @listStr = COALESCE(@listStr  
                                                              + ',', '')  
                                                              + CONVERT(NVARCHAR(50), ISNULL(KeyValue,  
                                                              ''))  
                                                            FROM  
                                                              ( SELECT  
                                                              KeyValue  
                                                              FROM  
                                                              dbo.ContactDetail  
                                                              WHERE  
                                                              ContactId = @FilterValue  
                                                              ) AS KeyValue;  
                                                        END;   
              
                                                    ELSE  
                                                        IF ( @Table = 'AppUserEstablishment' )  
                                                            BEGIN    
                                                              SELECT  
                                                              @listStr = COALESCE(@listStr  
                                                              + ', ', '')  
                                                              + CONVERT(NVARCHAR(50), ISNULL(EstablishmentName,  
                                                              ''))  
                                                              FROM  
                                                              ( SELECT  
                                                              EstablishmentName  
                                                              FROM  
                                                              dbo.AppUserEstablishment  
                                                              INNER JOIN dbo.Establishment ON dbo.AppUserEstablishment.EstablishmentId = dbo.Establishment.Id  
                                                              WHERE  
                                                              AppUserId = @FilterValue  
                                                              AND dbo.AppUserEstablishment.IsDeleted = 0  
                                    --AND UserType = 'Customer'  
                                                              ) AS EstablishmentId;  
                                                           END;   
              
                                                        ELSE  
                                                            IF ( @Table = 'Sales' )  
                                                              BEGIN    
                                                              SELECT  
                                                              @listStr = COALESCE(@listStr  
                                                              + ',', '')  
                                                              + CONVERT(NVARCHAR(50), ISNULL(EstablishmentId,  
                                                              ''))  
                                                              FROM  
                                                              ( SELECT  
                                                              EstablishmentId  
                                                              FROM  
                                                              dbo.AppUserEstablishment  
                                                              WHERE  
                                                              AppUserId = @FilterValue  
                                    --AND UserType = 'Sales'  
                                                              ) AS EstablishmentId;  
                                                              END;   
              
                                                            ELSE  
                                                              IF ( @Table = 'Supplier' )  
                                                              BEGIN    
                                                              SELECT  
                                                              @listStr = COALESCE(@listStr  
                                                              + ',', '')  
                                                              + CONVERT(NVARCHAR(50), ISNULL(EstablishmentId,  
                                                              ''))  
                                                              FROM  
                                                              ( SELECT  
                                                              EstablishmentId  
                                                              FROM  
                                                              dbo.AppUserEstablishment  
                                                              WHERE  
                                                              AppUserId = @FilterValue  
                                    --AND UserType = 'Supplier'  
                                                              ) AS EstablishmentId;  
                                                              END;   
                                                              ELSE  
                                                              IF ( @Table = 'Options' )  
                                                              BEGIN    
                                                              SELECT  
                                                              @listStr = COALESCE(@listStr  
                                                              + ',', '')  
                                                              + CONVERT(NVARCHAR(50), ISNULL(Name,  
                                                              ''))  
                                                              FROM  
                                                              ( SELECT  
                                                              Name  
                                                              FROM  
                                                              dbo.Options  
                                                              WHERE  
                                                              Id IN (  
                                                     SELECT  
                                                              OptionId  
                                                              FROM  
                                                              dbo.Answers  
                                                              WHERE  
                                                              Id = @FilterValue )  
                                                              ) AS EstablishmentId;  
                                                              END;  
                 ----Contact Summary  
                                                              ELSE  
                                                              IF ( @Table = 'ContactSummary' )  
                                                              BEGIN  
                                                              SELECT  
                                                              @listStr = COALESCE(@listStr  
                                                              + ', ', '')  
                                                              + CONVERT(NVARCHAR(50), ISNULL(Detail,  
                                                              ''))  
                                                              FROM  
                                                              ( SELECT  
                                                              CASE Cd.QuestionTypeId  
                                                              WHEN 8  
                                                              THEN CONVERT(NVARCHAR(50), dbo.ChangeDateFormat(Detail,  
                                                              'dd/MMM/yyyy'))  
                                                              WHEN 9  
                                                              THEN CONVERT(NVARCHAR(50), dbo.ChangeDateFormat(Detail,  
                                                              'hh:mm AM/PM'))  
                                                              WHEN 22  
                                                              THEN CONVERT(NVARCHAR(50), dbo.ChangeDateFormat(Detail,  
                                                              'dd/MMM/yyyy hh:mm AM/PM'))  
                                                              ELSE CONVERT(NVARCHAR(50), ISNULL(Detail,  
                                                              ''))  
                                                              END AS Detail ,  
                                                              Position  
                                                              FROM  
                                                              dbo.ContactDetails  
                                                              AS Cd  
                                                              INNER JOIN dbo.ContactQuestions  
                                                              AS Cq ON Cd.ContactQuestionId = Cq.Id  
                                                              WHERE  
                                                              ContactMasterId = @FilterValue  
                                                              AND Cd.IsDeleted = 0  
                                                              AND Cq.IsDeleted = 0  
                                                             -- AND IsDisplayInSummary = 1
                                                              -- AND (cd.QuestionTypeId = 4 OR cd.QuestionTypeId = 11 OR cd.QuestionTypeId = 10 OR cd.QuestionTypeId = 8)   
																AND Detail <> ''  
                                                              ) AS R  
                                                              ORDER BY R.Position;            
                                                              END;  
															  ELSE  /* Disha - 13-OCT-2016 -- Added for showing Contact Details in Contact Group Info Popup in Capture Form */
                                                              IF ( @Table = 'ContactDetails' )  
                                                              BEGIN  
                                                              SELECT  
                                                              @listStr = COALESCE(@listStr  
                                                              + ', ', '')  
                                                              + CONVERT(NVARCHAR(50), ISNULL(Detail,  
                                                              ''))  
                                                              FROM  
                                                              ( SELECT  
                                                              CASE Cd.QuestionTypeId  
                                                              WHEN 8  
                                                              THEN CONVERT(NVARCHAR(50), dbo.ChangeDateFormat(Detail,  
                                                              'dd/MMM/yyyy'))  
                                                              WHEN 9  
                                                              THEN CONVERT(NVARCHAR(50), dbo.ChangeDateFormat(Detail,  
                                                              'hh:mm AM/PM'))  
                                                              WHEN 22  
                                                              THEN CONVERT(NVARCHAR(50), dbo.ChangeDateFormat(Detail,  
                                                              'dd/MMM/yyyy hh:mm AM/PM'))  
                                                              ELSE CONVERT(NVARCHAR(50), ISNULL(Detail,  
                                                              ''))  
                                                              END AS Detail ,  
                                                              Position  
                                                              FROM  
                                                              dbo.ContactDetails  
                                                              AS Cd  
                                                              INNER JOIN dbo.ContactQuestions  
                                                              AS Cq ON Cd.ContactQuestionId = Cq.Id  
                                                              WHERE  
                                                              ContactMasterId = @FilterValue  
                                                              AND Cd.IsDeleted = 0  
                                                              AND Cq.IsDeleted = 0  
                                                              AND Cq.IsDisplayInDetail = 1
																AND Detail <> ''  
                                                              ) AS R  
                                                              ORDER BY R.Position;            
                                                              END;  
                 ----Diplicate Contact  
                                              ELSE  
                                                              IF ( @Table = 'DuplicateContact' )  
                                                              BEGIN  
                                                              SELECT  
                                                              @listStr = COALESCE(@listStr  
                                                              + ' ', '')  
                                                              + CONVERT(NVARCHAR(50), ISNULL(Detail,  
                                                              ''))  
                                                              FROM  
                                                              ( SELECT TOP 1  
                                                              ISNULL(Detail,  
                                                              '') AS Detail ,  
                                                              Position  
                                                              FROM  
                                                              dbo.ContactDetails  
                                                              AS Cd  
                                                              INNER JOIN dbo.ContactQuestions  
                                                              AS Cq ON Cd.ContactQuestionId = Cq.Id  
                                                              WHERE  
                                                              ContactMasterId = @FilterValue  
                                                              AND Cd.IsDeleted = 0  
                                                              AND Cq.IsDeleted = 0  
                                                              AND Cq.QuestionTypeId = 4  
                                                              AND Detail <> ''  
                                                              ) AS R  
                                                              ORDER BY R.Position;            
                                                              END;  
        RETURN  ISNULL((CASE WHEN LEN(@listStr) > 25000
                                             THEN LEFT(@listStr, 25000) + '...'
                                             ELSE @listStr END),'');  
    END;

