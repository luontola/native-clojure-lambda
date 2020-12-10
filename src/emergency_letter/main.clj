(ns emergency-letter.main
  (:require [uswitch.lambada.core :as lambada])
  (:import (com.amazonaws.services.lambda.runtime Context)
           (java.io InputStream OutputStream)))

(lambada/deflambdafn emergency_letter.Handler [^InputStream in ^OutputStream out ^Context ctx]
  (println "emergency_letter.Handler called")
  (prn 'in (slurp in))
  (prn 'out out)
  (prn 'ctx ctx))
