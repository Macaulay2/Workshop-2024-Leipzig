(setq package-archives '(("melpa" . "https://melpa.org/packages/")
			 ("melpa-stable" . "https://stable.melpa.org/packages/")
			 ("elpa" . "https://elpa.gnu.org/packages/")))

(use-package swiper :ensure t)
(use-package ivy
  :diminish
  :bind (("C-s" . swiper))
  :custom (ivy-wrap t)
  :config (ivy-mode 1))

(use-package counsel
  :ensure t
  :bind (("M-x" . counsel-M-x)
	 ("C-x b" . counsel-ibuffer)
	 ("C-x C-f" . counsel-find-file)
	 :map minibuffer-local-map
	 ("C-r" . 'counsel-minibuffer-history)))

(use-package magit
  :ensure t
  :bind (("C-x g" . 'magit-status)
	 ("C-x M-g" . magit-dispatch)))
