;; -*- coding: utf-8-unix -*-
;; History for SLIME REPL. Automatically written.
;; Edit only if you know what you're doing
("test-array" "(defvar test-array (make-array 1 :initial-contents '(1)))" "(defvar test-array (make-array (list 1) :initial-contents '(1)))" "(defvar test-array (make-array (list 1) :initial-contents '1))" "(coerce 1 'array)" "(coerce '(a b c) 'array)" "(coerce '(1 2 3 4) 'array)" "(count-items '(1 2 3 4 5 6))" "(div-con 640 1680)" "(div-con 1680 640)" "(rem 1680 640)" "(div-con 5 2)" "(div-con 4 2)" "(mod 4 2)" "0" "(= (mod 4 2) 0)" "(mod 5 2)" "(min 640 1680)" "(min 1680 640)" "(= (div-con 640 1680) 80)" "(= (div-con 1680 640) 80)" "(test-key \":x\" 0)" "(test-key \":x\")" "(test-key)" "(test-key (:k))" "(test-key :k)" "(test-key :k 'k)" "(test-key :k k)" "tot" "(defun nest (&rest args)
           (defvar tot 0)
           (loop :for x :in args
                 :do (if (listp x)
                         (incf tot (nest x))
                         (incf tot x)))
           tot)" "(nest 1 2 3 4 5)" "(return nest tot)" "(defun nest (&rest args)
           (setf tot 0)
           (loop :for x :in args
                 :do (if (listp x)
                         (incf tot (nest x))
                         (incf tot x)))
           (return tot))" "(nest 1 2 3 4 5 6)" "(nest 1 '(2 3) 4)" "(nest '(1 2 3 4 5))" "(defun nest (&rest args)
           (setf tot 0)
           (loop :for x :in args
                 :do (if (listp x)
                         (incf tot (nest x))
                         (incf tot x)))
           tot)" "(defun next (&rest args))" "(defu nest (&rest args))" "(def nest (&rest args))" "(defun nest (&rest args))" "(net.didierverna.clon:defsynopsis)" "(:net.didierverna.clon:defsynopsis)" "(defsynopsis)" "(asdf:load-system :net.didierverna.clon)" "(in-package :pelo/pelo)" "(asdf:make :pelo)" "(asdf:make :scripts)" "(print 3)" "(null '())" "(coerce '(#\\t #\\e #\\s #\\t) 'string)" "(coerce \"test\" 'list)" "(list \"test\")" "(binary-search 7 a (aref a 0) (aref a (- (length a) 1)))" "(binary-search 6 a (aref a 0) (aref a (- (length a) 1)))" "(binary-search 5 a (aref a 0) (aref a (- (length a) 1)))" "(binary-search 3 a (aref a 0) (aref a (- (length a) 1)))" "(floor (aref a (- (length a) 1)) 2)" "(floor (aref a (- (length a) 1)))" "(binary-search 3 a 1 10)" "(floor right)" "(binary-search 5 a 0 9)" "(floor 11 2)" "(floor 10 2)" "(floor 10 1)" "(describe 'floor)" "(floor 5)" "(floor 1 10)" "(binary-search 5 a 1 10)" "(aref a (- (length a) 1))" "(aref a 0)" "(floor 7 2)" "3" "(binary-search a (read) 0 9)" "(binary-search)" "a" "(defun binary-search ()
  (let* ((array a)
         (left (aref array 0))
         (right (aref array (- (length array) 1)))
         (mid (/ (+ left right) 2)))
    ))" "(length a)" "(setf (aref a 10) 11)" "(setf (aref a 9) 10)" "(setf (aref a 8) 9)" "(setf (aref a 7) 8)" "(setf (aref a 6) 7)" "(setf (aref a 5) 6)" "(setf (aref a 4) 5)" "(setf (aref a 3) 4)" "(setf (aref a 2) 3)" "(setf (aref a 1) 2)" "(setf (aref a 0) 1)" "(defvar a (make-array 10))" "(aref (make-array 10) 10)" "(aref (make-array 10) 0)" "(aref (make-array 10) 2)" "(make-array 10)" "(make-array)" "(string-append )" "(asdf:make :trivial-signal)" "(asdf:make :trivial-signal-asd)" "(case (intern \"b\")
           ((test |b|)  'hey))" "(case (intern \"b\")
           ((|b| test)  'hey))" "(case (intern name)
           (|b| 'eh))" "(case (intern \"b\")
           (intern 'hey))" "(case (intern \"b\")
           (|b| 'hey))" "(type-of \"remote\")" "(type-of 'remote)" "(type-of remote)" "(case (intern \"d\")
           ((d D) t))" "(case (intern \"d\")
           ((d D |d|) t))" "(string= (intern \"b\") '|b|)" "(string= (intern \"b\") |b|)" "(intern \"b\")" "(case (intern \"test\")
           (|test| t))" "(intern \"test\")" "(case (intern \"test\")
           ('test t))" "(case (intern \"test\")
           (test t))" "(let ((b (string \"test\")))
           (case \"test\"
             ((b) t)))" "(let ((b (string \"test\")))
           (case \"test\"
             (b t)))" "(let (b (string \"test\"))
           (case \"test\"
             (b t)))" "(type-of (string \"test\"))" "(string \"test\")" "(case \"test\"
           ((string \"test\") t))" "(case \"test\"
           (\"test\" t))" "(case \"test\"
           (\"test t\"))" "(case \"test\"
           (#\\t #\\e #\\s #\\t t))" "(case #\\v\\#\\t
           (#\\v\\#\\t t))" "(case #\\v#\\t
           (#\\v#\\t t))" "(case #\\v
           (#\\v t))" "(case \"test\"
           ((\"test\") t))" "(case \"test\"
           ('test t))" "(type-of 'string)" "(case 'test
           ('test t))" "(case test
           (test t))" "(case \"test\"
           (test t))" "(case \"test\"
           ((test) t))" "(case (+ 1 2)
           ((4 4 3) t))" "(case (+ 1 2)
           ((4 4) t))" "(case (intern \"test\")
           (4 t)
           (5 t)
           (|test| t)
           (2 t))" "(case (intern \"TEST\")
           (4 t)
           (5 t)
           (test t)
           (2 t))" "(case (intern \"test\")
           (4 t)
           (5 t)
           (test t)
           (2 t))" "(type-of (intern \"test\"))" "(symbol-name \"test\")" "(case '\"test\"
           (4 t)
           (5 t)
           (test t)
           (2 t))" "(case 'test
           (4 t)
           (5 t)
           (test t)
           (2 t))" "(case \"test\"
           (4 t)
           (5 t)
           (test t)
           (2 t))" "(case \"test\"
           (4 t)
           (5 t)
           ('test t)
           (2 t))" "(case \"test\"
           (4 t)
           (5 t)
           (\"test\" t)
           (2 t))" "(case (+ 1 2)
           (4 t)
           (5 t)
           (3 t)
           (2 t))" "(case (+ 1 2)
           (4 t))" "(case (+ 1 2)
           (3 t))" "(ping-host 'youtube.com nil)" "*beep-online*" "(beep-on)" "(beepon)" "(time (beep-on))" "(uiop:launch-program `(\"play\" ,(namestring (home *online*))))" "(uiop:launch-program `(\"play\" ,(home *online*)))" "(uiop:launch-program `(\"play\" (home *online*)))" "(uiop:launch-program \"play\" \"/home/zhaqenl/common-lisp/pelo/resources/online.mp3\")" "(uiop:launch-program (\"play\" \"/home/zhaqenl/common-lisp/pelo/resources/online.mp3\"))" "(uiop:launch-program `(\"play\" \"/home/zhaqenl/common-lisp/pelo/resources/online.mp3\"))" "(uiop:launch-program `(\"play\" \"/home/zhaqenl/common-lisp/pelo/resources/offline.mp3\"))" "(asdf:make)" "(uiop:run-program `(\"play\" \"/home/zhaqenl/common-lisp/pelo/resources/offline.mp3\"))" "(uiop:run-program `(play \"/home/zhaqenl/common-lisp/pelo/resources/offline.mp3\"))" "(uiop:run-program (play \"/home/zhaqenl/common-lisp/pelo/resources/offline.mp3\"))" "(setf *beep-online* t) " "(setf *beep-online*t) " "(setf *beep-online* nil)" "(time (inferior-shell:run/i `(play \"/home/zhaqenl/common-lisp/pelo/resources/offline.mp3\")))" "(inferior-shell:run/i `(play \"/home/zhaqenl/common-lisp/pelo/resources/offline.mp3\"))" "(inferior-shell:run/i `(play \"/home/zhaqenl/common-lisp/pelo/resources/offline.mp3\") :time t :output nil :error-output nil)" "(inferior-shell:run `(play \"/home/zhaqenl/common-lisp/pelo/resources/offline.mp3\") :time t :output nil :error-output nil)" "(inferior-shell:run `(play \"/home/zhaqenl/common-lisp/pelo/resources/offline.mp3\") :time t :output nil)" "(inferior-shell:run `(play \"/home/zhaqenl/common-lisp/pelo/resources/offline.mp3\") :time t :input nil :output nil :error-output nil)" "(inferior-shell:run `(play \"/home/zhaqenl/common-lisp/pelo/resources/offline.mp3\") :time t)" "(inferior-shell:run/nil `(play \"/home/zhaqenl/common-lisp/pelo/resources/offline.mp3\") :time t)" "(setf *beep-online* t)" "(describe 'uiop:run-program)" "(setf *interval* 1)" "(setf *interval* 2)" "(ping 'youtube.com nil)" "(describe 'inferior-shell:run/interactive)" "(describe 'inferior-shell:run/i)" "(describe 'inferior-shell:run)" "(describe 'inferior-shell/run)" "(and *beep-online* (beep-on))" "(bee-pon)" "(inferior-shell:run `(play ,(home *online*)) :error-output nil)" "(statistics)" "(ping-host 'yotuube.com nil)" "(asdf:make :pel)" "(ping-host 'youtube.com inl)" "(format *debug-io* \"~&~A ~A~&\" \"test\" \"test\")" "(ping-host 'youtube.com t)" "*online*" "(defvar *online* \"/home/zhaqenl/common-lisp/pelo/resources/online.mp3\" \"Sound file for online host\")" "(inferior-shell:run `(play ,*online*))" "(inferior-shell:run `(play *online*))" "(,*online*)" "(*online*)")