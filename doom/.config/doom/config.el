;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; ------------------------------------------------------------
;; User Information
;; ------------------------------------------------------------
;;
;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;;
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; ------------------------------------------------------------
;; Fonts
;; ------------------------------------------------------------
;;
;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face

(setq doom-font (font-spec :family "FiraCode Nerd Font" :size 12 :weight 'semi-light)
      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 14)
      doom-symbol-font (font-spec :family "Fira Code Nerd Font" :size 12 :weight 'semi-light))

;; ------------------------------------------------------------
;; Theme and Modeline
;; ------------------------------------------------------------

(setq doom-theme 'doom-nord
      doom-modeline-icon t                       ; Show icons in the modeline
      doom-modeline-major-mode-icon t            ; Show mode icon (e.g., Org, Clojure)
      doom-modeline-buffer-state-icon t
      doom-modeline-buffer-modification-icon t
      doom-modeline-enable-word-count t          ; Show word count in markdown, org
      doom-modeline-continuous-word-count-modes '(markdown-mode gfm-mode org-mode)
      doom-modeline-buffer-encoding nil          ; Hide encoding (usually UTF-8 anyway)
      doom-modeline-checker-simple-format t      ; Cleaner flycheck/linter output
      doom-modeline-time nil                     ; Hide clock
      doom-modeline-hud t)                       ; Show buffer progress bar

;; ------------------------------------------------------------
;; Line Numbers
;; ------------------------------------------------------------
;;
;; Visual (relative) line numbers for better motion with `j` and `k` in evil mode.

(setq display-line-numbers-type 'visual
      display-line-numbers-width 4
      line-move-visual t
      evil-respect-visual-line-mode t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
;; (setq org-directory "~/org/")

;; ------------------------------------------------------------
;; Parentheses
;; ------------------------------------------------------------

(after! parinfer-rust
  (set-face-attribute 'parinfer-rust-dim-parens nil))

;; ------------------------------------------------------------
;; Frame Size
;; ------------------------------------------------------------
;;
;; Set frame size on startup when using GUI Emacs (Mac app or emacs-plus).

(if (window-system) (set-frame-size (selected-frame) 150 80))

;; ------------------------------------------------------------
;; Evil Mode Tweaks
;; ------------------------------------------------------------
;;
;; Disable `evil-snipe-mode`, which in the default Doom configuration
;; overrides the [s]ubstitute key.

(remove-hook 'doom-first-input-hook #'evil-snipe-mode)

;; ------------------------------------------------------------
;; Package Configuration Notes
;; ------------------------------------------------------------
;;
;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;; ------------------------------------------------------------
;; Clojure / CIDER Enhancements
;; ------------------------------------------------------------

(after! cider
  ;; Make the CIDER REPL pop up on the right in a fixed-size window.
  (set-popup-rules!
    '(("^\\*cider-repl"
       :side right
       :width 80
       :quit nil
       :ttl nil))))

(defun my/clojure-workspace ()
  "Set up a focused Clojure workspace layout:
  - Resize frame
  - Close all windows except the one in focus
  - Toggle Treemacs
  - Launch REPL
  - Return focus to main window"
  (interactive)
  (set-frame-size (selected-frame) 240 80)
  (delete-other-windows)
  (let ((main-window (selected-window)))
    (+treemacs/toggle)
    (cider-jack-in nil)
    (select-window main-window)))

;; Bind the workspace setup function to
;; `<localleader> w` in clojure-mode
(map! :after clojure-mode
      :map clojure-mode-map
      :localleader
      "w" #'my/clojure-workspace)

;; ------------------------------------------------------------
;; Smartparens Keybindings (under leader-k)
;; ------------------------------------------------------------
;;
;; Useful structural editing commands for Lisp languages.
;; I'm working on learning the keystrokes for these, but in the
;; meantime it's handy to have them available in the menu.

(map! :leader
      (:prefix ("k" . "Smartparens")

       ;; Basic motion
       :desc "End of Sexp"        "$"  #'sp-end-of-sexp
       :desc "Start of Sexp"      "^"  #'sp-beginning-of-sexp
       :desc "Symbol Backward"    "h"  #'sp-backward-symbol
       :desc "Sexp Backward"      "H"  #'sp-backward-sexp
       :desc "Symbol Forward"     "l"  #'sp-forward-symbol
       :desc "Sexp Forward"       "L"  #'sp-forward-sexp
       :desc "Up Sexp"            "u"  #'sp-up-sexp
       :desc "Down Sexp"          "d"  #'sp-down-sexp
       :desc "Backward Up Sexp"   "U"  #'sp-backward-up-sexp
       :desc "Backward Down Sexp" "D"  #'sp-backward-down-sexp

       ;; Basic structural editing
       :desc "Absorb"           "a"  #'sp-absorb-sexp
       :desc "Barf forward"     "b"  #'sp-forward-barf-sexp
       :desc "Barf backward"    "B"  #'sp-backward-barf-sexp
       :desc "Convolute"        "c"  #'sp-convolute-sexp
       :desc "Splice"           "e"  #'sp-splice-sexp-killing-forward
       :desc "Splice Backward"  "E"  #'sp-splice-sexp-killing-backward
       :desc "Join"             "j"  #'sp-join-sexp
       :desc "Raise"            "r"  #'sp-raise-sexp
       :desc "Slurp"            "s"  #'sp-forward-slurp-sexp
       :desc "Slurp Backward"   "S"  #'sp-backward-slurp-sexp
       :desc "Transpose"        "t"  #'sp-transpose-sexp
       :desc "Copy sexp"        "y"  #'sp-copy-sexp

       ;; Hybrid editing commands
       (:prefix ("`" . "Hybrid")
        :desc "Kill"      "k"  #'sp-kill-hybrid-sexp
        :desc "Push"      "p"  #'sp-push-hybrid-sexp
        :desc "Slurp"     "s"  #'sp-slurp-hybrid-sexp
        :desc "Transpose" "t"  #'sp-transpose-hybrid-sexp)

       ;; Deletion
       (:prefix ("k" . "Kill")
        :desc "Symbol"          "s"  #'sp-kill-symbol
        :desc "Symbol Backward" "S"  #'sp-backward-kill-symbol
        :desc "Word"            "w"  #'sp-kill-word
        :desc "Word Backward"   "W"  #'sp-backward-kill-word
        :desc "Kill"            "x"  #'sp-kill-sexp
        :desc "Kill Backward"   "X"  #'sp-backward-kill-sexp)

       ;; Wrap and unwrap
       (:prefix ("w" . "Wrap")
        :desc "()"     "("  #'sp-wrap-round
        :desc "{}"     "{"  #'sp-wrap-curly
        :desc "[]"     "["  #'sp-wrap-square
        :desc "Round"  "w"  #'sp-wrap-round
        :desc "Curly"  "c"  #'sp-wrap-curly
        :desc "Square" "s"  #'sp-wrap-square
        :desc "Unwrap" "u"  #'sp-unwrap-sexp)))
