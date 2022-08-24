	/******************************************************************************************************************************
**               AUTHOR : Amanda Gladieux
**        CREATION DATE : 11/01/2021
**              VERSION : 1.0
**          DATABASE(S) : Caboodle
**          WRITTEN FOR : Mental Health Outcomes
**        SQL FILE NAME : 1469
**          TEMPLATE ID : 
**             TICKET # : 
**
**              PURPOSE : Patient Health Questionaire (PHQ-9)
** BI DOCUMENT LOCATION : 
*******************************************************************************************************************************
** CHANGES:
**      Date       Ticket #     Changes By                    Revision #    Comments  
**      ---------- -----------    ----------------     ----------    ------------------------------------
**            MM/DD/YYYY XXXX              Developer            1.X                Modified XXXXX.
*******************************************************************************************************************************/
CREATE PROCEDURE [dbo].[GetPatientHealthQuestionnaire1469]
AS

WITH sbhpatients AS
(SELECT DISTINCT  
	ef.patientkey,
	ef.PatientDurableKey,
	ef.EncounterEpicCsn,
	ef.EncounterKey,
	ef.DischargeInstant,
	ef.AdmissionInstant,
	dd.DepartmentKey,
	dd.DepartmentName,
	dd.DepartmentExternalName,
	pd.PrimaryMrn,
	pd.FirstName,
	pd.LastName
FROM 
	EncounterFact ef
INNER JOIN 
	departmentdim dd
ON 
	ef.DepartmentKey = dd.DepartmentKey
INNER JOIN 
	PatientDim pd
ON 
	pd.DurableKey = ef.PatientDurableKey
WHERE 
	dd.DepartmentName in ('KC SENIOR BH','KC CHILD & ADOLESCENT','UTMC RECOVERY')
AND 
	(ef.AdmissionInstant IS NOT NULL or ef.DischargeInstant IS NOT NULL)
),
sbhscores AS (
SELECT 
	CASE WHEN sbhp.DepartmentName = 'KC SENIOR BH' THEN '9305'
		 WHEN sbhp.DepartmentName = 'KC CHILD & ADOLESCENT' THEN '3246'  
		 WHEN sbhp.DepartmentName = 'UTMC RECOVERY' THEN '5189'
	END AS PROGCODE,
	sbhp.EncounterEpicCsn AS PTACCTNO,
	sbhp.FirstName as fname, 
	sbhp.LastName as lname,
	sbhp.PrimaryMrn as mrn,
	MAX(CASE  WHEN FlowsheetRowEpicId = '7580' AND value = 'Admission' THEN 1 
			  WHEN FlowsheetRowEpicId = '7580' AND value = 'Discharge' THEN 2 
		END) AS AWID,
	MAX(cast(format(TakenInstant,'MM/dd/yyyy') as varchar(15))) AS DTCDOC, 
	MAX(CASE WHEN FlowsheetRowEpicId = '1570000014' THEN value 
		END) AS PHQ901,
	MAX(CASE WHEN FlowsheetRowEpicId = '1570000015' THEN value 
		END) AS PHQ902,
	MAX(CASE WHEN FlowsheetRowEpicId = '1570000018' THEN value 
		END) AS PHQ903,
	MAX(CASE WHEN FlowsheetRowEpicId = '1570000019' THEN value 
		END) AS PHQ904,
	MAX(CASE WHEN FlowsheetRowEpicId = '1570000020' THEN value 
		END) AS PHQ905,
	MAX(CASE WHEN FlowsheetRowEpicId = '1570000021' THEN value 
		END) AS PHQ906,
	MAX(CASE WHEN FlowsheetRowEpicId = '1570000022' THEN value 
		END) AS PHQ907,
	MAX(CASE WHEN FlowsheetRowEpicId = '1570000023' THEN value		
		END) AS PHQ908,
	MAX(CASE WHEN FlowsheetRowEpicId = '1570000024' THEN value 
		END) AS PHQ909,
	MAX(CASE WHEN FlowsheetRowEpicId = '1570000025' THEN value 
		END) AS PHQ9TOT,
	MAX(CASE WHEN FlowsheetRowEpicId = '1570400187' AND value='Not difficult at all' THEN 0
		  	 WHEN FlowsheetRowEpicId = '1570400187' AND value='Somewhat difficult' THEN 1
			 WHEN FlowsheetRowEpicId = '1570400187' AND value='Very difficult' THEN 2
			 WHEN FlowsheetRowEpicId = '1570400187' AND value='Extremely difficult' THEN 3
		END) AS PHQ910,
	CAST(format(CURRENT_TIMESTAMP,'MM/dd/yyyy hh:mm:ss') as varchar(20)) AS TIME_STAMP,
	CASE WHEN sbhp.DepartmentName = 'KC SENIOR BH' THEN '9305.'
		 WHEN sbhp.DepartmentName = 'KC CHILD & ADOLESCENT' THEN '3246.'  
		 WHEN sbhp.DepartmentName = 'UTMC RECOVERY' THEN '5189.'
	END  + CAST(format(CURRENT_TIMESTAMP,'dd-MM-yyyy') AS varchar(15)) AS CSID,
	'1469' AS FORM_ID
FROM 
	FlowsheetRowDim frd
LEFT OUTER JOIN 
	FlowsheetValueFact fvf
ON 
	frd.FlowsheetRowKey = fvf.FlowsheetRowKey
LEFT OUTER JOIN 
	sbhpatients sbhp
ON	
	fvf.PatientDurableKey = sbhp.PatientDurableKey
WHERE 
	FlowsheetRowEpicId in ('7580','1570000014','1570000015','1570000018','1570000019','1570000020','1570000021',
	'1570000022','1570000023','1570000024','1570000025','1570400187')
AND 
	sbhp.PatientDurableKey IS NOT NULL
AND
	fvf.TakenInstant >= DATEADD(day, -28, GETDATE())
GROUP BY  
	sbhp.EncounterEpicCsn,
	sbhp.DepartmentName,
	sbhp.FirstName,
	sbhp.LastName,
	sbhp.PrimaryMrn,
	fvf.DateKey

	)
SELECT 
	PROGCODE,
	PTACCTNO,
	fname,
	lname,
	mrn,
	AWID,
	DTCDOC,
	ISNULL(CONVERT(VARCHAR, PHQ901),'') AS PHQ901,
	ISNULL(CONVERT(VARCHAR, PHQ902),'') AS PHQ902,
	ISNULL(CONVERT(VARCHAR, PHQ903),'') AS PHQ903,
	ISNULL(CONVERT(VARCHAR, PHQ904),'') AS PHQ904,
	ISNULL(CONVERT(VARCHAR, PHQ905),'') AS PHQ905,
	ISNULL(CONVERT(VARCHAR, PHQ906),'') AS PHQ906,
	ISNULL(CONVERT(VARCHAR, PHQ907),'') AS PHQ907,
	ISNULL(CONVERT(VARCHAR, PHQ908),'') AS PHQ908,
	ISNULL(CONVERT(VARCHAR, PHQ909),'') AS PHQ909,
	ISNULL(CONVERT(VARCHAR, PHQ9TOT),'') AS PHQ9TOT,
	ISNULL(CONVERT(VARCHAR, PHQ910),'') AS PHQ910,
	TIME_STAMP,
	CSID,
	FORM_ID
FROM
	sbhscores
RETURN 0
