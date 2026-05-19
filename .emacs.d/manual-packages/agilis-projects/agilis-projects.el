;;; agilis-projects.el --- Completion for Agilis Odoo project names -*- lexical-binding: t; -*-

;; Author: Raymund MARTINEZ <zhaqenl@gmail.com>
;; Keywords: completion, odoo

;;; Commentary:

;; Provides a completion-at-point function that completes Agilis Odoo
;; project.project names on lines that begin with "Project: " in
;; markdown buffers.  Names are fetched once per Emacs session via a
;; small Python XML-RPC helper.

;;; Code:

(require 'auth-source)
(require 'subr-x)

(defgroup agilis-projects nil
  "Auto-complete Agilis Odoo project names."
  :group 'completion
  :prefix "agilis-projects-")

(defcustom agilis-projects-helper
  (expand-file-name
   "~/dotfiles/.emacs.d/manual-packages/agilis-projects/agilis-projects.py")
  "Path to the XML-RPC helper script."
  :type 'file)

(defcustom agilis-projects-auth-host "agilis.odoo.com"
  "`:host' value used to look up credentials via `auth-source-search'."
  :type 'string)

(defvar agilis-projects--cache nil
  "Cached list of project names, or nil if not yet fetched.")

(defun agilis-projects--auth ()
  "Return plist with :user :password :database :url from auth-source."
  (let* ((entry (car (auth-source-search :host agilis-projects-auth-host
                                         :max 1)))
         (secret (and entry (plist-get entry :secret)))
         (pw (cond ((functionp secret) (funcall secret))
                   ((stringp secret) secret))))
    (unless entry
      (user-error "agilis-projects: no auth entry for host %s"
                  agilis-projects-auth-host))
    (let ((user (plist-get entry :user))
          (db (plist-get entry :database))
          (url (plist-get entry :url)))
      (unless (and user pw db url)
        (user-error
         "agilis-projects: auth entry missing fields (need login, password, database, url)"))
      (list :user user :password pw :database db :url url))))

(defun agilis-projects--fetch ()
  "Run helper, parse stdout into `agilis-projects--cache'.
Return t on success.  Return nil and message on transient (exit 3)
network failure (cache untouched).  Signal `user-error' on any other
non-zero exit (config / auth / missing env)."
  (unless (file-executable-p agilis-projects-helper)
    (user-error "agilis-projects: helper not executable: %s"
                agilis-projects-helper))
  (let* ((auth (agilis-projects--auth))
         (process-environment
          (append (list (format "ODOO_URL=%s" (plist-get auth :url))
                        (format "ODOO_DB=%s" (plist-get auth :database))
                        (format "ODOO_USER=%s" (plist-get auth :user))
                        (format "ODOO_PW=%s" (plist-get auth :password)))
                  process-environment))
         (stdout-buf (generate-new-buffer " *agilis-projects-out*"))
         (stderr-file (make-temp-file "agilis-projects-err")))
    (unwind-protect
        (let ((exit (call-process agilis-projects-helper
                                  nil
                                  (list stdout-buf stderr-file)
                                  nil)))
          (cond
           ((zerop exit)
            (with-current-buffer stdout-buf
              (let ((lines (split-string (buffer-string) "\n" t "[ \t\r]+")))
                (setq agilis-projects--cache lines)
                t)))
           (t
            (let ((err (with-temp-buffer
                         (insert-file-contents stderr-file)
                         (car (split-string (buffer-string) "\n" t)))))
              (if (= exit 3)
                  (progn
                    (message "agilis-projects: %s"
                             (or err "network error"))
                    nil)
                (user-error "agilis-projects: helper exit %d: %s" exit
                            (or err "no stderr")))))))
      (kill-buffer stdout-buf)
      (delete-file stderr-file))))

;;;###autoload
(defun agilis-projects-refresh ()
  "Clear the cache and refetch project names from Agilis Odoo."
  (interactive)
  (setq agilis-projects--cache nil)
  (if (agilis-projects--fetch)
      (message "agilis-projects: %d cached"
               (length agilis-projects--cache))
    (message "agilis-projects: fetch failed; see *Messages*")))

(defconst agilis-projects--line-prefix-re "^Project: "
  "Regex that must match from beginning of line for capf to fire.")

(defun agilis-projects--capf ()
  "Completion-at-point function for Agilis project names."
  (when (and (derived-mode-p 'markdown-mode)
             (save-excursion
               (beginning-of-line)
               (looking-at agilis-projects--line-prefix-re)))
    (let ((beg (save-excursion
                 (beginning-of-line)
                 (match-end 0)))
          (end (point)))
      (unless agilis-projects--cache
        (agilis-projects--fetch))
      (when agilis-projects--cache
        (list beg end agilis-projects--cache :exclusive 'no)))))

;;;###autoload
(defun agilis-projects-setup ()
  "Install the capf in markdown buffers."
  (add-hook 'markdown-mode-hook
            (lambda ()
              (add-hook 'completion-at-point-functions
                        #'agilis-projects--capf nil t))))

(provide 'agilis-projects)
;;; agilis-projects.el ends here
