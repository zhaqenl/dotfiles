;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.

;; (require 'package)
;; (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

(package-initialize)

;; (unless (package-installed-p 'sudo-edit)
;;   (package-refresh-contents)
;;   (package-install 'sudo-edit))

;; (require 'sudo-edit)

;; Enable line numbers globally
(global-display-line-numbers-mode t)

(menu-bar-mode -1)

(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/")
(load-theme 'miasma t)

;; Make terminal Emacs transparent (daemon mode)
(add-hook 'after-make-frame-functions
          (lambda (frame)
            (unless (display-graphic-p frame)
              (set-face-background 'default "unspecified-bg" frame))))

;; Python whitespace settings
(add-hook 'python-mode-hook
          (lambda ()
            ;; Use spaces, not tabs (PEP 8)
            (setq indent-tabs-mode nil)
            ;; Clean whitespace on save
            (add-hook 'before-save-hook 'whitespace-cleanup nil t)))

;; XML whitespace settings
(add-hook 'nxml-mode-hook
          (lambda ()
            ;; Clean whitespace on save
            (add-hook 'before-save-hook 'whitespace-cleanup nil t)))
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
