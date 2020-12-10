(defproject emergency-letter "0.1.0-SNAPSHOT"
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
