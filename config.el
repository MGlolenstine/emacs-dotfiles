;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; ── Session / startup behaviour ───────────────────────────────────────────
;; Clean-slate model: no session restore, no lingering buffers from last time.
;; Matches the `nvim .` workflow — you know where you're going, use the picker.
(setq doom-session-auto-save nil
      doom-session-auto-load nil)

;; Open `find-file` immediately on startup instead of a dashboard.
;; SPC SPC / SPC f f also work as normal during a session.
(add-hook 'doom-after-init-hook
          (lambda ()
            (when (zerop (length command-line-args-left))
              (call-interactively #'find-file)))
          100)

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
(setq doom-font (font-spec :family "JetBrainsMono Nerd Font" :size 14)
      doom-symbol-font (font-spec :family "Symbols Nerd Font Mono"))
(after! emojify
  (setq emojify-display-style 'unicode))

;; macOS GUI doesn't inherit shell $PATH; add Homebrew and common tool paths
;; once without duplicating entries across reloads.
(let* ((paths '("/opt/homebrew/bin"
                "/opt/homebrew/sbin"
                "/usr/local/bin"))
       (merged-paths (delete-dups
                      (append paths
                              (split-string (or (getenv "PATH") "")
                                            path-separator t)))))
  (setq exec-path (delete-dups (append paths exec-path)))
  (setenv "PATH" (mapconcat #'identity merged-paths path-separator)))

;; Tree-sitter grammar libraries
(setq treesit-extra-load-path '("~/.config/emacs/.local/etc/tree-sitter"))

;; ── Fix 4: Suppress spurious tree-sitter "not-found" warnings ─────────────
;; Emacs 29 probes several .so/.dylib path variants before finding the right
;; one; the failed probes emit noisy warnings. Suppress the treesit warning
;; category entirely (actual grammar errors will still appear via other means).
(add-to-list 'warning-suppress-types '(treesit))

;; ── Fix 1: Kill vc-mode's per-file-open git subprocess storm (~1.4s saved) ──
;; vc-refresh-state fires on every find-file and spawns ~20 git subprocesses
;; (vc-git-working-revision, vc-git-mode-line-string, git symbolic-ref, etc.)
;; costing ~1.4s on macOS due to slow process spawn overhead.
;;
;; Strategy: keep Git in vc-handled-backends (diff-hl needs vc-backend to
;; return 'Git for fringe markers) but remove the hook that fires the
;; subprocess storm and disable the modeline vc string (we use Magit anyway).
(remove-hook 'find-file-hook #'vc-refresh-state)
;; Disable the vc modeline segment — this suppresses vc-git-mode-line-string
;; and vc-git--symbolic-ref subprocess calls on buffer switches.
(setq vc-display-status nil)

;; Use external indexing for fast project file finding.
(after! projectile
  (setq projectile-indexing-method 'alien
        projectile-enable-caching t
        projectile-generic-command "fd . -0 --type f --color=never"
        projectile-git-command "fd . -0 --type f --color=never"
        projectile-globally-ignored-directories
        '("node_modules" ".git" "dist" "build" ".next"
          ".cache" "out" ".svn" "coverage" ".turbo")))

;; kaitai-mode — interactive binary format explorer
(use-package! kaitai-mode
  :commands kaitai-mode
  :config
  (setq kaitai-compiler-executable "/opt/homebrew/bin/kaitai-struct-compiler"
        kaitai-python-executable   "python3"))

;; Defer flyspell on open — scan only visible text, not the whole buffer
(after! flyspell
  (setq flyspell-issue-message-flag nil)
  (setq flyspell-delay 2))

;; ── Fix 2: Defer flycheck initial syntax check (~0.47s saved) ─────────────
;; flycheck-eslint-config-exists-p spawns a Node.js process synchronously on
;; the first buffer open to locate eslint config, costing ~470ms. Removing
;; 'mode-enabled from check triggers means the first check fires after
;; idle-change delay instead of immediately on file open.
(after! flycheck
  (setq flycheck-check-syntax-automatically
        '(idle-change idle-buffer-switch save))
  (setq flycheck-idle-change-delay 1.0)
  (setq flycheck-idle-buffer-switch-delay 1.5))

;; ── Fix B: Show ESLint warnings alongside LSP type errors ─────────────────
;; flycheck-eglot-exclusive t (default) replaces all checkers with eglot-check
;; when LSP connects, dropping ESLint entirely. Setting it nil makes eglot-check
;; the primary checker and chains javascript-eslint after it, so both LSP
;; type errors and ESLint style/quality warnings are visible simultaneously.
(after! flycheck-eglot
  (setq-default flycheck-eglot-exclusive nil))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
;; (setq doom-theme 'doom-one)
(setq doom-theme 'doom-gruvbox)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variab, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;; Better selection workflow
(map! :n "SPC v e" #'er/expand-region
      :n "SPC v c" #'er/contract-region
      :n "SPC v w" #'evil-visual-word
      :n "SPC v l" #'evil-visual-line
      :n "SPC v p" #'evil-visual-paragraph)

;; Multiple cursors (closer to Helix multi-select)
(map! :nv "SPC m c" #'mc/mark-all-like-this
      :nv "SPC m n" #'mc/mark-next-like-this
      :nv "SPC m p" #'mc/mark-previous-like-this)

;; Better search and select
;; (map! :n "SPC s s" #'swiper           ; visual search
;;       :n "SPC s r" #'vr/replace       ; visual regex replace
;;       :n "SPC j j" #'avy-goto-char-2) ; jump anywhere

(map! :leader
      :nv
      :desc "Visual regex replace"
      "s r" #'vr/replace)



;; ──────────────────────────────────────────────────────────────────────
;; TypeScript / JavaScript debugging via dape + vscode-js-debug
;; ──────────────────────────────────────────────────────────────────────
;; Prerequisites:
;;   1. Run ~/.config/doom/bin/bootstrap-debugging
;;      (installs a pinned js-debug release into debug-adapters/js-debug/)
;;   2. The script also installs `tsx` globally if needed
;;
;; Built-in dape configs already available:
;;   js-debug-node        — launch a .js file
;;   js-debug-ts-node     — launch a .ts file via ts-node
;;   js-debug-tsx         — launch a .ts file via tsx
;;   js-debug-node-attach — attach to node --inspect on port 9229
;;   js-debug-chrome      — attach to Chrome on localhost:3000
;;
;; Custom configs added below:
;;   js-debug-npm-run     — launch an npm script for debugging
;;   js-debug-jest-test   — debug Jest on the current test file
;;   js-debug-jest-single — debug the nearest test/it block at cursor

;; Holds the source buffer and cursor position captured before the dape
;; minibuffer opens, so that `fn' callbacks can reliably access the
;; buffer the user invoked the debugger from.
(defconst +dape-js-debug-version "v1.117.0"
  "Pinned vscode-js-debug release used by `bin/bootstrap-debugging`.")

(defconst +dape-js-debug-server-path
  (expand-file-name "debug-adapters/js-debug/src/dapDebugServer.js" doom-user-dir)
  "Path to the local js-debug DAP server entrypoint.")

(defconst +dape-bootstrap-script
  (expand-file-name "bin/bootstrap-debugging" doom-user-dir)
  "Repo-local helper for installing JS debugging prerequisites.")

(defun +dape-missing-runtime-deps ()
  "Return missing JavaScript debugging dependencies for this config."
  (let (missing)
    (unless (file-exists-p +dape-js-debug-server-path)
      (push (format "`js-debug` adapter at %s"
                    (abbreviate-file-name +dape-js-debug-server-path))
            missing))
    (unless (executable-find "tsx")
      (push "`tsx` executable" missing))
    (nreverse missing)))

(defun +dape-runtime-warning-message ()
  "Return a user-facing message for missing JS debugging prerequisites."
  (let ((missing (+dape-missing-runtime-deps)))
    (format (concat "JavaScript/TypeScript debugging prerequisites are missing: %s.\n"
                    "Run `%s` to install the pinned js-debug adapter (%s) and `tsx`.")
            (mapconcat #'identity missing ", ")
            (abbreviate-file-name +dape-bootstrap-script)
            +dape-js-debug-version)))

(defun +dape-warn-missing-runtime-deps ()
  "Show a startup warning when JS debugging prerequisites are missing."
  (when (+dape-missing-runtime-deps)
    (display-warning 'dape (+dape-runtime-warning-message) :warning)))

(defun +dape-bootstrap-debugging ()
  "Install JS debugging prerequisites for this config."
  (interactive)
  (unless (file-executable-p +dape-bootstrap-script)
    (user-error "Bootstrap script is not executable: %s"
                (abbreviate-file-name +dape-bootstrap-script)))
  (let ((buffer (get-buffer-create "*dape-bootstrap-debugging*")))
    (with-current-buffer buffer
      (erase-buffer))
    (make-process
     :name "dape-bootstrap-debugging"
     :buffer buffer
     :command (list shell-file-name shell-command-switch +dape-bootstrap-script)
     :noquery t
     :sentinel
     (lambda (process _event)
       (when (memq (process-status process) '(exit signal))
         (display-buffer (process-buffer process))
         (if (= (process-exit-status process) 0)
             (message "JS debugging prerequisites installed successfully")
           (display-warning
            'dape
            (format "Debug bootstrap failed; see buffer %s"
                    (buffer-name (process-buffer process)))
            :error)))))
    (display-buffer buffer)
    (message "Installing JS debugging prerequisites...")))

(add-hook 'emacs-startup-hook #'+dape-warn-missing-runtime-deps)

(defvar +dape--source-buffer nil)
(defvar +dape--source-point nil)

(defun +dape--capture-source-buffer ()
  "Save current buffer and point before dape opens the minibuffer."
  (setq +dape--source-buffer (current-buffer)
        +dape--source-point  (point)))

(add-hook 'dape-read-config-hook #'+dape--capture-source-buffer)

(defun +dape-jest-test-name-at-point ()
  "Return the name of the nearest Jest test (it/test/describe) at point.
Searches backward from point for the innermost `it(`, `test(`, or
`describe(` call and returns its first argument as a string.
Handles string literals ('...', \"...\", `...`) and identifier
references (e.g. enum values like TestCase.Name)."
  (save-excursion
    (let ((found nil))
      (while (and (not found)
                  (re-search-backward
                   "\\<\\(it\\|test\\|describe\\)\\s-*(" nil t))
        (let ((match-start (match-beginning 0))
              (match-after (match-end 0)))
          (unless (nth 4 (syntax-ppss match-start))
            (save-excursion
              (goto-char match-after)
              (skip-chars-forward " \t\n")
              (cond
               ;; String literal — extract content between quotes
               ((looking-at "['\"`]")
                (let ((quote-char (char-after)))
                  (forward-char 1)
                  (let ((start (point)))
                    (if (eq quote-char ?`)
                        (when (search-forward "`" nil t)
                          (setq found (buffer-substring-no-properties
                                       start (1- (point)))))
                      (when (search-forward (char-to-string quote-char) nil t)
                        (setq found (buffer-substring-no-properties
                                     start (1- (point)))))))))
               ;; Identifier (enum, variable, etc.) — grab the symbol
               ((looking-at "[a-zA-Z_$]")
                (let ((start (point)))
                  (skip-chars-forward "a-zA-Z0-9_$.")
                  (setq found (buffer-substring-no-properties start (point))))))))
          (goto-char (max (point-min) (1- match-start)))))
      (or found (user-error "No test/it/describe block found above point")))))

(after! dape
  (let ((js-debug-base
         `(ensure ,(lambda (config)
                      (dape-ensure-command config)
                      (when-let* ((runtime-executable
                                   (dape-config-get config :runtimeExecutable)))
                        (when (and (string= runtime-executable "tsx")
                                   (not (executable-find runtime-executable)))
                          (+dape-warn-missing-runtime-deps)
                          (user-error "%s" (+dape-runtime-warning-message)))
                        (dape--ensure-executable runtime-executable))
                      (let ((dap-debug-server-path
                             (car (plist-get config 'command-args))))
                        (unless (file-exists-p dap-debug-server-path)
                          (+dape-warn-missing-runtime-deps)
                          (user-error "%s" (+dape-runtime-warning-message)))))
            command "node"
            command-args (,+dape-js-debug-server-path
                          :autoport)
            port :autoport
            ;; Only resolve source maps from project code, not from
            ;; node_modules or global npm packages. Silences hundreds
            ;; of "Could not read source map" warnings.
            :resolveSourceMapLocations ["${workspaceFolder}/**"
                                        "!**/node_modules/**"])))

    ;; Debug an npm script — edit :runtimeArgs in the minibuffer to pick
    ;; a different script, e.g. ["run" "dev"] or ["run" "start:debug"]
    (setf (alist-get 'js-debug-npm-run dape-configs)
          `(modes (js-mode js-ts-mode typescript-mode typescript-ts-mode)
            ,@js-debug-base
            :type "pwa-node"
            :request "launch"
            :cwd dape-cwd
            :runtimeExecutable "npm"
            :runtimeArgs ["run" "debug"]
            :console "integratedTerminal"))

    ;; Debug the current test file with Jest (runs --runInBand for proper
    ;; breakpoint support). Automatically passes the current buffer as
    ;; the test file pattern.
    (setf (alist-get 'js-debug-jest-test dape-configs)
          `(modes (js-mode js-ts-mode typescript-mode typescript-ts-mode)
            ,@js-debug-base
            :type "pwa-node"
            :request "launch"
            :cwd dape-cwd
            :runtimeExecutable "npx"
            :runtimeArgs ["jest" dape-buffer-default
                          "--no-coverage" "--runInBand"]
            :console "integratedTerminal"))

    ;; Debug a SINGLE test at cursor — searches backward for the nearest
    ;; it()/test()/describe() and passes its name to --testNamePattern.
    ;; Place cursor inside the test you want to debug, then SPC d d →
    ;; js-debug-jest-single
    ;; Uses `fn' so the test name is resolved at launch time, not during
    ;; minibuffer completion (which would freeze Emacs).
    (setf (alist-get 'js-debug-jest-single dape-configs)
          `(modes (js-mode js-ts-mode typescript-mode typescript-ts-mode)
            ,@js-debug-base
            fn ,(lambda (config)
                  (let ((test-name
                         (with-current-buffer +dape--source-buffer
                           (save-excursion
                             (goto-char +dape--source-point)
                             (+dape-jest-test-name-at-point)))))
                    (plist-put config :runtimeArgs
                               (vector "jest" (dape-buffer-default)
                                       "--no-coverage" "--runInBand"
                                       "--testNamePattern" test-name))
                    config))
            :type "pwa-node"
            :request "launch"
            :cwd dape-cwd
            :runtimeExecutable "npx"
            :runtimeArgs ["jest" dape-buffer-default
                          "--no-coverage" "--runInBand"
                          "--testNamePattern" ""]
            :console "integratedTerminal"))))


;; Customise the look of the org-present presentations.
(defvar-local +org-present--saved-ui-state nil
  "Saved UI state for the current org-present buffer.")

(defun +org-present--save-ui-state ()
  "Capture the current buffer and frame UI state before org-present tweaks it."
  (setq +org-present--saved-ui-state
        (list :fullscreen (frame-parameter nil 'fullscreen)
              :mode-line mode-line-format
              :header-line header-line-format
              :left-margin left-margin-width
              :right-margin right-margin-width
              :face-remapping face-remapping-alist
              :display-line-numbers display-line-numbers
              :display-line-numbers-enabled (bound-and-true-p display-line-numbers-mode)
              :centaur-tabs-enabled (and (fboundp 'centaur-tabs-mode)
                                         (bound-and-true-p centaur-tabs-mode)))))

(defun +org-present--restore-ui-state ()
  "Restore the UI state saved by `+org-present--save-ui-state'."
  (when-let ((state +org-present--saved-ui-state))
    (set-frame-parameter nil 'fullscreen (plist-get state :fullscreen))
    (setq-local mode-line-format (plist-get state :mode-line)
                header-line-format (plist-get state :header-line)
                left-margin-width (plist-get state :left-margin)
                right-margin-width (plist-get state :right-margin)
                face-remapping-alist (plist-get state :face-remapping)
                display-line-numbers (plist-get state :display-line-numbers))
    (if (plist-get state :display-line-numbers-enabled)
        (display-line-numbers-mode 1)
      (display-line-numbers-mode -1))
    (when (fboundp 'centaur-tabs-mode)
      (centaur-tabs-mode (if (plist-get state :centaur-tabs-enabled) 1 -1)))
    (setq +org-present--saved-ui-state nil)
    (set-window-buffer nil (current-buffer))))

(add-hook 'org-present-mode-hook
          (lambda ()
            (+org-present--save-ui-state)
            (org-present-big)
            (org-display-inline-images)
            (org-present-hide-cursor)
            (display-line-numbers-mode -1)

            ;; Keybinds
            ;; (local-set-key (kbd "<right>") #'org-present-next)
            ;; (local-set-key (kbd "<left>")  #'org-present-prev)
            ;; (local-set-key (kbd "q")       #'org-present-quit)

            (evil-define-key 'normal org-present-mode-keymap
              (kbd "<right>") #'org-present-next
              (kbd "<left>")  #'org-present-prev
              (kbd "q")       #'org-present-quit)

            ;; Fullscreen
            (set-frame-parameter nil 'fullscreen 'fullboth)

            ;; Hide UI
            (setq-local mode-line-format nil)
            (when (fboundp 'centaur-tabs-mode)
              (centaur-tabs-mode -1))

            ;; Top padding
            (setq-local header-line-format " ")
            (setq-local face-remapping-alist
                        '((header-line (:height 4.0))
                          (default (:height 1.5))))

            ;; Side padding
            (setq-local left-margin-width 15)
            (setq-local right-margin-width 15)
            (set-window-buffer nil (current-buffer))))

(add-hook 'org-present-mode-quit-hook
          (lambda ()
            (org-present-small)
            (org-remove-inline-images)
            (org-present-show-cursor)
            (+org-present--restore-ui-state)))

;; ──────────────────────────────────────────────────────────────────────
;; org-re-reveal — Export Org files to reveal.js presentations
;; ──────────────────────────────────────────────────────────────────────
(use-package! org-re-reveal
  :after org
  :config
  ;; Default to a local reveal.js checkout relative to the org file.
  ;; Individual files can override with #+REVEAL_ROOT:.
  (setq org-re-reveal-root "./reveal.js"
        org-re-reveal-revealjs-version "4"
        org-re-reveal-transition "slide"
        org-re-reveal-theme "white"
        org-re-reveal-plugins '(notes search zoom)
        org-re-reveal-title-slide
        "<h1>%t</h1><h3>%a</h3><p>%d</p>"))

(use-package! simple-httpd
  :commands httpd-start httpd-stop)

(defvar +reveal-httpd-port 8899
  "Port for the local HTTP server used to serve reveal.js presentations.")

(defvar-local +reveal-live-export nil
  "When non-nil, auto-export this Org buffer to reveal.js HTML on save.")

(defun +reveal-present-current-file ()
  "Export the current Org buffer to a reveal.js HTML presentation,\nstart a local HTTP server, open it in the browser, and enable\nauto-export on save so the browser live-reloads."
  (interactive)
  (unless (derived-mode-p 'org-mode)
    (user-error "Not an Org buffer"))
  (require 'org-re-reveal)
  (require 'simple-httpd)
  ;; Export to HTML
  (let* ((org-file (buffer-file-name))
         (html-file (org-re-reveal-export-to-html))
         (html-basename (file-name-nondirectory html-file))
         (serve-dir (file-name-directory (expand-file-name html-file))))
    ;; Start (or restart) httpd rooted in the org file's directory
    (setq httpd-root serve-dir
          httpd-port +reveal-httpd-port)
    (ignore-errors (httpd-stop))
    (httpd-start)
    ;; Enable auto-export on save for this buffer
    (setq-local +reveal-live-export t)
    ;; Open in browser
    (let ((url (format "http://localhost:%d/%s" +reveal-httpd-port html-basename)))
      (browse-url url)
      (message "Presenting %s at %s (live-reload enabled)" html-basename url))))

(defun +reveal-auto-export-on-save ()
  "Re-export the current Org buffer to reveal.js HTML if live export is active."
  (when (and +reveal-live-export
             (derived-mode-p 'org-mode))
    (let ((inhibit-message t))
      (org-re-reveal-export-to-html))
    (message "reveal.js: re-exported %s" (file-name-nondirectory buffer-file-name))))

(add-hook 'after-save-hook #'+reveal-auto-export-on-save)

(map! :leader
      :desc "Present org as reveal.js"
      "o P" #'+reveal-present-current-file)

;; ──────────────────────────────────────────────────────────────────────
;; Project Command Picker (SPC x)
;; Parses package.json scripts and Makefile targets, presents in minibuffer
;; ──────────────────────────────────────────────────────────────────────

(defun +project-tools--detect-package-manager (root)
  "Detect which package manager is used in ROOT by checking lockfiles."
  (cond
   ((file-exists-p (concat root "/pnpm-lock.yaml")) "pnpm")
   ((file-exists-p (concat root "/yarn.lock")) "yarn")
   ((file-exists-p (concat root "/package-lock.json")) "npm")
   (t "npm")))

(defun +project-tools--build-package-command (pm script)
  "Build the command string for running a script with package manager PM."
  (if (string= pm "yarn")
      (format "yarn %s" script)
    (format "%s run %s" pm script)))

(defun +project-tools--parse-package-json (dir)
  "Parse package.json in DIR and return list of (:name :source :cmd :cwd)."
  (let ((path (concat dir "/package.json"))
        (results '()))
    (when (file-exists-p path)
      (let* ((content (ignore-errors (with-temp-buffer
                                       (insert-file-contents path)
                                       (buffer-string))))
             (decoded (ignore-errors (json-read-from-string content)))
             (scripts (and decoded (cdr (assoc 'scripts decoded))))
             (pm (when scripts (if decoded (+project-tools--detect-package-manager dir) "npm")))
             (display-path (file-relative-name path (expand-file-name "~"))))
        (when scripts
          (dolist (entry scripts)
            (let ((name (car entry)))
              (push (list :name name
                          :source (format "%s (%s)" display-path pm)
                          :cmd (+project-tools--build-package-command pm name)
                          :cwd dir)
                    results)))
          (setq results (sort results
                              (lambda (a b) (string< (plist-get a :name)
                                                     (plist-get b :name))))))))
    results))

(defun +project-tools--parse-makefile (dir)
  "Parse Makefile in DIR and return list of (:name :source :cmd :cwd)."
  (let ((path (concat dir "/Makefile"))
        (results '())
        (seen (make-hash-table :test 'equal)))
    (when (file-exists-p path)
      (let ((display-path (file-relative-name path (expand-file-name "~"))))
        (ignore-errors
          (with-temp-buffer
            (insert-file-contents path)
            (goto-char (point-min))
            (while (not (eobp))
              (let ((line (buffer-substring-no-properties (point-at-bol) (point-at-eol))))
                ;; Match lines like "target:" but skip indented lines and comments
                (when (and (not (string-match-p "^\\s-" line))
                           (not (string-match-p "^#" line))
                           (string-match "^\\([a-zA-Z0-9_.-]+\\)\\s-*:" line))
                  (let ((target (match-string 1 line)))
                    ;; Skip .PHONY and targets starting with .
                    (unless (or (string-prefix-p "." target)
                                (string= target "PHONY")
                                (gethash target seen))
                      (puthash target t seen)
                      (push (list :name target
                                  :source display-path
                                  :cmd (format "make %s" target)
                                  :cwd dir)
                            results)))))
              (forward-line 1))))
        (setq results (sort results
                            (lambda (a b) (string< (plist-get a :name)
                                                   (plist-get b :name)))))))
    results))

(defun +project-tools--run-in-vterm (dir cmd)
  "Run CMD in a vterm buffer under directory DIR."
  (let ((buffer-name (format "*project-cmd: %s*" cmd)))
    ;; Open the runner in a popup while keeping focus in the origin window.
    (let ((default-directory dir))
      (let ((buf (vterm-other-window buffer-name)))
        (with-current-buffer buf
          (setq default-directory dir)
          (vterm-send-string cmd)
          (vterm-send-return))))))

(set-popup-rule! "^\\*project-cmd:"
  :side 'bottom
  :size 0.25
  :select nil
  :quit nil
  :ttl nil)

(defun +project-tools-run-picker ()
  "Pick a project command from package.json scripts or Makefile targets and run it."
  (interactive)
  (let* ((root (or (projectile-project-root) default-directory))
         (items '())
         (dirs-to-scan (list root (expand-file-name "code" root))))
    ;; Collect commands from root and code/ subdirectory
    (dolist (dir dirs-to-scan)
      (when (file-directory-p dir)
        (dolist (item (append (+project-tools--parse-package-json dir)
                              (+project-tools--parse-makefile dir)))
          (push item items))))
    (if (not items)
        (message "No package.json scripts or Makefile targets found in project root")
      ;; Deduplicate by name, keeping first occurrence
      (let ((seen (make-hash-table :test 'equal))
            (deduped '()))
        (dolist (item items)
          (let ((name (plist-get item :name)))
            (unless (gethash name seen)
              (puthash name t seen)
              (push item deduped))))
        (setq items (nreverse deduped)))
      ;; Present picker via completing-read (uses Vertico)
      (let ((choice (completing-read
                     (format "Project commands (%s): " root)
                     (mapcar (lambda (item)
                               (cons (format "%-25s  [%s]"
                                             (plist-get item :name)
                                             (plist-get item :source))
                                     item))
                             items)
                     nil t)))
        (when choice
          (let* ((selected (cdr (assoc choice
                                        (mapcar (lambda (item)
                                                  (cons (format "%-25s  [%s]"
                                                                (plist-get item :name)
                                                                (plist-get item :source))
                                                        item))
                                                items))))
                 (cmd (plist-get selected :cmd))
                 (cwd (plist-get selected :cwd)))
            (when cmd
              (+project-tools--run-in-vterm cwd cmd))))))))

(map! :leader
      :desc "Run project command"
      "x" #'+project-tools-run-picker)

(after! eglot
  ;; 1. Do not freeze Emacs waiting for the TypeScript LSP to boot.
  ;; Let it connect in the background so you can start typing immediately.
  (setq eglot-sync-connect nil)

  ;; 2. Disable the hidden Eglot events logging buffer.
  ;; This stops Emacs from allocating 100+ MB of memory just to save
  ;; massive JSON initialization payloads sent by the TS server.
  (setq eglot-events-buffer-size 0)

  ;; Fix 3: Keep the TS language server alive between file switches (~0.2s saved).
  ;; With eglot-autoshutdown t, closing the last TS buffer kills the server
  ;; synchronously. The next TS file open then pays the full reconnect cost.
  ;; +lsp-defer-shutdown gives the server a 30s grace period — if you reopen a
  ;; TS file within 30s it reuses the live server with zero reconnect cost.
  (setq +lsp-defer-shutdown 30))

;; 3. Defer eglot startup to after the buffer is rendered.
;; lsp! is added by Doom to <mode>-local-vars-hook and fires synchronously
;; during after-find-file. On the first .ts file open this blocks ~2s while
;; typescript-language-server boots. We remove lsp! from those hooks and
;; replace it with a version that defers via an idle timer.
(defun +lsp!-deferred ()
  "Like `lsp!' but runs after a short idle delay to avoid blocking find-file."
  (let ((buf (current-buffer)))
    (run-with-idle-timer 0.1 nil
                         (lambda ()
                           (when (buffer-live-p buf)
                             (with-current-buffer buf
                               (lsp!)))))))

(defun +lsp!-replace-with-deferred-h ()
  "Swap `lsp!' for `+lsp!-deferred' on the current mode's local-vars-hook."
  (let ((hook (intern (format "%s-local-vars-hook" major-mode))))
    (when (and (boundp hook) (memq #'lsp! (symbol-value hook)))
      (remove-hook hook #'lsp!)
      (add-hook hook #'+lsp!-deferred))))

;; Run on mode activation, before local-vars-hook fires, so the swap happens
;; in time. typescript-ts-mode is built-in (no package to eval-after-load on),
;; so we hook into the mode hooks themselves.
(dolist (mode-hook '(typescript-mode-hook typescript-ts-mode-hook
                     js-mode-hook js-ts-mode-hook))
  (add-hook mode-hook #'+lsp!-replace-with-deferred-h))

;; Fix the format buffer to create an undo-boundary and set the buffer to changed.
(map! :leader
      :desc "Format buffer"
      "c f" (cmd! (undo-boundary)
                  (+format/region-or-buffer)
                  (set-buffer-modified-p t)))

;; ──────────────────────────────────────────────────────────────────────
;; emacs-http-client — JetBrains-compatible .http file client
;; Replaces restclient.el from the `rest' module.
;; ──────────────────────────────────────────────────────────────────────
(use-package! http-client
  :mode (("\\.http\\'" . http-client-mode)
         ("\\.rest\\'" . http-client-mode))
  :config
  ;; Use JS (Node.js) for full JetBrains .http script compatibility.
  ;; Switch to 'elisp if node is unavailable.
  (setq http-client-script-engine 'js)
  ;; grpcurl path — on macOS via Homebrew
  (setq http-client-grpcurl-bin "grpcurl")
  ;; Response window on the right, 40% width
  (setq http-client-response-window-side 'right
        http-client-response-window-size  0.4)
  (setq http-client-pretty-print-json t
        http-client-show-headers       t)
  ;; Teach Doom's popup system about the response buffer
  (set-popup-rule! "\\*http-response\\*"
    :side   'right
    :size   0.4
    :select nil
    :quit   t
    :ttl    nil))
