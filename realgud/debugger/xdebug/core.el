;;; Copyright (C) 2010, 2012 Rocky Bernstein <rocky@gnu.org>
(eval-when-compile (require 'cl))

(require 'load-relative)
(require-relative-list '("../../common/track"
                         "../../common/core"
                         "../../common/lang")
                       "realgud-")
(require-relative-list '("init") "realgud-xdebug-")

;; FIXME: I think the following could be generalized and moved to
;; realgud-... probably via a macro.
(defvar xdebug-minibuffer-history nil
  "minibuffer history list for the command `xdebug'.")

(easy-mmode-defmap xdebug-minibuffer-local-map
  '(("\C-i" . comint-dynamic-complete-filename))
  "Keymap for minibuffer prompting of gud startup command."
  :inherit minibuffer-local-map)

;; FIXME: I think this code and the keymaps and history
;; variable chould be generalized, perhaps via a macro.
(defun xdebug-query-cmdline (&optional opt-debugger)
  (realgud-query-cmdline
   'xdebug-suggest-invocation
   xdebug-minibuffer-local-map
   'xdebug-minibuffer-history
   opt-debugger))

(defun xdebug-parse-cmd-args (orig-args)
  "Parse command line ARGS for the annotate level and name of script to debug.

ARGS should contain a tokenized list of the command line to run.

We return the a list containing

- the command processor (e.g. ruby) and it's arguments if any - a
  list of strings

- the name of the debugger given (e.g. trepan) and its arguments
  - a list of strings

- the script name and its arguments - list of strings

- whether the annotate or emacs option was given ('-A',
  '--annotate' or '--emacs) - a boolean

For example for the following input
  (map 'list 'symbol-name
   '(ruby1.9 -W -C /tmp trepan --emacs ./gcd.rb a b))

we might return:
   ((ruby1.9 -W -C) (trepan --emacs) (./gcd.rb a b) 't)

NOTE: the above should have each item listed in quotes.
"

  ;; Parse the following kind of pattern:
  ;;  [ruby ruby-options] trepan trepan-options script-name script-options
  (list '("xdebugclient") '("index.php") nil)
  )

(defvar xdebug-command-name) ; # To silence Warning: reference to free variable
(defun xdebug-suggest-invocation (debugger-name)
  "Suggest a xdebug command invocation via `realgud-suggest-invocaton'"
  (realgud-suggest-invocation xdebug-command-name xdebug-minibuffer-history
                           "php" "\\.php$"))

(defun xdebug-reset ()
  "Xdebug cleanup - remove debugger's internal buffers (frame,
breakpoints, etc.)."
  (interactive)
  ;; (xdebug-breakpoint-remove-all-icons)
  (dolist (buffer (buffer-list))
    (when (string-match "\\*xdebug-[a-z]+\\*" (buffer-name buffer))
      (let ((w (get-buffer-window buffer)))
        (when w
          (delete-window w)))
      (kill-buffer buffer))))

;; (defun xdebug-reset-keymaps()
;;   "This unbinds the special debugger keys of the source buffers."
;;   (interactive)
;;   (setcdr (assq 'xdebug-debugger-support-minor-mode minor-mode-map-alist)
;;        xdebug-debugger-support-minor-mode-map-when-deactive))


(defun xdebug-customize ()
  "Use `customize' to edit the settings of the `xdebug' debugger."
  (interactive)
  (customize-group 'xdebug))

(provide-me "realgud-xdebug-")
