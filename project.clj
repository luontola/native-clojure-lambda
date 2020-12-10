(defproject emergency-letter "0.1.0-SNAPSHOT"

  :description "Dead man's switch for decrypting secret messages with a time-delay lock."
  :url "https://github.com/luontola/emergency-letter"
  :license {:name "Apache License 2.0"
            :url "https://www.apache.org/licenses/LICENSE-2.0"}

  :dependencies [[org.clojure/clojure "1.10.1"]
                 [medley "1.3.0"]]
  :managed-dependencies [[org.clojure/spec.alpha "0.2.187"]]
  :pedantic? :abort

  :main ^:skip-aot kata
  :target-path "target/%s"
  :jvm-opts ["--illegal-access=deny"
             "-XX:-OmitStackTraceInFastThrow"]

  :aliases {"kaocha" ["with-profile" "+kaocha" "run" "-m" "kaocha.runner"]}
  :plugins [[lein-ancient "0.6.15"]]

  :profiles {:uberjar {:aot :all}
             :dev {:dependencies [[lambdaisland/kaocha "1.0.732"]
                                  [org.clojure/test.check "1.1.0"]]}
             :kaocha {}})
