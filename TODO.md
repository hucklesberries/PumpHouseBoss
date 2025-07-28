# TODO

## Project
- automations:
  - pre-checkin procedure
    - transfer linting from regression-test?
  - chewck-in procedure
  - post-checkin procedures

## Source

## Build
- make
    - Build table showing what targets depend on what variables, and check for them
    - Add a make-all target to build all variants "OR" support a TESTS make variable that spawns make target for all nodes in config/phb-*-test.mk
    - distclean should wipe out regression-test.log (should it really?)
    - add 'publish' target
    - add support for serial uploads

## Documentation
- figure out how to make yaml files look reasonable after conversion to md
- review and update esphome-docs
- stand up wiki

## Next Cycle
- add/test HomeAssistant Support
- add/test Tuya support

## Notes/Reminders
- must be possbile to disable MMUs CTRL for lines that must NEVER be shut-off

## Possible Future Enhancements
- Add automated linting/formatting steps (e.g., shellcheck, yamllint, markdownlint) to the check-in process
- Add a step to check for outdated dependencies and update lock files as needed
- Integrate security checks (e.g., bandit for Python, npm audit for Node) before release
- Track and enforce test coverage, ensuring new code is coveredeby tests
- Consider CI/CD for linting, spellcheck, and test coverage
