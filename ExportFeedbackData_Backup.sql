-- =============================================
-- Author:			Sunil Vaghsiya
-- Create date:	27-09-2017
-- Description:	Excel Export Feedback List
-- Call SP:		dbo.ExportFeedbackData '0', '0', 2359, '01/01/2017', '05/12/2017', 1, '', ''
-- =============================================
CREATE PROCEDURE dbo.ExportFeedbackData_Backup
    (
      @EstablishmentId NVARCHAR(MAX) = NULL ,
      @UserId NVARCHAR(MAX) = NULL ,
      @ActivityId BIGINT = 0 ,
      @AppuserId BIGINT = 0 ,
      @FromDate DATETIME = NULL ,
      @ToDate DATETIME = NULL ,
      @IsOut BIT = 0 ,
      @FilterOn VARCHAR(255) = NULL ,
      @search VARCHAR(255) = NULL 
    )
AS
    BEGIN

        DECLARE @URL NVARCHAR(2000) = '' ,
            @SearchQuery NVARCHAR(MAX) = '' ,
            @SqlSelect1 NVARCHAR(MAX)= '' ,
            @SqlSelect2 NVARCHAR(MAX) = '' ,
            @SqlSelect3 NVARCHAR(MAX)= '' ,
            @cols AS NVARCHAR(MAX) = '' ,
            @Selectcols AS NVARCHAR(MAX) = '';

			SELECT @EstablishmentId [@EstablishmentId] , @UserId [@UserId];

        IF ( @EstablishmentId = '0' OR @EstablishmentId IS NULL )
            BEGIN
                SET @EstablishmentId = ( SELECT dbo.AllEstablishmentByAppUserAndActivity(@AppuserId, @ActivityId) );
            END;
        IF @UserId IS NULL
            BEGIN
                SET @UserId = '0';
            END;

        DECLARE @ActivityType NVARCHAR(50);
        SELECT  @ActivityType = EstablishmentGroupType
        FROM    dbo.EstablishmentGroup
        WHERE   Id = @ActivityId;
        IF ( @UserId = '0'
             AND @ActivityType != 'Customer'
           )
            BEGIN
                SET @UserId = ( SELECT  dbo.AllUserSelected(@AppuserId,
                                                            @EstablishmentId,
                                                            @ActivityId)
                              );
            END;

SELECT @EstablishmentId [@EstablishmentId] , @UserId [@UserId];

        IF @IsOut = 0
            BEGIN 
                SELECT  @URL = KeyValue + 'UploadFiles/FeedBack/'
                FROM    dbo.AAAAConfigSettings
                WHERE   KeyName = 'WebAppUrl'; 
            END; 
        ELSE
            BEGIN 
                SELECT  @URL = KeyValue + 'UploadFiles/SeenClient/'
                FROM    dbo.AAAAConfigSettings
                WHERE   KeyName = 'WebAppUrl'; 
            END; 
        IF @search <> ''
            AND @search IS NOT NULL
            BEGIN
                SET @SearchQuery = '	AND (REPLACE(STR(Am.Id , 10), SPACE(1), ''0'') like ''%'
                    + @search + '%'' 
										OR E.EstablishmentName LIKE ''%'
                    + @search + '%'' 
										OR Am.EI LIKE ''%' + @search + '%'' 
										OR U.UserName LIKE ''%' + @search
                    + '%'' 
										OR Am.SenderCellNo LIKE ''%' + @search
                    + '%''
										OR dbo.ChangeDateFormat(Am.CreatedOn, ''dd/MMM/yyyy hh:mm AM/PM'') LIKE ''%'
                    + @search + '%'' 
										OR ISNULL(ANS.Detail, '''') LIKE ''%'
                    + @search + '%'' 
										OR ISNULL(Q.ShortName, '''') LIKE ''%'
                    + @search + '%'' )' + CHAR(10); 
            END;

        IF ( @FilterOn = 'Neutral' )
            SET @FilterOn = ' AM.IsPositive = ''Neutral'''; 
        ELSE
            IF ( @FilterOn = 'Positive' )
                SET @FilterOn = ' AM.IsPositive = ''Positive'''; 
            ELSE
                IF ( @FilterOn = 'Negative' )
                    SET @FilterOn = ' AM.IsPositive = ''Negative'''; 
                ELSE
                    IF @FilterOn = 'OutStanding'
                        SET @FilterOn = ' ISNULL(AM.IsOutStanding,0) = 1 '; 
                    ELSE
                        IF @FilterOn = 'Resolved'
                            SET @FilterOn = ' AM.IsResolved = ''Resolved'''; 
                        ELSE
                            IF @FilterOn = 'UnResolved'
                                SET @FilterOn = ' AM.IsResolved = ''UnResolved'''; 
                            ELSE
                                IF @FilterOn = 'Actioned'
                                    SET @FilterOn = ' ISNULL(AM.IsActioned,0) = 1'; 
                                ELSE
                                    IF @FilterOn = 'UnActioned'
                                        SET @FilterOn = ' ISNULL(AM.IsActioned,0) = 0'; 
                                    ELSE
                                        IF @FilterOn = 'Transferred'
                                            SET @FilterOn = ' ISNULL(AM.IsTransferred,0) = 1'; 
                                        ELSE
                                            IF @FilterOn = 'In'
                                                AND @IsOut = 1
                                                SET @FilterOn = ' 2 = 1'; 
                                            ELSE
                                                IF @FilterOn = 'In'
                                                    AND @IsOut = 0
                                                    SET @FilterOn = '';	  
                                                ELSE
                                                    IF @FilterOn = 'Out'
                                                        AND @IsOut = 0
                                                        SET @FilterOn = ' 2 = 1'; 
                                                    ELSE
                                                        IF @FilterOn = 'Out'
                                                            AND @IsOut = 1
                                                            SET @FilterOn = ''; 

        IF @FilterOn <> ''
            SET @FilterOn = ' AND ' + @FilterOn; 

        IF @IsOut = 0
            BEGIN
                --- ## Feedback Form Data ##';
                SET @SqlSelect1 = 'SELECT  ISNULL(E.EstablishmentName, '''') AS [Establishment Name] ,
				        ISNULL(U.Name, '''') AS [User Name] ,
				         dbo.ChangeDateFormat(DATEADD(MINUTE,E.TimeOffSet,Am.CreatedOn),''dd-MMM-yyyy hh:mm AM/PM'') AS [Capture Date], 
						 ISNULL(Am.SeenClientAnswerMasterId, '''') AS [Out Reference No] ,
				        Am.Id AS [Reference No] ,
				        ISNULL(Am.[PI], 0.00) AS [PI] ,				       
				       CASE  Q.SeenClientQuestionIdRef  WHEN  NULL THEN CQ.ShortName ELSE Q.ShortName END AS [Question] ,
						CASE Q.QuestionTypeId 
				        WHEN 8 THEN ( CASE WHEN ANS.Detail IS NULL OR ANS.Detail = '''' THEN ISNULL(ANS.Detail, '''') ELSE dbo.ChangeDateFormat(ANS.Detail, ''dd/MMM/yyyy'') END ) 
				        WHEN 9 THEN ( CASE WHEN ANS.Detail IS NULL OR ANS.Detail = '''' THEN ISNULL(ANS.Detail, '''') ELSE dbo.ChangeDateFormat(ANS.Detail, ''hh:mm AM/PM'') END ) 
				        WHEN 22 THEN ( CASE WHEN ANS.Detail IS NULL OR ANS.Detail = '''' THEN ISNULL(ANS.Detail, '''') ELSE dbo.ChangeDateFormat(ANS.Detail, ''dd/MMM/yyyy hh:mm AM/PM'') END ) 
						WHEN 1 THEN dbo.GetOptionNameByQuestionId(Q.Id, ANS.Detail, 0) 
						WHEN 17 THEN ( CASE WHEN ANS.Detail IS NULL THEN '''' ELSE REPLACE(CASE ANS.Detail WHEN '''' THEN '''' ELSE '''
                    + @URL + ''' + ANS.Detail END, '','', '' | ' + @URL
                    + ''') END )
						ELSE (CASE WHEN (ISNULL(ANS.Detail, '''') = '''' AND Q.SeenClientQuestionIdRef  IS not NULL) THEN (SELECT Detail FROM dbo.SeenClientAnswers WHERE QuestionId = Q.SeenClientQuestionIdRef AND isnull(SeenClientAnswerMasterId,0) = ISNULL(Am.SeenClientAnswerMasterId, 0) AND ISNULL(SeenClientAnswerChildId,0) = ISNULL(Am.SeenClientAnswerChildId,0)) ELSE isnull(ANS.Detail,'''') END)
						END AS [Answer] ,						
				        ISNULL(Am.IsResolved, 0) AS [Status] ,
						dbo.ConcateString(N''ResolutionComments'', Am.Id) AS [Resolution Comments] ,
				         ISNULL(Am.IsActioned, 0) AS [Is Actioned] ,
				         ISNULL(Am.IsTransferred, 0) AS [Is Transferred] ,
				        CASE Am.IsTransferred WHEN 1 THEN ISNULL(TransferFromUser.Name, ISNULL(TransferByUser.Name, '''')) ELSE '''' END AS [Transfer From User] ,
				        CASE Am.IsTransferred WHEN 1 THEN ISNULL(U.Name, '''') ELSE '''' END AS [Transfer To User],
				        ISNULL(Am.IsDisabled, 0) AS [Disabled]'; 
                SET @SqlSelect2 = CHAR(10) + CHAR(13)
                    + ' FROM    dbo.AnswerMaster AS Am
				        INNER JOIN dbo.Establishment AS E ON Am.EstablishmentId = E.Id
				        INNER JOIN dbo.Questionnaire AS Qr ON Qr.Id = Am.QuestionnaireId
				        INNER JOIN dbo.Questions AS Q ON Q.QuestionnaireId = Qr.Id
				        LEFT JOIN dbo.SeenClientQuestions AS CQ ON CQ.Id = Q.SeenClientQuestionIdRef AND CQ.IsDeleted = 0
				        LEFT JOIN dbo.Answers AS ANS ON ANS.AnswerMasterId = Am.Id AND ANS.QuestionId = Q.Id
				        LEFT OUTER JOIN dbo.AppUser AS U ON Am.AppUserId = U.Id
				        LEFT OUTER JOIN dbo.AnswerMaster AS TransferFromAM ON TransferFromAM.Id = Am.AnswerMasterId
				        LEFT OUTER JOIN dbo.AppUser AS TransferFromUser ON TransferFromAM.AppUserId = TransferFromUser.Id
				        LEFT OUTER JOIN dbo.AppUser AS TransferByUser ON Am.CreatedBy = TransferByUser.Id';
                SET @SqlSelect3 = N'  WHERE   Am.IsDeleted = 0
				        AND Am.EstablishmentId IN ( SELECT Data FROM dbo.split('''
                    + CONVERT(NVARCHAR(MAX), @EstablishmentId) + ''', '',''))
						AND Am.AppuserId in ( SELECT Data FROM dbo.split('''
                    + CONVERT(NVARCHAR(MAX), @UserId) + ''', '',''))
						AND Am.CreatedOn BETWEEN '''
                    + CONVERT(NVARCHAR(50), @FromDate) + ''' AND '''
                    + CONVERT(NVARCHAR(50), DATEADD(dd, 1, @ToDate)) + '''
						AND Q.IsDeleted = 0
				        AND Q.QuestionTypeId NOT  IN ( 16, 23 )
						AND Q.IsDisplayInDetail = 1';
				

            END;
        ELSE
            BEGIN
               ---## Capture Form Data ##';
				---## For Repetitive questions  ##
                DECLARE @SqlSelect7 NVARCHAR(MAX)= '' ,
                    @SqlSelect8 NVARCHAR(MAX) = '' ,
                    @SqlSelect9 NVARCHAR(MAX)= '' ,
                    @SqlSelect4 NVARCHAR(MAX)= '' ,
                    @SqlSelect5 NVARCHAR(MAX) = '' ,
                    @SqlSelect6 NVARCHAR(MAX)= '';

                SET @SqlSelect1 = 'SELECT  Q.Position, Am.Id AS AnswerMasterID, Q.Id AS QuestionID,E.EstablishmentName AS [Establishment Name] ,
				        ISNULL(U.Name, '''') AS [User Name] ,
				        dbo.ChangeDateFormat(DATEADD(MINUTE,E.TimeOffSet,Am.CreatedOn),''dd-MMM-yyyy hh:mm AM/PM'') AS [Capture Date],
				        ISNULL(Am.SeenClientAnswerMasterId, '''') AS [Out Reference No] ,
				        Am.Id AS [Reference No] ,
				        ISNULL(Am.[PI], 0.00) AS [PI] ,
				        ISNULL( (SELECT ContactGropName FROM dbo.ContactGroup WHERE id IN( SELECT ContactGroupId FROM dbo.SeenClientAnswerMaster  WHERE Id = Am.Id )),'''') AS [Contact Group Name] ,	
				        CASE  Q.ContactQuestionId  WHEN  NULL THEN CQ.ShortName ELSE Q.ShortName END AS [Question] ,
						CASE Q.QuestionTypeId 
				        WHEN 8 THEN ( CASE WHEN ANS.Detail IS NULL OR ANS.Detail = '''' THEN ISNULL(ANS.Detail, '''') ELSE dbo.ChangeDateFormat(ANS.Detail, ''dd/MMM/yyyy'') END ) 
				        WHEN 9 THEN ( CASE WHEN ANS.Detail IS NULL OR ANS.Detail = '''' THEN ISNULL(ANS.Detail, '''') ELSE dbo.ChangeDateFormat(ANS.Detail, ''hh:mm AM/PM'') END ) 
				        WHEN 22 THEN ( CASE WHEN ANS.Detail IS NULL OR ANS.Detail = '''' THEN ISNULL(ANS.Detail, '''') ELSE dbo.ChangeDateFormat(ANS.Detail, ''dd/MMM/yyyy hh:mm AM/PM'') END ) 
						WHEN 1 THEN dbo.GetOptionNameByQuestionId(Q.Id, ANS.Detail, 0) 
						WHEN 17 THEN ( CASE WHEN ANS.Detail IS NULL THEN '''' ELSE REPLACE(CASE ANS.Detail WHEN '''' THEN '''' ELSE '''
                    + @URL + ''' + ANS.Detail END, '','', '' | ' + @URL
                    + ''') END )
						ELSE ISNULL(ANS.Detail, '''')
						END AS [Answer] ,						
				        Am.IsResolved AS [Status] ,
						dbo.ConcateString(N''ResolutionCommentsSeenClient'', Am.Id) AS [Resolution Comments] ,
				        Am.IsActioned AS [Is Actioned] ,
				        Am.IsTransferred AS [Is Transferred] ,
				        CASE Am.IsTransferred WHEN 1 THEN ISNULL(TransferFromUser.Name, ISNULL(TransferByUser.Name, '''')) ELSE '''' END AS [Transfer From User] ,
				        CASE Am.IsTransferred WHEN 1 THEN ISNULL(U.Name, '''') ELSE '''' END AS [Transfer To User],
				        ISNULL(Am.IsDisabled, 0) AS [Disabled]'; 

                SELECT  @SqlSelect1 [@SqlSelect1];

                SET @SqlSelect2 = CHAR(10) + CHAR(13)
                    + ' FROM  dbo.SeenClientAnswerMaster  AS Am
				        INNER JOIN dbo.Establishment AS E ON Am.EstablishmentId = E.Id
				        INNER JOIN dbo.SeenClient AS Qr ON Qr.Id = Am.SeenClientId
				        INNER JOIN dbo.SeenClientQuestions AS Q ON Q.SeenClientId = Am.SeenClientId
				        LEFT JOIN dbo.ContactQuestions AS CQ ON CQ.Id = Q.ContactQuestionId AND CQ.IsDeleted = 0
				        LEFT JOIN dbo.SeenClientAnswers AS ANS ON ANS.SeenClientAnswerMasterId = Am.Id AND ANS.QuestionId = Q.Id
				        LEFT OUTER JOIN dbo.AppUser AS U ON Am.AppUserId = U.Id
				        LEFT OUTER JOIN dbo.SeenClientAnswerMaster AS TransferFromAM ON TransferFromAM.Id = Am.SeenClientAnswerMasterId
				        LEFT OUTER JOIN dbo.AppUser AS TransferFromUser ON TransferFromAM.AppUserId = TransferFromUser.Id
				        LEFT OUTER JOIN dbo.AppUser AS TransferByUser ON Am.CreatedBy = TransferByUser.Id';

                SELECT  @SqlSelect2 [@SqlSelect2];
                SET @SqlSelect3 += N'  WHERE   Am.IsDeleted = 0
				        AND Am.EstablishmentId IN ( SELECT Data FROM dbo.split('''
                    + CONVERT(VARCHAR(2000), @EstablishmentId) + ''', '','')) 
						AND Am.AppuserId in ( SELECT Data FROM dbo.split('''
                    + CONVERT(VARCHAR(2000), @UserId) + ''', '',''))
						AND Am.CreatedOn BETWEEN '''
                    + CONVERT(NVARCHAR(50), @FromDate) + ''' AND '''
                    + CONVERT(NVARCHAR(50), DATEADD(dd, 1, @ToDate)) + '''
						AND Q.IsDeleted = 0
				        AND Q.QuestionTypeId NOT  IN ( 16, 23 )
						AND Q.IsDisplayInDetail = 1
						AND ISNULL(ANS.RepetitiveGroupId, 0) = 0
						AND Q.IsActive = 1
						AND Q.ContactQuestionId IS NULL ';

                SELECT  @SqlSelect3 [@SqlSelect3];
                SET @SqlSelect4 = 'UNION ALL ' + CHAR(10) + CHAR(13)
                    + ' SELECT  Q.Position, Am.Id AS AnswerMasterID, Q.Id AS QuestionID,E.EstablishmentName AS [Establishment Name] ,
				        ISNULL(U.Name, '''') AS [User Name] ,
				        dbo.ChangeDateFormat(DATEADD(MINUTE,E.TimeOffSet,Am.CreatedOn),''dd-MMM-yyyy hh:mm AM/PM'') AS [Capture Date],
				        ISNULL(Am.SeenClientAnswerMasterId, '''') AS [Out Reference No] ,
				        Am.Id AS [Reference No] ,
				        ISNULL(Am.[PI], 0.00) AS [PI] ,
				        ISNULL( (SELECT ContactGropName FROM dbo.ContactGroup WHERE id IN( SELECT ContactGroupId FROM dbo.SeenClientAnswerMaster  WHERE Id = Am.Id )),'''') AS [Contact Group Name] ,	
				        CASE  Q.ContactQuestionId  WHEN  NULL THEN CQ.ShortName ELSE Q.ShortName END AS [Question] ,
						--ISNULL(dbo.GetContactDetailsForGroupFeedback(am.Id, Cq.Id),'''') AS [Answer],
						(CASE WHEN ANS.Detail IS NULL THEN ISNULL(dbo.GetContactDetailsForGroupFeedback(am.Id, Cq.Id),'''') ELSE ANS.Detail END) AS [Answer],
						Am.IsResolved AS [Status] ,
						dbo.ConcateString(N''ResolutionCommentsSeenClient'', Am.Id) AS [Resolution Comments] ,
				        Am.IsActioned AS [Is Actioned] ,
				        Am.IsTransferred AS [Is Transferred] ,
				        CASE Am.IsTransferred WHEN 1 THEN ISNULL(TransferFromUser.Name, ISNULL(TransferByUser.Name, '''')) ELSE '''' END AS [Transfer From User] ,
				        CASE Am.IsTransferred WHEN 1 THEN ISNULL(U.Name, '''') ELSE '''' END AS [Transfer To User],
				        ISNULL(Am.IsDisabled, 0) AS [Disabled]'; 

                SELECT  @SqlSelect4 [@SqlSelect4];
                SET @SqlSelect5 = CHAR(10) + CHAR(13)
                    + ' FROM  dbo.SeenClientAnswerMaster  AS Am
				        INNER JOIN dbo.Establishment AS E ON Am.EstablishmentId = E.Id
				        INNER JOIN dbo.SeenClient AS Qr ON Qr.Id = Am.SeenClientId
				        INNER JOIN dbo.SeenClientQuestions AS Q ON Q.SeenClientId = Am.SeenClientId
				        LEFT JOIN dbo.ContactQuestions AS CQ ON CQ.Id = Q.ContactQuestionId AND CQ.IsDeleted = 0
				        LEFT JOIN dbo.SeenClientAnswers AS ANS ON ANS.SeenClientAnswerMasterId = Am.Id AND ANS.QuestionId = Q.Id
				        LEFT OUTER JOIN dbo.AppUser AS U ON Am.AppUserId = U.Id
				        LEFT OUTER JOIN dbo.SeenClientAnswerMaster AS TransferFromAM ON TransferFromAM.Id = Am.SeenClientAnswerMasterId
				        LEFT OUTER JOIN dbo.AppUser AS TransferFromUser ON TransferFromAM.AppUserId = TransferFromUser.Id
				        LEFT OUTER JOIN dbo.AppUser AS TransferByUser ON Am.CreatedBy = TransferByUser.Id';

                SELECT  @SqlSelect5 [@SqlSelect5];

                SET @SqlSelect6 = CHAR(10) + CHAR(13)
                    + ' WHERE   Am.IsDeleted = 0
				        AND Am.EstablishmentId IN ( SELECT Data FROM dbo.split('''
                    + CONVERT(NVARCHAR(MAX), @EstablishmentId) + ''', '','')) 
						AND Am.AppuserId in ( SELECT Data FROM dbo.split('''
                    + CONVERT(NVARCHAR(MAX), @UserId) + ''', '',''))
						AND Am.CreatedOn BETWEEN '''
                    + CONVERT(NVARCHAR(50), @FromDate) + ''' AND '''
                    + CONVERT(NVARCHAR(50), DATEADD(dd, 1, @ToDate)) + '''
						AND Q.IsDeleted = 0
				        AND Q.QuestionTypeId NOT  IN ( 16, 23 )
						AND Q.IsDisplayInDetail = 1
						AND ISNULL(ANS.RepetitiveGroupId, 0) = 0
						AND Q.IsActive = 1
						AND Q.ContactQuestionId IS NOT NULL ' + CHAR(10)
                    + CHAR(13);
                SET @SqlSelect7 = 'UNION ALL ' + CHAR(10) + CHAR(13)
                    + ' SELECT  Q.Position, Am.Id AS AnswerMasterID, Q.Id AS QuestionID,E.EstablishmentName AS [Establishment Name] ,
				        ISNULL(U.Name, '''') AS [User Name] ,
				       dbo.ChangeDateFormat(DATEADD(MINUTE,E.TimeOffSet,Am.CreatedOn),''dd-MMM-yyyy hh:mm AM/PM'') AS [Capture Date],
				        ISNULL(Am.SeenClientAnswerMasterId, '''') AS [Out Reference No] ,
				        Am.Id AS [Reference No] ,
				        ISNULL(Am.[PI], 0.00) AS [PI] ,
				        ISNULL( (SELECT ContactGropName FROM dbo.ContactGroup WHERE id IN( SELECT ContactGroupId FROM dbo.SeenClientAnswerMaster  WHERE Id = Am.Id )),'''') AS [Contact Group Name] ,	
				        CASE  Q.ContactQuestionId  WHEN  NULL THEN CQ.ShortName ELSE (''(''+ CAST(ANS.RepeatCount AS VARCHAR(20)) + ANS.RepetitiveGroupName  + CAST( ANS.RepetitiveGroupId AS VARCHAR(20))+'')'' + Q.ShortName) END AS [Question] ,
						CASE Q.QuestionTypeId 
				        WHEN 8 THEN ( CASE WHEN ANS.Detail IS NULL OR ANS.Detail = '''' THEN ISNULL(ANS.Detail, '''') ELSE dbo.ChangeDateFormat(ANS.Detail, ''dd/MMM/yyyy'') END ) 
				        WHEN 9 THEN ( CASE WHEN ANS.Detail IS NULL OR ANS.Detail = '''' THEN ISNULL(ANS.Detail, '''') ELSE dbo.ChangeDateFormat(ANS.Detail, ''hh:mm AM/PM'') END ) 
				        WHEN 22 THEN ( CASE WHEN ANS.Detail IS NULL OR ANS.Detail = '''' THEN ISNULL(ANS.Detail, '''') ELSE dbo.ChangeDateFormat(ANS.Detail, ''dd/MMM/yyyy hh:mm AM/PM'') END ) 
						WHEN 1 THEN dbo.GetOptionNameByQuestionId(Q.Id, ANS.Detail, 0) 
						WHEN 17 THEN ( CASE WHEN ANS.Detail IS NULL THEN '''' ELSE REPLACE(CASE ANS.Detail WHEN '''' THEN '''' ELSE '''
                    + @URL + ''' + ANS.Detail END, '','', '' | ' + @URL
                    + ''') END )
						ELSE ISNULL(ANS.Detail, '''')
						END AS [Answer] ,						
				        Am.IsResolved AS [Status] ,
						dbo.ConcateString(N''ResolutionCommentsSeenClient'', Am.Id) AS [Resolution Comments] ,
				        Am.IsActioned AS [Is Actioned] ,
				        Am.IsTransferred AS [Is Transferred] ,
				        CASE Am.IsTransferred WHEN 1 THEN ISNULL(TransferFromUser.Name, ISNULL(TransferByUser.Name, '''')) ELSE '''' END AS [Transfer From User] ,
				        CASE Am.IsTransferred WHEN 1 THEN ISNULL(U.Name, '''') ELSE '''' END AS [Transfer To User],
				        ISNULL(Am.IsDisabled, 0) AS [Disabled]'; 
                SET @SqlSelect8 = CHAR(10) + CHAR(13)
                    + ' FROM  dbo.SeenClientAnswerMaster  AS Am
				        INNER JOIN dbo.Establishment AS E ON Am.EstablishmentId = E.Id
				        INNER JOIN dbo.SeenClient AS Qr ON Qr.Id = Am.SeenClientId
				        INNER JOIN dbo.SeenClientQuestions AS Q ON Q.SeenClientId = Am.SeenClientId
				        LEFT JOIN dbo.ContactQuestions AS CQ ON CQ.Id = Q.ContactQuestionId AND CQ.IsDeleted = 0
				        LEFT JOIN dbo.SeenClientAnswers AS ANS ON ANS.SeenClientAnswerMasterId = Am.Id AND ANS.QuestionId = Q.Id
				        LEFT OUTER JOIN dbo.AppUser AS U ON Am.AppUserId = U.Id
				        LEFT OUTER JOIN dbo.SeenClientAnswerMaster AS TransferFromAM ON TransferFromAM.Id = Am.SeenClientAnswerMasterId
				        LEFT OUTER JOIN dbo.AppUser AS TransferFromUser ON TransferFromAM.AppUserId = TransferFromUser.Id
				        LEFT OUTER JOIN dbo.AppUser AS TransferByUser ON Am.CreatedBy = TransferByUser.Id';
                SET @SqlSelect9 = CHAR(10) + CHAR(13)
                    + ' WHERE   Am.IsDeleted = 0
				        AND Am.EstablishmentId IN ( SELECT Data FROM dbo.split('''
                    + CONVERT(NVARCHAR(MAX), @EstablishmentId) + ''', '','')) 
						AND Am.AppuserId in ( SELECT Data FROM dbo.split('''
                    + CONVERT(NVARCHAR(MAX), @UserId) + ''', '',''))
						AND Am.CreatedOn BETWEEN '''
                    + CONVERT(NVARCHAR(50), @FromDate) + ''' AND '''
                    + CONVERT(NVARCHAR(50), DATEADD(dd, 1, @ToDate))
                    + '''
						AND Q.IsDeleted = 0
				        AND Q.QuestionTypeId NOT  IN ( 16, 23 )
						AND Q.IsDisplayInDetail = 1
						AND (ISNULL(ANS.RepetitiveGroupId, 0) > 0 AND ISNULL(ANS.RepeatCount, 0) > 0)
						AND Q.IsActive = 1' + CHAR(10) + CHAR(13);

            END;
			---- For EXECUTE SQL Query.
			--SELECT (@SqlSelect1 + @SqlSelect2 + @SqlSelect3 )
        SELECT  ( @SqlSelect1 + @SqlSelect2 + @SqlSelect3 + @FilterOn
                  + @SearchQuery + @SqlSelect4 + @SqlSelect5 + @SqlSelect6
                  + @FilterOn + @SearchQuery + @SqlSelect7 + @SqlSelect8
                  + @SqlSelect9 + @FilterOn + @SearchQuery
                  + 'ORDER BY Am.Id, Q.Position ASC' ) AS QU;
      --  EXECUTE (@SqlSelect1 + @SqlSelect2 + @SqlSelect3 + @FilterOn + @SearchQuery + @SqlSelect4 + @SqlSelect5 + @SqlSelect6  + @FilterOn + @SearchQuery +  @SqlSelect7 + @SqlSelect8 + @SqlSelect9 +@FilterOn + @SearchQuery +  'ORDER BY Am.Id, Q.Position ASC');

    END;
