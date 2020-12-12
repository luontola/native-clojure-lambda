(ns hello-world.main-test
  (:require [clojure.test :refer :all]
            [hello-world.main :as main])
  (:import (com.amazonaws.services.lambda.runtime RequestStreamHandler)))

(deftest lambda-handler-test
  (testing "lambda handler class exists"
    (compile 'hello-world.main)
    (is (= [RequestStreamHandler]
           (seq (.getInterfaces (Class/forName main/handler-class)))))))
