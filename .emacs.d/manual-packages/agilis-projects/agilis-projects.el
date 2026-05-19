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
   "~/dotfiles/.emacs.d/manual-packages/agilis-projects/agilis-helper.py")
  "Path to the XML-RPC helper script."
  :type 'file)

(defcustom agilis-projects-auth-host "agilis.odoo.com"
  "`:host' value used to look up credentials via `auth-source-search'."
  :type 'string)

(defvar agilis-projects--cache nil
  "Cached alist of (NAME . (ID HAS-HELPDESK-TEAM)) for active projects.
ID is an integer.  HAS-HELPDESK-TEAM is t or nil.  Nil before first fetch.")

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

(defun agilis-projects--run-helper (args)
  "Run helper with ARGS (list of strings).
Return list (EXIT STDOUT STDERR-FIRST-LINE)."
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
         (stdout-buf (generate-new-buffer " *agilis-helper-out*"))
         (stderr-file (make-temp-file "agilis-helper-err")))
    (unwind-protect
        (let ((exit (apply #'call-process
                           agilis-projects-helper
                           nil
                           (list stdout-buf stderr-file)
                           nil
                           args)))
          (list exit
                (with-current-buffer stdout-buf (buffer-string))
                (with-temp-buffer
                  (insert-file-contents stderr-file)
                  (car (split-string (buffer-string) "\n" t)))))
      (kill-buffer stdout-buf)
      (delete-file stderr-file))))

(defun agilis-projects--handle-exit (exit stderr-first what)
  "Convert helper exit code into tri-state result.
Returns t if EXIT is 0.  Returns nil after messaging on exit 3.
Signals `user-error' otherwise.  WHAT is a short string label for messages."
  (cond
   ((zerop exit) t)
   ((= exit 3)
    (message "agilis-%s: %s" what (or stderr-first "network error"))
    nil)
   (t
    (user-error "agilis-%s: helper exit %d: %s" what exit
                (or stderr-first "no stderr")))))

(defun agilis-projects--fetch-projects ()
  "Fetch projects via helper, populate `agilis-projects--cache' alist.
Tri-state return: t on success, nil + message on transient (exit 3),
`user-error' otherwise."
  (pcase-let ((`(,exit ,stdout ,stderr) (agilis-projects--run-helper '("projects"))))
    (when (agilis-projects--handle-exit exit stderr "projects")
      (let (alist)
        (dolist (line (split-string stdout "\n" t "[ \t\r]+"))
          (let ((parts (split-string line "\t")))
            (when (= (length parts) 3)
              (push (cons (nth 0 parts)
                          (list (string-to-number (nth 1 parts))
                                (string= "1" (nth 2 parts))))
                    alist))))
        (setq agilis-projects--cache (nreverse alist))
        t))))

(defvar agilis-tasks--cache nil
  "Hash-table mapping project-id (int) to list of task names.
Nil before first use.  Daemon-lifetime.")

(defun agilis-tasks--cache-ensure ()
  "Create the tasks hash-table on first use."
  (unless agilis-tasks--cache
    (setq agilis-tasks--cache (make-hash-table :test 'eql))))

(defun agilis-projects--fetch-tasks (project-id)
  "Fetch task names for PROJECT-ID via helper, populate hash entry.
Tri-state return like `agilis-projects--fetch-projects'."
  (pcase-let ((`(,exit ,stdout ,stderr)
               (agilis-projects--run-helper
                (list "tasks" (number-to-string project-id)))))
    (when (agilis-projects--handle-exit exit stderr "tasks")
      (agilis-tasks--cache-ensure)
      (puthash project-id
               (split-string stdout "\n" t "[ \t\r]+")
               agilis-tasks--cache)
      t)))

(defun agilis-projects--current-project-id ()
  "Return id of the project named on the closest preceding Project line, or nil."
  (save-excursion
    (when (re-search-backward "^Project: \\(.+\\)$" nil t)
      (let* ((name (string-trim (match-string 1)))
             (entry (assoc name agilis-projects--cache)))
        (and entry (nth 1 entry))))))

;;;###autoload
(defun agilis-projects-refresh ()
  "Clear all agilis caches and refetch project names from Agilis Odoo."
  (interactive)
  (setq agilis-projects--cache nil
        agilis-tasks--cache nil)
  (if (agilis-projects--fetch-projects)
      (message "agilis-projects: %d cached"
               (length agilis-projects--cache))
    (message "agilis-projects: fetch failed; see *Messages*")))

(defconst agilis-projects--line-prefix-re "^Project: "
  "Regex that must match from beginning of line for capf to fire.")

(defun agilis-projects--exit-function (chosen status)
  "Post-insertion hook: emit a Task or Ticket scaffold line.
CHOSEN is the inserted project name; STATUS is the capf finish status."
  (when (eq status 'finished)
    (when-let ((entry (assoc chosen agilis-projects--cache)))
      (insert (if (nth 2 entry) "\n  * Ticket: " "\n  * Task: ")))))

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
        (agilis-projects--fetch-projects))
      (when agilis-projects--cache
        (list beg end
              (mapcar #'car agilis-projects--cache)
              :exclusive 'no
              :exit-function #'agilis-projects--exit-function)))))

(defconst agilis-tasks--line-prefix-re "^  \\* Task: "
  "Regex that must match from beginning of line for the tasks capf to fire.")

(defun agilis-tasks--capf ()
  "Completion-at-point function for project.task names scoped to preceding Project line."
  (when (and (derived-mode-p 'markdown-mode)
             (save-excursion
               (beginning-of-line)
               (looking-at agilis-tasks--line-prefix-re)))
    (let* ((beg (save-excursion
                  (beginning-of-line)
                  (match-end 0)))
           (end (point))
           (pid (agilis-projects--current-project-id)))
      (when pid
        (agilis-tasks--cache-ensure)
        (unless (gethash pid agilis-tasks--cache)
          (agilis-projects--fetch-tasks pid))
        (let ((names (gethash pid agilis-tasks--cache)))
          (when names
            (list beg end names :exclusive 'no)))))))

;;;###autoload
(defun agilis-projects-setup ()
  "Install agilis capfs in markdown buffers."
  (add-hook 'markdown-mode-hook
            (lambda ()
              (add-hook 'completion-at-point-functions
                        #'agilis-projects--capf nil t)
              (add-hook 'completion-at-point-functions
                        #'agilis-tasks--capf nil t))))

(provide 'agilis-projects)
;;; agilis-projects.el ends here
