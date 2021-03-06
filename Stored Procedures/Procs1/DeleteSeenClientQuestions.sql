-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,, 20 Aug 2015>
-- Description:	<Description,,DeleteSeenClientQuestions>
-- Call SP    :	DeleteSeenClientQuestions
-- =============================================
CREATE PROCEDURE [dbo].[DeleteSeenClientQuestions]
    @IdList NVARCHAR(MAX) ,
    @DeletedBy BIGINT ,
    @PageId BIGINT = 0
AS
    BEGIN        DECLARE @Start INT = 1 ,
            @Total INT ,
            @IsUsed BIT = 0 ,
            @Id BIGINT ,
            @Result NVARCHAR(MAX) = '' ,
            @Count INT = 0;        DECLARE @Tbl TABLE ( Id INT, Data INT );        INSERT  INTO @Tbl
                ( Id ,
                  Data
                )
                SELECT  Id ,
                        Data
                FROM    dbo.Split(@IdList, ',');        SELECT  @Total = COUNT(1)
        FROM    @Tbl;        WHILE @Start <= @Total
            BEGIN                SELECT  @Id = Data
                FROM    @Tbl
                WHERE   Id = @Start;                --EXEC dbo.IsReferenceExists N'SeenClientQuestions', @Id,
                --    @IsUsed OUTPUT;                IF @IsUsed = 0
                    BEGIN                        UPDATE  dbo.[SeenClientQuestions]
                        SET     IsDeleted = 1 ,
                                DeletedBy = @DeletedBy ,
                                DeletedOn = GETUTCDATE()
                        WHERE   [Id] = @Id;                        INSERT  INTO dbo.ActivityLog
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
                                  'Delete record in table SeenClientQuestions' ,
                                  'SeenClientQuestions' ,
                                  @Id ,
                                  GETUTCDATE() ,
                                  @DeletedBy ,
                                  0
                                );                    END;                ELSE
                    BEGIN                        SET @Count += 1;                    END;                SET @Start += 1;            END;        SELECT  ISNULL(@Count, 0) AS TotalReference ,
                SUBSTRING(@Result, 2, LEN(@Result)) AS Name;    END;
