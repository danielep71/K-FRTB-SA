# 🗺️ Market risk and CVA diagrams

Five diagrams map the regulatory architecture of the FRTB standardized
approach and of CVA risk. Each has an editable SVG master and a PNG,
1,600 pixels wide. They are method maps: they do not describe the implemented
scope of K-FRTB-SA or K-CVA, certify calculations or decide regulatory
eligibility. The same set is published on the K-Risk-Engines site (#98).

| Diagram | Shows |
| --- | --- |
| [Market risk framework](Market_risk_framework.png) | Market risk and CVA risk as two separate capital requirements, from perimeter and inputs to RWA; the internal models approach (MAR30–33), the simplified standardized approach (MAR40) and the CVA alternative of MAR50.9 are named, not drawn |
| [Where FRTB-SA fits](FRTB_uses.png) | The perimeter and the risk inputs that feed FRTB-SA, the steps it performs, and its results |
| [How FRTB-SA aggregates](FRTB_aggregation.png) | SBM (MAR21), DRC (MAR22) and RRAO (MAR23) from inputs to K<sub>FRTB-SA</sub> = K<sub>SBM</sub> + K<sub>DRC</sub> + K<sub>RRAO</sub> and RWA = 12.5 × K (MAR20.1, MAR20.4) |
| [Where CVA risk fits](CVA_uses.png) | Covered transactions, the BA-CVA and SA-CVA routes, the MAR50.8 carve-out and the MAR50.9 alternative |
| [How CVA capital aggregates](CVA_aggregation.png) | BA-CVA, reduced and full, and SA-CVA (delta and vega only), each applied to its own netting sets |

The K-FRTB-SA prototype covers a subset of the FRTB-SA framework that the
diagrams show. See the [scope](../../SCOPE.md) and the
[methodology](../../methodology.md).

## 🔁 Regenerate

`tools/build_market_diagrams.py` writes the SVGs and PNGs into this
directory, or into the directory given with `--output`:

```sh
python3 tools/build_market_diagrams.py
```

It needs CairoSVG 2.9.1 with the Cairo system library. CairoSVG is not one of
the pinned test dependencies. With the same fonts, a rerun reproduces the
committed files byte for byte. Arial is preferred and DejaVu Sans is the
fallback; Liberation Sans, which has Arial's metrics, centers labels that have
subscripts.

## 📚 Sources checked 2026-10-27

- Basel MAR20: https://www.bis.org/committees/bcbs/basel-framework/standard/mar/20/inforce/2023-01-01/published/2020-03-27
- Basel MAR21: https://www.bis.org/basel_framework/chapter/MAR/21.htm?inforce=20230101&published=20200327
- Basel MAR22: https://www.bis.org/basel_framework/chapter/MAR/22.htm?inforce=20230101&published=20200327
- Basel MAR23: https://www.bis.org/committees/bcbs/basel-framework/standard/mar/23/inforce/2023-01-01/published/2020-03-27
- Basel MAR50: https://www.bis.org/committees/bcbs/basel-framework/standard/mar/50/inforce/2023-01-01/published/2020-07-08
- Bundesbank, CVA risk: https://www.bundesbank.de/en/tasks/financial-supervision/individual-aspects/own-funds-requirements/cva-risk-743524
- Bundesbank, own funds requirements: https://www.bundesbank.de/en/tasks/financial-supervision/individual-aspects/own-funds-requirements/own-funds-requirements-623136

Jurisdiction-specific eligibility, exemptions and transition arrangements
need their own check; the diagrams assert no implementation dates. The layouts
and wording are original; no regulator endorsement is implied.
