;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

(package-initialize)

;; Unobtrusively remove trailing whitespace (only on edited lines)
(use-package ws-butler
  :ensure t
  :hook (prog-mode . ws-butler-mode))

(setq treesit-language-source-alist
      '((python "https://github.com/tree-sitter/tree-sitter-python" "v0.20.4")))

;; Enable line numbers globally
(global-display-line-numbers-mode t)

;; Auto-wrap lines in text and Markdown files
(add-hook 'text-mode-hook 'auto-fill-mode)
(use-package markdown-mode
  :ensure t
  :hook (markdown-mode . auto-fill-mode))

(menu-bar-mode -1)

;; Raymund: I added the following, since when an emacsclient was ran
;; on a symbolically-linked file, it does not retain being opened when
;; “tmux-resurrected”
;; Automatically follow symbolic links when visiting files
(setq find-file-visit-truename t)

(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/")
(load-theme 'miasma t)

;; Make terminal Emacs transparent (daemon mode)
(add-hook 'after-make-frame-functions
          (lambda (frame)
            (unless (display-graphic-p frame)
              (set-face-background 'default "unspecified-bg" frame))))

;; (add-to-list 'auto-mode-alist '("\\.py\\'" . python-ts-mode))
;; (with-eval-after-load 'eglot
;;   (add-to-list 'eglot-server-programs '(python-ts-mode . ("basedpyright-langserver" "--stdio"))))
;; (add-hook 'python-ts-mode-hook 'eglot-ensure)
;; (add-hook 'python-ts-mode-hook
;;           (lambda ()
;;             (setq indent-tabs-mode nil)
;;             (add-hook 'before-save-hook 'whitespace-cleanup nil t)))

;; Python settings: use spaces, not tabs (PEP 8)
(add-hook 'python-mode-hook
          (lambda ()
            (setq indent-tabs-mode nil)))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages '(sudo-edit)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
