-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,12 Jun 2015>
-- Description:	<Description,,>
-- Call SP:		WSGetActivityEstablishmetnAndEstablishmentUserByAppUserIdBySearch 313, 919,1,null,true,false
-- =============================================
CREATE PROCEDURE [dbo].[WSGetActivityEstablishmetnAndEstablishmentUserByAppUserIdBySearch]
    @AppUserId BIGINT ,
    @ActivityId BIGINT ,
    @Page BIGINT ,
    @Search NVARCHAR(MAX) ,
    @IsTransfer bit ,
    @IsCapture bit
AS
    BEGIN

        DECLARE @Start AS INT ,
            @End INT ,
            @Total INT ,
            @Rows INT = 50;

        SET @Start = ( ( @Page - 1 ) * @Rows ) + 1;
        SET @End = @Start + @Rows;



        DECLARE @TempTable TABLE
            (
              Rownum BIGINT IDENTITY(1, 1) ,
              EstablishmentId BIGINT ,
              EstablishmentName NVARCHAR(MAX) ,
              SendSeenClientSMS BIT ,
              SendSeenClientEmail BIT ,
              Total INT,
			  EstablishmentType NVARCHAR(20),
			  DefaultContactId BIGINT,
			  IsGroup BIT              
            );

        IF ( @IsTransfer = 0 AND @IsCapture = 0 )
		   
            BEGIN
                INSERT  INTO @TempTable
                        ( EstablishmentId ,
                          EstablishmentName ,
                          SendSeenClientSMS ,
                          SendSeenClientEmail ,
                          Total,
						  EstablishmentType,
						  DefaultContactId,
						  IsGroup
	                    )
                        SELECT  E.Id AS EstablishmentId ,
                                EstablishmentName ,
                                ISNULL(Eg.SMSReminder, 0) AS SendSeenClientSMS ,
                                ISNULL(Eg.SMSReminder, 0) AS SendSeenClientEmail ,
                                COUNT(*) OVER ( PARTITION BY 1 ) AS Total,
								UE.EstablishmentType,
								ISNULL(DC.ContactId,0) AS DefaultContactId,
								ISNULL(DC.IsGroup,'false') AS IsGroup
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
								LEFT JOIN dbo.DefaultContact AS DC WITH(NOLOCK) ON  ISNULL(DC.EstablishmentId,0) = E.Id AND ISNULL(DC.AppUserId,0) = @AppUserId AND DC.IsDeleted = 0
                        WHERE   UE.AppUserId = @AppUserId
                                AND E.IsDeleted = 0
                                AND UE.IsDeleted = 0
								AND LoginUser.IsActive = 1
                                AND AppUser.IsDeleted = 0
                                AND U.IsDeleted = 0
                                AND E.EstablishmentGroupId = @ActivityId
                                AND E.EstablishmentName LIKE '%' + ISNULL(@Search,'')
                                + '%'
                        GROUP BY E.Id ,
                                EstablishmentName ,
                                Eg.SMSReminder ,
                                Eg.SMSReminder,
								UE.EstablishmentType,
								DC.ContactId,
								DC.IsGroup
						ORDER BY E.EstablishmentName;
            END;
        ELSE
            IF ( @IsTransfer = 1 )
                BEGIN
                                   INSERT  INTO @TempTable
                        ( EstablishmentId ,
                          EstablishmentName ,
                          SendSeenClientSMS ,
                          SendSeenClientEmail ,
                          Total,
						  EstablishmentType,
						  DefaultContactId,
						  IsGroup
	                    )
                        SELECT  E.Id AS EstablishmentId ,
                                EstablishmentName ,
                                ISNULL(Eg.SMSReminder, 0) AS SendSeenClientSMS ,
                                ISNULL(Eg.SMSReminder, 0) AS SendSeenClientEmail ,
                                COUNT(*) OVER ( PARTITION BY 1 ) AS Total,
								UE.EstablishmentType,
								ISNULL(DC.ContactId,0) AS DefaultContactId,
								ISNULL(DC.IsGroup,'false') AS IsGroup
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
								LEFT JOIN dbo.DefaultContact AS DC WITH(NOLOCK) ON  ISNULL(DC.EstablishmentId,0) = E.Id AND ISNULL(DC.AppUserId,0) = @AppUserId AND DC.IsDeleted = 0
                        WHERE   UE.AppUserId = @AppUserId
                                AND E.IsDeleted = 0
                                AND UE.IsDeleted = 0
                                AND AppUser.IsDeleted = 0
                                AND U.IsDeleted = 0
                                AND E.EstablishmentGroupId = @ActivityId
                                AND E.EstablishmentName LIKE '%' + ISNULL(@Search,'')
                                + '%'
                        GROUP BY E.Id ,
                                EstablishmentName ,
                                Eg.SMSReminder ,
                                Eg.SMSReminder,
								UE.EstablishmentType,
								DC.ContactId,
								DC.IsGroup
						ORDER BY E.EstablishmentName;
									
                END;
        IF ( @IsCapture = 1 )
            BEGIN
                INSERT  INTO @TempTable
                        ( EstablishmentId ,
                          EstablishmentName ,
                          SendSeenClientSMS ,
                          SendSeenClientEmail ,
                          Total,
						  EstablishmentType,
						  DefaultContactId,
						  IsGroup
	                    )
                        SELECT  E.Id AS EstablishmentId ,
                                EstablishmentName ,
                                ISNULL(Eg.SMSReminder, 0) AS SendSeenClientSMS ,
                                ISNULL(Eg.SMSReminder, 0) AS SendSeenClientEmail ,
                                COUNT(*) OVER ( PARTITION BY 1 ) AS Total,
								UE.EstablishmentType,
								ISNULL(DC.ContactId,0) AS DefaultContactId,
								ISNULL(DC.IsGroup,'false') AS IsGroup
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
								LEFT JOIN dbo.DefaultContact AS DC WITH(NOLOCK) ON  ISNULL(DC.EstablishmentId,0) = E.Id AND ISNULL(DC.AppUserId,0) = @AppUserId AND DC.IsDeleted = 0
                        WHERE   UE.AppUserId = @AppUserId
                                AND E.IsDeleted = 0
                                AND UE.IsDeleted = 0
								AND AppUser.IsDeleted = 0
                                AND U.IsDeleted = 0
                                AND E.EstablishmentGroupId = @ActivityId
                                AND UE.EstablishmentType = 'Sales'
                                AND E.EstablishmentName LIKE '%' + ISNULL(@Search,'')
                                + '%'
                        GROUP BY E.Id ,
                                EstablishmentName ,
                                Eg.SMSReminder ,
                                Eg.SMSReminder ,
								UE.EstablishmentType,
								DC.ContactId,
								DC.IsGroup
								ORDER BY E.EstablishmentName;
            END;
        SELECT  EstablishmentId ,
                EstablishmentName ,
                SendSeenClientSMS ,
                SendSeenClientEmail ,
                CASE Total / @Rows
                  WHEN 0 THEN 1
                  ELSE ( Total / @Rows ) + 1
                END AS Total,
				EstablishmentType,
				DefaultContactId,
				IsGroup
        FROM    @TempTable
        WHERE   Rownum >= CONVERT(NVARCHAR(50), @Start)
                AND Rownum < CONVERT(NVARCHAR(50), @End); 
    END;
