/**************************************************************************************************************************************************
**               AUTHOR : Joni Khandekar
**        CREATION DATE : 03/7/2022
**              VERSION : 1.0
**          DATABASE(S) : Caboodle
**          WRITTEN FOR : CompMed
**        SQL FILE NAME : DNB
**          TEMPLATE ID : 
**             TICKET # : 
**
**              PURPOSE : HIM VENDOR DNFB ACCOUNTS
** BI DOCUMENT LOCATION : https://rocketsutoledo.sharepoint.com/:f:/s/EPICEMRProject-DTAS/Ei4adPjFbNFCuaUChmW-uOcBnzXCWblb51o64W7RfTYqTQ?e=jfTzuR
***************************************************************************************************************************************************
** CHANGES:
**      Date       Ticket #	    Changes By			Revision #	Comments  
**      ---------- -----------	----------------	----------	------------------------------------
**		MM/DD/YYYY XXXX	        Developer	        1.X			Modified XXXXX.
***************************************************************************************************************************************************/
CREATE PROCEDURE [dbo].[GetCompMedRegistrationLog]
AS
SELECT REPLACE(CAST(EC.AdmissionInstant AS DATE),'-','/') 'ADMIT DATE/TIME',
       EC.EncounterEpicCsn 'Patient Account',
       P.PrimaryMrn 'Patient MRN',
       P.Name 'PATIENT NAME',
       REPLACE(CAST(P.BirthDate AS DATE),'-','/') 'Patient DOB',
       DI.Name 'ADMITTING DIAGNOSIS',
       AP.ProviderEpicId 'ATTENDING PHYSICIAN ID',
       AP.Name 'ATTENDING PHYSICIAN NAME',
       C.PayorName 'INSURANCE CARRIER NAME',
       ED.EdDisposition 'DISCHARGE DISPOSITION',
       D.DateValue,       
       EC.PatientClass 'PATIENT TYPE'
FROM EdVisitFact ED
INNER JOIN PatientDim P
    ON ED.PatientDurableKey = P.PatientKey
INNER JOIN EncounterFact EC
    ON ED.EncounterKey = EC.EncounterKey
INNER JOIN DateDim D
    ON EC.AdmissionDateKey = D.DateKey
INNER JOIN DiagnosisDim DI
    ON ED.PrimaryEdDiagnosisKey = DI.DiagnosisKey
INNER JOIN ProviderDim AP
    ON EC.AttendingProviderDurableKey = AP.DurableKey
    AND AP.IsCurrent = '1'
INNER JOIN CoverageDim C
    ON ED.CoverageKey = C.CoverageKey
WHERE ED.EdVisitKey > 0
AND ED.HospitalAdmissionKey IN ('-2','-1')
AND D.DateValue = DATEADD(DAY,-1,CAST(GETDATE() AS DATE))