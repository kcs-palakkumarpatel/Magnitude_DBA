-- =============================================  
-- Author:			Anant Bhatt
-- Create date:	22-04-2020
-- Description:	Description,,GenerateContactGroupSCB
-- Call:					GenerateContactGroupSCB  
-- =============================================  
CREATE PROCEDURE dbo.GenerateContactGroupSCB
    @GroupId BIGINT,
    @ContactGropName NVARCHAR(50),
    @UserId BIGINT,
    @ActionOwnerEmailAddress NVARCHAR(500),
    @ActionOwnerManagerEmailAddress NVARCHAR(500)
AS
BEGIN
    DECLARE @ContactGroupId BIGINT;
    DECLARE @ContactFormId BIGINT;
    DECLARE @ActionOwnerId BIGINT;
    DECLARE @ActionOwnerManagerId BIGINT;

    INSERT INTO dbo.[ContactGroup]
    (
        [ContactGropName],
        [GroupId],
        [Description],
        [IsCreatedByCapture],
        [CreatedOn],
        [CreatedBy],
        [IsDeleted]
    )
    VALUES
    (@ContactGropName, @GroupId, '', 0, GETUTCDATE(), @UserId, 0);

    SELECT @ContactGroupId = SCOPE_IDENTITY();
    SELECT @ContactFormId = ContactId
    FROM dbo.[Group]
    WHERE Id = @GroupId;

    SELECT @ActionOwnerId = Id
    FROM dbo.ContactMaster
    WHERE Id IN (
                    SELECT ContactMasterId
                    FROM dbo.ContactDetails
                    WHERE Detail = @ActionOwnerEmailAddress
                )
          AND GroupId = @GroupId;


    SELECT @ActionOwnerManagerId = Id
    FROM dbo.ContactMaster
    WHERE Id IN (
                    SELECT ContactMasterId
                    FROM dbo.ContactDetails
                    WHERE Detail = @ActionOwnerManagerEmailAddress
                )
          AND GroupId = @GroupId;


    INSERT INTO dbo.ContactGroupRelation
    (
        ContactMasterId,
        ContactGroupId,
        CreatedOn,
        CreatedBy,
        UpdatedOn,
        UpdatedBy,
        DeletedOn,
        DeletedBy,
        IsDeleted
    )
    VALUES
    (   @ActionOwnerId,  -- ContactMasterId - bigint
        @ContactGroupId, -- ContactGroupId - bigint
        GETDATE(),       -- CreatedOn - datetime
        @UserId,         -- CreatedBy - bigint
        GETDATE(),       -- UpdatedOn - datetime
        0,               -- UpdatedBy - bigint
        GETDATE(),       -- DeletedOn - datetime
        0,               -- DeletedBy - bigint
        0                -- IsDeleted - bit
    );
    INSERT INTO dbo.ContactGroupRelation
    (
        ContactMasterId,
        ContactGroupId,
        CreatedOn,
        CreatedBy,
        UpdatedOn,
        UpdatedBy,
        DeletedOn,
        DeletedBy,
        IsDeleted
    )
    VALUES
    (   @ActionOwnerManagerId, -- ContactMasterId - bigint
        @ContactGroupId,       -- ContactGroupId - bigint
        GETDATE(),             -- CreatedOn - datetime
        @UserId,               -- CreatedBy - bigint
        GETDATE(),             -- UpdatedOn - datetime
        0,                     -- UpdatedBy - bigint
        GETDATE(),             -- DeletedOn - datetime
        0,                     -- DeletedBy - bigint
        0                      -- IsDeleted - bit
    );

    SELECT @ContactGroupId;
END;
