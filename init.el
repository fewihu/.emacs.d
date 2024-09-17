(require 'package)
(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/"))
(package-initialize)

;; ================================
;; look
(load-theme 'solarized-light t)
(setq solarized-use-less-bold t
      solarized-emphasize-indicators t
      solarized-use-variable-pitch nil)

(set-cursor-color       "#e08020")
(set-fringe-mode        20)
(add-hook 'org-mode-hook (lambda () (variable-pitch-mode 1)))
(custom-theme-set-faces 'user
			'(org-example ((t (:inherit (fixed-pitch)))))
			'(org-babel ((t (:inherit (fixed-pitch)))))
			'(org-block ((t (:inherit fixed-pitch))))
			'(org-code ((t (:inherit (fixed-pitch)))))
			'(org-indent ((t (:inherit (org-hide fixed-pitch)))))
			'(org-link ((t (:foreground "royal blue" :underline t))))
			'(org-meta-line ((t (:inherit (font-lock-comment-face fixed-pitch)))))
			'(org-property-value ((t (:inherit fixed-pitch))) t)
			'(org-special-keyword ((t (:inherit (font-lock-comment-face fixed-pitch)))))
			'(org-table ((t (:inherit fixed-pitch :foreground "#83a598"))))
			'(org-tag ((t (:inherit (fixed-pitch) :weight light :height 0.6))))
			'(org-verbatim ((t (:inherit (fixed-pitch) :foreground "maroon" )))))

;; increase SNR
(menu-bar-mode   -1)
(tool-bar-mode   -1)

(setq
 column-number-mode      t
 inhibit-startup-screen  t
 global-visual-line-mode t)

(customize-set-variable 'org-blank-before-new-entry
			'((heading . t) (plain-list-item . nil)))
(setq org-cycle-separator-lines 1)

(setq org-src-fontify          t
      org-src-fontify-natively t)


;; To have, or not to have line numbers, that is the question
(setq display-line-numbers-type 'relative)
(dolist (mode '(text-mode-hook
                prog-mode-hook
                conf-mode-hook))
  (add-hook mode (lambda ()
		   (display-line-numbers-mode 1)
		   (text-scale-set 2)
		   )))

(dolist (mode '(org-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; highlight indentation where it is helpful
(require 'highlight-indentation)
(set-face-background 'highlight-indentation-face "#e3e3d3")
(set-face-background 'highlight-indentation-current-column-face "#202020")
(setq highlight-indentation-blank-lines t)

(add-hook 'python-mode-hook #'highlight-indentation-mode)
(add-hook 'python-mode-hook #'highlight-indentation-current-column-mode)
(add-hook 'yaml-mode-hook #'highlight-indentation-mode)
(add-hook 'yaml-mode-hook #'highlight-indentation-mode)

(require 'ansi-color)
(defun display-ansi-colors ()
  (interactive)
  (ansi-color-apply-on-region (point-min) (point-max)))

;; highlight todos / mark where it is helpful
(require 'hl-todo)
(setq hl-todo-keyword-faces
      '(("TODO"   . "#FF0000")
        ("MARK"   . "#1E90FF")))
  (add-hook 'prog-mode-hook 'hl-todo-mode)
;; ================================
;; feel

(require 'company)
;; sensefull key-bindings to size windows
;; https://www.emacswiki.org/emacs/WindowResize
(global-set-key (kbd "S-C-<left>") 'shrink-window-horizontally)
(global-set-key (kbd "S-C-<right>") 'enlarge-window-horizontally)
(global-set-key (kbd "S-C-<down>") 'shrink-window)
(global-set-key (kbd "S-C-<up>") 'enlarge-window)

(require 'helm)
(global-set-key (kbd "C-j") 'helm-imenu)

;; switch to previous window (cd - like behaviour)
;; https://emacs.stackexchange.com/questions/43888/move-to-other-window-backwards
(defun fm-previous-window ()
    (interactive)
    (other-window -1))
(global-set-key "\C-xp" 'fm-previous-window)

;; binding for ibuffer
(global-set-key (kbd "C-x C-b") 'ibuffer)

;; change "focus" to new split windows
(global-set-key "\C-x2" (lambda ()
			  (interactive)(split-window-vertically) (other-window 1)))
(global-set-key "\C-x3" (lambda ()
			  (interactive)(split-window-horizontally) (other-window 1)))

;; make it harder to kill the daemon from client by accident
(defun my-confirm-kill-daemon (prompt)
  "Ask whether to kill daemon Emacs with PROMPT.
Intended as a predicate for `confirm-kill-emacs'."
  (or (not (daemonp))
      (yes-or-no-p prompt)))
(setq confirm-kill-emacs #'my-confirm-kill-daemon)

(global-auto-revert-mode t)
(delete-selection-mode   1)

(setq  global-auto-revert-non-file-buffers t)
;; reduce effects of little oopsies
(setq ring-bell-function 'ignore)


;; ----------
;; hightlighting of parens
(setq blink-matching-paren               t
      blink-matching-delay               0.5
      show-paren-when-point-inside-paren t
      show-paren-style                   'parenthesis)

(show-paren-mode    +1)
(electric-pair-mode +1)


;; ----------
;; integrate custom lost and found directory

(defvar laf-dir
  (expand-file-name  "~/laf"))

(defun laf ()
  (interactive)
  "browse lost and found directory"
  (find-file-other-window "~/laf" ))

;; integrate emacs backup / auto save files with custom lost and found dir
(defvar  laf-dir-emacs
  (expand-file-name "~/laf/emacs"))

(setq make-backup-files t
      backup-directory-alist          (list (cons ".*" laf-dir-emacs))
      auto-save-list-file-prefix      laf-dir-emacs
      auto-save-file-name-transforms  `((".*", laf-dir-emacs t))
      delete-old-versions             t)

;; ----------
;; translator
(require 'google-translate)
(require 'google-translate-default-ui)
(defun google-translate--search-tkk ()
  "Search TKK."
  (list 430675 2721866130))
(setq google-translate-backend-method 'curl)

;;  =============================================
;; || programming languages / mark up languages ||
;;  =============================================

;; ================================
;; general settings

;; ----------
;; magit
(require 'magit)
;; ----------
(require 'dash)

(defmacro pretty-magit (WORD ICON PROPS &optional NO-PROMPT?)
  "Replace sanitized WORD with ICON, PROPS and by default add to prompts."
  `(prog1
     (add-to-list 'pretty-magit-alist
                  (list (rx bow (group ,WORD (eval (if ,NO-PROMPT? "" ":"))))
                        ,ICON ',PROPS))
       (add-to-list 'pretty-magit-prompt ,WORD)))

(setq pretty-magit-alist nil)
(setq pretty-magit-prompt nil)

(pretty-magit "Merged" ?⛕ (:foreground "slate gray" :height 1.2))
(pretty-magit "feat:" ?➕ (:foreground "green" :height 1.2))
(pretty-magit "ci:" ?⟳ (:foreground "#375E97" :height 1.2))
(pretty-magit "fix:" ?⛑ (:foreground "#FB6542" :height 1.2))
(pretty-magit "doc:" ?🖉 (:foreground "#3F681C" :height 1.2))
(pretty-magit "chore:" ?🛠 (:foreground "#3F681C" :height 1.2))
(pretty-magit "" ?◯ (:foreground "black" :height 1.2))

(defun add-magit-faces ()
  "Add face properties and compose symbols for buffer from pretty-magit."
  (interactive)
  (with-silent-modifications
    (--each pretty-magit-alist
      (-let (((rgx icon props) it))
        (save-excursion
          (goto-char (point-min))
          (while (search-forward-regexp rgx nil t)
            (compose-region
             (match-beginning 1) (match-end 1) icon)
            (when props
              (add-face-text-property
               (match-beginning 1) (match-end 1) props))))))))

(advice-add 'magit-status :after 'add-magit-faces)
(advice-add 'magit-refresh-buffer :after 'add-magit-faces)

(setq use-magit-commit-prompt-p nil)
(defun use-magit-commit-prompt (&rest args)
  (setq use-magit-commit-prompt-p t))

(defun magit-commit-prompt ()
  "Magit prompt and insert commit header with faces."
  (interactive)
  (when use-magit-commit-prompt-p
    (setq use-magit-commit-prompt-p nil)
    (insert (ivy-read "Commit Type " pretty-magit-prompt
                      :require-match nil :sort t :preselect "Add: "))
    (add-magit-faces)
    ))

(remove-hook 'git-commit-setup-hook 'with-editor-usage-message)
(add-hook 'git-commit-setup-hook 'magit-commit-prompt)
(advice-add 'magit-commit :after 'use-magit-commit-prompt)

(setq git-commit-style-convention-checks
      '(non-empty-second-line
        overlong-summary-line))

;;seen at https://www.adventuresinwhy.com/post/commit-message-linting/
;;and found extremly helpful

;;Parallels `git-commit-style-convention-checks',
;;allowing the user to specify which checks they
;;wish to enforce.
(defcustom my-git-commit-style-convention-checks '(summary-starts-with-capital
                                                   summary-does-not-end-with-period
                                                   summary-uses-imperative)
  "List of checks performed by `my-git-commit-check-style-conventions'.
Valid members are `summary-starts-with-capital',
`summary-does-not-end-with-period', and
`summary-uses-imperative'. That function is a member of
`git-commit-finish-query-functions'."
  :options '(summary-starts-with-capital
             summary-does-not-end-with-period
             summary-uses-imperative)
  :type '(list :convert-widget custom-hood-convert-widget)
  :group 'git-commit)

;; Parallels `git-commit-check-style-conventions'
(defun my-git-commit-check-style-conventions (force)
  "Check for violations of certain basic style conventions.

For each violation ask the user if she wants to proceed anway.
Option `my-git-commit-check-style-conventions' controls which
conventions are checked."
  (save-excursion
    (goto-char (point-min))
    (re-search-forward (git-commit-summary-regexp) nil t)
    (let ((summary (match-string 1))
          (first-word))
      (and (or (not (memq 'summary-starts-with-capital
                          my-git-commit-style-convention-checks))
               (let ((case-fold-search nil))
                 (string-match-p "^[[:upper:]]" summary))
               (y-or-n-p "Summary line does not start with capital letter.  Commit anyway? "))
           (or (not (memq 'summary-does-not-end-with-period
                          my-git-commit-style-convention-checks))
               (not (string-match-p "[\\.!\\?;,:]$" summary))
               (y-or-n-p "Summary line ends with punctuation.  Commit anyway? "))
           (or (not (memq 'summary-uses-imperative
                          my-git-commit-style-convention-checks))
               (progn
                 (string-match "^\\([[:alpha:]]*\\)" summary)
                 (setq first-word (downcase (match-string 1 summary)))
                 (car (member first-word (get-imperative-verbs))))
               (when (y-or-n-p "Summary line should use imperative.  Does it? ")
                 (when (y-or-n-p (format "Add `%s' to list of imperative verbs?" first-word))
                   (with-temp-buffer
                     (insert first-word)
                     (insert "\n")
                     (write-region (point-min) (point-max) imperative-verb-file t)))
                 t))))))

(setq imperative-verb-file "~/.emacs.d/imperative_verbs.txt")
(defun get-imperative-verbs ()
  "Return a list of imperative verbs."
  (let ((file-path imperative-verb-file))
    (with-temp-buffer
      (insert-file-contents file-path)
      (split-string (buffer-string) "\n" t)
      )))

(add-to-list 'git-commit-finish-query-functions
               #'my-git-commit-check-style-conventions)


;; ----------
;; lets give projectile a try
(require 'projectile)
(projectile-mode +1)
(define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
(setq projectile-project-search-path '("~/repos" "~/stackit/repos" "~/util-repos" "~/bf" "~/.config"))
(setq projecttile-generic-command "ripgrep")
(require 'counsel-projectile)
(counsel-projectile-mode 1)

;; ----------
;; lsp-mode
(require 'lsp-mode)
(define-key lsp-mode-map (kbd "M-SPC") lsp-command-map)

(require 'lsp-treemacs)
;; ----------
;; Company mode
(require 'company)
(setq company-idle-delay 0)
(setq company-minimum-prefix-length 1)

;; ----------
;; flycheck popup
(require 'flycheck-popup-tip)
(add-hook 'flycheck-mode-hook 'flycheck-popup-tip-mode)

;; ================================
;; Python
;; crazy simple
(add-hook 'python-mode-hook #'lsp)

;; ================================
;; shell
(add-hook 'sh-mode-hook 'flycheck-mode)


;; ================================
;; Golang
;; seen at: https://geeksocket.in/posts/emacs-lsp-go/
(setenv "PATH" (concat (getenv "PATH") ":/usr/local/go/bin"))
(add-to-list 'exec-path "/home/felixmueller/go/bin")
(add-to-list 'exec-path "/usr/local/go/bin")
(require 'go-mode)


;; Go - lsp-mode
;; Set up before-save hooks to format buffer and add/delete imports.
(defun lsp-go-install-save-hooks ()
  (add-hook 'before-save-hook #'lsp-format-buffer t t)
  (add-hook 'before-save-hook #'lsp-organize-imports t t))
(add-hook 'go-mode-hook #'lsp-go-install-save-hooks)

;; Start LSP Mode and YASnippet mode
(add-hook 'go-mode-hook #'lsp-deferred)
(add-hook 'go-mode-hook #'yas-minor-mode) ;; is this necessary? yasnippet is active anyways

;; add golangci-lint
(require 'flycheck-golangci-lint)
(eval-after-load 'flycheck
  '(add-hook 'flycheck-mode-hook #'flycheck-golangci-lint-setup))

;; add revive flycheck
(flycheck-define-checker go-revive
  "A golang code style checker using the revive."
  :command ("/home/felixmueller/go/bin/revive"  source)
  :error-patterns
  ((warning line-start (file-name) ":"line ":" (message) line-end))
  :modes go-mode
  )
(add-to-list 'flycheck-checkers 'go-revive)

;; inject revive flychecker before the default lsp checker
;; seen at https://github.com/flycheck/flycheck/issues/1762#issuecomment-750458442
(defvar-local my/flycheck-local-cache nil)

(defun my/flycheck-checker-get (fn checker property)
  (or (alist-get property (alist-get checker my/flycheck-local-cache))
      (funcall fn checker property)))

(advice-add 'flycheck-checker-get :around 'my/flycheck-checker-get)
(add-hook 'lsp-managed-mode-hook
	  (lambda ()
	    (when (derived-mode-p 'go-mode)
	      (setq my/flycheck-local-cache '((lsp . ((next-checkers . (warning go-revive)))))))))

;; ================================
;; others

;; ----------
;; convert unix timestamp to rfc3339 timestamp
;; https://gist.github.com/digizeph/11a35d7cc29c89b8a2eb65b77ada70b3
(defun unix-ts-to-str (&optional time zone)
  "Convert unix timestamp integer to human-readable string in RFC3339 format."
  (interactive "nTimestamp: ")
  (setq zone (or zone "UTC"))
  (setq ts-str (format "%s" (or time (current-word))))
  (if (numberp (read ts-str))
      (progn
        (setq ts-int (string-to-number ts-str))
        ;; send message to Message buffer
        ;; copy to kill-ring (clipboard)
        (setq rfc_str (format-time-string "%Y-%m-%dT%H:%M:%S%z" ts-int zone))
        (message (format "%d %s ==> %s" ts-int zone rfc_str))
        (kill-new rfc_str)
        )
    (message "not a number")
    )
  )
(define-key global-map "\M-u" 'unix-ts-to-str)

;; ----------
;; markdown
(require 'markdown-mode)

;; ----------
;; Dockerfile syntax
(require 'dockerfile-mode)
(add-to-list 'load-path "~/.emacs.d/flymake-hadolint/")
(require 'flymake-hadolint)
(add-hook 'dockerfile-mode-hook #'flymake-hadolint-setup)

;; ----------
;; xml
(setq nxml-slash-auto-complete-flag t)

;; ----------
;; yaml-mode
(require 'yaml-mode)
(add-hook 'yaml-mode-hook
          (lambda ()
            (define-key yaml-mode-map "\C-m" 'newline-and-indent)))

;; ----------
;; flymake k8s manifests

(require 'flycheck)
(setq fm-kc-wrapper (expand-file-name "~/.emacs.d/lib/kc-wrapper"))
(flycheck-define-checker k8s
  "A k8s manifest syntax checker using kubeconform"
  :command ("~/.emacs.d/lib/kc-wrapper")
  :standard-input t
  :error-patterns (
                  (error line-start "line: " line " stdin - " (message) line-end)
                  (error line-start "stdin - failed validation: error unmarshalling
resource: error converting YAML to JSON: yaml: line " line ": " (message) line-end))
  :modes yaml-mode)
(add-to-list 'flycheck-checkers 'k8s)

;; k8s company yasnippet
(add-hook 'yaml-mode-hook
          '(lambda ()
             (set (make-local-variable 'company-backends)
                  '(company-yasnippet))))

(defun fm-k8s-mode()
  (interactive)
  (set (make-local-variable 'company-backends)
       '(company-yasnippet))
  (company-mode)
  (flycheck-mode ))

;; ----------
;; systemd
(require 'systemd)

;; ----------
;; json
(require 'flymake-json)
(require 'json-mode)
(global-set-key (kbd "C-c j v") 'flymake-json-load)

;;  ========================
;; || other helpfull modes ||
;;  ========================

;; ----------
;; pass
(add-to-list 'load-path "~/.emacs.d/pass/")
(require 'pass)

;; ----------
;; rfc mode
(require 'rfc-mode)
(setq rfc-mode-directory (expand-file-name "~/.rfc/"))

;; ----------
;; flyspell
(require 'flyspell)
(setq ispell-dictionary "english")
(add-hook 'text-mode-hook 'flyspell-mode)
(add-hook 'prog-mode-hook 'flyspell-prog-mode)
;; seen at https://tex.stackexchange.com/questions/166681/changing-language-of-flyspell-emacs-with-a-shortcut
(global-set-key [f3] (lambda () (interactive)
		       (ispell-change-dictionary "deutsch")))
(global-set-key [f4] (lambda () (interactive)
		       (ispell-change-dictionary "english")))

;; ----------
;; which key 
(require 'which-key)
(which-key-mode)

;; ----------
;; super-save seen at system crafters
(require 'super-save)
(super-save-mode +1)
(setq super-save-auto-save-when-idle t)

;; ----------
;; yasnippet
(require 'yasnippet)
(yas-global-mode 1)

;; ----------
;; let eww open links
(defun my-set-eww-buffer-title ()
  (let* ((title  (plist-get eww-data :title))
         (url    (plist-get eww-data :url))
         (result (concat "*eww-" (or title
                              (if (string-match "://" url)
                                  (substring url (match-beginning 0))
                                url)) "*")))
    (rename-buffer result t)))

(add-hook 'eww-after-render-hook 'my-set-eww-buffer-title)

;; ================================
;; Org-Mode the initial reason to use Emacs

(global-set-key (kbd "C-x C-a") 'org-agenda)
(setq org-agenda-custom-commands
      '(("w" "Weekly review"
	 ((agenda ""
		  ((org-agenda-span 32)
		   (org-agenda-start-day "-1m")
		   (org-agenda-start-with-log-mode '(closed clock state))
		   (org-agenda-start-with-clock-check-mode)
		   (org-agenda-show-log t)))))))
		   ;; (org-agenda-start-with-log-mode t)
		   ;; (org-agenda-log-mode-items '(clock))))))))

(defun fm-timesheet()
    (interactive)
    (org-agenda nil "w"))

;; individually size every image via attr
(setq org-image-actual-width nil)

;;
(require 'cl-lib)
(require 'org-clock)
(defun org-dblock-write:work-report (params)
  "Calculate how many hours too many or too few I have worked. PARAMS are
defined in the template, they are :tstart for the first day for which there's
data (e.g. <2022-01-01>) and :tend for the last date (e.g. <now>)."
  ;; cl-flet is a macro from the common lisp emulation package that allows us to
  ;; bind functions, just like let allows us to do with values.
  (cl-flet*
      ((format-time (time) (format-time-string
                            (org-time-stamp-format tm tm) time))
       (get-minutes-from-log (t1 t2) (cl-second
				      (org-clock-get-table-data
				       (buffer-file-name)
				       (list :maxlevel 0
					     :tstart (format-time t1)
					     :tend (format-time t2))))))
    (let* ((start
            (seconds-to-time (org-matcher-time (plist-get params :tstart))))
           (end
            (seconds-to-time (org-matcher-time (plist-get params :tend))))
           (tm start)
           (total-days-worked 0))
      (progn
        ;; loop through all the days in the time frame provided and count how
        ;; many days minutes were reported.
        (while (time-less-p tm end)
          (let* ((next-day (time-add tm (date-to-time "1970-01-02T00:00Z")))
                 (minutes-in-day (get-minutes-from-log tm next-day)))
            (if (> minutes-in-day 0) (cl-incf total-days-worked 1))
            (setq tm next-day)))
        ;; now we can just do some simple arithmetic to get the difference
        ;; between hours ideally worked and hours actually worked.
        (let* ((total-minutes-worked (get-minutes-from-log start end))
               (hours-worked (/ total-minutes-worked 60.0))
               (hours-per-workday 8)
               (hours-should-work (* total-days-worked hours-per-workday))
               (hour-difference (- hours-worked hours-should-work)))
          (insert (format "%0.1f" hour-difference)))))))
;;


(require 'org-bullets)
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))

(setq org-bullets-bullet-list '("●" "◉" "○" "▸" "▹"))

;; ----------
;; basic settings
(setq org-ellipsis              "⤵"
      org-hide-leading-stars    t
      org-hide-emphasis-markers 1    
      org-startup-folded        t
      org-startup-truncated     nil
      org-fontify-done-headline t
      org-pretty-entities       t ;; not sure
      org-edit-src-content-indentation 0
      org-src-preserve-indentation t)

;; clock and pomodoro
(require 'org-pomodoro)
(setq org-pomodoro-clock-break t) ;; also clock in pomodorro breaks, because I use them actively
(setq org-clock-continuously t
      org-duration-format (quote h:mm)
      org-log-note-clock-out t)

;; ----------
;; keywords
(setq org-todo-keywords 
		'((sequence "ISSUE(i)" "QUEST(q)" "INFO(a)")
		  (sequence "TODO(t)"  "CONT(c)" "DONE(d)" )
		  (sequence "IDEA(n)"  "DISM(m)" "WAIT(w)")))

(setq org-todo-keyword-faces
		'(("TODO"  :foreground "#ff5733" :background "#003060")
		  ("CONT"  :foreground "#ffc300" :background "#003060")
		  ("WAIT"  :foreground "#ffc300" :background "#003060")
		  ("DONE"  :foreground "#daf7a6" :background "#003060")
		  ("DISM"  :foreground "#ceffff" :background "#003060")
		  
		  ("ISSUE" :foreground "#ff7033" :background "#401020")
		  ("QUEST" :foreground "#ff7033" :background "#401020")
		  ("IDEA"  :foreground "#daf7a6" :background "#401020")
		  ("INFO"  :foreground "#aac776" :background "#401020")))


;; ----------
;; org-babel
(add-to-list 'load-path "~/.emacs.d/ob-go/")
(require 'ob-go)
(org-babel-do-load-languages
 'org-babel-load-languages '((plantuml . t) (awk . t) (shell . t) (python . t) (go . t)))
;;
(add-to-list 'org-src-lang-modes '("xml" . nxml-mode))

;; Don't ask for confirmation to execute snippet code
;; Can we do that just for plantuml? Could be deadly else
(setq org-confirm-babel-evaluate nil
		plantuml-default-exec-mode 'jar
		plantuml-output-type       'png
		org-plantuml-jar-path
		(expand-file-name "~/.emacs.d/libs/plantuml-1.2023.9.jar" ))





(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages '(company-go lsp-ui lsp-mode)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
