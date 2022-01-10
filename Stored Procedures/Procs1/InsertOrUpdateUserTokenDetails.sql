-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,07 Jul 2015>
-- Description:	<Description,,>
-- Call SP:		InsertOrUpdateUserTokenDetails
-- =============================================
CREATE PROCEDURE [dbo].[InsertOrUpdateUserTokenDetails]
    @AppUserId BIGINT ,
    @Imeid NVARCHAR(200) ,
    @TokenId NVARCHAR(MAX) ,
    @DeviceTypeId NVARCHAR(10),
	@CurrentAppVersion VARCHAR(5)
AS
    BEGIN
        IF @DeviceTypeId = 'I'
            BEGIN
                IF EXISTS ( SELECT  Id
                            FROM    dbo.UserTokenDetails
                            WHERE   DeviceTypeId = @DeviceTypeId
                                    AND ImeId = @Imeid )
                    BEGIN			
                        ---PRINT 'UPDATED - I';
                        UPDATE  dbo.UserTokenDetails
                        SET     AppUserId = @AppUserId ,
                                TokenId = @TokenId ,
                                UpdatedOn = GETUTCDATE()
                        WHERE   ImeId = @Imeid
                                AND DeviceTypeId = @DeviceTypeId;                   
                    END;             
                ELSE
                    BEGIN
                        IF EXISTS ( SELECT  Id
                                    FROM    dbo.UserTokenDetails
                                    WHERE   TokenId = @TokenId )
                            BEGIN
                             ---   PRINT 'UPDATED - I';
                                UPDATE  dbo.UserTokenDetails
                                SET     AppUserId = @AppUserId ,
                                        ImeId = @Imeid ,
                                        DeviceTypeId = @DeviceTypeId ,
                                        UpdatedOn = GETUTCDATE()
                                WHERE   TokenId = @TokenId;            
                            END;
                        ELSE
                            BEGIN
                             ---   PRINT 'INSERT - I';
                                INSERT  INTO dbo.UserTokenDetails
                                        ( AppUserId ,
                                          ImeId ,
                                          TokenId ,
                                          DeviceTypeId 
                                        )
                                VALUES  ( @AppUserId , -- AppUserId - bigint
                                          @Imeid , -- ImeId - nvarchar(200)
                                          @TokenId , -- TokenId - nvarchar(max)
                                          @DeviceTypeId  -- DeviceTypeId - nvarchar(10)
                                        );
                            END;
                    END;                   
            END;
        ELSE
            BEGIN
            ---    PRINT 'Not iOS';
                IF NOT EXISTS ( SELECT  Id
                                FROM    dbo.UserTokenDetails
                                WHERE   ImeId = @Imeid )
                    BEGIN
                        INSERT  INTO dbo.UserTokenDetails
                                ( AppUserId ,
                                  ImeId ,
                                  TokenId ,
                                  DeviceTypeId,
								  AppVersion
                                )
                        VALUES  ( @AppUserId , -- AppUserId - bigint
                                  @Imeid , -- ImeId - nvarchar(200)
                                  @TokenId , -- TokenId - nvarchar(max)
                                  @DeviceTypeId,  -- DeviceTypeId - nvarchar(10)
								  @CurrentAppVersion -- App Version.
                                );
                    END;
                ELSE
                    BEGIN
                        UPDATE  dbo.UserTokenDetails
                        SET     AppUserId = @AppUserId ,
                                TokenId = @TokenId ,
                                DeviceTypeId = @DeviceTypeId ,
                                UpdatedOn = GETUTCDATE(),
								AppVersion = @CurrentAppVersion
                        WHERE   ImeId = @Imeid;
                    END;                
            END;	
    END;
    RETURN 1;
