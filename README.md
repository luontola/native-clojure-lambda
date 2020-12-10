# Emergency Letter

Dead man's switch for decrypting secret messages with a time-delay lock.

## Developing

Required tools:

- [Java 11 JDK](https://www.oracle.com/java/technologies/javase-downloads.html)
- [Leiningen](https://leiningen.org)
- [tfenv](https://github.com/tfutils/tfenv)

### Terraform commands

*All Terraform commands need to be run in the `deployment` directory.*

Preview pending changes:

    terraform plan

Apply pending changes:

    terraform apply

Upgrade Terraform providers:

    terraform init -upgrade
