;;; edb.el --- run edb under Emacs
;; ======================================================================
;; SmallEiffel debugger on GDB.
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
;;
;; Modified from gdb.el         
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;        

;; Author: W. Schelter, University of Texas
;;     wfs@rascal.ics.utexas.edu
;; Rewritten by rms.
;; Keywords: c, unix, tools, debugging

;; Some ideas are due to Masanobu.

;; This file is part of XEmacs.

;; XEmacs is free software; you can redistribute it and/or modify it
;; under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; XEmacs is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with XEmacs; see the file COPYING.  If not, write to the Free
;; Software Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
;; 02111-1307, USA.

;;; Synched up with: Not in FSF

;;; Commentary:

;; Description of EDB interface:

;; A facility is provided for the simultaneous display of the source code
;; in one window, while using edb to step through a function in the
;; other.  A small arrow in the source window, indicates the current
;; line.

;; Starting up:

;; In order to use this facility, invoke the command EDB to obtain a
;; shell window with the appropriate command bindings.  You will be asked
;; for the name of a file to run.  Edb will be invoked on this file, in a
;; window named *edb-foo* if the file is foo.

;; M-s steps by one line, and redisplays the source file and line.

;; You may easily create additional commands and bindings to interact
;; with the display.  For example to put the edb command next on \M-n
;; (def-edb next "\M-n")

;; This causes the emacs command edb-next to be defined, and runs
;; edb-display-frame after the command.

;; edb-display-frame is the basic display function.  It tries to display
;; in the other window, the file and line corresponding to the current
;; position in the edb window.  For example after a edb-step, it would
;; display the line corresponding to the position for the last step.  Or
;; if you have done a backtrace in the edb buffer, and move the cursor
;; into one of the frames, it would display the position corresponding to
;; that frame.

;; edb-display-frame is invoked automatically when a filename-and-line-number
;; appears in the output.

;;; Code:

(require 'comint)
(require 'shell)

(condition-case nil
    (if (featurep 'toolbar)
	(require 'eos-toolbar "sun-eos-toolbar"))
  (error nil))

(defvar edb-last-frame)
(defvar edb-delete-prompt-marker)
(defvar edb-filter-accumulator)
(defvar edb-last-frame-displayed-p)
(defvar edb-arrow-extent nil)
(or (fboundp 'make-glyph) (fset 'make-glyph 'identity)) ; work w/ pre beta v12
(defvar edb-arrow-glyph (make-glyph "=>"))

(make-face 'edb-arrow-face)
(or (face-differs-from-default-p 'edb-arrow-face)
   ;; Usually has a better default value than highlight does
   (copy-face 'isearch 'edb-arrow-face))

;; Hooks can side-effect extent arg to change extent properties
(defvar edb-arrow-extent-hooks '())

(defvar edb-prompt-pattern "^>\\|^(.*gdb[+]?) *\\|^---Type <return> to.*--- *"
  "A regexp to recognize the prompt for gdb or gdb+.") 

(defvar edb-mode-map nil
  "Keymap for edb-mode.")

(defvar edb-toolbar
  '([eos::toolbar-stop-at-icon
     edb-toolbar-break
     t
     "Stop at selected position"]
    [eos::toolbar-stop-in-icon
     edb-toolbar-break
     t
     "Stop in function whose name is selected"]
    [eos::toolbar-clear-at-icon
     edb-toolbar-clear
     t
     "Clear at selected position"]
    [eos::toolbar-evaluate-icon
     nil
     nil
     "Evaluate selected expression; shows in separate XEmacs frame"]
    [eos::toolbar-evaluate-star-icon
     nil
     nil
     "Evaluate selected expression as a pointer; shows in separate XEmacs frame"]
    [eos::toolbar-run-icon
     edb-run
     t
     "Run current program"]
    [eos::toolbar-cont-icon
     edb-cont
     t
     "Continue current program"]
    [eos::toolbar-step-into-icon
     edb-step
     t
     "Step into (aka step)"]
    [eos::toolbar-step-over-icon
     edb-next
     t
     "Step over (aka next)"]
    [eos::toolbar-up-icon
     edb-up
     t
     "Stack Up (towards \"cooler\" - less recently visited - frames)"]
    [eos::toolbar-down-icon
     edb-down
     t
     "Stack Down (towards \"warmer\" - more recently visited - frames)"]
    [eos::toolbar-fix-icon	nil	nil	"Fix (not available with edb)"]
    [eos::toolbar-build-icon
     toolbar-compile
     t
     "Build (aka make -NYI)"]
    ))

(if edb-mode-map
   nil
  (setq edb-mode-map (make-sparse-keymap))
  (set-keymap-name edb-mode-map 'edb-mode-map)
  (set-keymap-parents edb-mode-map (list comint-mode-map))
  (define-key edb-mode-map "\C-l" 'edb-refresh)
  (define-key edb-mode-map "\C-c\C-c" 'edb-control-c-subjob)
  (define-key edb-mode-map "\t" 'comint-dynamic-complete)
  (define-key edb-mode-map "\M-?" 'comint-dynamic-list-completions))

(define-key ctl-x-map " " 'edb-break)
(define-key ctl-x-map "&" 'send-edb-command)

;;Of course you may use `def-edb' with any other edb command, including
;;user defined ones.   

(defmacro def-edb (name key &optional doc &rest forms)
  (let* ((fun (intern (format "edb-%s" name)))
	 (cstr (list 'if '(not (= 1 arg))
		     (list 'format "%s %s" name 'arg)
		     name)))
    (list 'progn
	  (nconc (list 'defun fun '(arg)
		       (or doc "")
		       '(interactive "p")
		       (list 'edb-call cstr))
		 forms)
	  (and key (list 'define-key 'edb-mode-map key  (list 'quote fun))))))

(def-edb "step"   "\M-s" "Step one source line with display"
  (edb-delete-arrow-extent))
(def-edb "stepi"  "\M-i" "Step one instruction with display"
  (edb-delete-arrow-extent))
(def-edb "finish" "\C-c\C-f" "Finish executing current function"
  (edb-delete-arrow-extent))
(def-edb "run" nil "Run the current program"
  (edb-delete-arrow-extent))

;;"next" and "cont" were bound to M-n and M-c in Emacs 18, but these are
;;poor choices, since M-n is used for history navigation and M-c is
;;capitalize-word.  These are defined without key bindings so that users
;;may choose their own bindings.
(def-edb "next"   "\C-c\C-n" "Step one source line (skip functions)"
  (edb-delete-arrow-extent))
(def-edb "cont"   "\C-c\M-c" "Proceed with the program"
  (edb-delete-arrow-extent))

(def-edb "up"     "\C-c<" "Go up N stack frames (numeric arg) with display")
(def-edb "down"   "\C-c>" "Go down N stack frames (numeric arg) with display")

(defvar edb-display-mode nil
  "Minor mode for edb frame display")
(or (assq 'edb-display-mode minor-mode-alist)
    (setq minor-mode-alist
	  (purecopy
	   (append minor-mode-alist
		   '((edb-display-mode " Frame"))))))

(defun edb-display-mode (&optional arg)
  "Toggle EDB Frame display mode
With arg, turn display mode on if and only if arg is positive.
In the display minor mode, source file are displayed in another
window for repective \\[edb-display-frame] commands."
  (interactive "P")
  (setq edb-display-mode (if (null arg)
			     (not edb-display-mode)
			   (> (prefix-numeric-value arg) 0))))

;; Using cc-mode's syntax table is broken.
(defvar edb-mode-syntax-table nil
  "Syntax table for EDB mode.")

;; This is adapted from CC Mode 5.11.
(unless edb-mode-syntax-table
  (setq edb-mode-syntax-table (make-syntax-table))
  ;; DO NOT TRY TO SET _ (UNDERSCORE) TO WORD CLASS!
  (modify-syntax-entry ?_  "_" edb-mode-syntax-table)
  (modify-syntax-entry ?\\ "\\" edb-mode-syntax-table)
  (modify-syntax-entry ?+  "." edb-mode-syntax-table)
  (modify-syntax-entry ?-  "." edb-mode-syntax-table)
  (modify-syntax-entry ?=  "." edb-mode-syntax-table)
  (modify-syntax-entry ?%  "." edb-mode-syntax-table)
  (modify-syntax-entry ?<  "." edb-mode-syntax-table)
  (modify-syntax-entry ?>  "." edb-mode-syntax-table)
  (modify-syntax-entry ?&  "." edb-mode-syntax-table)
  (modify-syntax-entry ?|  "." edb-mode-syntax-table)
  (modify-syntax-entry ?\' "\"" edb-mode-syntax-table)
  ;; add extra comment syntax
  (modify-syntax-entry ?/  ". 14"  edb-mode-syntax-table)
  (modify-syntax-entry ?*  ". 23"  edb-mode-syntax-table))


(defun edb-mode ()
  "Major mode for interacting with an inferior Edb process.
The following commands are available:

\\{edb-mode-map}

\\[edb-display-frame] displays in the other window
the last line referred to in the edb buffer. See also
\\[edb-display-mode].

\\[edb-step],\\[edb-next], and \\[edb-nexti] in the edb window,
call edb to step,next or nexti and then update the other window
with the current file and position.

If you are in a source file, you may select a point to break
at, by doing \\[edb-break].

Commands:
Many commands are inherited from comint mode. 
Additionally we have:

\\[edb-display-frame] display frames file in other window
\\[edb-step] advance one line in program
\\[send-edb-command] used for special printing of an arg at the current point.
C-x SPACE sets break point at current line."
  (interactive)
  (comint-mode)
  (use-local-map edb-mode-map)
  (set-syntax-table edb-mode-syntax-table)
  (make-local-variable 'edb-last-frame-displayed-p)
  (make-local-variable 'edb-last-frame)
  (make-local-variable 'edb-delete-prompt-marker)
  (make-local-variable 'edb-display-mode)
  (make-local-variable' edb-filter-accumulator)
  (setq edb-last-frame nil
        edb-delete-prompt-marker nil
        edb-filter-accumulator nil
	edb-display-mode t
        major-mode 'edb-mode
        mode-name "Inferior EDB"
        comint-prompt-regexp edb-prompt-pattern
        edb-last-frame-displayed-p t)
  (set (make-local-variable 'shell-dirtrackp) t)
  ;;(make-local-variable 'edb-arrow-extent)
  (and (extentp edb-arrow-extent)
       (delete-extent edb-arrow-extent))
  (setq edb-arrow-extent nil)
  ;; XEmacs change:
  (make-local-hook 'kill-buffer-hook)
  (add-hook 'kill-buffer-hook 'edb-delete-arrow-extent nil t)
;  (add-hook 'comint-input-filter-functions 'shell-directory-tracker nil t)
  (add-hook 'comint-input-filter-functions 'gud-edb-input-filter nil t)
  (run-hooks 'edb-mode-hook))

(defun edb-delete-arrow-extent ()
  (let ((inhibit-quit t))
    (if edb-arrow-extent
        (delete-extent edb-arrow-extent))
    (setq edb-arrow-extent nil)))

(defvar current-edb-buffer nil)

;;;###autoload
(defvar edb-command-name "gdb"
  "Pathname for executing edb.")

;;;###autoload
(defun edb (path &optional corefile)
  "Run edb on program FILE in buffer *edb-FILE*.
The directory containing FILE becomes the initial working directory
and source-file directory for EDB.  If you wish to change this, use
the EDB commands `cd DIR' and `directory'."
  (interactive "FRun edb on file: ")
  (setq path (file-truename (expand-file-name path)))
  (let ((file (file-name-nondirectory path)))
    (switch-to-buffer (concat "*edb-" file "*"))
    (setq default-directory (file-name-directory path))
    (or (bolp) (newline))
    (insert "Current directory is " default-directory "\n")
    (apply 'make-comint
	   (concat "edb-" file)
	   (substitute-in-file-name edb-command-name)
	   nil
	   "-fullname"
	   "-cd" default-directory
	   file
	   (and corefile (list corefile)))
    (set-process-filter (get-buffer-process (current-buffer)) 'edb-filter)
    (set-process-sentinel (get-buffer-process (current-buffer)) 'edb-sentinel)
    ;; XEmacs change: turn on edb mode after setting up the proc filters
    ;; for the benefit of shell-font.el
    (edb-mode)
    (edb-set-buffer)))

;;;###autoload
(defun edb-with-core (file corefile)
  "Debug a program using a corefile."
  (interactive "fProgram to debug: \nfCore file to use: ")
  (edb file corefile))

(defun edb-set-buffer ()
  (cond ((eq major-mode 'edb-mode)
	 (setq current-edb-buffer (current-buffer))
	 (if (featurep 'eos-toolbar)
	     (set-specifier default-toolbar (cons (current-buffer)
						  edb-toolbar))))))


;; This function is responsible for inserting output from EDB
;; into the buffer.
;; Aside from inserting the text, it notices and deletes
;; each filename-and-line-number;
;; that EDB prints to identify the selected frame.
;; It records the filename and line number, and maybe displays that file.
(defun edb-filter (proc string)
  (let ((inhibit-quit t))
    (save-current-buffer
     (set-buffer (process-buffer proc))
      (if edb-filter-accumulator
	  (edb-filter-accumulate-marker
	   proc (concat edb-filter-accumulator string))
	(edb-filter-scan-input proc string)))))

(defun edb-filter-accumulate-marker (proc string)
  (setq edb-filter-accumulator nil)
  (if (> (length string) 1)
      (if (= (aref string 1) ?\032)
	  (let ((end (string-match "\n" string)))
	    (if end
		(progn
		  (let* ((first-colon (string-match ":" string 2))
			 (second-colon
			  (string-match ":" string (1+ first-colon))))
		    (setq edb-last-frame
			  (cons (substring string 2 first-colon)
				(string-to-int
				 (substring string (1+ first-colon)
					    second-colon)))))
		  (setq edb-last-frame-displayed-p nil)
		  (edb-filter-scan-input proc
					 (substring string (1+ end))))
	      (setq edb-filter-accumulator string)))
	(edb-filter-insert proc "\032")
	(edb-filter-scan-input proc (substring string 1)))
    (setq edb-filter-accumulator string)))

(defun edb-filter-scan-input (proc string)
  (if (equal string "")
      (setq edb-filter-accumulator nil)
    (let ((start (string-match "\032" string)))
      (if start
	  (progn (edb-filter-insert proc (substring string 0 start))
		 (edb-filter-accumulate-marker proc
					       (substring string start)))
	(edb-filter-insert proc
			   (gud-edb-output-filter
			   string))))))

(defun edb-filter-insert (proc string)
  (let ((moving (= (point) (process-mark proc)))
	(output-after-point (< (point) (process-mark proc))))
    (save-excursion
      ;; Insert the text, moving the process-marker.
      (goto-char (process-mark proc))
      (insert-before-markers string)
      (set-marker (process-mark proc) (point))
      (edb-maybe-delete-prompt)
      ;; Check for a filename-and-line number.
      (edb-display-frame
       ;; Don't display the specified file
       ;; unless (1) point is at or after the position where output appears
       ;; and (2) this buffer is on the screen.
       (or output-after-point
           (not (get-buffer-window (current-buffer))))
       ;; Display a file only when a new filename-and-line-number appears.
       t))
    (if moving (goto-char (process-mark proc))))

  (let (s)
    (if (and (should-use-dialog-box-p)
	     (setq s (or (string-match " (y or n) *\\'" string)
			 (string-match " (yes or no) *\\'" string))))
	(edb-mouse-prompt-hack (substring string 0 s) (current-buffer))))
  )

(defun edb-mouse-prompt-hack (prompt buffer)
  (popup-dialog-box
   (list prompt
	 (vector "Yes"    (list 'edb-mouse-prompt-hack-answer 't   buffer) t)
	 (vector "No"     (list 'edb-mouse-prompt-hack-answer 'nil buffer) t)
	 nil
	 (vector "Cancel" (list 'edb-mouse-prompt-hack-answer 'nil buffer) t)
	 )))

(defun edb-mouse-prompt-hack-answer (answer buffer)
  (let ((b (current-buffer)))
    (unwind-protect
	(progn
	  (set-buffer buffer)
	  (goto-char (process-mark (get-buffer-process buffer)))
	  (delete-region (point) (point-max))
	  (insert (if answer "yes" "no"))
	  (comint-send-input))
      (set-buffer b))))

(defun edb-sentinel (proc msg)
  (cond ((null (buffer-name (process-buffer proc)))
	 ;; buffer killed
	 ;; Stop displaying an arrow in a source file.
	 ;(setq overlay-arrow-position nil) -- done by kill-buffer-hook
	 (set-process-buffer proc nil))
	((memq (process-status proc) '(signal exit))
	 ;; Stop displaying an arrow in a source file.
         (edb-delete-arrow-extent)
	 ;; Fix the mode line.
	 (setq modeline-process
	       (concat ": edb " (symbol-name (process-status proc))))
	 (let* ((obuf (current-buffer)))
	   ;; save-excursion isn't the right thing if
	   ;;  process-buffer is current-buffer
	   (unwind-protect
	       (progn
		 ;; Write something in *compilation* and hack its mode line,
		 (set-buffer (process-buffer proc))
		 ;; Force mode line redisplay soon
		 (set-buffer-modified-p (buffer-modified-p))
		 (if (eobp)
		     (insert ?\n mode-name " " msg)
		   (save-excursion
		     (goto-char (point-max))
		     (insert ?\n mode-name " " msg)))
		 ;; If buffer and mode line will show that the process
		 ;; is dead, we can delete it now.  Otherwise it
		 ;; will stay around until M-x list-processes.
		 (delete-process proc))
	     ;; Restore old buffer, but don't restore old point
	     ;; if obuf is the edb buffer.
	     (set-buffer obuf))))))


(defun edb-refresh (&optional arg)
  "Fix up a possibly garbled display, and redraw the arrow."
  (interactive "P")
  (recenter arg)
  (edb-display-frame))

(defun edb-display-frame (&optional nodisplay noauto)
  "Find, obey and delete the last filename-and-line marker from EDB.
The marker looks like \\032\\032FILENAME:LINE:CHARPOS\\n.
Obeying it means displaying in another window the specified file and line."
  (interactive)
  (edb-set-buffer)
  (and edb-last-frame (not nodisplay)
       edb-display-mode
       (or (not edb-last-frame-displayed-p) (not noauto))
       (progn (edb-display-line (car edb-last-frame) (cdr edb-last-frame))
	      (setq edb-last-frame-displayed-p t))))

;; Make sure the file named TRUE-FILE is in a buffer that appears on the screen
;; and that its line LINE is visible.
;; Put the overlay-arrow on the line LINE in that buffer.

(defun edb-display-line (true-file line &optional select-method)
  ;; FILE to display
  ;; LINE number to highlight and make visible
  ;; SELECT-METHOD 'source, 'debugger, or 'none.  (default is 'debugger)
  (and (null select-method) (setq select-method 'debugger))
  (let* ((pre-display-buffer-function nil) ; screw it, put it all in one screen
	 (pop-up-windows t)
	 (source-buffer (find-file-noselect true-file))
	 (source-window (display-buffer source-buffer))
	 (debugger-window (get-buffer-window current-edb-buffer))
         (extent edb-arrow-extent)
	 pos)
    ;; XEmacs change: make sure we find a window displaying the source file
    ;; even if we are already sitting in it when a breakpoint is hit.
    ;; Otherwise the t argument to display-buffer will prevent it from being
    ;; displayed.
    (save-excursion 
      (cond ((eq select-method 'debugger)
	     ;; might not already be displayed
	     (setq debugger-window (display-buffer current-edb-buffer))
	     (select-window debugger-window))
	    ((eq select-method 'source)
	     (select-window source-window))))
    (and extent
	 (not (eq (extent-object extent) source-buffer))
	 (setq extent (delete-extent extent)))
    (or extent
        (progn
          (setq extent (make-extent 1 1 source-buffer))
          (set-extent-face extent 'edb-arrow-face)
	  (set-extent-begin-glyph extent edb-arrow-glyph)
          (set-extent-begin-glyph-layout extent 'whitespace)
          (set-extent-priority extent 2000)
          (setq edb-arrow-extent extent)))
    (save-current-buffer
      (set-buffer source-buffer)
      (save-restriction
	(widen)
	(goto-line line)
	(set-window-point source-window (point))
	(setq pos (point))
        (end-of-line)
        (set-extent-endpoints extent pos (point))
        (run-hook-with-args 'edb-arrow-extent-hooks extent))
      (cond ((or (< pos (point-min)) (> pos (point-max)))
	     (widen)
	     (goto-char pos))))
    ;; Added by Stig.  It caused lots of problems for several users
    ;; and since its purpose is unclear it is getting commented out.
    ;;(and debugger-window
    ;; (set-window-point debugger-window pos))
    ))

(defun edb-call (command)
  "Invoke edb COMMAND displaying source in other window."
  (interactive)
  (goto-char (point-max))
  ;; Record info on the last prompt in the buffer and its position.
  ;; This is used in  edb-maybe-delete-prompt
  ;; to prevent multiple prompts from accumulating.
  (save-excursion
    (goto-char (process-mark (get-buffer-process current-edb-buffer)))
    (let ((pt (point)))
      (beginning-of-line)
      (setq edb-delete-prompt-marker
	    (if (= (point) pt)
		nil
	      (list (point-marker) (- pt (point))
		    (buffer-substring (point) pt))))))
  (edb-set-buffer)
  (process-send-string (get-buffer-process current-edb-buffer)
	       (concat command "\n")))

(defun edb-maybe-delete-prompt ()
  (if edb-delete-prompt-marker
      ;; Get the string that we used as the prompt before.
      (let ((prompt (nth 2 edb-delete-prompt-marker))
	    (length (nth 1 edb-delete-prompt-marker)))
	;; Position after it.
	(goto-char (+ (car edb-delete-prompt-marker) length))
	;; Delete any duplicates of it which follow right after.
	(while (and (<= (+ (point) length) (point-max))
		    (string= prompt
			     (buffer-substring (point) (+ (point) length))))
	  (delete-region (point) (+ (point) length)))
	;; If that didn't take us to where output is arriving,
	;; we have encountered something other than a prompt,
	;; so stop trying to delete any more prompts.
	(if (not (= (point)
		    (process-mark (get-buffer-process current-edb-buffer))))
	    (progn
	      (set-marker (car edb-delete-prompt-marker) nil)
	      (setq edb-delete-prompt-marker nil))))))

(defun edb-break (temp)
  "Set EDB breakpoint at this source line.  With ARG set temporary breakpoint."
  (interactive "P")
  (let* ((file-name (file-name-nondirectory buffer-file-name))
	 (line (save-restriction
		 (widen)
		 (beginning-of-line)
		 (1+ (count-lines 1 (point)))))
	 (cmd (concat (if temp "tbreak " "break ") file-name ":"
		      (int-to-string line))))
    (set-buffer current-edb-buffer)
    (goto-char (process-mark (get-buffer-process current-edb-buffer)))
    (delete-region (point) (point-max))
    (insert cmd)
    (comint-send-input)
    ;;(process-send-string (get-buffer-process current-edb-buffer) cmd)
    ))

(defun edb-clear ()
  "Set EDB breakpoint at this source line."
  (interactive)
  (let* ((file-name (file-name-nondirectory buffer-file-name))
	 (line (save-restriction
		 (widen)
		 (beginning-of-line)
		 (1+ (count-lines 1 (point)))))
	 (cmd (concat "clear " file-name ":"
		      (int-to-string line))))
    (set-buffer current-edb-buffer)
    (goto-char (process-mark (get-buffer-process current-edb-buffer)))
    (delete-region (point) (point-max))
    (insert cmd)
    (comint-send-input)
    ;;(process-send-string (get-buffer-process current-edb-buffer) cmd)
    ))

(defun edb-read-address()
  "Return a string containing the core-address found in the buffer at point."
  (save-excursion
   (let ((pt (point)) found begin)
     (setq found (if (search-backward "0x" (- pt 7) t)(point)))
     (cond (found (forward-char 2)
		  (buffer-substring found
				    (progn (re-search-forward "[^0-9a-f]")
					   (forward-char -1)
					   (point))))
	   (t (setq begin (progn (re-search-backward "[^0-9]") (forward-char 1)
				 (point)))
	      (forward-char 1)
	      (re-search-forward "[^0-9]")
	      (forward-char -1)
	      (buffer-substring begin (point)))))))


(defvar edb-commands nil
  "List of strings or functions used by send-edb-command.
It is for customization by you.")

(defun send-edb-command (arg)

  "This command reads the number where the cursor is positioned.  It
 then inserts this ADDR at the end of the edb buffer.  A numeric arg
 selects the ARG'th member COMMAND of the list edb-print-command.  If
 COMMAND is a string, (format COMMAND ADDR) is inserted, otherwise
 (funcall COMMAND ADDR) is inserted.  eg. \"p (rtx)%s->fld[0].rtint\"
 is a possible string to be a member of edb-commands.  "


  (interactive "P")
  (let (comm addr)
    (if arg (setq comm (nth arg edb-commands)))
    (setq addr (edb-read-address))
    (if (eq (current-buffer) current-edb-buffer)
	(set-mark (point)))
    (cond (comm
	   (setq comm
		 (if (stringp comm) (format comm addr) (funcall comm addr))))
	  (t (setq comm addr)))
    (switch-to-buffer current-edb-buffer)
    (goto-char (point-max))
    (insert comm)))

(fset 'edb-control-c-subjob 'comint-interrupt-subjob)

;(defun edb-control-c-subjob ()
;  "Send a Control-C to the subprocess."
;  (interactive)
;  (process-send-string (get-buffer-process (current-buffer))
;		       "\C-c"))

(defun edb-toolbar-break ()
  (interactive)
  (save-excursion
    (message (car edb-last-frame))
    (set-buffer (find-file-noselect (car edb-last-frame)))
    (edb-break nil)))

(defun edb-toolbar-clear ()
  (interactive)
  (save-excursion
    (message (car edb-last-frame))
    (set-buffer (find-file-noselect (car edb-last-frame)))
    (edb-clear)))



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
;;      --> try feature call		--> (FCALL,$x,x,(y))	p r???x($x)
;;     when $x = (Txx*)0x40......
;;      --> known type reference	--> (TYPE,$x,x,(y))	p *(T0*)$x
;;     when $x = Something else
;;      --> Result.			--> (nil)		""
;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; edb filter
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun gud-edb-input-filter (input)
  (when (and (null edb-query-state)
	     (string-match "p +\\([$A-Za-z_][.0-9A-Z_a-z]*\\)$" input))
    (message-s "input-filter <-- [%s]" input)
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
	(res nil))
    (while (string-match "\\([^.]*\\)\\." str)
      (setq s (matched-string str 1))
      (setq res (cons s res))
      (setq str (substring str (+ 1 (match-end 1)))))
    (cons str res)
))


(defvar last_str "")

(defun gud-edb-output-filter (str)
  (message-s "output-filter --> [%s]" str)
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
  (message-s "print-sw(%s %s %s) <-- [%s]" edb-query-state edb-print-var edb-print-var-seq str)
  (let ((proc (get-buffer-process current-edb-buffer))
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
	((string-match "\\(\\$[0-9]*\\) = (T\\([0-9]*\\) \\*) 0x[0-9a-f]*" str)
	 (setq edb-query-state 'TYPE)
	 (setq edb-target-var (matched-string str 1))
	 (setq edb-target-type (matched-string str 2))
	 (setq edb-print-var "")
	 (setq edb-print-var-seq nil)
	 (concat "*(T" edb-target-type "*)"  edb-target-var)
	 )
	(t (setq edb-target-var nil)
	   (setq edb-query-state nil)
	   
	)))

(defun gud-edb-print-filter-LOCAL (str)	
  (cond ((string-match "No symbol \".*\" in current context\." str)
	 (setq edb-query-state 'ATTR)
	 (concat "C._" edb-print-var))
	((string-match "\\(\\$[0-9]*\\) = (T\\([0-9]*\\) \\*) 0x[0-9a-f]*" str)
	 (setq edb-query-state 'TYPE)
	 (setq edb-target-var (matched-string str 1))
	 (setq edb-target-type (matched-string str 2))
	 (concat "*(T" edb-target-type "*)" edb-target-var)
	 )
	(t (setq edb-query-state nil)
	)
  ))

(defun gud-edb-print-filter-ATTR (str)	
  (cond 
	((string-match "There is no member named \\(.*\\)" str)
	 (setq edb-query-state 'CTYPE)
	 "*(T0*)C"
	 )
	((string-match "\\(\\$[0-9]*\\) = (T\\([0-9]*\\) \\*) 0x[0-9a-f]*" str)
	 (setq edb-query-state 'TYPE)
	 (setq edb-target-var (matched-string str 1))
	 (setq edb-target-type (matched-string str 2))
	 (concat "*(T" edb-target-type "*)" edb-target-var)
	 )
	(t (setq edb-query-state nil)
	   )
	)
  )


(defun gud-edb-print-filter-CTYPE (str)	
  (cond ((string-match "{id = \\([0-9]+\\)" str)
	 (setq edb-query-state 'FCALL)
	 (setq edb-target-cid (matched-string str 1))
	 (concat "r" edb-target-cid edb-print-var "(" edb-target-var ")")
	 )
	(t (setq edb-query-state nil)
	)
  ))


(defun gud-edb-print-filter-FCALL (str)	
  (cond 
	((string-match "\\(\\$[0-9]*\\) = (T\\([0-9]*\\) \\*) 0x[0-9a-f]*" str)
	 (setq edb-query-state 'TYPE)
	 (setq edb-target-var (matched-string str 1))
	 (setq edb-target-type (matched-string str 2))
	 (concat "*(T" edb-target-type "*)" edb-target-var)
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
	 (concat "r" edb-target-cid edb-print-var "(" edb-target-var ")") 
	 )
	((string-match "\\(\\$[0-9]*\\) = (T\\([0-9]*\\) \\*) 0x[0-9a-f]*" str)
	 (setq edb-query-state 'TYPE)
	 (setq edb-target-var (matched-string str 1))
	 (setq edb-target-type (matched-string str 2))
	 (concat "*(T" edb-target-type "*)" edb-target-var)
	 )
	(t (setq edb-query-state nil)
	   )
	)
  )

(defun edb-send (proc str)
  (message-s "send --> [%s]" str)
  (process-send-string proc str)
  ""
  )

(defvar debug-edb nil)

(defun message-s (fmt &rest args)
  (if debug-edb
      (save-current-buffer
	(set-buffer "*scratch*")
	(let ((str (apply 'format fmt args)))
	  (insert str)
	  (insert "\n")
	  str))))


(provide 'edb)

;;; edb.el ends here
