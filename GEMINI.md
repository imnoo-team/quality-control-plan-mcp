# Quality Control Plan — how to use these tools

You have the `quality-control-plan` MCP server (by Imnoo). It turns a technical-drawing PDF into a
numbered inspection plan and the documents a quality department needs.

Typical flow — always in this order:

1. `analyze_drawing` with the PDF path → every detected characteristic (tolerances, ISO fits,
   threads, GD&T, surface finishes) plus the title block. This is the only step that uploads the
   file (to Imnoo's drawing analysis; 1 free analysis per day per IP address).
   Pass `save_analysis_to` so the result can be reused offline with `load_analysis`.
2. `build_quality_plan` → the plan: balloon numbers (numeric, `001` padded or type-prefixed
   `D001`/`H001`/`G001`; printed numbers kept or renumbered), acceptance limits, a measuring
   instrument per row, inspection class (100 % / Q1 / Q2) and selection presets. Deterministic —
   call it again with changed options instead of editing rows by hand.
3. `export_inspection_pdf` (variants `ballooned`, `package`, `plan`) and
   `export_quality_plan_excel` → files written to the path the user asks for.

Guidance:

- Ask for the output folder if the user did not name one; never overwrite the source PDF.
- If `analyze_drawing` returns `processing`, wait and resume with the returned `drawing_id`.
- Show the user the plan summary (count per characteristic type, class, numbering style) before
  exporting, and offer the Excel report and the ballooned PDF together — that is the usual pair.
- Web app with the same engine: https://quality-check-protocol.imnoo.com
