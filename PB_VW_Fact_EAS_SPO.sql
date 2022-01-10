CREATE view [dbo].[PB_VW_Fact_EAS_SPO] as



  Select 
  EstablishmentName,CapturedDate,ReferenceNo,
UserName ,A.RepeatCount,FirstResponseDate,
[Short Title],
[Project leader],
[Deadline],
[Description & goal],
[Desired outcomes],
[Overall purpose],
[Revenue or Cost],
[Milestone Number],
[Description],
[Planned Start Date],
[Plan Finish Date],
ResponseDate,SeenclientAnswerMasterId,B.RepeatCount as RepeatCount_1,
[OVERALL average],
[Milestone #],
isnull([PROGRESS],'') as[PROGRESS],
isnull([BENEFITS],'') as[BENEFITS],
isnull([ISSUES to report],'') as[ISSUES to report],
isnull([Describe the issue],'') as[Describe the issue],
isnull([Issue Category],'') as [Issue Category],
isnull([Who can assist you],'') as [Who can assist you]
   from  Temp_FA_Captured A left outer join Temp_FA_Response B on A.ReferenceNo=B.SeenclientAnswermasterid and A.FirstResponseDate=B.ResponseDate
  
