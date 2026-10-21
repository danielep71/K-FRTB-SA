Attribute VB_Name = "CORE_Params"
'==============================================================================
' MODULE: CORE_Params
'------------------------------------------------------------------------------
' PURPOSE
'   Load the run settings (Control sheet) and every regulatory parameter
'   table (P_* sheets) into module storage, and expose typed accessors:
'   risk weights, correlation building blocks, cross-bucket correlations,
'   liquidity horizons, DRC and RRAO parameters.
'
' PUBLIC SURFACE
'   LoadAllParameters; ReportingCcy, FxCurvatureDivisor,
'   ScenarioCorrelation, VegaAlpha, VegaRiskWeight; IsValid* vertex and
'   bucket checks, IsOtherBucket; *RiskWeight; correlation accessors;
'   BucketGamma; Drc* and RraoRiskWeight.
'
' DEPENDENCIES
'   CORE_Config, CORE_Util.
'
' STATE OWNERSHIP
'   Owns the parameters of the current run (module variables m*), replaced
'   by every LoadAllParameters call. Parameters are never hard-coded here:
'   the P_* sheets are the source, and M_Setup only writes their defaults.
'
' ERROR POLICY
'   A missing table, or a required key, table value or vertex list entry
'   that is blank or not a number, raises (CORE_Util); an unknown tenor or
'   liquidity horizon raises vbObjectError + ERR_APP. The run stops before
'   any capital is written.
'
' COMPATIBILITY
'   Excel VBA; also runs in LibreOffice Calc with VBA support for the
'   automated tests. No references beyond the defaults.
'==============================================================================

'------------------------------------------------------------------------------
'                              MODULE SETTINGS
'------------------------------------------------------------------------------
Option Explicit
Option Private Module

'------------------------------------------------------------------------------
'                               MODULE STATE
'------------------------------------------------------------------------------
' Settings
Private mReportingCcy As String
Private mGirrSpecifiedOn As Boolean
Private mFxSpecifiedOn As Boolean
Private mFxCurvDivisorOn As Boolean

' General
Private mHighMult As Double
Private mLowMult As Double
Private mVegaRWSigma As Double
Private mVegaAlpha As Double
Private mLHCount As Long
Private mLHClass() As String
Private mLHBucket() As String
Private mLHValue() As Double
Private mGirrTenors() As Double, mGirrTenorN As Long
Private mCsrTenors() As Double, mCsrTenorN As Long
Private mComTenors() As Double, mComTenorN As Long
Private mVegaMats() As Double, mVegaMatN As Long

' GIRR
Private mGirrRWTenor() As Double
Private mGirrRWValue() As Double
Private mGirrRWCount As Long
Private mGirrTheta As Double
Private mGirrRhoFloor As Double
Private mGirrRhoDiffCurve As Double
Private mGirrRhoInflation As Double
Private mGirrRhoXccy As Double
Private mGirrRWInflation As Double
Private mGirrRWXccy As Double
Private mGirrGamma As Double
Private mGirrSpecDivisor As Double
Private mGirrSpecCcy As Collection

' CSR non-securitization
Private mCsrN As Long
Private mCsrQuality() As String
Private mCsrGroup() As String
Private mCsrType() As String
Private mCsrRW() As Double
Private mCsrRhoName As Double
Private mCsrRhoNameIndex As Double
Private mCsrRhoTenor As Double
Private mCsrRhoBasis As Double
Private mCsrGammaRating As Double
Private mCsrGroupIdx As Collection
Private mCsrSector() As Double

' Equity
Private mEqN As Long
Private mEqType() As String
Private mEqRWSpot() As Double
Private mEqRWRepo() As Double
Private mEqRhoName() As Double
Private mEqRhoSpotRepo As Double
Private mEqGamma() As Double

' Commodity
Private mComN As Long
Private mComRW() As Double
Private mComRhoCty() As Double
Private mComRhoTenor As Double
Private mComRhoBasis As Double
Private mComGamma() As Double

' FX
Private mFxRW As Double
Private mFxGamma As Double
Private mFxSpecDivisor As Double
Private mFxCurvDivisor As Double
Private mFxSpecPairs As Collection

' DRC
Private mDrcRW As Collection
Private mDrcLGD As Collection
Private mDrcRank As Collection
Private mDrcBuckets As Collection
Private mDrcBucketNames() As String
Private mDrcMinMat As Double
Private mDrcMaxMat As Double

' RRAO
Private mRraoRW As Collection

'------------------------------------------------------------------------------
' Loading
'------------------------------------------------------------------------------
Public Sub LoadAllParameters()
    LoadSettings
    LoadGeneral
    LoadGirr
    LoadCsr
    LoadEquity
    LoadCommodity
    LoadFx
    LoadDrc
    LoadRrao
End Sub

Private Sub LoadSettings()
    Dim kv As Collection
    Set kv = ReadKeyValues(SH_CONTROL, "SETTINGS")
    mReportingCcy = UCase$(KVText(kv, "REPORTING_CCY", "EUR"))
    mGirrSpecifiedOn = KVBool(kv, "GIRR_SPECIFIED_CCY_DISCRETION", False)
    mFxSpecifiedOn = KVBool(kv, "FX_SPECIFIED_PAIR_DISCRETION", False)
    mFxCurvDivisorOn = KVBool(kv, "FX_CURVATURE_DIVISOR", False)
End Sub

Private Sub LoadGeneral()
    Dim kv As Collection, t As Variant, nR As Long, nC As Long, r As Long

    Set kv = ReadKeyValues(SH_P_GENERAL, "CORR_SCENARIOS")
    mHighMult = KVNumber(kv, "HIGH_MULTIPLIER", SH_P_GENERAL)
    mLowMult = KVNumber(kv, "LOW_MULTIPLIER", SH_P_GENERAL)

    Set kv = ReadKeyValues(SH_P_GENERAL, "VEGA")
    mVegaRWSigma = KVNumber(kv, "RW_SIGMA", SH_P_GENERAL)
    mVegaAlpha = KVNumber(kv, "ALPHA", SH_P_GENERAL)

    t = ReadTable(SH_P_GENERAL, "VEGA_LH", nR, nC)
    mLHCount = nR
    ReDim mLHClass(1 To nR)
    ReDim mLHBucket(1 To nR)
    ReDim mLHValue(1 To nR)
    For r = 1 To nR
        mLHClass(r) = ToText(t(r, 1))
        mLHBucket(r) = BucketLabel(t(r, 2))
        mLHValue(r) = TableNumber(t, r, 3, SH_P_GENERAL, "VEGA_LH")
    Next r

    Set kv = ReadKeyValues(SH_P_GENERAL, "VERTICES")
    mGirrTenorN = ParseNumberList(KVText(kv, "GIRR_TENORS", ""), mGirrTenors, "GIRR_TENORS (" & SH_P_GENERAL & ")")
    mCsrTenorN = ParseNumberList(KVText(kv, "CSR_TENORS", ""), mCsrTenors, "CSR_TENORS (" & SH_P_GENERAL & ")")
    mComTenorN = ParseNumberList(KVText(kv, "COM_TENORS", ""), mComTenors, "COM_TENORS (" & SH_P_GENERAL & ")")
    mVegaMatN = ParseNumberList(KVText(kv, "VEGA_MATURITIES", ""), mVegaMats, "VEGA_MATURITIES (" & SH_P_GENERAL & ")")
End Sub

Private Sub LoadGirr()
    Dim kv As Collection, t As Variant, nR As Long, nC As Long, r As Long

    t = ReadTable(SH_P_GIRR, "GIRR_RW", nR, nC)
    mGirrRWCount = nR
    ReDim mGirrRWTenor(1 To nR)
    ReDim mGirrRWValue(1 To nR)
    For r = 1 To nR
        mGirrRWTenor(r) = TableNumber(t, r, 1, SH_P_GIRR, "GIRR_RW")
        mGirrRWValue(r) = TableNumber(t, r, 2, SH_P_GIRR, "GIRR_RW")
    Next r

    Set kv = ReadKeyValues(SH_P_GIRR, "GIRR_PARAMS")
    mGirrTheta = KVNumber(kv, "THETA", SH_P_GIRR)
    mGirrRhoFloor = KVNumber(kv, "RHO_FLOOR", SH_P_GIRR)
    mGirrRhoDiffCurve = KVNumber(kv, "RHO_DIFF_CURVE", SH_P_GIRR)
    mGirrRhoInflation = KVNumber(kv, "RHO_INFLATION", SH_P_GIRR)
    mGirrRhoXccy = KVNumber(kv, "RHO_XCCY", SH_P_GIRR)
    mGirrRWInflation = KVNumber(kv, "RW_INFLATION", SH_P_GIRR)
    mGirrRWXccy = KVNumber(kv, "RW_XCCY", SH_P_GIRR)
    mGirrGamma = KVNumber(kv, "GAMMA", SH_P_GIRR)
    mGirrSpecDivisor = KVNumber(kv, "SPECIFIED_DIVISOR", SH_P_GIRR)

    Set mGirrSpecCcy = New Collection
    t = ReadTable(SH_P_GIRR, "GIRR_SPECIFIED_CCY", nR, nC)
    For r = 1 To nR
        If Not KeyExists(mGirrSpecCcy, ToText(t(r, 1))) Then AddKey mGirrSpecCcy, ToText(t(r, 1)), True
    Next r
End Sub

Private Sub LoadCsr()
    Dim kv As Collection, t As Variant, nR As Long, nC As Long, r As Long, c As Long, b As Long

    t = ReadTable(SH_P_CSR, "CSR_BUCKETS", nR, nC)
    mCsrN = 0
    For r = 1 To nR
        b = CLng(TableNumber(t, r, 1, SH_P_CSR, "CSR_BUCKETS"))
        If b > mCsrN Then mCsrN = b
    Next r
    ReDim mCsrQuality(1 To mCsrN)
    ReDim mCsrGroup(1 To mCsrN)
    ReDim mCsrType(1 To mCsrN)
    ReDim mCsrRW(1 To mCsrN)
    For r = 1 To nR
        b = CLng(TableNumber(t, r, 1, SH_P_CSR, "CSR_BUCKETS"))
        mCsrQuality(b) = ToText(t(r, 3))
        mCsrGroup(b) = BucketLabel(t(r, 4))
        mCsrType(b) = ToText(t(r, 5))
        mCsrRW(b) = TableNumber(t, r, 6, SH_P_CSR, "CSR_BUCKETS")
    Next r

    Set kv = ReadKeyValues(SH_P_CSR, "CSR_PARAMS")
    mCsrRhoName = KVNumber(kv, "RHO_NAME", SH_P_CSR)
    mCsrRhoNameIndex = KVNumber(kv, "RHO_NAME_INDEX", SH_P_CSR)
    mCsrRhoTenor = KVNumber(kv, "RHO_TENOR", SH_P_CSR)
    mCsrRhoBasis = KVNumber(kv, "RHO_BASIS", SH_P_CSR)
    mCsrGammaRating = KVNumber(kv, "GAMMA_RATING", SH_P_CSR)

    ' Sector matrix: first column holds the row group, header holds the column groups
    t = ReadTable(SH_P_CSR, "CSR_GAMMA_SECTOR", nR, nC)
    Set mCsrGroupIdx = New Collection
    For r = 1 To nR
        AddKey mCsrGroupIdx, BucketLabel(t(r, 1)), r
    Next r
    ReDim mCsrSector(1 To nR, 1 To nR)
    For r = 1 To nR
        For c = 1 To nR
            mCsrSector(r, c) = TableNumber(t, r, c + 1, SH_P_CSR, "CSR_GAMMA_SECTOR")
        Next c
    Next r
End Sub

Private Sub LoadEquity()
    Dim kv As Collection, t As Variant, nR As Long, nC As Long, r As Long, c As Long, b As Long

    t = ReadTable(SH_P_EQ, "EQ_BUCKETS", nR, nC)
    mEqN = 0
    For r = 1 To nR
        b = CLng(TableNumber(t, r, 1, SH_P_EQ, "EQ_BUCKETS"))
        If b > mEqN Then mEqN = b
    Next r
    ReDim mEqType(1 To mEqN)
    ReDim mEqRWSpot(1 To mEqN)
    ReDim mEqRWRepo(1 To mEqN)
    ReDim mEqRhoName(1 To mEqN)
    For r = 1 To nR
        b = CLng(TableNumber(t, r, 1, SH_P_EQ, "EQ_BUCKETS"))
        mEqType(b) = ToText(t(r, 3))
        mEqRWSpot(b) = TableNumber(t, r, 4, SH_P_EQ, "EQ_BUCKETS")
        mEqRWRepo(b) = TableNumber(t, r, 5, SH_P_EQ, "EQ_BUCKETS")
        mEqRhoName(b) = TableNumber(t, r, 6, SH_P_EQ, "EQ_BUCKETS")
    Next r

    Set kv = ReadKeyValues(SH_P_EQ, "EQ_PARAMS")
    mEqRhoSpotRepo = KVNumber(kv, "RHO_SPOT_REPO", SH_P_EQ)

    t = ReadTable(SH_P_EQ, "EQ_GAMMA", nR, nC)
    ReDim mEqGamma(1 To mEqN, 1 To mEqN)
    For r = 1 To nR
        b = CLng(TableNumber(t, r, 1, SH_P_EQ, "EQ_GAMMA"))
        For c = 1 To mEqN
            mEqGamma(b, c) = TableNumber(t, r, c + 1, SH_P_EQ, "EQ_GAMMA")
        Next c
    Next r
End Sub

Private Sub LoadCommodity()
    Dim kv As Collection, t As Variant, nR As Long, nC As Long, r As Long, c As Long, b As Long

    t = ReadTable(SH_P_COM, "COM_BUCKETS", nR, nC)
    mComN = 0
    For r = 1 To nR
        b = CLng(TableNumber(t, r, 1, SH_P_COM, "COM_BUCKETS"))
        If b > mComN Then mComN = b
    Next r
    ReDim mComRW(1 To mComN)
    ReDim mComRhoCty(1 To mComN)
    For r = 1 To nR
        b = CLng(TableNumber(t, r, 1, SH_P_COM, "COM_BUCKETS"))
        mComRW(b) = TableNumber(t, r, 3, SH_P_COM, "COM_BUCKETS")
        mComRhoCty(b) = TableNumber(t, r, 4, SH_P_COM, "COM_BUCKETS")
    Next r

    Set kv = ReadKeyValues(SH_P_COM, "COM_PARAMS")
    mComRhoTenor = KVNumber(kv, "RHO_TENOR", SH_P_COM)
    mComRhoBasis = KVNumber(kv, "RHO_BASIS", SH_P_COM)

    t = ReadTable(SH_P_COM, "COM_GAMMA", nR, nC)
    ReDim mComGamma(1 To mComN, 1 To mComN)
    For r = 1 To nR
        b = CLng(TableNumber(t, r, 1, SH_P_COM, "COM_GAMMA"))
        For c = 1 To mComN
            mComGamma(b, c) = TableNumber(t, r, c + 1, SH_P_COM, "COM_GAMMA")
        Next c
    Next r
End Sub

Private Sub LoadFx()
    Dim kv As Collection, t As Variant, nR As Long, nC As Long, r As Long
    Set kv = ReadKeyValues(SH_P_FX, "FX_PARAMS")
    mFxRW = KVNumber(kv, "RW", SH_P_FX)
    mFxGamma = KVNumber(kv, "GAMMA", SH_P_FX)
    mFxSpecDivisor = KVNumber(kv, "SPECIFIED_DIVISOR", SH_P_FX)
    mFxCurvDivisor = KVNumber(kv, "CURVATURE_DIVISOR", SH_P_FX)

    Set mFxSpecPairs = New Collection
    t = ReadTable(SH_P_FX, "FX_SPECIFIED_PAIRS", nR, nC)
    For r = 1 To nR
        If Not KeyExists(mFxSpecPairs, ToText(t(r, 1))) Then AddKey mFxSpecPairs, ToText(t(r, 1)), True
    Next r
End Sub

Private Sub LoadDrc()
    Dim kv As Collection, t As Variant, nR As Long, nC As Long, r As Long

    Set mDrcRW = New Collection
    t = ReadTable(SH_P_DRC, "DRC_RW", nR, nC)
    For r = 1 To nR
        AddKey mDrcRW, ToText(t(r, 1)), TableNumber(t, r, 2, SH_P_DRC, "DRC_RW")
    Next r

    Set mDrcLGD = New Collection
    Set mDrcRank = New Collection
    t = ReadTable(SH_P_DRC, "DRC_SENIORITY", nR, nC)
    For r = 1 To nR
        AddKey mDrcRank, ToText(t(r, 1)), CLng(TableNumber(t, r, 2, SH_P_DRC, "DRC_SENIORITY"))
        AddKey mDrcLGD, ToText(t(r, 1)), TableNumber(t, r, 3, SH_P_DRC, "DRC_SENIORITY")
    Next r

    Set mDrcBuckets = New Collection
    t = ReadTable(SH_P_DRC, "DRC_BUCKETS", nR, nC)
    ReDim mDrcBucketNames(1 To nR)
    For r = 1 To nR
        AddKey mDrcBuckets, ToText(t(r, 1)), r
        mDrcBucketNames(r) = ToText(t(r, 1))
    Next r

    Set kv = ReadKeyValues(SH_P_DRC, "DRC_PARAMS")
    mDrcMinMat = KVNumber(kv, "MIN_MATURITY", SH_P_DRC)
    mDrcMaxMat = KVNumber(kv, "MAX_MATURITY", SH_P_DRC)
End Sub

Private Sub LoadRrao()
    Dim t As Variant, nR As Long, nC As Long, r As Long
    Set mRraoRW = New Collection
    t = ReadTable(SH_P_RRAO, "RRAO_RW", nR, nC)
    For r = 1 To nR
        AddKey mRraoRW, ToText(t(r, 1)), TableNumber(t, r, 2, SH_P_RRAO, "RRAO_RW")
    Next r
End Sub

'------------------------------------------------------------------------------
' Settings and general accessors
'------------------------------------------------------------------------------
Public Function ReportingCcy() As String
    ReportingCcy = mReportingCcy
End Function

Public Function FxCurvatureDivisor() As Double
    If mFxCurvDivisorOn Then FxCurvatureDivisor = mFxCurvDivisor Else FxCurvatureDivisor = 1#
End Function

' Correlation scenario transform (MAR21.6): high = min(1.25 rho, 1),
' low = max(2 rho - 1, 0.75 rho), medium = rho.
Public Function ScenarioCorrelation(ByVal rho As Double, ByVal scen As Long) As Double
    Select Case scen
        Case SCEN_HIGH
            ScenarioCorrelation = MinD(mHighMult * rho, 1#)
        Case SCEN_LOW
            ScenarioCorrelation = MaxD(2# * rho - 1#, mLowMult * rho)
        Case Else
            ScenarioCorrelation = rho
    End Select
End Function

Public Function VegaAlpha() As Double
    VegaAlpha = mVegaAlpha
End Function

' Vega risk weight: min(RW_sigma * sqrt(LH / 10), 100%) with the liquidity
' horizon looked up by risk class and bucket ("*" matches every bucket).
Public Function VegaRiskWeight(ByVal rc As String, ByVal bucket As String) As Double
    Dim r As Long, lh As Double, found As Boolean
    found = False
    For r = 1 To mLHCount
        If mLHClass(r) = rc And mLHBucket(r) = bucket Then
            lh = mLHValue(r)
            found = True
            Exit For
        End If
    Next r
    If Not found Then
        For r = 1 To mLHCount
            If mLHClass(r) = rc And mLHBucket(r) = "*" Then
                lh = mLHValue(r)
                found = True
                Exit For
            End If
        Next r
    End If
    If Not found Then
        Err.Raise vbObjectError + ERR_APP, "VegaRiskWeight", "No liquidity horizon for " & rc & " bucket " & bucket
    End If
    VegaRiskWeight = MinD(mVegaRWSigma * Sqr(lh / 10#), 1#)
End Function

Public Function IsValidGirrTenor(ByVal t As Double) As Boolean
    IsValidGirrTenor = InNumberList(t, mGirrTenors, mGirrTenorN)
End Function

Public Function IsValidCsrTenor(ByVal t As Double) As Boolean
    IsValidCsrTenor = InNumberList(t, mCsrTenors, mCsrTenorN)
End Function

Public Function IsValidComTenor(ByVal t As Double) As Boolean
    IsValidComTenor = InNumberList(t, mComTenors, mComTenorN)
End Function

Public Function IsValidVegaMaturity(ByVal t As Double) As Boolean
    IsValidVegaMaturity = InNumberList(t, mVegaMats, mVegaMatN)
End Function

'------------------------------------------------------------------------------
' Bucket validation and classification
'------------------------------------------------------------------------------
Public Function IsValidBucket(ByVal rc As String, ByVal bucket As String) As Boolean
    Dim b As Long
    IsValidBucket = False
    Select Case rc
        Case RC_GIRR, RC_FX
            IsValidBucket = (Len(bucket) = 3)
        Case RC_CSR, RC_EQ, RC_COM
            If Not IsNumber(bucket) Then Exit Function
            b = CLng(Val(bucket))
            If b < 1 Then Exit Function
            Select Case rc
                Case RC_CSR: If b <= mCsrN Then IsValidBucket = (mCsrType(b) <> "")
                Case RC_EQ: If b <= mEqN Then IsValidBucket = (mEqType(b) <> "")
                Case RC_COM: IsValidBucket = (b <= mComN)
            End Select
    End Select
End Function

' "Other sector" buckets (CSR 16, equity 11) are aggregated without
' diversification and added outside the cross-bucket square root.
Public Function IsOtherBucket(ByVal rc As String, ByVal bucket As String) As Boolean
    IsOtherBucket = False
    Select Case rc
        Case RC_CSR
            IsOtherBucket = (mCsrType(CLng(Val(bucket))) = "OTHER")
        Case RC_EQ
            IsOtherBucket = (mEqType(CLng(Val(bucket))) = "OTHER")
    End Select
End Function

'------------------------------------------------------------------------------
' Delta risk weights
'------------------------------------------------------------------------------
Public Function GirrRiskWeight(ByVal ccy As String, ByVal subType As String, ByVal tenor As Double) As Double
    Dim r As Long, rw As Double
    Select Case subType
        Case "INFLATION"
            GirrRiskWeight = mGirrRWInflation
            Exit Function
        Case "XCCY"
            GirrRiskWeight = mGirrRWXccy
            Exit Function
    End Select
    rw = -1#
    For r = 1 To mGirrRWCount
        If Abs(mGirrRWTenor(r) - tenor) < 0.000001 Then
            rw = mGirrRWValue(r)
            Exit For
        End If
    Next r
    If rw < 0# Then
        Err.Raise vbObjectError + ERR_APP, "GirrRiskWeight", "No GIRR risk weight for tenor " & tenor
    End If
    If mGirrSpecifiedOn Then
        If KeyExists(mGirrSpecCcy, ccy) Or ccy = mReportingCcy Then rw = rw / mGirrSpecDivisor
    End If
    GirrRiskWeight = rw
End Function

Public Function CsrRiskWeight(ByVal bucket As String) As Double
    CsrRiskWeight = mCsrRW(CLng(Val(bucket)))
End Function

Public Function EqRiskWeight(ByVal bucket As String, ByVal subType As String) As Double
    If subType = "REPO" Then
        EqRiskWeight = mEqRWRepo(CLng(Val(bucket)))
    Else
        EqRiskWeight = mEqRWSpot(CLng(Val(bucket)))
    End If
End Function

Public Function ComRiskWeight(ByVal bucket As String) As Double
    ComRiskWeight = mComRW(CLng(Val(bucket)))
End Function

Public Function FxRiskWeight(ByVal ccy As String) As Double
    Dim rw As Double
    rw = mFxRW
    If mFxSpecifiedOn Then
        If IsSpecifiedFxPair(ccy, mReportingCcy) Then rw = rw / mFxSpecDivisor
    End If
    FxRiskWeight = rw
End Function


' A pair is specified when it is listed, or when it is a first-order cross
' of two currencies that are each listed against USD (MAR21.88, fn 23).
Private Function IsSpecifiedFxPair(ByVal ccyA As String, ByVal ccyB As String) As Boolean
    If KeyExists(mFxSpecPairs, ccyA & "/" & ccyB) Or KeyExists(mFxSpecPairs, ccyB & "/" & ccyA) Then
        IsSpecifiedFxPair = True
    Else
        IsSpecifiedFxPair = IsUsdPaired(ccyA) And IsUsdPaired(ccyB)
    End If
End Function


Private Function IsUsdPaired(ByVal ccy As String) As Boolean
    IsUsdPaired = (ccy = "USD") Or KeyExists(mFxSpecPairs, "USD/" & ccy) Or KeyExists(mFxSpecPairs, ccy & "/USD")
End Function

'------------------------------------------------------------------------------
' Delta correlation building blocks (medium scenario)
'------------------------------------------------------------------------------
Public Function GirrTenorCorrelation(ByVal ta As Double, ByVal tb As Double) As Double
    If Abs(ta - tb) < 0.000001 Then
        GirrTenorCorrelation = 1#
    Else
        GirrTenorCorrelation = MaxD(Exp(-mGirrTheta * Abs(ta - tb) / MinD(ta, tb)), mGirrRhoFloor)
    End If
End Function

Public Function GirrRhoDiffCurve() As Double
    GirrRhoDiffCurve = mGirrRhoDiffCurve
End Function

Public Function GirrRhoInflation() As Double
    GirrRhoInflation = mGirrRhoInflation
End Function

Public Function GirrRhoXccy() As Double
    GirrRhoXccy = mGirrRhoXccy
End Function

Public Function CsrNameCorrelation(ByVal bucket As String) As Double
    If mCsrType(CLng(Val(bucket))) = "INDEX" Then
        CsrNameCorrelation = mCsrRhoNameIndex
    Else
        CsrNameCorrelation = mCsrRhoName
    End If
End Function

Public Function CsrRhoTenor() As Double
    CsrRhoTenor = mCsrRhoTenor
End Function

Public Function CsrRhoBasis() As Double
    CsrRhoBasis = mCsrRhoBasis
End Function

Public Function EqNameCorrelation(ByVal bucket As String) As Double
    EqNameCorrelation = mEqRhoName(CLng(Val(bucket)))
End Function

Public Function EqRhoSpotRepo() As Double
    EqRhoSpotRepo = mEqRhoSpotRepo
End Function

Public Function ComCommodityCorrelation(ByVal bucket As String) As Double
    ComCommodityCorrelation = mComRhoCty(CLng(Val(bucket)))
End Function

Public Function ComRhoTenor() As Double
    ComRhoTenor = mComRhoTenor
End Function

Public Function ComRhoBasis() As Double
    ComRhoBasis = mComRhoBasis
End Function

'------------------------------------------------------------------------------
' Cross-bucket correlations (medium scenario)
'------------------------------------------------------------------------------
Public Function BucketGamma(ByVal rc As String, ByVal b As String, ByVal c As String) As Double
    Dim ib As Long, ic As Long, rating As Double
    Select Case rc
        Case RC_GIRR
            BucketGamma = mGirrGamma
        Case RC_FX
            BucketGamma = mFxGamma
        Case RC_CSR
            ib = CLng(Val(b))
            ic = CLng(Val(c))
            ' Rating factor applies only between two buckets of 1-15 (MAR21.57)
            If mCsrType(ib) = "NAME" And mCsrType(ic) = "NAME" And mCsrQuality(ib) <> mCsrQuality(ic) Then
                rating = mCsrGammaRating
            Else
                rating = 1#
            End If
            BucketGamma = rating * mCsrSector(KeyIndex(mCsrGroupIdx, mCsrGroup(ib)), _
                                              KeyIndex(mCsrGroupIdx, mCsrGroup(ic)))
        Case RC_EQ
            BucketGamma = mEqGamma(CLng(Val(b)), CLng(Val(c)))
        Case RC_COM
            BucketGamma = mComGamma(CLng(Val(b)), CLng(Val(c)))
        Case Else
            BucketGamma = 0#
    End Select
End Function

'------------------------------------------------------------------------------
' DRC and RRAO accessors
'------------------------------------------------------------------------------
Public Function DrcRiskWeight(ByVal quality As String, ByRef found As Boolean) As Double
    found = KeyExists(mDrcRW, quality)
    If found Then DrcRiskWeight = CDbl(mDrcRW.Item(UCase$(quality))) Else DrcRiskWeight = 0#
End Function

Public Function DrcLGD(ByVal seniority As String, ByRef found As Boolean) As Double
    found = KeyExists(mDrcLGD, seniority)
    If found Then DrcLGD = CDbl(mDrcLGD.Item(UCase$(seniority))) Else DrcLGD = 0#
End Function

Public Function DrcSeniorityRank(ByVal seniority As String) As Long
    DrcSeniorityRank = KeyIndex(mDrcRank, seniority)
End Function

Public Function DrcMaxRank() As Long
    Dim i As Long, m As Long
    m = 0
    For i = 1 To mDrcRank.Count
        If CLng(mDrcRank.Item(i)) > m Then m = CLng(mDrcRank.Item(i))
    Next i
    DrcMaxRank = m
End Function

Public Function IsValidDrcBucket(ByVal bucket As String) As Boolean
    IsValidDrcBucket = KeyExists(mDrcBuckets, bucket)
End Function

Public Function DrcBucketCount() As Long
    DrcBucketCount = mDrcBuckets.Count
End Function

Public Function DrcBucketIndex(ByVal bucket As String) As Long
    DrcBucketIndex = KeyIndex(mDrcBuckets, bucket)
End Function

Public Function DrcBucketName(ByVal i As Long) As String
    DrcBucketName = mDrcBucketNames(i)
End Function

Public Function DrcMinMaturity() As Double
    DrcMinMaturity = mDrcMinMat
End Function

Public Function DrcMaxMaturity() As Double
    DrcMaxMaturity = mDrcMaxMat
End Function

Public Function RraoRiskWeight(ByVal category As String, ByRef found As Boolean) As Double
    found = KeyExists(mRraoRW, category)
    If found Then RraoRiskWeight = CDbl(mRraoRW.Item(UCase$(category))) Else RraoRiskWeight = 0#
End Function
