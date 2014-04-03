#lang racket

(require "constants.rkt"
         "data.rkt"
         "auxiliary.rkt"
         "ai.rkt"
         "init.rkt"
         "key-events.rkt"
         "rendering.rkt"
         (except-in 2htdp/universe left right))

(provide (all-defined-out))

;; Start the game
(define (roll-the-dice)
  (big-bang (create-world-of-dice-and-doom)
            (name GAME-TITLE)
            (on-key interact-with-board)
            (to-draw draw-dice-world)
            (stop-when no-more-moves-in-world?
                       draw-end-of-dice-world))
  (sleep 2))

;;  -> DiceWorld
;; Returns a randomly generated world. If the world that
;; has been generated starts as a tie, the world is regenerated.
;; property: world is not in endgame state (no-more-moves? returns false)
(define (create-world-of-dice-and-doom)
  (define board (territory-build))
  (define gamet (game-tree board INIT-PLAYER INIT-SPARE-DICE))
  (define new-world (dice-world #f board gamet))
  (if (no-more-moves-in-world? new-world)
      (create-world-of-dice-and-doom)
      new-world))

;; DiceWorld Key -> DiceWorld
;; Handles key events from a player
(define (interact-with-board w k)
  (cond [(key=? "left" k)
         (refocus-board w left)]
        [(key=? "right" k)
         (refocus-board w right)]
        [(key=? "p" k)
         (pass w)]
        [(key=? "\r" k)
         (mark w)]
        [(key=? "d" k)
         (unmark w)]
        [else w]))

;; Diceworld -> Scene
;; draws the world
(define (draw-dice-world w)
  (add-player-info
    (game-player (dice-world-gt w))
    (add-board-to-scene w (ISCENE))))

;; DiceWorld -> Boolean
;; is it possible to play any moves from this world state?
(define (no-more-moves-in-world? w)
  (define tree (dice-world-gt w))
  (define board (dice-world-board w))
  (define player (game-player tree))
  (or (no-more-moves? tree)
      (for/and ((t board)) (= (territory-player t) player))))
