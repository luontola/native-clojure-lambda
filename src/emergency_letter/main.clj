(ns emergency-letter.main
  (:require [uswitch.lambada.core :as lambada])
  (:import (com.amazonaws.services.lambda.runtime Context)
           (com.amazonaws.services.lambda.runtime.api.client AWSLambda)
           (java.io InputStream OutputStream))
  (:gen-class))

(lambada/deflambdafn emergency_letter.Handler [^InputStream in ^OutputStream out ^Context ctx]
  (println "Hello world")
  (println (slurp in)))

(defn -main [& _args]
  (AWSLambda/main (into-array String ["emergency_letter.Handler"])))
