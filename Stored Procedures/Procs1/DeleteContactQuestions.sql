-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,, 15 Jun 2015>
-- Description:	<Description,,DeleteContactQuestions>
-- Call SP    :	DeleteContactQuestions
-- =============================================
CREATE PROCEDURE [dbo].[DeleteContactQuestions]
    @IdList NVARCHAR(MAX) ,
    @DeletedBy BIGINT ,
    @PageId BIGINT
AS
    BEGIN
        DECLARE @Start INT = 1 ,
            @Total INT ,
            @IsUsed BIT = 0 ,
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
                --EXEC dbo.IsReferenceExists N'ContactQuestions', @Id,
                --    @IsUsed OUTPUT
                IF @IsUsed = 0
                    BEGIN
                        UPDATE  dbo.[ContactQuestions]
                        SET     IsDeleted = 1 ,
                                DeletedBy = @DeletedBy ,
                                DeletedOn = GETUTCDATE()
                        WHERE   [Id] = @Id;

                        UPDATE  dbo.ContactOptions
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @DeletedBy
                        WHERE   ContactQuestionId = @Id
                                AND IsDeleted = 0;

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
                                  'Delete record in table ContactQuestions' ,
                                  'ContactQuestions' ,
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