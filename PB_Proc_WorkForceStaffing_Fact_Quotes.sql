CREATE PROCEDURE [dbo].[PB_Proc_WorkForceStaffing_Fact_Quotes]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Desc VARCHAR(200)
	EXEC dbo.PB_Log_Insert 'WorkForceStaffing_Fact_Quotes','WorkForceStaffing_Fact_Quotes Start','WorkForce Staffing'

	TRUNCATE TABLE dbo.WorkForceStaffing_Fact_Quotes

	
	INSERT INTO WorkForceStaffing_Fact_Quotes(EstablishmentName,CapturedDate,ReferenceNo,Status,UserName,[Is this a new or existing client?] ,
[Did this come of a prospect engagement, courtesy call or cold call?] ,[Industry],[Company] ,[Company Size] ,[Company registration number from quote] ,
[Contract Type] ,[If Bargaining Council, Please select below],[Expected Monthly Revenue],[Expected GP (%)] ,[Order or Project Duration (Months)] ,
[Total Sale Value] ,[Are we facing competition?],ResponseDate,ResponseRef,ResponseStatus ,[Purchase Order Number],[Documentation Sign],
[Outstanding]  ,[Price (ZAR)] ,[Reason for requote],[Why you re-quoted],[lost sale],[wrong with the pri],[complaint type],[What other reasons],
[competitors?] ,[met requirement ?] ,[got the deal?],[Monthly revenue],[Start] ,[End],[Total revenue],[GP (%)] ,[PO number],[Expected Month Rev],
[Expected GP%] ,[Duration] ,[Estimate Headcount],[Project Duration] ,[Response Total Sale Value] ,Dummyrow,StatusSort,[User] )
	SELECT EstablishmentName,CapturedDate,ReferenceNo,Status,UserName,[Is this a new or existing client?] ,
[Did this come of a prospect engagement, courtesy call or cold call?] ,[Industry],[Company] ,[Company Size] ,[Company registration number from quote] ,
[Contract Type] ,[If Bargaining Council, Please select below],[Expected Monthly Revenue],[Expected GP (%)] ,[Order or Project Duration (Months)] ,
[Total Sale Value] ,[Are we facing competition?],ResponseDate,ResponseRef,ResponseStatus ,[Purchase Order Number],[Documentation Sign],
[Outstanding]  ,[Price (ZAR)] ,[Reason for requote],[Why you re-quoted],[lost sale],[wrong with the pri],[complaint type],[What other reasons],
[competitors?] ,[met requirement ?] ,[got the deal?],[Monthly revenue],[Start] ,[End],[Total revenue],[GP (%)] ,[PO number],[Expected Month Rev],
[Expected GP%] ,[Duration] ,[Estimate Headcount],[Project Duration] ,[Response Total Sale Value] ,Dummyrow ,StatusSort,[User]
	 FROM [PB_VW_WorkForceStaffing_Fact_Quotes]

	SELECT @Desc = 'WorkForceStaffing_Fact_Quotes Completed.( '+  CONVERT(VARCHAR,COUNT(1)) + ' ) Records Inserted'  FROM dbo.WorkForceStaffing_Fact_Quotes(NOLOCK) 
	EXEC dbo.PB_Log_Insert 'WorkForceStaffing_Fact_Quotes',@Desc,'WorkForce Staffing'

	SET NOCOUNT OFF;
END
