
-- =============================================
-- Author:			Developer D3
-- Create date:	29-09-2016
-- Description:	Get Contact Answers Table for Web API Using AnswerMasterId
-- Call:					dbo.APIInsertOrUpdateContactAnswersByAnswerMasterId 293
-- =============================================
CREATE PROCEDURE [dbo].[APIInsertOrUpdateContactAnswersByAnswerMasterId]
    (
      @MerchantKey BIGINT = 0 ,
      @ContactMasterId BIGINT = 0 ,
      @ContactQuestionId BIGINT = 0 ,
      @QuestionTypeId BIGINT = 0 ,
      @Answer NVARCHAR(2000) = NULL ,
      @AppUserId BIGINT = 0
	)
AS
    BEGIN
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
        DECLARE @Id BIGINT = 0 ,
            @PageId BIGINT= 0;

        SELECT  @Id = Id
        FROM    dbo.ContactDetails
        WHERE   ContactMasterId = @ContactMasterId
                AND ContactQuestionId = @ContactQuestionId
                AND IsDeleted = 0;

        DECLARE @OptionId NVARCHAR(500);
        IF ( @QuestionTypeId = 5
             OR @QuestionTypeId = 6
             OR @QuestionTypeId = 18
             OR @QuestionTypeId = 21
           )
            AND @Answer <> ''
            BEGIN
                SELECT  @OptionId = COALESCE(@OptionId + ',', '')
                        + CONVERT(NVARCHAR(50), Id)
                FROM    dbo.ContactOptions
                WHERE   Name IN ( SELECT  DISTINCT
                                            Data
                                  FROM      dbo.Split(@Answer, ',') )
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
                          @Answer , -- Detail - nchar(10)
                          @AppUserId  -- CreatedBy - bigint
				        );
                SELECT  @Id = SCOPE_IDENTITY();
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
                        Detail = @Answer ,
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
        SELECT  ISNULL(@Id, 0) AS InsertedId; 
		END TRY

		BEGIN CATCH
			INSERT INTO dbo.ErrorLog
				(
					PageId,
					MethodName,
					ErrorType,
					ErrorMessage,
					ErrorDetails,
					ErrorDate,
					UserId,
					Solution,
					CreatedOn,
					CreatedBy
				)
				VALUES
				(ERROR_LINE(),
				 'dbo.APIInsertOrUpdateContactAnswersByAnswerMasterId',
				 N'DATABASE',
				 ERROR_MESSAGE(),
				 ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
				  + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
				 )  ,
				 GETUTCDATE(),
				 ISNULL(@AppUserId,0),
				 @MerchantKey+','+
				 @ContactMasterId+','+
				 @ContactQuestionId+','+
				 @QuestionTypeId+','+
				 @Answer+','+
				 @AppUserId,
				 GETUTCDATE(),
				 ISNULL(@AppUserId,0)
				);
		END CATCH

    END;
