(defproject emergency-letter "0.1.0-SNAPSHOT"

  :description "Dead man's switch for decrypting secret messages with a time-delay lock."
  :url "https://github.com/luontola/emergency-letter"
  :license {:name "Apache License 2.0"
            :url "https://www.apache.org/licenses/LICENSE-2.0"}

  :min-lein-version "2.9.0"
  :dependencies [[com.amazonaws/aws-lambda-java-core "1.2.1"]
                 [com.amazonaws/aws-lambda-java-runtime-interface-client "1.0.0"]
                 [medley "1.3.0"]
                 [org.clojure/clojure "1.10.1"]
                 [uswitch/lambada "0.1.2"]]
  :managed-dependencies [[org.clojure/spec.alpha "0.2.187"]]
  :pedantic? :abort

  :target-path "target/%s"
  :main com.amazonaws.services.lambda.runtime.api.client.AWSLambda
  :jvm-opts ["--illegal-access=deny"
             "-XX:-OmitStackTraceInFastThrow"]

  :aliases {"kaocha" ["with-profile" "+kaocha" "run" "-m" "kaocha.runner"]}
  :plugins [[lein-ancient "0.6.15"]]

  :profiles {:uberjar {:uberjar-name "emergency-letter.jar"
                       :aot :all
                       :omit-source true}
             :dev {:dependencies [[lambdaisland/kaocha "1.0.732"]
                                  [org.clojure/test.check "1.1.0"]]}
             :kaocha {}})
