# Repository Guidelines

## Project Structure & Module Organization
This repository is a TyranoScript visual novel project. Runtime files live in `tyrano/` and should usually be treated as vendor code. Game content lives under `data/`: scenarios in `data/scenario/`, system settings in `data/system/`, plugins in `data/others/plugin/`, backgrounds in `data/bgimage/`, character sprites in `data/fgimage/`, UI images in `data/image/`, and audio in `data/bgm/` and `data/sound/`. The entry page is `index.html`. The `AT/` directory contains the auto-tagging helper sources and binary.

## Build, Test, and Development Commands
There is no Node or Make-based build pipeline in this repository. Typical local workflows are:

`start index.html`
Launch the game directly in a browser on Windows for quick checks.

`python -m http.server 8000`
Serve the project root when browser security or plugin behavior makes file-based loading unreliable, then open `http://localhost:8000/`.

`git diff -- data/scenario`
Review scenario edits before committing.

## Coding Style & Naming Conventions
Preserve TyranoScript tag syntax and the existing file layout. Write new story content in `.ks` files under `data/scenario/`, keep related labels grouped by route or feature, and prefer small include files over large unrelated edits. Use 4-space indentation in JavaScript files when touching plugins such as `data/others/plugin/*/main.js`. Keep asset names descriptive and consistent with the current Japanese naming already used in `data/bgimage/` and `data/sound/`.

## Testing Guidelines
There is no automated test suite yet. Validate changes by running the game and checking the edited route from the title screen, including save/load, backlog, choice buttons, voice playback, and any plugin-dependent flow you touched. For scenario additions, confirm jumps, labels, and asset paths resolve without console errors.

## Commit & Pull Request Guidelines
Current history uses short, imperative subjects such as `add files`. Continue with concise commit messages, but make them more specific, for example `add title screen button assets` or `fix route jump in first.ks`. Pull requests should include a short gameplay summary, affected files, manual test notes, and screenshots for visible UI changes.

## Agent-Specific Notes
Avoid editing `tyrano/` unless the change is an intentional engine or library patch. Prefer project-level plugins in `data/others/plugin/` and document any new external asset or plugin source in the PR description.
