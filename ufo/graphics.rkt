#lang racket

(provide (all-defined-out))

(require racket/gui/base
         racket/runtime-path)

(define-runtime-path UFO-PATH "ufo.png")

(define IMAGE-of-UFO (make-object bitmap% UFO-PATH 'png/alpha))
