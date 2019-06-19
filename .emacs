;;;; -*- mode: emacs-lisp; coding: utf-8; lexical-binding: t -*-

;;; load CL functions
(require 'cl)

;;; elpa
(require 'package)

(setq package-archives
      '(("gnu" . "http://elpa.gnu.org/packages/")
        ("marmalade" . "http://marmalade-repo.org/packages/")
        ("melpa" . "http://melpa.milkbox.net/packages/")
        ("melpa-stable" . "https://stable.melpa.org/packages/")))

(package-initialize)

;;; auto-compile
(setq load-prefer-newer t)
(package-initialize)
(require 'auto-compile)
(auto-compile-on-load-mode)
(auto-compile-on-save-mode)

;;; load-path
(let ((default-directory  "~/.emacs.d/plugins/"))
  (normal-top-level-add-subdirs-to-load-path))

;;; yasnippets, popup
(require 'yasnippet)
(require 'popup)
(yas-global-mode 1)

;;; Add key combinations for popup menu
(define-key popup-menu-keymap (kbd "M-n") 'popup-next)
(define-key popup-menu-keymap (kbd "TAB") 'popup-next)
(define-key popup-menu-keymap (kbd "<tab>") 'popup-next)
(define-key popup-menu-keymap (kbd "<backtab>") 'popup-previous)
(define-key popup-menu-keymap (kbd "M-p") 'popup-previous)

(defun yas/popup-isearch-prompt (prompt choices &optional display-fn)
  (when (featurep 'popup)
    (popup-menu*
     (mapcar
      (lambda (choice)
        (popup-make-item
         (or (and display-fn (funcall display-fn choice))
             choice)
         :value choice))
      choices)
     :prompt prompt
     ;; start isearch mode immediately
     :isearch t
     )))

(setq yas/prompt-functions '(yas/popup-isearch-prompt yas/no-prompt))

;;; neotree
(require 'neotree)

;;; elpy, pyenv, jedi
(setq elpy-rpc-backend "jedi")
(elpy-enable)
(pyenv-mode)

;;; python guess indent offset
(setq python-indent-guess-indent-offset t)
(setq python-indent-guess-indent-offset-verbose nil)

;;; whitespace cleanup
(add-hook 'before-save-hook 'whitespace-cleanup)

;;; use-package
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)
(require 'bind-key)

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
              fill-column 80)

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

;;; smartparens
(use-package smartparens-config
    :ensure smartparens
    :config
    (progn
      (show-smartparens-global-mode t)))

(add-hook 'prog-mode-hook 'turn-on-smartparens-strict-mode)
(add-hook 'markdown-mode-hook 'turn-on-smartparens-strict-mode)
(add-hook 'nxml-mode-hook 'turn-off-show-smartparens-mode)

;;; linum
(setq linum-format "%4d │ ")

(defun my-linum-mode-hook ()
  "Enable linum mode."
  (linum-mode t))

(add-hook 'find-file-hook 'my-linum-mode-hook)

;;; Fill with char up to column limit
(defun fill-to-end (char)
  (interactive "cFill Character:")
  (save-excursion
    (end-of-line)
    (while (< (current-column) 80)
      (insert-char char))))

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
(add-hook 'text-mode-hook 'turn-on-auto-fill)

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
 ("M-g i" . yas-insert-snippet)
 ("M-g t" . neotree-toggle)
 ("M-g f" . fill-to-end)
 ("M-g r" . query-replace)

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

;;; char-after
(defun ca ()
  (interactive)
  (call-interactively 'char-after))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (pyenv-mode use-package smartparens markdown-mode ample-theme)))
 '(safe-local-variable-values
   (quote
    ((encoding . utf-8)
     (eval font-lock-add-keywords nil
           (\`
            (((\,
               (concat "("
                       (regexp-opt
                        (quote
                         ("sp-do-move-op" "sp-do-move-cl" "sp-do-put-op" "sp-do-put-cl" "sp-do-del-op" "sp-do-del-cl"))
                        t)
                       "\\_>"))
              1
              (quote font-lock-variable-name-face)))))))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
