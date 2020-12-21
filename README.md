# Native Clojure Lambda

Example project of [Clojure](https://clojure.org/) +
[GraalVM Native Image](https://www.graalvm.org/reference-manual/native-image/) +
[AWS Lambda container images](https://aws.amazon.com/blogs/aws/new-for-aws-lambda-container-image-support/).

## Code walkthrough

The application entrypoint is [src/hello_world/main.clj](src/hello_world/main.clj)
where [lambada](https://github.com/uswitch/lambada) is used to generate a lambda handler class `hello_world.Handler`
which implements `com.amazonaws.services.lambda.runtime.RequestStreamHandler`.

To run our lambda handler inside a container image, we need
a [runtime interface client](https://docs.aws.amazon.com/lambda/latest/dg/runtimes-images.html#runtimes-api-client). For
Java, it's the `com.amazonaws.services.lambda.runtime.api.client.AWSLambda` class from
the [aws-lambda-java-runtime-interface-client](https://github.com/aws/aws-lambda-java-libs) library. We could call the
main method in `AWSLambda` from the command line, but to avoid having to specify the name of our lambda handler class on
the command line, we wrap it in our own main method in [src/hello_world/main.clj](src/hello_world/main.clj).

The runtime interface client looks for
the [AWS_LAMBDA_RUNTIME_API](https://docs.aws.amazon.com/lambda/latest/dg/runtimes-api.html) environment variable, which
contains the host and port of the AWS Lambda runtime endpoint. When running the code outside Lambda, we need to use
the [Lambda Runtime Interface Emulator](https://github.com/aws/aws-lambda-runtime-interface-emulator/) which will set
the AWS_LAMBDA_RUNTIME_API and start our application process. To run our container image conveniently both in and
outside Lambda, we use the [lambda-bootstrap.sh](lambda-bootstrap.sh) script to detect whether AWS_LAMBDA_RUNTIME_API is
defined, and use the runtime emulator if the container is running locally.

There are three Dockerfiles for packaging the application:

- [Dockerfile-jvm](Dockerfile-jvm) packages it with a normal OpenJDK JVM.
- [Dockerfile-graalvm](Dockerfile-graalvm) packages it with GraalVM and also enables
  the [native-image-agent](https://www.graalvm.org/reference-manual/native-image/BuildConfiguration/#assisted-configuration-of-native-image-builds)
  Java agent to help in writing Native Image configuration files. Normally `native-image-agent` generates the
  configuration when the process exits, but the application won't receive a shutdown signal through `aws-lambda-rie`, so
  the `config-write-period-secs` parameter is needed.
- [Dockerfile-native](Dockerfile-native) AOT compiles the application
  with [Native Image](https://www.graalvm.org/reference-manual/native-image/) and packages the resulting native binary
  (about 24 MB) into a minimal container image. The `native-image` command requires lots of time and memory. Even this
  hello world application takes 55 seconds to compile on a 2020 Intel Macbook Pro 13" while utilizing all the CPU cores
  and about 4 GB memory.

Due to [Native Image's limitations](https://www.graalvm.org/reference-manual/native-image/Limitations/), the AOT
compilation requires configuration files which among other things list all classes that are accessed using reflection
and all resources that the application loads at run time. These configuration files must be included in the application
JAR file under [META-INF/native-image](resources/META-INF/native-image) or its subdirectories. You can also
create [native-image.properties](https://www.graalvm.org/reference-manual/native-image/BuildConfiguration/#embedding-a-configuration-file)
files to specify the command line arguments to the `native-image` command.

When you run `./scripts/build.sh && docker-compose up -d --build graalvm` to start the application under GraalVM
with `native-image-agent` enabled, and invoke the application with `./smoke-test.sh`, the `native-image-agent` will
generate Native Image configuration to the `target/native-image` directory. The generated configuration can be
simplified manually, and it could be missing some entries if the tests did not execute all code paths, so it's
recommended to inspect it before including it under `META-INF/native-image`.

This project includes a bunch of
[aws-lambda-java-runtime-interface-client specific configuration](resources/META-INF/native-image/com.amazonaws/aws-lambda-java-runtime-interface-client),
but I'm working on a PR to embed that configuration inside the library, so that in the future it would work out of the box.

The only application specific Native Image configuration is
in [resources/META-INF/native-image/reflect-config.json](resources/META-INF/native-image/reflect-config.json) - the
runtime interface client uses reflection to instantiate our lambda handler. Normal Clojure code uses very little
reflection, provided your [Leiningen configuration](project.clj) has `:global-vars {*warn-on-reflection* true}` and you
add type hints where necessary.

With the Native Image configuration bundled inside the JAR, `native-image` can be called
in [Dockerfile-native](Dockerfile-native). For Clojure applications, the mandatory parameters
are `--report-unsupported-elements-at-runtime` and `--initialize-at-build-time`. The former suppresses warnings about
the Clojure compiler's code generator, which is normally called when a namespace is loaded, but Native Image doesn't
support runtime code generation. The latter loads all Clojure namespaces at build time.

### Performance

Here are some informal measurements (in December 2020) that how long it takes to invoke this hello world lambda
application, as reported by the lambda's billed duration:

|                        | JIT compiled (OpenJDK) | AOT compiled (Substrate VM) |
|------------------------|------------------------|-----------------------------|
| Local, cold start      | 1500-1600 ms           | 8-11 ms                     |
| Local, warm start      | 3-7 ms                 | 2-3 ms                      |
| AWS Lambda, cold start | 3500-4500 ms           | 350-1850 ms                 |
| AWS Lambda, warm start | 5-80 ms                | 1-2 ms                      |

The AOT compiled application itself starts in just a few milliseconds, but there is quite much overhead in the AWS
Lambda infrastructure. Normally a cold start is 300-400 ms billed duration, of which 99% is just waiting for the AWS
Lambda infrastructure to initialize. Occasionally it takes up to 2 or 3 seconds.

By the time the lambda handler is called inside AWS Lambda, the AOT compiled application process has an uptime of about
100 ms, which means the first call to `http://${AWS_LAMBDA_RUNTIME_API}/2018-06-01/runtime/invocation/next` takes 100
ms. The remaining billed 200 ms then happens either before our application process is even started, or in the call
to `http://${AWS_LAMBDA_RUNTIME_API}/2018-06-01/runtime/invocation/${REQUEST_ID}/response` after the lambda handler is
finished.

Hopefully Amazon will optimize the cold start of container images and/or only bill the time taken by our application.

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
    terraform apply -target=aws_ecr_repository.releases -target=data.aws_region.current

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
