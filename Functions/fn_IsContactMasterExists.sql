-- =============================================
-- Author: Matthew Grinaker	
-- Create date:			2020/03/30
-- Description:		Find ContactMasterId using GroupID, Email, 
-- Call SP:			fn_IsContactMasterExists 201,'mkgrinaker@gmail.com','0836591690'
-- =============================================
CREATE FUNCTION dbo.fn_IsContactMasterExists
(
    @GroupId BIGINT,
    @EmailId NVARCHAR(100),
    @MobileNo NVARCHAR(50)
)
RETURNS BIGINT
AS
BEGIN
    IF @EmailId IS NULL
        SET @EmailId = '';
    IF @MobileNo IS NULL
        SET @MobileNo = '';

    DECLARE @AppUserContactId BIGINT;
    SET @AppUserContactId = 0;

    SELECT @AppUserContactId = CM.Id
    FROM dbo.ContactMaster AS CM
        LEFT JOIN dbo.ContactDetails AS CD
            ON CD.ContactMasterId = CM.Id
    WHERE CM.GroupId = @GroupId
          AND CM.IsDeleted = 0
          AND CD.QuestionTypeId IN ( 10, 11 )
          AND  CD.Detail = @EmailId
          AND CD.Detail <> '';

    RETURN ISNULL(@AppUserContactId, 0);
END;
