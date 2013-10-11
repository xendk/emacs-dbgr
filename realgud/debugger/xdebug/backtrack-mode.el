;;; Copyright (C)

;;; Mode for parsing various kinds of backtraces found in the Ruby

(eval-when-compile (require 'cl))
(require 'load-relative)
(require-relative-list '(
			 "../../common/cmds"
			 "../../common/menu"
			 "../../common/backtrack-mode"
			 )
		       "realgud-")
(require-relative-list '("core" "init") "realgud-xdebug-")
(require-relative-list '("../../lang/ruby") "realgud-lang-")

(realgud-backtrack-mode-vars "xdebug")
(set-keymap-parent xdebug-backtrack-mode-map realgud-backtrack-mode-map)

(declare-function realgud-backtrack-mode(bool))

(defun realgud-xdebug-goto-control-frame-line (pt)
  "Display the location mentioned by a control-frame line
described by PT."
  (interactive "d")
  (realgud-goto-line-for-pt pt "control-frame"))

(realgud-ruby-populate-command-keys xdebug-backtrack-mode-map)
(define-key xdebug-backtrack-mode-map
  (kbd "C-c !c") 'realgud-xdebug-goto-control-frame-line)

(define-minor-mode xdebug-backtrack-mode
  "Minor mode for tracking ruby debugging inside a file which may not have process shell."
  :init-value nil
  ;; :lighter " xdebug"   ;; mode-line indicator from realgud-track is sufficient.
  ;; The minor mode bindings.
  :global nil
  :group 'xdebug
  :keymap xdebug-backtrack-mode-map

  (realgud-backtrack-set-debugger "xdebug")
  (if xdebug-backtrack-mode
      (progn
	(realgud-backtrack-mode 't)
	(run-mode-hooks (intern (xdebug-backtrack-mode-hook))))
    (progn
      (realgud-backtrack-mode nil)
      ))
)

(defun xdebug-backtrack-mode-hook()
  (if xdebug-backtrack-mode
      (progn
	(use-local-map xdebug-backtrack-mode-map)
	(message "using xdebug mode map")
	)
    (message "xdebug backtrack-mode-hook disable called"))
)

(provide-me "realgud-xdebug-")
