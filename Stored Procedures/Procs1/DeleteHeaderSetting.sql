-- =============================================
-- Author:		<Author,,ADMIN>
-- Create date: <Create Date,, 16 Dec 2016>
-- Description:	<Description,,DeleteHeaderSetting>
-- Call SP    :	DeleteHeaderSetting
-- =============================================
CREATE PROCEDURE [dbo].[DeleteHeaderSetting]
    @IdList NVARCHAR(MAX) ,
    @DeletedBy BIGINT ,
    @PageId BIGINT
AS
    BEGIN        DECLARE @Start INT = 1 ,
            @Total INT ,
            @IsUsed BIT ,
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
                WHERE   Id = @Start;                EXEC dbo.IsReferenceExists N'HeaderSetting', @Id,
                    @IsUsed OUTPUT;                IF @IsUsed = 0
                    BEGIN                        UPDATE  dbo.[HeaderSetting]
                        SET     IsDeleted = 1 ,
                                DeletedBy = @DeletedBy ,
                                DeletedOn = GETDATE()
                        WHERE   [HeaderSettingId] = @Id;                        INSERT  INTO dbo.ActivityLog
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
                                  'Delete record in table HeaderSetting' ,
                                  'HeaderSetting' ,
                                  @Id ,
                                  GETDATE() ,
                                  @DeletedBy ,
                                  0
                                );                    END;                ELSE
                    BEGIN                        SET @Count += 1;                    END;                SET @Start += 1;            END;        SELECT  ISNULL(@Count, 0) AS TotalReference ,
                SUBSTRING(@Result, 2, LEN(@Result)) AS Name;    END;