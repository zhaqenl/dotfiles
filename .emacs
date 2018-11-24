;;;; -*- mode: emacs-lisp; coding: utf-8; lexical-binding: t -*-

;;; load CL functions
(require 'cl)

;;; elpa
(require 'package)

(setq package-archives
      '(("gnu" . "http://elpa.gnu.org/packages/")
        ("marmalade" . "http://marmalade-repo.org/packages/")
        ("melpa" . "http://melpa.milkbox.net/packages/")))

(package-initialize)

;;; use-package
(require 'use-package)
(require 'bind-key)

;;; hyperspec
(add-to-list 'load-path "~/.emacs.d/lisp/")

(use-package hyperspec
    :config
  (progn
    (let ((hyperspec-root (expand-file-name "~/.emacs.d/lisp/hyperspec/")))
      (setq common-lisp-hyperspec-root hyperspec-root
            common-lisp-hyperspec-symbol-table (concat hyperspec-root "Data/Map_Sym.txt")))))

(defalias 'clhs 'hyperspec-lookup)

(setq browse-url-browser-function 'browse-url-firefox)

;;; general
(setq user-full-name "Martinez, Raymund M."
      user-mail-address "zhaqenl@gmail.com"
      user-login-name (getenv "USER")

      inhibit-startup-message t
      inhibit-splash-screen t
      scroll-step 1
      scroll-conservatively  101
      next-line-adds-newlines 1
      truncate-lines t
      use-dialog-box nil
      history-length t
      frame-title-format "%b - Emacs"

      enable-recursive-minibuffers nil
      lisp-indent-function 'common-lisp-indent-function

      display-time-day-and-date nil
      display-time-24hr-format t
      display-time-format "%H:%M"

      dired-use-ls-dired nil
      list-directory-brief-switches "-c"
      dired-recursive-deletes 'always

      auto-save-default t

      time-stamp-active t
      time-stamp-line-limit 10
      time-stamp-format "%:b %0d, %Y (%:a)"
      time-stamp-pattern "Last modified: %%"

      vc-follow-symlinks t
      delete-selection-mode 1
      ring-bell-function 'ignore
      grep-command "grep --color -nH -i -e ")

;;; default settings
(setq-default default-major-mode 'text-mode
              indent-tabs-mode nil
              fill-column 100)

;;; constants
(defconst initial-scratch-message nil "")
(defconst initial-major-mode 'text-mode)
(defconst default-major-mode 'text-mode)

;;; modes
(defmacro set-mode (val modes)
  "Loop over VAL and MODES to enable or disable a mode"
  `(progn
     ,@(loop
          for mode in modes
          collect `(when (fboundp ',mode) (,mode ,val)))))

(defun set-modes (modes)
  "Loop over modes to set specific values"
  (loop for (key . val) in modes do
       (funcall key val)))

;;; ui
(set-modes '((menu-bar-mode . -1)
             (tool-bar-mode . -1)
             (blink-cursor-mode . -1)
             (line-number-mode . 1)
             (scroll-bar-mode . -1)
             (column-number-mode . 1)
             (transient-mark-mode . 1)
             (size-indication-mode . 1)))

;;; locale
(set-language-environment "English")
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(setq locale-coding-system 'utf-8)
(prefer-coding-system 'utf-8)

;;; regions
(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)
(put 'narrow-to-region 'disabled nil)

;;; themes
;;(use-package ample-theme
;;    :ensure t
;;    :init (progn (load-theme 'ample-flat t t)
;;                 (enable-theme 'ample-flat))
;;    :defer t)

;;; smartparens
(use-package smartparens-config
    :ensure smartparens
    :config
    (progn
      (show-smartparens-global-mode t)))

(add-hook 'prog-mode-hook 'turn-on-smartparens-strict-mode)
(add-hook 'markdown-mode-hook 'turn-on-smartparens-strict-mode)

;;; linum
(setq linum-format "%4d │ ")

(defun my-linum-mode-hook ()
  "Enable linum mode."
  (linum-mode t))

(add-hook 'find-file-hook 'my-linum-mode-hook)

;;; insert-backticks
(defun insert-backticks (&optional arg)
  "Insert three backticks for code blocks"
  (interactive)
  (insert "``````")
  (backward-char 3))

;;; auto-fill
(defun my-find-file-hook ()
  "Hook for find-file"
  (auto-fill-mode 1))

(add-hook 'find-file-hook 'my-find-file-hook)

;;; go-to-column
(defun go-to-column (column)
  "Move to a column inserting spaces as necessary"
  (interactive "nColumn: ")
  (move-to-column column t))

;;; insert-until-last
(defun insert-until-last (string)
  "Insert string until column"
  (let ((count (save-excursion
                 (previous-line)
                 (end-of-line)
                 (current-column))))
    (dotimes (c count)
      (insert string))))

;;; insert-equals
(defun insert-equals (&optional arg)
  "Insert equals until the same column number as last line"
  (interactive)
  (insert-until-last "="))

;;; insert-hyphens
(defun insert-hyphens (&optional arg)
  "Insert hyphens until the same column number as last line"
  (interactive)
  (insert-until-last "-"))

;;; delete-to-bol
(defun delete-to-bol (&optional arg)
  "Delete to beginning of line"
  (interactive "p")
  (delete-region (point) (save-excursion (beginning-of-line) (point))))

;;; delete-to-eol
(defun delete-to-eol (&optional arg)
  "Delete to end of line"
  (interactive "p")
  (delete-region (point) (save-excursion (end-of-line) (point))))

;;; mark-to-bol
(defun mark-to-bol (&optional arg)
  "Create a region from point to beginning of line"
  (interactive "p")
  (mark-thing 'point 'beginning-of-line))

;;; mark-to-eol
(defun mark-to-eol (&optional arg)
  "Create a region from point to end of line"
  (interactive "p")
  (mark-thing 'point 'end-of-line))

;;; yank-primary
(defun yank-primary (&optional arg)
  "Yank the primary selection"
  (interactive)
  (insert (shell-command-to-string "xclip -selection primary -o")))

;;; yank-clipboard
(defun yank-clipboard (&optional arg)
  "Yank the clipboard selection"
  (interactive)
  (insert (shell-command-to-string "xclip -selection clipboard -o")))

;;; bind-key
(bind-keys
  :map global-map
  ("M-g `" . insert-backticks)
  ("M-g =" . insert-equals)
  ("M-g -" . insert-hyphens)

  ("C-c ^" . delete-to-bol)
  ("C-c $" . delete-to-eol)

  ("C-c ," . mark-to-bol)
  ("C-c ." . mark-to-eol)

  ("C-x y" . yank-clipboard)
  ("C-x C-y" . yank-primary)
  ("M-g SPC" . go-to-column)
)

(bind-keys
  :map smartparens-mode-map
  ("C-M-a" . sp-beginning-of-sexp)
  ("C-M-e" . sp-end-of-sexp)

  ("C-<down>" . sp-down-sexp)
  ("C-<up>"   . sp-up-sexp)
  ("M-<down>" . sp-backward-down-sexp)
  ("M-<up>"   . sp-backward-up-sexp)

  ("C-M-f" . sp-forward-sexp)
  ("C-M-b" . sp-backward-sexp)

  ("C-M-n" . sp-next-sexp)
  ("C-M-p" . sp-previous-sexp)

  ("C-S-f" . sp-forward-symbol)
  ("C-S-b" . sp-backward-symbol)

  ("C-<right>" . sp-forward-slurp-sexp)
  ("M-<right>" . sp-forward-barf-sexp)
  ("C-<left>"  . sp-backward-slurp-sexp)
  ("M-<left>"  . sp-backward-barf-sexp)

  ("C-M-t" . sp-transpose-sexp)
  ("C-M-k" . sp-kill-sexp)
  ("C-k"   . sp-kill-hybrid-sexp)
  ("M-k"   . sp-backward-kill-sexp)
  ("C-M-w" . sp-copy-sexp)
  ("C-M-d" . delete-sexp)

  ("M-<backspace>" . backward-kill-word)
  ("C-<backspace>" . sp-backward-kill-word)
  ([remap sp-backward-kill-word] . backward-kill-word)

  ("M-[" . sp-backward-unwrap-sexp)
  ("M-]" . sp-unwrap-sexp)

  ("C-x C-t" . sp-transpose-hybrid-sexp)

  ("C-c ("  . wrap-with-parens)
  ("C-c ["  . wrap-with-brackets)
  ("C-c {"  . wrap-with-braces)
  ("C-c '"  . wrap-with-single-quotes)
  ("C-c \"" . wrap-with-double-quotes)
  ("C-c _"  . wrap-with-underscores)
  ("C-c `"  . wrap-with-back-quotes))

;;; markdown
(use-package markdown-mode
    :ensure t
    :config
  (progn
    (add-hook 'markdown-mode-hook 'turn-on-smartparens-mode)
    (push '("\\.text\\'" . markdown-mode) auto-mode-alist)
    (push '("\\.markdown\\'" . markdown-mode) auto-mode-alist)
    (push '("\\.md\\'" . markdown-mode) auto-mode-alist)))

;;; slime
(use-package slime
    :ensure t
    :config
    (progn
      (load (expand-file-name "~/quicklisp/slime-helper.el"))

      (add-hook 'lisp-mode-hook 'turn-on-smartparens-mode)
      (add-hook 'slime-repl-mode-hook 'turn-on-smartparens-mode)

      (setq inferior-lisp-program "sbcl"
            slime-contribs '(slime-fancy slime-repl slime-asdf slime-cl-indent)
            slime-protocol-version 'ignore
            slime-documentation-lookup-function 'hyperspec-lookup)))

(defun my-lisp-mode-hook ()
  (setq common-lisp-style 'modern))
(add-hook 'lisp-mode-hook 'my-lisp-mode-hook)

;;; clojure
(use-package cider
  :ensure t
  :config
  (progn
    (push '("\\.clj\\'" . clojure-mode) auto-mode-alist)

    (add-hook 'clojure-mode-hook 'turn-on-smartparens-strict-mode)
    (add-hook 'cider-repl-mode-hook 'turn-on-smartparens-strict-mode)
    (add-hook 'cider-repl-mode-hook 'subword-mode)

    (setq nrepl-log-messages t
          nrepl-hide-special-buffers t
          cider-repl-result-prefix ";; => "
          cider-interactive-eval-result-prefix ";; => "
          cider-repl-use-clojure-font-lock t
          cider-repl-wrap-history t
          cider-repl-history-size 100000
          cider-repl-history-file "~/.cider_history"
          cider-repl-display-help-banner nil)))

;;; char-after
(defun ca ()
  (interactive)
  (call-interactively 'char-after))

;;; geiser
(add-to-list 'load-path "~/.emacs.d/elisp/geiser/elisp/")
(require 'geiser)

(setq geiser-active-implementations '(racket))

(defun geiser-save ()
  (interactive)
  (geiser-repl--write-input-ring))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (php-mode clojure-mode-extra-font-locking cider elpy slime use-package smartparens markdown-mode geiser ample-theme))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
