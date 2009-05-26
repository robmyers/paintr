;; paintr-rss.lisp -  RSS feed generation for paintr.
;; Copyright (C) 2009  Rob Myers rob@robmyers.org
;;
;; This file is part of paintr.
;;
;; paintr is free software; you can redistribute it and/or 
;; modify it under the terms of the GNU General Public License as published 
;; by the Free Software Foundation; either version 3 of the License, or
;; (at your option) any later version.
;;
;; paintr is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;; TODO - Set base url in configuration.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defvar *item-count* 5)

(defvar *paintr-web-path* "./")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Templates
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Encoding is to handle high byte characters in names from flickr

(defparameter +rss-header+ "<?xml version=\"1.0\" encoding=\"iso-8859-1\"?>
<rss version=\"2.0\">
  <channel>
    <title>paintr</title>
    <link>http://www.robmyers.org/paintr/</link>
    <description>Images by paintr.</description>
    <language>en</language>
")

(defparameter +rss-footer+ "  </channel>
</rss>
")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; RSS Generation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun current-id-file-path ()
  "Generate the full local filesystem path to the current id file"
  (format nil "~a/current-id" *paintr-directory-path*))

(defun rss-file-path ()
  "Generate the full local filesystem path to the rss file"
  (format nil "~a/rss.xml" *paintr-directory-path*))

(defun html-file-path (id)
  "Generate the full local filesystem path to the html file for the id"
  (format nil "~a/~a.html" *paintr-directory-path* id))

(defun read-current-id ()
  "Get the current id"
  (with-open-file (id-file (current-id-file-path))
    (read id-file)))

(defun slurp-file (file-path)
  "Slurp the contents of the file into a string"
  (with-open-file (file file-path)
    (let ((text (make-string (file-length file))))
      (read-sequence text file)
      text)))

(defun write-item (stream id)
  "Write the item entry for the id"
  (format stream "   <item>
      <title>paintr image ~a</title>
      <link>http://www.robmyers.org/paintr/index.php?image=~a</link>
      <guid>http://www.robmyers.org/paintr/index.php?image=~a</guid>
      <description><![CDATA[<p><a href=\"http://www.robmyers.org/paintr/index.php?image=~a\">paintr image ~a</a></p>~a]]></description>
    </item>
" id id id id id (slurp-file (html-file-path id))))

(defun write-items (stream current-id)
  "Write the items for the RSS"
  (let ((count (min current-id *item-count*)))
    (dotimes (i count)
      (let ((id (- current-id i)))
	(write-item stream id)))))

(defun generate-rss ()
  "Generate a simple rss feed for the most recent items."
  (with-open-file (file (rss-file-path) 
			:direction :output :if-exists :supersede)
    (format file +rss-header+)
    (write-items file (read-current-id))
    (format file +rss-footer+)))