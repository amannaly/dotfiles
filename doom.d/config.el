;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "John Doe"
      user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
 (setq doom-font (font-spec :family "Fira Code" :size 16 :weight 'semi-light)
      doom-variable-pitch-font (font-spec :family "Fira Code" :size 16))
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
;; (setq doom-font (font-spec :family "monospace" :size 12 :weight 'semi-light)
;;       doom-variable-pitch-font (font-spec :family "sans" :size 13))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-solarized-dark)

; In macOS we cannot symlink to Google drive sync directory.
(setq local-org-directory
      (if (file-directory-p "/Volumes/GoogleDrive/My Drive/org")
          "/Volumes/GoogleDrive/My Drive/org"
        "~/org"))

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'relative)



;; Here are some additional functions/macros that could help you configure Doom:
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
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.


;; map SPC s r to org-rifle
(map! :after org
      :map org-mode-map
      :leader
      :prefix ("s" . "+search")
      :desc "Rifle agenda files" "r" #'helm-org-rifle-agenda-files)


;; add CREATED property to an entry with the current timestamp.
;; copied from https://emacs.stackexchange.com/a/21302
(defvar org-created-property-name "CREATED"
  "The name of the org mode property that stores the creation date of the entry.")

(defun org-set-created-property (&optional active NAME)
  "Set a property on the entry giving the creation time.
By default the property is called CREATED. If given the `NAME'
argument will be used instead. If the property already exists, it
will not be modified."
  (interactive)
  (let* ((created (or NAME org-created-property-name))
         (fmt (if active "<%s>" "[%s]"))
         (now  (format fmt (format-time-string "%Y-%m-%d %a %H:%M"))))
    (unless (org-entry-get (point) created nil)
      (org-set-property created now))))

(map! :after org
      :map org-mode-map
      :leader
      :prefix ("i" . "+insert")
      :desc "insert a CREATED property" "p" #'org-set-created-property)
;; end CREATED property


;; copied from https://zzamboni.org/post/beautifying-org-mode-in-emacs/
(custom-theme-set-faces
 'user
 '(org-drawer ((t (:inherit (shadow fixed-pitch) :weight normal :height 0.8))))
 '(org-special-keyword ((t (:inherit (shadow fixed-pitch) :weight normal :height 0.8))))
 '(org-property-value ((t (:inherit (shadow fixed-pitch) :weight normal :height 0.8))))
 )

(after! org
  (setq
   org-hide-emphasis-markers t
   org-ellipsis " ... "
   org-agenda-files (directory-files-recursively "~/org/" "\\.org$")
   org-todo-keywords '((sequence "TODO(t)" "INPROGRESS(w)" "|" "DONE(d)" "CANCELLED(c)"))


   ;; org-refile
   ;; from https://blog.aaronbieber.com/2017/03/19/organizing-notes-with-refile.html
   ;; refile targets should be all agenda-files
   org-refile-targets '((org-agenda-files :maxlevel . 3))
   ;; also show file names for top-level refile.
   org-refile-use-outline-path 'file
   org-outline-path-complete-in-steps nil

   org-refile-allow-creating-parent-nodes 'confirm

   ;; all done tasks should be archived to archive.org
   org-archive-location "~/org/archive.org::"

   org-log-done t
   )
  ;; multiline emphasis
  (setcar (nthcdr 4 org-emphasis-regexp-components) 100)
  (org-set-emph-re 'org-emphasis-regexp-components org-emphasis-regexp-components)

  ; turn on flyspell for spell checks.
  (add-hook 'org-mode-hook 'turn-on-flyspell)
  )

(add-hook 'org-mode-hook 'turn-on-auto-fill)
(setq-default fill-column 100)

;; maximize window on startup
(add-hook 'window-setup-hook #'toggle-frame-maximized)

;; ss saves buffer.
(map! :map evil-normal-state-map
      "B" #'evil-first-non-blank
      "E" #'evil-last-non-blank
      ; s is mapped to evil-substitue. remove that so that i can map ss to write
      "s" nil
      "ss" #'evil-write)

; from https://stackoverflow.com/a/619525
; insert time in HH:MM format
(defun now ()
  "Insert string for the current time formatted like '2:34'."
  (interactive)                 ; permit invocation in minibuffer
  (insert (format-time-string "%H:%M")))
;; map SPC t i to now()
(map! :after org
      :map org-mode-map
      :leader
      :prefix ("i" . "+toggle")
      :desc "Insert current time" "t" #'now)
; duration in minutes. Used in daily activity table.
(setq org-table-duration-custom-format (quote hh:mm))

; change the format of org headings.
; From https://hugocisneros.com/org-config/
(defun my/set-specific-faces-org ()
   (set-face-attribute 'org-code nil
                       :inherit '(shadow fixed-pitch))
   ;; Without indentation the headlines need to be different to be visible
   (set-face-attribute 'org-level-1 nil
                       :height 1.25
                       :foreground "#BEA4DB")
   (set-face-attribute 'org-level-2 nil
                       :height 1.15
                       :foreground "#A382FF"
                       :slant 'italic)
   (set-face-attribute 'org-level-3 nil
                       :height 1.1
                       :foreground "#5E65CC"
                       :slant 'italic)
   (set-face-attribute 'org-level-4 nil
                       :height 1.05
                       :foreground "#ABABFF")
   (set-face-attribute 'org-level-5 nil
                       :foreground "#2843FB")
   (set-face-attribute 'org-date nil
                       :foreground "#ECBE7B"
                       :height 0.8)
   (set-face-attribute 'org-document-title nil
                       :foreground "DarkOrange3"
                       :height 1.3)
   (set-face-attribute 'org-ellipsis nil
                       :foreground "#4f747a" :underline nil)
   (set-face-attribute 'variable-pitch nil
                       :family "Roboto Slab" :height 1.2))

(add-hook 'org-mode-hook 'my/set-specific-faces-org)


;; don't ask for confirmation with quitting.
(setq confirm-kill-emacs nil)
