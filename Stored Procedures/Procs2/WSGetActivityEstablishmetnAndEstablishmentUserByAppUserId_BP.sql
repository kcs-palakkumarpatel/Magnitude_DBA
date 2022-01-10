-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,12 Jun 2015>
-- Description:	<Description,,>
-- Call SP:		WSGetActivityEstablishmetnAndEstablishmentUserByAppUserId 1243,2119
-- =============================================
CREATE PROCEDURE dbo.WSGetActivityEstablishmetnAndEstablishmentUserByAppUserId_BP
    @AppUserId BIGINT ,
    @ActivityId BIGINT
AS
  BEGIN

	DECLARE @DraftsCount INT;

	SELECT @DraftsCount = COUNT(1) FROM dbo.SeenClientAnswerMaster AS SAM
	INNER JOIN dbo.Establishment AS ES ON ES.Id = SAM.EstablishmentId
	WHERE  SAM.AppUserId =  @AppUserId
    AND ES.EstablishmentGroupId = @ActivityId
	AND SAM.IsDeleted = 1
	AND SAM.DraftEntry = 1

	Declare @table table (ContactId bigint,IsGroup bit ,EstablishmentId bigint)

	Insert into @table
	Select ISNULL(ContactId,0),IsGroup,EstablishmentId FROM dbo.DefaultContact WITH(NOLOCK) 
	WHERE ISNULL(AppUserId,0) = @AppUserId 
	AND IsDeleted = 0

    SELECT  E.Id AS EstablishmentId ,
		E.EstablishmentName ,
		ISNULL(Eg.SMSReminder, 0) AS SendSeenClientSMS ,
		ISNULL(Eg.SMSReminder, 0) AS SendSeenClientEmail ,
		U.Id AS UserId ,
		U.Name ,
		U.UserName ,
		AppUser.AppUserId,
		AppUser.EstablishmentType ,
		CASE AppUser.EstablishmentType WHEN 'supplier' THEN U.SupplierId ELSE 0 END AS SupplierId ,
        CASE AppUser.EstablishmentType WHEN 'supplier' THEN 'supplier' ELSE '' END AS SupplierName ,
        Eg.AllowToChangeDelayTime,
		ISNULL(DC.ContactId,0) AS DefaultContactId,
		ISNULL(DC.IsGroup,'false') AS IsGroup,
		ISNULL(@DraftsCount, 0) AS DraftsCount,
		ISNULL(E.DynamicSaveButtonText, '') AS [DynamicSaveButtonText],
		ISNULL(E.StatusIconEstablishment, 0) AS StatusIconEstablishment,
		ISNULL(E.FeedbackOnce, 0) AS FeedbackOnce,
		ISNULL(e.TimeOffSet,0) AS TimeOffSet
	FROM dbo.AppUserEstablishment AS UE
    INNER JOIN dbo.AppUser AS LoginUser ON UE.AppUserId = LoginUser.Id AND LoginUser.Id = @AppUserId
    INNER JOIN dbo.Establishment AS E ON UE.EstablishmentId = E.Id
    INNER JOIN dbo.EstablishmentGroup AS Eg ON Eg.Id = E.EstablishmentGroupId
    INNER JOIN dbo.AppUserEstablishment AS AppUser ON E.Id = AppUser.EstablishmentId
           AND ( UE.EstablishmentType = AppUser.EstablishmentType OR LoginUser.IsAreaManager = 1)
    INNER JOIN dbo.AppUser AS U ON AppUser.AppUserId = U.Id AND ( U.IsAreaManager = 0 OR U.Id = @AppUserId)
	LEFT OUTER JOIN @table DC ON  ISNULL(DC.EstablishmentId,0) = E.Id 
   -- LEFT JOIN dbo.DefaultContact AS DC WITH(NOLOCK) ON  ISNULL(DC.EstablishmentId,0) = E.Id 
			--AND ISNULL(DC.AppUserId,0) = @AppUserId AND DC.IsDeleted = 0
    WHERE UE.AppUserId = @AppUserId
    AND E.IsDeleted = 0
    AND UE.IsDeleted = 0
    AND AppUser.IsDeleted = 0
	AND U.IsDeleted = 0
    AND E.EstablishmentGroupId = @ActivityId
	ORDER BY E.EstablishmentName ASC
END

