# Quality Control Plan MCP Server

[![Quality Control Plan MCP server](https://glama.ai/mcp/servers/imnoo-team/quality-control-plan-mcp/badges/score.svg)](https://glama.ai/mcp/servers/imnoo-team/quality-control-plan-mcp)

**Generate quality control plans and inspection reports from technical-drawing PDFs — from any MCP-enabled assistant.**

This [Model Context Protocol](https://modelcontextprotocol.io) server exposes the engine behind [quality-check-protocol.imnoo.com](https://quality-check-protocol.imnoo.com) (by [Imnoo](https://www.imnoo.com)). Need a quality control plan for a technical drawing? Hand the PDF to your assistant and get a numbered inspection plan in about a minute: every dimensional tolerance, ISO fit, thread, geometric tolerance (GD&T) and surface finish is extracted automatically by Imnoo's drawing analysis, ballooned on the drawing and listed with its acceptance limits — ⌀50 ±0.05 becomes 49.95–50.05 — and a measuring instrument. Ask for an inspection class (100 % full inspection, Q1 reduced, Q2 spot check), keep the balloon numbers printed on the drawing or renumber them (1, 001 or D001 style, in reading or measurement order), then let it write the ballooned drawing, the complete inspection package or the Excel measurement and inspection report — the same documents the Imnoo calculator produces. It covers first-article inspection, PPAP-style dimensional reports and shop-floor quality check protocols, on vector and scanned PDFs alike. Built by Imnoo, the planning, scheduling and quoting platform for CNC manufacturers — where the same quality check protocols come out of every quote, next to cost estimation, manufacturing plans and G-code generation.

```
"Create a Q1 quality plan for flange.pdf with type-prefixed balloon numbers"
        │
        ▼  (your assistant calls the tools)
analyze_drawing ──► build_quality_plan ──► export_inspection_pdf + export_quality_plan_excel
                                                       │
                                                       ▼
                    QP-1001-A_inspection-package.pdf    D001  ⌀50 (±0.05)   49.95–50.05   Caliper
                    QP-1001-A_Q1.xlsx                   H001  ⌀10 H7        —             Inside micrometer
                                                        G001  ⏥ 0.05        —             CMM
```

## Tools

| Tool | What it does |
| --- | --- |
| `analyze_drawing` | Uploads a drawing PDF (vector or scanned, ≤ 30 MB) to Imnoo's drawing analysis — the service behind the web app — and returns every detected characteristic with type, value, PDF page, position, confidence and the balloon number printed on the drawing, plus the title block (drawing / article number, material, general tolerance). `save_analysis_to` keeps the analysis JSON for offline reuse. |
| `load_analysis` | Opens a saved analysis JSON. Fully offline — no upload, no daily credit. |
| `build_quality_plan` | Turns the analysis into the plan: balloon numbers (numeric, `001` padded, or type-prefixed `D001` / `H001` / `G001`…; printed numbers kept, or renumbered by list, reading direction or measurement sequence), acceptance limits from nominal ± tolerance, a default measuring instrument per type, inspection-class presets, selection presets (first-article = everything, production = measurable characteristics only) and per-row edits. Deterministic — iterate freely. |
| `export_quality_plan_excel` | Writes the *Measurement and inspection report* workbook: header block (article, ET-No., batch, inspection rate), visual-inspection checklist a–e, dimensional-conformity table (Insp. dim. no. · nominal dimension or thread size · tolerance range · measuring instrument · actual dimension · deviation · date · inspector), change-tracking footnotes and the special-release / signature block. Cell for cell the report the Imnoo calculator produces. |
| `export_inspection_pdf` | Writes the ballooned drawing (`ballooned`), the drawing plus the printed plan (`package`, default) or the plan document alone (`plan`): translucent boxes on every selected characteristic, numbered balloons with optional VDA-style leader arrows, the two-column general-information form, the feature table with colored number chips, instrument / sample fill-in lines, acceptance criteria and result checkboxes, and the final-approval block. The source PDF is never modified. |

Plus a `create-quality-plan` prompt that walks the assistant through analyze → review → export.

**Where the analysis runs.** `analyze_drawing` is the only tool that leaves your machine: it uploads the PDF to Imnoo's drawing analysis exactly like the web app does — **1 free analysis per day per IP address** (more when signed in), uploaded files are deleted automatically after a short retention period, nothing else is stored. Everything after that — plan building, numbering, acceptance limits, Excel and PDF generation — runs locally and offline.

## Installation

Requires Node.js ≥ 18.

### Claude Code

```bash
claude mcp add quality-control-plan -- npx -y quality-control-plan-mcp
```

### Claude Desktop

Add to `claude_desktop_config.json` (Settings → Developer → Edit Config):

```json
{
  "mcpServers": {
    "quality-control-plan": {
      "command": "npx",
      "args": ["-y", "quality-control-plan-mcp"]
    }
  }
}
```

### Cursor

[**Add to Cursor**](cursor://anysphere.cursor-deeplink/mcp/install?name=quality-control-plan&config=eyJjb21tYW5kIjoibnB4IiwiYXJncyI6WyIteSIsInF1YWxpdHktY29udHJvbC1wbGFuLW1jcCJdfQ==) — or add to `~/.cursor/mcp.json`:

```json
{
  "mcpServers": {
    "quality-control-plan": {
      "command": "npx",
      "args": ["-y", "quality-control-plan-mcp"]
    }
  }
}
```

### VS Code (GitHub Copilot)

```bash
code --add-mcp '{"name":"quality-control-plan","command":"npx","args":["-y","quality-control-plan-mcp"]}'
```

### Windsurf / other stdio clients

Any client that launches stdio servers works with:

```
npx -y quality-control-plan-mcp
```

### Configuration (optional)

| Variable | Purpose |
| --- | --- |
| `IMNOO_ACCESS_TOKEN` | Your Imnoo account token (the id token of your [quality-check-protocol.imnoo.com](https://quality-check-protocol.imnoo.com) login) — raises the daily analysis limit to your plan's quota. |
| `QCP_APP_URL` | Point the analysis at another deployment of the web app (default `https://quality-check-protocol.imnoo.com`). |

## Example session

> **You:** Build a Q1 quality plan for `C:\drawings\flange.pdf` with type-prefixed numbers and write everything next to the drawing.
>
> **Assistant:** *calls `analyze_drawing`* — 17 characteristics on 2 pages: 5 dimensional tolerances, 2 drill fits (⌀10 H7 carries the printed balloon 1), 1 shaft fit, 2 threads, 1 fine thread, 2 geometric tolerances, 4 surface finishes; drawing QP-1001-A, article 4711-050, AlMg3, ISO 2768-mK. *calls `build_quality_plan` with `inspection_class: "Q1"` and `numbering: { style: "typePrefixed" }`* — D001 ⌀50 (±0.05) → 49.95–50.05 (Caliper), H001 ⌀10 H7 (Inside micrometer), G001 ⏥ 0.05 (CMM), R001 Ra 3.2 (Surface roughness gauge)… *calls `export_inspection_pdf` and `export_quality_plan_excel` with the same plan* — wrote `QP-1001-A_inspection-package.pdf` (both drawing pages ballooned + the printed plan) and `QP-1001-A_Q1.xlsx`. Two values on page 2 were read with low confidence — worth a glance before the plan goes to the shop floor.

Those numbers are the bundled sample drawing the smoke test runs against; real drawings vary.

## Plan options (the `plan` argument)

One object, accepted by `build_quality_plan` and both export tools — pass the same one everywhere so the documents match the reviewed plan. Everything is optional; the defaults reproduce the web app's initial plan.

| Option | Values |
| --- | --- |
| `numbering.style` | `numeric` (default), `padded` (`001`), `typePrefixed` (`D001` dimensional, `H` drill fit, `S` shaft fit, `T` thread, `F` fine thread, `G` geometric, `R` surface roughness, `L` length) |
| `numbering.order` | `custom` (default — balloon numbers printed on the drawing are kept, the rest fill up), `list` (plan-table order), `reading` (top-left → bottom-right, page by page), `measurement` (CMM-measured geometric tolerances first, surface finishes last) |
| `numbering.restart_per_type` | restart the counter for every characteristic type |
| `section_order` | e.g. `["dimensional", "geometric"]` — listed types first, the rest in the default measurement sequence |
| `selection` · `include` · `exclude` | `all` (default), `production` (dimensional, fits, geometric — no threads or surface finishes), `none`; or explicit feature ids |
| `inspection_class` | `100%` (rate 100 %, checklist on), `Q1` (10 %, checklist on), `Q2` (5 %, checklist off), or any custom class name |
| `header` | `batch_number`, `inspection_rate`, `inspection_class`, `inspector_name`, `signature`, `date` |
| `drawing` · `article_name` · `drawing_index` | title-block values to print when the analysis missed them (article / drawing number, material, general tolerance, article name, revision) |
| `default_tools` | measuring instrument per type — defaults: CMM, thread plug gauge, caliper, inside / outside micrometer, depth caliper, surface roughness gauge |
| `rows[]` | per characteristic (by `feature_id`): `inspection_tool`, `samples` (judged against the limits), `passed`, `balloon`, `value` (corrected value; the original is kept as a footnote) |
| `include_checklist` · `show_arrows` · `annotation` | Excel checklist toggle, leader arrows on the drawing, an "INSPECTION DRAWING" stamp block (revision, note) |

## How the plan is derived

- Acceptance limits exist for plain dimensional tolerances with a numeric nominal (nominal + lower / upper deviation, rounded to 2 decimals). Fits, threads, geometric tolerances and surface finishes are gauged rather than measured against limits — the same rule as the Imnoo calculator.
- Balloon numbers are derived from the selection and the numbering settings, so dropping a characteristic renumbers the rest automatically; a number printed on the drawing is kept in `custom` order.
- A measured `samples` value is judged pass / fail against the limits; results and dates appear in both documents.
- The default section order is the measurement workflow: geometric tolerances (CMM) first, surface finishes (roughness gauge) last.

## Limitations

- The drawing analysis is automated: it can miss or misread characteristics, especially on low-quality scans — verify the plan against the drawing (`rows[].value` corrects a value, `exclude` drops a row).
- Free tier: 1 analysis per day per IP address; PDFs up to 30 MB. Saved analyses (`save_analysis_to` → `load_analysis`) are unlimited and offline.
- Hand-drawn characteristics, dragging balloons and saving the plan into the Imnoo calculator are features of the [web app](https://quality-check-protocol.imnoo.com) only.
- Encrypted or unusual PDFs that cannot be copied fall back to `variant: "plan"` here (the web app rasterises them instead).

## Development

This package is built from the Quality Check Protocol monorepo at [Imnoo](https://www.imnoo.com), where it imports the web app's domain layer directly (drawing mapper, plan math, numbering engine, Excel and PDF builders) — so the [web app](https://quality-check-protocol.imnoo.com) and this server produce identical plans and documents by construction. Every release is gated on 61 end-to-end checks that drive all five tools over stdio against the bundled sample drawing.

Issues and feature requests are welcome in this repository.

## About Imnoo

**Imnoo — The System for Manufacturers | AI Planning, Scheduling & Quoting · Complete Assemblies · DFM · Tool & Material Libraries · Quoted-Parts Database · Toolpath & G-Code · Machine Connection · Webshop · ERP · Shop Analytics & Optimization · Drawing Masking & IP Security**

*Plan It. Schedule It. Quote It. Win It.* — trusted by over 3,000 manufacturers.

[Imnoo](https://www.imnoo.com) is the AI-powered planning, scheduling, and quoting platform for CNC manufacturers — your automatic production platform. One system that covers it all: automatic manufacturing planning with raw-material, catalog and purchase-part, and subcontracting sourcing; scheduling with smart reminders and AI-driven customer workflows; and AI cost and cycle-time estimation for milling, turning, and EDM — even from a 2D PDF alone. Quote complete assemblies: drop in one file and Imnoo explodes it into single parts automatically — with DFM checks, quality protocols, tolerance extraction and 2D-to-3D matching, toolpath and G-code generation, tool and machine recommendations, and connected machines feeding real production data back into every quote. Built on your own tool and material libraries and a growing database of every part you've ever quoted — powering statistics, benchmarks, and shop optimization. Extends to deep hole drilling, sheet metal, casting, and profile parts — with a 24/7 webshop, built-in ERP, hourly-rate calculation, market-price benchmarking, and imperial ⇄ metric conversion. Your data lives in its own physically separated environment — automatic drawing masking, Swiss hosting, end-to-end encryption. From messy RFQ to production-ready order, on one platform.

### Planning

- **Automatic manufacturing planning** — production plans generated straight from the quote.
- **Machine recommendation** — every job routed to the machine that runs it best.
- **Catalog & purchase part management** — norm parts, screws, and bought-in components recognized straight from the BOM, managed and priced alongside your machined parts.
- **Raw material sourcing** — price, source, and order material without leaving the workflow.
- **Purchase part & external step sourcing** — bought-in components, coating, heat treatment, and subcontracting sourced and ordered in the same flow.
- **Beyond milling & turning** — deep hole drilling, sheet metal, casting, and profile parts.

### Scheduling & Workflow

- **Scheduling & smart reminders** — via email, Telegram, or WhatsApp. Nothing slips.
- **Email-to-quote automation** — a messy inbox in, structured quotes out.
- **AI customer agents** — RFQ answers, clarifications, and follow-ups handled automatically.
- **Built-in lightweight ERP** — orders, companies, payment terms, and margins without the bulky software.

### Quoting & Estimation

- **Complete assemblies, exploded automatically** — upload one assembly file and Imnoo blows it out into single parts: every component recognized, drawings matched to the right parts, sub-assemblies nested, purchase parts pulled from the BOM. Quote the whole machine as easily as one part.
- **CNC quoting in one place** — milling, turning, and EDM jobs quoted from a single AI-powered platform.
- **AI cost & cycle-time estimation** — know price, time, and effort before engineering ever looks at it.
- **Drawing-only estimation** — quote from the PDF alone. No 3D model needed.
- **Feature-by-feature costing** — see exactly which holes, pockets, and tolerances drive the price.
- **Instant quotes** — respond in minutes while competitors are still opening the STEP file.
- **24/7 instant-quoting webshop** — customers upload parts and buy while you sleep.
- **Instant market-price benchmarking** — know where your bid stands before you send it.
- **Hourly-rate calculation** — your true machine and labor rates, always current.
- **Imperial ⇄ metric conversion** — international RFQs without manual cleanup.

### Libraries & Insights

- **Tool library** — your cutting tools, holders, and parameters in one managed catalog.
- **Material library** — standard and custom materials with live supplier pricing.
- **Quoted-parts database** — every part you've ever quoted, searchable by geometry: similar part found, price found.
- **Statistics & analytics** — win rates, margins, throughput, and quoting performance at a glance.
- **Shop optimization** — learn from already-quoted parts to sharpen prices, spot profitable niches, and load the right machines.

### Drawing Intelligence

- **DFM — Design for Manufacturing** — manufacturability checked before you quote: undercuts, thin walls, unreachable features, and impossible tolerances flagged with the part still on the screen.
- **Quality check protocols** — inspection plans generated automatically: stamped and numbered drawing features, inspection classes and rates, ready-to-use measurement reports.
- **Axis & orientation detection** — AI finds the best part orientation and machining axes.
- **Automatic tolerance extraction** — critical tolerances pulled straight off the drawing.
- **2D-to-3D tolerance matching** — drawing requirements linked to the right model features.

### CAM & Shop Intelligence

- **AI tool recommendation** — stop searching catalogs: Imnoo suggests the exact cutting tools for every feature.
- **Automatic toolpath generation** — from quote to machining strategy in one step.
- **G-code generation & estimation** — generate and evaluate programs before work hits the floor.
- **Machine connection** — your machines feed real production data back into the AI. Every quote gets smarter.

### IP Protection & Data Security — Engineered Like a Swiss Vault

- **Physically separated data** — every manufacturer runs in its own isolated environment. Your drawings, prices — never pooled with anyone else's: not for storage, not for AI training.
- **Automatic drawing masking & redaction** — customer names, logos, and confidential data hidden before a drawing ever leaves your workflow. Share with suppliers and subcontractors without exposing whose part it is.
- **Your customers' IP, treated like your own** — end customers' designs stay within your tenant, full stop.
- **Swiss hosting & end-to-end encryption** — data sovereignty and security engineered to Swiss standards.
- **Trusted at scale** — over 3,000 manufacturers run their quoting on Imnoo.

Quote the complete job — not just the spindle time.

👉 [Book a demo at imnoo.com](https://www.imnoo.com)

## License

[MIT](./LICENSE) © Imnoo AG
