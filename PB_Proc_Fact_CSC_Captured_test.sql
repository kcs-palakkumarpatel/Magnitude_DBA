CREATE Procedure [dbo].[PB_Proc_Fact_CSC_Captured_test]
As
BEGIN
	set NoCount On;

	SELECT * INTO #TMP1
FROM
(
select EstablishmentName,CapturedDate,ReferenceNo,[Name],
[Surname],[Cell],[Email],[Gender],[Ethnic Group],[Alternate Number],[Vehicle Registration]
from(
select E.EstablishmentName,
dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,Q.QuestionTitle AS Question,A.Detail as Answer,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=555
) as Name,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=556
) as Surname,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=1584
) as [Alternate Number],
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=557
) as Cell,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=558
) as Email,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=704
) as Gender,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=705
) as [Ethnic Group]
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid AND G.Id=70 and EG.Id =429
inner join Establishment E on E.EstablishmentGroupId=EG.Id
inner join seenclientAnswerMaster AM on AM.EstablishmentId=E.id AND (AM.IsDeleted=0 or AM.IsDeleted is null) 
inner join SeenclientAnswers A on A.SeenClientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (2528)
left outer join SeenclientAnswerChild SAC on SAC.SeenclientANswerMasterID=AM.Id
) S
Pivot (
Max(Answer)
For  Question In (
[Vehicle Registration]
))p
) AS T


	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Fact_CSC_Captured','Fact_CSC_Captured Start','Car Service City'

	Truncate table dbo.Fact_CSC_Captured
	
	Insert into Fact_CSC_Captured(EstablishmentName,CapturedDate,ReferenceNo,[Name],[Surname],[Cell],[Email],[Gender],
[Ethnic Group],[Alternate Number],[Vehicle Registration])
select 
	EstablishmentName,CapturedDate,ReferenceNo,[Name],[Surname],[Cell],[Email],[Gender],
[Ethnic Group],[Alternate Number],[Vehicle Registration]
  from #TMP1

  drop table #TMP1

	Select @Desc = 'Fact_CSC_Captured Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Fact_CSC_Captured(NoLock) 
	Exec dbo.PB_Log_Insert 'Fact_CSC_Captured',@Desc,'Car Service City'

	Truncate table dbo.Dim_UpdateDateTimeCSC

	Insert Into dbo.Dim_UpdateDateTimeCSC
	Select * From [dbo].[Vw_Dim_UpdateDateTime]

	Select @Desc = 'Dim_UpdateDateTimeCSC Completed.( 1 ) Records Inserted' 
	Exec dbo.PB_Log_Insert 'Dim_UpdateDateTimeCSC',@Desc,'Reef Catering'


	Set NoCount OFF;
END
