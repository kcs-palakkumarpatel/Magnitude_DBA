--SET QUOTED_IDENTIFIER ON|OFF
--SET ANSI_NULLS ON|OFF
--GO
-- Exec GetActivityCountByAppUserId_2308 1615
CREATE PROCEDURE [dbo].[GetActivityCountByAppUserId_2308]
    @AppUserId BIGINT
AS
BEGIN
SET NOCOUNT ON

CREATE TABLE #ActivitybadgeCount
(
	ActivityId BIGINT,
	ActivityCount INT
)

CREATE TABLE #UnresolveCount
(
	ActivityId BIGINT,
	UnresolveCount INT
)

CREATE TABLE #Response
(
	ActivityId BIGINT,
	ResponseCount INT
)

CREATE TABLE #BadgeIn
(
	ActivityId BIGINT,
	InCount INT
)

CREATE TABLE #BadgeOut
(
	ActivityId BIGINT,
	OutCount INT
)


CREATE TABLE #ActivityUserTable (
	ActivityId BIGINT,
	Userid BIGINT
	)

CREATE TABLE #UserTable (
	Id BIGINT IDENTITY,
	ActivityId BIGINT,
	ActivityType VARCHAR(10)
)

	INSERT INTO #UserTable
	( ActivityId, ActivityType )

	SELECT DISTINCT EG.Id AS ActivityId,EG.EstablishmentGroupType AS ActivityType
	FROM dbo.EstablishmentGroup AS EG
	INNER JOIN dbo.Establishment AS EST ON EST.EstablishmentGroupId = EG.Id
	INNER JOIN dbo.AppUserEstablishment UE ON UE.EstablishmentId = EST.Id
	WHERE     EG.IsDeleted = 0
		AND EST.IsDeleted = 0
		AND UE.AppUserId = @AppUserId
		AND UE.IsDeleted = 0


	DECLARE @start INT
	SET @start = 1
	DECLARE @Aid BIGINT

	WHILE @start <= (SELECT COUNT(1) FROM #UserTable)
	BEGIN
		SET @Aid = (SELECT ActivityId FROM #UserTable WHERE Id = @start)
	
		INSERT INTO #ActivityUserTable
		SELECT ActivityId,UserId FROM dbo.AllUserSelected_2208(@AppUserId,'0',@Aid)
		SET @start = @start + 1;
	END

--SELECT * FROM #UserTable
/************** Badge Count For Activity  END ******************/
INSERT INTO #ActivitybadgeCount
SELECT UT.ActivityId, (SELECT (SELECT COUNT(1) AS Count1
        FROM    dbo.PendingNotificationWeb AS PNW 
		INNER JOIN dbo.AppUser A ON A.id = PNW.AppUserId
		INNER JOIN dbo.SeenClientAnswerMaster SA ON sa.Id = PNW.RefId
		INNER JOIN dbo.Establishment E ON E.Id = SA.EstablishmentId
        WHERE   PNW.AppUserId = @AppUserId
                AND IsRead = 0
				AND PNW.IsDeleted = 0
				AND SA.IsDeleted = 0
                AND ModuleId IN (8,12)
				AND (A.IsAreaManager = 1 OR sa.AppUserId = pnw.AppUserId)
				AND E.EstablishmentGroupId = UT.ActivityId)
+
(SELECT COUNT(1) AS Count1
      FROM    dbo.PendingNotificationWeb AS PNW 
		INNER JOIN dbo.AppUser A ON A.id = PNW.AppUserId
		INNER JOIN dbo.AnswerMaster AM ON AM.Id = PNW.RefId
		INNER JOIN dbo.Establishment E ON E.Id = AM.EstablishmentId
        WHERE   PNW.AppUserId = @AppUserId
                AND IsRead = 0
				AND PNW.IsDeleted = 0
				AND AM.IsDeleted = 0
                AND ModuleId IN (7,11)
				AND (AM.AppUserId = 0 OR A.IsAreaManager = 1 OR AM.AppUserId = pnw.AppUserId)
				AND E.EstablishmentGroupId = UT.ActivityId)) AS ActivityCount FROM #UserTable AS UT

/* *************** Badge Count for Activity END ****************** */

/* ***************Badge Count Unresolve Start ****************** */
      ---DECLARE @EstablishmentId VARCHAR(MAX), 
		DECLARE  @Last30DaysDate DATETIME;
		SET @Last30DaysDate = CONVERT(DATE,DATEADD(DAY,-(SELECT  TOP 1 CAST(KeyValue AS BIGINT) FROM dbo.AAAAConfigSettings WHERE KeyName = 'LastFormDays'),GETUTCDATE()));
        --SET @EstablishmentId = ( SELECT dbo.AllEstablishmentByAppUserAndActivity(@AppuserId,@ActivityId));

INSERT INTO #UnresolveCount
               SELECT UT.ActivityId, (CASE UT.ActivityType WHEN 'Sales' THEN (SELECT COUNT(1)
                FROM    dbo.SeenClientAnswerMaster AS SCA
						INNER JOIN (SELECT AUT.Userid FROM #ActivityUserTable AS AUT WHERE AUT.ActivityId = UT.ActivityId) AS U ON U.Userid = SCA.AppUserId
                        --INNER JOIN (SELECT Data FROM   dbo.Split(UT.UserId, ',')) AS U ON U.Data = SCA.AppUserId
						INNER JOIN dbo.Establishment ON Establishment.Id = SCA.EstablishmentId AND EstablishmentGroupId = UT.ActivityId AND Establishment.IsDeleted = 0
						INNER JOIN dbo.AppUserEstablishment ON AppUserEstablishment.EstablishmentId = Establishment.Id AND  AppUserEstablishment.AppUserId = @AppuserId AND dbo.AppUserEstablishment.IsDeleted = 0
                WHERE  SCA.CreatedOn BETWEEN @Last30DaysDate AND GETUTCDATE()
                       AND SCA.IsDeleted = 0
                       AND SCA.IsResolved = 'Unresolved')
            ELSE (SELECT COUNT(1)
                FROM    dbo.AnswerMaster AS AM
					INNER JOIN dbo.Establishment ON Establishment.Id = AM.EstablishmentId AND EstablishmentGroupId = UT.ActivityId AND Establishment.IsDeleted = 0
						INNER JOIN dbo.AppUserEstablishment ON AppUserEstablishment.EstablishmentId = Establishment.Id AND  AppUserEstablishment.AppUserId = @AppuserId AND dbo.AppUserEstablishment.IsDeleted = 0
                WHERE   AM.CreatedOn BETWEEN @Last30DaysDate AND GETUTCDATE()
                        AND AM.IsDeleted = 0
                        AND AM.IsResolved = 'Unresolved') end) AS UnresolveCount FROM #UserTable AS UT

		/* ***************Badge Count Unresolve End ****************** */
			/* ***************Badge Count Response Start ****************** */

INSERT INTO #Response
SELECT UT.ActivityId,(SELECT SUM(data) FROM ( SELECT  COUNT(SA.id) AS Data
FROM    dbo.ContactDetails AS c
        INNER JOIN dbo.AppUser AS App ON c.Detail = App.Email
        INNER JOIN SeenClientAnswerMaster AS A ON 1 = 1
        INNER JOIN dbo.SeenClientAnswerChild AS SA ON SA.ContactMasterId = c.ContactMasterId
                                                      AND SA.SeenClientAnswerMasterId = A.Id
WHERE   c.ContactMasterId IN ( SELECT   ContactMasterId
                               FROM     dbo.ContactGroupRelation
                               WHERE    ContactGroupId = A.ContactGroupId
                                        AND IsDeleted = 0 )
        AND c.QuestionTypeId = 10
        AND App.Id = @AppUserId
		AND A.CreatedOn BETWEEN @Last30DaysDate AND GETUTCDATE()
		  AND A.EstablishmentId IN (
                                                SELECT  EstablishmentId
                                                FROM    dbo.AppUserEstablishment
                                                        INNER JOIN dbo.Establishment ON Establishment.Id = AppUserEstablishment.EstablishmentId
														INNER JOIN (SELECT AUT.Userid FROM #ActivityUserTable AS AUT WHERE AUT.ActivityId = UT.ActivityId) AS U ON U.Userid = A.AppUserId
														--INNER JOIN (SELECT data FROM dbo.Split(UT.UserId,',')) AS U ON U.data = A.AppUserId
                                                WHERE   AppUserId = @AppuserId
                                                        AND EstablishmentGroupId = UT.ActivityId
                                                        AND Establishment.IsDeleted = 0
                                                        AND dbo.AppUserEstablishment.IsDeleted = 0 )
                                                AND A.IsDeleted = 0
                                                AND A.IsResolved = 'Unresolved'
												AND A.Id NOT IN (SELECT A.SeenClientAnswerMasterId
                      FROM      dbo.View_AllAnswerMaster AS A 
								INNER JOIN (SELECT AUT.Userid FROM #ActivityUserTable AS AUT WHERE AUT.ActivityId = UT.ActivityId) AS U ON (U.Userid = A.UserId OR U.Userid = ISNULL(A.TransferFromUserId,0)OR A.UserId = 0)
                                --INNER JOIN (SELECT Data FROM dbo.Split(UT.UserId, ',')) AS U ON (U.Data = A.UserId OR U.Data = ISNULL(A.TransferFromUserId,0)OR A.UserId = 0)
													 WHERE A.AnswerStatus = 'Unresolved' 
															AND A.ActivityId = UT.ActivityId
													 		AND A.CreatedOn BETWEEN @Last30DaysDate AND GETUTCDATE()
															  AND A.SeenClientAnswerMasterId != 0 
															  GROUP BY A.SeenClientAnswerMasterId)
		UNION ALL        
           SELECT (SELECT COUNT(1) AS Data
                             FROM  dbo.ContactDetails
                                                              AS C
                                                              INNER JOIN dbo.AppUser
                                                              AS App ON C.Detail = App.Email
                                                        WHERE C.ContactMasterId = A.ContactMasterId
                                                              AND QuestionTypeId = 10
                                                              AND App.Id = @AppUserId
                                                      )
            FROM    SeenClientAnswerMaster A WHERE  A.EstablishmentId IN (
                                                SELECT  EstablishmentId
                                                FROM    dbo.AppUserEstablishment
                                                        INNER JOIN dbo.Establishment ON Establishment.Id = AppUserEstablishment.EstablishmentId
														INNER JOIN (SELECT AUT.Userid FROM #ActivityUserTable AS AUT WHERE AUT.ActivityId = UT.ActivityId) AS U ON U.Userid = A.AppUserId
														--INNER JOIN (SELECT data FROM dbo.Split(UT.UserId,',')) AS U ON U.data = A.AppUserId
                                          WHERE   AppUserId = @AppuserId
                                                        AND EstablishmentGroupId = UT.ActivityId
                                                        AND Establishment.IsDeleted = 0
                                                        AND dbo.AppUserEstablishment.IsDeleted = 0 )
												AND A.CreatedOn BETWEEN @Last30DaysDate AND GETUTCDATE()
                                                AND A.IsDeleted = 0
                                                AND A.IsResolved = 'Unresolved'
                                                AND A.Id NOT IN (SELECT A.SeenClientAnswerMasterId
                      FROM      dbo.View_AllAnswerMaster AS A 
								INNER JOIN (SELECT AUT.Userid FROM #ActivityUserTable AS AUT WHERE AUT.ActivityId = UT.ActivityId) AS U ON (U.Userid = A.UserId OR U.Userid = ISNULL(A.TransferFromUserId,0)OR A.UserId = 0)
                                --INNER JOIN (SELECT Data FROM dbo.Split(UT.UserId, ',')) AS U ON (U.Data = A.UserId OR U.Data = ISNULL(A.TransferFromUserId,0)OR A.UserId = 0)
													 WHERE A.AnswerStatus = 'Unresolved' 
															AND A.ActivityId = UT.ActivityId
													 		AND A.CreatedOn BETWEEN @Last30DaysDate AND GETUTCDATE()
															  AND A.SeenClientAnswerMasterId != 0 
															  GROUP BY A.SeenClientAnswerMasterId)) AS T) AS ResponseCount  FROM #UserTable AS UT
--/*******************************************/
DECLARE @Days BIGINT = 30
INSERT INTO #BadgeIn
    SELECT UT.ActivityId,(CASE UT.ActivityType WHEN 'Seles' THEN (SELECT  COUNT(1) AS INCount
                                FROM    dbo.AnswerMaster AS AM
                                        INNER JOIN dbo.Establishment E ON E.Id = AM.EstablishmentId
                                        INNER JOIN dbo.AppUser A ON ( AM.AppUserId = A.Id )
										INNER JOIN (SELECT AUT.Userid FROM #ActivityUserTable AS AUT WHERE AUT.ActivityId = UT.ActivityId) AS U ON U.Userid = A.Id
										--inner JOIN (SELECT  Data FROM dbo.Split(UT.UserId, ',')) AS U ON A.Id = U.Data
                                WHERE   AM.IsDeleted = 0
                                        AND ( AM.AppUserId = 0
                                              OR A.IsAreaManager = 1
                                              OR AM.AppUserId = A.Id
                                            )
                                        AND E.EstablishmentGroupId = UT.ActivityId
                                        AND AM.CreatedOn BETWEEN DATEADD(DAY,
                                                              ( @Days * -1 ),
                                                              GETUTCDATE())
                                                         AND  GETUTCDATE())
    ELSE
    ( SELECT    COUNT(1) AS INCount
      FROM      dbo.AnswerMaster AS AM
                INNER JOIN dbo.Establishment E ON AM.EstablishmentId = E.Id
      WHERE     AM.IsDeleted = 0
                AND E.EstablishmentGroupId = UT.ActivityId
                AND AM.CreatedOn BETWEEN DATEADD(DAY,
                                                              ( @Days * -1 ),
                                                              GETUTCDATE())
                                                         AND  GETUTCDATE()) END) AS InCount 
				FROM #UserTable AS UT
	
    
	 INSERT INTO #BadgeOut
	SELECT  UT.ActivityId,( SELECT  COUNT(1) AS OutCount
                                FROM    dbo.SeenClientAnswerMaster AS SAM
                                        INNER JOIN dbo.Establishment E ON E.Id = SAM.EstablishmentId
										INNER JOIN (SELECT AUT.Userid FROM #ActivityUserTable AS AUT WHERE AUT.ActivityId = UT.ActivityId) AS U ON U.Userid = SAM.AppUserId
										--INNER JOIN (SELECT  Data FROM    dbo.Split(UT.UserId, ',') ) AS U ON SAM.AppUserId = U.Data
                                WHERE   SAM.IsDeleted = 0
                                        AND E.EstablishmentGroupId = UT.ActivityId
                                        AND SAM.CreatedOn BETWEEN DATEADD(DAY,
                                                              ( @Days ),
                                                              GETUTCDATE())
                                                          AND GETUTCDATE() ) AS OUTCount  FROM #UserTable AS UT



/*88888888888888888*/

SELECT #ActivitybadgeCount.ActivityId,ActivityCount,InCount,OutCount,ResponseCount,UnresolveCount 
FROM #ActivitybadgeCount INNER JOIN #BadgeIn ON #BadgeIn.ActivityId = #ActivitybadgeCount.ActivityId
INNER JOIN #BadgeOut ON #BadgeOut.ActivityId = #ActivitybadgeCount.ActivityId 
INNER JOIN #Response ON #Response.ActivityId = #ActivitybadgeCount.ActivityId
INNER JOIN #UnresolveCount ON #UnresolveCount.ActivityId = #ActivitybadgeCount.ActivityId

SET NOCOUNT OFF
END


