# Emergency Letter

Dead man's switch for decrypting secret messages with a time-delay lock.

## Developing

Required tools:

- [Java 11 JDK](https://www.oracle.com/java/technologies/javase-downloads.html)
- [Leiningen](https://leiningen.org)
- [tfenv](https://github.com/tfutils/tfenv)

### Commands

Build the app:

    ./scripts/build.sh

Deploy the app:

    ./scripts/build.sh
    docker-compose build native         # or "jvm"
    ./scripts/deploy.sh

Run the app with OpenJDK: 

    docker-compose up -d --build jvm

Run the app with GraalVM. This also writes native-image configuration to `resources/META-INF/native-image/*.json` files:

    docker-compose up -d --build graalvm

Run the app with GraalVM Native Image/Substrate VM:

    docker-compose up -d --build native

Try calling the app. This is useful for exercising all code paths to generate native-image configuration:

    ./smoke-test.sh

View logs:

    docker-compose logs --follow

Shutdown the app:

    docker-compose down

### Terraform commands

*All Terraform commands need to be run in the `deployment` directory.*

Preview pending changes:

    terraform plan

Apply pending changes:

    terraform apply

Upgrade Terraform providers:

    terraform init -upgrade
