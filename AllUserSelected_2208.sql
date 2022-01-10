-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- select dbo.AllUserSelected_2208(1615,'0',2011)
-- =============================================
CREATE FUNCTION dbo.AllUserSelected_2208
    (
      @AppUserId BIGINT ,
      @EstablishmentId NVARCHAR(MAX) ,
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

		--DECLARE @listStr NVARCHAR(MAX);
		--SELECT  @listStr = COALESCE(@listStr + ', ', '')
		--		+ CONVERT(NVARCHAR(50), ISNULL(dbo.Establishment.Id, ''))
		--FROM dbo.Establishment
		--INNER JOIN dbo.AppUserEstablishment ON AppUserEstablishment.EstablishmentId = Establishment.Id
		--WHERE   EstablishmentGroupId = @ActivityId
		--AND dbo.AppUserEstablishment.AppUserId = @AppUserId;

		--IF (@EstablishmentId = '0' )
		--	BEGIN
		--		SET @EstablishmentId = @listStr
		--	END;

		
        IF EXISTS ( SELECT  1
                    FROM    dbo.AppUserEstablishment
                            INNER JOIN dbo.AppUser ON AppUser.Id = AppUserEstablishment.AppUserId
                            INNER JOIN dbo.Establishment AS E ON E.Id = AppUserEstablishment.EstablishmentId
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
                                    INNER JOIN dbo.Establishment AS E ON E.Id = AppManagerUserRights.EstablishmentId
                                                              AND E.EstablishmentGroupId = @ActivityId
					--INNER JOIN (SELECT Data FROM dbo.Split(@EstablishmentId,',') ) AS E ON E.Data = dbo.AppManagerUserRights.EstablishmentId
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
                                        INNER JOIN dbo.Establishment AS E ON E.Id = AppUserEstablishment.EstablishmentId
                                                              AND E.EstablishmentGroupId = @ActivityId
						--INNER JOIN (SELECT  DATA FROM  dbo.Split(@EstablishmentId,',') ) AS E ON E.Data = dbo.AppUserEstablishment.EstablishmentId
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
                                        INNER JOIN dbo.Establishment AS E ON E.Id = AppManagerUserRights.EstablishmentId
                                                              AND E.EstablishmentGroupId = @ActivityId
						--INNER JOIN (SELECT DATA FROM dbo.Split(@EstablishmentId,',')) AS E ON E.DATA = dbo.AppManagerUserRights.EstablishmentId 
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
                SELECT  @ActivityId ,
                        UserId
                FROM    @TempTable;
        RETURN;
         --DECLARE @listStrFinal NVARCHAR(MAX);
        --BEGIN
        --    SELECT  @listStrFinal = COALESCE(@listStrFinal + ', ', '')
        --            + CONVERT(NVARCHAR(50), ISNULL(UserId, ''))
        --    FROM    @TempTable
        --    GROUP BY UserId
        --    ORDER BY UserId;
        --END;

        --@listStrFinal;
    END;
