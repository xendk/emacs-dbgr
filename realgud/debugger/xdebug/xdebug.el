;;; Copyright (C) 2010-2011, 2013 Rocky Bernstein <rocky@gnu.org>
;;  `xdebug' Main interface to xdebug via Emacs
(require 'load-relative)
(require-relative-list '("../../common/helper") "realgud-")
(require-relative-list '("../../common/track") "realgud-")
(require-relative-list '("core" "track-mode") "realgud-xdebug-")
;; This is needed, or at least the docstring part of it is needed to
;; get the customization menu to work in Emacs 23.
(defgroup xdebug nil
  "XDebug"
  :group 'processes
  :group 'php
  :group 'dbgr
  :version "23.1")

;; -------------------------------------------------------------------
;; User definable variables
;;

(defcustom xdebug-command-name
  ;;"xdebug --emacs 3"
  "/home/xen/dev/xdebugclient/xdebugclient"
  "File name for executing the XDebug client script and command options.
This should be an executable on your path, or an absolute file name."
  :type 'string
  :group 'xdebug)

(defun realgud-xdebug-fn (&optional opt-command-line no-reset)
  "See `realgud-xdebug' for details."

  (let* ((cmd-str (or opt-command-line (xdebug-query-cmdline "xdebug")))
	 (cmd-args (split-string-and-unquote cmd-str))
	 (parsed-args (xdebug-parse-cmd-args cmd-args))
	 (script-args (cdr cmd-args))
	 (script-name (car script-args))
	 (cmd-buf
	   (realgud-run-process "xdebug" script-name cmd-args
			     'xdebug-track-mode no-reset)
	   ))
  ))

;;;###autoload
(defun realgud-xdebug (&optional opt-command-line no-reset)
  "Invoke the xdebug Ruby debugger and start the Emacs user interface.

String COMMAND-LINE specifies how to run xdebug.

Normally command buffers are reused when the same debugger is
reinvoked inside a command buffer with a similar command. If we
discover that the buffer has prior command-buffer information and
NO-RESET is nil, then that information which may point into other
buffers and source buffers which may contain marks and fringe or
marginal icons is reset."
  (interactive)
  (realgud-xdebug-fn opt-command-line no-reset))

(defalias 'xdebug 'realgud-xdebug)
(provide-me "realgud-")
;;; xdebug.el ends here
