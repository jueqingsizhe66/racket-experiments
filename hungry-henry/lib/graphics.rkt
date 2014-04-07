#lang racket

(require racket/gui/base
         racket/runtime-path)

(provide FOOD-IMG
         PLAYER-IMG)

;; Dir
(define-for-syntax GRAPHICS-PATH (build-path ".." "graphics"))
(define            GRAPHICS-PATH (build-path ".." "graphics"))

;; Paths
(define-runtime-path FOOD-IMG-PATH   (build-path GRAPHICS-PATH "cupcake.gif"))
(define-runtime-path PLAYER-IMG-PATH (build-path GRAPHICS-PATH "hungry-henry.gif"))

;; Images
(define FOOD-IMG   (make-object bitmap% FOOD-IMG-PATH 'gif/mask))
(define PLAYER-IMG (make-object bitmap% PLAYER-IMG-PATH 'gif/mask))
