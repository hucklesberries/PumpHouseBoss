# TODO

## General
- Figure out what is deleting the configuration/*-test.mk files (i think it was included in .gitignore - verify)
- rename all .yaml files .yml (and update makefiles/scripts)
- align STANDARD.md and DISPOSITION.md

## Makefile
- Consolidate or clarify ESPTOOL_CMD and PYTHON_WITH_ESPTOOL
- Build table showing what targets depend on what variables, and check for them
- Normalize all output
- Add a make-all target to build all variants

## Possible Enhancements
- Add automated linting/formatting steps (e.g., shellcheck, yamllint, markdownlint) to the check-in process
- Add a step to check for outdated dependencies and update lock files as needed
- Integrate security checks (e.g., bandit for Python, npm audit for Node) before release
- Track and enforce test coverage, ensuring new code is covered by tests