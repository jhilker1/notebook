(setq user-emacs-directory (file-truename "./.emacs.d/"))

(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))
(straight-use-package 'use-package)
(setq straight-use-package-by-default t)

(use-package ox-plumhtml
  :straight (:host github :repo "C-xC-c/ox-plumhtml"))

(use-package esxml
  :straight (:host github :repo "tali713/esxml":pin "701ccc285f3748d94c12f85636fecaa88858c178"))

(use-package ox-tailwind
  :straight (:host github :repo "vascoferreira25/ox-tailwind"))

(defun get-article-output-path (org-file pub-dir)
  (let ((article-dir (concat pub-dir
                             (downcase
                              (file-name-as-directory
                               (file-name-sans-extension
                                (file-name-nondirectory org-file)))))))

    (if (string-match "\\/index.org$" org-file)
        pub-dir
      (progn
        (unless (file-directory-p article-dir)
          (make-directory article-dir t))
        article-dir))))

(defun jh/org-html-template (content info)
  (concat
   (sxml-to-xml
    `(html
      (head
       (link (@ (href "/css/mvp.css")
                (rel "stylesheet")))
       (title ,(concat (org-export-data (plist-get info :title) info) " - Jacob's Notebook")))
      (body
       (main
        ,(when (plist-get info :with-title)
           (sxml-to-xml
              `(h1 ,(org-export-data (plist-get info :title) info))))
        ,content))))))



(org-export-define-derived-backend
 'site-html 'plumhtml
 :translate-alist
 '((template . jh/org-html-template)))


(defun org-html-publish-to-html (plist filename pub-dir)
  "Publish an org file to HTML, using the FILENAME as the output directory."
  (let ((article-path (get-article-output-path filename pub-dir)))
    (cl-letf (((symbol-function 'org-export-output-file-name)
               (lambda (extension &optional subtreep pub-dir)
                 (concat article-path "index" extension))))
      (org-publish-org-to 'site-html
                          filename
                          (concat "." (or (plist-get plist :html-extension)
                                          "html"))
                          plist
                          article-path))))

