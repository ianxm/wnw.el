;;; wnw.el --- Host wits 'n wagers over a conference call -*- lexical-binding: t -*-

;; Copyright (C) 2020 Ian Martins

;; Author: Ian Martins <ianxm@jhu.edu>
;; URL: https://github.com/ianxm/wnw.el
;; Version: 0.0.1
;; Package-Requires: ((emacs "24.4") (seq "2.3"))

;; This file is not part of GNU Emacs.

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; For a full copy of the GNU General Public License
;; see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; wnw.el manages the wits 'n wagers gameboard.  It can be used to
;; host a game of wits 'n wagers over a conference call.

;;; Code:

(require 'seq)

(defconst wnw-player-heading "players"
  "The name of heading that holds player data.")

(defconst wnw-gameboard-heading "gameboard"
  "The name of heading where we render the gameboard.")

(defconst wnw-gamelog-heading "gamelog"
  "The name of heading for the game log.")

(defvar wnw-round 1
  "The current round number.")

(defgroup wnw nil
  "Options for Wits 'n Wagers."
  :group 'games
  :tag "Wits 'n Wagers")

(defcustom wnw-timer-duration "0:30"
  "The amount of time each question and betting phase can take."
  :type 'string
  :group 'wnw)

(defgroup wnw-faces nil
  "Faces used by Wits 'n Wagers."
  :group 'wnw
  :group 'faces)

(defface wnw-player1
  '((((class color) (background light)) :foreground "#e377c2")
    (((class color) (background  dark)) :foreground "#e377c2"))
  "Face used by player 1."
  :group 'wnw-faces)

(defface wnw-player1-win
  '((((class color) (background light)) :inherit wnw-player1 :weight bold)
    (((class color) (background  dark)) :inherit wnw-player1 :weight bold))
  "Face used when player 1 wins."
  :group 'wnw-faces)

(defface wnw-player2
  '((((class color) (background light)) :foreground "#ff7f0e")
    (((class color) (background  dark)) :foreground "#ff7f0e"))
  "Player 2"
  :group 'wnw-faces)

(defface wnw-player2-win
  '((((class color) (background light)) :inherit wnw-player2 :weight bold)
    (((class color) (background  dark)) :inherit wnw-player2 :weight bold))
  "Face used when player 2 wins."
  :group 'wnw-faces)

(defface wnw-player3
  '((((class color) (background light)) :foreground "#2ca02c")
    (((class color) (background  dark)) :foreground "#2ca02c"))
  "Player 3"
  :group 'wnw-faces)

(defface wnw-player3-win
  '((((class color) (background light)) :inherit wnw-player3 :weight bold)
    (((class color) (background  dark)) :inherit wnw-player3 :weight bold))
  "Face used when player 3 wins."
  :group 'wnw-faces)

(defface wnw-player4
  '((((class color) (background light)) :foreground "#d62728")
    (((class color) (background  dark)) :foreground "#d62728"))
  "Player 4"
  :group 'wnw-faces)

(defface wnw-player4-win
  '((((class color) (background light)) :inherit wnw-player4 :weight bold)
    (((class color) (background  dark)) :inherit wnw-player4 :weight bold))
  "Face used when player 4 wins."
  :group 'wnw-faces)

(defface wnw-player5
  '((((class color) (background light)) :foreground "#7f7f7f")
    (((class color) (background  dark)) :foreground "#7f7f7f"))
  "Player 5"
  :group 'wnw-faces)

(defface wnw-player5-win
  '((((class color) (background light)) :inherit wnw-player5 :weight bold)
    (((class color) (background  dark)) :inherit wnw-player5 :weight bold))
  "Face used when player 5 wins."
  :group 'wnw-faces)

(defface wnw-player6
  '((((class color) (background light)) :foreground "#bcbd22")
    (((class color) (background  dark)) :foreground "#bcbd22"))
  "Player 6"
  :group 'wnw-faces)

(defface wnw-player6-win
  '((((class color) (background light)) :inherit wnw-player6 :weight bold)
    (((class color) (background  dark)) :inherit wnw-player6 :weight bold))
  "Face used when player 6 wins."
  :group 'wnw-faces)

(defface wnw-player7
  '((((class color) (background light)) :foreground "#17becf")
    (((class color) (background  dark)) :foreground "#17becf"))
  "Player 7"
  :group 'wnw-faces)

(defface wnw-player7-win
  '((((class color) (background light)) :inherit wnw-player7 :weight bold)
    (((class color) (background  dark)) :inherit wnw-player7 :weight bold))
  "Face used when player 7 wins."
  :group 'wnw-faces)

(defface wnw-player8
  '((((class color) (background light)) :foreground "#1f77b4")
    (((class color) (background  dark)) :foreground "#1f77b4"))
  "Player 8"
  :group 'wnw-faces)

(defface wnw-player8-win
  '((((class color) (background light)) :inherit wnw-player8 :weight bold)
    (((class color) (background  dark)) :inherit wnw-player8 :weight bold))
  "Face used when player 8 wins."
  :group 'wnw-faces)

(defface wnw-player9
  '((((class color) (background light)) :foreground "#9467bd")
    (((class color) (background  dark)) :foreground "#9467bd"))
  "Player 9"
  :group 'wnw-faces)

(defface wnw-player9-win
  '((((class color) (background light)) :inherit wnw-player9 :weight bold)
    (((class color) (background  dark)) :inherit wnw-player9 :weight bold))
  "Face used when player 9 wins."
  :group 'wnw-faces)

(defface wnw-player10
  '((((class color) (background light)) :foreground "#8c564b")
    (((class color) (background  dark)) :foreground "#8c564b"))
  "Player 10"
  :group 'wnw-faces)

(defface wnw-player10-win
  '((((class color) (background light)) :inherit wnw-player10 :weight bold)
    (((class color) (background  dark)) :inherit wnw-player10 :weight bold))
  "Face used when player 10 wins."
  :group 'wnw-faces)

(defun wnw-init ()
  "Set all players chips to zero and clear other properties."
  (interactive)
  (save-excursion
    (setq wnw-round 1)
    (goto-char (org-find-exact-headline-in-buffer wnw-player-heading))
    (let ((count 1))
      (org-map-tree (lambda () (when (= 2 (org-current-level))
                                 (org-entry-put (point) "chips" "2")
                                 (org-entry-put (point) "face" (concat "wnw-player" (number-to-string count)))
                                 (org-entry-delete (point) "guess")
                                 (org-entry-delete (point) "bets")
                                 (setq count (1+ count))))))
    (wnw--clear wnw-gamelog-heading)
    (wnw--log (format "-- round %d --" wnw-round))
    (goto-char (org-find-exact-headline-in-buffer wnw-gameboard-heading))
    (outline-show-entry)
    (goto-char (org-find-exact-headline-in-buffer wnw-gamelog-heading))
    (outline-show-entry))
  (wnw--render))

(defun wnw--all-players ()
  "Return an alist of (player . (chips-held bets chips-in-play guess face)) sorted by chips-held high to low."
  (save-excursion
    (let (players)
      (goto-char (org-find-exact-headline-in-buffer wnw-player-heading))
      (org-map-tree (lambda ()
                      (if (org-entry-get (point) "chips")
                          (let ((name (org-entry-get (point) "ITEM"))
                                (chips-held (if (org-entry-get (point) "chips")
                                                (string-to-number (org-entry-get (point) "chips"))
                                              0))
                                (bets (if (org-entry-get (point) "bets")
                                          (length (org-entry-get-multivalued-property (point) "bets"))
                                        0))
                                (chips-in-play (seq-reduce
                                                (lambda (chips x) (+ chips (string-to-number (first (split-string x "on")))))
                                                (org-entry-get-multivalued-property (point) "bets")
                                                0))
                                (guess (and (org-entry-get (point) "guess")
                                            (string-to-number (org-entry-get (point) "guess"))))
                                (face (org-entry-get (point) "face")))
                            (setq players (cons (cons name (list chips-held bets chips-in-play guess face))
                                                players))))))
      (setq players (sort players (lambda (a b) (if (< (cadr a) (cadr b)) nil t)))))))

(defun wnw-timer ()
  "Start the game timer."
  (interactive)
  (org-timer-set-timer wnw-timer-duration))

(defun wnw-guess (arg)
  "Make a guess.  Save it to player data and redraw.
if ARG, allow overriding existing guesses."
  (interactive "P")
  (diminish 'wnw-mode " qGban")
  (while (or arg
             (seq-some (lambda (x) (null (fourth (cdr x)))) (wnw--all-players)))
    (let ((player (completing-read "Player: " (mapcar #'car (seq-filter
                                                             (lambda (x) (null (fourth (cdr x))))
                                                             (wnw--all-players)))))
         (guess (read-string "Guess: " nil nil "smaller")))
     (org-entry-put (org-find-exact-headline-in-buffer player)
                    "guess"
                    (if (string= guess "smaller") (number-to-string most-negative-fixnum) guess))
     (wnw--render))))

(defun wnw--all-guesses ()
  "Return a sorted list of guesses."
  (let ((guesses (list (number-to-string most-negative-fixnum))))
    (save-excursion
      (goto-char (org-find-exact-headline-in-buffer wnw-player-heading))
      (org-map-tree (lambda () (setq guesses (cons (org-entry-get (point) "guess") guesses))))
      (setq guesses (seq-filter (lambda (x) (not (null x))) guesses) ; remove null
            guesses (mapcar #'string-to-number guesses) ; convert to numbers
            guesses (cl-remove-duplicates guesses)      ; remove dups
            guesses (sort guesses '<)))))               ; sort

(defun wnw-bet (arg)
  "Make a bet.
if ARG, allow someone with zero chips to bet in order to clear out an existing bet."
  (interactive "P")
  (diminish 'wnw-mode " qgBan")
  (while (or arg
             (seq-some (lambda (x) (and (< (second (cdr x)) 2)
                                        (> (first (cdr x)) 0)))
                       (wnw--all-players)))
      (let ((player (completing-read "Player: " (seq-reduce
                                                 (lambda (res x) (if (and (< (second (cdr x)) 2)
                                                                          (> (first (cdr x)) 0))
                                                                     (cons x res) res))
                                                 (wnw--all-players)
                                                 nil)))
         (guess (completing-read "Guess: " (mapcar (lambda (x) (if (= x most-negative-fixnum) "smaller" (number-to-string x)))
                                                   (wnw--all-guesses))
                                 nil t)))
     (let* ((player-point (org-find-exact-headline-in-buffer player))
            (player-stats (assoc player (wnw--all-players)))
            (chips (second player-stats))
            (amount (read-number "Amount: " chips))
            (num-bets (third player-stats))
            (bets (and (org-entry-get player-point "bets")
                       (mapcar (lambda (x) (apply #'cons (reverse (mapcar #'string-to-number (split-string x "on")))))
                               (org-entry-get-multivalued-property player-point "bets"))))
            (oldbet (assoc (string-to-number guess) bets))
            (oldamount (if oldbet (cdr oldbet) 0)))
       (if (> amount (+ chips oldamount))
           (error (format "%s doesn't have enough chips" player)))
       (if (< amount 0)
           (error (format "%s can't make negative bet" player)))
       (if (null oldbet)
           (setq bets (cons (cons (if (string= guess "smaller") most-negative-fixnum guess) amount)
                            bets))
         (setcdr oldbet amount))
       (if (> (length bets) 2)
           (error (format "%s has already made two bets." player)))
       (let ((newbets (mapcar (lambda (x) (format "%son%s" (cdr x) (car x)))
                              (seq-filter (lambda (x) (> (cdr x) 0)) bets))))
         (if newbets
             (apply #'org-entry-put-multivalued-property player-point "bets" newbets)
           (org-entry-delete player-point "bets")))
       (org-entry-put player-point "chips" (number-to-string (- chips (- amount oldamount))))
       (wnw--render)))))

(defun wnw--find-bets (guess)
  "Return alist of (player . amount) for all bets for the given GUESS."
  (let (found-bets)
    (save-excursion
      (goto-char (org-find-exact-headline-in-buffer wnw-player-heading))
      (org-map-tree (lambda ()
                      (let* ((player (org-entry-get (point) "ITEM"))
                             (bets (and (org-entry-get (point) "bets")
                                        (mapcar (lambda (x) (apply #'cons (reverse (mapcar #'string-to-number (split-string x "on")))))
                                                (org-entry-get-multivalued-property (point) "bets"))))
                             (bet (assoc guess bets)))
                        (if bet
                            (setq found-bets (cons (cons player (cdr bet)) found-bets)))))))
    found-bets))

(defun wnw--find-guessers (guess)
  "Find all players who made GUESS."
  (let (found-guessers)
    (save-excursion
      (goto-char (org-find-exact-headline-in-buffer wnw-player-heading))
      (org-map-tree (lambda ()
                      (let ((player (org-entry-get (point) "ITEM"))
                            (player-guess (and (org-entry-get (point) "guess")
                                               (string-to-number (org-entry-get (point) "guess")))))
                        (if (and player-guess (= guess player-guess))
                            (setq found-guessers (cons player found-guessers)))))))
    found-guessers))

(defun wnw--clear (section)
  "Delete all content from SECTION."
  (save-excursion
    (let ((top (progn (goto-char (org-find-exact-headline-in-buffer section))
                      (forward-line)
                      (point)))
          (bottom (progn (goto-char (org-find-exact-headline-in-buffer section))
                         (outline-end-of-subtree)
                         (point))))
      (delete-region top bottom))))

(defun wnw--render (&optional best)
  "Render the game board.
BEST is the value of the best guess.  If given the row with the best guess is marked as a win."
  (save-excursion
    ;; clear board
    (wnw--clear wnw-gameboard-heading)
    (goto-char (org-find-exact-headline-in-buffer wnw-gameboard-heading))
    (forward-line)

    ;; render player table
    (insert "\n||chips||chips|\n|player|held|bets|in play\n|-\n|")
    (org-table-align)
    (dolist (player (wnw--all-players))
      (wnw--insert-with-face (car player) (sixth player) nil)
      (org-table-next-field)
      (insert (number-to-string (second player)))
      (org-table-next-field)
      (insert (number-to-string (third player)))
      (org-table-next-field)
      (insert (number-to-string (fourth player)))
      (org-table-next-field))
    (beginning-of-line)
    (kill-line)
    (insert "\n")

    ;; render main table
    (insert "|guesser|guess|bets|pays|\n|-\n|")
    (org-table-align)
    (let ((players (wnw--all-players))
          (all-guesses (wnw--all-guesses))
          (index 0))
     (dolist (guess all-guesses)
       (let* ((bets (wnw--find-bets guess))
              (guessers (wnw--find-guessers guess))
              (middlerow (/ (length all-guesses) 2))
              (payrate (wnw--determine-payrate index (1- (length all-guesses))))
              (winner (and best (= guess best)))
              row start)
         (setq index (1+ index)
               bets (sort bets (lambda (a b) (if (< (cdr a) (cdr b)) nil t))))
         ;; (org-table-next-row)
         (org-table-goto-column 1)
         (setq row (org-table-current-line))
         (dolist (guesser guessers)
           (wnw--insert-with-face guesser
                                  (sixth (assoc guesser players))
                                  winner)
           (org-table-next-row))
         (org-table-goto-line row)

         (org-table-goto-column 2)
         (wnw--insert-with-face (if (= guess most-negative-fixnum)
                                    "smaller"
                                  (number-to-string guess))
                                nil winner)

         (org-table-goto-column 3)
         (dolist (bet bets)
           (wnw--insert-with-face (format "%s:%s" (car bet) (cdr bet))
                                  (sixth (assoc (car bet) players))
                                  winner)
           (org-table-next-row))
         (org-table-goto-line row)

         (org-table-goto-column 4)
         (wnw--insert-with-face (format "%d to 1" payrate) nil winner)

         (dotimes (_ (max 0
                          (1- (length guessers))
                          (1- (length bets))))
           (org-table-next-row))
         (org-table-hline-and-move)))
     (goto-char (line-beginning-position))
     (kill-line))
    (org-table-align)

    ;; unfontify gameboard
    (let ((top (progn (goto-char (org-find-exact-headline-in-buffer wnw-gameboard-heading))
                      (forward-line)
                      (point)))
          (bottom (progn (goto-char (org-find-exact-headline-in-buffer wnw-gameboard-heading))
                         (outline-end-of-subtree)
                         (point))))
      (font-lock-unfontify-region top bottom)
      (remove-text-properties top bottom '(face org-table)))))

(defun wnw--insert-with-face (text face boldp)
  "Insert the give TEXT using FACE and make bold if BOLDP."
  (let ((start (point)))
    (insert text)
    (unless (and (null face) (not boldp))
      (cond ((and (null face) boldp)
             (setq face 'bold))
            (boldp
             (setq face (concat face "-win"))))
      (add-text-properties start (point) `(font-lock-face ,face)))))

(defun wnw--determine-payrate (index count)
  "Determine the payrate at INDEX given COUNT guesses."
  (if (= 0 index)
      6 ; smaller
    (let* ((evenp (= 0 (% count 2)))
           (middlerow (/ count 2))
           (shift (if (and evenp (> index middlerow)) 1 0))) ; skip "2 to 1" if even
      (+ 2 (abs (- (1- index) middlerow)) shift))))

(defun wnw--pay (player amount winp)
  "Increase PLAYER's chips by AMOUNT.
If WINP then the player won, else their losing chip is being returned."
  (wnw--log (format "%s %s to %s" (if winp "paying" "returning") amount player) player)
  (let* ((player-point (org-find-exact-headline-in-buffer player))
         (chips (string-to-number (org-entry-get player-point "chips"))))
    (org-entry-put player-point "chips" (number-to-string (+ chips amount)))))

(defun wnw--log (msg &optional player)
  "Write MSG to the game log.
if given, use color for PLAYER."
  (save-excursion
    (let ((face (and player (org-entry-get (org-find-exact-headline-in-buffer player) "face"))))
      (goto-char (org-find-exact-headline-in-buffer "gamelog"))
      (forward-line 1)
      (insert (format "[%s] " (format-time-string "%H:%M" (current-time)) msg))
      (wnw--insert-with-face (format "%s\n" msg) face nil))))

(defun wnw-answer ()
  "Enter the actual answer and pay out the winners."
  (interactive)
  (diminish 'wnw-mode " qgbAn")
  (let* ((answer (read-number "Correct answer: "))
         (guesses (wnw--all-guesses))
         (best (seq-reduce (lambda (best guess) (if (<= guess answer) guess best))
                           guesses
                           most-negative-fixnum))
         (winning-guessers (wnw--find-guessers best))
         (best-index (cl-position best guesses))
         (payrate (wnw--determine-payrate best-index (1- (length guesses)))))
    (wnw--log (format "correct answer was %s, winning guess was %s" answer (if (= best most-negative-fixnum) "smaller" best)))
    ;; pay guesser
    (if winning-guessers
        (mapc (lambda (x) (wnw--pay x 3 t))
              winning-guessers))
    ;; pay bets at rate
    (dolist (guess guesses)
      (mapc (lambda (x) (wnw--pay (car x)
                                  (if (eq guess best)
                                      ;; for a win, pay the bet times the payrate
                                      ;; plus the amount they put in
                                      (+ (* (cdr x) payrate) (cdr x))
                                    ;; for a loss, return two chips to a player iff it's their only bet
                                    ;; and they bet more than one chip, else return one chip per bet
                                    (let* ((player-stats (assoc (car x) (wnw--all-players))) ; return
                                           (player-bets (third player-stats))
                                           (player-chips-in-play (fourth player-stats)))
                                      (if (and (eq 1 player-bets) (< 1 player-chips-in-play)) 2 1)))
                                  (eq guess best)))
            (wnw--find-bets guess)))
    (wnw--render best)))

(defun wnw-next ()
  "Set up for the next round."
  (interactive)
  (save-excursion
    (diminish 'wnw-mode " Qgban")
    (setq wnw-round (1+ wnw-round))
    (wnw--log (format "-- round %d --" wnw-round))
    ;; clear guesses and bets
    (goto-char (org-find-exact-headline-in-buffer wnw-player-heading))
    (org-map-tree (lambda () (when (= 2 (org-current-level))
                               (org-entry-delete (point) "guess")
                               (org-entry-delete (point) "bets"))))
    (wnw--render)))




;; steps:
;;   Q question
;;   G guess (timed)
;;   B bet (timed)
;;   A answer
;;   N next

;;;###autoload
(define-minor-mode wnw-mode "Toggle Wits 'n Wagers mode."
  :init-value nil
  :lighter " Qgban"
  :keymap
  `((,(kbd "C-c g") . wnw-guess)
    (,(kbd "C-c b") . wnw-bet)
    (,(kbd "C-c a") . wnw-answer)
    (,(kbd "C-c n") . wnw-next)
    (,(kbd "C-c t") . wnw-timer))
  :group 'wnw)

(provide 'wnw-mode)

;;; wnw.el ends here
