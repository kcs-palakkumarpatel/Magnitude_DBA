CREATE PROCEDURE dbo.InsertBrowserDetail
	@BrowserDetail  NVARCHAR(MAX),
	@UserAgent NVARCHAR(MAX)
AS
BEGIN
	INSERT INTO dbo.BrowserHistory
	(
	    BrowserDetail,
	    UserAgent
	)
	VALUES
	(   @BrowserDetail, -- BrowserDetail - nvarchar(max)
	    @UserAgent  -- UserAgent - nvarchar(max)
	)
END
