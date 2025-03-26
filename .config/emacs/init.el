;; -*- lexical-binding: t; -*-

;; ===== Disable Startup Message =====
(setq inhibit-startup-message t)

;; ===== Hide Menu and Tool Bars =====
(if (display-graphic-p)
  (tool-bar-mode 0))
(menu-bar-mode 0)

;; ===== Set Window Size Based On Resolution =====
(defun set-frame-size-according-to-resolution ()
  (interactive)
  (if window-system
  (progn
    ;; use 120 char wide window for largeish displays,
    ;; smaller 80 column windows for smaller displays.
    ;; pick whatever numbers make sense for you
    (if (> (x-display-pixel-width) 1280)
           (add-to-list 'default-frame-alist (cons 'width 140))
           (add-to-list 'default-frame-alist (cons 'width 80)))
    ;; for the height, subtract a couple hundred pixels
    ;; from the screen height (for panels, menubars and
    ;; whatnot), then divide by the height of a char to
    ;; get the height we want
    (add-to-list 'default-frame-alist 
         (cons 'height (/ (- (x-display-pixel-height) 220)
                             (frame-char-height))))
    )))
(set-frame-size-according-to-resolution)

;; ===== Launch Window In Front =====
(if (display-graphic-p)
  (x-focus-frame nil))

;; ===== Don't Split Window When Loading Multiple Files =====
(add-hook 'window-setup-hook 'delete-other-windows)

;; ===== Configure Intel Proxies =====
;(setq url-proxy-services
;  '(("http"     . "http://proxy-jf.intel.com:911")
;    ("https"    . "http://proxy-jf.intel.com:912")
;    ("no_proxy" . "localhost,127.0.0.0/8,::1,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,.sc.intel.com,.drones.intel.com,.devtools.intel.com,.caas.intel.com")
;    ))

;; ===== Set Local site-lisp Path =====
(add-to-list 'load-path "/usr/local/share/emacs/site-lisp")
(add-to-list 'load-path "/usr/local/share/emacs/30.1/site-lisp")

;; ===== Package Archives =====
(require 'package)
(package-initialize)

(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

;; ===== Load Theme =====
(if (boundp 'custom-theme-load-path)
  (progn
    ;; https://emacsthemes.com/
    ;; https://unkertmedia.com/37-emacs-themes-to-try
    (add-to-list 'custom-theme-load-path
                 "~/.config/emacs/elpa/vscode-dark-plus-theme-20230725.1703")
    ;(add-to-list 'custom-theme-load-path
    ;             "~/.config/emacs/elpa/timu-caribbean-theme-20231022.1816")
    ;(add-to-list 'custom-theme-load-path
    ;             "~/.config/emacs/elpa/timu-macos-theme-20231022.1832")
    ;(add-to-list 'custom-theme-load-path
    ;             "~/.config/emacs/elpa/dracula-theme-20231013.821")
  ))

;(if (display-graphic-p)
  (load-theme 'vscode-dark-plus t)
  ;(load-theme 'timu-caribbean t)
  ;(load-theme 'timu-macos t)
  ;(load-theme 'dracula t)
;)

;; ===== Set Fonts =====
(modify-frame-parameters
  (selected-frame)
  '((font . "-*-monaco-*-*-*-*-16-*-*-*-*-*-*")))

(add-hook 'after-make-frame-functions 
          (lambda (frame)
            (modify-frame-parameters 
              frame
              '((font . "-*-monaco-*-*-*-*-16-*-*-*-*-*-*"))
              )))

;; ===== Set Colors =====
;; Set cursor and mouse-pointer colors
;(set-cursor-color "red")
;(set-mouse-color "goldenrod")
;; Set region background color
;(set-face-background 'region "blue")
;; Set Emacs background color
;(set-background-color "black")

;; ===== Set Highlight Current Line Minor Mode ===== 
;; In every buffer, the line which contains the cursor
;; will be fully highlighted
;(global-hl-line-mode t)

;; ===== Line By Line Scrolling =====
;; This makes the buffer scroll by only a single line when the up
;; or down cursor keys push the cursor (tool-bar-mode) outside the
;; buffer. The standard emacs behaviour is to reposition the cursor
;; in the center of screen, but this can make scrolling confusing
(setq scroll-step 1)

;; ===== Turn Off Tab Character =====
;; Emacs normally uses both tabs and spaces to indent lines. If you
;; prefer, all indentation can be made from spaces only. To request
;; this, set `indent-tabs-mode' to `nil'. This is a per-buffer variable;
;; altering the variable affects only the current buffer, but it can be
;; disabled for all buffers.
;; Use (setq ...) to set value locally to a buffer
;; Use (setq-default ...) to set value globally
(setq-default indent-tabs-mode nil)

;; ===== Disable Auto-Indentation of New Lines =====
(when (fboundp 'electric-indent-mode) (electric-indent-mode -1))

;; ===== Make Tab Key Do Indent First Then Completion =====
(setq-default tab-always-indent t)

;; ===== Set Default Tab Width =====
(setq-default tab-width 2)
(setq standard-indent   2)
(setq sh-basic-offset   2)
(setq sh-indentation    2)

;; ===== Support Wheel Mouse Scrolling =====
(if (display-graphic-p)
  (mouse-wheel-mode t))

;; ===== Prevent Emacs From Creating Lock Files =====
(setq create-lockfiles nil)

;; ===== Prevent Emacs From Making Backup Files =====
(setq make-backup-files nil)

;; ===== Write Backup Files in Designated Folder =====
;; Enable backup files
;(setq make-backup-files t)
;; Enable versioning with default values
;(setq version-control t)
;; Save all backup file in this directory
;(setq backup-directory-alist (quote ((".*" . "~/.emacs.d/backups/"))))

;; ===== Show Line+Column Numbers on Mode Line =====
  (line-number-mode t)
(column-number-mode t)

;; ===== Load Editor Mode Extensions =====
(autoload 'jq-mode "jq-mode.el"
  "Major mode for editing jq files" t)

;; ===== Define Auto-Loading of Scripting Major Modes =====
(add-to-list 'interpreter-mode-alist '("bash"   . shell-script-mode))
(add-to-list 'interpreter-mode-alist '("perl"   . perl-mode))
(add-to-list 'interpreter-mode-alist '("python" . python-mode))
(add-to-list 'interpreter-mode-alist '("expect" . tcl-mode))
(add-to-list 'auto-mode-alist        '("\\.jq$" . jq-mode))

;; ===== Show Line Numbers Only In Programming Modes =====
(add-hook 'prog-mode-hook 'display-line-numbers-mode)

;; ===== Make Text Mode The Default Mode For New Buffers =====
(setq default-major-mode 'text-mode)

;; ===== Prevent Emacs From Inserting a NewLine at EOF =====
(setq next-line-add-newline nil)
(setq require-final-newline nil)

;; ===== Send Copied/Killed Text to the OS Clipboard =====
;; See https://github.com/spudlyo/clipetty
(require 'clipetty)
(global-clipetty-mode)

;; ===== Enable Syntax Checking =====
;; https://www.flycheck.org/
(global-flycheck-mode)

;; Make Flycheck ignore "init.el"
;; https://emacs.stackexchange.com/questions/21664/how-to-prevent-flycheck-from-treating-my-init-el-as-a-package-file
(setq-default flycheck-disabled-checkers '(emacs-lisp-checkdoc))

;; ===== Configure TIDE (TypeScript) Environment =====
;; See https://github.com/ananthakumaran/tide
(defun setup-tide-mode ()
  (interactive)
  (tide-setup)
  (flycheck-mode +1)
  (setq flycheck-check-syntax-automatically '(save mode-enabled))
  (eldoc-mode +1)
  (tide-hl-identifier-mode +1)
  ;; company is an optional dependency. You have
  ;; to install it separately via package-install
  ;; `M-x package-install [ret] company`
  (company-mode +1))

;; Align annotations to right-hand side
(setq company-tooltip-align-annotations t)
;; Set TypeScript indentation width
(setq-default typescript-indent-level 2)
;; Format the buffer before saving
;(add-hook 'before-save-hook 'tide-format-before-save)
(add-hook 'typescript-mode-hook #'setup-tide-mode)

;; ===== Highlight Indentations =====
;; https://github.com/antonj/Highlight-Indentation-for-Emacs
(defun setup-highlight-indentation-mode ()
  (require 'highlight-indentation)
  (set-face-background 'highlight-indentation-face "#323232")
  (set-face-background 'highlight-indentation-current-column-face "#4c4c4c")
  (highlight-indentation-mode t)
  (highlight-indentation-current-column-mode t))
(add-hook 'yaml-mode-hook #'setup-highlight-indentation-mode)

;; ===== Function to Prettify XML =====
;; Taken from http://stackoverflow.com/questions/12492/pretty-printing-xml-files-on-emacs
(defun prettify-xml-region (begin end)
"Pretty format XML markup in region. You need to have nxml-mode
http://www.emacswiki.org/cgi-bin/wiki/NxmlMode installed to do
this. The function inserts linebreaks to separate tags that have
nothing but whitespace between them. It then indents the markup
by using nxml's indentation rules."
  (interactive "r")
  (save-excursion
      (nxml-mode)
      (goto-char begin)
      (while (search-forward-regexp "\>[ \\t]*\<" nil t)
        (backward-char) (insert "\n"))
      (indent-region begin end))
    (message "Ah, much better!"))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(just-mode breadcrumb clipetty company docker-compose-mode dockerfile-mode fish-mode flycheck go-mode highlight-indentation ini-mode lua-mode terraform-mode tide typescript-mode xml+))
 '(sort-fold-case t t))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; https://stackoverflow.com/questions/52521587/emacs-error-when-i-call-it-in-the-terminal
(delete-file "~/Library/Colors/Emacs.clr")
