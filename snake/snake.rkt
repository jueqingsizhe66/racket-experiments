#lang racket

(require "graphics.rkt"
         2htdp/image
         2htdp/universe)

;;;;;;;;;;
;; Data ;;
;;;;;;;;;;

;; Pit is the whole level, snake is the snake object,
;; goos is a list of goo objects.
(struct pit (snake goos) #:transparent)

;; Snake has a direction: "up", "down", "left", "right",
;; and a list of segments (posn objects).
(struct snake (dir segs) #:transparent)

;; Goos have a location (posn object) and a number of click
;; ticks before they expire.
(struct goo (loc expire) #:transparent)

;; Simple 2D point, part of the snake.
(struct posn (x y) #:transparent)

;;;;;;;;;;;;;;;
;; Constants ;;
;;;;;;;;;;;;;;;

(define GAME-TITLE "Snake")

;; Tick Rate
(define TICK-RATE 1/10)

;; Board Size Constants
(define SIZE 30)

;; Snake Constants
(define SEG-SIZE 15)

;; Goo Constants
(define MAX-GOO 5)
(define EXPIRATION-TIME 150)

;; Graphical Board
(define WIDTH-PX  (* SEG-SIZE 30))
(define HEIGHT-PX (* SEG-SIZE 30))

;; Visual Constants
(define MT-SCENE (empty-scene WIDTH-PX HEIGHT-PX))

(define HEAD-LEFT-IMG  HEAD-IMAGE)
(define HEAD-DOWN-IMG  (rotate 90 HEAD-LEFT-IMG))
(define HEAD-RIGHT-IMG (flip-horizontal HEAD-LEFT-IMG))
(define HEAD-UP-IMG    (flip-vertical HEAD-DOWN-IMG))

(define ENDGAME-TEXT-SIZE 15)

;;;;;;;;;;
;; Main ;;
;;;;;;;;;;

;; Start the Game
(define (start-snake)
  (big-bang (pit (snake "right" (list (posn 1 1)))
                 (list (fresh-goo)
                       (fresh-goo)
                       (fresh-goo)
                       (fresh-goo)
                       (fresh-goo)
                       (fresh-goo)))
            (name GAME-TITLE)
            (on-tick next-pit TICK-RATE)
            (on-key direct-snake)
            (to-draw render-pit)
            (stop-when dead? render-end))
  (sleep 2))

;;;;;;;;;;;;;;;;;
;; Clock Ticks ;;
;;;;;;;;;;;;;;;;;

;; One step: eat or slither
(define (next-pit w)
  (define snake (pit-snake w))
  (define goos  (pit-goos w))
  (define goo-to-eat (can-eat snake goos))
  (if goo-to-eat
      (pit (grow snake) (age-goo (eat goos goo-to-eat)))
      (pit (slither snake) (age-goo goos))))

(define (can-eat snake goos)
  (define head (snake-head snake))
  (ormap (lambda (g) (and (close? head g) g)) goos))

(define (close? s g)
  (posn=? s (goo-loc g)))

(define (eat goos goo-to-eat)
  (cons (fresh-goo) (remove goo-to-eat goos)))

(define (grow sn)
  (snake (snake-dir sn)
         (cons (next-head sn) (snake-segs sn))))

(define (slither sn)
  (snake (snake-dir sn)
         (cons (next-head sn) (all-but-last (snake-segs sn)))))

(define (all-but-last segs)
  (define rest-segs (rest segs))
  (cond [(empty? rest-segs) empty]
        [else (cons (first segs) (all-but-last rest-segs))]))

(define (next-head sn)
  (define head (snake-head sn))
  (define dir  (snake-dir sn))
  (cond [(string=? dir "up") (posn-move head 0 -1)]
        [(string=? dir "down") (posn-move head 0 1)]
        [(string=? dir "left") (posn-move head -1 0)]
        [(string=? dir "right") (posn-move head 1 0)]))

(define (posn-move p dx dy)
  (posn (+ (posn-x p) dx)
        (+ (posn-y p) dy)))

(define (age-goo goos)
  (rot (renew goos)))

(define (rot goos)
  (map decay goos))

(define (renew goos)
  (map (lambda (f) (if (rotten? f) (fresh-goo) f))
       goos))

(define (rotten? g)
  (zero? (goo-expire g)))

(define (decay g)
  (goo (goo-loc g) (sub1 (goo-expire g))))

(define (fresh-goo)
  (goo (posn (add1 (random (sub1 SIZE)))
             (add1 (random (sub1 SIZE))))
       ; EXPIRATION-TIME))
       (add1 (random EXPIRATION-TIME))))

;;;;;;;;;;;;;;;;
;; Key Events ;;
;;;;;;;;;;;;;;;;

(define (direct-snake w ke)
  (cond [(dir? ke) (world-change-dir w ke)]
        [else w]))

(define (dir? x)
  (or (key=? x "up")
      (key=? x "down")
      (key=? x "left")
      (key=? x "right")))

(define (world-change-dir w d)
  (define the-snake (pit-snake w))
  (cond [(and (opposite-dir? (snake-dir the-snake) d)
              ;; consists of the head and at least one segment
              (cons? (rest (snake-segs the-snake))))
         (stop-with w)]
        [else
         (pit (snake-change-dir the-snake d) (pit-goos w))]))

(define (opposite-dir? d1 d2)
  (cond [(string=? d1 "up") (string=? d2 "down")]
        [(string=? d1 "down") (string=? d2 "up")]
        [(string=? d1 "left") (string=? d2 "right")]
        [(string=? d1 "right") (string=? d2 "left")]))

;;;;;;;;;;;;;;;
;; Rendering ;;
;;;;;;;;;;;;;;;

(define (render-pit w)
  (snake+scene (pit-snake w)
               (goo-list+scene (pit-goos w) MT-SCENE)))

(define (snake+scene snake scene)
  (define snake-body-scene
    (img-list+scene (snake-body snake) BODY-IMAGE scene))
  (define dir (snake-dir snake))
  (img+scene (snake-head snake)
             (cond [(string=? "up" dir)    HEAD-UP-IMG]
                   [(string=? "down" dir)  HEAD-DOWN-IMG]
                   [(string=? "left" dir)  HEAD-LEFT-IMG]
                   [(string=? "right" dir) HEAD-RIGHT-IMG])
             snake-body-scene))

(define (img-list+scene posns img scene)
  (foldr (lambda (p s) (img+scene p img s)) scene posns))

(define (img+scene posn img scene)
  (place-image img
               (* (posn-x posn) SEG-SIZE)
               (* (posn-y posn) SEG-SIZE)
               scene))

(define (goo-list+scene goos scene)
  (define (get-posns-from-goo goos)
    (map goo-loc goos))
  (img-list+scene (get-posns-from-goo goos) GOO-IMAGE scene))

;;;;;;;;;;;;;;
;; End Game ;;
;;;;;;;;;;;;;;

(define (dead? w)
  (define snake (pit-snake w))
  (or (self-colliding? snake) (wall-colliding? snake)))

(define (render-end w)
  (overlay (text "Game Over" ENDGAME-TEXT-SIZE "black")
           (render-pit w)))

(define (self-colliding? snake)
  (cons? (member (snake-head snake) (snake-body snake))))

(define (wall-colliding? snake)
  (define x (posn-x (snake-head snake)))
  (define y (posn-y (snake-head snake)))
  (or (= 0 x) (= x SIZE)
      (= 0 y) (= y SIZE)))

;;;;;;;;;;;;;;;;;;;;;;;;;
;; Auxiliary Functions ;;
;;;;;;;;;;;;;;;;;;;;;;;;;

(define (posn=? p1 p2)
  (and (= (posn-x p1) (posn-x p2))
       (= (posn-y p1) (posn-y p2))))

(define (snake-head sn)
  (first (snake-segs sn)))

(define (snake-body sn)
  (rest (snake-segs sn)))

(define (snake-tail sn)
  (last (snake-segs sn)))

(define (snake-change-dir sn d)
  (snake d (snake-segs sn)))

;;;;;;;;;;;;;
;; Autorun ;;
;;;;;;;;;;;;;

(start-snake)
