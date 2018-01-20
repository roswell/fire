(uiop/package:define-package :roswell.init.fire/main
                             (:nicknames :roswell.init.fire) (:use :cl)
                             (:shadow) (:export) (:intern))
(in-package :roswell.init.fire/main)
;;don't edit above

(defun fire (&rest r)
  (let ((name (second r)))
    (when name
      (map () (lambda (i)
                (setf name (remove i name)))
           "/\\")
      (let* ((date (get-universal-time))
             (path (merge-pathnames (format nil "~A.ros" name))))
        (handler-case
            (unless
                (prog1
                    (with-open-file (out path
                                         :direction :output
                                         :if-exists nil
                                         :if-does-not-exist :create)
                      (when out
                        (format out "~@{~A~%~}"
                                "#!/bin/sh"
                                "#|-*- mode:lisp -*-|#"
                                "#|"
                                "exec ros -Q -- $0 \"$@\"" "|#"
                                "(progn"
                                "  (ros:ensure-asdf)"
                                (format nil "  (ql:quickload '(:fire :~(~A~)) :silent t))" name) 
                                ""
                                (format nil "(defpackage :ros.script.~A.~A" name date)
                                (format nil "  (:use :~(~A~)))" name)
                                (format nil "(cl:in-package :ros.script.~A.~A)" name date)
                                ""
                                "(cl:defun main (cl:&rest argv)"
                                (format nil "  (fire/src/shelly-like::shelly argv :package (cl:find-package :ros.script.~A.~A)))"
                                        name date)
                                ";;; vim: set ft=lisp lisp:")
                        (format t "~&Successfully generated: ~A~%" path)
                        t))
                  #+sbcl (sb-posix:chmod path #o700))
              (format *error-output* "~&File already exists: ~A~%" path)
              (roswell:quit 1))
          (error (e)
            (format *error-output* "~&~A~%" e)
            (roswell:quit 1)))))))
