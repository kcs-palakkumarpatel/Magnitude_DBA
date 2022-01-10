﻿-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,, 12 Aug 2015>
-- Description:	<Description,,DeleteContact>
-- Call SP    :	DeleteContact
-- =============================================
CREATE PROCEDURE DeleteContact
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
                                  'Delete record in table Contact' ,
                                  'Contact' ,
                                  @Id ,
                                  GETUTCDATE() ,
                                  @DeletedBy ,
                                  0
                                );
                    BEGIN
                SUBSTRING(@Result, 2, LEN(@Result)) AS Name;