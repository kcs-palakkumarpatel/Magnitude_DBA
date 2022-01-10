-- =============================================
-- Author:		GD
-- Create date: Jul 2015
-- Description:	
-- Call SP:		SearchFeedbackData 100, 1, '', '', '18 Aug 2014', '18 Aug 2015',0
-- =============================================
CREATE PROCEDURE [dbo].[SearchFeedbackData]
    @Rows INT ,
    @Page INT ,
    @Search NVARCHAR(50) ,
    @Sort NVARCHAR(50) ,
    @FromDate DATETIME ,
    @ToDate DATETIME ,
    @GroupId BIGINT ,
	@UserID INT
AS
    BEGIN
        DECLARE @Start AS INT ,
            @End INT ,
			@AdminRole bigint ,
			@UserRole bigint ,
			@PageID bigint;

        SET @Start = ( ( @Page * @Rows ) - @Rows ) + 1;
        SET @End = @Start + @Rows - 1;

        SET @ToDate = DATEADD(DAY, 1, @ToDate);

		SELECT TOP 1 @AdminRole = Id FROM [dbo].[Role] WHERE RoleName = 'Admin'
		SELECT TOP 1 @UserRole = RoleId FROM dbo.[User] WHERE Id = @UserId
		SELECT TOP 1 @PageID = Id FROM dbo.Page WHERE PageName = 'Establishment'

		IF @AdminRole = @UserRole
		BEGIN

			SELECT  *
			FROM    ( SELECT    ReportId ,
								dbo.ChangeDateFormat(CreatedOn,
													 'dd/MMM/yyyy HH:mm AM/PM') AS CaptureDate ,
								EstablishmentName ,
								UserName ,
								IsPositive AS SmileType ,
								COUNT(*) OVER ( PARTITION BY 1 ) AS Total ,
								ROW_NUMBER() OVER ( ORDER BY CASE WHEN @Sort = 'CaptureDate Asc'
																  THEN CreatedOn
															 END ASC, CASE
																  WHEN @Sort = 'CaptureDate DESC'
																  THEN CreatedOn
																  END DESC, CASE
																  WHEN @Sort = 'EstablishmentName Asc'
																  THEN EstablishmentName
																  END ASC, CASE
																  WHEN @Sort = 'EstablishmentName DESC'
																  THEN EstablishmentName
																  END DESC, CASE
																  WHEN @Sort = 'UserName Asc'
																  THEN UserName
																  END ASC, CASE
																  WHEN @Sort = 'UserName DESC'
																  THEN UserName
																  END DESC, CASE
																  WHEN @Sort = 'SmileType Asc'
																  THEN IsPositive
																  END ASC, CASE
																  WHEN @Sort = 'SmileType DESC'
																  THEN IsPositive
																  END DESC, CASE
																  WHEN @Sort = ''
																  THEN CreatedOn
																  END DESC ) AS RowNum
					  FROM      dbo.View_AnswerMaster
					  WHERE     ( CreatedOn BETWEEN @FromDate AND @ToDate )
								AND ( EstablishmentName LIKE '%' + @Search + '%'
									  OR UserName LIKE '%' + @Search + '%'
									  OR IsPositive LIKE '%' + @Search + '%'
									  OR dbo.ChangeDateFormat(CreatedOn,
															  'dd/MMM/yyyy HH:mm AM/PM') LIKE '%'
									  + @Search + '%'
									)
								AND ( GroupId = @GroupId
									  OR @GroupId = 0
									)
					) AS R
			WHERE   R.RowNum BETWEEN @Start AND @End
			ORDER BY R.RowNum;
		END
		ELSE
		BEGIN

						SELECT  *
			FROM    ( SELECT    ReportId ,
								dbo.ChangeDateFormat(dbo.View_AnswerMaster.CreatedOn,
													 'dd/MMM/yyyy HH:mm AM/PM') AS CaptureDate ,
								EstablishmentName ,
								UserName ,
								IsPositive AS SmileType ,
								COUNT(*) OVER ( PARTITION BY 1 ) AS Total ,
								ROW_NUMBER() OVER ( ORDER BY CASE WHEN @Sort = 'CaptureDate Asc'
																  THEN dbo.View_AnswerMaster.CreatedOn
															 END ASC, CASE
																  WHEN @Sort = 'CaptureDate DESC'
																  THEN dbo.View_AnswerMaster.CreatedOn
																  END DESC, CASE
																  WHEN @Sort = 'EstablishmentName Asc'
																  THEN EstablishmentName
																  END ASC, CASE
																  WHEN @Sort = 'EstablishmentName DESC'
																  THEN EstablishmentName
																  END DESC, CASE
																  WHEN @Sort = 'UserName Asc'
																  THEN UserName
																  END ASC, CASE
																  WHEN @Sort = 'UserName DESC'
																  THEN UserName
																  END DESC, CASE
																  WHEN @Sort = 'SmileType Asc'
																  THEN IsPositive
																  END ASC, CASE
																  WHEN @Sort = 'SmileType DESC'
																  THEN IsPositive
																  END DESC, CASE
																  WHEN @Sort = ''
																  THEN dbo.View_AnswerMaster.CreatedOn
																  END DESC ) AS RowNum
					  FROM      dbo.View_AnswerMaster
					  INNER JOIN dbo.UserRolePermissions ON dbo.UserRolePermissions.PageID = @PageID
						AND dbo.UserRolePermissions.ActualID = dbo.View_AnswerMaster.EstablishmentId
						AND dbo.UserRolePermissions.UserID = @UserID
					  WHERE     ( dbo.View_AnswerMaster.CreatedOn BETWEEN @FromDate AND @ToDate )
								AND ( EstablishmentName LIKE '%' + @Search + '%'
									  OR UserName LIKE '%' + @Search + '%'
									  OR IsPositive LIKE '%' + @Search + '%'
									  OR dbo.ChangeDateFormat(dbo.View_AnswerMaster.CreatedOn,
															  'dd/MMM/yyyy HH:mm AM/PM') LIKE '%'
									  + @Search + '%'
									)
								AND ( GroupId = @GroupId
									  OR @GroupId = 0
									)
					) AS R
			WHERE   R.RowNum BETWEEN @Start AND @End
			ORDER BY R.RowNum;

		END

    END;
