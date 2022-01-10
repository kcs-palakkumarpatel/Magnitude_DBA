-- =============================================
-- Author:		<Author,bhavik>
-- Create date: <Create Date,,02-04-21>
-- Description:	<Description,,>
-- Call SP:		InsertOrUpdateContactDetails_With_outputparam
-- =============================================
CREATE PROCEDURE [dbo].[InsertOrUpdateContactDetails_With_outputparam]
    @ContactMasterId BIGINT ,
    @ContactQuestionId BIGINT ,
    @QuestionTypeId BIGINT ,
    @Detail NVARCHAR(MAX) ,
    @AppUserId BIGINT ,
    @PageId BIGINT = 0
AS
    BEGIN
        DECLARE @Id BIGINT = 0 
           -- @PageId BIGINT= 0;

        SELECT  @Id = Id
        FROM    dbo.ContactDetails
        WHERE   ContactMasterId = @ContactMasterId
                AND ContactQuestionId = @ContactQuestionId
                AND IsDeleted = 0;

        DECLARE @OptionId NVARCHAR(MAX);
        IF ( @QuestionTypeId = 5
             OR @QuestionTypeId = 6
             OR @QuestionTypeId = 18
             OR @QuestionTypeId = 21
           )
            AND @Detail <> ''
            BEGIN
                SELECT  @OptionId = COALESCE(@OptionId + ',', '')
                        + CONVERT(NVARCHAR(50), Id)
                FROM    dbo.ContactOptions
                WHERE   Name IN ( SELECT  DISTINCT
                                            Data
                                  FROM      dbo.Split(@Detail, ',') )
                        AND ContactQuestionId = @ContactQuestionId
                ORDER BY Position;
               
            END;

        IF @Id = 0
            BEGIN
                INSERT  INTO dbo.ContactDetails
                        ( ContactMasterId ,
                          ContactQuestionId ,
                          ContactOptionId ,
                          QuestionTypeId ,
                          Detail ,
                          CreatedBy
                        )
                VALUES  ( @ContactMasterId , -- ContactMasterId - bigint
                          @ContactQuestionId , -- ContactQuestionId - bigint
                          @OptionId , -- ContactOptionId - nvarchar(max)
                          @QuestionTypeId , -- QuestionTypeId - int
                          @Detail , -- Detail - nchar(10)
                          @AppUserId  -- CreatedBy - bigint
				        );
                --SELECT  @Id = SCOPE_IDENTITY();
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
                VALUES  ( @AppUserId ,
                          @PageId ,
                          'Insert record in table ContactDetails' ,
                          'ContactDetails' ,
                          @Id ,
                          GETUTCDATE() ,
                          @AppUserId ,
                          0
                        );              
            END;
        ELSE
            BEGIN
                UPDATE  dbo.ContactDetails
                SET     ContactOptionId = @OptionId ,
                        Detail = @Detail ,
                        UpdatedBy = @AppUserId ,
                        UpdatedOn = GETUTCDATE()
                WHERE   Id = @Id;
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
                VALUES  ( @AppUserId ,
                          @PageId ,
                          'Update record in table ContactDetails' ,
                          'ContactDetails' ,
                          @Id ,
                          GETUTCDATE() ,
                          @AppUserId ,
                          0
                        );
            END;
       -- SELECT  ISNULL(@Id, 0) AS InsertedId;          
    END;