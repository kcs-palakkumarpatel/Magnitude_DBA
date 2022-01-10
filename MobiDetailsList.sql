--=============================================
--Author		:		D3
--Create date	:	07-FEB-2018
--Description	:	Mobile Api Search Feedback List Page.
--Note. :				If Make Chnages then apply this Mobile AP 'dbo.AdvanceSearchFormData' also.
-- Exec MobiDetailsList '0','0',1548,2475,'01 jan 2015','30 May 2018',50,1,''
--=============================================
CREATE PROCEDURE [dbo].[MobiDetailsList]
	@EstablishmentId VARCHAR(max),
	@UserId VARCHAR(max),
    @AppuserId INT ,
    @ActivityId BIGINT ,
	@FromDate DATETIME ,
    @ToDate DATETIME ,
    @Rows INT ,
    @Page INT ,
    @Search VARCHAR(1000) 
AS
    BEGIN
        SET NOCOUNT ON;

        IF ( @Rows = 0 )
            BEGIN
                SET @Rows = 50;
            END;
	
        DECLARE @ActivityType NVARCHAR(50);
        SELECT  @ActivityType = EstablishmentGroupType
        FROM    dbo.EstablishmentGroup
        WHERE   Id = @ActivityId;

		DECLARE @Filter VARCHAR(MAX);
		DECLARE @SqlString VARCHAR(MAX);

		IF ( @EstablishmentId = '0' )
            BEGIN
                SET @EstablishmentId = ( SELECT dbo.AllEstablishmentByAppUserAndActivity(@AppuserId, @ActivityId) );
            END;
			PRINT @EstablishmentId
		IF @UserId IS NULL
            BEGIN
                SET @UserId = '0';
            END;

		IF ( @UserId = '0' AND @ActivityType != 'Customer' )
            BEGIN
                SET @UserId = ( SELECT  dbo.AllUserSelected(@AppuserId, @EstablishmentId, @ActivityId) );
            END;

			DECLARE @Result AS TABLE
			(
				ReportId BIGINT,
				EstablishmentName VARCHAR(100),
				EstablishmentId BIGINT,
				[PI]  DECIMAL(18,2),
				ActivityId BIGINT,
				DisplayText VARCHAR(MAX),
				CaptureDate VARCHAR(20),
				ContactData VARCHAR(50),
				IsFeedback VARCHAR(100),
				FeedbackSubmitted INT
			)

			SELECT @SqlString = N'select * from (SELECT
				A.ReportId ,
				A.EstablishmentName ,
				a.EstablishmentId,
				A.[PI] ,
				A.ActivityId ,
				dbo.SummaryQuestionsList(CASE A.IsOut WHEN 0 THEN ''Answers'' ELSE ''SeenClientAnswers'' END, A.ReportId) AS DisplayText ,
				dbo.ChangeDateFormat(A.CreatedOn, ''dd/MMM/yyyy hh:mm AM/PM'') AS CaptureDate,
				CASE WHEN A.IsOut = 1 THEN A.UserName + '' To '' + IIF(A.ContactMasterId = 0, ( SELECT ContactGropName FROM   dbo.ContactGroup WHERE  Id = A.ContactGroupId), ( SELECT TOP 1  Cd.Detail FROM  dbo.ContactDetails AS Cd WHERE Cd.QuestionTypeId = 4 AND ContactMasterId = A.ContactMasterId AND Cd.IsDeleted = 0 AND Cd.Detail <> '''' ))
				ELSE  (SELECT TOP 1  Cd.Detail FROM  dbo.ContactDetails AS Cd WHERE Cd.QuestionTypeId = 4 AND ContactMasterId = A.ContactMasterId AND Cd.IsDeleted = 0 AND Cd.Detail <> '''' ) + '' To '' + A.UserName 
				END AS ContactData,
				dbo.GetMObilink(A.ReportId, CONVERT(VARCHAR(10), '''+CONVERT (VARCHAR(10), @AppuserId)+'''), CASE WHEN A.ContactGroupId != 0 THEN 1 ELSE 0 END) AS IsFeedback,
				CASE WHEN A.ContactGroupId != 0 THEN IIF((SELECT IsFeedBackSubmitted FROM dbo.FeedbackOnceHistory WHERE SeenclientChildId = (SELECT Id FROM dbo.SeenClientAnswerChild WHERE ContactMasterId = A.ContactMasterId AND
				SeenClientAnswerMasterId = A.ReportId) AND SeenClientAnswerMasterId = A.ReportId) = 1,1,0) ELSE IIF((SELECT TOP 1 IsFeedBackSubmitted FROM dbo.FeedbackOnceHistory WHERE SeenClientAnswerMasterId = A.ReportId ORDER BY id DESC) = 1,1,0) end as FeedbackSubmitted
				FROM    dbo.View_AllAnswerMaster AS A 
				INNER JOIN (SELECT * FROM dbo.Split(''' + @UserId + ''', '','')) AS U ON (U.Data = CONVERT(VARCHAR(50),A.UserId)
				OR U.Data = ISNULL(CONVERT(VARCHAR(50),A.TransferFromUserId), 0) OR ''' + @UserId + ''' = ''0'' OR A.UserId = 0)
				AND A.EstablishmentId IN (SELECT data FROM dbo.Split(''' + @EstablishmentId + ''','','')) AND A.IsOut = 1) as T'
				
				SELECT @Filter = N' WHERE T.IsFeedback != '''''
				IF(@Search != '')
				BEGIN
				SELECT @Filter += N' And (T.Reportid like ''%'+ @Search +'%'' or T.EstablishmentName like ''%'+ @Search +'%'' or T.DisplayText like ''%' + @search + '%'')'
				END
                
				SELECT @Filter += ' ORDER BY CONVERT(DateTime, T.CaptureDate,101) DESC'

				PRINT (@SqlString + @Filter)
				
INSERT INTO
@Result
        ( ReportId ,
          EstablishmentName ,
          EstablishmentId ,
          PI ,
          ActivityId ,
          DisplayText ,
          CaptureDate ,
          ContactData ,
          IsFeedback,
		  FeedbackSubmitted
        )
	EXEC (@SqlString + @Filter)
		SELECT DISTINCT ReportId ,
          EstablishmentName ,
          EstablishmentId ,
          PI ,
          ActivityId ,
          DisplayText ,
		  CaptureDate,
		  CONVERT(DateTime, CaptureDate,101) AS CaptureDate1,
          ContactData ,
          CASE WHEN (SELECT COUNT(data) FROM dbo.Split(IsFeedback,'|')) > 1 THEN RTRIM(SUBSTRING(IsFeedback, 1,Charindex('|', IsFeedback)-1)) ELSE '' END AS SeenclientChildId,
		  FeedbackSubmitted
		   FROM @Result WHERE IsFeedback != '' ORDER BY CONVERT(DateTime, CaptureDate,101) DESC
			OFFSET ((@Page - 1 ) * @Rows) ROWS FETCH NEXT @Rows ROWS ONLY;

    SET NOCOUNT OFF;
    END;
