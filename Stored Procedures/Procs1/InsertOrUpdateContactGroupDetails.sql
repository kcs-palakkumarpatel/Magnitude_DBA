-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,, 20 Jul 2015>
-- Description:	<Description,,InsertOrUpdateContactGroupDetails>
-- Call SP    :	InsertOrUpdateContactGroupDetails
-- =============================================
CREATE PROCEDURE [dbo].[InsertOrUpdateContactGroupDetails]
    @ContactGroupId BIGINT ,
    @ContactQuestionId BIGINT ,
    @QuestionTypeId INT ,
    @Detail NVARCHAR(MAX) ,
    @UserId BIGINT ,
    @PageId BIGINT
AS 
    BEGIN        DECLARE @Id BIGINT = 0 ,
            @ContactOptionId NVARCHAR(MAX) = NULL

        SELECT  @Id = Id
        FROM    dbo.ContactGroupDetails
        WHERE   QuestionTypeId = @QuestionTypeId
                AND ContactQuestionId = @ContactQuestionId
                AND ContactGroupId = @ContactGroupId
                AND IsDeleted = 0

        IF ( @QuestionTypeId = 5
             OR @QuestionTypeId = 6
             OR @QuestionTypeId = 18
			 OR @QuestionTypeId = 21
           )
            AND @Detail <> '' 
            BEGIN
                SELECT  @ContactOptionId = COALESCE(@ContactOptionId + ',', '')
                        + CONVERT(NVARCHAR(50), Id)
                FROM    dbo.ContactOptions
                WHERE   Name IN ( SELECT  DISTINCT
                                            Data
                                  FROM      dbo.Split(@Detail, ',') )
                        AND ContactQuestionId = @ContactQuestionId
                ORDER BY Position
            END

        IF ( @Id = 0 ) 
            BEGIN                INSERT  INTO dbo.[ContactGroupDetails]
                        ( [ContactGroupId] ,
                          [ContactQuestionId] ,
                          [ContactOptionId] ,
                          [QuestionTypeId] ,
                          [Detail] ,
                          [CreatedOn] ,
                          [CreatedBy] ,
                          [IsDeleted]
                        )
                VALUES  ( @ContactGroupId ,
                          @ContactQuestionId ,
                          @ContactOptionId ,
                          @QuestionTypeId ,
                          @Detail ,
                          GETUTCDATE() ,
                          @UserId ,
                          0
                        )                SELECT  @Id = SCOPE_IDENTITY()                INSERT  INTO dbo.ActivityLog
                        ( UserId ,
                          PageId ,
                          AuditComments ,
                          TableName ,
                          RecordId ,
                          CreatedOn ,
                          CreatedBy ,
                          IsDeleted 
                        )
                VALUES  ( @UserId ,
                          @PageId ,
                          'Insert record in table ContactGroupDetails' ,
                          'ContactGroupDetails' ,
                          @Id ,
                          GETUTCDATE() ,
                          @UserId ,
                          0
                        )            END        ELSE 
            BEGIN                UPDATE  dbo.[ContactGroupDetails]
                SET     [ContactGroupId] = @ContactGroupId ,
                        [ContactQuestionId] = @ContactQuestionId ,
                        [ContactOptionId] = @ContactOptionId ,
                        [QuestionTypeId] = @QuestionTypeId ,
                        [Detail] = @Detail ,
                        [UpdatedOn] = GETUTCDATE() ,
                        [UpdatedBy] = @UserId
                WHERE   [Id] = @Id                INSERT  INTO dbo.ActivityLog
                        ( UserId ,
                          PageId ,
                          AuditComments ,
                          TableName ,
                          RecordId ,
                          CreatedOn ,
                          CreatedBy ,
                          IsDeleted 
                        )
                VALUES  ( @UserId ,
                          @PageId ,
                          'Update record in table ContactGroupDetails' ,
                          'ContactGroupDetails' ,
                          @Id ,
                          GETUTCDATE() ,
                          @UserId ,
                          0
                        )            END        SELECT  ISNULL(@Id, 0) AS InsertedId    END