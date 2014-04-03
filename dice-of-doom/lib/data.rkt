#lang racket

(provide (all-defined-out))

(struct dice-world (src board gt) #:transparent)
;; DiceWorld = (dice-world (U #false Natural) Board GameTree)
;; in (dice-world i b gt)
;; -- if i is a Natural, it is an index for the territory that the player has marked for an attack
;; -- if i is #f, no territory has been marked yet
;; b is the current board
;; gt is the game-tree for the given i and b

(define-values (game game? game-board game-player game-moves)
  (let ()
    (struct game (board player delayed-moves) #:transparent)
    (values game
            game?
            game-board
            game-player
            (lambda (g) (force (game-delayed-moves g))))))
;; GameTree = (game Board Player [Listof Move])
;; in (game-tree b p lm)
;; -- b is the current board
;; -- p is the current player
;; -- lm is the list of moves that that player may execute

;; Board = [List-of Territory]
;; the first field in the list is the currently marked  territory

;; Player ∈ [0, PLAYER#) | Natural

(struct move (action gt) #:transparent)
;; Move = (move Action GameTree)
;; in (move a gt)
;; -- a represents the actione to be takem
;; -- gt is the game-tree resulting from that action

;; Action is one of:
;; -- '()                      a passing move
;; -- (list Natural Natural)   the move where the first attacks the second

(struct territory (index player dice x y) #:transparent)
;; Territory = (territory Natural Player Dice Integer Integer)
;; in (territory i p d x y)
;; -- i is a unique identifier for the territory; it also determines its initial location
;; -- p is the player who owns this territory
;; -- d is the number of dice on this board
;; -- x is the x coordiate of this territory in pixels
;; -- y is the y coordiate of this territory in pixels

;; Territory Natural -> Territory
;; updates number of dice on territory
(define (territory-set-dice t d)
  (territory (territory-index t) (territory-player t) d (territory-x t) (territory-y t)))

;; Territory Player -> Territory
;; updates owner of territory
(define (territory-set-player t p)
  (territory (territory-index t) p (territory-dice t) (territory-x t) (territory-y t)))
