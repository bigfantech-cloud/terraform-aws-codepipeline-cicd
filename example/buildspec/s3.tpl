version: 0.2
env:
  variables:
    ENV: ${_environment_}
    SERVICE: ${_application_name_}
phases:
  install:
    commands:
      - echo NPM version
      - npm -v
  pre_build:
    commands:
      - echo Installing NPM dependencies...
      - npm i
  build:
    commands:
      - npm run build
artifacts:
  base-directory: build
  files:
    - "**/*"