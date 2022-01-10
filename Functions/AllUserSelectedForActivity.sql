-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- select * from dbo.AllUserSelectedForActivity(1615,2527)
-- =============================================
CREATE FUNCTION [dbo].[AllUserSelectedForActivity]
    (
      @AppUserId BIGINT ,
      @ActivityId BIGINT 
    )
RETURNS @rtnTable TABLE
    (
      ActivityId BIGINT ,
      UserId BIGINT
    )
AS
    BEGIN
        DECLARE @Count BIGINT = 0;
        DECLARE @IsManager BIT;
        
        SELECT  @IsManager = IsAreaManager
        FROM    dbo.AppUser
        WHERE   Id = @AppUserId;

		
        IF EXISTS ( SELECT  1
                    FROM    dbo.AppUserEstablishment
                            INNER JOIN dbo.AppUser ON AppUser.Id = AppUserEstablishment.AppUserId
                            INNER JOIN dbo.Vw_Establishment AS E ON E.Id = AppUserEstablishment.EstablishmentId
                                                              AND E.EstablishmentGroupId = @ActivityId
                    WHERE   dbo.AppUserEstablishment.IsDeleted = 0
                            AND ( IsAreaManager = 0
                                  OR AppUserId = @AppUserId
                                )
                            AND IsActive = 1 )
            BEGIN
                SET @Count = 1;
            END;


        IF @Count = 0
            BEGIN
                IF EXISTS ( SELECT  1
                            FROM    AppManagerUserRights
                                    INNER JOIN dbo.AppUser ON dbo.AppUser.Id = AppManagerUserRights.ManagerUserId
                                                              AND AppManagerUserRights.UserId = @AppUserId
                                    INNER JOIN dbo.Vw_Establishment AS E ON E.Id = AppManagerUserRights.EstablishmentId
                                                              AND E.EstablishmentGroupId = @ActivityId
                                                              AND AppManagerUserRights.IsDeleted = 0
                                                              AND IsActive = 1 )
                    BEGIN
                        SET @Count = 1;
                    END;
            END;


        DECLARE @TempTable TABLE ( UserId BIGINT );
        DECLARE @TempUserTable TABLE ( UserId BIGINT );

        IF ( @IsManager = 1 )
            BEGIN
                IF ( @Count > 0 )
                    BEGIN
                        INSERT  INTO @TempUserTable
                                ( UserId
                                )
                                SELECT  AppUserId
                                FROM    dbo.AppUserEstablishment
                                        INNER JOIN dbo.AppUser ON AppUser.Id = AppUserEstablishment.AppUserId
                                        INNER JOIN dbo.Vw_Establishment AS E ON E.Id = AppUserEstablishment.EstablishmentId
                                                              AND E.EstablishmentGroupId = @ActivityId
                                WHERE   dbo.AppUserEstablishment.IsDeleted = 0
                                        AND ( IsAreaManager = 0
                                              OR AppUserId = @AppUserId
                                            )
                                        AND IsActive = 1
                                UNION
                                SELECT  ManagerUserId
                                FROM    AppManagerUserRights
                                        INNER JOIN dbo.AppUser ON dbo.AppUser.Id = AppManagerUserRights.ManagerUserId
                                                              AND AppManagerUserRights.UserId = @AppUserId
                                        INNER JOIN dbo.Vw_Establishment AS E ON E.Id = AppManagerUserRights.EstablishmentId
                                                              AND E.EstablishmentGroupId = @ActivityId
                                                              AND AppManagerUserRights.IsDeleted = 0
                                                              AND IsActive = 1
                                        INNER JOIN dbo.AppUserEstablishment ON AppManagerUserRights.EstablishmentId = AppUserEstablishment.EstablishmentId
                                GROUP BY ManagerUserId;


                        INSERT  INTO @TempTable
                                ( UserId
                                )
                                SELECT  UserId
                                FROM    @TempUserTable;
                    END;
                ELSE
                    BEGIN
                        INSERT  INTO @TempTable
                                ( UserId
                                )
                                SELECT  U.Id AS UserId
                                FROM    dbo.AppUserEstablishment AS UE
                                        INNER JOIN dbo.AppUser AS LoginUser ON UE.AppUserId = LoginUser.Id
                                                              AND LoginUser.Id = @AppUserId
                                        INNER JOIN dbo.Vw_Establishment AS E ON UE.EstablishmentId = E.Id
                                        --INNER JOIN dbo.EstablishmentGroup AS Eg ON Eg.Id = E.EstablishmentGroupId
                                        INNER JOIN dbo.AppUserEstablishment AS AppUser ON E.Id = AppUser.EstablishmentId
                                                              AND ( UE.EstablishmentType = AppUser.EstablishmentType
                                                              OR LoginUser.IsAreaManager = 1
                                                              )
                                        INNER JOIN dbo.AppUser AS U ON AppUser.AppUserId = U.Id
                                                              AND ( U.IsAreaManager = 0
                                                              OR U.Id = @AppUserId
                                                              )
                                WHERE   E.IsDeleted = 0
                                        AND UE.IsDeleted = 0
                                        AND AppUser.IsDeleted = 0
                                        AND U.IsDeleted = 0;
                    END;
            END;
        ELSE
            BEGIN
                INSERT  INTO @TempTable
                        ( UserId
                        )
                        SELECT  U.Id AS UserId
                        FROM    dbo.AppUserEstablishment AS UE
                                INNER JOIN dbo.AppUser AS LoginUser ON UE.AppUserId = LoginUser.Id
                                                              AND LoginUser.Id = @AppUserId
                                INNER JOIN dbo.Vw_Establishment AS E ON UE.EstablishmentId = E.Id
                                --INNER JOIN dbo.EstablishmentGroup AS Eg ON Eg.Id = E.EstablishmentGroupId
                                INNER JOIN dbo.AppUserEstablishment AS AppUser ON E.Id = AppUser.EstablishmentId
                                                              AND ( UE.EstablishmentType = AppUser.EstablishmentType
                                                              OR LoginUser.IsAreaManager = 1
                                                              )
                                INNER JOIN dbo.AppUser AS U ON AppUser.AppUserId = U.Id
                                                              AND ( U.IsAreaManager = 0
                                                              OR U.Id = @AppUserId
                                                              )
                        WHERE   U.Id = @AppUserId
                                AND E.IsDeleted = 0
                                AND UE.IsDeleted = 0
                                AND AppUser.IsDeleted = 0
                                AND U.IsDeleted = 0;
            END;
    
        INSERT  INTO @rtnTable
                ( ActivityId ,
                  UserId
                )
                SELECT DISTINCT @ActivityId ,
                        UserId
                FROM    @TempTable;
        RETURN;

    END;


