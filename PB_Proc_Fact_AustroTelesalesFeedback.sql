

CREATE Procedure [dbo].[PB_Proc_Fact_AustroTelesalesFeedback]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Fact_AustroTelesalesFeedback','Fact_AustroTelesalesFeedback Start','Austro'

	Truncate table dbo.Fact_AustroTelesalesFeedback

	
	Insert into Fact_AustroTelesalesFeedback(EstablishmentName ,ResponseDate ,ReferenceNo ,SeenClientAnswerMasterId ,IsPositive ,Status ,UserName ,[Info Correct ] ,[Make Contact] ,
	[General Comments ])
	select EstablishmentName ,ResponseDate ,ReferenceNo ,SeenClientAnswerMasterId ,IsPositive ,Status ,UserName ,[Info Correct ] ,[Make Contact] ,[General Comments ]
	 from [PB_VW_Fact_AustroTelesalesFeedback]

	Select @Desc = 'Fact_AustroTelesalesFeedback Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Fact_AustroTelesalesFeedback(NoLock) 
	Exec dbo.PB_Log_Insert 'Fact_AustroTelesalesFeedback',@Desc,'Austro'

	
	Set NoCount OFF;
END
