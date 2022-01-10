--CALL EXEC GetCustomerContcatName '35531'
--CALL EXEC GetCustomerContcatName '35532'
--CALL EXEC GetCustomerContcatName '32182'
--CALL EXEC GetCustomerContcatName '35534'
--CALL EXEC GetCustomerContcatName '35533'

CREATE PROCEDURE dbo.GetCustomerContcatName (@ContactMasterId BIGINT)
AS
BEGIN
    DECLARE @Name NVARCHAR(MAX);
    DECLARE @EmailId NVARCHAR(MAX);
    DECLARE @MobileNumber NVARCHAR(MAX);
    DECLARE @FinalName NVARCHAR(MAX);
    SET @Name =
    (
        SELECT TOP 1
            Detail
        FROM ContactDetails
        WHERE ContactMasterId = @ContactMasterId
              AND QuestionTypeId = 4
    );
    SET @EmailId =
    (
        SELECT TOP 1 Detail
        FROM ContactDetails
        WHERE ContactMasterId = @ContactMasterId
              AND QuestionTypeId = 10
    );
    SET @MobileNumber =
    (
        SELECT TOP 1 Detail
        FROM ContactDetails
        WHERE ContactMasterId = @ContactMasterId
              AND QuestionTypeId = 11
    );

    IF (@Name != '')
    BEGIN
        PRINT 1;
        SET @FinalName = (ISNULL(@Name, ''));
   
    END;
    ELSE IF (@EmailId != '')
    BEGIN
        PRINT 2;
		SET @FinalName = LEFT(@EmailId, (CHARINDEX('@', @EmailId) - 1));
    END;
	ELSE 
	BEGIN
	  SET @FinalName = ISNULL(RTRIM(LTRIM(@MobileNumber)), '');
	END
    SELECT @FinalName;


--   IF ((@Name IS NULL AND @MobileNumber IS NULL)
--         BEGIN
--             SET @FinalName = LEFT(@EmailId, (CHARINDEX('@', @EmailId) - 1)) + ' ' + ' (' + @EmailId + ')';
--         END;
--         ELSE IF (@Name IS NULL AND @EmailId IS NULL)
--         BEGIN
--             SET @FinalName = ISNULL(RTRIM(LTRIM(@MobileNumber)), '');
--         END;
--         ELSE IF (@MobileNumber IS NULL)
--         BEGIN
--             SET @FinalName = (ISNULL(@Name, ''));
--         END;
--         ELSE IF (@EmailId IS NULL)
--         BEGIN
--             SET @FinalName = (ISNULL(@Name, ''));
--         END;
--         ELSE IF (@Name IS NULL)
--         BEGIN
--             SET @FinalName
--                 = LEFT(@EmailId, (CHARINDEX('@', @EmailId) - 1)) + ' ' + ' (' + ISNULL(@EmailId + ',', '');
--         END;
--         ELSE
--         BEGIN
--             SET @FinalName
--                 = (ISNULL(@Name, ''));
--         END;
--SELECT @FinalName

--SET @count =
--(
--    SELECT COUNT(1)
--    FROM ContactDetails
--    WHERE ContactMasterId = @ContactMasterId
--          AND QuestionTypeId = 4
--);
--IF (@count = 0)
--BEGIN
--    SELECT *
--    FROM ContactDetails
--    WHERE ContactMasterId = @ContactMasterId
--          AND QuestionTypeId = 11;
--END;
--ELSE
--BEGIN
--    SET @Details =
--    (
--        SELECT Detail
--        FROM ContactDetails
--        WHERE ContactMasterId = @ContactMasterId
--              AND QuestionTypeId = 10
--    );
--    IF (@Details <> '')
--    BEGIN
--        SELECT *
--        FROM ContactDetails
--        WHERE ContactMasterId = @ContactMasterId
--              AND QuestionTypeId = 10;
--    END;
--    ELSE
--    BEGIN
--        SELECT *
--        FROM ContactDetails
--        WHERE ContactMasterId = @ContactMasterId
--              AND QuestionTypeId = 11;
--    END;
--END;

END;
