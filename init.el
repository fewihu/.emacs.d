(require 'package)
(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/"))
(package-initialize)

;; ================================
;; look

(defun my-confirm-kill-daemon (prompt)
  "Ask whether to kill daemon Emacs with PROMPT.
Intended as a predicate for `confirm-kill-emacs'."
  (or (not (daemonp))
      (yes-or-no-p prompt)))

(setq confirm-kill-emacs #'my-confirm-kill-daemon)

(if (display-graphic-p)
    (progn
      ;;used in window system environment
      (customize-set-variable 'timu-spacegrey-org-intense-colors nil)
      (customize-set-variable 'timu-spacegrey-muted-colors       t)
      (customize-set-variable 'timu-spacegrey-scale-org-level-1  1.3)
      (customize-set-variable 'timu-spacegrey-scale-org-level-2  1.2)
      (customize-set-variable 'timu-spacegrey-scale-org-level-3  1.1)
      (customize-set-variable 'timu-spacegrey-mode-line-border   t)
      (load-theme 'timu-spacegrey t)
      (set-cursor-color       "#a0a0a0")
      (set-fringe-mode        20)
      (add-hook 'org-mode-hook (lambda () (variable-pitch-mode 1)))
      (custom-theme-set-faces 'user
			      '(org-example ((t (:inherit (shadow fixed-pitch)))))
			      '(org-babel ((t (:inherit (shadow fixed-pitch)))))
			      '(org-block ((t (:inherit fixed-pitch))))
			      '(org-code ((t (:inherit (shadow fixed-pitch)))))
			      '(org-indent ((t (:inherit (org-hide fixed-pitch)))))
			      '(org-link ((t (:foreground "royal blue" :underline t))))
			      '(org-meta-line ((t (:inherit (font-lock-comment-face fixed-pitch)))))
			      '(org-property-value ((t (:inherit fixed-pitch))) t)
			      '(org-special-keyword ((t (:inherit (font-lock-comment-face fixed-pitch)))))
			      '(org-table ((t (:inherit fixed-pitch :foreground "#83a598"))))
			      '(org-tag ((t (:inherit (shadow fixed-pitch) :weight bold :height 0.8))))
			      '(org-verbatim ((t (:inherit (shadow fixed-pitch))))))
      (setq org-src-fontify          t
	    org-src-fontify-natively t))
  ;; used in terminal environment
  ;; This is necessary because the Windows Terminal App behaves strange,
  ;; as one could guess from the name WINDOWS Terminal App.
  (load-theme 'tango t)
  (set-cursor-color   "#ffffff")
  (global-display-line-numbers-mode +1)
  (scroll-bar-mode -1))

;; increase SNR
(menu-bar-mode   -1)
(tool-bar-mode   -1)

(setq
 column-number-mode      t
 inhibit-startup-screen  t
 global-visual-line-mode t)


;; To have, or not to have line numbers, that is the question
(dolist (mode '(text-mode-hook
                prog-mode-hook
                conf-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 1))))

(dolist (mode '(org-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))


;; ================================
;; feel

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


;; ================================
;; programming / mark up languages

;; ----------
;; Golang - seen at: https://geeksocket.in/posts/emacs-lsp-go/

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


;; Company mode
(setq company-idle-delay 0)
(setq company-minimum-prefix-length 1)

;; ----------
;; markdown
(require 'markdown-mode)

;; ----------
;; Dockerfile syntax
(require 'dockerfile-mode)

;; ----------
;; xml
(setq nxml-slash-auto-complete-flag t)


;; ================================
;; helpfull things


;; ----------
;; json support
(require 'flymake-json)
(require 'json-mode)
(global-set-key (kbd "C-c j v") 'flymake-json-load)


;; ----------
;; git-commit

(require 'git-commit)
(setq git-commit-style-convention-checks
      '(non-empty-second-line
        overlong-summary-line))

;; seen at https://www.adventuresinwhy.com/post/commit-message-linting/
;; and found extremly helpful

;; Parallels `git-commit-style-convention-checks',
;; allowing the user to specify which checks they
;; wish to enforce.
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
;; flyspell

(when (eq system-type 'gnu/linux)
  (require 'flyspell)
  (add-hook 'text-mode-hook 'flyspell-mode)
  (add-hook 'prog-mode-hook 'flyspell-prog-mode)
  ;; seen at https://tex.stackexchange.com/questions/166681/changing-language-of-flyspell-emacs-with-a-shortcut
  (global-set-key [f3] (lambda () (interactive)
			 (ispell-change-dictionary "deutsch")))
  (global-set-key [f4] (lambda () (interactive)
			 (ispell-change-dictionary "english"))))


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

;; ================================
;; Org-Mode the initial reason to use Emacs


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


;; ----------
;; keywords
(setq org-todo-keywords 
		'((sequence "ISSUE(i)" "QUEST(q)" "INFO(a)")
		  (sequence "TODO(t)"  "CONT(c)" "DONE(d)" )
		  (sequence "IDEA(n)"  "DISM(m)" "WAIT(w)")))

(setq org-todo-keyword-faces
		'(("TODO" :foreground "#ff5733" weigth: bold)
		  ("CONT" :foreground "#ffc300" weigth: bold)
		  ("DONE" :foreground "#daf7a6")
	
		  ("ISSUE" :foreground "#ff5733" weigth: bold italic)
		  ("QUEST" :foreground "#cf2703" :background "#2e7388")
	
		  ("WAIT" :foreground "#ffc300")
	
		  ("IDEA" :foreground "#daf7a6")
		  ("INFO" :foreground "#aac776" :background "#2e7388")
		  
		  ("DISM" :foreground "#ceffff")))

;; ----------
;; org-babel

(org-babel-do-load-languages            
 'org-babel-load-languages '((plantuml . t)))
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
