;;; Copyright (C)
;;; Ruby "xdebug" Debugger tracking a comint or eshell buffer.

(eval-when-compile (require 'cl))
(require 'load-relative)
(require-relative-list '(
			 "../../common/cmds"
			 "../../common/menu"
			 "../../common/track"
			 "../../common/track-mode"
			 )
		       "realgud-")
(require-relative-list '("core" "init") "realgud-xdebug-")
(require-relative-list '("../../lang/ruby") "realgud-lang-")

(realgud-track-mode-vars "xdebug")

(declare-function realgud-track-mode(bool))

(defun realgud-xdebug-goto-control-frame-line (pt)
  "Display the location mentioned by a control-frame line
described by PT."
  (interactive "d")
  (realgud-goto-line-for-pt pt "control-frame"))

(defun realgud-xdebug-goto-syntax-error-line (pt)
  "Display the location mentioned in a Syntax error line
described by PT."
  (interactive "d")
  (realgud-goto-line-for-pt pt "syntax-error"))

(define-key xdebug-track-mode-map
  (kbd "C-c !c") 'realgud-xdebug-goto-control-frame-line)
(define-key xdebug-track-mode-map
  (kbd "C-c !s") 'realgud-xdebug-goto-syntax-error-line)

(defun xdebug-track-mode-hook()
  (if xdebug-track-mode
      (progn
	(use-local-map xdebug-track-mode-map)
	(message "using xdebug mode map")
	)
    (message "xdebug track-mode-hook disable called"))
)

(define-minor-mode xdebug-track-mode
  "Minor mode for tracking xdebug debugging inside a process shell."
  :init-value nil
  ;; :lighter " xdebug"   ;; mode-line indicator from realgud-track is sufficient.
  ;; The minor mode bindings.
  :global nil
  :group 'xdebug
  :keymap xdebug-track-mode-map
  (realgud-track-set-debugger "xdebug")
  (if xdebug-track-mode
      (progn
	(realgud-track-mode-setup 't)
	(xdebug-track-mode-hook))
    (progn
      (setq realgud-track-mode nil)
      ))
)

(provide-me "realgud-xdebug-")
