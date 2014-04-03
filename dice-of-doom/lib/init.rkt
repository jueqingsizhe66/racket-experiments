#lang racket

(require "constants.rkt"
         "data.rkt"
         "auxiliary.rkt")

(provide (all-defined-out))

;; Making A Board

;; -> Board
;; Creates a list of territories the size of GRID with given x and y coordinates
;; properties: dice is (0,MAX-DICE]
;;             returns list of size GRID
(define (territory-build)
  (for/list ([n (in-range GRID)])
    (territory n (modulo n PLAYER#) (dice) (get-x n) (get-y n))))

;; -> Natural
;; the number of initial die on a territory
(define (dice)
  (add1 (random DICE#)))

;; Natural -> Number
;; the x coordinate for territory n of a board
(define (get-x n)
  (+ OFFSET0
    (if (odd? (get-row n)) 0 (/ X-OFFSET 2))
    (* X-OFFSET (modulo n BOARD))))

;; Natural -> Number
;; the y coordinate for territory n of a board
(define (get-y n)
  (+ OFFSET0 (* Y-OFFSET (get-row n))))

;; Making a Game Tree

;; Board Player Natural -> GameTree
;; creates a complete game-tree from the given board, player, and spare dice
(define (game-tree board player dice)
  ;; create tree of attacks from this position; add passing move
  (define (attacks board)
    (for*/list ([src board]
                [dst (neighbors (territory-index src))]
                #:when (attackable? board player src dst))
      (define from (territory-index src))
      (define dice (territory-dice src))
      (define newb (execute board player from dst dice))
      (define more (delay (cons (passes newb) (attacks newb))))
      (define attacks-from-newb (game newb player more))
      (move (list from dst) attacks-from-newb)))
  ;; create a passing move, distribute dice, continue
  (define (passes board)
    (define-values (new-dice newb) (distribute board player dice))
    (move '() (game-tree newb (switch player) new-dice)))
  ;; -- START: --
  (game board player (delay (attacks board))))

;; Player -> Player
;; switches from one player to the next
(define (switch player)
  (modulo (add1 player) PLAYER#))

;; Board Player Natural -> Natural Board
;; adds reinforcements to the game board
;; > (add-new-dice (list (territory 0 2 2 9 0)) 2 2))
;; (list (territory 0 2 2 9 0))
(define (distribute board player spare-dice)
  (for/fold ([dice spare-dice] [new-board '()]) ([t board])
    (if (and (= (territory-player t) player)
             (< (territory-dice t) DICE#)
             (not (zero? dice)))
        (values (- dice 1) (cons (add-dice-to t) new-board))
        (values dice (cons t new-board)))))

;; Territory -> Territory
;; adds one dice to the given territory
(define (add-dice-to t)
  (territory-set-dice t (add1 (territory-dice t))))

;; Board Player Territory Natural -> Boolean
;; can player attack dst from src?
(define (attackable? board player src dst)
  (define dst-t
    (findf (lambda (t) (= (territory-index t) dst)) board))
  (and dst-t
       (= (territory-player src) player)
       (not (= (territory-player dst-t) player))
       (> (territory-dice src) (territory-dice dst-t))))

;; Board Natural Natural Natural Natural -> Board
;; Creates a new board after an attack
;; updates only src and dst
(define (execute board player src dst dice)
  (for/list ([t board])
    (define idx (territory-index t))
    (cond [(= idx src) (territory-set-dice t 1)]
          [(= idx dst)
           (define s (territory-set-dice t (- dice 1)))
           (territory-set-player s player)]
          [else t])))

;; Getting Neigbors

;; Natural -> [List-of Natural]
;; returns the neighbors of the current spot
;; > (neighbors 0)
;; '(1 2 3)
(define (neighbors pos)
  (define top?      (< pos BOARD))
  (define bottom?   (= (get-row pos) (sub1 BOARD)))
  (define even-row? (zero? (modulo (get-row pos) 2)))
  (define right?    (zero? (modulo (add1 pos) BOARD)))
  (define left?     (zero? (modulo pos BOARD)))
  (if even-row?
      (even-row pos top? bottom? right? left?)
      (odd-row  pos top? bottom? right? left?)))

;; Natural Boolean Boolean Boolean Boolean -> [Listof Naturals]
;; gets the neighbors for a territory on an even row
(define (even-row pos top? bottom? right? left?)
  (append (add (or top? right?)    (add1 (- pos BOARD)))
          (add (or bottom? right?) (add1 (+ pos BOARD)))
          (add top?                (- pos BOARD))
          (add bottom?             (+ pos BOARD))
          (add right?              (add1 pos))
          (add left?               (sub1 pos))))

;; Natural Boolean Boolean Boolean Boolean -> [Listof Naturals]
;; gets the neighbors for a territory on an even odd
(define (odd-row pos top? bottom? right? left?)
  (append (add top?               (- pos BOARD))
          (add bottom?            (+ pos BOARD))
          (add (or top? left?)    (sub1 (- pos BOARD)))
          (add (or bottom? left?) (sub1 (+ pos BOARD)))
          (add right?             (add1 pos))
          (add left?              (sub1 pos))))

;; Boolean X -> [Listof X]
;; returns (list x) if (not b) else empty
(define (add b x)
  (if b '() (list x)))
