
(setq user-full-name "Daniel Clark")
(setq user-mail-address "daniel@qcode.co.uk")

;; Fix ansi-error for version > 22.2.1
(defadvice ansi-color-apply-on-region (around
				       powershell-throttle-ansi-colorizing
				       (begin end)
				       activate compile)
  (progn
    (let ((start-pos (marker-position begin)))
      (cond
       (start-pos
	(progn
	  ad-do-it))))))

;; Menu bar visible?
(menu-bar-mode 1)

;; Tool bar visible?
(tool-bar-mode 1)

;; Scroll bars visible?
(scroll-bar-mode -1)

;; Enable line numbers
;;(global-linum-mode 1)

;; Offset the number to work around some weird fringe glitch
;;(setq linum-format "%d  ")

;; Inhibit start-up screen?
(setq inhibit-startup-screen 1)
(setq inhibit-startup-message t
      inhibit-startup-echo-area-message t)

;; Inhibit Splash screen?
(setq inhibit-splash-screen 1)

;; Show Initial scratch message?
(setq initial-scratch-message "")

;; Auto-reload buffers when they change
(global-auto-revert-mode 1)

;; Highlights current line
;;(global-hl-line-mode 1)

;; Disable line-wrap
;;(set-default 'truncate-lines t)

;; Allow line wrap in split screen mode
(setq truncate-partial-width-windows nil)

;; Switch on match bracket
(show-paren-mode)

;; Auto-closing parenthesis
;;(electric-pair-mode 1)

;; Auto-indent current and new lines
;;(electric-indent-mode 1)

;; Delete trailing white space on save
;;(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; Disable all version control
(setq vc-handled-backends nil)

(defconst emacs-tmp-dir (format "%s%s/" user-emacs-directory "tmp"))
;; puts backup files into temp directory rather than cluttering up file tree
(setq backup-directory-alist `(("." . , emacs-tmp-dir)))

;; stop emacs creating backup files
;;(setq make-backup-files nil)

;; puts auto save files into temp directory rather than cluttering up file tree
(setq auto-save-file-name-transforms `((".*", emacs-tmp-dir t)))
(setq auto-save-list-file-prefix emacs-tmp-dir)

;; stop emacs creating auto save files
;;(setq auto-save-default nil)

;;(require 'autopair)

;;(require 'auto-complete-config)
;;(add-to-list 'ac-dictionary-directories "/home/daniel/.emacs.d/ac-dict")
;;(ac-config-default)
;;(ac-flyspell-workaround)
;;(add-to-list 'ac-modes 'tcl-mode)
;;(add-to-list 'ac-modes 'lisp-mode)
;;(add-to-list 'ac-modes 'text-mode)
;;(add-to-list 'ac-modes 'html-mode)
;;(add-to-list 'ac-modes 'javascript-mode)
;;(add-to-list 'ac-modes 'css-mode)

;;(setq ac-auto-show-menu 0.01)
;;(setq ac-delay 0.01)

;; Open files ending in  .test  in tcl-mode
(add-to-list 'auto-mode-alist '("\\.test\\'". tcl-mode))

;; initial mode
(setq initial-major-mode (quote text-mode))

(defun toggle-comment-region ()
  "Comments or uncomments the region or the current line if there's no active region."
  (interactive)
  (let (beg end)
    (if (region-active-p)
        (setq beg (region-beginning) end (region-end))
      (setq beg (line-beginning-position) end (line-end-position)))
    (comment-or-uncomment-region beg end)))

(setq swapping-buffer nil)
(setq swapping-window nil)

(defun comment-toggle (&optional arg)
  "Replacement for the comment-dwim command.
        If no region is selected and current line is not blank and we are not at the end of the line,
        then comment current line.
        Replaces default behaviour of comment-dwim, when it inserts comment at the end of the line."
  (interactive "*P")
  (comment-normalize-vars)
  (if (and (not (region-active-p)) (not (looking-at "[ \t]*$")))
      (comment-or-uncomment-region (line-beginning-position) (line-end-position))
    (comment-dwim arg)))

(defun smart-beginning-of-line ()
  ;;  "Move point to first non-whitespace character or beginning-of-line.
  ;;Move point to the first non-whitespace character on this line.
  ;;If point was already at that position, move point to beginning of line."
  (interactive)
  (let ((oldpos (point)))
    (back-to-indentation)
    (and (= oldpos (point))
         (beginning-of-line))))

(defun rename-current-buffer-file ()
  "Renames current buffer and file it is visiting."
  (interactive)
  (let ((name (buffer-name))
        (filename (buffer-file-name)))
    (if (not (and filename (file-exists-p filename)))
        (error "Buffer '%s' is not visiting a file!" name)
      (let ((new-name (read-file-name "New name: " filename)))
        (if (get-buffer new-name)
            (error "A buffer named '%s' already exists!" new-name)
          (rename-file filename new-name 1)
          (rename-buffer new-name)
          (set-visited-file-name new-name)
          (set-buffer-modified-p nil)
          (message "File '%s' successfully renamed to '%s'"
                   name (file-name-nondirectory new-name)))))))

(global-set-key (kbd "C-x C-r") 'rename-current-buffer-file)

(defun sudo-save ()
  (interactive)
  (if (not buffer-file-name)
      (write-file (concat "/sudo:root@localhost:" (ido-read-file-name "File:")))
    (write-file (concat "/sudo:root@localhost:" buffer-file-name))))

(defun dev-frame-title (title)
  "Set frame title to:- title + ": " + full file path for current buffer."
  (interactive "sSet frame title to: ")
  (setq frame-title title)
  (setq frame-title-format '((concat "" frame-title) ": " (buffer-file-name "%f" (dired-directory dired-directory "%b"))))
  )

(defun dev-term (&optional user)
  "Open ansi term"
  (interactive)
  (ansi-term "/bin/bash")
  ;; rename buffer to "*cp" or buffer_name if provided.
  (if (and user (not (string= user "")))
      (progn
        (insert (concat "sudo su - " user))
        (term-send-input)
        (rename-buffer (concat "*" user) 1))
    (rename-buffer "*term" 1)
    )
  )

(defun dev-shell (&optional user)
  "Open shell"
  (interactive)
  (shell)
  ;; rename buffer to "*cp" or buffer_name if provided.
  (if (and user (not (string= user "")))
      (progn
        (insert (concat "sudo su - " user))
        (comint-send-input)
        (rename-buffer (concat "*" user) 1))
    (rename-buffer "*term" 1)
    )
  )

(defun dev-psql (db &optional buffer_name)
  "Open ansi-term and connect to psql db."
  (interactive "sConnect to db: ")
  (shell)
  (insert (concat "psql " db))
  (comint-send-input)
  ;; rename buffer to "*psql" or buffer_name if provided.
  (if (and buffer_name (not (string= buffer_name "")))
      (rename-buffer (concat "*" buffer_name) 1)
    (rename-buffer "*psql" 1)
    )
  )

(defun dev-cp (ip port &optional buffer_name)
  "Open shell for Naviserver control port login."
  (interactive "sConnect to ip (default 127.0.0.1): \nsConnect to port: ")
  ;; default ip, useful when calling function interactively.
  (if (string= ip "")
      (set 'ip "127.0.0.1")
    )
  ;; open shell instead of ansi-term so we can cycle through command history.
  (shell)
  (insert (concat "telnet " ip " " port))
  (comint-send-input)
  ;; rename buffer to "*cp" or buffer_name if provided.
  (if (and buffer_name (not (string= buffer_name "")))
      (rename-buffer (concat "*" buffer_name) 1)
    (rename-buffer "*cp" 1)
    )
  )

(defun dev-log (log_path)
  "Open log file"
  (interactive "FOpen log file: ")
  (shell)
  (insert (concat "tail -f " log_path))
  (comint-send-input)
  ;; rename buffer as "*" + filename.
  (rename-buffer (concat "*" (file-name-nondirectory log_path)) 1)
  )

(defun dev-load-tcl (tcl_path)
  "Open buffers for .tcl files in tcl_path, set location of TAGS table."
  (interactive "FLoad tcl files in: ")
  (cd tcl_path)
  (find-file "*.tcl" "wildcards")
  )

(defun dev-load-js (js_path)
  "Open buffers for .js files in js_path, set location of TAGS table."
  (interactive "FLoad js files in: ")
  (cd js_path)
  (find-file "*.js" "wildcards")
  )

;; Shortcuts
(global-set-key (kbd "M-#") 'comment-toggle)
(global-set-key [home] 'smart-beginning-of-line)
(global-set-key "\C-a" 'smart-beginning-of-line)
;;(global-set-key (kbd "<f1>") 'multi-term)
;;(global-set-key (kbd "<f2>") 'dev-term)
;;(global-set-key (kbd "<f3>") 'dev-psql)
;;(global-set-key (kbd "<f4>") 'dev-cp)
;;(global-set-key (kbd "<f5>") 'er/expand-region)
;; (global-set-key (kbd "<f6>") ')
;;(global-set-key (kbd "<f7>") (lambda() (interactive)(find-file "~/.emacs.d/daniel.org"))) ;; Open config file
;; (global-set-key (kbd "<f9>") ')
;; (global-set-key (kbd "<f10>") ')
;; (global-set-key (kbd "<f11>") ')
;; (global-set-key (kbd "<f12>") ')

;;(global-set-key (kbd "C-<f1>") 'tags-search)
;;(global-set-key (kbd "C-<f2>") 'tags-query-replace)
;; (global-set-key (kbd "<C-f3>") ')
;; (global-set-key (kbd "<C-f4>") ')
;; (global-set-key (kbd "<C-f5>") ')
;; (global-set-key (kbd "<C-f6>") ')
;; (global-set-key (kbd "<C-f7>") ')
;; (global-set-key (kbd "<C-f8>") ')
;; (global-set-key (kbd "<C-f9>") ')
;; (global-set-key (kbd "<C-f11>") ')
;; (global-set-key (kbd "<C-f12>") ')


;; (global-set-key (kbd "<M-f1>") 'dev-shell)
;; (global-set-key (kbd "<M-f2>") ')
;; (global-set-key (kbd "<M-f3>") ')
;; (global-set-key (kbd "<M-f4>") ')
;; (global-set-key (kbd "<M-f5>") ')
;; (global-set-key (kbd "<M-f6>") ')
;; (global-set-key (kbd "<M-f7>") ')
;; (global-set-key (kbd "<M-f8>") ')
;; (global-set-key (kbd "<M-f9>") ')
;; (global-set-key (kbd "<M-f11>") ')
;; (global-set-key (kbd "<M-f12>") ')

;;(global-set-key (kbd "C-o") 'other-window)
;;(global-set-key (kbd "C-s") 'isearch-forward-regexp)
;;(global-set-key (kbd "C-r") 'isearch-backward-regexp)
(global-set-key (kbd "C-M-s") 'isearch-forward)
(global-set-key (kbd "C-M-r") 'isearch-backward)

;;(global-set-key (kbd "M-/") 'hippie-expand)
(global-set-key (kbd "C-x C-b") 'ibuffer)
;;(global-set-key (kbd "M-z") 'zap-up-to-char)

;;(global-set-key (kbd "C-n") 'new-empty-buffer)

;; shortcut to skip to next/previous buffer
(global-set-key (kbd "M-]") 'next-buffer)
(global-set-key (kbd "M-[") 'previous-buffer)

;; Easier jumping between frames
;;(global-set-key (kbd "C-o") 'other-window)

;;(global-set-key (kbd "M-=") 'text-scale-increase)
;;(global-set-key (kbd "M--") 'text-scale-decrease)

;;(global-set-key (kbd "A-s") 'tags-search)
;;(global-set-key (kbd "A-f") 'tags-query-replace)

(global-set-key (kbd "C-s") 'isearch-forward)
(global-set-key (kbd "C-r") 'isearch-backward)
(global-set-key (kbd "C-M-s") 'isearch-forward-regexp)
(global-set-key (kbd "C-M-r") 'isearch-backward-regexp)

(defun toggle-fullscreen ()
  (interactive)
  (x-send-client-message nil 0 nil "_NET_WM_STATE" 32
                         '(2 "_NET_WM_STATE_MAXIMIZED_VERT" 0))
  (x-send-client-message nil 0 nil "_NET_WM_STATE" 32
                         '(2 "_NET_WM_STATE_MAXIMIZED_HORZ" 0))
  ;;                    (set-variable '(truncate-partial-width-window nil))
  )
(global-set-key (kbd "C-x 4") 'toggle-fullscreen)

;;(global-set-key (kbd "C-x C-j") 'term-line-mode)
;;(global-set-key (kbd "C-x C-j") 'term-char-mode)

;; shortcut for ispell-buffer & flyspell
;;(global-set-key (kbd "C-x C-#") 'ispell-buffer)
;;(global-set-key (kbd "C-x #") 'flyspell-buffer)

;; shortcut for find tag
(global-set-key (kbd "M-.") 'find-tag)

;; shortcut to skip to beggining/end of buffer
(global-set-key (kbd "C-<next>") 'end-of-buffer)
(global-set-key (kbd "C-<prior>") 'beginning-of-buffer)

;; shortcut to skip to next/previous buffer
(global-set-key (kbd "M-<prior>") 'previous-buffer)
(global-set-key (kbd "M-<next>") 'next-buffer)

;; clipboard
(setq x-select-enable-clipboard t
      x-select-enable-primary t
      x-select-enable-clipboard-manager t
      save-interprogram-paste-before-kill t
      select-active-regions t
      x-select-enable-primary t
      apropos-do-all t
      mouse-yank-at-point t
      mouse-drag-copy-region t
      x-selection-timeout 300
      )
 ; make mouse middle-click only paste from primary X11 selection, not clipboard and kill ring.
(global-set-key [mouse-2] 'mouse-yank-primary) 

(setq current-language-environment "UTF-8")

;; for now, fix bug of files disappearing from TAGS files messing up
;; M-x tags-search.  in the future, fix the logic in
;; `tags-verify-table' to detect files being removed.  The problem is
;; that in the TAGS buffers, the buffer-local variable
;; `tags-table-files' is out of date.
(defadvice tags-search (before kill-TAGS-buffers activate)
  (let ((active-TAGS-bufs
         (delq nil
               (mapcar
                (lambda (x)
                  (if (string-match "TAGS$" (buffer-name x)) x nil))
                (buffer-list)))))
    (mapc
     (lambda (x)
       (kill-buffer x))
     active-TAGS-bufs)))

(defun xml-format ()
  (interactive)
  (save-excursion
    (shell-command-on-region (mark) (point) "xmllint --format -" (buffer-name) t)
    )
  )

;; No tabs!
(setq-default indent-tabs-mode nil)
(setq tab-width 4)
(setq indent-tabs-mode nil)

(show-paren-mode 1)
(setq-default indent-tabs-mode nil)

;; Split window and switch focus to new window
(global-set-key "\C-x2" (lambda () (interactive)(split-window-vertically) (other-window 1)))
(global-set-key "\C-x3" (lambda () (interactive)(split-window-horizontally) (other-window 1)))

;; Disable visible bell as this crashes emacs within an X2GO session
(setq visible-bell nil)

;; load up all literate .el files in this directory
(mapc #'load-file (directory-files (format "%s%s/" user-emacs-directory "init") t "\\.el$"))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-faces-vector
   [default default default italic underline success warning error])
 '(ansi-color-names-vector
   ["#212526" "#ff4b4b" "#b4fa70" "#fce94f" "#729fcf" "#e090d7" "#8cc4ff" "#eeeeec"])
 '(custom-enabled-themes nil)
 '(show-paren-mode t)
 )
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
