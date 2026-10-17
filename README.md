<div align="center">

# 📈 K-FRTB-SA

### FRTB standardized approach for market risk in Excel VBA

**Basel MAR21-MAR23 · Sensitivities-based method · Default risk charge · Residual risk add-on · Reconciled with an independent reference · No real portfolio data**

<br>

[![Excel VBA](https://img.shields.io/badge/Excel_VBA-source_first-217346?style=for-the-badge&logo=microsoft-excel&logoColor=white)](#quick-start)
[![Windows](https://img.shields.io/badge/Platform-Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white)](#quick-start)
[![Framework](https://img.shields.io/badge/Framework-Basel_MAR21--MAR23-1f3a5f?style=for-the-badge)](docs/methodology.md)
[![Status](https://img.shields.io/badge/Status-Prototype_0.1.0-D93F0B?style=for-the-badge)](#status)
[![Reference tests](https://img.shields.io/badge/Reconciliation-55_tests_PASS-2ea44f?style=for-the-badge)](docs/validation.md)
[![Excel evidence](https://img.shields.io/badge/Excel_evidence-pending-6E7781?style=for-the-badge)](docs/validation.md#not-validated)
[![License](https://img.shields.io/badge/License-MIT-2ea44f?style=for-the-badge)](LICENSE)

<br>

[![Last commit](https://img.shields.io/github/last-commit/danielep71/MKT-FTRB-SA?style=flat-square&label=last%20commit&color=217346)](https://github.com/danielep71/MKT-FTRB-SA/commits)
[![P1 issues](https://img.shields.io/github/issues/danielep71/MKT-FTRB-SA/P1?style=flat-square&label=P1&color=B60205)](https://github.com/danielep71/MKT-FTRB-SA/issues?q=is%3Aissue%20is%3Aopen%20label%3AP1)
[![P2 issues](https://img.shields.io/github/issues/danielep71/MKT-FTRB-SA/P2?style=flat-square&label=P2&color=D93F0B)](https://github.com/danielep71/MKT-FTRB-SA/issues?q=is%3Aissue%20is%3Aopen%20label%3AP2)
[![P3 issues](https://img.shields.io/github/issues/danielep71/MKT-FTRB-SA/P3?style=flat-square&label=P3&color=FBCA04)](https://github.com/danielep71/MKT-FTRB-SA/issues?q=is%3Aissue%20is%3Aopen%20label%3AP3)
[![Stars](https://img.shields.io/github/stars/danielep71/MKT-FTRB-SA?style=flat-square&color=bf8700)](https://github.com/danielep71/MKT-FTRB-SA/stargazers)

<br>

**No add-in · No external reference · No DLL · No installer · Reviewable source for every calculation**

[Quick start](#quick-start)
&nbsp;·&nbsp;
[How a run works](#how-a-run-works)
&nbsp;·&nbsp;
[Workbook](#workbook)
&nbsp;·&nbsp;
[Validation](#validation)
&nbsp;·&nbsp;
[Limitations](#limitations)
&nbsp;·&nbsp;
[Methodology](docs/methodology.md)
&nbsp;·&nbsp;
[Workbook guide](docs/workbook-guide.md)

---

<p align="center">
  <img width="100%"
       alt="K-FRTB-SA: total capital of the sample portfolio, SBM by correlation scenario and by risk class"
       src="docs/assets/FRTB_social_preview.png">
</p>

---

</div>

<a id="status"></a>

> [!IMPORTANT]
> **Version 0.1.0 is a prototype.** The engine implements the Basel
> standardized approach (MAR21-MAR23) with parameters checked against the BIS
> text, and every output is reconciled with an independent Python reference.
> It has **not yet been compiled or run in Excel**, and no result is validated
> for regulatory use ([validation](docs/validation.md)).

> [!NOTE]
> The workbook is **not stored in the repository**. It is built from the
> exported VBA source by `tools/Build-Workbook.ps1`, so every line of
> calculation code and every default parameter is reviewable in a pull request.

## ✨ What this project is

The **FRTB standardized approach** sets the own-funds requirement for market
risk as the sum of three parts:

```text
Capital = SBM + DRC + RRAO
SBM     = max over {low, medium, high} correlation scenarios of
          sum over risk classes of (delta + vega + curvature)
```

**K-FRTB-SA** is an Excel/VBA implementation for reproducing, testing and
explaining that calculation. You enter sensitivities and positions; the
engine nets them per risk factor, applies the risk weights and correlations
of each bucket, aggregates across buckets under three correlation scenarios
and writes every intermediate result.

It is built for people who need to **check** an FRTB-SA number:

- each bucket's `Kb` and `Sb`, the curvature scenario chosen and every use of
  the alternative `Sb` are visible on `Out_Buckets`;
- each obligor's net jump-to-default and each bucket's hedge benefit ratio are
  visible on `Out_DRC`;
- every rejected input row is listed on `Log` with the reason, never counted
  as zero;
- every parameter sits on an editable `P_*` sheet next to its MAR paragraph.

---

## 🎯 Core capabilities

| Area | Capability |
| --- | --- |
| Risk classes | GIRR, CSR non-securitization, equity, commodity, FX |
| SBM measures | Delta, vega and curvature; netting per risk factor; other-sector buckets without diversification |
| Correlation scenarios | Low, medium and high for every `rho` and `gamma` (squared for curvature); SBM = max of the three totals |
| Discretions | sqrt(2) for specified GIRR currencies and FX pairs (with first-order crosses), FX curvature divisor 1.5 |
| DRC | Non-securitization JTD, maturity scaling, obligor netting by seniority, hedge benefit ratio per bucket |
| RRAO | Exotic (1.0%) and other (0.1%) residual risks |
| Input validation | Unknown risk classes, buckets, tenors, sub-types, ratings and seniorities, non-numeric amounts and the reporting currency as an FX bucket are rejected and logged |
| Parameters | Eight `P_*` sheets with MAR references, checked against the BIS Basel Framework on 2026-10-17 |
| Testing | Hand-calculated formula tests, an independent Python reference, headless LibreOffice runs of the VBA, an in-workbook regression test and a static VBA lint |
| Deployment | Plain exported VBA; no add-in, COM component, DLL or extra VBA reference |

---

<a id="quick-start"></a>

# ⚡ Quick start

## 1. Clone and check

```sh
git clone https://github.com/danielep71/MKT-FTRB-SA.git
cd MKT-FTRB-SA
python3 tools/vba_lint.py
```

Use a clone, not **Download ZIP**: a clone checks the VBA out with the CRLF
line endings the VBA editor expects. The full test suite needs LibreOffice
and Python packages; see [validation](docs/validation.md).

## 2. Build the workbook

1. In Excel, enable **Trust access to the VBA project object model**.
2. From the repository root, in PowerShell:

   ```powershell
   powershell -ExecutionPolicy Bypass -File tools\Build-Workbook.ps1 -RunTests
   ```

3. Open `dist\K-FRTB-SA.xlsm`, then run **Debug → Compile VBAProject** in the
   VBA editor (**Alt+F11**).

`-Production` leaves out the test module; the manual import is described in
the [workbook guide](docs/workbook-guide.md#building-the-workbook-windows-excel).

## 3. Run

The workbook ships with a synthetic sample portfolio. On **Control**, click
**Run FRTB-SA**: Results, the `Out_*` sheets and Log are rewritten. Then click
**Run regression test**: `Test_Expected` compares 52 results with the values
of the independent reference and shows PASS or FAIL per item.

<a id="how-a-run-works"></a>

## 🔄 How a run works

```text
Control + P_*  ──►  load settings and parameters
In_Delta       ──►  validate, net per risk factor ──► WS = RW x s ──► Kb, Sb ──► across buckets ─┐
In_Vega        ──►  validate, net per risk factor ──► WS = RW x s ──► Kb, Sb ──► across buckets ─┼─► SBM per scenario
In_Curvature   ──►  validate, net per risk factor ──► CVR up/down ──► Kb, Sb ──► across buckets ─┘
In_DRC         ──►  JTD, maturity scaling, seniority netting ──► HBR ──► DRC per bucket
In_RRAO        ──►  gross notional x RW
                    ──►  Results, Out_Summary, Out_RiskClass, Out_Buckets, Out_DRC, Log
```

<a id="workbook"></a>

## 🗂️ Workbook

Every sheet carries the same frame: the product name in gold on a black bar,
the sheet title on a blue bar and a one-line subtitle. Tabs are colored by
role.

| Tab | Sheets | Content |
| --- | --- | --- |
| 🟦 Navy | `README` | In-workbook guide |
| 🟨 Gold | `Control`, `In_Delta`, `In_Vega`, `In_Curvature`, `In_DRC`, `In_RRAO`, `P_*` | Settings, inputs and parameters; cream cells are meant to be edited |
| 🔷 Blue | `Results`, `Out_Summary`, `Out_RiskClass`, `Out_Buckets`, `Out_DRC`, `Log` | Outputs, rewritten on every run |
| 🟩 Green | `Test_Expected` | Regression test of the sample portfolio |

<a id="validation"></a>

## 🧪 Validation

| Check | What it shows |
| --- | --- |
| VBA static lint | `Option Explicit`, module names and banners, no undeclared identifiers, no cross-module use of private procedures |
| Hand-calculated tests | The reference reproduces small examples worked from the MAR formulas, including the points confirmed against the BIS text |
| Parameter spot check | The `P_*` sheets equal an independently typed list of the regulatory values |
| VBA reconciliation | The VBA, run headless in LibreOffice, reproduces every output of the Python reference, with and without the discretions, and logs every invalid row |
| In-workbook regression | 52 items PASS |

The [validation record](docs/validation.md) lists the commands and,
explicitly, what is **not** validated yet.

<a id="limitations"></a>

## ⚠️ Limitations

- Not compiled or run in Excel yet; LibreOffice's VBA support is not Excel's.
- CSR securitization (non-CTP and CTP) and securitization DRC are not
  implemented and are rejected.
- Sensitivities and CVRs are inputs: the workbook does not price instruments.
- The [interpretations](docs/methodology.md#interpretations-and-simplifications-to-review)
  listed in the methodology still need a decision.

## 📚 Documentation

| Document | Content |
| --- | --- |
| [Methodology](docs/methodology.md) | Formulas, parameters, the BIS check and the interpretations to review |
| [Workbook guide](docs/workbook-guide.md) | Source layout, build, sheets, inputs, running |
| [Validation](docs/validation.md) | Automated checks and what is not validated |
| [Labels and triage](docs/LABELS.md) | Issue labels and metadata rules |

## 📄 License

[MIT](LICENSE) © 2026 Daniele Penza
