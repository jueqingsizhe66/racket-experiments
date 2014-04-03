#lang racket

(require "data.rkt"
         "constants.rkt")

(provide (all-defined-out))

;; [List-of Moves] [or '() [List Natural Natural]] -> [or #f Game-tree]
;; find the move from the current list of moves
(define (find-move moves action)
  (define m
    (findf (lambda (m) (equal? (move-action m) action)) moves))
  (and m (move-gt m)))

;; Game -> Boolean
;; are there any moves in this game record?
(define (no-more-moves? g)
  (empty? (game-moves g)))

;; Board -> String
;; Which player has won the game -- eager is for N human players
(define (won board)
  (define-values (best-score w) (winners board))
  (if (cons? (rest w)) "It's a tie." "You won."))

;; Natural -> Natural
;; gets the row that territory is on, indexed from 0
;; [test vary on current board-size]
(define (get-row pos)
  (quotient pos BOARD))

;; Board ->* Natural [non-empty-listof Player]
;; gives the number of winning territories and the players(s) who have them
;; > (winners (list (territory 0 0 1 9 0) (territory 0 0 1 9 1)))
;; (values 2 '(0))
;; > (winners (list (territory 0 1 1 9 0) (territory 0 0 1 9 1)))
;; (values 1 '(0 1))
(define (winners board)
  (for/fold ([best 0][winners '()]) ([p PLAYER#])
    (define p-score (sum-territory board p))
    (cond [(> p-score best) (values p-score (list p))]
          [(< p-score best) (values best winners)]
          [(= p-score best) (values best (cons p winners))])))

;; Board Player -> Natural
;; counts the number of territorys the player owns
;; > (sum-territory (list (territory 0 1 1 9 0) (territory 0 1 1 9 1)) 1)
;; 2
(define (sum-territory board player)
  (for/fold ([result 0]) ([t board])
    (if (= (territory-player t) player) (+ result 1) result)))
