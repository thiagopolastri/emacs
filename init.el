;;; init.el --- Emacs init file -*- lexical-binding: t -*-

;; Author: Thiago Polastri

;; This file is not part of GNU Emacs.

;;; Commentary:

;; I'm too lazy to separate all the modules and too inexpressive
;; to write this as literate org file.

;; Enjoy this long file.

;;; Code:

(require 'dotemacs)
(require 'package)
(require 'recentf)

;; Set package, no-littering, diminish and eglot -------------------------------

(push '("melpa" . "https://melpa.org/packages/") package-archives)
(package-initialize)

(when (not package-archive-contents)
  (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile (require 'use-package))

(use-package no-littering :ensure t)
(add-to-list 'recentf-exclude no-littering-var-directory)
(add-to-list 'recentf-exclude no-littering-etc-directory)

(customize-set-variable
 'auto-save-file-name-transforms
 `((".*" ,(no-littering-expand-var-file-name "auto-save/") t)))

(use-package diminish :ensure t)

(unless (package-installed-p 'eglot) ; if not builtin...
  (message "Installing Eglot...")
  (package-install 'eglot))

;; Defaults --------------------------------------------------------------------

(add-hook 'emacs-startup-hook #'dotemacs:startup-profile-message)
(add-hook 'prog-mode-hook 'dotemacs:prog-mode)
(global-unset-key (kbd "C-z")) ; C-x C-z still `suspend-frame' if needed
(global-set-key (kbd "<f11>") 'dotemacs:toggle-fullscreen)

(setq-default cursor-type 'bar
              indent-tabs-mode nil
              tab-width 4
              word-wrap t
              truncate-lines t
              truncate-partial-width-windows nil
              fill-column 80
              find-file-visit-truename t ; follow symlinks
              vc-follow-symlinks t
              vc-handled-backends '(Git) ; only git, read the docs before change
              kill-buffer-query-functions nil ; kill process when kill a buffer
              revert-without-query t ; revert buffer without asking
              bidi-paragraph-direction 'left-to-right
              bidi-inhibit-bpa t)

(use-package emacs
  :custom
  (use-short-answers t) ; yes-or-no-p becomes y-or-n-p
  (confirm-kill-emacs 'yes-or-no-p)
  (visible-bell 1)
  (use-dialog-box nil) ; use minibuffer instead
  (create-lockfiles nil)
  (require-final-newline t)
  (uniquify-buffer-name-style 'forward)
  (large-file-warning-threshold 100000000) ; 100MB
  (line-move-visual t)
  (mouse-yank-at-point t)
  ;; Hide commands in M-x which do not work in the current mode.
  (read-extended-command-predicate #'command-completion-default-include-p)
  (auto-window-vscroll nil)
  (fast-but-imprecise-scrolling t)
  (scroll-conservatively 101)
  (scroll-margin 0)
  (scroll-preserve-screen-position t)
  (enable-recursive-minibuffers t) ; use the minibuffer whilst in the minibuffer
  (completion-cycle-threshold 1) ; TAB cycles candidates
  (completions-detailed t) ; show annotations
  (tab-always-indent 'complete) ; try to complete, otherwise, indent
  (completion-styles '(basic initials substring))
  (inferior-lisp-program "sbcl")
  :hook (after-save-hook . executable-make-buffer-file-executable-if-script-p)
  :init
  (delete-selection-mode 1)
  (column-number-mode 1)
  (show-paren-mode 1)
  (save-place-mode 1)
  (global-so-long-mode 1)
  (when (fboundp 'pixel-scroll-precision-mode) ; only on emacs 29
    (pixel-scroll-precision-mode 1)))

(use-package autorevert ; revert buffers when changed
  :custom
  (global-auto-revert-non-file-buffers t)
  (auto-revert-interval 3)
  (auto-revert-check-vc-info t)
  :config (global-auto-revert-mode 1))

(use-package savehist ; save command history
  :custom (history-length 25)
  :config (savehist-mode 1))

(use-package dired
  :custom
  (dired-auto-revert-buffer t)
  (dired-dwim-target t)
  (dired-hide-details-hide-symlink-targets nil)
  (dired-recursive-copies 'always)
  (dired-recursive-deletes 'top)
  (dired-listing-switches "-valho --group-directories-first")
  :hook (dired-mode . dired-hide-details-mode)) ; use ( to show details

(use-package eldoc
  :diminish eldoc-mode
  :custom
  ;; Prevent echo area resize and always prefer buffer (C-h .)
  (eldoc-echo-area-use-multiline-p nil)
  (eldoc-echo-area-prefer-doc-buffer t))

(use-package whitespace
  :diminish whitespace-mode
  :custom
  (whitespace-style '(face tabs empty trailing tab-mark indentation::space))
  (whitespace-action '(auto-cleanup)) ; clean on save
  :hook (dotemacs:prog-mode . whitespace-mode))

(use-package display-line-numbers
  :hook (dotemacs:prog-mode . display-line-numbers-mode)
  :bind ("C-z n" . dotemacs:toggle-line-numbers-type))

(use-package hl-line
  :hook ((dotemacs:prog-mode . hl-line-mode)
         (dired-mode . hl-line-mode)))

(use-package fill-column
  :custom (display-fill-column-indicator-character ?\u258F)
  :hook (dotemacs:prog-mode . display-fill-column-indicator-mode))

(use-package visual-line-mode
  :hook (dotemacs:text-mode . visual-line-mode))

(use-package eglot
  :custom (eglot-autoshutdown t)
  :commands (eglot-ensure))

;; Essential -------------------------------------------------------------------

(use-package editorconfig
  :ensure t
  :diminish editorconfig-mode
  :config (editorconfig-mode 1))

(use-package multiple-cursors
  :ensure t
  :bind (("C-S-c C-S-c"   . mc/edit-lines)
         ("C-c C-<"       . mc/mark-all-like-this)
         ("C->"           . mc/mark-next-like-this)
         ("C-<"           . mc/mark-previous-like-this)
         ("C-S-<mouse-1>" . mc/add-cursor-on-click)))

(use-package smartparens
  :ensure t
  :diminish smartparens-mode
  :custom
  (sp-highlight-pair-overlay nil)
  (sp-highlight-wrap-overlay nil)
  (sp-highlight-wrap-tag-overlay nil)
  (sp-max-prefix-length 25)
  (sp-max-pair-length 4)
  :init (smartparens-global-mode))

(use-package which-key
  :ensure t
  :diminish which-key-mode
  :custom
  (which-key-sort-order 'which-key-key-order-alpha)
  (which-key-sort-uppercase-first nil)
  (which-key-add-column-padding 1)
  (which-key-max-display-columns nil)
  (which-key-min-display-lines 6)
  (which-key-side-window-slot -10)
  :init (which-key-mode)
  :config (which-key-setup-side-window-bottom))

(use-package helpful
  :ensure t
  :config
  (define-key helpful-mode-map [remap revert-buffer] #'helpful-update)
  (global-set-key [remap describe-function] #'helpful-callable)
  (global-set-key [remap describe-symbol] #'helpful-symbol)
  (global-set-key [remap describe-variable] #'helpful-variable)
  (global-set-key [remap describe-command] #'helpful-command)
  (global-set-key [remap describe-key] #'helpful-key)
  ;; By default, C-h F is bound to `Info-goto-emacs-command-node'. Helpful
  ;; already links to the manual, if a function is referenced there.
  (global-set-key (kbd "C-h F") #'helpful-function))

(use-package elisp-demos
  :ensure t
  :init (advice-add 'helpful-update :after #'elisp-demos-advice-helpful-update))

;; Completion ------------------------------------------------------------------

(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless))
  (completion-category-overrides '((file (styles . (partial-completion)))))
  (completion-category-defaults nil))

(use-package embark
  :ensure t
  :custom
  (prefix-help-command #'embark-prefix-help-command)
  :bind (("C-."   . embark-act)
         ("C-z ." . embark-dwim) ; alternative to M-.
         ("C-h B" . embark-bindings)
         ("C-z e" . embark-export))
  :config
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

(use-package vertico
  :ensure t
  :custom (vertico-cycle t)
  :init (vertico-mode))

(use-package isearch ; keep isearch bind for keyboard macros
  :bind ("C-z s" . isearch-forward))

(use-package consult
  :ensure t
  :custom
  (completion-in-region-function #'consult-completion-in-region)
  :bind (("C-s"   . consult-line)
         ("C-x b" . consult-buffer)
         ("C-c k" . consult-ripgrep)
         ("C-z m" . consult-minor-mode-menu)
         :map dotemacs:prog-mode-map ("C-z c"  . consult-flymake)
         :map minibuffer-local-map ("C-r" . consult-history)))

(use-package marginalia
  :ensure t
  :custom
  (marginalia-annotators
   '(marginalia-annotators-heavy marginalia-annotators-light nil))
  :init (marginalia-mode))

(use-package embark-consult
  :ensure t
  :hook (embark-collect-mode . consult-preview-at-point-mode))

(use-package corfu
  :ensure t
  :custom
  (corfu-cycle t)
  (corfu-auto t)
  (corfu-quit-no-match 'separator)
  (corfu-popupinfo-delay 0.2) ; popupinfo replaces corfu-doc
  (corfu-preselect-first nil) ; avoid wrong completion with <Enter>
  :init
  (global-corfu-mode)
  (corfu-popupinfo-mode))

(use-package cape
  :ensure t
  :init
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-dabbrev))

;; Sanitize the `pcomplete-completions-at-point' Capf.
;; The Capf has undesired side effects on Emacs 28 and earlier.

;; Wrap a chatty Capf and silence it.
(advice-add 'pcomplete-completions-at-point :around #'cape-wrap-silent)
;; Purify a broken Capf and ensure that it does not modify the buffer.
(advice-add 'pcomplete-completions-at-point :around #'cape-wrap-purify)

(use-package consult-project-extra
  :ensure t
  :bind
  (("C-c p f" . consult-project-extra-find)
   ("C-c p o" . consult-project-extra-find-other-window)))

(use-package consult-eglot :ensure t)

;; Spell/Code Check ------------------------------------------------------------

(use-package flymake
  :hook (dotemacs:prog-mode . flymake-mode))

(use-package ispell
  :if (> (length dotemacs:hunspell-dict-list) 0)
  :custom
  (ispell-program-name "hunspell")
  (ispell-dictionary (car dotemacs:hunspell-dict-list))
  :config
  (dolist (dict dotemacs:hunspell-dict-list)
    (add-to-list
     'ispell-local-dictionary-alist
     `(,dict "[[:alpha:]]" "[^[:alpha:]]" "[']" t ("-d" ,dict) nil utf-8)))
  ;; Don't spellcheck org blocks
  (add-to-list 'ispell-skip-region-alist
               '(":\\(PROPERTIES\\|LOGBOOK\\):" . ":END:"))
  (add-to-list 'ispell-skip-region-alist
               '("#\\+BEGIN_SRC" . "#\\+END_SRC"))
  (add-to-list 'ispell-skip-region-alist
               '("#\\+BEGIN_EXAMPLE" . "#\\+END_EXAMPLE"))
  (ispell-set-spellchecker-params))

(defun dotemacs:consult-hunspell-dict ()
  "Consult interface for dictionary selection."
  (interactive)
  (dotemacs:hunspell-set-local-dict
   (consult--read
    dotemacs:hunspell-dict-list
    :prompt "Change dictionary:"
    :require-match t
    :history t
    :sort nil)))

(use-package flyspell
  :hook (dotemacs:text-mode . flyspell-mode)
  :bind (:map dotemacs:text-mode-map ("C-z c" . flyspell-buffer)
              :map flyspell-mode-map
              ("C-z h" . dotemacs:consult-hunspell-dict)))

(use-package flyspell-correct
  :ensure t
  :after flyspell
  :bind (:map flyspell-mode-map ("C-;" . flyspell-correct-wrapper)))

;; Version Control -------------------------------------------------------------

(use-package magit
  :ensure t
  :custom (magit-diff-refine-hunk t))

(use-package diff-hl
  :ensure t
  :hook (dired-mode . diff-hl-dired-mode-unless-remote)
  :hook (magit-post-refresh . diff-hl-magit-post-refresh)
  :hook (magit-pre-refresh  . diff-hl-magit-pre-refresh)
  :init (global-diff-hl-mode) ; or diff-hl-flydiff-mode
  :config (diff-hl-margin-mode))

(use-package blamer
  :ensure t
  :custom
  (blamer-idle-time 0.3)
  (blamer-min-offset 70)
  :bind ("C-z b" . blamer-mode))

;; Extras ----------------------------------------------------------------------

(use-package expand-region
  :ensure t
  :bind (("C-=" . er/expand-region)))

(use-package drag-stuff
  :ensure t
  :diminish drag-stuff-mode
  :hook (dotemacs:prog-mode . drag-stuff-mode)
  :config (drag-stuff-define-keys))

(use-package avy
  :ensure t
  :bind (("C-:" . 'avy-goto-char)
         ("C-z >" . 'avy-goto-char-2)
         ("C-z l" . 'avy-goto-line)))

(use-package rainbow-mode
  :ensure t
  :diminish rainbow-mode)

(use-package rainbow-delimiters
  :ensure t
  :hook (dotemacs:prog-mode . rainbow-delimiters-mode))

(use-package highlight-numbers
  :ensure t
  :hook (dotemacs:prog-mode . highlight-numbers-mode))

(use-package highlight-indent-guides
  :ensure t
  :diminish highlight-indent-guides-mode
  :custom
  (highlight-indent-guides-method 'character) ; or 'bitmap or 'column
  (highlight-indent-guides-suppress-auto-error t)
  (highlight-indent-guides-auto-odd-face-perc 1.5)
  (highlight-indent-guides-auto-even-face-perc 1.5)
  (highlight-indent-guides-auto-character-face-perc 35)
  :bind (:map dotemacs:prog-mode-map
              ("C-z g" . highlight-indent-guides-mode)))

(use-package visual-fill-column
  :ensure t
  :hook (visual-line-mode . visual-fill-column-mode)
  :custom
  (visual-fill-column-center-text t)
  (visual-fill-column-width 80))

(use-package format-all
  :ensure t
  :bind (:map dotemacs:prog-mode-map
              ("C-c <C-tab>" . format-all-buffer)))

(use-package realgud :ensure t :defer t)

;; Languages -------------------------------------------------------------------

(add-hook 'c-mode-hook #'eglot-ensure)
(add-hook 'c++-mode-hook #'eglot-ensure)
(add-hook 'ruby-mode-hook #'eglot-ensure)
(add-hook 'css-mode-hook #'eglot-ensure)
(add-hook 'js-mode-hook #'eglot-ensure)
(add-hook 'js-json-mode-hook #'eglot-ensure)
(add-hook 'java-mode-hook #'eglot-ensure)
(add-hook 'csharp-mode-hook #'eglot-ensure)
(add-hook 'html-mode-hook #'eglot-ensure)
(add-hook 'mhtml-mode-hook #'eglot-ensure)
(add-hook 'nxml-mode-hook #'eglot-ensure)
(add-hook 'python-mode-hook #'eglot-ensure)

(add-hook 'css-mode-hook 'rainbow-mode)
(add-hook 'scss-mode-hook 'rainbow-mode)
(add-hook 'less-css-mode-hook 'rainbow-mode)
(add-hook 'js-mode-hook 'subword-mode)

(add-hook 'conf-mode-hook 'dotemacs:prog-mode)
(add-hook 'html-mode-hook 'dotemacs:prog-mode)
(add-hook 'mhtml-mode-hook 'dotemacs:prog-mode)
(add-hook 'nxml-mode-hook 'dotemacs:prog-mode)

(use-package go-mode
  :ensure t
  :hook (go-mode . eglot-ensure))

(use-package rustic
  :ensure t
  :custom (rustic-lsp-client 'eglot)
  :init
  (when (and (bound-and-true-p dotemacs:use-treesitter)
             (treesit-available-p))
    (setq rustic-treesitter-derive t)))

(use-package yaml-mode
  :ensure t
  :hook ((yaml-mode . dotemacs:prog-mode)
         (yaml-mode . eglot-ensure)))

(use-package typescript-mode
  :ensure t
  :hook ((typescript-mode . eglot-ensure)
         (typescript-mode . subword-mode)))

(when (and (bound-and-true-p dotemacs:use-treesitter)
           (treesit-available-p))

  (let ((ts-path (dotemacs:get-path "ts-parsers/tree-sitter-module/dist")))
    (when (file-directory-p ts-path)
      (push ts-path treesit-extra-load-path)))

  (push '(c-mode . c-ts-mode) major-mode-remap-alist)
  (push '(c++-mode . c++-ts-mode) major-mode-remap-alist)
  (push '(python-mode . python-ts-mode) major-mode-remap-alist)
  (push '(css-mode . css-ts-mode) major-mode-remap-alist)
  (push '(java-mode . java-ts-mode) major-mode-remap-alist)
  (push '(js-mode . js-ts-mode) major-mode-remap-alist)
  (push '(js-json-mode . json-ts-mode) major-mode-remap-alist)
  (push '(csharp-mode . csharp-ts-mode) major-mode-remap-alist)
  (push '(go-mode . go-ts-mode) major-mode-remap-alist)
  (push '(yaml-mode . yaml-ts-mode) major-mode-remap-alist)

  (add-hook 'c-ts-mode-hook #'eglot-ensure)
  (add-hook 'c++-ts-mode-hook #'eglot-ensure)
  (add-hook 'python-ts-mode-hook #'eglot-ensure)
  (add-hook 'css-ts-mode-hook #'eglot-ensure)
  (add-hook 'js-ts-mode-hook #'eglot-ensure)
  (add-hook 'java-ts-mode-hook #'eglot-ensure)
  (add-hook 'json-ts-mode-hook #'eglot-ensure)
  (add-hook 'csharp-ts-mode-hook #'eglot-ensure)
  (add-hook 'go-ts-mode-hook #'eglot-ensure)
  (add-hook 'yaml-ts-mode-hook #'eglot-ensure)

  (add-hook 'js-ts-mode-hook 'subword-mode)
  (add-hook 'css-ts-mode-hook 'rainbow-mode)
  (add-hook 'yaml-ts-mode-hook 'dotemacs:prog-mode)

  (use-package typescript-ts-mode
    :mode "\\.js\\'"
    :mode "\\.ts\\'"
    :hook ((typescript-ts-mode . eglot-ensure)
           (typescript-ts-mode . subword-mode)))

  (use-package tsx-ts-mode
    :mode "\\.jsx\\'"
    :mode "\\.tsx\\'"
    :hook ((tsx-ts-mode . eglot-ensure)
           (tsx-ts-mode . subword-mode))))

;; Extra languages -------------------------------------------------------------

(use-package racket-mode
  :ensure t
  :hook (racket-mode . eglot-ensure))

(use-package clojure-mode
  :ensure t
  :hook (clojure-mode . eglot-ensure))

(use-package haskell-mode
  :ensure t
  :hook (haskell-mode . eglot-ensure))

(use-package elixir-mode
  :ensure t
  :hook (elixir-mode . eglot-ensure))

(use-package lua-mode
  :ensure t
  :hook (lua-mode . eglot-ensure))

(use-package php-mode
  :ensure t
  :hook (php-mode . eglot-ensure))

(use-package web-mode
  :ensure t
  :mode "\\.[px]?html?\\'"
  :mode "\\.\\(?:tpl\\|blade\\)\\(?:\\.php\\)?\\'"
  :mode "\\.erb\\'"
  :mode "\\.[lh]?eex\\'"
  :mode "\\.sface\\'"
  :mode "\\.jsp\\'"
  :mode "\\.as[cp]x\\'"
  :mode "\\.ejs\\'"
  :mode "\\.hbs\\'"
  :mode "\\.mustache\\'"
  :mode "\\.twig\\'"
  :mode "\\.jinja2?\\'"
  :mode "\\.eco\\'"
  :mode "wp-content/themes/.+/.+\\.php\\'"
  :mode "templates/.+\\.php\\'"
  :custom
  (web-mode-enable-html-entities-fontification t)
  (web-mode-auto-close-style 1)
  (web-mode-enable-auto-quoting nil)
  (web-mode-enable-auto-pairing t))

(define-derived-mode dotemacs:vue-mode web-mode "Web/Vue"
  "Custom Vue major mode derived from `web-mode'.")
(add-to-list 'auto-mode-alist '("\\.vue\\'" . dotemacs:vue-mode))
(add-to-list 'eglot-server-programs '(dotemacs:vue-mode "vls"))
(add-hook 'dotemacs:vue-mode-hook #'eglot-ensure)

(define-derived-mode dotemacs:svelte-mode web-mode "Web/Svelte"
  "Custom Svelte major mode derived from `web-mode'.")
(add-to-list 'auto-mode-alist '("\\.svelte\\'" . dotemacs:svelte-mode))

(use-package sly
  :ensure t
  :custom (sly-symbol-completion-mode nil))

(use-package restclient :ensure t :defer t)

;; Text ------------------------------------------------------------------------

(use-package org
  :commands (org-capture org-agenda)
  :hook ((org-mode . dotemacs:text-mode)
         (org-mode . variable-pitch-mode))
  :custom
  (org-return-follows-link t) ; Follow links when press enter
  (org-edit-src-content-indentation 0) ; Disable the extra indentation on code
  (org-catch-invisible-edits 'show-and-error) ; prevent accidental edits
  (org-ellipsis " ???")
  (org-hide-emphasis-markers t) ; hide markers (`org-appear' will show then)
  (org-auto-align-tags nil)
  (org-tags-column 0)
  (org-pretty-entities t) ; show entities as UTF-8 character
  (org-special-ctrl-a/e t)
  (org-insert-heading-respect-content t)
  ;; dont close a TODO with open subtasks
  (org-enforce-todo-dependencies t)
  (org-enforce-todo-checkbox-dependencies t)
  ;; Images
  (org-startup-with-inline-images t)
  (org-image-actual-width '(300))
  ;; Agenda
  (org-agenda-start-with-log-mode t)
  (org-log-done 'time)
  (org-log-reschedule 'time)
  (org-log-redeadline 'time)
  (org-log-into-drawer t)
  ;; testing stuff
  (org-blank-before-new-entry '((heading . t) (plain-list-item . t)))
  (org-adapt-indentation nil)
  :custom-face
  (org-block ((t (:inherit 'fixed-pitch))))
  (org-block-begin-line ((t (:inherit 'fixed-pitch))))
  (org-block-end-line ((t (:inherit 'fixed-pitch))))
  (org-table ((t (:inherit 'fixed-pitch))))
  (org-formula ((t (:inherit 'fixed-pitch))))
  (org-code ((t (:inherit 'fixed-pitch))))
  (org-verbatim ((t (:inherit 'fixed-pitch))))
  (org-special-keyword ((t (:inherit 'fixed-pitch))))
  (org-meta-line ((t (:inherit 'fixed-pitch))))
  (org-checkbox ((t (:inherit 'fixed-pitch))))
  :config
  (plist-put org-format-latex-options :scale 2))

(use-package org-appear
  :ensure t
  :hook (org-mode . org-appear-mode))

(use-package org-modern
  :ensure t
  :custom
  (org-modern-star ["???" "???" "???" "???" "???" "???" "???" "???"])
  (org-modern-block-fringe nil)
  :hook (org-mode . org-modern-mode))

(when (and (bound-and-true-p dotemacs:roam-dir)
           (file-exists-p dotemacs:roam-dir))
  (use-package org-roam
    :ensure t
    :after org
    :init (setq org-roam-v2-ack t)
    :custom
    (org-roam-directory dotemacs:roam-dir)
    (org-roam-completion-everywhere t)
    (org-roam-completion-system 'default)
    :bind (("C-z r f" . org-roam-node-find)
           ("C-z r i" . org-roam-node-insert)
           ("C-z r c" . org-roam-capture)
           ("C-z r t" . org-roam-buffer-toggle))
    :config (org-roam-setup)))

(use-package markdown-mode
  :ensure t
  :hook ((markdown-mode . dotemacs:text-mode)
         (gfm-mode . dotemacs:text-mode))
  :mode ("/README\\(?:\\.md\\)?\\'" . gfm-mode)
  :custom
  (markdown-command "pandoc") ; or multimarkdown
  (markdown-enable-math t)
  (markdown-enable-wiki-links t)
  (markdown-italic-underscore t)
  (markdown-asymmetric-header t)
  (markdown-fontify-code-blocks-natively t)
  (markdown-gfm-additional-languages '("sh"))
  (markdown-make-gfm-checkboxes-buttons t))

(use-package tex
  :ensure auctex
  :hook ((LaTeX-mode . LaTeX-math-mode)
         (LaTeX-mode . reftex-mode)
         (LaTeX-mode . eglot-ensure))
  :custom
  (TeX-auto-save t)
  (TeX-parse-self t)
  :config (setq-default TeX-master nil))

(use-package pdf-tools :ensure t :defer t)

;; Terminal and sudo opened files-----------------------------------------------

(use-package sudo-edit
  :ensure t
  :bind ("C-z C-s" . sudo-edit))

(use-package vterm
  :ensure t
  :defer t
  :custom (vterm-max-scrollback 100000)) ; C-c C-t enter copy mode

(use-package multi-vterm
  :ensure t
  :bind (("C-z t" . multi-vterm)
         :map vterm-mode-map ("C-n" . multi-vterm)
         :map vterm-mode-map ("C->" . multi-vterm-next)
         :map vterm-mode-map ("C-<" . multi-vterm-prev)))

;; Extra docs ------------------------------------------------------------------

(use-package devdocs ; use devdocs-install to install relevant documentantion
  :ensure t
  :bind ("C-z d" . devdocs-lookup))

(use-package sicp :ensure t)

;; Snippets --------------------------------------------------------------------

(use-package yasnippet
  :ensure t
  :diminish yas-minor-mode
  :init (yas-global-mode))
(use-package yasnippet-snippets :ensure t)

;; -----------------------------------------------------------------------------
;; hacky stuff that I dont want to commit
(when (file-exists-p (dotemacs:get-path "mess.el"))
    (load (dotemacs:get-path "mess.el")))

;; Reset GC value and finish ---------------------------------------------------
(setq gc-cons-threshold 2000000)
;;; init.el ends here
