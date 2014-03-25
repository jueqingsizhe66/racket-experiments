#lang racket

(provide (all-defined-out))

(require racket/gui/base
         racket/runtime-path)

(define-for-syntax GRAPHICS-PATH "graphics")
(define            GRAPHICS-PATH "graphics")


(define-runtime-path body-path (build-path GRAPHICS-PATH "body.gif"))
(define-runtime-path goo-path  (build-path GRAPHICS-PATH "goo.gif"))
(define-runtime-path head-path (build-path GRAPHICS-PATH "head.gif"))
; (define-runtime-path tail-path (build-path GRAPHICS-PATH "tail.gif"))

(define BODY-IMAGE (make-object bitmap% body-path 'gif/mask))
(define GOO-IMAGE  (make-object bitmap% goo-path  'gif/mask))
(define HEAD-IMAGE (make-object bitmap% head-path 'gif/mask))
; (define TAIL-IMAGE (make-object bitmap% tail-path 'gif/mask))
