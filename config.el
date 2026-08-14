;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
;;(setq doom-theme 'doom-one)
;;(setq doom-theme 'doom-monokai-classic)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `with-eval-after-load' block, otherwise Doom's defaults may override your
;; settings. E.g.
;;
;;   (with-eval-after-load 'PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look them up).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;; ---------------------------------------------------------
;; Font / theme
;; ---------------------------------------------------------

(setq doom-font (font-spec :family "MartianMono Nerd Font" :size 14)
      doom-variable-pitch-font (font-spec :family "MartianMono Nerd Font" :size 14)
      doom-theme 'doom-monokai-classic)

;; Slightly thicker window dividers
(setq window-divider-default-right-width 4)
(window-divider-mode 1)

;; ---------------------------------------------------------
;; Basic editing / GUI behaviour
;; ---------------------------------------------------------

(add-to-list 'default-frame-alist '(fullscreen . maximized))

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
      mouse-wheel-scroll-amount-horizontal 4)

;; History
(add-to-list 'savehist-additional-variables 'kill-ring)

;; Session persistence via persp-mode (the :ui workspaces module), instead of
;; desktop.el. desktop-save-mode conflicts with persp-mode: it prompts "Save
;; desktop?" on quit/restart, complains "Desktop file in use; not loaded" at
;; daemon startup, and never restores buffers for the daemon+client workflow.
(after! persp-mode
  (setq persp-auto-resume-time 5))

;; When the last client frame is closed, persp-mode's `+workspaces'
;; integration kills all buffers (and only autosaves on daemon exit, which
;; never happens here). Instead, keep the buffers alive in the daemon and save
;; the session, so reopening a client restores them instantly.
(defadvice! +workspaces-preserve-session-on-last-frame-a (orig-fn &optional frame)
  "Save the session, but keep its buffers, when the last client frame closes."
  :around #'+workspaces-delete-associated-workspace-h
  (if (null (cdr-safe (persp-frame-list-without-daemon)))
      (persp-save-state-to-file)
    (funcall orig-fn frame)))

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
;; Familiar shortcuts
;; ---------------------------------------------------------
(map! "s-c" #'kill-ring-save
      "s-v" #'yank
      "s-x" #'kill-region
      "s-a" #'mark-whole-buffer

      "s-f" #'isearch-forward

      "s-r" #'query-replace
      "s-z" #'undo
      "s-s" #'save-buffer
      "s-/" #'comment-line
      "s-w" #'kill-current-buffer
      "s-\\" #'my/snap-buffer
      "s-<up>" #'drag-stuff-up
      "s-<down>" #'drag-stuff-down
      "M-~" #'eval-buffer)

;; Cmd+Q closes the client frame without the "Close frame?" prompt. Calling
;; `delete-frame' directly (not via the `[remap delete-frame]' keybinding)
;; bypasses `doom/delete-frame-with-prompt'.
(defun my/close-frame-or-quit ()
  (interactive)
  (if (daemonp)
      (delete-frame)
    (save-buffers-kill-terminal)))
(map! "s-q" #'my/close-frame-or-quit)

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
        treemacs-position 'left)

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
                 "hidden" "visible")))
  ;; :leader
  (add-hook 'treemacs-mode-hook (lambda () (display-line-numbers-mode -1))))

(add-hook! 'window-setup-hook #'+treemacs/toggle)
(map! "C-t" #'treemacs)

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

(after! lsp-csharp
  (cl-defmethod lsp-execute-command (_server (_command (eql textDocument/references)) arguments)
    (let ((params (if (and (vectorp arguments) (> (length arguments) 0))
                      (aref arguments 0)
                    (lsp--text-document-position-params))))
      (lsp-request-async
       "textDocument/references" params
       (lambda (locations)
         (if (seq-empty-p locations)
             (lsp--error "Not found for: %s" (or (thing-at-point 'symbol t) ""))
           (lsp-show-xrefs (lsp--locations-to-xref-items locations) nil t))))))

  (eval '(when-let ((csharp-ls-client (gethash 'csharp-ls lsp-clients)))
           (setf (lsp--client-custom-capabilities csharp-ls-client)
                 '((experimental . ((csharp . ((metadataUris . t))))))))))

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
