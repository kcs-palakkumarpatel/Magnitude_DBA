-- =============================================
--  Author: 	  Mitesh Kachhadiya
--  Create date:  19-Oct-2021
--	Description:	
--	Call SP: CheckUserNameExistCommonAppUser 'Johan.B','MG'
--	=============================================
CREATE PROCEDURE [dbo].[CheckUserNameExistCommonAppUser]
    @UserName NVARCHAR(50),
    @InstanceKey NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (1)  E.InstanceName
    FROM dbo.CommonAppUser CAU WITH (NOLOCK)
        JOIN dbo.ENVIRONMENT AS E WITH (NOLOCK)
            ON E.Id = CAU.EnvironmentId
    WHERE Username = @UserName
          AND [Key] != @InstanceKey;

    SET NOCOUNT OFF;
END;
