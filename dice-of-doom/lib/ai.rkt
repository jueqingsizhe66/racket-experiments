#lang racket

(require "constants.rkt"
         "data.rkt"
         "auxiliary.rkt")

(provide (all-defined-out))

;; Player -> {AI-TURN, YOUR-TURN}
(define (whose-turn player)
  (if (= player AI) AI-TURN YOUR-TURN))

;; DiceWorld -> DiceWorld
;; executes a passing move on the world state
(define (pass w)
  (define m (find-move (game-moves (dice-world-gt w)) '()))
  (cond [(not m) w]
        [(or (no-more-moves? m) (not (= (game-player m) AI)))
         (dice-world #f (game-board m) m)]
        [else
          (define ai (the-ai-plays m))
          (dice-world #f (game-board ai) ai)]))

;; GameTree -> GameTree
;; Computer calls this function until it is no longer the player
(define (the-ai-plays tree)
  (define ratings (rate-moves tree AI-DEPTH))
  (define the-move (first (argmax second ratings)))
  (define new-tree (move-gt the-move))
  (if (= (game-player new-tree) AI)
      (the-ai-plays new-tree)
      new-tree))

;; GameTree Natural -> [List-of (List Move Number)]
;; assigns a value to each move that is being considered
;; and return those values in a list
(define (rate-moves tree depth)
  (for/list ([move (game-moves tree)])
    (list move (rate-position (move-gt move) (- depth 1)))))

;; GameTree Natural -> Number
;; Returns a number that is the best move for the given player.
(define (rate-position tree depth)
  (cond [(or (= depth 0) (no-more-moves? tree))
         (define-values (best w) (winners (game-board tree)))
         (if (member AI w) (/ 1 (length w)) 0)]
        [else
         (define ratings (rate-moves tree depth))
         (apply (if (= (game-player tree) AI) max min)
                (map second ratings))]))
