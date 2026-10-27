from pathlib import Path
from html import escape
import textwrap
import cairosvg
import zipfile
import argparse

parser = argparse.ArgumentParser(description='Render the five market-risk diagrams as SVG and PNG.')
parser.add_argument('--output', type=Path, default=Path(__file__).resolve().parent)
parser.add_argument('--archive', action='store_true')
args = parser.parse_args()
OUT = args.output.resolve()
OUT.mkdir(exist_ok=True)
NAVY='#17365F'; BLUE='#24558D'; PALE='#EAF1FA'; EDGE='#B5CBE8'
INK='#31445C'; GREEN='#218452'; MINT='#EAF5EF'; ORANGE='#B75B16'

class Diagram:
    def __init__(self,name,title,subtitle,h):
        self.name=name; self.h=h; self.p=[]
        self.p.append(f'<svg xmlns="http://www.w3.org/2000/svg" width="1600" height="{h}" viewBox="0 0 1600 {h}" role="img" aria-labelledby="title desc"><title id="title">{escape(title)}</title><desc id="desc">{escape(subtitle)}</desc><defs><marker id="arrow" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="8" markerHeight="8" orient="auto-start-reverse"><path d="M0 0L10 5L0 10Z" fill="#7999BF"/></marker></defs><rect width="1600" height="{h}" fill="white"/>')
        self.text(800,55,title,38,NAVY,True,'middle')
        self.text(800,96,subtitle,23,BLUE,False,'middle')
    def text(self,x,y,t,size=22,color=INK,bold=False,anchor='start'):
        self.p.append(f'<text x="{x}" y="{y}" font-family="Arial, DejaVu Sans, sans-serif" font-size="{size}" fill="{color}" font-weight="{700 if bold else 400}" text-anchor="{anchor}">{escape(t)}</text>')
    def rect(self,x,y,w,h,fill=PALE,stroke=EDGE,r=10):
        self.p.append(f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{r}" fill="{fill}" stroke="{stroke}" stroke-width="2"/>')
    def arrow(self,x1,y1,x2,y2):
        self.p.append(f'<path d="M{x1} {y1} L{x2} {y2}" stroke="#7999BF" stroke-width="3" fill="none" marker-end="url(#arrow)"/>')
    def card(self,x,y,w,h,title,body=(),dark=False,green=False,size=22):
        self.rect(x,y,w,h,NAVY if dark else MINT if green else PALE,NAVY if dark else GREEN if green else EDGE)
        self.text(x+22,y+36,title,25,'white' if dark else NAVY,True)
        yy=y+70
        for paragraph in body:
            for line in textwrap.wrap(paragraph,width=int((w-46)/(size*.53)),break_long_words=False):
                assert yy<y+h-12,(self.name,title,yy,y+h)
                self.text(x+22,yy,line,size,'#FFFFFF' if dark else INK)
                yy+=size*1.36
            yy+=8
    def bar(self,y,n,title,note=''):
        self.rect(32,y,1536,42,BLUE,BLUE,3);self.rect(32,y,48,42,NAVY,NAVY,3)
        self.text(56,y+29,str(n),23,'white',True,'middle');self.text(96,y+29,title,24,'white',True)
        if note:self.text(1544,y+29,note,19,'#DBE7F7',False,'end')
    def foot(self,source,scope):
        self.text(36,self.h-55,scope,18,INK)
        self.text(36,self.h-25,source,17,BLUE)
    def save(self):
        data=(''.join(self.p)+'</svg>').encode()
        (OUT/(self.name+'.svg')).write_bytes(data)
        cairosvg.svg2png(bytestring=data,write_to=str(OUT/(self.name+'.png')))

d=Diagram('Market_risk_framework','MARKET RISK AND CVA RISK','From supplied risk inputs to two distinct capital requirements',1330)
d.text(800,137,'K = own funds requirement       |       RWA = risk-weighted assets',22,NAVY,False,'middle')
d.bar(170,1,'DEFINE THE PERIMETER','regulatory scope and exemptions first')
d.card(40,232,740,184,'K-FRTB-SA | MARKET-RISK POSITIONS',[
    'Trading-book positions, plus relevant FX and commodity risk outside the trading book.',
    'Capture market-price movements, jump-to-default and specified residual risks.'])
d.card(820,232,740,184,'K-CVA | COVERED COUNTERPARTIES',[
    'Covered derivatives; SFTs where CVA risk is material, subject to the applicable rules.',
    'Capture changes in CVA from credit spreads and market risk factors.'])
d.arrow(410,416,410,466);d.arrow(1190,416,1190,466)
d.bar(470,2,'SUPPLY THE RIGHT INPUTS','pricing and exposure measurement happen upstream')
d.card(40,532,740,180,'FRTB STANDARDISED APPROACH',[
    'SBM: delta, vega and curvature inputs.',
    'DRC: position and issuer data. RRAO: gross notionals and residual-risk classification.'])
d.card(820,532,740,180,'CVA CAPITAL APPROACH',[
    'BA-CVA: exposure values, effective maturities, counterparty data and eligible hedges.',
    'SA-CVA: regulatory CVA and hedge sensitivities; supervisory approval required.'])
d.arrow(410,712,410,759);d.arrow(1190,712,1190,759)
d.bar(764,3,'AGGREGATE WITHIN EACH FRAMEWORK','CVA is a separate capital calculation')
d.card(40,826,740,160,'FRTB-SA CAPITAL',[
    'K FRTB-SA = K SBM + K DRC + K RRAO',
    'SBM takes the largest total across its three correlation scenarios.'],dark=True)
d.card(820,826,740,160,'CVA CAPITAL',[
    'Apply BA-CVA or SA-CVA to the relevant portfolios.',
    'Do not add alternative methods for the same covered portfolio.'],dark=True)
d.arrow(410,986,410,1026);d.arrow(1190,986,1190,1026)
d.card(40,1034,740,110,'RWA FRTB-SA = 12.5 × K FRTB-SA',[],green=True)
d.card(820,1034,740,110,'RWA CVA = 12.5 × K CVA',[],green=True)
d.text(800,1191,'Two capital contributions. No CVA charge inside the FRTB-SA three-component sum.',25,NAVY,True,'middle')
d.foot('Sources: Basel MAR10–23 and MAR50; CRR Part Three, Titles IV and VI; Art. 92.','Conceptual architecture; not a statement of implemented coverage. Local rules and transitions must be checked separately.')
d.save()

def hub(name,title,subtitle,center,centerbody,cards,source,scope):
    d=Diagram(name,title,subtitle,1100)
    # Connectors are behind the six cards and the central node.
    for x,y in [(600,264),(1000,264),(600,529),(1000,529),(600,794),(1000,794)]:
        d.arrow(800,546,x,y)
    positions=[(40,160),(1000,160),(40,425),(1000,425),(40,690),(1000,690)]
    for (x,y),(t,b) in zip(positions,cards):d.card(x,y,560,208,t,b,green=y==690,size=21)
    d.rect(620,442,360,210,NAVY,NAVY)
    for i,line in enumerate(center.split(' | ')):
        for j,part in enumerate(textwrap.wrap(line,20)):
            d.text(800,490+i*47+j*30,part,25,'white',True,'middle')
    d.text(800,980,centerbody,23,BLUE,False,'middle')
    d.foot(source,scope);d.save()

hub('FRTB_uses','Where FRTB-SA fits in the capital framework',
    'A market-risk aggregation framework built around supplied risk measures',
    'K-FRTB-SA | SENSITIVITIES TO CAPITAL','SBM + DRC + RRAO',[
    ('1 | Regulatory perimeter',['Apply the trading-book boundary and the scope rules for FX and commodity positions.']),
    ('2 | Risk-measure inputs',['Supply sensitivities and curvature inputs from upstream valuation systems; preserve units and signs.']),
    ('3 | Sensitivities-based method',['Aggregate delta, vega and curvature by risk class and bucket. Compare three correlation scenarios.']),
    ('4 | Complementary charges',['DRC addresses jump-to-default. RRAO covers specified residual risks. Both supplement the SBM charge.']),
    ('5 | Capital and RWA',['Add SBM, DRC and RRAO capital requirements. Convert the resulting requirement to RWA using 12.5.']),
    ('6 | Benchmark and explain',['Compare bank aggregation with a transparent reference; trace differences to inputs, parameters and aggregation.'])],
    'Sources: Basel MAR11 and MAR20–23.','Framework illustration. Product scope, methodology profile and validation evidence must be stated separately.')

d=Diagram('FRTB_aggregation','How FRTB-SA aggregates risk inputs','Three calculation branches; one standardised capital requirement',1410)
d.bar(140,1,'ASSIGN INPUTS','keep valuation and risk-input production upstream')
for x,w,t,b in [(40,490,'SBM | RISK FACTORS',['Delta and vega sensitivities; curvature inputs. Map to risk classes, factors and buckets.']),
                (555,490,'DRC | POSITIONS',['Jump-to-default inputs, issuer, seniority, maturity and bucket.']),
                (1070,490,'RRAO | INSTRUMENTS',['Gross notional and residual-risk category. Apply the regulatory scope tests.'])]:d.card(x,206,w,190,t,b)
for x in [285,800,1315]:d.arrow(x,396,x,439)
d.bar(444,2,'CALCULATE EACH BRANCH','use the appropriate rules within each branch')
d.card(40,510,490,356,'SBM | MAR21',[
    'Net sensitivities by risk factor; apply regulatory risk weights.',
    'Aggregate within buckets, then across buckets, by risk class and risk measure.',
    'For curvature, apply its prescribed upward/downward shock and aggregation rules.'])
d.card(555,510,490,356,'DRC | MAR22',[
    'Determine gross jump-to-default and apply permitted netting.',
    'Separate non-securitisations, securitisations and correlation-trading portfolios.',
    'Apply bucket weights and permitted hedge recognition under the relevant rules.'])
d.card(1070,510,490,356,'RRAO | MAR23',[
    'Identify instruments in the residual-risk scope.',
    'Multiply gross notional by the applicable residual-risk weight.',
    'Sum the instrument charges; no offset against SBM or DRC.'])
for x in [285,800,1315]:d.arrow(x,866,x,904)
d.card(40,914,490,180,'K SBM',[
    'For each correlation scenario, sum delta, vega and curvature across risk classes.',
    'Take the maximum scenario total.'],dark=True,size=21)
d.card(555,914,490,180,'K DRC',[
    'Sum the applicable default-risk capital components.'],dark=True)
d.card(1070,914,490,180,'K RRAO',[
    'Sum residual-risk charges on gross notionals.'],dark=True)
for x in [285,800,1315]:d.arrow(x,1094,x,1138)
d.bar(1145,3,'ADD THE THREE CAPITAL COMPONENTS')
d.text(800,1236,'K FRTB-SA = K SBM + K DRC + K RRAO',34,NAVY,True,'middle')
d.text(800,1280,'RWA FRTB-SA = 12.5 × K FRTB-SA',27,BLUE,True,'middle')
d.foot('Sources: Basel MAR20.1 and MAR20.4; MAR21, MAR22 and MAR23.','Full framework shown. The K-FRTB-SA prototype covers a subset; this diagram does not expand its implemented scope.')
d.save()

hub('CVA_uses','Where CVA risk fits in the capital framework',
    'A separate charge for adverse changes in credit valuation adjustment',
    'K-CVA | REGULATORY CVA CAPITAL','CVA valuation, CCR exposure and CVA capital are distinct measures',[
    ('1 | The risk being capitalised',['CVA changes with counterparty credit quality and the market factors driving derivative exposure.']),
    ('2 | Covered transactions',['Start from the regulatory CVA perimeter: covered derivatives and material SFT CVA risk, with exemptions applied.']),
    ('3 | BA-CVA route',['Use supplied exposure values, effective maturities and counterparty characteristics. Full BA-CVA recognises eligible credit hedges.']),
    ('4 | SA-CVA route',['Use regulatory CVA and eligible hedge sensitivities. Supervisory approval and the relevant risk-management capabilities are required.']),
    ('5 | Capital and RWA',['Produce a CVA own funds requirement and its RWA equivalent. Add it separately in the bank-wide capital framework.']),
    ('6 | Link to exposure engines',['SA-CCR exposure can feed BA-CVA. SA-CVA instead needs CVA sensitivities; EAD alone is insufficient.'])],
    'Sources: Basel MAR50; CRR Part Three, Title VI; Bundesbank, CVA risk.','Method map. Eligibility, exemptions and any simplified route depend on the applicable regulatory profile.')

d=Diagram('CVA_aggregation','How CVA capital aggregates its inputs','Choose the applicable approach for each covered portfolio',1330)
d.bar(140,1,'DEFINE COVERAGE AND METHOD','identify exemptions and eligible hedges first')
d.card(40,206,740,155,'BA-CVA | EXPOSURE-BASED INPUTS',[
    'Netting-set exposure values, effective maturities, counterparty characteristics and eligible credit hedges.'])
d.card(820,206,740,155,'SA-CVA | SENSITIVITY-BASED INPUTS',[
    'Supplied regulatory CVA sensitivities and eligible hedge sensitivities; supervisory approval required.'])
d.arrow(410,361,410,405);d.arrow(1190,361,1190,405)
d.bar(410,2,'AGGREGATE UNDER THE CHOSEN APPROACH','BA-CVA and SA-CVA are alternative routes')
d.card(40,476,740,340,'BA-CVA',[
    'Build the stand-alone counterparty risk amounts from the relevant exposure and maturity inputs.',
    'Reduced version: aggregate counterparty amounts with prescribed dependence; no hedge recognition.',
    'Full version: recognise eligible credit hedges and retain the reduced-version component that limits hedge benefit.'])
d.card(820,476,740,340,'SA-CVA',[
    'Map CVA and hedge sensitivities to risk classes, risk factors and buckets.',
    'Apply prescribed weights, hedge offsets and within-/across-bucket aggregation.',
    'Aggregate delta and vega requirements. This route has no curvature or default-risk component.'])
d.arrow(410,816,410,855);d.arrow(1190,816,1190,855)
d.card(40,865,740,120,'BA-CVA CAPITAL REQUIREMENT',[
    'Apply the selected version and relevant regulatory adjustments.'],dark=True,size=21)
d.card(820,865,740,120,'SA-CVA CAPITAL REQUIREMENT',[
    'Apply the prescribed aggregation and regulatory adjustments.'],dark=True,size=21)
d.bar(1030,3,'REPORT CVA CAPITAL SEPARATELY','avoid counting the same portfolio twice')
d.text(800,1125,'RWA CVA = 12.5 × K CVA',34,NAVY,True,'middle')
d.text(800,1175,'CVA capital supplements the bank-wide requirement; it is outside SBM + DRC + RRAO.',24,BLUE,True,'middle')
d.foot('Sources: Basel MAR50; CRR Part Three, Title VI; Bundesbank, CVA risk.','Conceptual calculation map. It does not assert that either approach is currently implemented in K-CVA.')
d.save()

readme='''# Market risk visual set

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
'''
(OUT/'README.md').write_text(readme)
if args.archive:
    with zipfile.ZipFile(OUT.parent/'Market-risk-visuals.zip','w',zipfile.ZIP_DEFLATED) as z:
        for p in sorted(OUT.iterdir()):z.write(p,p.name)
        z.write(Path(__file__),'build_market_diagrams.py')
print(OUT)
