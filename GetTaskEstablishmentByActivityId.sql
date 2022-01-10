-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,12 Jun 2015>
-- Description:	<Description,,>
-- Call SP:		GetTaskEstablishmentByActivityId 1246,'7871'
-- =============================================
CREATE PROCEDURE dbo.GetTaskEstablishmentByActivityId
    @AppUserId BIGINT,
    @ActivityId NVARCHAR(2000)
AS
BEGIN

    SELECT DISTINCT E.Id AS EstablishmentId,
           E.EstablishmentName,
           Eg.Color
    FROM dbo.AppUserEstablishment AS UE
        INNER JOIN dbo.AppUser AS LoginUser
            ON UE.AppUserId = LoginUser.Id
               AND LoginUser.Id = @AppUserId
        INNER JOIN dbo.Vw_Establishment AS E
            ON UE.EstablishmentId = E.Id
        INNER JOIN dbo.EstablishmentGroup AS Eg
            ON Eg.Id = E.EstablishmentGroupId
        INNER JOIN dbo.AppUserEstablishment AS AppUser
            ON E.Id = AppUser.EstablishmentId
               AND (
                       UE.EstablishmentType = AppUser.EstablishmentType
                       OR LoginUser.IsAreaManager = 1
                   )
        INNER JOIN dbo.AppUser AS U
            ON AppUser.AppUserId = U.Id
               AND (
                       U.IsAreaManager = 0
                       OR U.Id = @AppUserId
                   )
    WHERE UE.AppUserId = @AppUserId
          AND E.IsDeleted = 0
          AND UE.IsDeleted = 0
          AND AppUser.IsDeleted = 0
          AND U.IsDeleted = 0
          AND ((E.EstablishmentGroupId IN (
                                            SELECT Data FROM dbo.Split(@ActivityId, ',')
                                        )) OR @ActivityId = '')
    ORDER BY E.EstablishmentName ASC;
END;
