

CREATE Procedure [dbo].[PB_Proc_Fact_Beekman_BodyBliss]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Fact_Beekman_BodyBliss','Fact_Beekman_BodyBliss Start','Beekman New'

	Truncate table dbo.Fact_Beekman_BodyBliss

	
	Insert into Fact_Beekman_BodyBliss(EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,PI,Answer,Rating,Question,FirstActionDate,ResolvedDate,Longitude,Latitude,AutoResolved)
	select EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,PI,Answer,Rating,Question,FirstActionDate,ResolvedDate,Longitude,Latitude,AutoResolved
	 from [PB_VW_Fact_Beekman_BodyBliss]

	Select @Desc = 'Fact_Beekman_BodyBliss Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Fact_Beekman_BodyBliss(NoLock) 
	Exec dbo.PB_Log_Insert 'Fact_Beekman_BodyBliss',@Desc,'Beekman New'

	Set NoCount OFF;
END
