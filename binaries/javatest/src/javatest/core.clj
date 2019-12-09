(ns javatest.core
  (:gen-class))

(defn -main
  "I don't do a whole lot ... yet."
  [& args]
  (while true
    (println "Sleeping now")
    (Thread/sleep 5000)))
