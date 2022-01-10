-- =============================================
-- Author:			Sunil Vaghasiya
-- Create date:	10-May-2017
-- Description:	<Delete contacts>
-- Call SP    :	DeleteContactMaster '566070' , 20119, 29
-- =============================================
CREATE PROCEDURE dbo.DeleteContactMaster
    @IdList NVARCHAR(MAX) ,
    @DeletedBy BIGINT ,
    @PageId BIGINT
AS
    BEGIN
        DECLARE @Start INT = 1 ,
            @Total INT ,
            @IsUsed BIT ,
            @Id BIGINT ,
            @Result NVARCHAR(MAX) = '' ,
            @Count INT = 0;
        DECLARE @Tbl TABLE ( Id INT, Data INT );
        INSERT  INTO @Tbl
                ( Id ,
                  Data 
                )
                SELECT  Id ,
                        Data
                FROM    dbo.Split(@IdList, ',');
        SELECT  @Total = COUNT(1)
        FROM    @Tbl;
        WHILE @Start <= @Total
            BEGIN
                SELECT  @Id = Data
                FROM    @Tbl
                WHERE   Id = @Start;
                EXEC dbo.IsReferenceExists N'ContactMaster', @Id,
                    @IsUsed OUTPUT;

                IF ( SELECT COUNT(1)
                     FROM   dbo.SeenClientAnswerMaster
                     WHERE  ContactMasterId IN ( @Id ) AND IsDeleted = 0
                   ) > 0
                    --OR ( SELECT COUNT(1)
                    --     FROM   dbo.AnswerMaster
                    --     WHERE  SeenClientAnswerMasterId IN ( @Id ) AND IsDeleted = 0
                    --   ) > 0
                    BEGIN
                        SET @IsUsed = 1;
                    END
				ELSE IF (SELECT COUNT(1)
						 FROM dbo.ContactGroupRelation
						 WHERE ContactMasterId IN (@Id) AND IsDeleted = 0) > 0
					BEGIN
						SET @IsUsed = 1;
					END 

                IF @IsUsed = 0
                    BEGIN
                        UPDATE  dbo.[ContactDetails]
                        SET     IsDeleted = 1 ,
                                DeletedBy = @DeletedBy ,
                                DeletedOn = GETUTCDATE()
                        WHERE   [ContactMasterId] = @Id;

                        UPDATE  dbo.[ContactMaster]
                        SET     IsDeleted = 1 ,
                                DeletedBy = @DeletedBy ,
                                DeletedOn = GETUTCDATE()
                        WHERE   [Id] = @Id;
                        INSERT  INTO dbo.ActivityLog
                                ( UserId ,
                                  PageId ,
                                  AuditComments ,
                                  TableName ,
                                  RecordId ,
                                  CreatedOn ,
                                  CreatedBy ,
                                  IsDeleted 
                                )
                        VALUES  ( @DeletedBy ,
                                  @PageId ,
                                  'Delete record in table ContactMaster' ,
                                  'ContactMaster' ,
                                  @Id ,
                                  GETUTCDATE() ,
                                  @DeletedBy ,
                                  0
                                );
                    END;
                ELSE
                    BEGIN
                        SET @Count += 1;
                    END;
                SET @Start += 1;
            END;
        SELECT  ISNULL(@Count, 0) AS TotalReference ,
                SUBSTRING(@Result, 2, LEN(@Result)) AS Name;
    END;
