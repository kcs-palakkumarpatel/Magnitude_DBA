

Create Procedure [dbo].[PB_Proc_Masslift_Fact_TaskCaptured]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Masslift_Fact_TaskCaptured','Masslift_Fact_TaskCaptured Start','Masslift'

	Truncate table dbo.Masslift_Fact_TaskCaptured

	
	Insert into Masslift_Fact_TaskCaptured(EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,PI,
UserId,UserName,[Name],[Surname],[Mobile],[Email ],[Task Title],[Task Description],[Task Category],
[Deadline],[Allocated Time])
	select EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,PI,
UserId,UserName,[Name],[Surname],[Mobile],[Email ],[Task Title],[Task Description],[Task Category],
[Deadline],[Allocated Time]
	 from [PB_VW_Masslift_Fact_TaskCaptured]

	Select @Desc = 'Masslift_Fact_TaskCaptured Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Masslift_Fact_TaskCaptured(NoLock) 
	Exec dbo.PB_Log_Insert 'Masslift_Fact_TaskCaptured',@Desc,'Masslift'

	Set NoCount OFF;
END
