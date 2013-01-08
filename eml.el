;;;; eml.el is an acronym Emacs-lisp Markup Language
;;;;
;;;; Author: Zhang, Zepeng (Joe) <redraiment@gmail.com>
;;;; Time-stamp: <2012-12-27 CST>
;;;; Copyright: (C) 2012 Zhang, Zepeng (Joe)
;;;;
;;;; This program is free software; you can redistribute it and/or
;;;; modify it under the terms of the GNU General Public License as
;;;; published by the Free Software Foundation; either version 2, or (at
;;;; your option) any later version.
;;;;
;;;; This program is distributed in the hope that it will be useful, but
;;;; WITHOUT ANY WARRANTY; without even the implied warranty of
;;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;;;; General Public License for more details.
;;;;
;;;; You should have received a copy of the GNU General Public License
;;;; along with this program ; see the file COPYING.  If not, write to
;;;; the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;;;; Boston, MA 02111-1307, USA.

(require 'cl)

;;; Escape
(defconst eml-escape-characters
  '(("&" . "&amp;")
    ("'" . "&apos;")
    ("\"" . "&quot;")
    ("<" . "&lt;")
    (">" . "&gt;")
    (" " . "&nbsp;"))
  "List of (from . to) pairs for escaping.")

(defun eml-escape-encode (content)
  "Escape CONTENT for inclusion in some XML."
  (reduce
   #'(lambda (s alist)
       (replace-regexp-in-string (car alist) (cdr alist) s))
   eml-escape-characters
   :initial-value content))

(defun eml-escape-decode (content)
  "Decode the escape characters in CONTENT."
  (reduce
   #'(lambda (s alist)
       (replace-regexp-in-string (cdr alist) (car alist) s))
   (reverse eml-escape-characters)
   :initial-value content))

;;; Attribute
(defun eml-attribute-p (alist)
  "Predicate for XML attributs.
Accept Cons Cell (key . value) type only, and the value MUSTN't be nil."
  (and (consp alist)
       (atom (car alist))
       (not (listp (cdr alist)))))

(defun eml-attribute-encode (alist)
  "Convert an Association List to xml style attribute."
  (format "%s=\"%s\"" (car alist) (or (cdr alist) (car alist) "")))

;;; main
(defun eml (sexp)
  "Convert a S-EXP to XML string.
'(root (person (name . Joe) (skill elisp)))
=>
<root><person name=\"Joe\"><skill>elisp</skill></person></root>

S-EXP could contain script-let (`<%' and `%>', `<%=' and `%>')
followed by a Lisp expression used as part of the content.
The result of expressions that inside of `<%=' and `%>' will
insert into content, which the output of expressions that inside
of `<%' and `%>' will be inserted.

'(root (name <% (princ \"Joe\") %>) (age <%= 23 %>))
=>
<root><name>Joe</name><age>23</age></root>"
  (let ((tag (format "%s" (car sexp)))
        (attr ())
        (children ())
        (value-content? nil)
        (eval-content? nil))
    (dolist (e (cdr sexp))
      (cond
       ((eq e '%>)
        (setq value-content? nil
              eval-content? nil))
       ((eq e '<%)
        (setq eval-content? t))
       ((eq e '<%=)
        (setq value-content? t))
       (eval-content?
        (push (with-output-to-string (eval e)) children))
       (value-content?
        (push (format "%s" (eval e)) children))
       ((eml-attribute-p e)
        (push (eml-attribute-encode e) attr))
       ((consp e)
        (push (eml e) children))
       (t
        (push (format "%s" (or e "")) children))))
    (format "<%s%s%s>"
            tag
            (mapconcat (lambda (s) (concat " " s)) (nreverse attr) "")
            (if children
              (format ">%s</%s" (apply #'concat (nreverse children)) tag)
              " /"))))

(provide 'eml)
