-- =============================================
-- Author:		<Vasudev Patel>
-- Create date: <12 Dec 2018>
-- Description:	Flag Unflag chat and form    
-- Format of ID parameter = ReportId OR Notification Id | 1 = IN, 2 = OUT, 3 = CHAT
-- call: UpdateNotificationFlag '37058|395662|1',1,1864
-- =============================================
CREATE PROCEDURE [dbo].[UpdateNotificationFlagOutMobile]
    @Id VARCHAR(MAX),
    @Flag BIT,
    @AppUserId BIGINT
AS
BEGIN

DECLARE @Type VARCHAR(10)
	DECLARE @tempId TABLE
	(
		id VARCHAR(100)
	)

	INSERT INTO @tempId SELECT Data FROM dbo.Split(@Id, ',')

	DECLARE @TempType TABLE
	(	Id BIGINT,
		NotificationId BIGINT,
		[Type] VARCHAR(10)
	)

	DECLARE @TempType1 TABLE
	(	Id BIGINT,
		NotificationId BIGINT,
		[Type] VARCHAR(10)
	)

INSERT INTO @TempType
SELECT SUBSTRING(id,1,CHARINDEX('|', id)-1),
SUBSTRING(SUBSTRING(id, CHARINDEX('|', id) +1,LEN(SUBSTRING(id, CHARINDEX('|', id) +1 ,LEN(id)))),1,CHARINDEX('|', SUBSTRING(id, CHARINDEX('|', id) +1 ,LEN(id)))-1),
REPLACE(SUBSTRING(id, LEN(id)-1,LEN(id)+1),'|','') FROM @tempId

	--DELETE FROM dbo.FlagMaster
	--WHERE Id IN (
	--				SELECT FM.Id
	--				FROM dbo.FlagMaster AS FM
	--					INNER JOIN @TempType AS TT
	--						ON FM.ReportId = TT.Id
	--						   AND FM.NotificationId = TT.NotificationId
	--						   AND FM.Type = TT.Type
	--				WHERE FM.AppUserId = @AppUserId
	--			);
	--INSERT INTO dbo.FlagMaster
	--				(
	--					ReportId,
	--					NotificationId,
	--					Type,
	--					IsFlag,
	--					AppUserId,
	--					CreatedOn,
	--					CreatedBy,
	--					IsDeleted
	--				)
	--				SELECT Id,
	--					   NotificationId,
	--					   [Type],
	--					   @Flag,
	--					   @AppUserId,
	--					   GETUTCDATE(),
	--					   @AppUserId,
	--					   0
	--				FROM @TempType;	
       
	IF EXISTS (SELECT COUNT(1) FROM @TempType WHERE [Type] = 3)
	BEGIN
	PRINT 1
				--UPDATE dbo.PendingNotificationWeb
				--SET IsFlag = @Flag
				--WHERE Id IN (
				--				SELECT id FROM @TempType WHERE [Type] = 3
				--			)
				--	  AND IsDeleted = 0;
				
				IF(@Flag = 1)
				BEGIN
				
				INSERT INTO @TempType1
				(
				    Id,
				    NotificationId,
				    Type
				)
						SELECT RefId,
							   0,
							   1
						FROM dbo.PendingNotificationWeb
						WHERE Id IN (
										SELECT NotificationId FROM @TempType WHERE [Type] = 3
									)
							  AND ModuleId IN ( 2, 5, 7, 11 );

							  PRINT 2
				INSERT INTO @TempType1
				(
				    Id,
				    NotificationId,
				    Type
				)
					SELECT RefId,
						   0,
						   2
					FROM dbo.PendingNotificationWeb
					WHERE Id IN (
									SELECT NotificationId FROM @TempType WHERE [Type] = 3
								)
						  AND ModuleId IN ( 3, 6, 8, 12 );
				END
	END
	IF EXISTS (SELECT COUNT(1) FROM @TempType WHERE [Type] = 1)
	BEGIN
				--UPDATE dbo.AnswerMaster SET IsFlag = @Flag WHERE Id IN (SELECT Id FROM @TempType WHERE [Type] = 1)
				--	  AND IsDeleted = 0;
					  IF(@Flag = 1)
					  BEGIN
							
							
						INSERT INTO @TempType1
				(
				    Id,
				    NotificationId,
				    Type
				)
							SELECT SeenClientAnswerMasterId,
								   0,
								   2
							FROM dbo.AnswerMaster
							WHERE Id IN (
											SELECT Id FROM @TempType WHERE [Type] = 1
										)
					  END
					  --		UPDATE dbo.PendingNotificationWeb
							--SET IsFlag = @Flag
							--WHERE Id IN (
							--				SELECT NotificationId FROM @TempType WHERE [Type] = 1 
							--			)
							--	  AND IsDeleted = 0;
	END

	INSERT INTO @TempType
	(
	    Id,
	    NotificationId,
	    Type
	)
	SELECT Id,
	    NotificationId,
	    Type FROM @TempType1


	DELETE FROM dbo.FlagMaster
	WHERE Id IN (
					SELECT FM.Id
					FROM dbo.FlagMaster AS FM
						INNER JOIN @TempType AS TT
							ON FM.ReportId = TT.Id
							   --AND FM.NotificationId = TT.NotificationId
							   AND FM.Type = TT.Type
					WHERE FM.AppUserId = @AppUserId AND FM.Type IN (1,2)
				);

					DELETE FROM dbo.FlagMaster
	WHERE Id IN (
					SELECT FM.Id
					FROM dbo.FlagMaster AS FM
						INNER JOIN @TempType AS TT
							ON FM.ReportId = TT.Id
							   AND FM.NotificationId = TT.NotificationId
							   AND FM.Type = TT.Type
                     WHERE FM.AppUserId = @AppUserId
									AND FM.Type IN (3)
				);

	INSERT INTO dbo.FlagMaster
					(
						ReportId,
						NotificationId,
						Type,
						IsFlag,
						AppUserId,
						CreatedOn,
						CreatedBy,
						IsDeleted
					)
					SELECT Id,
						   NotificationId,
						   [Type],
						   @Flag,
						   @AppUserId,
						   GETUTCDATE(),
						   @AppUserId,
						   0
					FROM @TempType;	



	--IF EXISTS (SELECT COUNT(1) FROM @TempType WHERE [Type] = 2)
	--BEGIN
	--				UPDATE dbo.SeenClientAnswerMaster
	--				SET IsFlag = @Flag
	--				WHERE Id IN (SELECT Id FROM @TempType WHERE [Type] = 2);

	--					UPDATE dbo.PendingNotificationWeb
	--			SET IsFlag = @Flag
	--			WHERE Id IN (
	--							SELECT NotificationId FROM @TempType WHERE [Type] = 2 
	--						)
	--				  AND IsDeleted = 0;
	--END
END
