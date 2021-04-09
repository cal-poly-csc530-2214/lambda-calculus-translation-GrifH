#lang typed/racket
(require typed/rackunit)
;; Types and Structs

;ExprC represents an operation the can produce a Real
(define-type ExprC (U numC binop AppC ifleq0 id LamC assignC))
(struct numC ([n : Real]) #:transparent)
(struct binop ([op : Symbol] [l : ExprC] [r : ExprC]) #:transparent)
(struct ifleq0 ([if : ExprC] [then : ExprC] [else : ExprC]) #:transparent)
(struct id ([sym : Symbol]) #:transparent)
(struct LamC ([param : id] [body : ExprC]) #:transparent)
(struct AppC ([func : ExprC] [arg : ExprC]) #:transparent)
(struct assignC ([label : id] [body : ExprC]) #:transparent)

;predicates for helping with parse
(define isop? (lambda (s) (or (eq? s '+) (eq? s '-) (eq? s '*) (eq? s '/))))
(define notkeyword? (lambda (s)
                      (and (symbol? s)
                           (not (eq? s '+)) (not (eq? s '-)) (not (eq? s '*)) (not (eq? s '/))
                           (not (eq? s 'ifleq0)) (not (eq? s 'def)))))

;top-interp combines parsing and evaluating by taking a S-expression and returning a real.
(define (top-interp [prog : Sexp]) : String
  (interp (parse prog)))

;interp-script takes what is assumed to be a list of LC programs, processes them all, and prints them out as instructions.
(define (interp-script [progs : (Listof Sexp)]) : Void
  (fprintf (current-output-port) (string-join (map interp (map parse progs)) "~n")))


(define (interp [e : ExprC]) : String
  (match e
    [(numC n) (number->string n)]
    [(id sym) (symbol->string sym)]
    [(binop s l r) (string-append "(" (interp l) (symbol->string s) (interp r) ")")]
    [(ifleq0 if then else) (string-append "(" (interp then) " if " (interp if) " == 0 else " (interp else) ")")]
    [(AppC f a) (string-append (interp f) "(" (interp a) ")")]
    [(LamC p b) (string-append "(lambda " (interp p) " : " (interp b) ")")]
    [(assignC label body) (string-append (interp label) " = " (interp body))]))

;parse takes an s-expression and attempts to convert it to an ExprC
(define (parse [s : Sexp]) : ExprC
  (match s
    [(? notkeyword? s) (id s)]
    [(? real? r) (numC r)]
    [(list '/ (? notkeyword? p) '=> body) (LamC (id p) (parse body))]
    [(list 'ifleq0 if then else) (ifleq0 (parse if) (parse then) (parse else))]
    [(list (? isop? s) l r) (binop s (parse l) (parse r))]
    [(list (? list? s) l ) (AppC (parse s) (parse l))]
    [(list (? notkeyword? s) l ) (AppC (parse s) (parse l))]
    [(list '= (? notkeyword? s) b) (assignC (id s) (parse b))]
    [other (error "LC: Could not parse" s)]))

;top-interp
(check-equal? (top-interp '(+ 5 2)) "(5+2)")
(check-equal? (top-interp '((/ x => (* 5 (+ x 2))) 4)) "(lambda x : (5*(x+2)))(4)")
(check-equal? (top-interp '((/ x => (* 5 (+ x 2))) 4)) "(lambda x : (5*(x+2)))(4)")
(check-equal? (top-interp '((/ x => (ifleq0 x 1 0)) 1)) "(lambda x : (1 if x == 0 else 0))(1)")

;interp-script
(check-equal? (interp-script (list '(= a (+ 5 2)) '(* a 3) '(ifleq0 1 2 3) '(= f (/ x => (* 5 (+ x 2)))) '(f 4))) (void))

;parse
(check-equal? (parse '5) (numC 5))
(check-equal? (parse 'apple) (id 'apple))
(check-equal? (parse '(+ (* 4 3) (/ 4 2)))
              (binop '+ (binop '* (numC 4) (numC 3)) (binop '/ (numC 4) (numC 2))))
(check-equal? (parse '(ifleq0 (- 2 3) 1 0))
              (ifleq0 (binop '- (numC 2) (numC 3)) (numC 1) (numC 0)))
(check-equal? (parse '((/ x => (+ x 5)) 2)) (AppC (LamC (id 'x) (binop '+ (id 'x) (numC 5))) (numC 2)))

(check-exn (regexp (regexp-quote "LC: Could not parse (5 two)"))
           (lambda () (parse '(5 two))))
(check-exn (regexp (regexp-quote "LC: Could not parse"))
           (lambda () (parse '(+))))
(check-exn (regexp (regexp-quote "LC: Could not parse"))
           (lambda () (parse '(+ / 4))))
(check-exn (regexp (regexp-quote "LC: Could not parse"))
           (lambda () (parse '(/ 2 3 4))))