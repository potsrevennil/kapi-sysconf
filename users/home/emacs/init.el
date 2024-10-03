(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))
(package-initialize)
(package-refresh-contents)

;; Download Evil
(unless (package-installed-p 'evil)
  (package-install 'evil))

(require 'evil)
(evil-mode 1)
(evil-set-undo-system 'undo-redo)

(setq backup-directory-alist '((".*" . "~/.Trash")))
(setq create-lockfiles nil)
(load-theme 'tsdh-dark t)
(global-auto-revert-mode 1)
