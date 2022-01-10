--=============================================
--Author		:		VASUDEV
--Create date	:	29-JUNE-2017
--Description	:	Mobile Api Search Feedback List Page.
--Call SP		:	dbo.AdvanceSearchFormData '0', '0', 1753, 50, 1, '', '11/1/2017 00:00:00', '03/13/2018 00:00:00', '','', 1776,0,'Unresolved','','False','False','','','False','','','','','',''
/*
EXEC dbo.AdvanceSearchFormDataOffline @EstablishmentId = '0', -- varchar(max)
    @UserId = '0', -- varchar(max)
    @ActivityId = 1941, -- bigint
    @FromDate = '2015-05-25 06:18:39', -- datetime
    @ToDate = '2018-05-21 06:18:39', -- datetime
    @AppuserId = 1243, -- int
    @FormStatus = 'Unresolved', -- varchar(10)
    @IsResponse = 'true', -- varchar(5)
    @ResponseType = 'All' -- varchar(15)
	*/

--=============================================
CREATE PROCEDURE dbo.AdvanceSearchFormDataOffline
    @EstablishmentId VARCHAR(MAX) ,
    @UserId VARCHAR(MAX) ,
    @ActivityId BIGINT ,
    @FromDate DATETIME ,
    @ToDate DATETIME ,
    @AppuserId INT ,
    @FormStatus VARCHAR(10) ,		/* Resolved, Unresolved AnswerStatus */
    @IsResponse VARCHAR(5) = 'true'
	,@ResponseType VARCHAR(15) = 'All'
AS
    BEGIN
        SET NOCOUNT ON;
		
		DECLARE @Url VARCHAR(100)
		DECLARE @GroupType INT
		SELECT  @url = KeyValue FROM  dbo.AAAAConfigSettings WHERE KeyName = 'FeedbackUrl'
		SELECT @GroupType = ISNULL(Id,0) FROM dbo.AppUser WHERE GroupId IN (SELECT data FROM dbo.Split((SELECT KeyValue FROM dbo.AAAAConfigSettings WHERE KeyName = 'ExcludeGroupId'),',')) AND id = @AppuserId
		
	
        IF ( @EstablishmentId = '0' )
            BEGIN
			SET @EstablishmentId = (SELECT dbo.AllEstablishmentByAppUserAndActivity(@AppuserId,@ActivityId))
            END;
        IF @UserId IS NULL
            BEGIN
                SET @UserId = '0';
            END;

        DECLARE @ActivityType NVARCHAR(50);
        SELECT  @ActivityType = EstablishmentGroupType FROM    dbo.EstablishmentGroup WHERE   Id = @ActivityId;
        IF ( @UserId = '0' AND @ActivityType != 'Customer' )
            BEGIN
			SET @UserId = (SELECT dbo.AllUserSelected(@AppuserId,@EstablishmentId,@ActivityId))
            END;
		
		
        
        DECLARE @Establishment TABLE
            (
              EstablishemtnId BIGINT
            );
        
        INSERT  INTO @Establishment
                ( EstablishemtnId
                )
                SELECT  Data
                FROM    dbo.Split(@EstablishmentId, ',')
                WHERE   Data <> '';

        DECLARE @AppUser TABLE ( AppUserId BIGINT );
        
        INSERT  INTO @AppUser
                ( AppUserId
                )
                SELECT  Data
                FROM    dbo.Split(@UserId, ',')
                WHERE   Data <> '';

        DECLARE @Result TABLE
            (
            ReportId NVARCHAR(15) NOT NULL ,
			EstablishmentId BIGINT NOT NULL ,
			EstablishmentName NVARCHAR(500) NOT NULL ,
			AppUserId BIGINT NOT NULL ,
			UserName NVARCHAR(100) ,
			SenderCellNo NVARCHAR(50) ,
			IsOutStanding BIT NOT NULL ,
			AnswerStatus NVARCHAR(50) NOT NULL ,
			TimeOffSet INT ,
			CreatedOn DATETIME ,
			UpdatedOn NVARCHAR(50),
			[PI] DECIMAL(18, 0) NOT NULL ,
			SmileType NVARCHAR(20) NOT NULL ,
			QuestionnaireType NVARCHAR(10) NOT NULL ,
			FormType NVARCHAR(10) NOT NULL ,
			IsOut BIT ,
			QuestionnaireId BIGINT NOT NULL ,
			ReadBy BIGINT NOT NULL ,
			ContactMasterId BIGINT NULL ,
			Latitude NVARCHAR(50) ,
			Longitude NVARCHAR(50) ,
			IsTransferred BIT NOT NULL ,
			TransferToUser NVARCHAR(100) NOT NULL ,
			TransferFromUser NVARCHAR(100) NOT NULL ,
			SeenClientAnswerMasterId BIGINT NOT NULL ,
			ActivityId BIGINT NOT NULL ,
			IsActioned BIT NOT NULL ,
			TransferByUserId BIGINT NOT NULL ,
			TransferFromUserId BIGINT NOT NULL ,
			DisplayText NVARCHAR(MAX) ,
			ContactDetails NVARCHAR(MAX) ,
			CaptureDate NVARCHAR(50) ,
			IsDisable BIT NULL ,
			ContactGropName nvarchar(100) NULL ,
			IsResend BIT ,
			UnreadAction INT ,
			IsRecursion BIT ,
			PositiveCount Int,
			NegativeCount Int,
			PassiveCount Int,
			UnresolvedCount INT ,
			ResolvedCount INT ,
			ActionedCount INT ,
			UnActionedCount INT ,
			TransferredCount INT ,
			OutstandingCount INT ,
			AlertUnreadCountCount INT,
			Id BIGINT,
			MobiLink VARCHAR(50),
			GroupType VARCHAR(10),
			TotalRecord INT ,
			RowNum BIGINT, 
			TotalPage INT NOT NULL,
			ActionDate DATETIME,
			ActionDateEveryone DATETIME,
			ActionTo BIGINT,
			FeedbackSubmitted INT );

        DECLARE @SqlSelect1 NVARCHAR(MAX),
		@SqlSelect11 NVARCHAR(MAX),
		@SqlSelect12 NVARCHAR(MAX) = ' ',
        @SqlSelect2 NVARCHAR(MAX) = ' ',
		@Filter NVARCHAR(MAX)= ' ',
		@SqlselectCount VARCHAR(MAX) = '';
	
      
     
        
     

        SET @SqlSelect1 = N'
		SELECT ReportId as ReportId,
        EstablishmentId ,EstablishmentName ,UserId ,UserName ,SenderCellNo ,IsOutStanding ,AnswerStatus ,
        TimeOffSet ,CreatedOn , dbo.ChangeDateFormat(UpdatedOn,''dd/MMM/yyyy hh:mm AM/PM'') AS UpdatedOn, 
		[PI] as [PI],
		SmileType ,QuestionnaireType ,FormType ,IsOut ,QuestionnaireId ,ReadBy ,CASE ContactMasterId WHEN 0 THEN ContactGroupId ELSE R.ContactMasterId end AS ContactMasterId,
		Latitude ,Longitude ,IsTransferred ,TransferToUser ,TransferFromUser ,SeenClientAnswerMasterId ,ActivityId ,IsActioned ,
		TransferByUserId ,TransferFromUserId ,dbo.AnswerDetails(CASE IsOut WHEN 0 THEN ''Answers'' ELSE ''SeenClientAnswers'' END, ReportId) AS DisplayText , dbo.ConcateString(''ContactSummary'', ContactMasterId) AS ContactDetails ,
                        dbo.ChangeDateFormat(CreatedOn, ''dd/MMM/yyyy hh:mm AM/PM'') AS CaptureDate ,
                        isnull(isdisabled,''false'') as Isdisabled, ISNULL( (SELECT ContactGropName FROM dbo.ContactGroup WHERE id IN( SELECT ContactGroupId FROM dbo.SeenClientAnswerMaster 
						WHERE id = ReportId AND R.IsOut=1)),'''') as ContactGropName, (SELECT CASE R.Isout WHEN 1 THEN ISNULL((SELECT CASE WHEN COUNT(1) = 0 THEN 1 ELSE 0 end FROM dbo.AnswerMaster WHERE   SeenClientAnswerMasterId = R.ReportId),1) ELSE 0 end) AS Resend,
						UnreadAction, R.IsRecursion,Sum(CASE WHEN SmileType = ''Positive'' THEN 1 ELSE 0 END) OVER() AS PositiveCount ,Sum(CASE WHEN SmileType = ''Negative'' THEN 1 ELSE 0 END)  OVER() AS NegativeCount ,Sum(CASE WHEN SmileType = ''Neutral'' THEN 1 ELSE 0 END)  OVER() AS PassiveCount ,
				IIF('''+  ISNULL(@ActivityType,'') +''' != ''Customer'', SUM(CASE WHEN (AnswerStatus = ''Unresolved'' AND R.IsOut = 1) THEN 1 ELSE 0 END)  OVER(),SUM(CASE WHEN AnswerStatus = ''Unresolved'' THEN 1 ELSE 0 END)  OVER()) AS UnresolvedCount,
				Sum(CASE WHEN AnswerStatus = ''Resolved'' THEN 1 ELSE 0 END)  OVER() AS ResolvedCount,Sum(CASE WHEN IsActioned = 1 THEN 1 ELSE 0 END)  OVER() AS ActionedCount ,Sum(CASE WHEN IsActioned = 0 THEN  1 ELSE 0 END)  OVER() AS UnActionedCount ,
				Sum(CASE WHEN IsTransferred = 1 THEN 1 ELSE 0 END)  OVER() AS TransferredCount ,Sum(CASE WHEN IsOutStanding = 1 THEN 1 ELSE 0 END)  OVER() AS OutstandingCount ,UnreadAction AS AlertUnreadCountCount ,
				case isnull(SeenClientAnswerMasterId,0) when 0 then ReportId else SeenClientAnswerMasterId end as Id, R.MobiLink, R.GroupType, R.TotalRecord, ROW_NUMBER() OVER ( ORDER BY R.CreatedOn DESC ) as RowNum, R.TotalPage,
				R.ActionDate,
				R.ActionDateEveryone,
				R.ActionTo,				R.FeedbackSubmitted'
SET @SqlSelect11 =  CHAR(13) + N'FROM    ( SELECT    A.* ,
									0 AS UnreadAction,
                                   ( SELECT CASE A.IsOut WHEN 1 THEN ISNULL(( SELECT CASE WHEN IsRecursion = 0 THEN 0 ELSE 1 END FROM dbo.SeenClientAnswerMaster WHERE   Id = A.ReportId ), 0) ELSE 0 END ) AS IsRecursion,
									(SELECT COUNT(Id) FROM dbo.AnswerMaster WHERE SeenClientAnswerMasterId = ReportId AND IsDeleted = 0) AS MobiLink,
									'''+  CONVERT(VARCHAR(10), ISNULL(@GroupType,'')) +''' AS GroupType ,
									 (SUM(CASE WHEN (A.IsOut = 1) THEN 1 ELSE 0 END)  OVER()) AS TotalRecord,
									0 AS RowNum,
									(CASE COUNT(1) OVER ( PARTITION BY 1 ) / 50 WHEN 0 THEN 1 ELSE ( COUNT(1) OVER ( PARTITION BY 1 ) / 50 ) + 1 END) AS TotalPage,
									'''' AS ActionDate,
									'''' AS ActionDateEveryone,
									(dbo.GetMObilink(A.ReportId,
                                                              '+ CONVERT(VARCHAR(10),@AppuserId) +',
                                                              CASE
                                                              WHEN A.ContactGroupId != 0
                                                              THEN 1
                                                              ELSE 0
                                                              END)) AS mobilink1,
									''' + CONVERT(VARCHAR(10), @AppuserId) + ''' AS ActionTo ,
									0 as FeedbackSubmitted ' +CHAR(13) + '
									FROM      dbo.View_AllAnswerMaster AS A ';
	SET @SqlSelect12 +=CHAR(13) + ' INNER JOIN (SELECT * FROM dbo.Split('''+ @EstablishmentId+ ''', '','')) AS E ON A.EstablishmentId = E.Data OR '''+ @EstablishmentId + ''' = ''0''
                                    INNER JOIN (SELECT * FROM dbo.Split('''+ @UserId + ''', '','')) AS U ON (U.Data = A.UserId OR U.Data = ISNULL(A.TransferFromUserId, 0) OR '''+ @UserId + ''' = ''0'' OR A.UserId = 0 ) ';
		

		IF ( @FormStatus = 'Resolved' )
            BEGIN
                SET @Filter += ' AND A.AnswerStatus = ''' + @FormStatus + '''';
            END;
        ELSE
            IF ( @FormStatus = 'Unresolved' )
                BEGIN
                    SET @Filter += ' AND A.AnswerStatus = ''' + @FormStatus + '''';
                END;
			
			DECLARE @Temp TABLE (
				[SeenClientAnswerMasterId] [BIGINT] NOT NULL
				)

				INSERT INTO @Temp
				        ( SeenClientAnswerMasterId )
				EXEC ('select A.SeenClientAnswerMasterId FROM  dbo.View_AllAnswerMaster AS A ' + @SqlSelect12 + @SqlSelect2 + @Filter + ' Group By A.SeenClientAnswerMasterId');
				
				DECLARE @var VARCHAR(MAX)
SET @var  = 
(SELECT distinct
  STUFF((SELECT distinct ',' + CONVERT(VARCHAR(max),p1.[SeenClientAnswerMasterId])
         FROM @Temp p1
         
            FOR XML PATH('')), 1, 1, '' ) SeenClientAnswerMasterId
FROM @Temp p)
 IF (@ResponseType = 'Responded')
		 BEGIN
			SET @Filter += ' AND  IIF(ISNULL(A.SeenClientAnswerMasterId, 0) = 0, A.ReportId, A.SeenClientAnswerMasterId) in ('+@var+') ';
		 END
		 ELSE IF (@ResponseType = 'NotResponded')
         BEGIN
		 	SET @Filter += ' AND  IIF(ISNULL(A.SeenClientAnswerMasterId, 0) = 0, A.ReportId, A.SeenClientAnswerMasterId) not in ('+@var+') ';
		 END
		 IF (@IsResponse = 'true')
		BEGIN
		SET @Filter += ' ) As R where R.Mobilink1 != '''' AND R.FeedbackSubmitted = 0  '
				--SET @Filter += ' AND dbo.GetMObilink(A.ReportId, ' + CONVERT(VARCHAR(10),@AppuserId) + ' , CASE WHEN A.ContactGroupId != 0 THEN 1 ELSE 0 END) != '''') as R where R.RowNum between 1 and 50';
		END
		ELSE
         BEGIN
				SET @Filter += ' )  as R ';
		 END

       --SELECT ( @SqlSelect1 + @SqlSelect11 + @SqlSelect12 + @SqlSelect2 + @Filter);
        INSERT  INTO @Result
        EXEC ( @SqlSelect1 + @SqlSelect11 + @SqlSelect12 + @SqlSelect2 + @Filter);

					SELECT * FROM (
						SELECT ISNULL(ReportId ,0) AS ReportId,
					          isnull(EstablishmentId ,0) AS EstablishmentId,
					          isnull(EstablishmentName ,0) AS EstablishmentName ,
					          isnull(AppUserId ,0) AS AppUserId, 
					          isnull(UserName ,'') AS UserName ,
					          isnull(SenderCellNo ,0) AS SenderCellNo ,
					          isnull(IsOutStanding ,0) AS IsOutStanding,
					          isnull(AnswerStatus ,0) AS AnswerStatus,
					          isnull(TimeOffSet ,0) AS TimeOffSet,
					          isnull(CreatedOn ,0) AS CreatedOn ,
							  isnull(UpdatedOn,0) AS UpdatedOn,
					          isnull([PI] ,0) AS [PI],
					          isnull(SmileType ,0) AS SmileType , 
					          isnull(QuestionnaireType ,0) AS QuestionnaireType , 
					          isnull(FormType ,0) AS FormType , 
					          isnull(IsOut ,0) AS IsOut , 
					          isnull(QuestionnaireId ,0) AS QuestionnaireId ,
					          isnull(ReadBy ,0) AS ReadBy ,
					          isnull(ContactMasterId ,0) AS ContactMasterId ,
					          isnull(Latitude ,0) AS Latitude ,
					          isnull(Longitude ,0) AS Longitude ,
					          isnull(IsTransferred ,0) AS IsTransferred ,
					          isnull(TransferToUser ,0) AS TransferToUser, 
					          isnull(TransferFromUser ,0) AS TransferFromUser ,
					          isnull(SeenClientAnswerMasterId ,0) AS SeenClientAnswerMasterId ,
					          isnull(ActivityId ,0) AS ActivityId ,
					          isnull(IsActioned ,0) AS IsActioned ,
					          isnull(TransferByUserId ,0) AS TransferByUserId ,
					          isnull(TransferFromUserId ,0) AS TransferFromUserId ,
					          isnull(DisplayText ,0) AS DisplayText ,
					          isnull(ContactDetails ,0) AS ContactDetails ,
					          isnull(CaptureDate ,0) AS CaptureDate ,
							  isnull(IsDisable ,0) AS IsDisable ,
					          isnull(ContactGropName ,0) AS ContactGropName ,
					          isnull(IsResend ,0) AS IsResend ,
					          isnull(UnreadAction ,0) AS UnreadAction ,
					          isnull(IsRecursion ,0) AS IsRecursion ,
					          isnull(PositiveCount ,0) AS PositiveCount ,
					          isnull(NegativeCount ,0) AS NegativeCount , 
					          isnull(PassiveCount ,0) AS PassiveCount , 
					          isnull(UnresolvedCount ,0) AS UnresolvedCount , 
					          isnull(ResolvedCount ,0) AS ResolvedCount , 
					          isnull(ActionedCount ,0) AS ActionedCount , 
					          isnull(UnActionedCount ,0) AS UnActionedCount , 
					          isnull(TransferredCount ,0) AS TransferredCount , 
					          isnull(OutstandingCount ,0) AS OutstandingCount, 
					          isnull(AlertUnreadCountCount,0) AS AlertUnreadCountCount, 
							  isnull(MobiLink,0) AS MobiLink, 
							  isnull(GroupType,0) AS GroupType, 
							  isnull(Id,0) AS Id, 
							  isnull(TotalRecord ,0)  AS TotalRecord , 
							  isnull(RowNum,0) AS RowNum, 
							  isnull(TotalPage,0) AS TotalPage, 
							  isnull(ActionDate,0) AS ActionDate, 
							  isnull(ActionDateEveryone,0) AS ActionDateEveryone, 
							  isnull(ActionTo,0) AS ActionTo, 
							  isnull(FeedbackSubmitted,0) AS FeedbackSubmitted
							   FROM @Result ) AS SS
			
        SET NOCOUNT OFF;
END;
