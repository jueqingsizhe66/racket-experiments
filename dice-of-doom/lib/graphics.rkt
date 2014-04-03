#lang racket

(require racket/gui/base
         racket/runtime-path)

(provide DICE1
         DICE2
         DICE3
         DICE4)

;; Dir
(define-for-syntax GRAPHICS-PATH (build-path ".." "graphics"))
(define            GRAPHICS-PATH (build-path ".." "graphics"))

;; Paths
(define-runtime-path DICE1-PATH (build-path GRAPHICS-PATH "dice1.png"))
(define-runtime-path DICE2-PATH (build-path GRAPHICS-PATH "dice2.png"))
(define-runtime-path DICE3-PATH (build-path GRAPHICS-PATH "dice3.png"))
(define-runtime-path DICE4-PATH (build-path GRAPHICS-PATH "dice4.png"))

;; Images
(define DICE1 (make-object bitmap% DICE1-PATH 'png/alpha))
(define DICE2 (make-object bitmap% DICE2-PATH 'png/alpha))
(define DICE3 (make-object bitmap% DICE3-PATH 'png/alpha))
(define DICE4 (make-object bitmap% DICE4-PATH 'png/alpha))
