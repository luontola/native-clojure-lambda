(ns emergency-letter.main
  (:require [uswitch.lambada.core :as lambada])
  (:import (com.amazonaws.services.lambda.runtime Context)))

(lambada/deflambdafn emergency_letter.Handler [in out ^Context ctx]
  (println "emergency_letter.Handler called")
  (prn 'in (class in) in)
  (prn 'out (class out) out)
  (prn 'ctx ctx))
