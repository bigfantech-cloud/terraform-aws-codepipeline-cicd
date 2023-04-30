version: 0.2
env:
variables:
    ECR_REPOSITORY_URL: "${_ecr_repository_url_}"

phases:
pre_build:
    commands:
    - echo Logging in to Amazon ECR...
    - aws --version
    - REPOSITORY_URI=$ECR_REPOSITORY_URL
    - aws ecr get-login-password | docker login --password-stdin --username AWS $REPOSITORY_URI
    - COMMIT_HASH=$(echo $CODEBUILD_RESOLVED_SOURCE_VERSION | cut -c 1-7)
    - IMAGE_TAG=$${COMMIT_HASH:=latest}

build:
    commands:
    - echo Build started on `date`
    - cat .env
    - echo Building the Docker image...
    - docker build -t $REPOSITORY_URI:latest .
    - docker tag $REPOSITORY_URI:latest $REPOSITORY_URI:$IMAGE_TAG

post_build:
    commands:
    - echo Build completed on `date`
    - echo Pushing the Docker images...
    - docker push $REPOSITORY_URI:latest
    - docker push $REPOSITORY_URI:$IMAGE_TAG
    - printf '[{"name":"${_application_name_}","imageUri":"%s"}]' $REPOSITORY_URI:$IMAGE_TAG $REPOSITORY_URI:$IMAGE_TAG > imagedefinitions.json

artifacts:
  files: imagedefinitions.json