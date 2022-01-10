-- =============================================
-- Author:		Vasu Patel
-- Create date:	31-Jan-2018
-- Description:	Get OUT and IN count
-- Call:		select dbo.GetCountForResponse(2182,1941)
-- =============================================
CREATE FUNCTION [dbo].[GetCountForResponse]
    (
	@AppUserId BIGINT,
	@ActivityId BIGINT
	)
	RETURNS INT
AS
BEGIN
DECLARE @result BIGINT;

	   DECLARE @Last30DaysDate DATETIME;
		SET @Last30DaysDate = DATEADD(DAY,-(SELECT  TOP 1 CAST(KeyValue AS BIGINT) FROM dbo.AAAAConfigSettings WHERE KeyName = 'LastFormDays'),GETUTCDATE());
        
        DECLARE @UserId VARCHAR(MAX); 
        SET @UserId = ( SELECT  dbo.AllUserSelected(@AppuserId,
                                                    0,
                                                    @ActivityId)
                      );

				DECLARE @Temp TABLE (
				[SeenClientAnswerMasterId] [BIGINT] NOT NULL
				)
				INSERT INTO @Temp
				        ( SeenClientAnswerMasterId )
				
				SELECT A.SeenClientAnswerMasterId
                      FROM      dbo.View_AllAnswerMaster AS A
                                INNER JOIN ( SELECT Data
                                             FROM   dbo.Split(@UserId, ',')
                                           ) AS U ON ( U.Data = A.UserId
                                                       OR U.Data = ISNULL(A.TransferFromUserId,0)
                                                       OR @UserId = '0'
                                                       OR A.UserId = 0
                                                     )
													 WHERE A.AnswerStatus = 'Unresolved' 
															AND A.ActivityId = @ActivityId
													 		AND A.CreatedOn BETWEEN @Last30DaysDate AND DATEADD(MINUTE, A.TimeOffSet, GETUTCDATE())
															  AND A.SeenClientAnswerMasterId != 0 
															  GROUP BY A.SeenClientAnswerMasterId
SELECT @result = SUM(data) FROM ( SELECT  COUNT(SA.id) AS Data
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
                                                        INNER JOIN dbo.Vw_Establishment AS E ON E.Id = AppUserEstablishment.EstablishmentId
                                                WHERE   AppUserId = @AppuserId
                                                        AND EstablishmentGroupId = @ActivityId
                                                        AND E.IsDeleted = 0
                                                        AND dbo.AppUserEstablishment.IsDeleted = 0 )
                                                AND A.IsDeleted = 0
                                                AND A.IsResolved = 'Unresolved'
                                                AND A.AppUserId IN (
                                                SELECT  Data
                                                FROM    dbo.Split(@UserId, ',') )
												AND A.Id NOT IN (SELECT SeenClientAnswerMasterId FROM @Temp)
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
                                                        INNER JOIN dbo.Vw_Establishment AS E ON E.Id = AppUserEstablishment.EstablishmentId
                                                WHERE   AppUserId = @AppuserId
                                                        AND EstablishmentGroupId = @ActivityId
                                                        AND E.IsDeleted = 0
                                                        AND dbo.AppUserEstablishment.IsDeleted = 0 )
											AND A.CreatedOn BETWEEN @Last30DaysDate AND GETUTCDATE()
                                                AND A.IsDeleted = 0
                                                AND A.IsResolved = 'Unresolved'
                                                AND A.AppUserId IN (
                                                SELECT  Data
                                                FROM    dbo.Split(@UserId, ',') ) AND A.Id NOT IN (SELECT SeenClientAnswerMasterId FROM @Temp)) AS T
			  RETURN @Result ;
		END







