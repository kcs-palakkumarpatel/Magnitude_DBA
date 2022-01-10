
Create Procedure [dbo].[PB_Proc_Topbet_Fact_TrainingRequest]
As
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Topbet_Fact_TrainingRequest','Topbet_Fact_TrainingRequest Start','Topbet'

	Truncate table dbo.Topbet_Fact_TrainingRequest

	
	Insert into Topbet_Fact_TrainingRequest(EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,
UserId,UserName,Longitude,Latitude,RepeatCount,[Branch manager],[Branch / Location],[Type of Training],
[Training Needs],[Who needs this Tra],[Name],[Surname],[Mobile],[E-Mail],ResponseDate,
CustomerName,[Training success],[Training],[When can this be d],[Time taken])
	select EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,
UserId,UserName,Longitude,Latitude,RepeatCount,[Branch manager],[Branch / Location],[Type of Training],
[Training Needs],[Who needs this Tra],[Name],[Surname],[Mobile],[E-Mail],ResponseDate,
CustomerName,[Training success],[Training],[When can this be d],[Time taken]
	 from [PB_VW_Topbet_Fact_TrainingRequest]

	Select @Desc = 'Topbet_Fact_TrainingRequest Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Topbet_Fact_TrainingRequest(NoLock) 
	Exec dbo.PB_Log_Insert 'Topbet_Fact_TrainingRequest',@Desc,'Topbet'
	Set NoCount OFF;
