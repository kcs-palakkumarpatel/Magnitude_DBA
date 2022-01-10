﻿-- =============================================
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
    BEGIN
            @Total INT ,
            @IsUsed BIT = 0 ,
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
                --    @IsUsed OUTPUT;
                    BEGIN
                        SET     IsDeleted = 1 ,
                                DeletedBy = @DeletedBy ,
                                DeletedOn = GETUTCDATE()
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
                                  'Delete record in table SeenClientQuestions' ,
                                  'SeenClientQuestions' ,
                                  @Id ,
                                  GETUTCDATE() ,
                                  @DeletedBy ,
                                  0
                                );
                    BEGIN
                SUBSTRING(@Result, 2, LEN(@Result)) AS Name;