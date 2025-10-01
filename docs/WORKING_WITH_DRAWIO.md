# Working with Draw.io Diagrams

Keep the `.drawio` source in version control so changes are reviewable alongside code.

## Recommended Workflow
1. Open the relevant `.drawio` source in [draw.io](https://app.diagrams.net/) (browser) or the desktop app.
2. Update the diagram and save – the XML format is friendly to Git diffs when indentation is preserved.
3. Export a static image for quick viewing:
   - **PNG:** File → Export as → PNG → enable *Include a copy of my diagram* so reviewers can copy-crop.
   - **SVG:** File → Export as → SVG → enable *Embed images* for portability.
   - Save exports next to the source file, e.g. `docs/diagrams/<process>.drawio.png`.
4. Commit both the `.drawio` and the export together.

## CLI Automation (optional)
Install the official CLI once (requires Node.js):

```bash
npm install --save-dev @drawio/export
```

Then you can script exports, for example:

```bash
npx drawio-export --format png --output docs/diagrams/registration.drawio.png docs/diagrams/draw.registration.txt
```

Add a simple npm/yarn script or Makefile target if you want to regenerate all exports in one command.

## Large Files
If diagrams start to exceed ~10 MB, consider enabling [Git LFS](https://git-lfs.github.com/) for `.drawio` and `.png` assets to avoid bloating the repository history.

## Naming Tips
- Match file names to the process (`registration`, `login`, `mailbox`, ...).
- Use folders when several diagrams document the same area (e.g. `docs/diagrams/mailbox/sequence.drawio`).
- Reference the exports from your Markdown using relative paths so previews work in GitHub and IDEs.

