-- =============================================  
-- Author:			Anant Bhatt
-- Create date:	22-04-2020
-- Description:	Description,,InsertOrUpdateSCBSeenClientAnswerChild
-- Call:					InsertOrUpdateSCBSeenClientAnswerChild  
-- =============================================  
CREATE PROCEDURE [dbo].[InsertOrUpdateSCBSeenClientAnswerChild]
    @GroupId BIGINT,
    @UserId BIGINT,
    @ActionOwnerEmailAddress NVARCHAR(500),
    @ActionOwnerManagerEmailAddress NVARCHAR(500),
    @AnswerMasterId BIGINT
AS
BEGIN

    DECLARE @ActionOwnerId BIGINT;
    DECLARE @ActionOwnerManagerId BIGINT;

    SELECT @ActionOwnerId = Id
    FROM dbo.ContactMaster
    WHERE Id = (
                    SELECT TOP 1 ContactMasterId
                    FROM dbo.ContactDetails
                    WHERE Detail = @ActionOwnerEmailAddress
                )
          AND GroupId = @GroupId;
    SELECT @ActionOwnerManagerId = Id
    FROM dbo.ContactMaster
    WHERE Id = (
                    SELECT TOP 1 ContactMasterId
                    FROM dbo.ContactDetails
                    WHERE Detail = @ActionOwnerManagerEmailAddress
                )
          AND GroupId = @GroupId;
    INSERT INTO dbo.SeenClientAnswerChild
    (
        SeenClientAnswerMasterId,
        ContactMasterId,
        SenderCellNo,
        DeletedOn,
        DeletedBy,
        IsDeleted
    )
    VALUES
    (   @AnswerMasterId, -- SeenClientAnswerMasterId - bigint
        @ActionOwnerId,  -- ContactMasterId - bigint
        N'',             -- SenderCellNo - nvarchar(50)
        NULL,            -- DeletedOn - datetime
        0,               -- DeletedBy - bigint
        0                -- IsDeleted - bit
    );
    INSERT INTO dbo.SeenClientAnswerChild
    (
        SeenClientAnswerMasterId,
        ContactMasterId,
        SenderCellNo,
        DeletedOn,
        DeletedBy,
        IsDeleted
    )
    VALUES
    (   @AnswerMasterId,       -- SeenClientAnswerMasterId - bigint
        @ActionOwnerManagerId, -- ContactMasterId - bigint
        N'',                   -- SenderCellNo - nvarchar(50)
        NULL,                  -- DeletedOn - datetime
        0,                     -- DeletedBy - bigint
        0                      -- IsDeleted - bit
    );

    SELECT Id
    FROM dbo.SeenClientAnswerChild
    WHERE ContactMasterId IN ( @ActionOwnerId, @ActionOwnerManagerId )
          AND SeenClientAnswerMasterId = @AnswerMasterId;
END;
