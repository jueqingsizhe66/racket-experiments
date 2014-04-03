#lang racket

(require "constants.rkt"
         "data.rkt"
         "ai.rkt"
         "auxiliary.rkt"
         2htdp/image)

(provide (all-defined-out))

;; DiceWorld -> Image
;; render the endgame screen
(define (draw-end-of-dice-world w)
  (define board (dice-world-board w))
  (define message (text (won board) TEXT-SIZE TEXT-COLOR))
  (define background (add-board-to-scene w (PLAIN)))
  (overlay message background))

;; Player Scene-> Scene
;; Draws the world
(define (add-player-info player s)
  (define str (whose-turn player))
  (define txt (text str TEXT-SIZE TEXT-COLOR))
  (place-image txt (- WIDTH INFO-X-OFFSET) INFO-Y-OFFSET s))

;; DiceWorld Scene -> Scene
;; folds through the board and creates an image representation of it
(define (add-board-to-scene w s)
  (define board   (dice-world-board w))
  (define player  (game-player (dice-world-gt w)))
  (define focus?  (dice-world-src w))
  (define trtry1  (first board))
  (define p-focus (territory-player trtry1))
  (define t-image (draw-territory trtry1))
  (define image   (draw-focus focus? p-focus player t-image))
  (define base-s  (add-territory trtry1 image s))
  (for/fold ([s base-s]) ([t (rest board)])
    (add-territory t (draw-territory t) s)))

;; Nat Player Player Image -> Image
;; add focus marker to territory if needed
(define (draw-focus marked? p-in-focus p t-image)
  (if (or (and (not marked?) (= p-in-focus p))
          (and marked? (not (= p-in-focus p))))
      (overlay FOCUS t-image)
      t-image))

;; Image Territory Image -> Image
(define (add-territory t image scene)
  (place-image image (territory-x t) (territory-y t) scene))

;; Territory -> Image
;; renders a single territory
(define (draw-territory t)
  (define color (color-chooser (territory-player t)))
  (overlay (hexagon color) (draw-dice (territory-dice t))))

;; Natural -> Image
;; renders all n >= 1 dice as a stack of dice
(define (draw-dice n)
  (define first-dice (get-dice-image 0))
  (define height-dice (image-height first-dice))
  (for/fold ([s first-dice]) ([i (- n 1)])
    (define dice-image (get-dice-image (+ i 1)))
    (define y-offset (* height-dice (+ 0.5 (* i 0.25))))
    (overlay/offset s 0 y-offset dice-image)))

;; Player -> Color
;; Determines a color for each player
(define (color-chooser n)
  (list-ref COLORS n))

;; -> Image
;; returns an image from the list of dice images
(define (get-dice-image i)
  (list-ref IMG-LIST (modulo i (length IMG-LIST))))
