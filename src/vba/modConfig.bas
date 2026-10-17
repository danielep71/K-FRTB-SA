Attribute VB_Name = "modConfig"
'==============================================================================
' modConfig
' Workbook-wide constants: sheet names, risk class codes, components and
' correlation scenarios. Every other module refers to these names only.
'==============================================================================
Option Explicit

Public Const APP_NAME As String = "FRTB-SA Prototype"
Public Const APP_VERSION As String = "0.1.0-prototype"

' Sheet names
Public Const SH_README As String = "README"
Public Const SH_CONTROL As String = "Control"
Public Const SH_RESULTS As String = "Results"
Public Const SH_IN_DELTA As String = "In_Delta"
Public Const SH_IN_VEGA As String = "In_Vega"
Public Const SH_IN_CURV As String = "In_Curvature"
Public Const SH_IN_DRC As String = "In_DRC"
Public Const SH_IN_RRAO As String = "In_RRAO"
Public Const SH_P_GENERAL As String = "P_General"
Public Const SH_P_GIRR As String = "P_GIRR"
Public Const SH_P_CSR As String = "P_CSR"
Public Const SH_P_EQ As String = "P_EQ"
Public Const SH_P_COM As String = "P_COM"
Public Const SH_P_FX As String = "P_FX"
Public Const SH_P_DRC As String = "P_DRC"
Public Const SH_P_RRAO As String = "P_RRAO"
Public Const SH_OUT_CLASS As String = "Out_RiskClass"
Public Const SH_OUT_BUCKETS As String = "Out_Buckets"
Public Const SH_OUT_DRC As String = "Out_DRC"
Public Const SH_OUT_SUMMARY As String = "Out_Summary"
Public Const SH_LOG As String = "Log"
Public Const SH_TEST As String = "Test_Expected"

' Risk classes implemented by the SBM engine (in reporting order)
Public Const RC_GIRR As String = "GIRR"
Public Const RC_CSR As String = "CSR_NS"
Public Const RC_EQ As String = "EQ"
Public Const RC_COM As String = "COM"
Public Const RC_FX As String = "FX"
Public Const RC_COUNT As Long = 5

' SBM components
Public Const COMP_DELTA As Long = 1
Public Const COMP_VEGA As Long = 2
Public Const COMP_CURV As Long = 3
Public Const COMP_COUNT As Long = 3

' Correlation scenarios (MAR21.6)
Public Const SCEN_LOW As Long = 1
Public Const SCEN_MEDIUM As Long = 2
Public Const SCEN_HIGH As Long = 3
Public Const SCEN_COUNT As Long = 3

Public Function RiskClassCode(ByVal i As Long) As String
    Select Case i
        Case 1: RiskClassCode = RC_GIRR
        Case 2: RiskClassCode = RC_CSR
        Case 3: RiskClassCode = RC_EQ
        Case 4: RiskClassCode = RC_COM
        Case 5: RiskClassCode = RC_FX
        Case Else: RiskClassCode = ""
    End Select
End Function

Public Function RiskClassIndex(ByVal rc As String) As Long
    Dim i As Long
    RiskClassIndex = 0
    For i = 1 To RC_COUNT
        If RiskClassCode(i) = rc Then
            RiskClassIndex = i
            Exit Function
        End If
    Next i
End Function

Public Function ComponentName(ByVal comp As Long) As String
    Select Case comp
        Case COMP_DELTA: ComponentName = "DELTA"
        Case COMP_VEGA: ComponentName = "VEGA"
        Case COMP_CURV: ComponentName = "CURVATURE"
        Case Else: ComponentName = ""
    End Select
End Function

Public Function ScenarioName(ByVal scen As Long) As String
    Select Case scen
        Case SCEN_LOW: ScenarioName = "LOW"
        Case SCEN_MEDIUM: ScenarioName = "MEDIUM"
        Case SCEN_HIGH: ScenarioName = "HIGH"
        Case Else: ScenarioName = ""
    End Select
End Function

' True for risk classes whose buckets are numbered (CSR, equity, commodity);
' GIRR and FX buckets are currency codes.
Public Function HasNumericBuckets(ByVal rc As String) As Boolean
    HasNumericBuckets = (rc = RC_CSR Or rc = RC_EQ Or rc = RC_COM)
End Function
