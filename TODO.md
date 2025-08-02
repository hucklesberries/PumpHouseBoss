# PumpHouseBoss TODO & Roadmap

> **Scope & Purpose:**
> This document tracks project tasks, enhancements, and future plans for PumpHouseBoss. It is a living list for contributors to coordinate ongoing and upcoming work.

**Usage:**
- Use checkboxes (`- [ ]` for open, `- [x]` for done) to track progress.
- Group related tasks under clear section headers.
- Keep items concise and action-oriented.


## General
- [ ] Re-think indications (8 red LEDs?) and controls
- [ ] Automations:
  - [ ] Pre-check-in procedure
    - [ ] Transfer linting from regression-test?
  - [ ] Check-in procedure
  - [ ] Post-check-in procedures


## Processes (Makefile, Automations, Workflows)
- [ ] Add wiki update process to pre-commit check-list
- [ ] Document build dependencies


## Source
- [ ] Troubleshoot PWM not-reporting (pending parts arrival)
- [ ] Investigate why BLUE LED starts blinking after a while
- [ ] Implement Display Updates
- [ ] Implement Controls

- [ ] Refine documentation for wiki and doc library
## Documentation


### Mkdocs

### Wiki
- [ ] Add diagrams/images as needed
- [ ] Invite contributors and set editing guidelines
- [ ] Plan for ongoing updates and advanced topics

**Note:** To convert the social preview SVG (e.g., `social-preview-valve2.svg`) to PNG for GitHub:
- Use Inkscape: `inkscape social-preview-valve2.svg --export-type=png --export-filename=social-preview-valve2.png -w 1280 -h 640`
- Or use an online converter (e.g., svg2png.com)
- Then upload the PNG in your repository settings for the social preview image.


## Notes & Reminders
- [ ] Must be possible to disable MMUs CTRL for lines that must NEVER be shut-off


## Possible Future Enhancements
- [ ] Add automated linting/formatting steps (e.g., shellcheck, yamllint, markdownlint) to the check-in process
- [ ] Add a step to check for outdated dependencies and update lock files as needed
- [ ] Integrate security checks (e.g., bandit for Python, npm audit for Node) before release
- [ ] Track and enforce test coverage, ensuring new code is covered by tests
- [ ] Consider CI/CD for linting, spellcheck, and test coverage
