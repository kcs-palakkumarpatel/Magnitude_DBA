-- =============================================
-- Author:		GD
-- Create date: 03 Sep 2015
-- Description:	WSGetAppUserByActivityId 2301
-- =============================================
CREATE PROCEDURE dbo.WSGetAppUserByActivityId @ActivityId BIGINT
AS
    BEGIN
        SELECT  U.Name ,
                U.Id AS UserId ,
                U.UserName ,
                ISNULL(U.SupplierId, 0) AS SupplierId ,
                AUE.EstablishmentType ,
                ISNULL(S.SupplierName, '') AS SupplierName ,
                AUE.EstablishmentId ,
                E.EstablishmentName
        FROM    dbo.AppUserEstablishment AS AUE
                INNER JOIN dbo.AppUser AS U ON U.Id = AUE.AppUserId
                INNER JOIN dbo.Establishment AS E ON E.Id = AUE.EstablishmentId
                LEFT OUTER JOIN dbo.Supplier AS S ON S.Id = U.SupplierId
        WHERE   E.EstablishmentGroupId = @ActivityId
                AND AUE.IsDeleted = 0
                AND E.IsDeleted = 0
                AND U.IsDeleted = 0
				AND U.IsActive = 1
        GROUP BY U.Name ,
                U.Id ,
                U.UserName ,
                U.SupplierId ,
                AUE.EstablishmentType ,
                S.SupplierName ,
                AUE.EstablishmentId ,
                E.EstablishmentName;
    END;
