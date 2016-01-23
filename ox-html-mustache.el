;;; ox-html-mustache.el --- Mustache Back-End for Org Export Engine -*- lexical-binding: t; -*-

;; Copyright (C) 2016  Jonas Palm

;; Author: Jonas Palm
;; Keywords: org

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This library implements a Mustache back-end, derived from the HTML
;; one. The export function requires an option to specify which
;; Mustache template to use.

;;; Code:

(require 'ox-html)
(require 'mustache)

(setq org-mustache-export-attrs '(("author" :author)
                                  ("email" :email)
                                  ("date" :date)
                                  ("title" :title)))

(org-export-define-derived-backend 'mustache 'html
  :menu-entry
  '(?h 1
       ((?m "As HTML file (Mustache)" org-html-mustache-export-to-html)
        (?M "As HTML file and open (Mustache)"
            (lambda (a s v b)
              (if a (org-html-mustache-export-to-html t s v b)
                (org-open-file (org-html-mustache-export-to-html nil s v b)))))))

  :options-alist
  '((:mustache-template-file "MUSTACHE_TEMPLATE" nil org-mustache-template-file t))
  
  :translate-alist
  '((template . org-mustache-template)))

(defcustom org-mustache-template-file nil
  "Mustache template file."
  :group 'org-export-mustache
  :type 'string)

(defun mh/hash-from-info (info)
  (let* ((result (make-hash-table :test 'equal)))
    (dolist (attr org-mustache-export-attrs)
      (puthash (car attr)
               (org-export-data (plist-get info (car (cdr attr))) info)
               result))
    result))

(defun org-mustache-template (contents info)
  (let ((context (mh/hash-from-info info))
        (template-string (with-temp-buffer
                           (insert-file-contents
                            (plist-get info :mustache-template-file))
                           (buffer-string))))
    (puthash "content" contents context)
    (mustache-render template-string context)))

(defun org-html-mustache-export-to-html
    (&optional async subtreep visible-only body-only ext-plist)
  (interactive)
  (let* ((extension (concat "." org-html-extension))
         (file (org-export-output-file-name extension subtreep)))
    (org-export-to-file 'mustache file
      async subtreep visible-only body-only ext-plist)))

(provide 'ox-html-mustache)

;;; ox-html-mustache.el ends here

