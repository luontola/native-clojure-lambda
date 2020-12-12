(defproject native-clojure-lambda "0.1.0-SNAPSHOT"

  :description "Example project of Clojure + GraalVM Native Image + AWS Lambda Containers"
  :url "https://github.com/luontola/native-clojure-lambda"
  :license {:name "Apache License 2.0"
            :url "https://www.apache.org/licenses/LICENSE-2.0"}

  :min-lein-version "2.9.0"
  :dependencies [[com.amazonaws/aws-lambda-java-core "1.2.1"]
                 [com.amazonaws/aws-lambda-java-runtime-interface-client "1.0.0"]
                 [medley "1.3.0"]
                 [org.clojure/clojure "1.10.2-alpha4"] ; >= 1.10.2-alpha1 is needed to avoid org.graalvm.compiler.core.common.PermanentBailoutException: Frame states being merged are incompatible: unbalanced monitors - locked objects do not match
                 [uswitch/lambada "0.1.2"]]
  :managed-dependencies [[org.clojure/spec.alpha "0.2.187"]]
  :pedantic? :abort

  :target-path "target/%s"
  :main hello-world.main
  :global-vars {*warn-on-reflection* true
                *print-namespace-maps* false}
  :jvm-opts ["--illegal-access=deny"
             "-XX:-OmitStackTraceInFastThrow"]

  :aliases {"kaocha" ["with-profile" "+kaocha" "run" "-m" "kaocha.runner"]}
  :plugins [[lein-ancient "0.6.15"]]

  :profiles {:uberjar {:uberjar-name "hello-world.jar"
                       :aot :all
                       :omit-source true}
             :dev {:dependencies [[lambdaisland/kaocha "1.0.732"]
                                  [org.clojure/test.check "1.1.0"]]}
             :kaocha {}})
