# Methodology

The prototype implements the FRTB standardized approach for market risk
following the Basel Framework chapters MAR21 (sensitivities-based method),
MAR22 (default risk capital) and MAR23 (residual risk add-on). Paragraph
references below point to those chapters.

> **Status: prototype.** Parameters were transcribed for review and are
> editable on the `P_*` sheets. Verify every value and interpretation below
> against the regulatory text that applies to you (Basel, CRR3 or another
> jurisdiction) before relying on any figure.

The capital requirement is:

```
Total = SBM + DRC (non-securitization) + RRAO
SBM   = max over {low, medium, high} correlation scenarios of
        sum over risk classes of (delta + vega + curvature)      (MAR21.7)
```

## Scope

| Component | Implemented | Not implemented |
| --- | --- | --- |
| SBM risk classes | GIRR, CSR non-securitization, equity, commodity, FX | CSR securitization (non-CTP), CSR securitization (CTP) |
| SBM measures | Delta, vega, curvature | Computation of sensitivities and CVRs from pricing models |
| DRC | Non-securitizations | Securitizations (non-CTP), CTP |
| RRAO | Exotic and other residual risks | Automatic identification of RRAO instruments |

Rows for unsupported risk classes are rejected and logged as errors, so a
missing component is never silently counted as zero.

## Sensitivities-based method

### Inputs

Sensitivities are supplied in the reporting currency on `In_Delta`,
`In_Vega` and `In_Curvature`; rows with the same risk factor are netted
first (MAR21.4(1)). The workbook does not compute sensitivities: they must
follow the definitions of MAR21.18-MAR21.26 (for example, GIRR delta is the
PV change for a 1 bp shift divided by 0.0001; equity delta is the PV change
for a 1% relative shift divided by 0.01). Vega inputs are the vega times the
implied volatility (MAR21.25). Curvature inputs are the CVR+ and CVR- of
MAR21.5(2), already net across instruments for each risk factor.

| Risk class | Bucket | Qualifier | Sub-type | Tenor / maturity |
| --- | --- | --- | --- | --- |
| GIRR | Currency | Curve name | `YIELD`, `INFLATION`, `XCCY` | Yield tenors 0.25-30y |
| CSR_NS | 1-18 | Issuer | `BOND`, `CDS` | 0.5, 1, 3, 5, 10y |
| EQ | 1-13 | Issuer or index | `SPOT`, `REPO` | n/a |
| COM | 1-11 | Commodity | Delivery location | 0-30y |
| FX | Currency | (= bucket) | n/a | n/a |

Vega option maturities are 0.5, 1, 3, 5 and 10 years; GIRR vega also needs
the underlying residual maturity on the same grid.

### Aggregation (MAR21.4)

For delta and vega, with weighted sensitivity `WS_k = RW_k * s_k`:

```
K_b = sqrt( max(0, sum_k WS_k^2 + sum_k sum_{l!=k} rho_kl WS_k WS_l) )
S_b = sum_k WS_k
Charge = sqrt( sum_b K_b^2 + sum_b sum_{c!=b} gamma_bc S_b S_c )
```

If the cross-bucket radicand is negative, the alternative specification
`S_b = max(min(sum WS_k, K_b), -K_b)` is used for every bucket
(MAR21.4(5)(b)); `Out_Buckets` marks those rows `ALT_SB` and
`Out_RiskClass` sets `AltSbUsed = Y`.

The "other sector" buckets (CSR 16, equity 11) use `K_b = sum |WS_k|` and are
added to the risk-class charge outside the square root, without
diversification.

### Curvature (MAR21.5)

```
K_b+ = sqrt( max(0, sum_k max(CVR_k+, 0)^2 + sum_k sum_{l!=k} rho_kl CVR_k+ CVR_l+ psi(CVR_k+, CVR_l+)) )
K_b  = max(K_b+, K_b-)
Charge = sqrt( max(0, sum_b K_b^2 + sum_b sum_{c!=b} gamma_bc S_b S_c psi(S_b, S_c)) )
```

`psi(x, y) = 0` when both arguments are negative, otherwise 1. The bucket
uses the scenario with the larger `K_b`; on a tie, the scenario with the
larger sum of CVRs. `S_b` is the sum of the CVRs of the selected scenario.
Curvature correlations are the squared delta correlations (MAR21.100). For
the other-sector buckets, `K_b = max(sum max(CVR+, 0), sum max(CVR-, 0))`.

### Correlation scenarios (MAR21.6)

Every correlation (`rho` and `gamma`, after squaring for curvature) is
transformed per scenario: high `min(1.25 rho, 1)`, medium `rho`, low
`max(2 rho - 1, 0.75 rho)`.

### Risk weights and correlations

The defaults written to the `P_*` sheets are summarized below; the sheets
carry the paragraph reference next to each value.

| Risk class | Risk weights | Within-bucket correlation | Cross-bucket |
| --- | --- | --- | --- |
| GIRR | 1.7%-1.1% by tenor; inflation and cross-currency basis 1.6% (MAR21.42-43) | `max(exp(-3% abs(Tk-Tl) / min(Tk,Tl)), 40%)`; x 99.9% across curves; inflation vs yield 40%; cross-currency basis 0% (MAR21.46-50) | 50% |
| CSR_NS | 0.5%-12% by bucket (MAR21.53) | name 35% (indices 80%) x tenor 65% x basis 99.9% (MAR21.54-55) | rating (50% IG vs HY) x sector table (MAR21.57) |
| EQ | Spot 15%-70%, repo spot/100 (MAR21.77) | names 15% / 25% / 7.5% / 12.5% / 80% by bucket; spot vs repo 99.9% (MAR21.78) | 15%, 45%, 75%, 0% for bucket 11 (MAR21.80) |
| COM | 20%-80% by bucket (MAR21.82) | commodity (by bucket) x tenor 99% x location 99.9% (MAR21.83) | 20%, 0% for bucket 11 (MAR21.85) |
| FX | 15% (MAR21.87) | n/a (one risk factor per bucket) | 60% (MAR21.89) |

Vega risk weight: `min(55% x sqrt(LH / 10), 100%)` with liquidity horizons
GIRR 60, CSR 120, equity large cap 20, small cap and other 60, commodity
120, FX 40 days (MAR21.92). Vega correlation:
`min(rho_option_maturity x rho_underlying, 1)` with
`rho_option_maturity = exp(-1% |Tk-Tl| / min(Tk,Tl))` (MAR21.93-95).

### Discretions (Control sheet)

| Setting | Effect |
| --- | --- |
| `GIRR_SPECIFIED_CCY_DISCRETION` | GIRR yield-curve risk weights divided by sqrt(2) for EUR, USD, GBP, AUD, JPY, SEK, CAD and the reporting currency (MAR21.44) |
| `FX_SPECIFIED_PAIR_DISCRETION` | FX risk weight divided by sqrt(2) for the specified currency pairs (MAR21.88) |
| `FX_CURVATURE_DIVISOR` | FX CVRs divided by 1.5 (MAR21.98; subject to supervisory approval) |

## Default risk capital, non-securitizations (MAR22)

1. Gross jump-to-default per position: `JTD = LGD x notional + (market value - notional)`,
   floored at zero for longs and capped at zero for shorts (signed amounts;
   MAR22.10-12). LGD defaults by seniority: equity and non-senior 100%,
   senior 75%, covered bonds 25% (MAR22.13); a per-row LGD overrides it.
2. Maturity scaling: `min(max(M, 0.25), 1)` (MAR22.17).
3. Netting per obligor: a short offsets a long only when it ranks the same as
   or junior to the long (MAR22.19). Shorts are applied from the most junior
   rank upward, which maximizes the eligible offset.
4. Per bucket (corporates, sovereigns, local governments):
   `HBR = sum net long / (sum net long + sum |net short|)` and
   `DRC_b = max(sum RW x net long - HBR x sum RW x |net short|, 0)`; the
   total is the simple sum of buckets (MAR22.23-24). Risk weights by credit
   quality: AAA 0.5%, AA 2%, A 3%, BBB 6%, BB 15%, B 30%, CCC 50%, unrated
   15%, defaulted 100%.

## Residual risk add-on (MAR23)

`RRAO = sum gross notional x RW`, with RW 1.0% for exotic underlyings and
0.1% for other residual risks (MAR23.8).

## Interpretations and simplifications to review

These choices are not spelled out unambiguously in the text or were
simplified for the prototype. Each is a candidate for a review issue.

1. **GIRR inflation curves**: two inflation curves in the same currency are
   correlated at 99.9% (the different-curve correlation).
2. **GIRR sqrt(2) discretion** is applied to yield-curve tenor risk weights
   only, not to inflation or cross-currency basis.
3. **CSR covered bonds** use 2.5%; no reduced risk weight for highly rated
   covered bonds is modeled.
4. **Vega underlying correlation** outside GIRR uses the delta correlation
   between the underlyings without the tenor component (name and basis for
   CSR, name for equity, commodity and location for commodity).
5. **Curvature risk factors**: GIRR has one risk factor per currency (all
   curves shifted together); FX one per currency; CSR one per issuer and
   bond/CDS curve; equity one per issuer; commodity one per commodity and
   location. Curvature correlations exclude the tenor component.
6. **Equity vega liquidity horizon**: index bucket 12 is treated as large
   cap (20 days), bucket 13 as other (60 days).
7. **Commodity bucket 11** has a 0% cross-bucket correlation but no
   other-sector absolute-sum treatment.
8. **DRC obligor attributes**: bucket and credit quality come from the
   obligor's first position; differing values are logged as warnings.
   Blank maturity defaults to one year.
9. **Binding scenario ties** resolve in the order low, medium, high.
