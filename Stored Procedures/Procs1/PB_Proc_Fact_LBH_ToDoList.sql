

CREATE Procedure [dbo].[PB_Proc_Fact_LBH_ToDoList]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Fact_LBH_ToDoList','Fact_LBH_ToDoList Start','LBH To Do List'

	Truncate table dbo.Fact_LBH_ToDoList

	
	Insert into Fact_LBH_ToDoList(EstablishmentName,CapturedDate,ReferenceNo,Status,UserName,ResolvedDate,
	FirstResponseDate,[Task],[Priority],[Category],[Deadline],[Comment],IsOutStanding,ResponseDate,
	SeenClientAnswerMasterId,[Permanent fix],[Time spent],[Deadline met],[Cost])
	select EstablishmentName,CapturedDate,ReferenceNo,Status,UserName,ResolvedDate,
	FirstResponseDate,[Task],[Priority],[Category],[Deadline],[Comment],IsOutStanding,ResponseDate,
	SeenClientAnswerMasterId,[Permanent fix],[Time spent],[Deadline met],[Cost]
	from PB_VW_Fact_LBH_ToDoList

	Select @Desc = 'Fact_LBH_ToDoList Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Fact_LBH_ToDoList(NoLock) 
	Exec dbo.PB_Log_Insert 'Fact_LBH_ToDoList',@Desc,'LBH To Do List'

	Set NoCount OFF;
END
