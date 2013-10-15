;;; Copyright (C) 2013
(eval-when-compile (require 'cl))

(require 'load-relative)
(require-relative-list '("../../common/regexp"
			 "../../common/loc"
			 "../../common/init")
		       "realgud-")

(defvar realgud-pat-hash)
(declare-function make-realgud-loc-pat (realgud-loc))

(defvar realgud-xdebug-pat-hash (make-hash-table :test 'equal)
  "Hash key is the what kind of pattern we want to match:
backtrace, prompt, etc.  The values of a hash entry is a
realgud-loc-pat struct")

;; Regular expression that describes a xdebug location generally shown
;; before a command prompt.
;; For example:
;; -- (/tmp/linecache.rb:64)
;; C> (/tmp/eval.rb:2)
(setf (gethash "loc" realgud-xdebug-pat-hash)
      (make-realgud-loc-pat
       :regexp "\nfile://\\([^:]+\\):\\([0-9]+\\)> "
       :file-group 1
       :line-group 2))

;; Regular expression that describes a xdebug command prompt
;; For example:
;;   file:num>
(setf (gethash "prompt" realgud-xdebug-pat-hash)
      (make-realgud-loc-pat
       :regexp "^.+> "
       ))

;; Regular expression that describes a Ruby YARV 1.9 syntax error line.
;; (setf (gethash "syntax-error" realgud-trepan-pat-hash)
;;       realgud-ruby-YARV-syntax-error-pat)

;; Regular expression that describes a Ruby YARV 1.9 backtrace line.
;; For example:
;; <internal:lib/rubygems/custom_require>:29:in `require'
;; <internal:lib/rubygems/custom_require>:29:in `require'
;; /tmp/Rakefile:50:in `<top /src/external-vcs/laser/Rakefile>'
;;	from /usr/lib/ruby/gems/rspec/compatibility.rb:6:in `const_missing'
;; (setf (gethash "lang-backtrace" realgud-trepan-pat-hash)
;;   (make-realgud-loc-pat
;;    :regexp "^\\(?:[\t]from \\)?\\([^:]+\\):\\([0-9]+\\)\\(?:in `.*'\\)?"
;;    :file-group 1
;;    :line-group 2))

;;  Regular expression that describes a ruby $! backtrace
;; (setf (gethash "dollar-bang-backtrace" realgud-trepan-pat-hash)
;;       realgud-ruby-dollar-bang-loc-pat)

;; Regular expression that describes a "breakpoint set" line.
;; For example:
;;   Breakpoint set at line 12 in /var/www/index.php
(setf (gethash "brkpt-set" realgud-xdebug-pat-hash)
      (make-realgud-loc-pat
       :regexp "\nBreakpoint set at line \\([0-9]+\\) in file \\(.+\\)\n"
       ; :num 1
       :file-group 2
       :line-group 1))

;; Regular expression that describes a debugger "delete" (breakpoint) response.
;; For example:
;;   Deleted breakpoint 1.
;; (setf (gethash "brkpt-del" realgud-trepan-pat-hash)
;;       (make-realgud-loc-pat
;;        :regexp "^Deleted breakpoint \\([0-9]+\\)\n"
;;        :num 1))

;; (defconst realgud-trepan-selected-frame-indicator "-->"
;; "String that describes which frame is selected in a debugger
;; backtrace listing.")

;; (defconst realgud-trepan-frame-file-regexp
;;   "[ \t\n]+in file \\([^ \n]+\\)")

(defconst realgud-xdebug-debugger-name "xdebug" "Name of debugger")

;; Top frame number
(setf (gethash "top-frame-num" realgud-xdebug-pat-hash) 0)

;; Regular expression that describes a debugger "selected" frame in in
;; a frame-motion command.
;; For example:
;; --> #1 TOP Object#<top /usr/local/bin/irb> in file /usr/local/bin/irb at line 9
;; (setf (gethash "selected-frame" realgud-trepan-pat-hash)
;;       (make-realgud-loc-pat
;;        :regexp
;;        (format "^%s #\\([0-9]+\\) .*%s"
;; 	       realgud-trepan-selected-frame-indicator
;; 	       realgud-trepan-frame-file-regexp)
;;        :num 1))

;; (setf (gethash "control-frame" realgud-trepan-pat-hash)
;;       (make-realgud-loc-pat
;;        :regexp "^c:\\([0-9]+\\) p:\\([0-9]+\\) s:\\([0-9]+\\) b:\\([0-9]+\\) l:\\([0-9a-f]+\\) d:\\([0-9a-f]+\\) \\([A-Z]+\\) \\(.+\\):\\([0-9]+\\)"
;;        :file-group 8
;;        :line-group 9))

;;  Regular expression that describes a Ruby $! string
;; (setf (gethash "dollar-bang" realgud-trepan-pat-hash)
;;       realgud-ruby-dollar-bang-loc-pat)

;;  Regular expression that describes debugger "backtrace" command line.
;;  e.g.
;; --> #0 METHOD Object#require(path) in file <internal:lib/require> at line 28
;;     #1 TOP Object#<top /tmp/linecache.rb> in file /tmp/linecache.rb
;; (setf (gethash "debugger-backtrace" realgud-trepan-pat-hash)
;;       (make-realgud-loc-pat
;;        :regexp 	(concat realgud-trepan-frame-start-regexp " "
;; 			realgud-trepan-frame-num-regexp " "
;; 			"\\([A-Z]+\\) *\\([A-Z_][a-zA-Z0-9_]*\\)[#]\\(.*\\)"
;; 			realgud-trepan-frame-file-regexp
;; 			"\\(?:" realgud-trepan-frame-line-regexp "\\)?"
;; 			)
;;        :num 2
;;        :file-group 6
;;        :line-group 7)
;;       )

;; Regular expression that for a termination message.
(setf (gethash "termination" realgud-xdebug-pat-hash)
       "^Exiting.\n")

;; (setf (gethash "font-lock-keywords" realgud-trepan-pat-hash)
;;       '(
;; 	;; The frame number and first type name, if present.
;; 	("^\\(-->\\|   \\)? #\\([0-9]+\\) \\([A-Z]+\\) *\\([A-Z_][a-zA-Z0-9_]*\\)[#]\\([a-zA-Z_][a-zA-Z_[0-9]]*\\)?"
;; 	 (2 realgud-backtrace-number-face)
;; 	 (3 font-lock-keyword-face)         ; e.g. METHOD, TOP
;; 	 (4 font-lock-constant-face)        ; e.g. Object
;; 	 (5 font-lock-function-name-face nil t))   ; t means optional
;; 	;; Instruction sequence
;; 	("<\\(.+\\)>"
;; 	 (1 font-lock-variable-name-face))
;; 	;; "::Type", which occurs in class name of function and in parameter list.
;; 	;; Parameter sequence
;; 	("(\\(.+\\))"
;; 	 (1 font-lock-variable-name-face))
;; 	;; "::Type", which occurs in class name of function and in parameter list.
;; 	("::\\([a-zA-Z_][a-zA-Z0-9_]*\\)"
;; 	 (1 font-lock-type-face))
;; 	;; File name.
;; 	("[ \t]+in file \\([^ ]+*\\)"
;; 	 (1 realgud-file-name-face))
;; 	;; Line number.
;; 	("[ \t]+at line \\([0-9]+\\)$"
;; 	 (1 realgud-line-number-face))
;; 	;; Function name.
;; 	("\\<\\([a-zA-Z_][a-zA-Z0-9_]*\\)\\.\\([a-zA-Z_][a-zA-Z0-9_]*\\)"
;; 	 (1 font-lock-type-face)
;; 	 (2 font-lock-function-name-face))
;; 	;; (trepan-frames-match-current-line
;; 	;;  (0 trepan-frames-current-frame-face append))
;; 	))

;; (setf (gethash "font-lock-keywords" realgud-trepan-pat-hash)
;;       '(
;; 	;; The frame number and first type name, if present.
;; 	((concat realgud-trepan-frame-start-regexp " "
;; 			realgud-trepan-frame-num-regexp " "
;; 			"\\([A-Z]+\\) *\\([A-Z_][a-zA-Z0-9_]*\\)[#]\\([a-zA-Z_][a-zA-Z_[0-9]]*\\)?")
;; 	 (2 realgud-backtrace-number-face)
;; 	 (3 font-lock-keyword-face)         ; e.g. METHOD, TOP
;; 	 (4 font-lock-constant-face)        ; e.g. Object
;; 	 (5 font-lock-function-name-face nil t))   ; t means optional
;; 	;; Instruction sequence
;; 	("<\\(.+\\)>"
;; 	 (1 font-lock-variable-name-face))
;; 	;; "::Type", which occurs in class name of function and in
;; 	;; parameter list.  Parameter sequence
;; 	("(\\(.+\\))"
;; 	 (1 font-lock-variable-name-face))
;; 	;; "::Type", which occurs in class name of function and in
;; 	;; parameter list.
;; 	("::\\([a-zA-Z_][a-zA-Z0-9_]*\\)"
;; 	 (1 font-lock-type-face))
;; 	;; File name.
;; 	(realgud-trepan-frame-file-regexp (1 realgud-file-name-face))
;; 	;; Line number.
;; 	(realgud-trepan-frame-line-regexp (1 realgud-line-number-face))
;; 	;; Function name.
;; 	("\\<\\([a-zA-Z_][a-zA-Z0-9_]*\\)\\.\\([a-zA-Z_][a-zA-Z0-9_]*\\)"
;; 	 (1 font-lock-type-face)
;; 	 (2 font-lock-function-name-face))
;; 	;; (trepan-frames-match-current-line
;; 	;;  (0 trepan-frames-current-frame-face append))
;; 	))

(setf (gethash realgud-xdebug-debugger-name realgud-pat-hash) realgud-xdebug-pat-hash)

(defvar realgud-xdebug-command-hash (make-hash-table :test 'equal)
  "Hash key is command name like 'quit' and the value is
  the xdebug command to use, like 'quit!'")

(setf (gethash "quit" realgud-xdebug-command-hash) "quit")
(setf (gethash "continue" realgud-xdebug-command-hash) "run")
(setf (gethash "finish" realgud-xdebug-command-hash) "step_out")
(setf (gethash "kill" realgud-xdebug-command-hash) "stop")
(setf (gethash "next" realgud-xdebug-command-hash) "step_over")
(setf (gethash "step" realgud-xdebug-command-hash) "step_into")
(setf (gethash realgud-xdebug-debugger-name
	       realgud-command-hash) realgud-xdebug-command-hash)

(provide-me "realgud-xdebug-")
