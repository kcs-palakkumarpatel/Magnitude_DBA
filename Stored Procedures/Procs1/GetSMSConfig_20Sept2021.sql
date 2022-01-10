CREATE PROCEDURE [dbo].[GetSMSConfig_20Sept2021]
AS
    BEGIN
		SELECT [UserName]
			  ,[Password]
			  ,[ApiId]
			  ,[Concat]
		FROM [dbo].[SMSConfig]
END