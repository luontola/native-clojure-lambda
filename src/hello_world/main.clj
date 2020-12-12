(ns hello-world.main
  (:require [uswitch.lambada.core :as lambada])
  (:import (com.amazonaws.services.lambda.runtime Context)
           (com.amazonaws.services.lambda.runtime.api.client AWSLambda)
           (java.io InputStream OutputStream)
           (java.lang.management ManagementFactory GarbageCollectorMXBean))
  (:gen-class))

(def handler-class "hello_world.Handler")

(lambada/deflambdafn hello_world.Handler [^InputStream in ^OutputStream out ^Context ctx]
  (println "Hello world")
  (println (slurp in))
  (println "JVM:")
  (println "uptime" (.getUptime (ManagementFactory/getRuntimeMXBean)) "ms")
  (doseq [k ["java.specification.version"
             "java.version"
             "java.vm.name"
             "java.vm.version"
             "java.vendor"
             "java.vendor.version"]]
    (println k "=" (System/getProperty k)))
  #_(doseq [[k v] (sort-by key (System/getProperties))]
      (prn k v))
  (println "GC:")
  (doseq [^GarbageCollectorMXBean bean (ManagementFactory/getGarbageCollectorMXBeans)]
    (println (.getName bean) "-" (.getCollectionCount bean) "collections, time spent" (.getCollectionTime bean) "ms")))

(defn -main [& _args]
  (AWSLambda/main (into-array String [handler-class])))
