-- =============================================
-- Author:		GD
-- Create date: 03 Sep 2015
-- Description:	WSGetAlertAppUserByActivityId 919,'01-01-2017'
-- =============================================
CREATE PROCEDURE [dbo].[WSGetAlertAppUserByActivityId]
    @ActivityId BIGINT ,
    @LastServerDate DATETIME
AS
    BEGIN
        IF EXISTS ( SELECT  1
                    FROM    dbo.AppUserEstablishment AS AUE
                            INNER JOIN dbo.Establishment ON Establishment.Id = AUE.EstablishmentId
                    WHERE   EstablishmentGroupId = @ActivityId
                            AND ISNULL(AUE.DeletedOn,
                                       ISNULL(AUE.UpdatedOn, AUE.CreatedOn)) >= @LastServerDate )
            BEGIN

			SELECT 'EveryOne' AS Name,0 AS UserId,'EveryOne' AS UserName
			UNION ALL
			    SELECT  U.Name ,
                        U.Id AS UserId ,
                        U.UserName
                FROM    dbo.AppUserEstablishment AS AUE
                        INNER JOIN dbo.AppUser AS U ON U.Id = AUE.AppUserId
                        INNER JOIN dbo.Establishment AS E ON E.Id = AUE.EstablishmentId
                        LEFT OUTER JOIN dbo.Supplier AS S ON S.Id = U.SupplierId
                WHERE   E.EstablishmentGroupId = @ActivityId
				--AND ISNULL(AUE.DeletedOn,isnull(AUE.UpdatedOn, AUE.CreatedOn)) >= @LastServerDate
                        AND AUE.IsDeleted = 0
                        AND E.IsDeleted = 0
                        AND U.IsDeleted = 0
                        AND U.IsActive = 1
                GROUP BY U.Name ,
                        U.Id ,
                        U.UserName; 
            END;
			--ELSE
			--BEGIN
			--SELECT   Name ,
   --                     UserId ,
   --                     UserName FROM a
			--END
            
    END;
