(require 'gud)
;; ======================================================================
;; SmallEiffel debugger on GDB. (For Emacs 20.x)
;;
;;  Aug 28 1997 M.Mogaki
;;            mmogaki@kanagawa.hitachi.co.jp
;;
;;  print local variable and class attribute with `p' comand.
;;
;;; Alogorithm outline.
;;   1)  if command like "p x" is typed,
;;       try command "p _x" and "p C._x" to obtain reasonable printing.
;;   2)  If it is a pointer to some object, gdb will prints as follows.
;;         $1 = (T0 *) 0x40000000
;;   3) Try command "p *$1" to obtain class id of this.
;;        Gdb will print as follows.
;;         $2 = {id = 7 }
;;   4) Now we can try comand "p *(T7*)$1" to obtain desired printing
;;         $3 = {id = 7 , _count = 5, _capacity = 7, _strage = 0x40000016 "STRING" }
;;   5) In case of dot notation like x.count,
;;        split them into word like (x count).
;;        apply 1~3 to obtain the class id of x.
;;        Once class of x is known, we can try command 
;;        "p ((T7*)$3)._count"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;        
;;; History of argument lists passed to edb.
(defvar gud-edb-history nil)

(defvar gud-edb-directories nil
  "*A list of directories that edb should search for source code.
If nil, only source files in the program directory
will be known to edb.

The file names should be absolute, or relative to the directory
containing the executable being debugged.")

(defun gud-edb-massage-args (file args)
  (cons "-fullname" args))

(defvar gud-edb-marker-regexp
  (concat "\032\032\\([^" path-separator "\n]*\\)" path-separator
	  "\\([0-9]*\\)" path-separator ".*\n"))

;; There's no guarantee that Emacs will hand the filter the entire
;; marker at once; it could be broken up across several strings.  We
;; might even receive a big chunk with several markers in it.  If we
;; receive a chunk of text which looks like it might contain the
;; beginning of a marker, we save it here between calls to the
;; filter.
(defvar gud-marker-acc "")
(make-variable-buffer-local 'gud-marker-acc)

(defun gud-edb-marker-filter (string)
  (setq gud-marker-acc (concat gud-marker-acc string))
  (let ((output ""))

    ;; Process all the complete markers in this chunk.
    (while (string-match gud-edb-marker-regexp gud-marker-acc)
      (setq

       ;; Extract the frame position from the marker.
       gud-last-frame
       (cons (substring gud-marker-acc (match-beginning 1) (match-end 1))
	     (string-to-int (substring gud-marker-acc
				       (match-beginning 2)
				       (match-end 2))))

       ;; Append any text before the marker to the output we're going
       ;; to return - we don't include the marker in this text.
       output (concat output
		      (substring gud-marker-acc 0 (match-beginning 0)))

       ;; Set the accumulator to the remaining text.
       gud-marker-acc (substring gud-marker-acc (match-end 0))))

    ;; Does the remaining text look like it might end with the
    ;; beginning of another marker?  If it does, then keep it in
    ;; gud-marker-acc until we receive the rest of it.  Since we
    ;; know the full marker regexp above failed, it's pretty simple to
    ;; test for marker starts.
    (if (string-match "\032.*\\'" gud-marker-acc)
	(progn
	  ;; Everything before the potential marker start can be output.
	  (setq output (concat output (substring gud-marker-acc
						 0 (match-beginning 0))))

	  ;; Everything after, we save, to combine with later input.
	  (setq gud-marker-acc
		(substring gud-marker-acc (match-beginning 0))))

      (setq output (concat output gud-marker-acc)
	    gud-marker-acc ""))

    (gud-edb-output-filter (or output ""))))

(defun gud-new-keymap (map)
  "Return a new keymap which inherits from MAP and has name `Gud'."
  (nconc (make-sparse-keymap "Gud") map))

(defun gud-make-debug-menu ()
  "Make sure the current local map has a [menu-bar debug] submap.
If it doesn't, replace it with a new map that inherits it,
and create such a submap in that new map."
  (if (and (current-local-map)
	   (lookup-key (current-local-map) [menu-bar debug]))
      nil
    (use-local-map (gud-new-keymap (current-local-map)))
    (define-key (current-local-map) [menu-bar debug]
      (cons "Gud" (gud-new-keymap gud-menu-map)))))

(defun gud-edb-find-file (f)
  (save-excursion
    (let ((buf (find-file-noselect f)))
      (set-buffer buf)
      (gud-make-debug-menu)
      (local-set-key [menu-bar debug tbreak]
		     '("Temporary Breakpoint" . gud-tbreak))
      (local-set-key [menu-bar debug finish] '("Finish Function" . gud-finish))
      (local-set-key [menu-bar debug up] '("Up Stack" . gud-up))
      (local-set-key [menu-bar debug down] '("Down Stack" . gud-down))
      buf)))

(defvar edb-minibuffer-local-map nil
  "Keymap for minibuffer prompting of edb startup command.")
(if edb-minibuffer-local-map
    ()
  (setq edb-minibuffer-local-map (copy-keymap minibuffer-local-map))
  (define-key
    edb-minibuffer-local-map "\C-i" 'comint-dynamic-complete-filename))

;;;###autoload
(defun edb (command-line)
  "Run edb on program FILE in buffer *gud-FILE*.
The directory containing FILE becomes the initial working directory
and source-file directory for your debugger."
  (interactive
   (list (read-from-minibuffer "Run edb (like this): "
			       (if (consp gud-edb-history)
				   (car gud-edb-history)
				 "gdb ")
			       edb-minibuffer-local-map nil
			       '(gud-edb-history . 1))))

  (gud-common-init command-line 'gud-edb-massage-args
		   'gud-edb-marker-filter 'gud-edb-find-file)

  (add-hook 'comint-input-filter-functions  'gud-edb-input-filter)

  (gud-def gud-break  "break %f:%l"  "\C-b" "Set breakpoint at current line.")
  (gud-def gud-tbreak "tbreak %f:%l" "\C-t" "Set temporary breakpoint at current line.")
  (gud-def gud-remove "clear %f:%l"  "\C-d" "Remove breakpoint at current line")
  (gud-def gud-step   "step %p"      "\C-s" "Step one source line with display.")
  (gud-def gud-stepi  "stepi %p"     "\C-i" "Step one instruction with display.")
  (gud-def gud-next   "next %p"      "\C-n" "Step one line (skip functions).")
  (gud-def gud-cont   "cont"         "\C-r" "Continue with display.")
  (gud-def gud-finish "finish"       "\C-f" "Finish executing current function.")
  (gud-def gud-up     "up %p"        "<" "Up N stack frames (numeric arg).")
  (gud-def gud-down   "down %p"      ">" "Down N stack frames (numeric arg).")
  (gud-def gud-print  "print %e"     "\C-p" "Evaluate C expression at point.")

  (local-set-key "\C-i" 'gud-edb-complete-command)
  (local-set-key [menu-bar debug tbreak] '("Temporary Breakpoint" . gud-tbreak))
  (local-set-key [menu-bar debug finish] '("Finish Function" . gud-finish))
  (local-set-key [menu-bar debug up] '("Up Stack" . gud-up))
  (local-set-key [menu-bar debug down] '("Down Stack" . gud-down))
  (setq comint-prompt-regexp "^(.*gdb[+]?) *")
  (setq paragraph-start comint-prompt-regexp)
  (run-hooks 'edb-mode-hook)
  )

;; One of the nice features of EDB is its impressive support for
;; context-sensitive command completion.  We preserve that feature
;; in the GUD buffer by using a EDB command designed just for Emacs.

;; The completion process filter indicates when it is finished.
(defvar gud-edb-complete-in-progress)

;; Since output may arrive in fragments we accumulate partials strings here.
(defvar gud-edb-complete-string)

;; We need to know how much of the completion to chop off.
(defvar gud-edb-complete-break)

;; The completion list is constructed by the process filter.
(defvar gud-edb-complete-list)

(defvar gud-comint-buffer nil)

(defun gud-edb-complete-command ()
  "Perform completion on the EDB command preceding point.
This is implemented using the EDB `complete' command which isn't
available with older versions of EDB."
  (interactive)
  (let* ((end (point))
	 (command (save-excursion
		    (beginning-of-line)
		    (and (looking-at comint-prompt-regexp)
			 (goto-char (match-end 0)))
		    (buffer-substring (point) end)))
	 command-word)
    ;; Find the word break.  This match will always succeed.
    (string-match "\\(\\`\\| \\)\\([^ ]*\\)\\'" command)
    (setq gud-edb-complete-break (match-beginning 2)
	  command-word (substring command gud-edb-complete-break))
    ;; Temporarily install our filter function.
    (let ((gud-marker-filter 'gud-edb-complete-filter))
      ;; Issue the command to EDB.
      (gud-basic-call (concat "complete " command))
      (setq gud-edb-complete-in-progress t
	    gud-edb-complete-string nil
	    gud-edb-complete-list nil)
      ;; Slurp the output.
      (while gud-edb-complete-in-progress
	(accept-process-output (get-buffer-process gud-comint-buffer))))
    ;; Protect against old versions of EDB.
    (and gud-edb-complete-list
	 (string-match "^Undefined command: \"complete\""
		       (car gud-edb-complete-list))
	 (error "This version of EDB doesn't support the `complete' command."))
    ;; Sort the list like readline.
    (setq gud-edb-complete-list
	  (sort gud-edb-complete-list (function string-lessp)))
    ;; Remove duplicates.
    (let ((first gud-edb-complete-list)
	  (second (cdr gud-edb-complete-list)))
      (while second
	(if (string-equal (car first) (car second))
	    (setcdr first (setq second (cdr second)))
	  (setq first second
		second (cdr second)))))
    ;; Add a trailing single quote if there is a unique completion
    ;; and it contains an odd number of unquoted single quotes.
    (and (= (length gud-edb-complete-list) 1)
	 (let ((str (car gud-edb-complete-list))
	       (pos 0)
	       (count 0))
	   (while (string-match "\\([^'\\]\\|\\\\'\\)*'" str pos)
	     (setq count (1+ count)
		   pos (match-end 0)))
	   (and (= (mod count 2) 1)
		(setq gud-edb-complete-list (list (concat str "'"))))))
    ;; Let comint handle the rest.
    (comint-dynamic-simple-complete command-word gud-edb-complete-list)))
    
;; The completion process filter is installed temporarily to slurp the
;; output of EDB up to the next prompt and build the completion list.
(defun gud-edb-complete-filter (string)
  (setq string (concat gud-edb-complete-string string))
  (while (string-match "\n" string)
    (setq gud-edb-complete-list
	  (cons (substring string gud-edb-complete-break (match-beginning 0))
		gud-edb-complete-list))
    (setq string (substring string (match-end 0))))
  (if (string-match comint-prompt-regexp string)
      (progn
	(setq gud-edb-complete-in-progress nil)
	string)
    (progn
      (setq gud-edb-complete-string string)
      "")))



(defvar edb-query-state nil)

(defvar edb-print-var-orig nil)
(defvar edb-print-var-seq nil)
(defvar edb-last-print-var nil)
(defvar edb-print-var nil)
(defvar edb-print-var-seq nil)
(defvar edb-target-var nil)
(defvar edb-target-cid nil)

(defun matched-string (str at)
  (substring str (match-beginning at) (match-end at)))

;;
;;  User input: p x.y
;;  			                (sate,target,var,rest)	command
;;  (INIT,"",x,(y))
;;     when No symbol "x" in current context
;;      --> is it local var? 		--> (LOCAL,"",x,(y))	p _x
;;     when Threre is no member named ...
;;      --> check type of x 		--> (TYPE,x,y,())	p *(T0*)x
;;     when $x = (Txx*)0x40....
;;      --> reference			--> (TYPE,$x,"",())	p *(T0*)$x
;;     when $x = Something else
;;      --> Result.			--> (nil,x.y,*)		""
;;
;;  (LOCAL,"",x,(y)) p _x
;;     when No symbol "_x" in current context
;;      --> try C._x			--> (ATTR,"",x,(y))	p C._x
;;     when $x = (Txx*)0x40....
;;      --> known type reference	--> (TYPE,$x,x,(y))	p *(T0*)$x
;;     when $x = Something else
;;      --> Result.			--> (nil)		""
;;
;;  (ATTR,"",x,(y))
;;     when Threre is no member named ...
;;      --> try feature call of Current --> (CTYPE,"C",x,(y))	p "*C"
;;     when $x = (Txx*)0x40......
;;      --> known type reference	--> (TYPE,$x,x,(y))	p *(T0*)$x
;;     when $x = Something else
;;      --> Result.			--> (nil)		""
;;
;;  (CTYPE)
;;     when $1 = {id=???}
;;;	--> try feature call of target -->(FCALL,$x,x,(y))	p rT???x($x)
;;     othewise
;;
;;  (FCALL)
;;     when $x = (Txx*)0x40......
;;      --> known type reference	--> (TYPE,$x,x,(y))	p *(T0*)$x
;;     when $x = Something else
;;      --> Result.			--> (nil)		""
;;
;;  (TYPE) p *(T0*)$x
;;      when $y = {$id=???}
;;        if more quorifier		-->(VALUE,$x,y,())	p ((Txx*)$x)._y
;;        if no more quorifier		-->(VALUE,$x,x,())	p *(Txx*)$x
;;
;;  (VALUE)
;;     when Threre is no member named ...
;;      --> try feature call		--> (FCALL,$x,x,(y))	p rT???x($x)
;;     when $x = (Txx*)0x40......
;;      --> known type reference	--> (TYPE,$x,x,(y))	p *(T0*)$x
;;     when $x = Something else
;;      --> Result.			--> (nil)		""
;;

(defun gud-edb-input-filter (input)
  (when (and (null edb-query-state)
	     (string-match "p +\\([$A-Za-z_][.0-9A-Z_a-z]*\\)$" input))
    (message "<<1 |%s|<<" input)
    (setq edb-print-var-orig (matched-string input 1))
    (setq edb-print-var-seq (reverse (split-string-at-dot edb-print-var-orig)))
    (setq edb-last-print-var nil)
    (setq edb-print-var (car edb-print-var-seq))
    (setq edb-print-var-seq (cdr edb-print-var-seq))
    (setq edb-target-var nil)
    (setq edb-target-cid nil)
    (setq edb-query-state 'INIT)
    ))

(defun split-string-at-dot (str)
  (let ((s nil)
	(res nil)
	(from 0)
	(pos))
    (while (string-match "\\([^.]*\\)\\." str)
      (setq s (matched-string str 1))
      (setq res (cons s res))
      (setq str (substring str (+ 1 (match-end 1)))))
    (cons str res)
))


(defvar last_str "")

(defun gud-edb-output-filter (str)
  (if edb-query-state
      (gud-edb-print-filter (concat last_str str))
    str))

(defun gud-edb-print-filter (str)
    (setq last_str "")
    (cond 
     ((string-match "\n" str)
      (setq str (gud-edb-print-filter-switch str)))
     (t (setq last_str str) (setq str "")))
    str)

(defun gud-edb-print-filter-switch (str)
  (message "%s %s %s <<<|%s|" edb-query-state edb-print-var edb-print-var-seq str)
  (let ((proc (get-buffer-process gud-comint-buffer))
	(new-query
	 (cond
	  ((eq 'INIT edb-query-state)
	   (gud-edb-print-filter-INIT str))
	  ((eq 'LOCAL edb-query-state)
	   (gud-edb-print-filter-LOCAL str))
	  ((eq 'ATTR edb-query-state)
	   (gud-edb-print-filter-ATTR str))
	  ((eq 'CTYPE edb-query-state)
	   (gud-edb-print-filter-CTYPE str))
	  ((eq 'FCALL edb-query-state)
	   (gud-edb-print-filter-FCALL str))
	  ((eq 'TYPE edb-query-state)
	   (gud-edb-print-filter-TYPE str))
	  ((eq 'VALUE edb-query-state)
	   (gud-edb-print-filter-VALUE str))
	  (t nil))))

    (cond (new-query
	    (edb-send proc (concat "p " new-query "\n")))
	  ((and edb-target-var (string-match "\\$[0-9]*\\( = {id = [0-9]+, .*\\)" str))
	   (concat edb-target-var (substring str (match-beginning 1))))
	  (t str))))

	  
(defun gud-edb-print-filter-INIT (str)	
  (cond ((string-match "No symbol \"\\(.*\\)\" in current context\." str)
	 (setq edb-query-state 'LOCAL)
	 (concat "_" edb-print-var)
	 )
	((string-match "There is no member named" str)
	 (setq edb-query-state 'TYPE)
	 (setq edb-target-var edb-print-var)
	 ;(setq edb-print-var (car edb-print-var-seq))
	 ;(setq edb-print-var-seq (cdr edb-print-var-seq))
	 (concat "*(T0*)" edb-target-var)
	 )
	((string-match "\\(\\$[0-9]*\\) = \\((T[0-9]* \\*)\\) 0x[0-9a-f]*" str)
	 (setq edb-query-state 'TYPE)
	 (setq edb-target-var (matched-string str 1))
	 (setq edb-print-var "")
	 (setq edb-print-var-seq nil)
	 (concat "*" edb-target-var)
	 )
	(t (setq edb-target-var nil)
	   (setq edb-query-state nil)
	   
	)))

(defun gud-edb-print-filter-LOCAL (str)	
  (cond ((string-match "No symbol \".*\" in current context\." str)
	 (setq edb-query-state 'ATTR)
	 (concat "C._" edb-print-var))
	((string-match "\\(\\$[0-9]*\\) = \\((T[0-9]* \\*)\\) 0x[0-9a-f]*" str)
	 (setq edb-query-state 'TYPE)
	 (setq edb-target-var (matched-string str 1))
	 (concat "*(T0*)" edb-target-var)
	 )
	(t (setq edb-query-state nil)
	)
  ))

(defun gud-edb-print-filter-ATTR (str)	
  (cond 
	((string-match "There is no member named \\(.*\\)" str)
	 (setq edb-query-state 'CTYPE)
	 "*C"
	 )
	((string-match "\\(\\$[0-9]*\\) = (T[0-9]* \\*) 0x[0-9a-f]*" str)
	 (setq edb-query-state 'TYPE)
	 (setq edb-target-var (matched-string str 1))
	 (concat "*(T0*)" edb-target-var)
	 )
	(t (setq edb-query-state nil)
	   )
	)
  )


(defun gud-edb-print-filter-CTYPE (str)	
  (cond ((string-match "{id = \\([0-9]+\\)" str)
	 (setq edb-query-state 'FCALL)
	 (setq edb-target-cid (matched-string str 1))
	 (concat "rT" edb-target-cid edb-print-var "(" edb-target-var ")")
	 )
	(t (setq edb-query-state nil)
	)
  ))


(defun gud-edb-print-filter-FCALL (str)	
  (cond 
	((string-match "\\(\\$[0-9]*\\) = \\((T[0-9]* \\*)\\) 0x[0-9a-f]*" str)
	 (setq edb-query-state 'TYPE)
	 (setq edb-target-var (matched-string str 1))
	 (concat "*(T0*)" edb-target-var)
	 )
	(t (setq edb-query-state nil)
	   )
	)
  )


(defun gud-edb-print-filter-TYPE (str)	
  (cond	((string-match "{id = \\([0-9]+\\)}" str)
	 (setq edb-target-cid (matched-string str 1))
	 (cond (edb-print-var-seq
		(setq edb-query-state 'VALUE)
		(setq edb-print-var (car edb-print-var-seq))
		(setq edb-print-var-seq (cdr edb-print-var-seq))
		(concat "((T" edb-target-cid "*)" edb-target-var ")._" edb-print-var)
		)
	       (t
		(setq edb-query-state 'VALUE)
		(concat "*(T"  edb-target-cid "*)" edb-target-var)
		)))
	(t (setq edb-query-state nil))

	))

(defun gud-edb-print-filter-VALUE (str)	
  (cond 
	((string-match "There is no member named \\(.*\\)" str)
	 (setq edb-query-state 'FCALL)
	 (concat "rT" edb-target-cid edb-print-var "(" edb-target-var ")") 
	 )
	((string-match "\\(\\$[0-9]*\\) = \\((T[0-9]* \\*)\\) 0x[0-9a-f]*" str)
	 (setq edb-query-state 'TYPE)
	 (setq edb-target-var (matched-string str 1))
	 (concat "*(T0*)" edb-target-var)
	 )
	(t (setq edb-query-state nil)
	   )
	)
  )

(defun edb-send (proc str)
  (message ">>>%s>>>" str)
  (process-send-string proc str)
  ""
  )

(provide 'edb)
