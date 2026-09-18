;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; ---------------------------------------------------------
;; Font / theme
;; ---------------------------------------------------------

(setq doom-font (font-spec :family "MartianMono Nerd Font" :size 14)
      doom-variable-pitch-font (font-spec :family "MartianMono Nerd Font" :size 14)
      doom-theme 'doom-monokai-classic)

(setq window-divider-default-right-width 4)
(window-divider-mode 1)

;; ---------------------------------------------------------
;; Basic editing / GUI behaviour
;; ---------------------------------------------------------
(setq org-directory "~/org/")

(add-to-list 'default-frame-alist '(fullscreen . maximized))

(setq display-line-numbers-type t)

(setq-default
 cursor-type 'bar
 truncate-lines t
 case-fold-search t)

(global-hl-line-mode 1)
(global-display-line-numbers-mode 1)
(column-number-mode 1)
(blink-cursor-mode 0)
(delete-selection-mode 1)
(global-auto-revert-mode 1)
(electric-pair-mode 1)

;; Custom electric-pair inhibit
(defun my/electric-pair-inhibit (char)
  (and (not (eobp))
       (not (memq (char-after) '(?\s ?\t ?\n ?\r)))))

(setq-default electric-pair-inhibit-predicate #'my/electric-pair-inhibit)

;; Smooth scrolling
(setq scroll-conservatively 101
      mouse-wheel-scroll-amount '(3 ((shift) . hscroll))
      mouse-wheel-progressive-speed nil
      mouse-wheel-tilt-scroll t
      mouse-wheel-scroll-amount-horizontal 2)

;; History
(add-to-list 'savehist-additional-variables 'kill-ring)

(after! persp-mode
  (setq persp-auto-resume-time 5))

(defadvice! +workspaces-preserve-session-on-last-frame-a (orig-fn &optional frame)
  :around #'+workspaces-delete-associated-workspace-h
  (if (null (cdr-safe (persp-frame-list-without-daemon)))
      (persp-save-state-to-file)
    (funcall orig-fn frame)))

;; Disabling format on save for specific minor modes

(setq +format-on-save-disabled-modes
      '(csharp-mode))

;; ---------------------------------------------------------
;; OS-specific modifiers
;; ---------------------------------------------------------
(when (eq system-type 'darwin)
  (setq mac-command-modifier 'super)
  mac-option-modifier 'meta)
(when (eq system-type 'gnu/linux)
  (setq x-super-keysym 'meta
        x-meta-keysym 'super))

;; ---------------------------------------------------------
;; Convenient shortcuts
;; ---------------------------------------------------------
(map! "s-c" #'kill-ring-save
      "s-v" #'yank
      "s-x" #'kill-region
      "s-a" #'mark-whole-buffer
      "s-r" #'query-replace
      "s-z" #'undo
      "s-s" #'save-buffer
      "s-/" #'comment-line
      "s-w" #'kill-current-buffer
      "s-\\" #'my/snap-buffer
      "s-<up>" #'drag-stuff-up
      "s-<down>" #'drag-stuff-down
      "M-~" #'eval-buffer
      "s-m" #'magit
      "s-f" #'rgrep)

(defun my/close-frame-or-quit ()
  (interactive)
  (if (daemonp)
      (delete-frame)
    (save-buffers-kill-terminal)))
(map! "s-q" #'my/close-frame-or-quit)

(defun my/delete-word-forward (arg)
  (interactive "p")
  (delete-region (point) (progn (backward-word arg) (point))))

(map! :g "<C-backspace>" #'my/delete-word-forward)

;; Mouse
(map! [mouse-3] #'context-menu-open)

;; ---------------------------------------------------------
;; Trackpad horizontal scroll direction fix
;; ---------------------------------------------------------
(defun my/trackpad-hscroll (event left)
  (let* ((win (posn-window (event-start event))))
    (when (window-minibuffer-p win)
      (setq win (minibuffer-selected-window)))
    (with-selected-window (if (window-live-p win) win (selected-window))
      (funcall (if left #'scroll-right #'scroll-left)
               mouse-wheel-scroll-amount-horizontal))))

(defun my/wheel-left (event)
  (interactive "e")
  (my/trackpad-hscroll event t))
(defun my/wheel-right (event)
  (interactive "e")
  (my/trackpad-hscroll event nil))

(define-key global-map [wheel-left]  #'my/wheel-left)
(define-key global-map [wheel-right] #'my/wheel-right)

;; ---------------------------------------------------------
;; Buffer snapping (s-\)
;; ---------------------------------------------------------
(defvar my/snapped-window nil)
(defun my/snap-buffer ()
  (interactive)
  (if (and my/snapped-window (window-live-p my/snapped-window))
      (let ((buf (window-buffer my/snapped-window)))
        (delete-window my/snapped-window)
        (set-window-buffer (selected-window) buf)
        (setq my/snapped-window nil))
    (let* ((buf (current-buffer))
           (win (selected-window)))
      (setq my/snapped-window (split-window-right))
      (set-window-buffer my/snapped-window buf)
      (let ((prev (switch-to-prev-buffer win)))
        (unless (and prev (not (eq prev buf)))
          (set-window-buffer win (other-buffer buf)))))))

;; ---------------------------------------------------------
;; Treemacs extras (Unity ignore rules)
;; ---------------------------------------------------------
(after! treemacs
  (setq treemacs-is-never-other-window t
        treemacs-width 20
        treemacs-position 'left
        treemacs-indentation 1)

  (defun my/treemacs-ignore-meta-files-p (filename _path)
    (string-suffix-p ".meta" filename))
  (add-to-list 'treemacs-ignored-file-predicates #'my/treemacs-ignore-meta-files-p)

  (defun my/treemacs-ignore-unity-transients-p (filename path)
    (and (file-directory-p path)
         (string-match-p "\\`\\(Library\\|Temp\\|Logs\\|obj\\|Build\\|Builds\\)\\'"
                         filename)))
  (add-to-list 'treemacs-ignored-file-predicates
               #'my/treemacs-ignore-unity-transients-p)

  (defun my/treemacs-toggle-meta-files ()
    (interactive)
    (if (memq #'my/treemacs-ignore-meta-files-p treemacs-ignored-file-predicates)
        (setq treemacs-ignored-file-predicates
              (delq #'my/treemacs-ignore-meta-files-p treemacs-ignored-file-predicates))
      (add-to-list 'treemacs-ignored-file-predicates #'my/treemacs-ignore-meta-files-p))
    (dolist (buf (buffer-list))
      (when (with-current-buffer buf (derived-mode-p 'treemacs-mode))
        (with-current-buffer buf
          (treemacs--do-refresh (current-buffer) 'all))))
    (message "Unity .meta files are now %s in treemacs."
             (if (memq #'my/treemacs-ignore-meta-files-p treemacs-ignored-file-predicates)
                 "hidden" "visible"))))

(add-hook! 'treemacs-mode-hook (display-line-numbers-mode -1))

(add-hook! 'window-setup-hook #'+treemacs/toggle)
(map! "C-t" #'treemacs)

;; ---------------------------------------------------------
;; Tabs grouping behaviour
;; ---------------------------------------------------------
(after! centaur-tabs
  (defun centaur-tabs-buffer-groups ()
    (list
     (cond
      ((or (string-equal "*" (substring (buffer-name) 0 1))
           (memq major-mode '(magit-process-mode
                              magit-status-mode
                              magit-diff-mode
                              magit-log-mode
                              magit-file-mode
                              magit-blob-mode
                              magit-blame-mode
                              dired-mode
                              eshell-mode
                              helmet-mode)))
       "Emacs")
      (t "Default")))))

;; ---------------------------------------------------------
;; Multiple cursors + mouse support
;; ---------------------------------------------------------
(defun my-mc-middle-drag-start (event)
  (interactive "e")
  (mouse-drag-region event)
  )
(defun my-mc-middle-drag-end (event)
  (interactive "e")
  (mouse-set-region event)

  (when (use-region-p)
    (run-at-time
     0 nil
     (lambda ()
       (when (use-region-p)
         (mc/edit-lines))))))

(with-eval-after-load 'multiple-cursors
  (add-to-list 'mc/cmds-to-run-once
               #'my-mc-middle-drag-end)

  (setq mc/cmds-to-run-for-all
        (remove #'my-mc-middle-drag
                mc/cmds-to-run-for-all)))

(global-set-key [down-mouse-2] #'my-mc-middle-drag-start)
(global-set-key [drag-mouse-2] #'my-mc-middle-drag-end)

;; Cancel multi-cursors with left click
(defun my/mouse-drag-region (event)
  (interactive "e")
  (when (bound-and-true-p multiple-cursors-mode)
    (multiple-cursors-mode -1))
  (mouse-drag-region event))
(map! [down-mouse-1] #'my/mouse-drag-region)

;; ---------------------------------------------------------
;; C# / LSP
;; ---------------------------------------------------------
(after! csharp-mode
  (setq-hook! 'csharp-mode-hook
    c-basic-offset 4
    c-auto-newline t)
  (c-set-offset 'defun-open 0)
  (c-set-offset 'block-open 0)
  (c-set-offset 'inline-open 0)
  (c-set-offset 'substatement-open 0)
  (setq c-hanging-braces-alist
        '((defun-open before after)
          (defun-close before)
          (block-open before after)
          (block-close before)
          (inline-open before after)
          (substatement-open before after)
          (statement-case-open before after))))

;; Prefer csharp-ls
(after! lsp-mode
  (setq lsp-disabled-clients '(omnisharp)
        lsp-headerline-breadcrumb-enable t
        lsp-idle-delay 0.5
        lsp-enable-snippet t
        lsp-completion-provider :capf))

(with-eval-after-load 'lsp-roslyn
  (defun my/lsp-roslyn--find-solution-file ()
    (let ((solutions (lsp-roslyn--find-files-in-parent-directories
                      (file-name-directory (buffer-file-name))
                      (rx (* anychar) "." (or "sln" "slnx") eos))))
      (cond
       ((not solutions) nil)
       ((eq (length solutions) 1) (cl-first solutions))
       (t (lsp-roslyn--pick-solution-file-interactively solutions)))))

  (advice-add 'lsp-roslyn--find-solution-file :override #'my/lsp-roslyn--find-solution-file))

(with-eval-after-load 'lsp-mode
  (define-advice lsp--client-capabilities (:filter-return (caps) roslyn-pull-diagnostics-fix)
    (when-let* ((text-document (alist-get 'textDocument caps))
                (diagnostic    (alist-get 'diagnostic text-document)))
      (setf (alist-get 'dynamicRegistration diagnostic) t))
    caps))

;; (after! lsp-csharp
;;   (cl-defmethod lsp-execute-command (_server (_command (eql textDocument/references)) arguments)
;;     (let ((params (if (and (vectorp arguments) (> (length arguments) 0))
;;                       (aref arguments 0)
;;                     (lsp--text-document-position-params))))
;;       (lsp-request-async
;;        "textDocument/references" params
;;        (lambda (locations)
;;          (if (seq-empty-p locations)
;;              (lsp--error "Not found for: %s" (or (thing-at-point 'symbol t) ""))
;;            (lsp-show-xrefs (lsp--locations-to-xref-items locations) nil t))))))

;;   (eval '(when-let ((csharp-ls-client (gethash 'csharp-ls lsp-clients)))
;;            (setf (lsp--client-custom-capabilities csharp-ls-client)
;;                  '((experimental . ((csharp . ((metadataUris . t))))))))))

(after! lsp-ui
  (setq lsp-ui-doc-enable t
        lsp-ui-doc-position 'at-point
        lsp-ui-doc-delay 0.25
        lsp-ui-doc-use-childframe (display-graphic-p)
        lsp-ui-doc-header t
        lsp-ui-sideline-enable t
        lsp-ui-sideline-show-diagnostics t
        lsp-ui-sideline-show-hover nil
        lsp-ui-sideline-ignore-duplicate t))

(after! company
  (setq company-idle-delay 0.2
        company-minimum-prefix-length 1
        company-tooltip-limit 12
        company-tooltip-align-annotations t
        completion-ignore-case t)
  (map! :map company-active-map
        "TAB" #'company-complete-selection
        "<tab>" #'company-complete-selection))

;; ---------------------------------------------------------
;; Consult keybindins
;; ---------------------------------------------------------
(map! "s-p" #'consult-buffer
      "s-o" #'consult-find
      "s-g" #'consult-ripgrep)

;; ---------------------------------------------------------
;; Winner mode
;; ---------------------------------------------------------
(winner-mode 1)
