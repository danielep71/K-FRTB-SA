# Market risk visual set

Five matching technical diagrams for the K-Risk-Engines portfolio. Each has an editable SVG master and a 1600-pixel PNG. Text is real SVG text; labels and connectors were laid out programmatically, not raster-generated.

## Website placement
1. Market_risk_framework: directly below the Market Risk introduction.
2. FRTB_uses and FRTB_aggregation: below the K-FRTB-SA card.
3. CVA_uses and CVA_aggregation: below the K-CVA card.

## Regenerate
Install CairoSVG 2.9.1 and its Cairo system dependency, then run `python build_market_diagrams.py` from this directory. The script writes the SVGs, PNGs and this README alongside itself. Use `--output PATH` for another output directory and `--archive` to also create a ZIP in its parent. Arial is preferred; DejaVu Sans is the fallback. Fonts can affect text metrics.

These explain the regulatory architecture. They do not represent current product implementation, certify calculations or supply a regulatory eligibility decision. FRTB prototype limitations and CVA implementation status remain separate from the method maps. CVA is a separate capital contribution, outside the three-component FRTB-SA sum. BA-CVA and SA-CVA are alternative approaches for a covered portfolio; the diagrams do not add them for the same portfolio. Jurisdiction-specific eligibility, exemptions and transition arrangements require their own check. No implementation dates are asserted.

## Sources checked 2026-10-27
- Basel MAR20: https://www.bis.org/committees/bcbs/basel-framework/standard/mar/20/inforce/2023-01-01/published/2020-03-27
- Basel MAR21: https://www.bis.org/basel_framework/chapter/MAR/21.htm?inforce=20230101&published=20200327
- Basel MAR22: https://www.bis.org/basel_framework/chapter/MAR/22.htm?inforce=20230101&published=20200327
- Basel MAR23: https://www.bis.org/committees/bcbs/basel-framework/standard/mar/23/inforce/2023-01-01/published/2020-03-27
- Basel MAR50: https://www.bis.org/committees/bcbs/basel-framework/standard/mar/50/inforce/2023-01-01/published/2020-07-08
- Bundesbank CVA risk: https://www.bundesbank.de/en/tasks/financial-supervision/individual-aspects/own-funds-requirements/cva-risk-743524
- Bundesbank own funds requirements: https://www.bundesbank.de/en/tasks/financial-supervision/individual-aspects/own-funds-requirements/own-funds-requirements-623136

The styling follows the site's CCR framework and SA-CCR/SFT diagrams: white canvas, navy titles, blue stage bars, pale-blue calculation cards, green output cards and directional connectors. Original diagram copy and layouts; no regulator endorsement implied.
