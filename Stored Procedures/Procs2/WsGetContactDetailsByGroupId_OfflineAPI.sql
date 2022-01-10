/*
Modified By : Jayesh Prajapati (10/11/2020) --Optimised stored procedure
--drop procedure WsGetContactDetailsByGroupId_OfflineAPI
exec WsGetContactDetailsByGroupId_OfflineAPI 201,1246,'2020-11-18 05:50:36'
exec WsGetContactDetailsByGroupId_101120_2 437,3841,'2020-11-16 00:00:00'
exec WsGetContactDetailsByGroupId 201,1246
exec WsGetContactDetailsByGroupId 534,5830
*/
CREATE PROCEDURE [dbo].[WsGetContactDetailsByGroupId_OfflineAPI]
	@GroupId BIGINT ,
    @AppUserId BIGINT,
	@LastServerDate DATETIME = ''
AS
BEGIN
SET NOCOUNT ON
BEGIN TRY
	DECLARE @top INT = 100;
    DECLARE @Count INT;
    
	DECLARE @SeenclinetContact AS TABLE
    (
		Id BIGINT ,
        SeenClientId BIGINT ,
        Name NVARCHAR(MAX) ,
        IsGroup BIT,
		LastUpdateOn DATETIME
	);

    DECLARE @FinalResult AS TABLE
    (
        Id BIGINT ,
        Name NVARCHAR(MAX) ,
        IsGroup BIT ,
		LastUsedOn DATETIME,
        s INT
	);

	DECLARE @Result AS TABLE
	(
		Id BIGINT ,
		Name NVARCHAR(MAX) ,
		IsGroup BIT,
		LastUsedOn DATETIME 
	)

	DECLARE @RoleDetails AS TABLE
	(
		ContactRoleId BIGINT,
		appEstablishmentUserId BIGINT
	)

   	INSERT INTO @RoleDetails
	( 
		ContactRoleId ,
		appEstablishmentUserId
	)
	SELECT  ContactRoleId ,AppUserId
	FROM  dbo.AppUserEstablishment WITH(NOLOCK)
    INNER JOIN dbo.ContactRoleEstablishment WITH(NOLOCK) ON ContactRoleEstablishment.EstablishmentId = AppUserEstablishment.EstablishmentId
    WHERE   ContactRoleId IN (SELECT ContactRoleId FROM dbo.AppUserContactRole WHERE AppUserId = @AppUserId) 
	AND AppUserEstablishment.IsDeleted = 0
    GROUP BY AppUserId,ContactRoleId;

	----If Start
	IF EXISTS ( SELECT  1 FROM dbo.AppUserContactRole WHERE  AppUserId = @AppUserId )
	BEGIN
	    PRINT 1
		INSERT  INTO @SeenclinetContact
        SELECT  DISTINCT
			R.ContactMasterOrGroupId ,
            R.SeenClientId ,
            R.ContactGropName ,
            R.IsGroup,
			R.LastUsedOn
		FROM (SELECT TOP 50 ISNULL(SAM.ContactMasterId, SAM.ContactGroupId) AS ContactMasterOrGroupId ,
				SAM.SeenClientId ,
				(CASE WHEN SAM.IsSubmittedForGroup = 1 THEN CG.LastUsedOn ELSE CM.LastUsedOn END ) AS LastUsedOn,
				--(CASE WHEN SAM.IsSubmittedForGroup = 1 AND SAM.ContactMasterId IS NULL THEN CG.ContactGropName
				--	WHEN SAM.ContactMasterId IS NOT NULL THEN dbo.ConcateString('ContactSummary', SAM.ContactMasterId) END ) AS ContactGropName ,
				(CASE WHEN SAM.IsSubmittedForGroup = 1 AND SAM.ContactMasterId IS NULL THEN CG.ContactGropName
						WHEN SAM.ContactMasterId IS NOT NULL THEN 
				 Isnull((select stuff(( select ','+ CASE Cd.QuestionTypeId  
					 WHEN 8  THEN CONVERT(NVARCHAR(50), dbo.ChangeDateFormat(Detail,  'dd/MMM/yyyy'))  
					 WHEN 9  THEN CONVERT(NVARCHAR(50), dbo.ChangeDateFormat(Detail,  'hh:mm AM/PM'))  
					 WHEN 22  THEN CONVERT(NVARCHAR(50), dbo.ChangeDateFormat(Detail,  'dd/MMM/yyyy hh:mm AM/PM'))  
				     ELSE CONVERT(NVARCHAR(50), ISNULL(Detail,'')) END   
				FROM  dbo.ContactDetails  AS Cd WITH(NOLOCK)
				INNER JOIN dbo.ContactQuestions AS Cq WITH(NOLOCK) ON Cd.ContactQuestionId = Cq.Id  
				WHERE  ContactMasterId = SAM.ContactMasterId AND Cd.IsDeleted = 0 AND Cq.IsDeleted = 0 AND Detail <> ''
				AND ISNULL(Cd.CreatedOn,cd.UpdatedOn) >= @LastServerDate
				ORDER BY Position
				for xml path('')), 1, 1, '')),'') END ) AS ContactGropName ,
				CASE WHEN SAM.ContactMasterId IS NULL THEN 1 ELSE 0 END AS IsGroup ,
				CONVERT(NVARCHAR(50), SAM.CreatedOn, 121) AS CreatedOn
				FROM SeenClientAnswerMaster SAM
				INNER JOIN dbo.Establishment E WITH(NOLOCK) ON E.Id = SAM.EstablishmentId
                INNER JOIN dbo.EstablishmentGroup EG WITH(NOLOCK) ON EG.Id = E.EstablishmentGroupId
                LEFT OUTER JOIN dbo.ContactMaster AS CM WITH(NOLOCK) ON CM.Id = SAM.ContactMasterId
				LEFT OUTER JOIN dbo.ContactGroup AS CG WITH(NOLOCK) ON CG.Id = SAM.ContactGroupId
				INNER JOIN dbo.ContactRole AS c WITH(NOLOCK) ON c.GroupId = @GroupId
				INNER JOIN @RoleDetails AS crd ON crd.ContactRoleId = c.Id
						AND ( crd.AppEstablishmentUserId = CM.CreatedBy OR CM.CreatedBy = 0)
				INNER JOIN dbo.AppUserContactRole AS ac WITH(NOLOCK) ON ac.ContactRoleId = c.Id AND ac.AppUserId = @AppUserId
				WHERE SAM.SeenClientId = EG.SeenClientId
				AND ( ISNULL(CM.GroupId, 0) = @GroupId OR ISNULL(CG.GroupId, 0) = @GroupId )
				AND ISNULL(CM.IsDeleted, 0) = 0
                AND ISNULL(CG.IsDeleted, 0) = 0
				AND ( ISNULL(CM.UpdatedON,CM.CreatedOn) >= @LastServerDate OR ISNULL(CG.UpdatedON,CG.CreatedON) >= @LastServerDate)
                GROUP BY  SAM.SeenClientId ,
					ISNULL(SAM.ContactMasterId,SAM.ContactGroupId) ,
					SAM.ContactMasterId ,
                    SAM.IsSubmittedForGroup ,
                    CG.ContactGropName ,
                    CONVERT(NVARCHAR(50), SAM.CreatedOn, 121),
					( CASE WHEN SAM.IsSubmittedForGroup = 1 THEN  CG.LastUsedOn ELSE CM.LastUsedOn END )
				ORDER BY  CONVERT(NVARCHAR(50), SAM.CreatedOn, 121) DESC
			) AS R  
                        
		SELECT  @Count = COUNT(*)
        FROM    @SeenclinetContact;
        
		-----------------
		IF ( @Count < @top )
        BEGIN
			INSERT  INTO @FinalResult
            ( 
				Id ,
                Name ,
                IsGroup ,
				LastUsedOn,
                s
			)
            SELECT  S.Id ,
				Name ,
                IsGroup ,
				CM.LastUsedOn ,
				0 AS s
             FROM @SeenclinetContact AS S
             LEFT JOIN dbo.ContactMaster CM WITH(NOLOCK) ON S.Id = CM.Id AND CM.IsDeleted = 0
			 INNER JOIN ContactRole AS c WITH(NOLOCK) ON c.GroupId = @GroupId
             INNER JOIN @RoleDetails AS crd ON crd.ContactRoleId = c.Id
				AND ( crd.AppEstablishmentUserId = CM.CreatedBy OR CM.CreatedBy = 0 )
			 INNER JOIN dbo.AppUserContactRole AS ac WITH(NOLOCK) ON ac.ContactRoleId = c.Id AND ac.AppUserId = @AppUserId
			WHERE S.Id IS NOT NULL AND ISNULL(CM.UpdatedON,CM.CreatedON) >= @LastServerDate
            UNION
            SELECT TOP ( @top - @Count )
				CM.Id ,
                --dbo.ConcateString('ContactSummary',CM.Id) AS ContactGropName ,
				Isnull((select stuff(( select ','+ CASE Cd.QuestionTypeId  
					 WHEN 8  THEN CONVERT(NVARCHAR(50), dbo.ChangeDateFormat(Detail,  'dd/MMM/yyyy'))  
					 WHEN 9  THEN CONVERT(NVARCHAR(50), dbo.ChangeDateFormat(Detail,  'hh:mm AM/PM'))  
					 WHEN 22  THEN CONVERT(NVARCHAR(50), dbo.ChangeDateFormat(Detail,  'dd/MMM/yyyy hh:mm AM/PM'))  
				     ELSE CONVERT(NVARCHAR(50), ISNULL(Detail,'')) END   
				FROM  dbo.ContactDetails  AS Cd  WITH(NOLOCK)
				INNER JOIN dbo.ContactQuestions AS Cq WITH(NOLOCK) ON Cd.ContactQuestionId = Cq.Id  
				WHERE  ContactMasterId = CM.Id AND Cd.IsDeleted = 0 AND Cq.IsDeleted = 0 AND Detail <> ''
				ORDER BY Position
				for xml path('')), 1, 1, '')),'') AS ContactGropName,
				--'' As ContactGropName,
				0 AS t ,
				CM.LastUsedOn,
                0 AS s
			FROM   dbo.ContactMaster AS CM WITH(NOLOCK)
            INNER JOIN ContactRole AS c WITH(NOLOCK) ON c.GroupId = @GroupId
            INNER JOIN @RoleDetails AS crd ON crd.ContactRoleId = c.Id
				AND ( crd.AppEstablishmentUserId = CM.CreatedBy OR CM.CreatedBy = 0)
			INNER JOIN dbo.AppUserContactRole AS ac WITH(NOLOCK) ON ac.ContactRoleId = c.Id AND ac.AppUserId = @AppUserId
			WHERE  CM.GroupId = @GroupId
				AND CM.IsDeleted = 0
                AND CM.Id NOT IN ( SELECT  Id FROM  @SeenclinetContact )
				AND ISNULL(CM.UpdatedON,CM.CreatedON) >= @LastServerDate
			UNION
			SELECT  ISNULL(CG.Id, 0) ,
				ContactGropName ,
                1 ,
				CG.LastUsedOn,
                1 AS s
			FROM  dbo.ContactGroup AS CG WITH(NOLOCK)
            INNER JOIN ContactRole AS c WITH(NOLOCK) ON c.GroupId = @GroupId
            INNER JOIN @RoleDetails AS crd ON crd.ContactRoleId = c.Id
				AND ( crd.AppEstablishmentUserId = CG.CreatedBy OR CG.CreatedBy = 0)
			INNER JOIN dbo.AppUserContactRole AS ac WITH(NOLOCK) ON ac.ContactRoleId = c.Id AND ac.AppUserId = @AppUserId
			WHERE   CG.IsDeleted = 0
			AND CG.Id NOT IN (SELECT  Id FROM  @SeenclinetContact )
			AND CG.GroupId = @GroupId
			AND ISNULL(CG.UpdatedON,CG.CreatedON) >= @LastServerDate

			INSERT INTO @Result
			(
				Id, Name, IsGroup, LastUsedOn 
			)
            SELECT TOP 50
				Id ,
                Name ,
                IsGroup,
				LastUsedOn
			FROM  @FinalResult
            GROUP BY Id ,
				Name ,
                IsGroup ,
				LastUsedOn ,
                s
             ORDER BY s; 
		END;
        ELSE--------------
        BEGIN
			INSERT INTO @Result
			( 
				Id, Name, IsGroup, LastUsedOn 
			)
            SELECT S.Id ,
				Name ,
                IsGroup,
				LastUsedOn
            FROM @SeenclinetContact AS S
            INNER JOIN dbo.ContactMaster CM WITH(NOLOCK) ON CM.Id = S.Id
            WHERE  S.Id IS NOT NULL
            AND CM.IsDeleted = 0
			AND ISNULL(CM.UpdatedON,CM.CreatedON) >= @LastServerDate
       END;
    END
    --Else IF
	ELSE
	BEGIN
	  PRINT 2
		INSERT  INTO @SeenclinetContact
        SELECT  DISTINCT
			R.ContactMasterOrGroupId ,
			R.SeenClientId ,
            R.ContactGropName ,
            R.IsGroup,
			R.LastUsedOn
		FROM (  SELECT TOP 50
				ISNULL(SAM.ContactMasterId,SAM.ContactGroupId) AS ContactMasterOrGroupId ,
                SAM.SeenClientId ,
				(CASE WHEN SAM.IsSubmittedForGroup = 1 AND SAM.ContactMasterId IS NULL THEN CG.ContactGropName
						WHEN SAM.ContactMasterId IS NOT NULL THEN 
				Isnull((select stuff(( select ','+ CASE Cd.QuestionTypeId  
					 WHEN 8  THEN CONVERT(NVARCHAR(50), dbo.ChangeDateFormat(Detail,  'dd/MMM/yyyy'))  
					 WHEN 9  THEN CONVERT(NVARCHAR(50), dbo.ChangeDateFormat(Detail,  'hh:mm AM/PM'))  
					 WHEN 22  THEN CONVERT(NVARCHAR(50), dbo.ChangeDateFormat(Detail,  'dd/MMM/yyyy hh:mm AM/PM'))  
				     ELSE CONVERT(NVARCHAR(50), ISNULL(Detail,'')) END   
				FROM  dbo.ContactDetails  AS Cd WITH(NOLOCK)  
				INNER JOIN dbo.ContactQuestions AS Cq WITH(NOLOCK) ON Cd.ContactQuestionId = Cq.Id  
				WHERE  ContactMasterId = SAM.ContactMasterId AND Cd.IsDeleted = 0 AND Cq.IsDeleted = 0 AND Detail <> ''
				--AND ISNULL(Cd.CreatedOn,cd.UpdatedOn) >= @LastServerDate
				ORDER BY Position
				for xml path('')), 1, 1, '')),'') END) AS ContactGropName ,
				CASE WHEN SAM.ContactMasterId IS NULL THEN 1 ELSE 0 END AS IsGroup ,
				CONVERT(NVARCHAR(50), SAM.CreatedOn, 121) AS CreatedOn,
				( CASE WHEN SAM.IsSubmittedForGroup = 1 THEN  CG.LastUsedOn ELSE CM.LastUsedOn END ) AS LastUsedOn
				FROM dbo.SeenClientAnswerMaster SAM WITH(NOLOCK)
				INNER JOIN dbo.Establishment E WITH(NOLOCK) ON E.Id = SAM.EstablishmentId
                INNER JOIN dbo.EstablishmentGroup EG WITH(NOLOCK) ON EG.Id = E.EstablishmentGroupId
                LEFT OUTER JOIN dbo.ContactMaster AS CM WITH(NOLOCK) ON CM.Id = SAM.ContactMasterId
				LEFT OUTER JOIN dbo.ContactGroup AS CG WITH(NOLOCK) ON CG.Id = SAM.ContactGroupId
				WHERE SAM.SeenClientId = EG.SeenClientId
				AND ( ISNULL(CM.GroupId, 0) = @GroupId OR ISNULL(CG.GroupId, 0) = @GroupId )
				AND ISNULL(CM.IsDeleted, 0) = 0
                AND ISNULL(CG.IsDeleted, 0) = 0
				AND (ISNULL(CM.UpdatedON,CM.CreatedOn) >= @LastServerDate 
				OR ISNULL(CG.UpdatedON,CG.CreatedON) >= @LastServerDate)
                GROUP BY  SAM.SeenClientId ,
						ISNULL(SAM.ContactMasterId,SAM.ContactGroupId) ,
						SAM.ContactMasterId ,
                        SAM.IsSubmittedForGroup ,
                        CG.ContactGropName ,
                        CONVERT(NVARCHAR(50), SAM.CreatedOn, 121) ,
						( CASE WHEN SAM.IsSubmittedForGroup = 1 THEN  CG.LastUsedOn ELSE CM.LastUsedOn END )
				ORDER BY  CONVERT(NVARCHAR(50), SAM.CreatedOn, 121) DESC
			) AS R  
        SELECT  @Count = COUNT(*)
        FROM    @SeenclinetContact;
		 PRINT '@Count'
		 PRINT @Count
		-------------------
		IF ( @Count < @top )
        BEGIN
			INSERT  INTO @FinalResult
            ( 
				Id ,
                Name ,
                IsGroup ,
				LastUsedOn,
                s
             )
             SELECT  S.Id ,Name ,IsGroup ,
				CASE  WHEN IsGroup = 1 THEN CONVERT(VARCHAR, CG.LastUsedOn, 20)
					ELSE CONVERT(VARCHAR, CM.LastUsedOn, 20) END AS LastUsedOn,
                 0 AS s
             FROM    @SeenclinetContact AS S
             LEFT JOIN dbo.ContactMaster CM WITH(NOLOCK) ON S.Id = CM.Id AND CM.IsDeleted = 0
			 LEFT JOIN dbo.ContactGroup CG WITH(NOLOCK) ON S.Id = CG.Id AND CG.IsDeleted = 0 -- Added by Mittal
			 WHERE   S.Id IS NOT NULL AND (ISNULL(CM.UpdatedON,CM.CreatedOn) >= @LastServerDate 
				OR ISNULL(CG.UpdatedON,CG.CreatedON) >= @LastServerDate)
             UNION
             SELECT TOP ( @top - @Count )
                  CM.Id ,
                 -- dbo.ConcateString('ContactSummary',CM.Id) AS ContactGropName ,
				IsNull((select stuff(( select ','+ CASE Cd.QuestionTypeId  
					 WHEN 8  THEN CONVERT(NVARCHAR(50), dbo.ChangeDateFormat(Detail,  'dd/MMM/yyyy'))  
					 WHEN 9  THEN CONVERT(NVARCHAR(50), dbo.ChangeDateFormat(Detail,  'hh:mm AM/PM'))  
					 WHEN 22  THEN CONVERT(NVARCHAR(50), dbo.ChangeDateFormat(Detail,  'dd/MMM/yyyy hh:mm AM/PM'))  
				     ELSE CONVERT(NVARCHAR(50), ISNULL(Detail,'')) END   
				FROM  dbo.ContactDetails  AS Cd WITH(NOLOCK)  
				INNER JOIN dbo.ContactQuestions AS Cq WITH(NOLOCK) ON Cd.ContactQuestionId = Cq.Id  
				WHERE  ContactMasterId = CM.Id AND Cd.IsDeleted = 0 AND Cq.IsDeleted = 0 AND Detail <> ''
				ORDER BY Position
				for xml path('')), 1, 1, '')),'') AS ContactGropName,
                   0 AS t ,
				   CM.LastUsedOn ,
                   0 AS s
             FROM    dbo.ContactMaster AS CM WITH(NOLOCK)
			 WHERE   CM.GroupId = @GroupId
             AND CM.IsDeleted = 0
             AND CM.Id NOT IN ( SELECT  Id FROM @SeenclinetContact )
			 AND (ISNULL(CM.UpdatedON,CM.CreatedOn) >= @LastServerDate)
             UNION
             SELECT  ISNULL(CM.Id, 0) ,
                ContactGropName ,
                1 ,
				CM.LastUsedOn,
                1 AS s
             FROM    dbo.ContactGroup AS CM WITH(NOLOCK)
			 WHERE   CM.IsDeleted = 0
             AND CM.Id NOT IN (SELECT  Id FROM    @SeenclinetContact )
             AND CM.GroupId = @GroupId
			 AND ISNULL(CM.UpdatedON,CM.CreatedON) >= @LastServerDate;

			INSERT INTO @Result
			( Id, Name, IsGroup, LastUsedOn )
            SELECT TOP 50
               Id ,
                Name ,
                IsGroup,
				LastUsedOn
            FROM @FinalResult
            GROUP BY Id ,
				Name ,
                IsGroup ,
				LastUsedOn,
                s
			ORDER BY s; 
           END;
        ELSE--------------------
        BEGIN
			INSERT INTO @Result
			( 
				Id, Name, IsGroup,LastUsedOn 
			)
			SELECT  S.Id ,
				Name ,
				IsGroup,
				LastUsedOn
			FROM    @SeenclinetContact AS S
			INNER JOIN dbo.ContactMaster CM WITH(NOLOCK) ON CM.Id = S.Id
			WHERE   S.Id IS NOT NULL
			AND CM.IsDeleted = 0
			AND ISNULL(CM.UpdatedON,CM.CreatedON) >= @LastServerDate
        END;
		--------------------
	END
	--If End

	SELECT Id,Name,IsGroup, CONVERT(varchar, LastUsedOn, 20) as LastUsedOn FROM @Result
	UNION
	SELECT ContactId,
		--CASE IsGroup WHEN 1 THEN (SELECT ContactGropName FROM dbo.ContactGroup WHERE Id = ContactId)
		--ELSE dbo.ConcateString('ContactSummary',dbo.DefaultContact.ContactId) 
		--end AS ContactGropName 
		CASE IsGroup WHEN 1 THEN (SELECT Top 1 ContactGropName FROM dbo.ContactGroup WHERE Id = ContactId)
		ELSE 
		Isnull((select stuff(( select ','+ CASE Cd.QuestionTypeId  
					 WHEN 8  THEN CONVERT(NVARCHAR(50), dbo.ChangeDateFormat(Detail,  'dd/MMM/yyyy'))  
					 WHEN 9  THEN CONVERT(NVARCHAR(50), dbo.ChangeDateFormat(Detail,  'hh:mm AM/PM'))  
					 WHEN 22  THEN CONVERT(NVARCHAR(50), dbo.ChangeDateFormat(Detail,  'dd/MMM/yyyy hh:mm AM/PM'))  
				     ELSE CONVERT(NVARCHAR(50), ISNULL(Detail,'')) END   
				FROM  dbo.ContactDetails  AS Cd WITH(NOLOCK)  
				INNER JOIN dbo.ContactQuestions AS Cq WITH(NOLOCK) ON Cd.ContactQuestionId = Cq.Id  
				WHERE  ContactMasterId = dbo.DefaultContact.ContactId AND Cd.IsDeleted = 0 AND Cq.IsDeleted = 0 AND Detail <> ''
				ORDER BY Position
				for xml path('')), 1, 1, '')),'') end AS ContactGropName 	
		,IsGroup, 
		CASE IsGroup WHEN 1 THEN (SELECT CONVERT(varchar, LastUsedOn, 20) FROM dbo.ContactGroup WITH(NOLOCK) WHERE id = ContactId)
			ELSE
		(SELECT CONVERT(varchar, LastUsedOn, 20) FROM dbo.ContactMaster WITH(NOLOCK) WHERE Id = ContactId)
		END as LastUsedOn
	FROM dbo.DefaultContact  WITH(NOLOCK)
	WHERE ContactId NOT IN (SELECT Id FROM @Result) AND IsDeleted = 0 AND AppUserId = @AppUserId
	And ISNULL(dbo.DefaultContact.UpdatedOn,dbo.DefaultContact.CreatedOn) >= @LastServerDate
	ORDER BY LastUsedOn DESC
END TRY
BEGIN CATCH 
SELECT
    ERROR_NUMBER() AS ErrorNumber,
    ERROR_STATE() AS ErrorState,
    ERROR_SEVERITY() AS ErrorSeverity,
    ERROR_PROCEDURE() AS ErrorProcedure,
    ERROR_LINE() AS ErrorLine,
    ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
SET NOCOUNT OFF	
END;
