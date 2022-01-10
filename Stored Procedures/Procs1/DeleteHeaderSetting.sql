﻿-- =============================================
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
    BEGIN
            @Total INT ,
            @IsUsed BIT ,
            @Id BIGINT ,
            @Result NVARCHAR(MAX) = '' ,
            @Count INT = 0;
                ( Id ,
                  Data
                )
                SELECT  Id ,
                        Data
                FROM    dbo.Split(@IdList, ',');
        FROM    @Tbl;
            BEGIN
                FROM    @Tbl
                WHERE   Id = @Start;
                    @IsUsed OUTPUT;
                    BEGIN
                        SET     IsDeleted = 1 ,
                                DeletedBy = @DeletedBy ,
                                DeletedOn = GETDATE()
                        WHERE   [HeaderSettingId] = @Id;
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
                                );
                    BEGIN
                SUBSTRING(@Result, 2, LEN(@Result)) AS Name;