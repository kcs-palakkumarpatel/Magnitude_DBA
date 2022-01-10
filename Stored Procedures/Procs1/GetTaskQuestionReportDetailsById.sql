-- =============================================  
-- Author:      
-- Create date: 25-Sep-2017  
-- Description: Get In/Out Form Data Details in Action List Page.  
-- Call SP:    GetTaskQuestionReportDetailsById 976781, 1  
-- =============================================  
CREATE PROCEDURE [dbo].[GetTaskQuestionReportDetailsById]
    @ReportId BIGINT,
    @IsOut BIT
AS
BEGIN

    DECLARE @Url NVARCHAR(100),
            @GraphicImagePath NVARCHAR(100);
    SELECT @GraphicImagePath = KeyValue
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'DocViewerRootFolderPathCMS';


    DECLARE @TempTable TABLE
    (
        QuestionTitle NVARCHAR(MAX),
        Detail NVARCHAR(MAX),
        Url NVARCHAR(MAX),
        ThumbnilUrl NVARCHAR(MAX),
        QuestionId BIGINT,
        QuestionTypeId INT, 
		IsRequired BIT,
		Position INT
    );

    SELECT @Url = KeyValue
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'DocViewerRootFolderPathWebApp';

    INSERT INTO @TempTable
    (
        QuestionTitle,
        Detail,
        Url,
        ThumbnilUrl,
        QuestionId,
        QuestionTypeId,
		IsRequired,
		Position
    )
    SELECT Q.QuestionTitle,
           CASE Q.QuestionTypeId
               WHEN 8 THEN
                   dbo.ChangeDateFormat(Detail, 'dd/MMM/yyyy')
               WHEN 9 THEN
                   dbo.ChangeDateFormat(Detail, 'hh:mm')
               WHEN 22 THEN
                   dbo.ChangeDateFormat(Detail, 'dd/MMM/yyyy hh:mm')
               WHEN 1 THEN
                   dbo.GetOptionNameByQuestionId(A.QuestionId, A.Detail, @IsOut)
               WHEN 23 THEN
                   Q.ImagePath
               ELSE
                   ISNULL(Detail, '')
           END AS Detail,
           CASE Q.QuestionTypeId
               WHEN 23 THEN
                   @GraphicImagePath + 'Questions/'
               ELSE
                   @Url + 'SeenClient/'
           END AS Url,
           CASE Q.QuestionTypeId
               WHEN 23 THEN
                   @GraphicImagePath + 'Questions/'
               ELSE
                   @Url + 'SeenClient/'
           END AS ThumbnilUrl,
           Q.Id AS QuestionId,
           Q.QuestionTypeId AS QuestionTypeId,
           Q.Required AS IsRequired,
		   Q.Position
    FROM dbo.SeenClientAnswerMaster AS Am
        INNER JOIN dbo.SeenClient AS Qr
            ON Am.SeenClientId = Qr.Id
        INNER JOIN dbo.SeenClientQuestions AS Q
            ON Qr.Id = Q.SeenClientId
        LEFT OUTER JOIN dbo.SeenClientAnswers AS A
            ON Am.Id = A.SeenClientAnswerMasterId
               AND Q.Id = A.QuestionId
    WHERE Am.Id = @ReportId
          AND Q.IsDisplayInDetail = 1
          AND Q.QuestionTypeId NOT IN ( 25 )
    ORDER BY Position;
END;
SELECT ISNULL(QuestionId, 0) AS QuestionId,
       ISNULL(QuestionTitle, '') AS QuestionTitle,
       ISNULL(Detail, '') AS Detail,
       ISNULL(Url, '') AS Url,
       ISNULL(ThumbnilUrl, '') AS ThumbnilUrl,
       ISNULL(QuestionTypeId, 0) AS QuestionTypeId,
       ISNULL(IsRequired, 0) AS IsRequired,
	   Position AS Position
FROM @TempTable ORDER BY Position ASC;
