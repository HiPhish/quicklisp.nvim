;;;; Copyright (c) 2018 HiPhish
;;;;
;;;; Permission is hereby granted, free of charge, to any person obtaining a
;;;; copy of this software and associated documentation files (the
;;;; "Software"), to deal in the Software without restriction, including
;;;; without limitation the rights to use, copy, modify, merge, publish,
;;;; distribute, sublicense, and/or sell copies of the Software, and to permit
;;;; persons to whom the Software is furnished to do so, subject to the
;;;; following conditions:
;;;;
;;;; The above copyright notice and this permission notice shall be included
;;;; in all copies or substantial portions of the Software.
;;;;
;;;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
;;;; OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
;;;; MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
;;;; NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
;;;; DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
;;;; OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
;;;; USE OR OTHER DEALINGS IN THE SOFTWARE.

;;;; This file implements the entire Quicklisp remote plugin. It defines the
;;;; functions and the command available to Vim. Tab-completion for the plugin
;;;; is implemented in a Vimscript function in another file.

(eval-when (:compile-toplevel)
  (ql:quickload :cl-neovim))

(defpackage #:quicklisp-nvim
  (:use #:cl))
(in-package #:quicklisp-nvim)


;;; ---------------------------------------------------------------------------
(defun display-nvim-error (message)
  "Display an error message in Neovim, but do not throw an actual error"
  (nvim:err-writeln message))

(defun out-writeln (message)
  "Display a MESSAGE in Neovim. Unlike `nvim:out-write` the message will be
   terminated with a line feed."
  (nvim:out-write message)
  (nvim:out-write "
"))

(defmacro string-case (string &body clauses)
  "Compare a given STRING to a series of strings, return the result of
   evaluating the body of the first matching case."
  `(cond
     ,@(loop :for (case . body) in clauses
             :collect
             `(,(if (listp case)
                  `(or ,@(loop :for literal in case
                               :collect `(string= ,string ,literal)))
                  case)
                ,@body))))


;;; ---[ NEOVIM FUNCTIONS ]----------------------------------------------------
(nvim:defun/s "QuicklispWhoDependsOn" (system-name)
  "Return a list system name strings of systems depending on SYSTEM-NAME"
  (declare (type string system-name))
  (ql:who-depends-on system-name))

(nvim:defun/s "QuicklispSystemApropos" (substring)
  "Return a list of strings representing systems containing SUBSTRING"
  (declare (type string substring))
  (mapcar (lambda (system) (format nil "~A" system))
          (ql:system-apropos-list substring)))


;;; ---[ NEOVIM COMMANDS ]-----------------------------------------------------
(defun quickload (systems)
  (declare (type list systems))
  "Quick-loads systems from the list SYSTEMS."
  (dolist (system systems)
    (declare (type string system))
    (nvim:out-write
      (format nil "~A~&"
              (with-output-to-string (*standard-output*)
                (with-output-to-string (*error-output*)
                  (ql:quickload system)))))))

(defun system-apropos (pattern)
  (declare (type string pattern))
  "Display a message listing all systems matching PATTERN"
  (let ((systems (ql:system-apropos-list pattern)))
    (nvim:out-write
      (format nil
              "Systems matching '~A':~%~{   ~A~%~}~&"
              pattern
              (mapcar (lambda (system) (format nil "~A" system))
                      systems)))))

(defun who-depends-on (system)
  "Display a message in Neovim listing all packages dependent on SYSTEM"
  (declare (type string system))
  (let ((systems (ql:who-depends-on system)))
    (nvim:out-write
      (format nil
              "The following packages depend on '~A':~%~{   ~A~%~}~&"
              system
              systems))))

(defun update-dist (distro)
  (declare (type string distro))
  "Update the distribution DISTRO"
  (out-writeln
    (with-output-to-string (*standard-output*)
      (with-output-to-string (*error-output*)
        (ql:update-dist distro)))))

(defun update-client ()
  "Update the Quicklisp client itself"
  (out-writeln
    (with-output-to-string (*standard-output*)
      (with-output-to-string (*error-output*)
        (ql:update-client)))))

(nvim:defcommand/s "Quicklisp" (sub-command &rest arg*)
  (declare (type string sub-command)
           (type list arg*)
           (opts (complete "custom,__quicklisp_cmd_completion")))
  "The main Quicklisp command for Neovim; dispatches dynamically on SUB-COMMAND"
  (string-case sub-command
    (("quickload") (quickload arg*))
    (("uninstall") (dolist (system arg*)
                     (declare (type string system))
                     (ql:uninstall system)))
    (("system-apropos") (if (= (length arg*) 1)
                          (system-apropos (elt arg* 0))
                          (out-writeln "Wrong number of arguments: requires a pattern")))
    (("who-depends-on") (if (= (length arg*) 1)
                          (who-depends-on (elt arg* 0))
                          (out-writeln "Wrong number of arguments: requires a package name")))
    (("update-dist") (if (= (length arg*) 1)
                       (update-dist (elt arg* 0))
                       (out-writeln "Wrong number of arguments: requires a distro name")))
    (("update-client") (if arg*
                         (out-writeln "Wrong number of arguments: takes no arguments")
                         (update-client)))
    (t (nvim:out-write
         (format nil
                 "Unknown Quicklisp command, use one of the following:~{~&    ~A~}~&"
                 '("quickload" "uninstall" "system-apropos" "who-depends-on" "update-dist" "update-client"))))))
