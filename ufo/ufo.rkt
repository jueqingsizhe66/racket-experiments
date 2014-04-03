#lang racket

(require "graphics.rkt"
         2htdp/universe
         2htdp/image)

;;;;;;;;;;;;;;;
;; Constants ;;
;;;;;;;;;;;;;;;

(define GAME-TITLE "UFO: Enemy Unknown :)")
(define WIDTH 200)
(define HEIGHT 300)
(define HALF-of_UFO (/ (image-width IMAGE-of-UFO) 2))
(define LEFT-EDGE-X   (- 0 HALF-of_UFO))
(define RIGHT-EDGE-X  (+ WIDTH HALF-of_UFO))
(define TOP-EDGE-Y    (- 0 HALF-of_UFO))
(define BOTTOM-EDGE-Y (+ HEIGHT HALF-of_UFO))
(define SPEED 3)

(define START-X (/ WIDTH 2))
(define START-Y (/ HEIGHT 2))
(define START-DIRECTION 'down)

;;;;;;;;;;
;; Main ;;
;;;;;;;;;;

(define (start x y direction)
  (big-bang (position x y direction)
            (name GAME-TITLE)
            (on-tick modify-state)
            (on-key handle-key)
            (to-draw render))
  (void))

;;;;;;;;;;;
;; State ;;
;;;;;;;;;;;

;; Keep track of lower and upper bounds
(struct position (x y direction) #:transparent)

;;;;;;;;;;;;;;
;; Handlers ;;
;;;;;;;;;;;;;;

(define (modify-state current-state)
  (define current-x (position-x current-state))
  (define current-y (position-y current-state))
  (define current-direction (position-direction current-state))

  (cond
    [(equal? current-direction 'up)
     (cond [(<= current-y TOP-EDGE-Y) (position current-x BOTTOM-EDGE-Y current-direction)]
           [else (position current-x (- current-y SPEED) current-direction)]
     )]
    [(equal? current-direction 'down)
     (cond [(>= current-y BOTTOM-EDGE-Y) (position current-x TOP-EDGE-Y current-direction)]
           [else (position current-x (+ current-y SPEED) current-direction)]
     )]
    [(equal? current-direction 'left)
     (cond [(<= current-x LEFT-EDGE-X) (position RIGHT-EDGE-X current-y current-direction)]
           [else (position (- current-x SPEED) current-y current-direction)]
     )]
    [else ; right
     (cond [(>= current-x RIGHT-EDGE-X) (position LEFT-EDGE-X current-y current-direction)]
           [else (position (+ current-x SPEED) current-y current-direction)]
     )]
  ))

(define (handle-key current-state key)
  (define current-x (position-x current-state))
  (define current-y (position-y current-state))
  (define current-direction (position-direction current-state))

  (cond [(key=? key "up")    (position current-x current-y 'up)]
        [(key=? key "down")  (position current-x current-y 'down)]
        [(key=? key "left")  (position current-x current-y 'left)]
        [(key=? key "right") (position current-x current-y 'right)]
        [else current-state]))

;;;;;;;;;;;;;;;
;; Rendering ;;
;;;;;;;;;;;;;;;

(define (render current-state)
  (define current-x (position-x current-state))
  (define current-y (position-y current-state))
  (define smoke-x (- current-x 30))
  (define smoke-y (- current-y 30))

  (place-image IMAGE-of-UFO
               current-x
               current-y (empty-scene WIDTH HEIGHT)))

;;;;;;;;;;;;;
;; Autorun ;;
;;;;;;;;;;;;;

(start START-X START-Y START-DIRECTION)
