(uiop/package:define-package :fire/src/shelly-like (:use :cl))
(in-package :fire/src/shelly-like)
;;;don't edit above

(defvar *shelly-package* (find-package :cl-user))
(defvar *shelly-debug* nil)
(defvar *shelly-eval* t)

(defun read% (args &key (depth 0) (package (find-package :cl-user)))
  (loop
     with hyphen
     with result
     with qu = 0
     for pos from 0 below (length args)
     for e = (nth pos args)
     for errorp = nil
     for read = (handler-case
                    (let ((*package* package))
                      (read-from-string e))
                  (error ()
                    (setf errorp t)
                    e))
     do (flet ((q (x)
                 (loop repeat qu
                    do (setf x `(quote ,x)))
                 (setf qu 0)
                 x))
          (tagbody
             (push
              (q (cond ((and            ; immediates.
                         (not (symbolp read))
                         (not errorp))
                        read)
                       ((equal e ":")   ; quote
                        (incf qu)
                        (go :continue))
                       ((ignore-errors  ; :string -> string
                          (equal (subseq e 0 1) ":")) 
                        (subseq e 1))
                       ((or             ; open paren
                         (string= read "[")
                         (string= read "{")
                         (string= read "("))
                        (multiple-value-bind (r num)
                            (read% (subseq args (1+ pos))
                                   :depth (1+ depth)
                                   :package package)
                          (incf pos (1+ num))
                          r))
                       ((or             ; close paren
                         (string= read "]")
                         (string= read "}")
                         (string= read ")"))
                        #1=(return-from read%
                             (values (if hyphen
                                         (let ((result (nreverse (cons (nreverse result) hyphen))))
                                           (if (zerop depth)
                                               result
                                               (cons 'progn result)))
                                         (let ((result (nreverse result)))
                                           (if (and (zerop depth)
                                                    (symbolp (first result)))
                                               (list result)
                                               result)))
                                     pos)))
                       ((string= read "--") ; divide e.g. a 1 -- b 1 -> ((a 1) (b 2))
                        (push (nreverse result) hyphen)
                        (setf result nil)
                        (go :continue))
                       ((ignore-errors  ; --keyword -> :keyword
                          (equal (subseq (string read) 0 2) "--")) 
                        (intern (subseq (string read) 2) :keyword))
                       ((uiop:file-exists-p e))      ; file
                       ((uiop:directory-exists-p e)) ; dir
                       ((and (symbolp read) ; symbols which are not belongs to read package.
                             (not (eql (symbol-package read) package))
                             (not errorp))
                        read)
                       (t e))) ; otherwise string.
              result)
           :continue))
     finally #1#))

(defun shelly (args &key (package *shelly-package*) (debug *shelly-debug*) (eval *shelly-eval*))
  "shelly flavored main"
  ;; tbd document...
  (let ((read (read% args :package package)))
    (when debug
      (print read)
      (force-output))
    (when eval
      (dolist (exp read)
        (when debug
          (print exp)
          (force-output))
        (eval exp)))))
