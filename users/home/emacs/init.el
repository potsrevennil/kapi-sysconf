(require 'evil)
(evil-mode 1)
(evil-set-undo-system 'undo-redo)

(setq backup-directory-alist '((".*" . "~/.Trash")))
(setq create-lockfiles nil)
(load-theme 'tsdh-dark t)
(global-auto-revert-mode 1)
