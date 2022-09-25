(setq user-full-name "Nicholas Dunham"
      user-mail-address "nmdnhm@gmail.com")

(require 'cl-lib)
(defun nd/concat-path (&rest parts)
  (cl-reduce (lambda (a b) (expand-file-name b a)) parts))

(setq doom-font (font-spec :family "FiraCode Nerd Font" :size 12 :weight 'semi-light)
      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 14)
      doom-unicode-font (font-spec :family "FiraCode Nerd Font" :size 12 :weight 'semi-light))

(setq doom-theme 'doom-nord
      doom-modeline-icon t
      doom-modeline-major-mode-icon t
      doom-modeline-major-mode-color-icon t
      doom-modeline-buffer-state-icon t
      doom-modeline-buffer-modification-icon t
      doom-modeline-enable-word-count t
      doom-modeline-continuous-word-count-modes '(markdown-mode gfm-mode org-mode)
      doom-modeline-buffer-encoding nil
      doom-modeline-checker-simple-format t
      doom-modeline-time nil)

(if (window-system) (set-frame-size (selected-frame) 150 80))

(global-display-line-numbers-mode)
(global-visual-line-mode)

(setq display-line-numbers-type 'visual
      line-move-visual t
      evil-respect-visual-line-mode t)

(add-hook 'vterm-mode-hook 'display-line-numbers-mode)
(add-hook 'term-mode-hook 'display-line-numbers-mode)

(remove-hook 'doom-first-input-hook #'evil-snipe-mode)

(after! org
  (setq org-directory "~/Projects/org/"))

(after! org (setq org-hide-emphasis-markers t
                  org-pretty-entities t
                  org-pretty-entities-include-sub-superscripts t))

(add-hook! org-mode :append #'org-appear-mode)

(use-package! mixed-pitch)
(add-hook! 'org-mode-hook #'mixed-pitch-mode)

(after! org
  (custom-set-faces!
    '(org-block nil :foreground nil :inherit 'fixed-pitch)
    '(org-code nil   :inherit '(shadow fixed-pitch))
    '(org-table nil   :inherit '(shadow fixed-pitch))
    '(org-verbatim nil :inherit '(shadow fixed-pitch))
    '(org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
    '(org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))))

(after! org
  (custom-set-faces!
    '(org-document-title :height 1.5)
    '(org-level-1 :inherit outline-1 :weight extra-bold :height 1.4)
    '(org-level-2 :inherit outline-2 :weight bold :height 1.15)
    '(org-level-3 :inherit outline-3 :weight bold :height 1.12)
    '(org-level-4 :inherit outline-4 :weight bold :height 1.09)
    '(org-level-5 :inherit outline-5 :weight semi-bold :height 1.06)
    '(org-level-6 :inherit outline-6 :weight semi-bold :height 1.03)
    '(org-level-7 :inherit outline-7 :weight semi-bold)
    '(org-level-8 :inherit outline-8 :weight semi-bold)))

(after! org (setq org-log-done-with-time t
                  org-log-into-drawer "LOGBOOK"
                  org-log-refile 'time
                  org-log-repeat 'time
                  org-log-reschedule 'note
                  org-todo-keywords '((sequence "TODO(t)" "NEXT(n!)" "WAIT(w@/!)" "|" "DONE(d!)" "CNCL(c@)"))))

(after! org-fancy-priorities (setq org-fancy-priorities-list '("■" "■" "■")))

(after! org
  (setq org-agenda-files '("inbox.org"
                           "emacs.org"
                           "work.org"
                           "personal.org")
        org-refile-targets '((nil :maxlevel . 3)
                             (org-agenda-files :maxlevel . 3)
                             ("ideas.org" :maxlevel . 3))))

(setq org-agenda-custom-commands
      '(("A" "Daily agenda and top priority tasks"
         ((tags-todo "+PRIORITY=A"
                     ((org-agenda-skip-function '(org-agenda-skip-entry-if 'scheduled 'deadline))
                      (org-agenda-block-separator nil)
                      (org-agenda-overriding-header "Important tasks without a date\n")))
          (todo "WAIT"
                ((org-agenda-block-separator nil)
                 (org-agenda-skip-function '(org-agenda-skip-if nil '(timestamp)))
                 (org-agenda-overriding-header "\nUndated tasks on hold\n")))
          (agenda ""
                 ((org-agenda-block-separator nil)
                  (org-agenda-start-day "+0d")
                  (org-agenda-span 1)
                  (org-deadline-warning-days 0)
                  (org-scheduled-past-days 0)
                  (org-agenda-day-face-function (lambda (date) 'org-agenda-date))
                  (org-agenda-format-date "%A %-e %B %Y")
                  (org-agenda-overriding-header "\nDaily agenda\n")))
          (agenda ""
                  ((org-agenda-start-on-weekday nil)
                   (org-agenda-start-day "+1d")
                   (org-agenda-span 3)
                   (org-deadline-warning-days 0)
                   (org-agenda-block-separator nil)
                   (org-agenda-skip-function '(org-agenda-skip-entry-if 'todo 'done))
                   (org-agenda-overriding-header "\nNext three days\n")))
          (agenda ""
                  ((org-agenda-time-grid nil)
                   (org-agenda-start-on-weekday nil)
                   (org-agenda-start-day "+3d")
                   (org-agenda-span 14)
                   (org-agenda-show-all-dates nil)
                   (org-deadline-warning-days 0)
                   (org-agenda-block-separator nil)
                   (org-agenda-entry-types '(:deadline))
                   (org-agenda-skip-function '(org-agenda-skip-entry-if 'todo 'done))
                   (org-agenda-overriding-header "\nUpcoming deadlines (+14d)\n")))))))

(use-package! org-super-agenda
  :after org-agenda
  :init
  (setq org-agenda-skip-scheduled-if-done t
        org-agenda-skip-deadline-if-done t
        org-agenda-include-deadlines t
        org-agenda-block-separator nil
        org-agenda-compact-blocks nil
        org-agenda-start-day nil ;; i.e. today
        org-agenda-start-on-weekday nil
        org-deadline-warning-days 0
        org-agenda-format-date "%A %e %B %Y")
  (setq org-agenda-custom-commands
        '(("c" "Super view"
           ((agenda "" ((org-agenda-overriding-header "Today\n")
                        (org-agenda-start-day nil)
                        (org-agenda-day-face-function (lambda (date) 'org-agenda-date))
                        (org-agenda-span 1)))
            (agenda "" ((org-agenda-overriding-header "\nNext three days\n")
                        (org-agenda-start-day "+1")
                        (org-agenda-span 3)))
            (agenda "" ((org-agenda-overriding-header "\nUpcoming deadlines\n")
                        (org-agenda-time-grid nil)
                        (org-agenda-start-day "+4")
                        (org-agenda-span 14)
                        (org-agenda-show-all-dates nil)
                        (org-agenda-entry-types '(:deadline))))
            (alltodo "" ((org-agenda-overriding-header "\nUndated tasks\n")
                         (org-super-agenda-groups
                          '((:discard (:deadline t :scheduled t))
                            (:name "\nImportant\n"
                             :priority "A")
                            (:auto-parent t
                             :name "\nActive work projects\n"
                             :and (:category "Work" :tag "Project"))
                            (:name "\nTo refile\n"
                             :category "Inbox")
                            (:name "\nOn hold\n"
                             :todo "WAIT")))))))))
  :init
  (org-super-agenda-mode))

(defun nd/adjust-org-company-backends ()
  (remove-hook 'after-change-major-mode-hook '+company-init-backends-h)
  (setq-local company-backends nil))

(add-hook! org-mode (nd/adjust-org-company-backends))

(after! org-journal
  (setq org-journal-date-prefix "#+TITLE: "
        org-journal-time-prefix "* "
        org-journal-file-format "%Y-%m-%d.org"))

(defun nd/org-journal-find-location ()
  ;; Open today's journal, but specify a non-nil prefix argument in order to
  ;; inhibit inserting the heading; org-capture will insert the heading
  (org-journal-new-entry t)
  (unless (eq org-journal-file-type 'daily)
    (org-narrow-to-subtree))
  (goto-char (point-max)))

(use-package! denote
  :after org
  :config
  (setq denote-directory (nd/concat-path org-directory "notes")
        denote-known-keywords '("work"
                                "french"
                                "ideas"
                                "python"
                                "ml&ai"
                                "clojure"
                                "elisp"
                                "geography")))

(after! org
  (setq org-capture-templates '(("i" "Inbox" entry
                                 (file "inbox.org")
                                 "* TODO %i%?\n:PROPERTIES:\n:CREATED: %U\n:END:\n:LOGBOOK:\n:END:"
                                 :kill-buffer t)
                                ("s" "Shopping")
                                ("sg" "Groceries" checkitem
                                 (file+olp "shopping.org" "Groceries")
                                 "- [ ] %^{Item}"
                                 :immediate-finish t)
                                ("so" "Online" checkitem
                                 (file+olp "shopping.org" "Online shopping")
                                 "- [ ] %^{Item}"
                                 :immediate-finish t)
                                ("sl" "Liquor" checkitem
                                 (file+olp "shopping.org" "Liquor")
                                 "- [ ] %^{Item}"
                                 :immediate-finish t)
                                ("sm" "Miscellaneous" checkitem
                                 (file+olp "shopping.org" "Miscellaneous")
                                 "- [ ] %^{Item}"
                                 :immediate-finish t)
                                ("st" "Later" checkitem
                                 (file+olp "shopping.org" "Later")
                                 "- [ ] %^{Item}"
                                 :immediate-finish t)
                                ("n" "Note with Denote" plain
                                 (file denote-last-path)
                                 #'denote-org-capture
                                 :no-save t
                                 :immediate-finish nil
                                 :kill-buffer t
                                 :jump-to-captured t)
                                ("j" "Journal" plain
                                 (function nd/org-journal-find-location)
                                 "* %(format-time-string org-journal-time-format)%^{Title}\n%i%?"
                                 :jump-to-captured t
                                 :immediate-finish t))))

(use-package! command-log-mode)

(setq nd/command-frame nil)

(defun nd/toggle-command-frame ()
  (interactive)
  (if nd/command-frame
      (progn
        (posframe-delete-frame clm/command-log-buffer)
        (setq nd/command-frame nil))
    (progn
      (global-command-log-mode t)
      (with-current-buffer
          (setq clm/command-log-buffer
                (get-buffer-create " *command-log*"))
        (text-scale-set -1))
      (setq nd/command-frame
            (posframe-show clm/command-log-buffer
             :poshandler 'posframe-poshandler-frame-top-right-corner
             :width 45
             :height 5
             :min-width 45
             :min-height 5
             :internal-border-width 1
             :internal-border-color "#c792ea"
             :override-parameters '((parent-frame . nil)))))))

(map! :leader
      :desc "Command log frame"
      "t o" #'nd/toggle-command-frame)
