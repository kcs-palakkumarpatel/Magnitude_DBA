﻿-- =============================================
-- Author:		Vasu Patel
-- Create date: 04-05-2016
-- Description:	Insert App Manager user
-- =============================================
CREATE PROCEDURE [dbo].[InsertAppManagerUserRights]
	@AppUserId	BIGINT,
	@appmanager XML,
	@UserId	BIGINT
AS
BEGIN

CREATE TABLE #TempTeabl (
Data VARCHAR(20)
)

INSERT INTO #TempTeabl
        ( Data )
  SELECT
      Name = XCol.value('(value)[1]','varchar(25)')
   FROM 
      @appmanager.nodes('/AppManager/row') AS XTbl(XCol)

IF EXISTS (SELECT 1 FROM #TempTeabl WHERE Data = '0|0')
BEGIN
	UPDATE dbo.AppManagerUserRights SET IsDeleted = 1,DeletedOn = GETUTCDATE(), DeletedBy = @UserId WHERE UserId = @AppUserId
END
ELSE
BEGIN
CREATE TABLE #AppmanagerTable 
(Id BIGINT IDENTITY(1,1),
ManagerId BIGINT,
EstablishmentId BIGINT
)

CREATE TABLE #ExistTable 
	(
	Id BIGINT IDENTITY(1,1),
	EstablishmentId BIGINT,
	ManagerId BIGINT,
	EIdMid VARCHAR(50)
	)
	CREATE TABLE #NotExistTable 
	(
	Id BIGINT IDENTITY(1,1),
	EstablishmentId BIGINT,
	ManagerId BIGINT
	)
	CREATE TABLE #DeleteEstabilshment 
	(	id BIGINT IDENTITY(1,1),
		EstablishmentId BIGINT,
		ManagerId BIGINT
	)

		INSERT  INTO #AppmanagerTable
        ( ManagerId ,
          EstablishmentId
        )
        SELECT  SUBSTRING(Data, 1, CHARINDEX('|', Data) - 1) AS ManagerId ,
                SUBSTRING(Data, CHARINDEX('|', Data) + 1, LEN(Data)) AS EstablishmentID
        FROM    #TempTeabl;
	 
	 

	 INSERT INTO #ExistTable
            ( EstablishmentId,
			  ManagerId,
			  EIdMid
            )
            SELECT  AMR.EstablishmentId,AMR.ManagerUserId , CONVERT(VARCHAR(15), AMR.ManagerUserId) +'|'+ CONVERT(VARCHAR(15), AMR.EstablishmentId)
            FROM    dbo.AppManagerUserRights AS AMR
                    INNER JOIN #AppmanagerTable AS E ON AMR.EstablishmentId = E.EstablishmentId AND AMR.ManagerUserId = e.ManagerId
					WHERE AMR.UserId = @AppUserId;
	

    INSERT  INTO #NotExistTable
	        ( ManagerId, EstablishmentId)
        SELECT  SUBSTRING(E.Data, 1, CHARINDEX('|', Data) - 1) AS ManagerId ,
                SUBSTRING(Data, CHARINDEX('|', Data) + 1, LEN(Data)) AS EstablishmentID
        FROM    #TempTeabl AS E WHERE E.Data NOT IN (SELECT EIdMid FROM #ExistTable);
	
	INSERT INTO #DeleteEstabilshment
	        ( ManagerId, EstablishmentId)
	    SELECT  SUBSTRING(T.EidMid, 1, CHARINDEX('|', T.EidMid) - 1) AS ManagerId ,
                SUBSTRING(T.EidMid, CHARINDEX('|', T.EidMid) + 1, LEN(T.EidMid)) AS EstablishmentID
        FROM   (SELECT E.EidMid FROM (SELECT CONVERT(VARCHAR(15), ManagerUserId) + '|' + CONVERT(VARCHAR(15), EstablishmentId) AS EidMid FROM dbo.AppManagerUserRights WHERE UserId = @AppUserId) AS E  WHERE E.EidMid NOT IN (SELECT EIdMid FROM #ExistTable)) AS T
	
			IF EXISTS ( SELECT  1
					FROM    #DeleteEstabilshment )
			BEGIN
				UPDATE  AMR
				SET     AMR.IsDeleted = 1 ,
						AMR.UpdatedOn = GETUTCDATE() ,
						AMR.UpdatedBy = @UserId
				FROM    dbo.AppManagerUserRights AS AMR
						INNER JOIN #DeleteEstabilshment AS E ON E.EstablishmentId = AMR.EstablishmentId
																AND E.ManagerId = AMR.ManagerUserId
																AND AMR.UserId = @AppUserId;
			END;
                                                       
		--SELECT * FROM @AppmanagerTable
		--SELECT * FROM @ExistTable
		--SELECT * FROM @NotExistTable
		--SELECT * FROM @DeleteEstabilshment
        IF EXISTS ( SELECT  1
                    FROM    #NotExistTable )
            BEGIN
                INSERT  INTO dbo.AppManagerUserRights
                        ( UserId ,
                          EstablishmentId ,
                          ManagerUserId ,
                          CreatedOn ,
                          CreatedBy ,
                          IsDeleted
	                    )
                        SELECT  @AppUserId ,
                                EstablishmentId ,
                                ManagerId ,
                                GETUTCDATE() ,
                                @UserId ,
                                0
                        FROM    #NotExistTable;
            END;
        IF EXISTS ( SELECT  1
                    FROM    #ExistTable )
            BEGIN
                UPDATE  AMR
                SET     AMR.IsDeleted = 0 ,
                        AMR.UpdatedOn = GETUTCDATE() ,
                        AMR.UpdatedBy = @UserId
                FROM    dbo.AppManagerUserRights AS AMR
                        INNER JOIN #ExistTable AS E ON E.EstablishmentId = AMR.EstablishmentId
                                                       AND E.ManagerId = AMR.ManagerUserId
                                                       AND AMR.UserId = @AppUserId;
            END;
        END
		SELECT 1 AS id
END
