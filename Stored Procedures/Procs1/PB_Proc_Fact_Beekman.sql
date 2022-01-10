
CREATE Procedure [dbo].[PB_Proc_Fact_Beekman]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Fact_Beekman','Fact_Beekman Start','Beekman'

	Truncate table dbo.Fact_Beekman

	Insert Into dbo.Fact_Beekman(Survey,EstablishmentGroupName,EstablishmentName ,CapturedDate ,ReferenceNo,IsPositive,Status ,PI,Detail,Answer ,QuestionId,Question) 
	Select Survey,EstablishmentGroupName,EstablishmentName ,CapturedDate ,ReferenceNo,IsPositive,Status ,PI,Detail,Answer ,QuestionId,Question From dbo.BI_Vw_Fact_Beekman


	Select @Desc = 'Fact_Beekman Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Fact_Beekman(NoLock) 
	Exec dbo.PB_Log_Insert 'Fact_Beekman',@Desc,'Beekman'


	Exec dbo.PB_Log_Insert 'Dim_UpdateDateTime','Dim_UpdateDateTime Start','Beekman'


	Truncate table dbo.Dim_UpdateDateTime

	Insert Into dbo.Dim_UpdateDateTime
	Select * From [dbo].[Vw_Dim_UpdateDateTime]

	Select @Desc = 'Dim_UpdateDateTime Completed.( 1 ) Records Inserted' 
	Exec dbo.PB_Log_Insert 'Dim_UpdateDateTime',@Desc,'Beekman'

	Set NoCount OFF;
END


