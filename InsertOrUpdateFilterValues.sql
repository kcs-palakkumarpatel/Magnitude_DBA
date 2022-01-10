-- =============================================
-- Author:		<Author,,Name-Anant>
-- Create date: <Create Date,30-04-2018,>
-- Description:	<Description,,filter Values store in data table>
-- call Sp: InsertOrUpdateFilterValues 1,314,1,919,'13410','1','2018-03-30 00:00:00','2018-04-30 00:00:00','15174~1~anant~true|15175~1~anant.bhatt@kcspl.co.in~true','Unresolved','Read',0,0,0,1
-- =============================================
CREATE PROCEDURE [dbo].[InsertOrUpdateFilterValues]
    @Id BIGINT ,
    @UserId BIGINT ,
    @FilterType INT ,
    @ActivityId BIGINT ,
    @EstablishmentId VARCHAR(MAX) ,
    @SelectedUserId VARCHAR(MAX) ,
    @FromDate DATETIME ,
    @ToDate DATETIME ,
    @FromQuestion VARCHAR(MAX) ,
    @Status VARCHAR(50) ,
    @ReadUnread VARCHAR(50) ,
    @CreatedBy BIGINT ,
    @UpdatedBy BIGINT ,
    @DeletedBy BIGINT ,
    @inOutSwitch BIT
AS
    BEGIN
        SET @Id = ( SELECT Id
                    FROM    dbo.FilterValues
                    WHERE   UserId = @UserId
                            AND ActivityId = @ActivityId
                            AND FilterType = @FilterType
                            AND inOutSwitch = @inOutSwitch
                  );

        IF ( @Id IS NULL )
            BEGIN
                    BEGIN
                        INSERT  INTO dbo.FilterValues
                                ( UserId ,
                                  ActivityId ,
                                  FilterType ,
                                  EstablishmentId ,
                                  SelectedUserId ,
                                  FromDate ,
                                  ToDate ,
                                  FromQuestion ,
                                  Status ,
                                  ReadUnread ,
                                  CreatedBy ,
                                  UpdatedBy ,
                                  CreatedOn ,
                                  UpdatedOn ,
                                  IsDeleted ,
                                  DeletedBy ,
                                  inOutSwitch
			                    )
                        VALUES  ( @UserId , -- UserId - bigint
                                  @ActivityId , -- ActivityId - bigint
                                  @FilterType , -- FilterType - int
                                  @EstablishmentId , -- EstablishmentId - nvarchar(500)
                                  @SelectedUserId , -- SelectedUserId - nvarchar(500)
                                  @FromDate , -- FromDate - datetime
                                  @ToDate , -- ToDate - datetime
                                  @FromQuestion , -- FromQuestion - varchar(max)
                                  @Status , -- Status - varchar(50)
                                  @ReadUnread , -- ReadUnread -  varchar(50)
                                  @UserId , -- CreatedBy - bigint
                                  0 , -- UpdatedBy - bigint
                                  GETDATE() , -- CreatedOn - datetime
                                  GETDATE() , -- UpdatedOn - datetime
                                  0 , -- IsDeleted - bit
                                  0 ,  -- DeletedBy - bigint
                                  @inOutSwitch
                                );
                        SELECT  @Id = SCOPE_IDENTITY();
                    END;
            END;
        ELSE
            BEGIN
                BEGIN
                    UPDATE  dbo.FilterValues
                    SET     EstablishmentId = @EstablishmentId ,
                            SelectedUserId = @SelectedUserId ,
                            FromDate = @FromDate ,
                            ToDate = @ToDate ,
                            FromQuestion = @FromQuestion ,
                            Status = @Status ,
                            ReadUnread = @ReadUnread ,
                            [UpdatedOn] = GETUTCDATE() ,
                            [UpdatedBy] = @UserId ,
                            IsDeleted = 0 ,
                            DeletedBy = NULL ,
                            inOutSwitch = @inOutSwitch
                    WHERE   [Id] = @Id; 
                    SELECT  @Id = SCOPE_IDENTITY();
                END;
            END;          
    END;
