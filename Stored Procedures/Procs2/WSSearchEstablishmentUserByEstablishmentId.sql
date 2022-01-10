-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- WSSearchEstablishmentUserByEstablishmentId  1247,'0',1941,'',1,1
-- WSSearchEstablishmentUserByEstablishmentId  313,'0',919,'',1,1
-- =============================================
CREATE PROCEDURE [dbo].[WSSearchEstablishmentUserByEstablishmentId]
    @AppUserId BIGINT ,
    @EstablishmentId NVARCHAR(MAX) ,
    @ActivityId BIGINT ,
    @Search NVARCHAR(MAX) ,
    @Page BIGINT,
	@blIsForTransfer BIT
    
AS
    BEGIN
        DECLARE @Count BIGINT = 0;

		DECLARE @IsManager BIT
        
		SELECT @IsManager = IsAreaManager FROM dbo.AppUser WHERE id = @AppUserId

        DECLARE @Start AS INT ,
            @End INT ,
            @Total INT ,
            @Rows INT = 50;

        SET @Start = ( ( @Page - 1 ) * @Rows ) + 1;
        SET @End = @Start + @Rows;

        DECLARE @listStr NVARCHAR(MAX);
        SELECT  @listStr = COALESCE(@listStr + ', ', '')
                + CONVERT(NVARCHAR(50), ISNULL(dbo.Establishment.Id, ''))
        FROM    dbo.Establishment INNER JOIN dbo.AppUserEstablishment ON AppUserEstablishment.EstablishmentId = Establishment.Id
        WHERE   EstablishmentGroupId = @ActivityId AND dbo.AppUserEstablishment.AppUserId = @AppUserId;

        IF ( @EstablishmentId = '0' )
            BEGIN
                SET @EstablishmentId = @listStr;
            END;

        IF EXISTS ( SELECT  dbo.AppUserEstablishment.AppUserId ,
                            Name
                    FROM    dbo.AppUserEstablishment
                            INNER JOIN dbo.AppUser ON AppUser.Id = AppUserEstablishment.AppUserId
                    WHERE   EstablishmentId IN (
                            SELECT  Data
                            FROM    dbo.Split(@EstablishmentId, ',') )
                            AND dbo.AppUserEstablishment.IsDeleted = 0
                            AND ( IsAreaManager = 0
                                  OR AppUserId = CASE @blIsForTransfer WHEN 0 THEN @AppUserId ELSE AppUserId END
                                )
                            AND IsActive = 1
                            AND Name LIKE '%' + ISNULL(@Search, '') + '%'
                    UNION
                    SELECT  ManagerUserId ,
                            Name
                    FROM    AppManagerUserRights
                            INNER JOIN dbo.AppUser ON dbo.AppUser.Id = AppManagerUserRights.ManagerUserId
                                                      AND AppManagerUserRights.UserId = CASE @blIsForTransfer WHEN 0 THEN @AppUserId ELSE AppManagerUserRights.UserId END
                                                      AND dbo.AppManagerUserRights.EstablishmentId IN (
                                                      SELECT  Data
                                                      FROM    dbo.Split(@EstablishmentId,
                                                              ',') )
                                                      AND AppManagerUserRights.IsDeleted = 0
                                                      AND IsActive = 1
                                                      AND Name LIKE '%'
                                                      + ISNULL(@Search, '')
                                                      + '%'
                    GROUP BY ManagerUserId ,
                            Name )
            BEGIN
                SET @Count = 1;
            END;

        DECLARE @TempTable TABLE
            (
              Rownum BIGINT IDENTITY(1, 1) ,
              Name NVARCHAR(100) ,
              UserId BIGINT ,
              UserName NVARCHAR(100) ,
              SupplierId BIGINT ,
              EstablishmentType NVARCHAR(25) ,
              SupplierName NVARCHAR(100) ,
              EstablishmentId BIGINT,
			  Total BIGINT
            );

		 DECLARE @TempUserTable TABLE
            (
              Rownum BIGINT IDENTITY(1, 1) ,
              Name NVARCHAR(100) ,
              UserId BIGINT ,
              UserName NVARCHAR(100) ,
              SupplierId BIGINT ,
              EstablishmentType NVARCHAR(25) ,
              SupplierName NVARCHAR(100) ,
              EstablishmentId BIGINT
            );

        IF ( @IsManager = 1 )
            BEGIN
                IF ( @Count > 0 )
                    BEGIN
                        INSERT  INTO @TempUserTable
                                ( Name ,
                                  UserId ,
                                  UserName ,
                                  SupplierId ,
                                  EstablishmentType ,
                                  SupplierName 
                                  --,EstablishmentId
	                            )
                                SELECT  Name ,
                                        AppUserId ,
                                        UserName ,
                                        0 ,
                                        EstablishmentType ,
                                        '' 
                                       --, AppUserEstablishment.EstablishmentId
                                FROM    dbo.AppUserEstablishment
                                        INNER JOIN dbo.AppUser ON AppUser.Id = AppUserEstablishment.AppUserId
                                WHERE   EstablishmentId IN (
                                        SELECT  Data
                                        FROM    dbo.Split(@EstablishmentId,
                                                          ',') )
                                        AND dbo.AppUserEstablishment.IsDeleted = 0
                                        --AND ( IsAreaManager = 0
                                        --      OR AppUserId = CASE @blIsForTransfer WHEN 0 THEN @AppUserId ELSE AppUserId END
                                        --    )
										AND IsAreaManager = 0
                                              and AppUserId = CASE @blIsForTransfer WHEN 0 THEN @AppUserId ELSE AppUserId END
                                        AND IsActive = 1
										AND Appuser.isDeleted = 0
                                        AND Name LIKE '%' + ISNULL(@Search, '')
                                        + '%'
                                UNION                                 
                                SELECT  Name + ' [Manager]' ,
                                        ManagerUserId ,
                                        UserName + ' [Manager]' ,
                                        0 ,
                                        EstablishmentType ,
                                        '' 
                                        --, AppUserEstablishment.EstablishmentId
                                FROM    AppManagerUserRights
                                        INNER JOIN dbo.AppUser ON dbo.AppUser.Id = AppManagerUserRights.ManagerUserId
                                                              AND AppManagerUserRights.UserId = CASE @blIsForTransfer WHEN 0 THEN @AppUserId ELSE AppManagerUserRights.UserId END
                                                              AND dbo.AppManagerUserRights.EstablishmentId IN (
                                                              SELECT
                                                              Data
                                                              FROM
                                                              dbo.Split(@EstablishmentId,
                                                              ',') )
                                                              AND AppManagerUserRights.IsDeleted = 0
                                                              AND IsActive = 1
                                        INNER JOIN dbo.AppUserEstablishment ON AppManagerUserRights.EstablishmentId = AppUserEstablishment.EstablishmentId
                                                              AND Name LIKE '%'
                                                              + ISNULL(@Search,
                                   '') + '%'
                                GROUP BY ManagerUserId ,
                                        Name ,
                                        EstablishmentType ,
										UserName
                                        --AppUserEstablishment.EstablishmentId;


										INSERT INTO @TempTable
										        ( Name ,
										          UserId ,
										          UserName ,
										          SupplierId ,
										          EstablishmentType ,
										          SupplierName ,
										        --  EstablishmentId ,
										          Total
										        )
										SELECT Name ,
										          UserId ,
										          UserName ,
										          SupplierId ,
										          EstablishmentType ,
										          SupplierName ,
										         -- EstablishmentId ,
										          COUNT(*) OVER ( PARTITION BY 1 ) AS Total
								FROM @TempUserTable
                    END;
                ELSE
                    BEGIN
                        INSERT  INTO @TempTable
                                ( Name ,
                                  UserId ,
                                  UserName ,
                                  SupplierId ,
                                  EstablishmentType ,
                                  SupplierName ,
                                  --EstablishmentId,
								  Total
	                            )
                                SELECT  U.Name ,
                                        U.Id AS UserId ,
                                        U.UserName ,
                                        CASE AppUser.EstablishmentType
                                          WHEN 'supplier' THEN U.SupplierId
                                          ELSE 0
                                        END AS SupplierId ,
                                        AppUser.EstablishmentType ,
                                        CASE AppUser.EstablishmentType
                                          WHEN 'supplier' THEN S.SupplierName
                                          ELSE ''
                                        END AS SupplierName ,
                                       -- E.Id AS EstablishmentId,
										COUNT(*) OVER ( PARTITION BY 1 ) AS Total
                                FROM    dbo.AppUserEstablishment AS UE
                                        INNER JOIN dbo.AppUser AS LoginUser ON UE.AppUserId = LoginUser.Id
                                                              AND LoginUser.Id = CASE @blIsForTransfer WHEN 0 THEN @AppUserId ELSE LoginUser.Id  END
                                        INNER JOIN dbo.Establishment AS E ON UE.EstablishmentId = E.Id
                                        INNER JOIN dbo.EstablishmentGroup AS Eg ON Eg.Id = E.EstablishmentGroupId
                                        INNER JOIN dbo.AppUserEstablishment AS AppUser ON E.Id = AppUser.EstablishmentId
                                                              AND ( UE.EstablishmentType = AppUser.EstablishmentType
                                                              OR LoginUser.IsAreaManager = 1
                                                              )
                                        INNER JOIN dbo.AppUser AS U ON AppUser.AppUserId = U.Id
                                                              AND ( U.IsAreaManager = 0
                                                              OR U.Id = CASE @blIsForTransfer WHEN 0 THEN @AppUserId ELSE U.Id  END
                                                              )
                                        LEFT JOIN dbo.Supplier AS S ON U.SupplierId = S.Id
                                WHERE   E.IsDeleted = 0
                                        AND UE.IsDeleted = 0
                                        AND AppUser.IsDeleted = 0
            AND U.IsDeleted = 0
                                        AND E.Id IN (
                                        SELECT  Data
                                        FROM    dbo.Split(@EstablishmentId,
                                                          ',') )
                                        AND U.Name LIKE '%' + ISNULL(@Search,
                                                              '') + '%';
                    END;
            END;
        ELSE
            BEGIN
                INSERT  INTO @TempTable
                        ( Name ,
                          UserId ,
                          UserName ,
                          SupplierId ,
                          EstablishmentType ,
                          SupplierName ,
                          --EstablishmentId,
						  Total
	                    )
                        SELECT  U.Name ,
                                U.Id AS UserId ,
                                U.UserName ,
                                CASE AppUser.EstablishmentType
                                  WHEN 'supplier' THEN U.SupplierId
                                  ELSE 0
                                END AS SupplierId ,
                                AppUser.EstablishmentType ,
                                CASE AppUser.EstablishmentType
                                  WHEN 'supplier' THEN S.SupplierName
                                  ELSE ''
                                END AS SupplierName ,
                           --     E.Id AS EstablishmentId,
								 COUNT(*) OVER ( PARTITION BY 1 ) AS Total
                        FROM    dbo.AppUserEstablishment AS UE
                                INNER JOIN dbo.AppUser AS LoginUser ON UE.AppUserId = LoginUser.Id
                                                              AND LoginUser.Id = CASE @blIsForTransfer WHEN 0 THEN @AppUserId ELSE LoginUser.Id  END
                                INNER JOIN dbo.Establishment AS E ON UE.EstablishmentId = E.Id
                                INNER JOIN dbo.EstablishmentGroup AS Eg ON Eg.Id = E.EstablishmentGroupId
                                INNER JOIN dbo.AppUserEstablishment AS AppUser ON E.Id = AppUser.EstablishmentId
                                                              AND ( UE.EstablishmentType = AppUser.EstablishmentType
                                                              OR LoginUser.IsAreaManager = 1
                                                              )
                                INNER JOIN dbo.AppUser AS U ON AppUser.AppUserId = U.Id
                                                              AND ( U.IsAreaManager = 0
                                                              OR U.Id = CASE @blIsForTransfer WHEN 0 THEN @AppUserId ELSE U.Id  END
                                                              )
                                LEFT JOIN dbo.Supplier AS S ON U.SupplierId = S.Id
                        WHERE   U.Id = CASE @blIsForTransfer WHEN 0 THEN @AppUserId ELSE U.Id  END
                                AND E.IsDeleted = 0
                                AND UE.IsDeleted = 0
                                AND AppUser.IsDeleted = 0
                                AND U.IsDeleted = 0
                                AND E.Id IN (
                                SELECT  Data
                                FROM    dbo.Split(@EstablishmentId, ',') )
                                AND U.Name LIKE '%' + ISNULL(@Search, '')
                                + '%';
            END;
    
	IF(@blIsForTransfer = 0)
	BEGIN
	        SELECT  Name ,
                UserId ,
                UserName ,
                SupplierId ,
                EstablishmentType ,
                --SupplierName ,
                --EstablishmentId,
				CASE Total / @Rows
                WHEN 0 THEN 1
                ELSE ( Total / @Rows ) + 1
                END AS Total
        FROM    @TempTable
        WHERE   Rownum >= CONVERT(NVARCHAR(50), @Start)
                AND Rownum < CONVERT(NVARCHAR(50), @End)
				GROUP BY Name ,
                UserId ,
                UserName ,
                SupplierId ,
                EstablishmentType,
				Total
				ORDER BY UserName;
		END
           ELSE
		   BEGIN     
		   	        SELECT  Name ,
                UserId ,
                UserName ,
                SupplierId ,
                '' as EstablishmentType ,
                --SupplierName ,
                --EstablishmentId,
				CASE Total / @Rows
                WHEN 0 THEN 1
                ELSE ( Total / @Rows ) + 1
                END AS Total
        FROM    @TempTable
        WHERE   Rownum >= CONVERT(NVARCHAR(50), @Start)
                AND Rownum < CONVERT(NVARCHAR(50), @End)
				GROUP BY Name ,
                UserId ,
                UserName ,
                SupplierId ,
                --EstablishmentType,
				Total
				ORDER BY UserName;
		END
   END;