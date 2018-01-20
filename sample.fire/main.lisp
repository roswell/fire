(uiop/package:define-package :sample.fire/main (:nicknames :sample.fire)
                             (:use :cl) (:shadow) (:export :f2 :f1) (:intern))
(in-package :sample.fire/main)
;;don't edit above

(defun f1 (&rest r)
  (print `(:f1 ,@r)))

(defun f2 (&rest r)
  (print `(:f2 ,@r)))
