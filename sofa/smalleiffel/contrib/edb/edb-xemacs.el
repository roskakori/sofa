;; ======================================================================
;; SmallEiffel debugger on GDB on Xemacs-21.
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
;;
;;  Histrory
;;     Aug 28 1997  Original emacs version
;;     May    2000  Xemacs-21.x
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;        

(require 'gud)
(require 'gud-patch)

(defvar old-edb-buffer-instance nil)

(require 'gud-edb)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;        
;; Replacement of gud-edb functions
;;
(defun gud-edb-marker-filter (string)
  "A gud marker filter for edb."
  ;; Bogons don't tell us the process except through scoping crud.
  (let ((instance (edb-proc->instance proc)))
     (gud-edb-output-filter (edb-output-burst instance string))))

(defun edb-send (proc string)
  "A comint send filter for edb.
This filter may simply queue output for a later time."
  (let ((instance (edb-proc->instance proc)))
    (gud-edb-input-filter string)
    (edb-instance-enqueue-input instance (concat string "\n"))))

(defun edb (command-line)
  "Run edb on program FILE in buffer *gud-FILE*.
The directory containing FILE becomes the initial working directory
and source-file directory for your debugger."
  (interactive
   (list (read-shell-command "Run edb (like this): "
			       (if (consp gud-edb-history)
				   (car gud-edb-history)
				 "gdb ")
			       '(gud-edb-history . 1))))
  (gud-overload-functions
   '((gud-massage-args . gud-edb-massage-args)
     (gud-marker-filter . gud-edb-marker-filter)
     (gud-find-file . gud-edb-find-file)
     ))

  (let* ((words (gud-chop-words command-line))
	 (program (car words))
	 (file-word (let ((w (cdr words)))
		      (while (and w (= ?- (aref (car w) 0)))
			(setq w (cdr w)))
		      (car w)))
	 (args (delq file-word (cdr words)))
	 (file (and file-word (expand-file-name file-word)))
	 (filepart (if file (file-name-nondirectory file) ""))
	 (buffer-name (concat "*" "edb"
			      (and (string< "" filepart) 
				   (concat "-" filepart)) "*")))
    (setq edb-first-time (not (get-buffer-process buffer-name))))

  (gud-common-init command-line "gdb")

  (gud-def gud-break  "break %f:%l"  "\C-b" "Set breakpoint at current line.")
  (gud-def gud-tbreak "tbreak %f:%l" "\C-t" "Set breakpoint at current line.")
  (gud-def gud-remove "clear %l"     "\C-d" "Remove breakpoint at current line")
  (gud-def gud-kill   "kill"	     nil    "Kill the program.")
  (gud-def gud-run    "run"	     nil    "Run the program.")
  (gud-def gud-stepi  "stepi %p"     "\C-i" "Step one instruction with display.")
  (gud-def gud-step   "step %p"      "\C-s" "Step one source line with display.")
  (gud-def gud-next   "next %p"      "\C-n" "Step one line (skip functions).")
  (gud-def gud-finish "finish"       "\C-f" "Finish executing current function.")
  (gud-def gud-cont   "cont"         "\C-r" "Continue with display.")
  (gud-def gud-up     "up %p"        "<" "Up N stack frames (numeric arg).")
  (gud-def gud-down   "down %p"      ">" "Down N stack frames (numeric arg).")
  (gud-def gud-print  "print %e"     "\C-p" "Evaluate C expression at point.")

  (setq comint-prompt-regexp "^(.*gdb[+]?) *")
  (setq comint-input-sender 'edb-send)
  (run-hooks 'edb-mode-hook)
  (let ((instance
	 (make-edb-instance (get-buffer-process (current-buffer)))
	 ))
    (when edb-first-time
      (edb-clear-inferior-io instance)
      (edb-instance-enqueue-input instance "set height 1000\n")
      (edb-instance-enqueue-input instance "set width 1000\n")
      ))
  )


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Edb i/o filter

;;; Trace for debugging
(defvar *edb-trace-buffer* nil)

(defun edb-trace-on ()
  (setq *edb-trace-buffer* (get-buffer-create "edb-trace")))

(defun edb-trace-off ()
  (setq *edb-trace-buffer* nil))

(defvar edb-trace-count 0)

(defun edb-trace-init ()
  (setq edb-trace-count 0))

(defun edb-trace (&rest args)
  (if *edb-trace-buffer*
      (save-excursion
	(set-buffer *edb-trace-buffer*)
	(goto-char (point-max))
	(insert (format "\n%d: " (setq edb-trace-count (+ edb-trace-count 1))))
	(insert (apply #'format args))
	)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Global varirables to save status. 

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
  (if edb-query-state
      (edb-trace "||%s||" input)
      (when (string-match "^ *p +\\([$A-Za-z_][.0-9A-Z_a-z]*\\)$" input)
	(edb-trace-init)
	(edb-trace "<<1 |%s|<<" input)
	(setq edb-print-var-orig (matched-string input 1))
	(setq edb-print-var-seq (reverse (split-string-at-dot edb-print-var-orig)))
	(setq edb-last-print-var nil)
	(setq edb-print-var (car edb-print-var-seq))
	(setq edb-print-var-seq (cdr edb-print-var-seq))
	(setq edb-target-var nil)
	(setq edb-target-cid nil)
	(setq edb-query-state 'INIT)
	)))

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
  (when edb-query-state
    (setq str (gud-edb-print-filter (concat last_str str)))
    )
  str)

(defun gud-edb-print-filter (str)
    (setq last_str "")
    (cond 
     ((string-match "\n" str)
      (edb-trace "----A <%s>" str)
      (setq str (gud-edb-print-filter-switch str))
      (edb-trace "----B <%s>" str)
      )
     (t (setq last_str str) (setq str "")))
    str)

(defun gud-edb-print-filter-switch (str)
  (edb-trace "%s %s %s <<<|%s|" edb-query-state edb-print-var edb-print-var-seq str)
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
    (edb-trace "%s |%s|<%s>" new-query str edb-target-var)
    (cond (new-query
	    (edb-send proc (concat "p " new-query ))
	    ""
	    )
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
	  "" 
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
	   "" 
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
;	   "" 
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
;	   "" 
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
;	   "" 
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
	(t (setq edb-query-state nil)
	   "" 
	   )
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
	   "" 
	   )

	)
  )

(provide 'edb)
