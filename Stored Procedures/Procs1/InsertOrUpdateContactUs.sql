
-- =============================================
-- Author:		<Author,,ADMIN>
-- Create date: <Create Date,, 27 May 2015>
-- Description:	<Description,,InsertOrUpdateContactUs>
-- Call SP    :	InsertOrUpdateContactUs
-- =============================================
CREATE PROCEDURE [dbo].[InsertOrUpdateContactUs]
    @CustomerName VARCHAR(100) ,
    @Mobile VARCHAR(15) ,
    @Email VARCHAR(100) ,
    @Comment VARCHAR(4000)
AS 
    BEGIN
        DECLARE @ID BIGINT
        --IF ( @ID = 0 ) 
        --    BEGIN
        INSERT  INTO dbo.[ContactUs]
                ( [CustomerName] ,
                  [Mobile] ,
                  [Email] ,
                  [Comment] ,
                  [Status] ,
                  [CreatedOn] ,
                  [IsDeleted] ,
                  [CreatedBy]
                        
                )
        VALUES  ( @CustomerName ,
                  @Mobile ,
                  @Email ,
                  @Comment ,
                  1 ,
                  GETUTCDATE() ,
                  0 ,
                  1
                        
                )
        SELECT  @ID = SCOPE_IDENTITY()
        --    END
        --ELSE 
        --    BEGIN
        --        UPDATE  dbo.[ContactUs]
        --        SET     [CustomerName] = @CustomerName ,
        --                [Mobile] = @Mobile ,
        --                [Email] = @Email ,
        --                [Comment] = @Comment ,
        --                [Status] = @Status ,
        --                [UpdatedOn] = GETUTCDATE() ,
        --                [UpdatedBy] = @UserId
        --        WHERE   [ID] = @ID
        --    END

		IF ( @ID > 0 ) 
            EXEC SendContactUsEmail @ID --Send ContactUs Email


        SELECT  ISNULL(@ID, 0) AS InsertedId

    END