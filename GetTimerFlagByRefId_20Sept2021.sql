/****** Script for SelectTopNRows command from SSMS  ******/
CREATE PROCEDURE [dbo].[GetTimerFlagByRefId_20Sept2021] @RefId BIGINT, @childId BIGINT
AS
    BEGIN
SELECT [Id]
      ,[RefId]
      ,[Flag]
      ,[CreatedOn]
      ,[ChildId]
      ,[Link]
  FROM [dbo].[TimerFlag]
  WHERE   RefId = @RefId AND ChildId = @childId;
END