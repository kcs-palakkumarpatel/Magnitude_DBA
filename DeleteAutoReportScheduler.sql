﻿-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,, 20 Oct 2015>
-- Description:	<Description,,DeleteAutoReportScheduler>
-- Call SP    :	DeleteAutoReportScheduler
-- =============================================
CREATE PROCEDURE [dbo].[DeleteAutoReportScheduler]
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
                        WHERE   [Id] = @Id;
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
                                  'Delete record in table AutoReportScheduler' ,
                                  'AutoReportScheduler' ,
                                  @Id ,
                                  GETDATE() ,
                                  @DeletedBy ,
                                  0
                                );
                    BEGIN
                SUBSTRING(@Result, 2, LEN(@Result)) AS Name;