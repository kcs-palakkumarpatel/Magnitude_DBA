-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,12 Jun 2015>
-- Description:	<Description,,>
-- Call SP:		WSGetActivityEstablishmetnAndEstablishmentUserByAppUserId 4177, 1941
-- =============================================
CREATE PROCEDURE [dbo].[WSGetActivityEstablishmetnAndEstablishmentUserByAppUserIdForDropDown]
    @AppUserId BIGINT ,
    @ActivityId BIGINT
AS
    BEGIN
        SELECT  E.Id AS EstablishmentId ,
                EstablishmentName 
        FROM    dbo.AppUserEstablishment AS UE
                INNER JOIN dbo.AppUser AS LoginUser ON UE.AppUserId = LoginUser.Id
                                                       AND LoginUser.Id = @AppUserId
                INNER JOIN dbo.Establishment AS E ON UE.EstablishmentId = E.Id
                INNER JOIN dbo.EstablishmentGroup AS Eg ON Eg.Id = E.EstablishmentGroupId
                INNER JOIN dbo.AppUserEstablishment AS AppUser ON E.Id = AppUser.EstablishmentId
                                                              AND ( UE.EstablishmentType = AppUser.EstablishmentType
                                                              OR LoginUser.IsAreaManager = 1
                                                              )
                INNER JOIN dbo.AppUser AS U ON AppUser.AppUserId = U.Id
                                               AND ( U.IsAreaManager = 0
                                                     OR U.Id = @AppUserId
                                                   )
                LEFT JOIN dbo.Supplier AS S ON U.SupplierId = S.Id
        WHERE   UE.AppUserId = @AppUserId
                AND E.IsDeleted = 0
                AND UE.IsDeleted = 0
                AND AppUser.IsDeleted = 0
				AND LoginUser.IsActive = 1
				AND U.IsDeleted = 0
                AND E.EstablishmentGroupId = @ActivityId
	GROUP BY
				E.Id,
                EstablishmentName  
    END