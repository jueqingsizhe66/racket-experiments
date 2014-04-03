#lang racket

(require "data.rkt"
         "auxiliary.rkt")

(provide (all-defined-out))

;; Territory Focusing and Marking

;; DiceWorld [Board -> Board] -> World
;; Creates a new World that has a rotated territory list
;; > (define lterritory (territory 0 0 1 9 2))
;; > (define rterritory (territory 0 0 1 9 0))
;; > (refocus-board-action (dice-world -1 (list rterritory lterritory ...) GT) left)
;; (dice-world -1 (list lterritory ... rterritory) GT)
;; > (refocus-board-action (dice-world -1 (list lterritory ... rterritory) GT) left)
;; (dice-world -1 (list rterritory lterritory ...) GT)
(define (refocus-board w direction)
  (define source (dice-world-src w))
  (define board  (dice-world-board w))
  (define tree   (dice-world-gt w))
  (define player (game-player tree))
  (define (owner? tid)
    (if source (not (= tid player)) (= tid player)))
  (define new-board (rotate-until owner? board direction))
  (dice-world source new-board tree))

;; [Player -> Boolean] Board (Board -> Board) -> Board
;; rotate until the first element of the list satisfies owned-by
(define (rotate-until owned-by board rotate)
  (define next-list (rotate board))
  (if (owned-by (territory-player (first next-list)))
      next-list
      (rotate-until owned-by next-list rotate)))

;; Board -> Board
;; rotate a list to the left
(define (left l)
  (append (rest l) (list (first l))))

;; Board -> Board
;; rotate a list to the right
(define (right l)
  (reverse (left (reverse l))))

;; Handling Moves

;; DiceWorld -> DiceWorld
;; marks a territory as the launching pad for an attack or launches the attack
(define (mark w)
  (define tree   (dice-world-gt w))
  (define board  (dice-world-board w))
  (define source (dice-world-src w))
  (define focus  (territory-index (first board)))
  (if source
      (attacking w source focus)
      (dice-world focus board tree)))

;; DiceWorld Natural Natural -> DiceWorld
(define (attacking w source target)
  (define feasible (game-moves (dice-world-gt w)))
  (define attack   (list source target))
  (define next     (find-move feasible attack))
  (if next (dice-world #f (game-board next) next) w))

;; DiceWorld -> DiceWorld
;; unmarks a marked territory
(define (unmark w)
  (dice-world #f (dice-world-board w) (dice-world-gt w)))
