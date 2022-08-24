
/******************************************************************************************************************************
**               AUTHOR : Theja Kandra
**        CREATION DATE : 02/22/2022
**              VERSION : 1.0
**          DATABASE(S) : Clarity
**          WRITTEN FOR : Humana Extract
**        SQL FILE NAME : Humana Extract
**          TEMPLATE ID : N/A
**             TICKET # : N/A
**
**              PURPOSE : Pull info for Humana extract
** BI DOCUMENT LOCATION : N/A
*******************************************************************************************************************************
** CHANGES:
**      Date       Ticket #	    Changes By			Revision #	Comments  
**      ---------- -----------	----------------	----------	------------------------------------
**		MM/DD/YYYY XXXX	        Developer	        1.X			Modified XXXXX.
*******************************************************************************************************************************/
CREATE PROCEDURE [dbo].[GetSupplementalDataForHumana]
	
AS


DECLARE @StartDate AS DATETIME = EPIC_UTIL.EFN_DIN('MB-1');
DECLARE @EndDate AS DATETIME = DATEADD(S, 86399, EPIC_UTIL.EFN_DIN('ME-1'));

WITH
MEDID
AS 
(
SELECT 
DISTINCT 
ML.COVERAGE_ID, 
PAT_ID, 
CASE WHEN FIN_CLASS_C = 2 THEN MEM_NUMBER END AS 'Member Medicare ID', 
CASE WHEN FIN_CLASS_C = 3 THEN MEM_NUMBER END AS 'Member Medicaid ID'  
FROM V_COVERAGE_PAYOR_PLAN V
LEFT JOIN COVERAGE C ON C.COVERAGE_ID = V.COVERAGE_ID
LEFT JOIN COVERAGE_MEM_LIST ML ON ML.COVERAGE_ID = C.COVERAGE_ID
where FIN_CLASS_C in (2,3)
),

DXG
AS
(
select 
t.TX_ID,
MAX(t.[ICD Diagnosis Code 1]) I1,
MAX(t.[ICD Diagnosis Code 2]) I2,
MAX(t.[ICD Diagnosis Code 3]) I3,
MAX(t.[ICD Diagnosis Code 4]) I4,
MAX(t.[ICD Diagnosis Code 5]) I5,
MAX(t.[ICD Diagnosis Code 6]) I6,
MAX(t.[ICD Diagnosis Code 7]) I7,
MAX(t.[ICD Diagnosis Code 8]) I8,
MAX(t.[ICD Diagnosis Code 9]) I9,
MAX(t.[ICD Diagnosis Code 10]) I10





from (
select distinct TX_ID, 
case when htd.line = 1 then v.REF_BILL_CODE end as [ICD Diagnosis Code 1], 
case when htd.line = 2 then v.REF_BILL_CODE end as [ICD Diagnosis Code 2],
case when htd.line = 3 then v.REF_BILL_CODE end as [ICD Diagnosis Code 3],
case when htd.line = 4 then v.REF_BILL_CODE end as [ICD Diagnosis Code 4],
case when htd.line = 5 then v.REF_BILL_CODE end as [ICD Diagnosis Code 5],
case when htd.line = 6 then v.REF_BILL_CODE end as [ICD Diagnosis Code 6],
case when htd.line = 7 then v.REF_BILL_CODE end as [ICD Diagnosis Code 7],
case when htd.line = 8 then v.REF_BILL_CODE end as [ICD Diagnosis Code 8],
case when htd.line = 9 then v.REF_BILL_CODE end as [ICD Diagnosis Code 9],
case when htd.line = 10 then v.REF_BILL_CODE end as [ICD Diagnosis Code 10]



from hsp_tx_diag htd
left join V_CODING_ALL_DX_PX_LIST v on v.DX_ID = htd.DX_ID

) t

GROUP BY TX_ID
),

PBDXG 
AS 
(
SELECT 
DISTINCT 
TX_ID, 
V1.REF_BILL_CODE I1,
V2.REF_BILL_CODE I2,
V3.REF_BILL_CODE I3,
V4.REF_BILL_CODE I4,
V5.REF_BILL_CODE I5,
V6.REF_BILL_CODE I6,
'' I7,
'' I8,
'' I9,
'' I10

FROM ARPB_TRANSACTIONS ATX
LEFT JOIN CLARITY_EDG V1 ON V1.DX_ID = ATX.PRIMARY_DX_ID
LEFT JOIN CLARITY_EDG V2 ON V2.DX_ID = ATX.DX_TWO_ID
LEFT JOIN CLARITY_EDG V3 ON V3.DX_ID = ATX.DX_THREE_ID
LEFT JOIN CLARITY_EDG V4 ON V4.DX_ID = ATX.DX_FOUR_ID
LEFT JOIN CLARITY_EDG V5 ON V5.DX_ID = ATX.DX_FIVE_ID
LEFT JOIN CLARITY_EDG V6 ON V6.DX_ID = ATX.DX_SIX_ID
)
---------------------
--BP, BMI
---------------------
SELECT 
DISTINCT
c.MEM_NUMBER [Member Card ID],
P.PAT_FIRST_NAME [Member First Name],
P.PAT_LAST_NAME [Member Last Name],
convert (varchar, P.BIRTH_DATE, 112) [Member DOB],
CASE WHEN P.SEX_C = 1 THEN 'F' WHEN P.SEX_C = 2 THEN 'M' ELSE 'U' END [Member Gender],
replace (P.SSN, '-','') [Member SSN],
MEDID.[Member Medicare ID] [Member Medicare ID],
MEDID.[Member Medicaid ID] [Member Medicaid ID],
SER.NPI [Rendering Provider NPI],
convert (varchar, v.CONTACT_DATE, 112) [Service Date],
''[Revenue Code],
''[ICD Diagnosis Code 1],
''[ICD Diagnosis Code 2],
''[ICD Diagnosis Code 3],
''[ICD Diagnosis Code 4],
''[ICD Diagnosis Code 5],
''[ICD Diagnosis Code 6],
''[ICD Diagnosis Code 7],
''[ICD Diagnosis Code 8],
''[ICD Diagnosis Code 9],
''[ICD Diagnosis Code 10],
''[Procedural ICD Code 1],
''[Procedural ICD Code 2],
''[Procedural ICD Code 3],
''[Procedural ICD Code 4],
''[Procedural ICD Code 5],
''[Procedural ICD Code 6],
''[Procedural ICD Code 7],
''[Procedural ICD Code 8],
''[Procedural ICD Code 9],
''[Procedural ICD Code 10],
'10' [ICD Version],
''[CPT/CPTII/HCPCS Code],
''[CPT Modifier 1],
''[CPT Modifier 2],
''[CPT Result],
''[LOINC Code],
''[LOINC Result],
cast (V.BMI as varchar) [BMI Value],	
--ROUND((WEIGHT/16),2) 
'' [Member Weight],	
cast (BP_SYSTOLIC as varchar) [BP Systolic],	
cast (BP_DIASTOLIC as varchar) [BP Diastolic],	
''[NDC Code],	
''[SNOMED Code],
''[Discharge Status Code]

FROM 
V_PAT_ENC V
LEFT JOIN COVERAGE_MEM_LIST C ON C.COVERAGE_ID = V.COVERAGE_ID AND V.PAT_ID = C.PAT_ID
LEFT JOIN PATIENT P ON P.PAT_ID = V.PAT_ID
LEFT JOIN MEDID ON MEDID.PAT_ID = V.PAT_ID
LEFT JOIN CLARITY_SER_2 SER ON SER.PROV_ID = V.VISIT_PROV_ID


WHERE (WEIGHT is not null or (BP_SYSTOLIC is not null and BP_DIASTOLIC is not null))

and c.MEM_NUMBER is not null

union all

Select 

DISTINCT
c.MEM_NUMBER [Member Card ID],
P.PAT_FIRST_NAME [Member First Name],
P.PAT_LAST_NAME [Member Last Name],
convert (varchar, P.BIRTH_DATE, 112) [Member DOB],
CASE WHEN P.SEX_C = 1 THEN 'F' WHEN P.SEX_C = 2 THEN 'M' ELSE 'U' END [Member Gender],
replace (P.SSN, '-','') [Member SSN],
MEDID.[Member Medicare ID] [Member Medicare ID],
MEDID.[Member Medicaid ID] [Member Medicaid ID],
SER.NPI [Rendering Provider NPI],
convert (varchar, PREV_CARE.SERVICE_DATE, 112) [Service Date],
''[Revenue Code],
I1 [ICD Diagnosis Code 1],
I2 [ICD Diagnosis Code 2],
I3 [ICD Diagnosis Code 3],
I4 [ICD Diagnosis Code 4],
I5 [ICD Diagnosis Code 5],
I6 [ICD Diagnosis Code 6],
I7 [ICD Diagnosis Code 7],
I8 [ICD Diagnosis Code 8],
I9 [ICD Diagnosis Code 9],
I10 [ICD Diagnosis Code 10],
''[Procedural ICD Code 1],
''[Procedural ICD Code 2],
''[Procedural ICD Code 3],
''[Procedural ICD Code 4],
''[Procedural ICD Code 5],
''[Procedural ICD Code 6],
''[Procedural ICD Code 7],
''[Procedural ICD Code 8],
''[Procedural ICD Code 9],
''[Procedural ICD Code 10],
'10' [ICD Version],
cast (PREV_CARE.CPT_CODE as varchar) [CPT/CPTII/HCPCS Code],
''[CPT Modifier 1],
''[CPT Modifier 2],
''[CPT Result],
''[LOINC Code],
''[LOINC Result],
'' [BMI Value],	
'' [Member Weight],	
'' [BP Systolic],	
'' [BP Diastolic],	
''[NDC Code],	
''[SNOMED Code],
''[Discharge Status Code]

FROM 
(
SELECT
DISTINCT TX.PAT_ENC_CSN_ID, TX.HSP_ACCOUNT_ID 'HAR_ID', H.PAT_ID, TX.CPT_CODE, SERVICE_DATE, H.ATTENDING_PROV_ID 'PROV_ID', H.COVERAGE_ID, I1, I2, I3, I4, I5, I6, I7, I8, I9, I10

FROM
HSP_TRANSACTIONS TX
LEFT JOIN F_ARHB_INACTIVE_TX I on I.TX_ID = TX.TX_ID

LEFT JOIN ZC_TX_SOURCE_HA ON ZC_TX_SOURCE_HA.TX_SOURCE_HA_C = TX.TX_SOURCE_HA_C
LEFT JOIN HSP_ACCOUNT H ON H.HSP_ACCOUNT_ID = TX.HSP_ACCOUNT_ID
LEFT JOIN DXG ON DXG.TX_ID = TX.TX_ID

WHERE
I.TX_ID IS NULL
AND TX.CPT_CODE IN 
( '45378', --Colonoscopy
'77067', --breast cancer screening
'G0438', 'G0439', -- Medicare Annual Wellness Visit
'99495', '99496', --Transiitonal Care Management
'77080', '77081', --Dexa Scan
'99497', --care for Older Adults
'4005F'-- Osteoporosis therpay prescribed
)
AND TX_TYPE_HA_C = 1

UNION ALL

SELECT ATX.PAT_ENC_CSN_ID, ATX.VISIT_NUMBER 'HAR_ID', ATX.PATIENT_ID 'PAT_ID', ATX.CPT_CODE, ATX.SERVICE_DATE, ATX.SERV_PROVIDER_ID 'PROV_ID', ATX.COVERAGE_ID, I1, I2, I3, I4, I5, I6, I7, I8, I9, I10
 

FROM ARPB_TRANSACTIONS ATX
LEFT JOIN PBDXG ON PBDXG.TX_ID = ATX.TX_ID
WHERE CPT_CODE IN ( '45378', --Colonoscopy
'77067', --breast cancer screening
'G0438', 'G0439', -- Medicare Annual Wellness Visit
'99495', '99496', --Transiitonal Care Management
'77080', '77081', --Dexa Scan
'99497', --care for Older Adults
'4005F'-- Osteoporosis therpay prescribed
)
AND TX_TYPE_C = 1 AND VOID_DATE IS NULL
)
PREV_CARE

LEFT JOIN COVERAGE_MEM_LIST C ON C.COVERAGE_ID = PREV_CARE.COVERAGE_ID AND PREV_CARE.PAT_ID = C.PAT_ID
LEFT JOIN PATIENT P ON P.PAT_ID = PREV_CARE.PAT_ID
LEFT JOIN MEDID ON MEDID.PAT_ID = PREV_CARE.PAT_ID
LEFT JOIN CLARITY_SER_2 SER ON SER.PROV_ID = PREV_CARE.PROV_ID

WHERE C.MEM_NUMBER is not null


union all

SELECT 
DISTINCT
c.MEM_NUMBER [Member Card ID],
P.PAT_FIRST_NAME [Member First Name],
P.PAT_LAST_NAME [Member Last Name],
convert (varchar, P.BIRTH_DATE, 112) [Member DOB],
CASE WHEN P.SEX_C = 1 THEN 'F' WHEN P.SEX_C = 2 THEN 'M' ELSE 'U' END [Member Gender],
replace (P.SSN, '-','') [Member SSN],
MEDID.[Member Medicare ID] [Member Medicare ID],
MEDID.[Member Medicaid ID] [Member Medicaid ID],
SER.NPI [Rendering Provider NPI],
convert (varchar, v.CONTACT_DATE, 112) [Service Date],
''[Revenue Code],
''[ICD Diagnosis Code 1],
''[ICD Diagnosis Code 2],
''[ICD Diagnosis Code 3],
''[ICD Diagnosis Code 4],
''[ICD Diagnosis Code 5],
''[ICD Diagnosis Code 6],
''[ICD Diagnosis Code 7],
''[ICD Diagnosis Code 8],
''[ICD Diagnosis Code 9],
''[ICD Diagnosis Code 10],
''[Procedural ICD Code 1],
''[Procedural ICD Code 2],
''[Procedural ICD Code 3],
''[Procedural ICD Code 4],
''[Procedural ICD Code 5],
''[Procedural ICD Code 6],
''[Procedural ICD Code 7],
''[Procedural ICD Code 8],
''[Procedural ICD Code 9],
''[Procedural ICD Code 10],
'10' [ICD Version],
''[CPT/CPTII/HCPCS Code],
''[CPT Modifier 1],
''[CPT Modifier 2],
''[CPT Result],
 cast (ORDER_RESULTS.COMPON_LNC_ID as varchar) [LOINC Code],
CAST( CASE WHEN ORDER_RESULTS.ORD_NUM_VALUE = 9999999 THEN NULL
                  ELSE ORDER_RESULTS.ORD_NUM_VALUE END AS float ) [LOINC Result],
cast (V.BMI as varchar) [BMI Value],	
--ROUND((WEIGHT/16),2) 
'' [Member Weight],	
cast (BP_SYSTOLIC as varchar) [BP Systolic],	
cast (BP_DIASTOLIC as varchar) [BP Diastolic],	
''[NDC Code],	
''[SNOMED Code],
''[Discharge Status Code]


     
       
       
  FROM ORDER_RESULTS
    INNER JOIN ( SELECT ORDER_RESULTS.ORDER_PROC_ID,
                        MAX(ORDER_RESULTS.ORD_DATE_REAL) LatestContact
                   FROM ORDER_RESULTS
                  
                   GROUP BY ORDER_RESULTS.ORDER_PROC_ID ) OrderContactFilter
      ON ORDER_RESULTS.ORDER_PROC_ID = OrderContactFilter.ORDER_PROC_ID
        AND ORDER_RESULTS.ORD_DATE_REAL = OrderContactFilter.LatestContact
    LEFT OUTER JOIN ORDER_PROC_5
      ON ORDER_RESULTS.ORDER_PROC_ID = ORDER_PROC_5.ORDER_ID
    LEFT OUTER JOIN ORDER_STATUS
      ON ORDER_RESULTS.ORDER_PROC_ID = ORDER_STATUS.ORDER_ID
        AND ORDER_RESULTS.ORD_DATE_REAL = ORDER_STATUS.ORD_DATE_REAL
    LEFT OUTER JOIN ORDER_RES_COMP_CMT
      ON ORDER_RESULTS.ORDER_PROC_ID = ORDER_RES_COMP_CMT.ORDER_ID
        AND ORDER_RESULTS.ORD_DATE_REAL = ORDER_RES_COMP_CMT.CONTACT_DATE_REAL
        AND ORDER_RESULTS.LINE = ORDER_RES_COMP_CMT.LINE_COMP
        AND ORDER_RES_COMP_CMT.LINE_COMMENT = 1
    LEFT OUTER JOIN ORDER_PROC
      ON ORDER_RESULTS.ORDER_PROC_ID = ORDER_PROC.ORDER_PROC_ID
    LEFT OUTER JOIN ORDER_PROC_2
      ON ORDER_RESULTS.ORDER_PROC_ID = ORDER_PROC_2.ORDER_PROC_ID
LEFT JOIN V_PAT_ENC V ON  ORDER_RESULTS.PAT_ENC_CSN_ID = V.PAT_ENC_CSN_ID
LEFT JOIN COVERAGE_MEM_LIST C ON C.COVERAGE_ID = V.COVERAGE_ID AND V.PAT_ID = C.PAT_ID
LEFT JOIN PATIENT P ON P.PAT_ID = V.PAT_ID
LEFT JOIN MEDID ON MEDID.PAT_ID = V.PAT_ID
LEFT JOIN CLARITY_SER_2 SER ON SER.PROV_ID = ORDER_PROC.AUTHRZING_PROV_ID


WHERE 
ORDER_RESULTS.COMPONENT_ID IS NOT NULL
    AND ( ORDER_PROC_5.ACTV_EXCLUDE_FROM_CDS_REASON_C = 1 OR ORDER_PROC_5.ACTV_EXCLUDE_FROM_CDS_REASON_C IS NULL ) --AND c.MEM_NUMBER is not null
	
	--AND ORDER_PROC.PROC_ID IN (64611)
	and c.MEM_NUMBER is not null and  ( ORDER_RESULTS.COMPON_LNC_ID is not null and
 ORDER_RESULTS.ORD_NUM_VALUE <> '9999999')

RETURN 0
