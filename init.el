; Cask is initialized with the following:
(require 'cask "/usr/local/Cellar/cask/0.7.2/cask.el")
(cask-initialize)

; Pallet
; You can download all packages in your =Cask= file by using =M-x pallet-install=.
; However, this should not be necessary.
(require 'pallet)
(pallet-mode t)


; Start using use-package
(eval-when-compile
  (require 'use-package))
(require 'bind-key)
(require 'diminish)

; Add custom packages directory to the =load-path=.
(let ((default-directory (concat user-emacs-directory "packages/")))
  (normal-top-level-add-subdirs-to-load-path))

; Essentials
; Some quick essentials.

;; paths
(use-package exec-path-from-shell
  :ensure
  :config
  (when (memq window-system '(mac ns))
    (exec-path-from-shell-initialize))
  )

;; default font
(set-frame-font "-*-Source Code Pro-normal-normal-normal-*-13-*-*-*-m-0-iso10646-1")

;; dark theme
(load-theme 'monokai t t)
(load-theme 'solarized-light t t)
(defun dark-theme (&optional leave-pl)
  (interactive)
  (disable-theme (car custom-enabled-themes))
  (enable-theme 'monokai)
  (if leave-pl () (powerline-reset)))

;; light theme
(defun light-theme (&optional leave-pl)
  (interactive)
  (disable-theme (car custom-enabled-themes))
  (enable-theme 'solarized-light)
  (if leave-pl () (powerline-reset)))

;; faces
(custom-theme-set-faces 'monokai
  `(evil-search-highlight-persist-highlight-face ((t :background "blue"))))

; !! evil-mode !!
(use-package evil
  :init
  (progn
    (use-package evil-surround
      :config (global-evil-surround-mode 1))

    (use-package evil-nerd-commenter
      :init (evilnc-default-hotkeys)
      :config
      (progn
        (define-key evil-normal-state-map ";" 'evilnc-comment-operator)
        (define-key evil-visual-state-map ";" 'evilnc-comment-operator)
        ))

    (use-package evil-matchit
      :config (global-evil-matchit-mode 1))

    (use-package evil-extra-operator
      :config (global-evil-extra-operator-mode 1))

    (use-package evil-snipe
      :diminish ""
      :config (evil-snipe-mode 1))

    ;; guide-key
    (use-package guide-key
      :diminish ""
      :config
      (progn (setq guide-key/guide-key-sequence '("C-x" "C-c" "SPC"))
             (setq guide-key/recursive-key-sequence-flag t))
      (guide-key-mode 1))

    (use-package evil-leader
      :init
      (global-evil-leader-mode)
      :config
      (progn
             (evil-leader/set-leader "<SPC>")
             (define-prefix-command 'buffers)
             (define-prefix-command 'files)
             (define-prefix-command 'projects)
             (define-prefix-command 'help)
             (define-prefix-command 'git)
             (define-prefix-command 'tags)
             (define-prefix-command 'settings)
             (define-prefix-command 'errors)
             (evil-leader/set-key
               "b"  'buffers
               "bs" 'helm-buffers-list
               "bb" 'evil-buffer
               "bd" 'evil-delete-buffer

               "f"  'files
               "fs" 'save-buffer
               "fr" 'helm-recentf
               "fd" 'helm-open-dired
               "fo" 'helm-find-files

               "p"  'projects
               "pf" 'projectile-find-file
               "pa" 'projectile-ag
               "ps" 'projectile-switch-project
               "pk" 'projectile-kill-buffers
               "pr" 'projectile-replace
               "pw" 'ag-project-at-point

               "h"  'help
               "hf" 'describe-function
               "hk" 'describe-key
               "hm" 'describe-minor-mode
               "hM" 'describe-mode
               "hb" 'describe-bindings

               "g"  'git
               "gs" 'magit-status
               "gc" 'magit-commit
               "gl" 'magit-log
               "gd" 'magit-diff
               "ga" 'magit-stage-all

               "t"  'tags
               "tt" 'helm-etags-select

               "s"  'settings
               "sf" 'menu-set-font

               "e"  'errors
               "el" 'flycheck-list-errors
               "en" 'flycheck-next-error
               "ep" 'flycheck-previous-error
               "ef" 'flycheck-first-error

               ":"  'helm-M-x
               ";"  'other-window)))

    (use-package evil-search-highlight-persist
      :config
      (progn (global-evil-search-highlight-persist t)
             (evil-leader/set-key "th" 'evil-search-highlight-persist-remove-all)))
    
    (use-package key-chord
      :config (key-chord-define evil-insert-state-map  "kj" 'evil-normal-state)
      (key-chord-mode 1))

    (evil-mode 1))

  :config
  (progn
    ;; esc should always quit: http://stackoverflow.com/a/10166400/61435
    (define-key evil-normal-state-map [escape] 'keyboard-quit)
    (define-key evil-visual-state-map [escape] 'keyboard-quit)
    (define-key minibuffer-local-map [escape] 'abort-recursive-edit)
    (define-key minibuffer-local-ns-map [escape] 'abort-recursive-edit)
    (define-key minibuffer-local-completion-map [escape] 'abort-recursive-edit)
    (define-key minibuffer-local-must-match-map [escape] 'abort-recursive-edit)
    (define-key minibuffer-local-isearch-map [escape] 'abort-recursive-edit)

    (defun my-move-key (keymap-from keymap-to key)
     "Moves key binding from one keymap to another, deleting from the old location. "
     (define-key keymap-to key (lookup-key keymap-from key))
     (define-key keymap-from key nil))
   (my-move-key evil-motion-state-map evil-normal-state-map (kbd "RET"))
   (my-move-key evil-motion-state-map evil-normal-state-map " ")
   ))

;; misc key bindings
(bind-key (kbd "M-ƒ") 'toggle-frame-fullscreen)

;; line numbers
(require 'linum)
(global-linum-mode 1)
(use-package linum-relative
  :init
  (progn
    (defun linum-relative-off ()
      (if (eq linum-format 'linum-relative)
          (setq linum-format linum-relative-user-format)))
    (defun linum-relative-on ()
      (if (eq linum-format linum-relative-user-format)
          (progn (setq linum-relative-user-format linum-format)
                 (setq linum-format 'linum-relative)))))
  :config
  (setq linum-relative-current-symbol ""))
  ;; (progn
  ;;   (add-hook 'evil-insert-state-entry-hook 'linum-relative-off)
  ;;   (add-hook 'evil-visual-state-entry-hook 'linum-relative-on)
  ;;   (add-hook 'evil-normal-state-entry-hook 'linum-relative-on))


;; Turn off mouse interface early in startup to avoid momentary display.
(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))

;; Save hist
(require 'savehist)
(setq savehist-additional-variables    ;; also save...
  '(search-ring regexp-search-ring)    ;; ... my search entries
  savehist-file "~/.emacs.d/savehist") ;; keep my home clean
(savehist-mode t)                      ;; do customization before activate

;; Get meta key working on mac
(set-keyboard-coding-system nil)

;; No splash screen please.
(setq inhibit-startup-message t)

;; No fascists.
(setq initial-scratch-message nil)
(setq initial-major-mode 'emacs-lisp-mode)

;; No alarms.
(setq ring-bell-function 'ignore)

;; When on a tab, make the cursor the tab length.
(setq-default x-stretch-cursor t)

;; Keep emacs Custom-settings in separate file.
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file)

;; Write backup files to own directory
(setq backup-directory-alist
    `(("." . ,(expand-file-name
               (concat user-emacs-directory "backups")))))

;; Make backups of files, even when they're in version control.
(setq vc-make-backup-files t)

;; Save point position between sessions.
(use-package saveplace)
(setq-default save-place t)
(setq save-place-file (expand-file-name "places" user-emacs-directory))

;; Fix empty pasteboard error.
(setq save-interprogram-paste-before-kill nil)

;; Enable some commands.
; (put 'downcase-region 'disabled nil)
; (put 'upcase-region 'disabled nil)
; (put 'narrow-to-region 'disabled nil)
; (put 'erase-buffer 'disabled nil)

;; Full path in frame title
; (when window-system
; (setq frame-title-format '(buffer-file-name "%f" ("%b"))))

;; Auto refresh buffers when edits occur outside emacs
(global-auto-revert-mode 1)

;; Also auto refresh dired, but be quiet about it
; (setq global-auto-revert-non-file-buffers t)
; (setq auto-revert-verbose nil)

;; Show keystrokes in progress
(setq echo-keystrokes 0.1)

;; Move files to trash when deleting
(setq delete-by-moving-to-trash t)

;; Transparently open compressed files
(auto-compression-mode t)

;; Enable syntax highlighting for older Emacsen that have it off
(global-font-lock-mode t)

;; Answering just 'y' or 'n' will do
(defalias 'yes-or-no-p 'y-or-n-p)

;; UTF-8 please
(setq locale-coding-system 'utf-8) ; pretty
(set-terminal-coding-system 'utf-8) ; pretty
(set-keyboard-coding-system 'utf-8) ; pretty
(set-selection-coding-system 'utf-8) ; please
(prefer-coding-system 'utf-8) ; with sugar on top

(show-paren-mode 1)

;; Remove text in active region if inserting text
; (delete-selection-mode 1)

;; Always display line and column numbers
(setq line-number-mode t)
(setq column-number-mode t)

;; Lines should be 80 characters wide, not 72
(setq fill-column 80)
(setq-default fill-column 80)
(setq word-wrap t)

;; Smooth Scroll:
(setq mouse-wheel-scroll-amount '(1 ((shift) .1))) ;; one line at a time

;; Scrol one line when hitting bottom of window
(setq scroll-conservatively 10000)

;; Change Cursor
(setq-default cursor-type 'box)
(blink-cursor-mode -1)

;; Remove alarm (bell) on scroll
(setq ring-bell-function 'ignore)

;; Never insert tabs
(set-default 'indent-tabs-mode nil)

;; Easily navigate sillycased words
(global-subword-mode 1)

;; Word Wrap (t is no wrap, nil is wrap)
(setq-default truncate-lines nil)

;; Add parts of each file's directory to the buffer name if not unique
(use-package uniquify
           :config
           (setq uniquify-buffer-name-style 'forward))

;; eval-expression-print-level needs to be set to nil (turned off) so
;; that you can always see what's happening.
(setq eval-expression-print-level nil)

;; from 'better-defaults.el'
;; Allow clipboard from outside emacs
(setq x-select-enable-clipboard t
    x-select-enable-primary t
    save-interprogram-paste-before-kill t
    apropos-do-all t
    mouse-yank-at-point t)

; (setq custom-theme-directory (concat user-emacs-directory "themes/"))

; ;; last t is for NO-ENABLE
; (load-theme 'base16-eighties-dark-custom t t)
; (load-theme 'base16-solarized-light-custom t t)

; ;; Use the default theme at the shell.
; (defun mb/pick-color-theme (frame)
  ; (select-frame frame)
  ; (if (window-system frame)
    ; (enable-theme 'base16-eighties-dark-custom)
    ; (disable-theme 'base16-eighties-dark-custom)))
; (add-hook 'after-make-frame-functions 'mb/pick-color-theme)

; ;; For when started with emacs or emacs -nw rather than emacs --daemon
; (when window-system
  ; (enable-theme 'base16-eighties-dark-custom))


; (defun toggle-theme-dark-light ()
  ; "Toggles the current theme between 'light' and 'dark' variants."
  ; (interactive)
  ; (if (string= (face-background 'default) "#2d2d2d")
    ; (progn
      ; (disable-theme 'base16-eighties-dark-custom)
      ; (enable-theme 'base16-solarized-light-custom))
    ; (when (string= (face-background 'default) "#fdf6e3")
      ; (progn
        ; (disable-theme 'base16-solarized-light-custom)
        ; (enable-theme 'base16-eighties-dark-custom)))))

;; python mode
(add-hook 'python-mode-hook 'flycheck-mode)
(add-hook 'python-mode-hook 'anaconda-mode)
(add-hook 'python-mode-hook 'eldoc-mode)
(add-hook 'python-mode-hook (lambda ()
                              (evil-local-set-key 'normal "gD" 'anaconda-mode-goto-definitions)
                              (evil-local-set-key 'normal "K" 'anaconda-mode-view-doc)))
(use-package anaconda
  :init
  (use-package company-anaconda
    :config
    (add-to-list 'company-backends 'company-anaconda))
  )

;; (use-package jedi
;;   :init
;;   (defun my/python-mode-hook ()
;;     (add-to-list 'company-backends 'company-jedi))
;;   (use-package company-jedi
;;     :init
;;     (add-hook 'python-mode-hook 'my/python-mode-hook))
;;   :config
;;   (progn ()
;;          (setq jedi:tooltip-method nil)
;;          ;; (setq jedi:complete-on-dot t) 
;;          (add-hook 'python-mode-hook 'jedi:setup)
;;          (add-hook 'python-mode-hook (progn () (bind-key "C-SPC" 'jedi:complete)))
;;          (evil-define-key 'normal 'python-mode "gD" 'jedi:goto-definition)
;;          (evil-define-key 'normal 'python-mode "K" 'jedi:show-doc)
;;          (evil-leader/set-key-for-mode 'python-mode
;;            "mp" 'run-python
;;            "mr" 'python-shell-send-region
;;            "mb" 'python-shell-send-buffer
;;            "mf" 'python-shell-send-file)))

;; powerline
(use-package powerline
  :config
  (powerline-default-theme))

; *** Elpy Mode
; If you don't want to configure anything yourself (or can't decide what you want), [[https://github.com/jorgenschaefer/elpy][Elpy]] combines many helpful packages for working with Python and sets everything up for you.
;; (use-package elpy
;;            :defer 2
;;            :config
;;            (progn
;;              ;; Use Flycheck instead of Flymake
;;              (when (require 'flycheck nil t)
;;                (remove-hook 'elpy-modules 'elpy-module-flymake)
;;                ;; (remove-hook 'elpy-modules 'elpy-module-yasnippet)
;;                (remove-hook 'elpy-mode-hook 'elpy-module-highlight-indentation)
;;                (add-hook 'elpy-mode-hook 'flycheck-mode))
;;              (elpy-enable)
;;              ;; jedi is great
;;              (setq elpy-rpc-backend "jedi")
;;              (add-hook 'python-mode-hook 'elpy-mode)))

; ** Magit
; [[https://github.com/magit/magit][Magit]] is the ultimate =git= interface for Emacs.
(use-package magit
             :defer 2
             :diminish magit-auto-revert-mode
             :init
             (setq magit-last-seen-setup-instructions "1.4.0")
             :config
             (bind-key "q" 'magit-mode-quit-window magit-status-mode-map))

;; yasnippet
(use-package yasnippet
  :init
  (setq yas-snippet-dirs (concat user-emacs-directory "snippets"))
  :config
  (yas-global-mode 1))

;; Git gutter
(use-package git-gutter-fringe+)
(use-package git-gutter+
  :config
  (global-git-gutter+-mode t))

;; Projectile
(use-package projectile
  :config
  (progn (projectile-global-mode)
         (setq projectile-completion-system 'helm)
         (helm-projectile-on)))

;; Helm
(use-package helm-config
  :config
  (helm-mode 1))

; ** Company
; [[http://company-mode.github.io/][Company]] is a text completion framework for Emacs. It stands for "complete anything".
(use-package company
             :diminish ""
             :config
             (progn ()
                    (global-company-mode '(not vhdl-mode))
                    (defun my/company-show-doc-buffer ()
                      "Temporarily show the documentation buffer for the selection."
                      (interactive)
                      (let* ((selected (nth company-selection company-candidates))
                             (doc-buffer (or (company-call-backend 'doc-buffer selected)
                                             (error "No documentation available"))))
                        (with-current-buffer doc-buffer
                          (goto-char (point-min)))
                        (display-buffer doc-buffer t)))
                    (define-key company-active-map (kbd "C-d") #'my/company-show-doc-buffer)  
                    ))

; ** Smartparens
; Show matching and unmatched delimiters and auto-close them as well.
(use-package smartparens
           :diminish ""
           :config
           (progn
             ;; Use the base configuration
             (require 'smartparens-config nil t)
             (smartparens-global-mode t)
             (sp-use-smartparens-bindings)))


; ** Silver Searcher
(use-package ag)

; ** Flyspell
; Enable spell-checking in Emacs.
(use-package flyspell
             :diminish ""
             :init
             (progn
               ;; Enable spell check in program comments
               (add-hook 'prog-mode-hook 'flyspell-prog-mode)
               ;; Enable spell check in plain text / org-mode
               (add-hook 'text-mode-hook 'flyspell-mode)
               (add-hook 'org-mode-hook 'flyspell-mode)
               (add-hook 'latex-mode-hook 'flyspell-mode)
               (setq flyspell-issue-welcome-flag nil)
               (setq flyspell-issue-message-flag nil)

               ;; ignore repeated words
               (setq flyspell-mark-duplications-flag nil)

               (setq-default ispell-program-name "/usr/local/bin/aspell")
               (setq-default ispell-list-command "list"))
             :config ()) 

; ** Flycheck
; [[https://github.com/flycheck/flycheck][Flycheck]] is a great modern syntax checker.
(use-package flycheck
  :diminish ""
  :init
  (progn
    (setq flycheck-indication-mode 'left-fringe)
    ;; disable the annoying doc checker
    (setq-default flycheck-disabled-checkers '(emacs-lisp-checkdoc)))
  :config
  (global-flycheck-mode 1))

; ** Markdown
(use-package markdown-mode
  :config
  (progn
    (autoload 'markdown-mode "markdown-mode"
      "Major mode for editing Markdown files" t)
    (add-to-list 'auto-mode-alist '("\\.text\\'" . markdown-mode))
    (add-to-list 'auto-mode-alist '("\\.markdown\\'" . markdown-mode))
    (add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))))


;; help/doc buffers
;; ----------------

(defun xwl-jump-to-help ()
  "Focus cusor on the help-mode buffer."
  (unless (eq major-mode 'help-mode)
    (other-window 1)))

(defadvice describe-mode (after jump-to-help)
  (xwl-jump-to-help))

(defadvice describe-bindings (after jump-to-help)
  (xwl-jump-to-help))

(defadvice describe-function (after jump-to-help)
  (xwl-jump-to-help))

(defadvice describe-variable (after jump-to-help)
  (xwl-jump-to-help))

(defadvice describe-key (after jump-to-help)
  (xwl-jump-to-help))

(ad-activate 'describe-mode)
(ad-activate 'describe-bindings)
(ad-activate 'describe-function)
(ad-activate 'describe-variable)
(ad-activate 'describe-key)

;; -------- latex -----------
;; Let AucTex use latexmk
(require 'reftex)
(add-hook 'LaTeX-mode-hook 'turn-on-reftex)
(add-hook 'LaTeX-mode-hook 'turn-on-auto-fill)
(add-hook 'LaTeX-mode-hook
          (lambda ()
            (push
             '("Latexmk" "latexmk -pdf -outdir=./build %s" TeX-run-TeX nil t
               :help "Run Latexmk on file")
             TeX-command-list)))
(defvar TeX-command-force "Latexmk")
(add-hook 'LaTeX-mode-hook
          (lambda ()
            (evil-leader/set-key
              "mt" 'reftex-toc
              "mc" 'tex-compile-default
              "mp" 'tex-view
              "mi" 'preview-buffer)))
(add-hook 'LaTeX-mode-hook (lambda ()
                             (disable-theme 'monokai)
                             (load-theme 'solarized-light)))
(add-hook 'LaTeX-mode-hook (lambda()
                             (key-chord-define evil-insert-state-map  "hj" 'LaTeX-insert-item)))

;; tramp
(setq tramp-default-method "sshx")
(setq explicit-shell-file-name "/bin/zsh")
(push "/home/smutch/3rd_party/git/bin" tramp-remote-path)

;; remote client
(defun my/server-start-and-copy-to-g2 ()
  (interactive)
  (setq server-use-tcp t
        server-port    4324)
  (server-start)
  (copy-file "~/.emacs.d/server/server" "/ssh:g2:~/.emacs.d/server/server" t))

;; finally select the theme (once everything has been loaded)
(dark-theme)
