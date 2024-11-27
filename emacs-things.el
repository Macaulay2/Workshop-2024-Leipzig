(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
			 ("melpa-stable" . "https://stable.melpa.org/packages/")
			 ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Initialize use-package on non linux systems
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(when (cl-find-if-not #'package-installed-p package-selected-packages)
  (package-refresh-contents)
  (mapc #'package-install package-selected-packages))

(use-package ivy
  :diminish
  :bind (("C-s" . swiper))
  :custom (ivy-wrap t)
  :config (ivy-mode 1))

(use-package counsel
  :bind (("M-x" . counsel-M-x)
	 ("C-x b" . counsel-ibuffer)
	 ("C-x C-f" . counsel-find-file)
	 :map minibuffer-local-map
	 ("C-r" . 'counsel-minibuffer-history)))

(use-package magit
  :bind (("C-x g" . 'magit-status)
	 ("C-x M-g" . magit-dispatch)))
(use-package helpful
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key))

(use-package ivy-rich
  :ensure t
  :after (ivy))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package smartparens
  :ensure t
  :config
  (require 'smartparens-config)  ; Load the default smartparens configuration
  (smartparens-global-mode t)    ; Enable smartparens globally
  :bind
  (("M-p f" . sp-forward-slurp-sexp)  ; Bind keys for slurping
   ("M-p b" . sp-backward-slurp-sexp))) ; and barfing
