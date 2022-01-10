-- =============================================
-- Author:		<Vasu Patel>
-- Create date: <19 Sep 2017>
-- Description:	<Get OUT and IN count>
-- Call: select dbo.GetBadgeCountINOUT_0908(1615,2011,30,1)
-- =============================================
CREATE FUNCTION dbo.GetBadgeCountINOUT_0908
(
   @AppuserId INT ,
	@ActivityId INT ,
	@Days INT ,
	@Type BIT 
)
RETURNS INT
AS
BEGIN
IF (@Days = 0)
	SET @Days = 30;

DECLARE @UserId VARCHAR(2000) 
SET @UserId = (SELECT dbo.AllUserSelected(@AppuserId,0,@ActivityId))
DECLARE @Result INT
    IF ( @Type = 0 )
        BEGIN
		IF((SELECT EstablishmentGroupType FROM dbo.EstablishmentGroup WHERE id = @ActivityId) = 'Sales')
		BEGIN
            SELECT  @Result = ( SELECT  COUNT(AM.Id) AS INCount
                                FROM    dbo.AnswerMaster AS AM
                                        INNER JOIN dbo.Establishment E ON E.Id = AM.EstablishmentId
                                        INNER JOIN dbo.AppUser A ON ( AM.AppUserId = A.Id )
										inner JOIN (SELECT  Data FROM    dbo.Split(@UserId, ',')) AS U ON A.Id = U.Data
                                WHERE   AM.IsDeleted = 0
                                        AND ( AM.AppUserId = 0 OR A.IsAreaManager = 1 OR AM.AppUserId = A.Id)
                                        AND E.EstablishmentGroupId = @ActivityId
                                        AND AM.CreatedOn BETWEEN DATEADD(DAY,( @Days * -1 ),GETUTCDATE()) AND  GETUTCDATE()
                              );
	END
    ELSE
    BEGIN
	SELECT @Result = 
    ( SELECT    COUNT(AM.Id) AS INCount
      FROM      dbo.AnswerMaster AS AM
                INNER JOIN dbo.Establishment E ON AM.EstablishmentId = E.Id
      WHERE     AM.IsDeleted = 0
                AND E.EstablishmentGroupId = @ActivityId
                AND AM.CreatedOn BETWEEN DATEADD(DAY, ( @Days * -1 ),
                                                 GETUTCDATE())
                                 AND     GETUTCDATE()
    );
	END
    
       END;
    ELSE
        BEGIN
	
            SELECT  @Result = ( SELECT  COUNT(SAM.Id) AS OutCount
                                FROM    dbo.SeenClientAnswerMaster AS SAM
                                        INNER JOIN dbo.Establishment E ON E.Id = SAM.EstablishmentId
										INNER JOIN (SELECT  Data FROM dbo.Split(@UserId, ',') ) AS U ON SAM.AppUserId = U.Data
                                WHERE   SAM.IsDeleted = 0
                                        AND E.EstablishmentGroupId = @ActivityId
                                        AND SAM.CreatedOn BETWEEN DATEADD(DAY,( @Days * -1 ),GETUTCDATE()) AND GETUTCDATE());

        END;
	RETURN @Result
END









