-- =============================================
-- Author:
-- Create date:	11-May-2017
-- Description:	
-- Call SP:		SearchSeenClientData  100, 1, '', '', '18 Aug 2014', '18 Aug 2015', 0
-- =============================================
CREATE PROCEDURE [dbo].[SearchSeenClientData]
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
		SELECT TOP 1 @UserRole = RoleId FROM dbo.[User] WHERE Id = @UserID
		SELECT TOP 1 @PageID = Id FROM dbo.Page WHERE PageName = 'Establishment'

		IF @AdminRole = @UserRole
		BEGIN

			SELECT  *
			FROM    ( SELECT    ReportId ,
								EstablishmentName ,
								UserName ,
								SeenClientTitle ,
								dbo.ChangeDateFormat(CreatedOn,
													 'dd/MMM/yyyy HH:mm AM/PM') AS CaptureDate ,
								CreatedOn ,
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
																  WHEN @Sort = 'SeenClientTitle Asc'
																  THEN SeenClientTitle
																  END ASC, CASE
																  WHEN @Sort = 'SeenClientTitle DESC'
																  THEN SeenClientTitle
																  END DESC, CASE
																  WHEN @Sort = ''
																  THEN CreatedOn
																  END DESC ) AS RowNum
					  FROM      View_SeenClientAnswerMaster
					  WHERE     ( CreatedOn BETWEEN @FromDate AND @ToDate )
								AND ( EstablishmentName LIKE '%' + @Search + '%'
									  OR UserName LIKE '%' + @Search + '%'
									  OR SeenClientTitle LIKE '%' + @Search + '%'
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
								EstablishmentName ,
								UserName ,
								SeenClientTitle ,
								dbo.ChangeDateFormat(View_SeenClientAnswerMaster.CreatedOn,
													 'dd/MMM/yyyy HH:mm AM/PM') AS CaptureDate ,
								View_SeenClientAnswerMaster.CreatedOn ,
								COUNT(*) OVER ( PARTITION BY 1 ) AS Total ,
								ROW_NUMBER() OVER ( ORDER BY CASE WHEN @Sort = 'CaptureDate Asc'
																  THEN View_SeenClientAnswerMaster.CreatedOn
															 END ASC, CASE
																  WHEN @Sort = 'CaptureDate DESC'
																  THEN View_SeenClientAnswerMaster.CreatedOn
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
																  WHEN @Sort = 'SeenClientTitle Asc'
																  THEN SeenClientTitle
																  END ASC, CASE
																  WHEN @Sort = 'SeenClientTitle DESC'
																  THEN SeenClientTitle
																  END DESC, CASE
																  WHEN @Sort = ''
																  THEN View_SeenClientAnswerMaster.CreatedOn
																  END DESC ) AS RowNum
					  FROM      View_SeenClientAnswerMaster
					  INNER JOIN dbo.UserRolePermissions ON dbo.UserRolePermissions.PageID = @PageID
							AND dbo.UserRolePermissions.ActualID = dbo.View_SeenClientAnswerMaster.EstablishmentId
						    AND dbo.UserRolePermissions.UserID = @UserID
					  WHERE     ( View_SeenClientAnswerMaster.CreatedOn BETWEEN @FromDate AND @ToDate )
								AND ( EstablishmentName LIKE '%' + @Search + '%'
									  OR UserName LIKE '%' + @Search + '%'
									  OR SeenClientTitle LIKE '%' + @Search + '%'
									  OR dbo.ChangeDateFormat(View_SeenClientAnswerMaster.CreatedOn,
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
