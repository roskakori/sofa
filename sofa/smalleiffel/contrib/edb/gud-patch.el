;;;
;;; Replace gud bauggy functions in emacs21.2
;;;

(defun gud-format-command (str arg)
  (let ((insource (not (eq (current-buffer) gud-comint-buffer))))
    (if (string-match "\\(.*\\)%f\\(.*\\)" str)
	(setq str (concat
		   (substring str (match-beginning 1) (match-end 1))
		   (file-name-nondirectory (if insource
					       (buffer-file-name)
					     (car gud-last-frame)))
		   (substring str (match-beginning 2) (match-end 2)))))
    (if (string-match "\\(.*\\)%d\\(.*\\)" str)
	(setq str (concat
		   (substring str (match-beginning 1) (match-end 1))
		   (file-name-directory (if insource
					    (buffer-file-name)
					  (car gud-last-frame)))
		   (substring str (match-beginning 2) (match-end 2)))))
    (if (string-match "\\(.*\\)%l\\(.*\\)" str)
	(setq str (concat
		   (substring str (match-beginning 1) (match-end 1))
		   (if insource
		       (save-excursion
			 (beginning-of-line)
			 (int-to-string (save-restriction (widen)
					   (1+ (count-lines 1 (point))))))
		     (cdr gud-last-frame))
		   (substring str (match-beginning 2) (match-end 2)))))
    (if (string-match "\\(.*\\)%e\\(.*\\)" str)
	(setq str (concat
		   (substring str (match-beginning 1) (match-end 1))
		   (find-c-expr)
		   (substring str (match-beginning 2) (match-end 2)))))
    (if (string-match "\\(.*\\)%a\\(.*\\)" str)
	(setq str (concat
		   (substring str (match-beginning 1) (match-end 1))
		   (gud-read-address)
		   (substring str (match-beginning 2) (match-end 2)))))
    (if (string-match "\\(.*\\)%p\\(.*\\)" str)
	(setq str (concat
		   (substring str (match-beginning 1) (match-end 1))
		   (if arg (int-to-string arg) "")
		   (substring str (match-beginning 2) (match-end 2)))))
    )
  str
  )

(provide 'gud-patch)
