# Native Clojure Lambda

Example project of [Clojure](https://clojure.org/) +
[GraalVM Native Image](https://www.graalvm.org/reference-manual/native-image/) +
[AWS Lambda container images](https://aws.amazon.com/blogs/aws/new-for-aws-lambda-container-image-support/).

## Developing

### Prerequisites

Build tools:

- [Java 11 JDK](https://www.oracle.com/java/technologies/javase-downloads.html)
- [Leiningen](https://leiningen.org/)
- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)

Deployment tools:

- [tfenv](https://github.com/tfutils/tfenv)
- [AWS CLI](https://aws.amazon.com/cli/)

### Building

Build the app:

    ./scripts/build.sh

Run the app with OpenJDK:

    docker-compose up -d --build jvm

Run the app with GraalVM. This also writes native-image configuration to `target/native-image` directory, from where you
can copy them to `resources/META-INF/native-image` or its subdirectories:

    docker-compose up -d --build graalvm

Run the app with GraalVM Native Image/Substrate VM:

    docker-compose up -d --build native

Try calling the app. This is useful for exercising all code paths to generate native-image configuration:

    ./smoke-test.sh

View logs:

    docker-compose logs --follow

Shutdown the app:

    docker-compose down

### Deploying

Prepare the deployment environment in AWS:

    # <change AWS_PROFILE in scripts/env-setup.sh> 
    # <change terraform backend in deployment/main.tf>
    . ./scripts/env-setup.sh 
    cd deployment
    terraform init
    terraform apply    # will fail because the new ECR repo has no images, but that's okay

Deploy the app:

    ./scripts/build.sh
    docker-compose build native         # or "jvm"
    . ./scripts/env-setup.sh 
    ./scripts/deploy.sh

### Terraform commands

*All Terraform commands need to be run in the `deployment` directory.*

Initialize the working directory. This creates a local cache in the `.terraform` directory:

    terraform init

Preview pending changes:

    terraform plan

Apply pending changes:

    terraform apply

Upgrade Terraform providers:

    terraform init -upgrade
