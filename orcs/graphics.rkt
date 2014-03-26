#lang racket

(provide (all-defined-out))

(require racket/gui/base
         racket/runtime-path)

(define-for-syntax GRAPHICS-PATH "graphics")
(define            GRAPHICS-PATH "graphics")

(define-runtime-path orc-path     (build-path GRAPHICS-PATH "orc.png"))
(define-runtime-path hydra-path   (build-path GRAPHICS-PATH "hydra.png"))
(define-runtime-path slime-path   (build-path GRAPHICS-PATH "slime.bmp"))
(define-runtime-path brigand-path (build-path GRAPHICS-PATH "brigand.bmp"))
(define-runtime-path player-path  (build-path GRAPHICS-PATH "player.bmp"))

;; Monsters
(define ORC     (make-object bitmap% orc-path     'png/alpha))
(define HYDRA   (make-object bitmap% hydra-path   'png/alpha))
(define SLIME   (make-object bitmap% slime-path   'bmp/alpha))
(define BRIGAND (make-object bitmap% brigand-path 'bmp/alpha))

;; Player
(define PLAYER-IMAGE (make-object bitmap% player-path 'bmp/alpha))
