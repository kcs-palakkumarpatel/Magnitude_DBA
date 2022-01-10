CREATE VIEW [dbo].[PB_VW_Masslift_Fact_SalesStack]
AS
SELECT X.* ,Y.CapturedDate AS ResponseDate,
Y.Name AS CustomerName,Y.Surname AS CustomerSurname,Y.Company AS CustomerCompany,Y.Email AS CustomerEmail,Y.Mobile AS CustomerMobile,
Y.[Your title],
Y.[Do you approve?],
Y.[Why do you not approve?] AS [If not, please comment],
Y.[Is your signature required for sign off?],
Y.[Selling Price (ZAR)],
Y.[Cost Price (ZAR)],
Y.[Gross Profit (ZAR)],
Y.[Gross Profit %],
Y.[Your signature] FROM(

SELECT 
EstablishmentName,CapturedDate,ReferenceNo,
IsPositive,Status,PI,
UserId,UserName,Longitude,Latitude,

[Salesmen name: ],
[Customer ],
[Serial number ],
[Model ],
[Mast ],
[Delivery address ],
[Contact person on ],
[Contact number ],
[Bank / finance con],
[Bank Contact number ],
[Expected date of d],
[Client Chose ],
[MF Costing sheet ],
[MF Signed quote ],
[MF Masslift credit ap],
[MF Site Survey ],
[MF Financial Survey ],
[MF AIM ],
[MF RV Percentage ],
[MF RV percentage (%)],
[MF Bank approval],
[MF Bank Name],
[MF Signed RV addendum],
[MF Signed ownership ],
[MF Rental with owner],
[MF Rental No Ownershi],
[OP Costing sheet ],
[OP Signed quote ],
[OP Site survey],
[OP Financial survey],
[OP Purchase order ],
[OP Existing client ],
[OP AIM ],
[OP PMA],
[CF Costing sheet ],
[CF Signed quote ],
[CF Masslift credit ap],
[CF Site survey ],
[CF Financial survey ],
[CF AIM],
[CF RV percentage (%)],
[CF Return unit fleet ],
[CF Rental without own],
[CF Bank Name ],
[CF Rental with owners],
[BB Costing sheet ],
[BB Signed quote ],
[BB Masslift credit ap],
[BB Site survey ],
[BB Financial survey ],
[BB AIM],
[BB RV percentage (%)],
[BB Bank approval ],
[BB Bank name ],
[BB Signed ownership ],
[BB Signed MRA],
[BB Sunlyn agreement],
[MB Costing sheet ],
[MB Signed quote ],
[MB Financial survey ],
[MB Site survey ],
[MB Masslift credit ap],
[MB Signed MRA ],
[Model: ],
[S/Shift ],
[Forks (mm)],
[Tyres (If not stan],
[FMX],
[Contact for FMX ],
[Email for FMX cont],
[TXP transmission p],
[Donaldson filtrati],
[PTX purifier ],
[Spray (if not stan],
[Transaction ],
[Machine Serial number ],
[Quantity ],
[Type ],
[Amount],
[Invoice ],
[Date Paid ],
[If other, please s],
[Is this a new or e],
[ORDER INTAKE BY TR],
[Branch],
[Dealer ],
[New or used ]
FROM(
SELECT
E.EstablishmentName,DATEADD(MINUTE,AM.TimeOffSet,AM.CreatedOn) AS CapturedDate,AM.id AS ReferenceNo,
AM.IsPositive,AM.IsResolved AS Status,AM.PI,
A.Detail AS Answer
,Q.ShortName AS Question ,U.Id AS UserId, u.name AS UserName,
AM.Longitude,AM.Latitude


FROM dbo.[Group] G
INNER JOIN EstablishmentGroup EG ON G.id=EG.groupid AND G.Id=463 AND EG.Id =3997
INNER JOIN Establishment E ON  E.EstablishmentGroupId=EG.Id
INNER JOIN SeenClientAnswerMaster AM ON AM.EstablishmentId=E.id AND (AM.IsDeleted=0 OR AM.IsDeleted=NULL) AND (AM.IsDisabled=0 OR AM.IsDisabled IS NULL) 
INNER JOIN [SeenClientAnswers] A ON A.SeenclientAnswerMasterId=AM.id
INNER JOIN SeenClientQuestions Q ON Q.id=A.QuestionId AND Q.IsRequiredInBI=1
LEFT OUTER JOIN dbo.[Appuser] u ON u.id=AM.CreatedBy
LEFT OUTER JOIN ContactDetails CD ON CD.contactMasterid=AM.ContactMasterid AND CD.contactQuestionId=2843
/*Where (G.Id=463 and EG.Id =3997
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) and (AM.IsDisabled=0 or AM.IsDisabled is null) 

and Q.id in(33322,31432,31433,31434,31435,31436,31437,31438,31439,31440,31441,33831,31446,31447,34142,31449,31450,31451,31452,33713,31453,33715,31454,31455,31445,31444,33718,33719,33720,
33721,33722,34143,33724,33725,33747,33748,34145,33750,33751,33739,33740,31513,33745,33742,33746,33811,31479,34146,31481,31480,33817,33819,31483,33821,33823,33825,33827,31489,31490,31491,
31492,34144,31494,33323,31496,31497,31498,31499,31500,31501,31502,31503,31504,31506,31507,31508,32036,31509,31510,31511,31512,31514,64739,64741,64740,64742,64746))*/



) S
PIVOT (
MAX(Answer)
FOR  Question IN (
[Salesmen name: ],
[Customer ],
[Serial number ],
[Model ],
[Mast ],
[Delivery address ],
[Contact person on ],
[Contact number ],
[Bank / finance con],
[Bank Contact number ],
[Expected date of d],
[Client Chose ],
[MF Costing sheet ],
[MF Signed quote ],
[MF Masslift credit ap],
[MF Site Survey ],
[MF Financial Survey ],
[MF AIM ],
[MF RV Percentage ],
[MF RV percentage (%)],
[MF Bank approval],
[MF Bank Name],
[MF Signed RV addendum],
[MF Signed ownership ],
[MF Rental with owner],
[MF Rental No Ownershi],
[OP Costing sheet ],
[OP Signed quote ],
[OP Site survey],
[OP Financial survey],
[OP Purchase order ],
[OP Existing client ],
[OP AIM ],
[OP PMA],
[CF Costing sheet ],
[CF Signed quote ],
[CF Masslift credit ap],
[CF Site survey ],
[CF Financial survey ],
[CF AIM],
[CF RV percentage (%)],
[CF Return unit fleet ],
[CF Rental without own],
[CF Bank Name ],
[CF Rental with owners],
[BB Costing sheet ],
[BB Signed quote ],
[BB Masslift credit ap],
[BB Site survey ],
[BB Financial survey ],
[BB AIM],
[BB RV percentage (%)],
[BB Bank approval ],
[BB Bank name ],
[BB Signed ownership ],
[BB Signed MRA],
[BB Sunlyn agreement],
[MB Costing sheet ],
[MB Signed quote ],
[MB Financial survey ],
[MB Site survey ],
[MB Masslift credit ap],
[MB Signed MRA ],
[Model: ],
[S/Shift ],
[Forks (mm)],
[Tyres (If not stan],
[FMX],
[Contact for FMX ],
[Email for FMX cont],
[TXP transmission p],
[Donaldson filtrati],
[PTX purifier ],
[Spray (if not stan],
[Transaction ],
[Machine Serial number ],
[Quantity ],
[Type ],
[Amount],
[Invoice ],
[Date Paid ],
[If other, please s],
[Is this a new or e],
[ORDER INTAKE BY TR],
[Branch],
[Dealer ],
[New or used ]
))P

)X 
LEFT OUTER JOIN

(
SELECT * FROM(
SELECT
E.EstablishmentName,DATEADD(MINUTE,AM.TimeOffSet,AM.CreatedOn) AS CapturedDate,AM.id AS ReferenceNo,
AM.IsPositive,AM.IsResolved AS Status,AM.PI,AM.SeenclientAnswerMasterid,
A.Detail AS Answer,Q.QuestionTitle AS Question,

(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(CASE WHEN SAM.IsSubmittedForGroup=1 THEN SAC.ContactMasterId  ELSE SAM.ContactMasterId END) AND CD.IsDeleted = 0 AND CD.Detail<>'' 
AND CD.contactQuestionId=2843
) AS Company,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(CASE WHEN SAM.IsSubmittedForGroup=1 THEN SAC.ContactMasterId  ELSE SAM.ContactMasterId END) AND CD.IsDeleted = 0 AND CD.Detail<>'' 
AND CD.contactQuestionId=2842
) AS Email,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(CASE WHEN SAM.IsSubmittedForGroup=1 THEN SAC.ContactMasterId  ELSE SAM.ContactMasterId END) AND CD.IsDeleted = 0 AND CD.Detail<>'' 
AND CD.contactQuestionId=2841
) AS Mobile,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(CASE WHEN SAM.IsSubmittedForGroup=1 THEN SAC.ContactMasterId  ELSE SAM.ContactMasterId END) AND CD.IsDeleted = 0 AND CD.Detail<>'' 
AND CD.contactQuestionId=2839
) AS Name,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(CASE WHEN SAM.IsSubmittedForGroup=1 THEN SAC.ContactMasterId  ELSE SAM.ContactMasterId END) AND CD.IsDeleted = 0 AND CD.Detail<>'' 
AND CD.contactQuestionId=2840
) AS Surname,
AM.Longitude,AM.Latitude


FROM dbo.[Group] G
INNER JOIN EstablishmentGroup EG ON G.id=EG.groupid AND G.Id=463 AND EG.Id =3997
INNER JOIN Establishment E ON  E.EstablishmentGroupId=EG.Id
INNER JOIN AnswerMaster AM ON AM.EstablishmentId=E.id AND (AM.IsDeleted=0 OR AM.IsDeleted=NULL) AND (AM.IsDisabled=0 OR AM.IsDisabled IS NULL) 
INNER JOIN [Answers] A ON A.AnswerMasterId=AM.id
INNER JOIN Questions Q ON Q.id=A.QuestionId AND Q.IsRequiredInBI=1
LEFT OUTER JOIN dbo.[Appuser] u ON u.id=AM.CreatedBy
LEFT OUTER JOIN SeenClientAnswerMaster SAM ON SAM.id=AM.SeenClientAnswerMasterId
	LEFT OUTER JOIN SeenClientAnswerChild SAC ON SAM.id=SAC.SeenClientAnswerMasterId AND SAC.Id=AM.SeenClientAnswerChildId
/*Where (G.Id=463 and EG.Id =3997
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) and (AM.IsDisabled=0 or AM.IsDisabled is null) 

and Q.id in(19593,19594,19595,19596,19598,19600,19601,19602,19603)*/
) S
PIVOT (
MAX(Answer)
FOR  Question IN (
[Your title],
[Do you approve?],
[Why do you not approve?],
[Is your signature required for sign off?],
[Your signature],
[Selling Price (ZAR)],
[Cost Price (ZAR)],
[Gross Profit (ZAR)],
[Gross Profit %])
)P

)Y ON X.ReferenceNo=Y.seenclientanswermasterid
