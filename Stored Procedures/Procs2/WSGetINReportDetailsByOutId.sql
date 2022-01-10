-- =============================================
-- Author:			Vasu Patel
-- Create date:	14-Jun-2017
-- Description:	Get In/Out Form Data Details in Action List Page.
-- Call SP:			WSGetINReportDetailsByOutId 105088
-- =============================================
CREATE PROCEDURE dbo.WSGetINReportDetailsByOutId
    @ReportId BIGINT 
AS
    BEGIN

DECLARE  @IsOut BIT
		SET @IsOut = 0
        DECLARE @Url NVARCHAR(100) ,
            @GraphicImagePath NVARCHAR(100);

        SELECT  @GraphicImagePath = KeyValue
        FROM    dbo.AAAAConfigSettings
        WHERE   KeyName = 'DocViewerRootFolderPathCMS';


		--SELECT  @GraphicImagePath = KeyValue + 'UploadFiles/'
  --      FROM    dbo.AAAAConfigSettings
  --      WHERE   KeyName = 'DocViewerRootFolderPath';

        DECLARE @TempTable TABLE
            (
              Id BIGINT ,
			  ReportId BIGINT,
              QuestionTitle NVARCHAR(MAX) ,
              ShortName NVARCHAR(MAX) ,
              QuestionTypeId BIGINT ,
              RepetitiveGroupCount INT ,
              RepetitiveGroupNo INT ,
              RepetitiveGroupName VARCHAR(100) ,
              Detail NVARCHAR(MAX) ,
              Url NVARCHAR(MAX) ,
              QuestionId BIGINT ,
              CaptureDate NVARCHAR(80) ,
              IsDeleted BIT
            );

       BEGIN
                SELECT  @Url = KeyValue 
                FROM    dbo.AAAAConfigSettings
                WHERE   KeyName = 'DocViewerRootFolderPathWebApp';

                INSERT  INTO @TempTable
                        ( Id ,
						  ReportId,
                          QuestionTitle ,
                          ShortName ,
                          QuestionTypeId ,
                          RepetitiveGroupCount ,
                          RepetitiveGroupNo ,
                          RepetitiveGroupName ,
                          Detail ,
                          Url ,
                          QuestionId ,
                          CaptureDate ,
                          IsDeleted
				        )
                        SELECT  Q.Id ,
								Am.Id,
                                Q.QuestionTitle ,
                                Q.ShortName ,
                                Q.QuestionTypeId ,
                                ISNULL(A.RepeatCount, 0) ,
                                ISNULL(A.RepetitiveGroupId, 0) ,
                                ISNULL(A.RepetitiveGroupName, '') ,
                                CASE Q.QuestionTypeId
                                  WHEN 8
                                  THEN dbo.ChangeDateFormat(Detail,
                                                            'dd/MMM/yyyy')
                                  WHEN 9
                                  THEN dbo.ChangeDateFormat(Detail,
                                                            'hh:mm AM/PM')
                                  WHEN 22
                                  THEN dbo.ChangeDateFormat(Detail,
                                                            'dd/MMM/yyyy hh:mm AM/PM')
                                  WHEN 1
                                  THEN dbo.GetOptionNameByQuestionId(A.QuestionId,
                                                              A.Detail, @IsOut)
                                  WHEN 23 THEN Q.ImagePath
                                  ELSE ISNULL(Detail, '')
                                END AS Detail ,
                                CASE Q.QuestionTypeId
                                  WHEN 23
                                  THEN @GraphicImagePath + 'Questions/'
                                  ELSE @Url + 'Feedback/'
                                END AS Url ,
                                Q.Id AS QuestionId ,
                                dbo.ChangeDateFormat(DATEADD(MINUTE,
                                                             Am.TimeOffSet,
                                                             Am.CreatedOn),
                                                     'dd/MMM/yyyy HH:mm AM/PM') AS CaptureDate ,
                                Am.IsDisabled
                        FROM    dbo.AnswerMaster AS Am
                                INNER JOIN dbo.Questionnaire AS Qr ON Am.QuestionnaireId = Qr.Id
                                INNER JOIN dbo.Questions AS Q ON Qr.Id = Q.QuestionnaireId
                                LEFT OUTER JOIN dbo.Answers AS A ON Am.Id = A.AnswerMasterId
                                                              AND Q.Id = A.QuestionId
                        WHERE   Am.SeenClientAnswerMasterId = @ReportId
                                AND Q.IsDisplayInDetail = 1
								AND Q.QuestionTypeId NOT IN (25)
                                AND ( A.Id IS NOT NULL
                                      OR ( Q.QuestionTypeId IN ( 16, 23 )
                                           AND Q.IsDeleted = 0
                                         )
                                    )
                        ORDER BY Position;

------------------------------------------------------------------------------------------------------------------
                DECLARE @shortName NVARCHAR(MAX);
                DECLARE @Possition BIGINT;
                DECLARE @Questionnierid BIGINT;
                DECLARE @QuestionId BIGINT;
                DECLARE @QuestionTitle NVARCHAR(MAX);
                DECLARE @Start BIGINT = 1 ,
                    @End BIGINT; 

                SELECT  TOP 1 @Questionnierid = QuestionnaireId
                FROM    dbo.AnswerMaster
                WHERE   SeenClientAnswerMasterId = @ReportId;

                DECLARE @Reftable TABLE
                    (
                      Id BIGINT IDENTITY(1, 1) ,
                      SeenclientQuestionId BIGINT ,
                      QuestionId BIGINT ,
                      possition BIGINT ,
                      shortName NVARCHAR(MAX) ,
                      QuestionTitle NVARCHAR(MAX) ,
                      QuestionTypeId BIGINT
                    );
                INSERT  @Reftable
                        ( SeenclientQuestionId ,
                          QuestionId ,
                          possition ,
                          shortName ,
                          QuestionTitle ,
                          QuestionTypeId
						 )
                        SELECT  SeenClientQuestionIdRef ,
                                Id ,
                                Position ,
                                ShortName ,
                                QuestionTitle ,
                                QuestionTypeId
                        FROM    dbo.Questions
                        WHERE   QuestionnaireId = @Questionnierid
                                AND SeenClientQuestionIdRef IS NOT NULL
                                AND IsDisplayInDetail = 1  --- Add by Sunil For Bug 0000069891
                                AND IsDeleted = 0
                                AND IsActive = 0;
                SET @Start = 1;
                SELECT  @End = COUNT(*)
                FROM    @Reftable;
                WHILE ( @Start <= @End )
                    BEGIN
                        SELECT  @QuestionId = QuestionId ,
                                @shortName = shortName ,
                                @Possition = possition ,
                                @QuestionTitle = QuestionTitle
                        FROM    @Reftable
                        WHERE   Id = @Start;
                        INSERT  INTO @TempTable
                                ( Id ,
								  ReportId,
                                  QuestionTitle ,
                                  ShortName ,
                                  QuestionTypeId ,
                                  RepetitiveGroupCount ,
                                  RepetitiveGroupNo ,
                                  RepetitiveGroupName ,
                                  Detail ,
                                  Url ,
                                  QuestionId ,
                                  CaptureDate ,
                                  IsDeleted
									
                                )
                                SELECT  QuestionId ,
										Id,
                                        @QuestionTitle ,
                                        @shortName ,
                                        QuestionTypeId ,
                                        0 ,
                                        0 ,
                                        '' ,
                                        Detail ,
                                        '' ,
                                        QuestionId ,
                                        dbo.ChangeDateFormat(GETUTCDATE(),
                                                             'dd/MMM/yyyy HH:mm AM/PM') AS CaptureDate ,
                                        0
                                FROM    dbo.SeenClientAnswers
                                WHERE   SeenClientAnswerMasterId IN (
                                        SELECT  SeenClientAnswerMasterId
                                        FROM    dbo.AnswerMaster
                                        WHERE   SeenClientAnswerMasterId = @ReportId )
                                        AND ( ( ISNULL(SeenClientAnswerChildId,
                                                       0) = 0 )
                                              OR SeenClientAnswerChildId IN (
                                              SELECT    SeenClientAnswerChildId
                                              FROM      dbo.AnswerMaster
                                              WHERE     SeenClientAnswerMasterId = @ReportId )
                                            )
                                        AND QuestionId = ( SELECT
                                                              SeenclientQuestionId
                                                           FROM
                                                              @Reftable
                                                           WHERE
                                                              Id = @Start
                                                         );
                        SET @Start = @Start + 1;
                    END;
------------------------------------------------------------------------------------------------------------------------
            END;
       
	   END;
    SELECT  Id ,
			ReportId,
            QuestionTitle ,
            ShortName ,
            QuestionTypeId ,
            RepetitiveGroupCount ,
            RepetitiveGroupNo ,
            RepetitiveGroupName ,
            REPLACE(Detail, ',', ', ') AS Detail ,
            Url ,
            QuestionId ,
            CaptureDate ,
            IsDeleted
    FROM    @TempTable ORDER BY ReportId ;
