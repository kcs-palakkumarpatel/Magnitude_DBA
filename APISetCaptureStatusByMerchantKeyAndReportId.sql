-- =============================================
-- Author:		Matthew Grinaker
-- Create date:	05-June-2017
-- Description:	Get Capture Master Data from for Web API Using MerchantKey(GroupId)
-- Call:        APISetCaptureStatusByMerchantKeyAndReportId 201, 123319, 1329
-- =============================================
CREATE PROCEDURE [dbo].[APISetCaptureStatusByMerchantKeyAndReportId]
    (
      @MerchantKey BIGINT = 0 ,
	  @ReportId NVARCHAR(MAX) = '0',
	  @EstablishmentStatusId BIGINT
	)
AS
    BEGIN

	if exists(select 1 from SeenClientAnswerMaster where id = @ReportId)
	BEGIN
		DECLARE @id BIGINT,
        @Offset INT,
		@StatusDateTime DateTime;

		SET @StatusDateTime = GETUTCDATE();

		SELECT @Offset = MAX(E.TimeOffSet)
		FROM dbo.Establishment AS E
		INNER JOIN dbo.EstablishmentStatus AS ES
        ON ES.EstablishmentId = E.Id
		WHERE E.IsDeleted = 0
		AND ES.Id = @EstablishmentStatusId;

	  INSERT INTO StatusHistory
		(
		[ReferenceNo],
		[EstablishmentStatusId],
		[UserId],
		[StatusDateTime],
		[Latitude],
		[Longitude],
		[CreatedOn],
		[CreatedBy]
		)
	  VALUES
		(
		 @ReportId,
		 @EstablishmentStatusId,
		 1,
		 DATEADD(MINUTE, @Offset, @StatusDateTime),
		 NULL,
		 NULL,
		 GETUTCDATE(),
		 1
		);

	SELECT @id = ISNULL(CAST(SCOPE_IDENTITY() AS BIGINT), 0);

	UPDATE dbo.SeenClientAnswerMaster
	SET StatusHistoryId = @id, UpdatedOn =  DATEADD(MINUTE, @Offset, @StatusDateTime), UpdatedBy = 1
	WHERE Id = @ReportId;

	
	SELECT TOP 1
		   ES.Id AS StatusId,
		   --SH.ReferenceNo,
		   ES.StatusName AS StatusName
		FROM dbo.StatusHistory AS SH
		INNER JOIN dbo.EstablishmentStatus AS ES
			ON SH.EstablishmentStatusId = ES.Id
		WHERE SH.Id = @id;
	END
	ELSE
	BEGIN
		SELECT -1;
	END
END;
