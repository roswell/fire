# fire

fire is a init script generator to invoke exproted functions.

inspired by https://github.com/google/python-fire

## Warning

This software is still ALPHA quality. The APIs will be likely to change.

## Installation

```
ros install roswell/fire
```

## Usage by example



```
$ ros init fire sample.fire
Successfully generated: sample.fire.ros
```

sample.fire.ros

```
cat sample.fire.ros
#!/bin/sh
#|-*- mode:lisp -*-|#
#|
exec ros -Q -- $0 "$@"
|#
(progn
  (ros:ensure-asdf)
  (ql:quickload '(:fire :sample.fire) :silent t))

(defpackage :ros.script.sample.fire.3725423011
  (:use :sample.fire))
(cl:in-package :ros.script.sample.fire.3725423011)

(cl:defun main (cl:&rest argv)
  (fire/src/shelly-like::shelly argv :package (cl:find-package :ros.script.sample.fire.3725423011)))
;;; vim: set ft=lisp lisp:
```

with this. You might want to edit `:use` part.

`sample.fire` is a project and it define same package name in it. The package export functions named `f1` and `f2`.

### Invoke exported function


passing numbers

```
$ ros sample.fire.ros f1 1 2 3
(:F1 1 2 3)
```

passing strings

```
$ ros sample.fire.ros f1 :"1 2 3"
(:F1 "1 2 3")
```

passing keywords

```
$ros sample.fire.ros f2 --a --b --c
(:F2 :A :B :C)
```

quoted

```
$ros sample.fire.ros f2 : 1
(:F2 1)
```

list (need to be quoted)

```
$ ros sample.fire.ros f1 : { 1 2 3 }
(:F1 (1 2 3))
```

