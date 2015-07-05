;; TODO find way to enable c-hungry-delete-forward in all modes
;; NOTE installed packages are: ido-ubiquitous, smex, rainbow-delimiters, geiser, slime, lua-mode, multiple-cursors, magit (2.1), ace-jump-mode
;; NOTE additional files are: paredit.el, <some themes>, desktop+

;; load-path & package archives
(add-to-list 'load-path "~/.emacs.d/extra")
(require 'package)
(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/"))
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)
(package-initialize)
             
;; packages
(require 'ido)
(ido-mode t)
(ido-ubiquitous t)
(require 'smex) 
(global-set-key (kbd "M-x") 'smex)
(global-set-key (kbd "M-X") 'smex-major-mode-commands)
;; This is your old M-x.
;; (global-set-key (kbd "C-c C-c M-x") 'execute-extended-command)
(add-hook 'prog-mode-hook #'rainbow-delimiters-mode)
(require 'magit)
(global-set-key (kbd "C-x g") 'magit-status)
(require 'multiple-cursors)
(global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)
(global-set-key (kbd "C->") 'mc/mark-next-like-this)
(global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this)
;; ace-jump
(autoload
  'ace-jump-mode
  "ace-jump-mode"
  "Emacs quick move minor mode"
  t)
(define-key global-map (kbd "M-o") 'ace-jump-mode)

;; paredit (http://www.emacswiki.org/emacs/ParEdit)
(autoload 'enable-paredit-mode "paredit"
  "Turn on pseudo-structural editing of Lisp code." t)
(add-hook 'emacs-lisp-mode-hook                  #'enable-paredit-mode)
(add-hook 'eval-expression-minibuffer-setup-hook #'enable-paredit-mode)
(add-hook 'ielm-mode-hook                        #'enable-paredit-mode)
(add-hook 'lisp-mode-hook                        #'enable-paredit-mode)
(add-hook 'lisp-interaction-mode-hook            #'enable-paredit-mode)
(add-hook 'scheme-mode-hook                      #'enable-paredit-mode)

;; color theme (https://github.com/juba/color-theme-tangotango)
(add-to-list 'custom-theme-load-path "~/.emacs.d/extra") ; packaged themes sometimes don't work, so we hoard them manually
;;(load-theme 'tangotango t)
;;(load-theme 'hc-zenburn t)
(load-theme 'zenburn t)

;; set meta key to CMD-key instead of Alt-Key
(setq mac-option-key-is-meta nil)
(setq mac-command-key-is-meta t)
(setq mac-command-modifier 'meta)
(setq mac-option-modifier nil)

(global-set-key (kbd "C-z") 'yank) ; remove c-z (suspend-emacs)
(global-set-key (kbd "C-x C-b") 'ibuffer) ; ibuffer
(global-set-key (kbd "<f5>") 'next-error)
(global-set-key (kbd "<f6>") 'previous-error)
(global-set-key (kbd "C-<tab>") 'dabbrev-expand) ; expand
(define-key minibuffer-local-map (kbd "C-<tab>") 'dabbrev-expand) ; expand in minibuffer
(global-set-key (kbd "C-S-k") 'c-hungry-delete-forward) ; nice forward-delete
(global-set-key (kbd "<f12>") 'jao-toggle-selective-display) ; code folding
(global-set-key (kbd "C-c C-t") 'truncate-comint-buffer) ; trunc big buffs

;; sniffed from starter kit
(setq visible-bell t
      uniquify-buffer-name-style 'forward
      backup-directory-alist `(("." . ,(expand-file-name "~/.emacs.d/backups"))))
(when window-system
  (setq frame-title-format '(buffer-file-name "%f" ("%b")))
  (tooltip-mode -1)
  (mouse-wheel-mode t)
  (blink-cursor-mode 1)
  (setq blink-cursor-blinks -1
        blink-cursor-interval .1
        blink-cursor-delay 0.5))
(dolist (mode '(menu-bar-mode
                tool-bar-mode
                scroll-bar-mode))
  (when (fboundp mode) (funcall mode -1)))
(show-paren-mode 1)
(defalias 'yes-or-no-p 'y-or-n-p) ;; ???

;; move between windows
(defun move-cursor-next-pane ()
  "Move cursor to the next pane."
  (interactive)
  (other-window 1))
(defun move-cursor-previous-pane ()
  "Move cursor to the previous pane."
  (interactive)
  (other-window -1))
(global-set-key (kbd "M-n") 'move-cursor-next-pane)
(global-set-key (kbd "M-p") 'move-cursor-previous-pane)

;; lua / love quickfix
(defun run-love-and-load-current (&optional step)
  (interactive ())
  (let ((proc (get-process "shell"))
        pbuf min max command)
    (unless proc
      (let ((currbuff (current-buffer)))
        (shell)
        (switch-to-buffer currbuff)
        (setq proc (get-process "shell"))
        ))
    (setq pbuff (process-buffer proc))
    (if (use-region-p)
        (setq min (region-beginning)
              max (region-end))
      (setq min (point-at-bol)
            max (point-at-eol)))
    ;; (setq command "open -a love.app .\n")
    (setq command "~/Documents/Code/Love/love.app/Contents/MacOS/love .\n")
    (with-current-buffer pbuff
      (goto-char (process-mark proc))
      (insert command)
      (move-marker (process-mark proc) (point))
      ) ;;pop-to-buffer does not work with save-current-buffer -- bug?
    (process-send-string  proc command)
    ;; (display-buffer (process-buffer proc) t)
    ;; (when step 
    ;;   )
    ;;(goto-char max)
    ;;(next-line)
    ))
(require 'lua-mode)
(define-key lua-mode-map (kbd "C-c C-o") 'run-love-and-load-current)

;; fix executable path
;; (when (equal system-type 'darwin)
;;   (setenv "PATH" (concat "/Applications/Racketv6.0.1/bin:/opt/local/bin:/usr/local/bin:"
;;                          (getenv "PATH")))
;;   (push "/opt/local/bin" exec-path)
;;   (push "/usr/bin" exec-path)
;;   (push "/usr/local/bin" exec-path)
;;   )

;; slime
(setq inferior-lisp-program "/Users/philipp/Downloads/ccl/scripts/ccl")

;; python mode
(setq python-shell-interpreter "/Library/Frameworks/Python.framework/Versions/3.4/bin/python3")

;; homemade code folding
(defun jao-toggle-selective-display (column)
  (interactive "P")
  (set-selective-display 
   (if selective-display nil (or column (1+ (current-indentation))))))

;; truncate
(defun truncate-comint-buffer (x)
  (interactive "P")
  (let ((comint-buffer-maximum-size (if x x 4)))
    (comint-truncate-buffer)))

;; ibuffer format
(setq ibuffer-formats '((mark modified read-only " "
                              (name 26 26 :left :elide)
                              " "
                              (size 9 -1 :right)
                              " "
                              (mode 16 16 :left :elide)
                              " " filename-and-process)
                        (mark " "
                              (name 16 -1)
                              " " filename)))

;; lifted from cc-cmds.el
(defun c-hungry-delete-forward ()
  "Delete the following character or all following whitespace
up to the next non-whitespace character.
See also \\[c-hungry-delete-backwards]."
  (interactive)
  (let ((here (point)))
    (c-skip-ws-forward)
    (if (/= (point) here)
	(delete-region (point) here)
      (funcall c-delete-function 1))))

;;(set-frame-font "-apple-Anonymous_Pro-medium-normal-normal-*-14-*-*-*-m-0-iso10646-1")
;;(set-frame-font "-*-Liberation Mono-normal-normal-normal-*-14-*-*-*-m-0-iso10646-1")
(set-frame-font "-*-Source Code Pro-light-normal-normal-*-14-*-*-*-m-0-iso10646-1")

;; generated
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(c-basic-offset 2)
 '(desktop-save-mode t)
 '(geiser-racket-binary "/Applications/Racket v6.1.1/bin/racket")
 '(ibuffer-saved-filter-groups
   (quote
    (("default"
      ("dir"
       (used-mode . dired-mode))
      ("C/C++"
       (or
        (used-mode . c-mode)
        (used-mode . c++-mode)))
      ("lua"
       (used-mode . lua-mode))))))
 '(ibuffer-saved-filters
   (quote
    (("gnus"
      ((or
        (mode . message-mode)
        (mode . mail-mode)
        (mode . gnus-group-mode)
        (mode . gnus-summary-mode)
        (mode . gnus-article-mode))))
     ("programming"
      ((or
        (mode . emacs-lisp-mode)
        (mode . cperl-mode)
        (mode . c-mode)
        (mode . java-mode)
        (mode . idl-mode)
        (mode . lisp-mode)))))))
 '(indent-tabs-mode nil)
 '(inhibit-startup-screen t)
 '(initial-buffer-choice nil)
 '(initial-scratch-message nil)
 '(js-indent-level 2)
 '(lua-indent-level 2)
 '(ns-pop-up-frames nil)
 '(tab-width 2))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
