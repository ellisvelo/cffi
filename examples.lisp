;; Examples of using FSBV
;; Liam Healy 2009-04-07 22:13:34EDT examples.lisp
;; Time-stamp: <2009-04-18 18:05:28EDT examples.lisp>
;; $Id: $

(in-package :fsbv)

;;; These examples are based on GSL functions using and returning complex numbers
;;; http://www.gnu.org/software/gsl/manual/html_node/Properties-of-complex-numbers.html
;;; http://www.gnu.org/software/gsl/manual/html_node/Complex-arithmetic-operators.html

;;; Install the GSL libraries, load this file, then try
;;; (complex-abs #c(1.0d0 2.0d0))
;;; (complex-conjugate #c(1.0d0 2.0d0))
;;; (complex-add #c(1.0d0 2.0d0) #c(3.0d0 4.0d0))
;;; (complex-add-real #c(1.0d0 2.0d0) 3.0d0)

;;; Load the libraries
(cffi:load-foreign-library #+unix "libgslcblas.so")
(cffi:load-foreign-library #+unix "libgsl.so")

;;; Define the foreign struct; see /usr/include/gsl/gsl_complex.h
(defcstruct (complex :constructor complex :deconstructor (realpart imagpart))
  (dat :double :count 2))

;;; Generalize this into fsbv:with-foreign-objects
;;; where the bindings are (var type &optional initialize)
(defmacro with-complex-input ((object foreign-name) &body body)
  `(cffi:with-foreign-objects ((,foreign-name 'complex))
     (setf (foreign-object-components ,foreign-name 'complex) ,object)
     ,@body))

(defmacro complex-return (form)
  `(foreign-object-components ,form 'complex))

;;; gsl_complex_abs: an example of a function that takes a complex
;;; number and returns a double-float
(defun complex-abs (complex-number)
  (with-complex-input (complex-number gslnum)
    (foreign-funcall "gsl_complex_abs" complex gslnum :double)))

;;; gsl_complex_conjugate: an example of a function that takes a complex
;;; number and returns another complex number
(defun complex-conjugate (complex-number)
  (with-complex-input (complex-number gslin)
    (complex-return
     (foreign-funcall "gsl_complex_conjugate" complex gslin complex))))

;;; gsl_complex_add: an example of a function that takes two complex
;;; numbers and returns another complex number
(defun complex-add (c1 c2)
  (with-complex-input (c1 arg1)
    (with-complex-input (c2 arg2)
      (complex-return
	  (foreign-funcall "gsl_complex_add"
			   complex arg1 complex arg2 complex)))))

;;; gsl_complex_add_real: an example of a function that takes one complex
;;; number and one real number and returns another complex number
(defun complex-add-real (c1 real)
  (cffi:with-foreign-objects ((arg2 :double))
    (setf (foreign-object-components arg2 :double) real)
    (with-complex-input (c1 arg1)
      (complex-return
       (foreign-funcall "gsl_complex_add_real"
			complex arg1 :double arg2 complex)))))

