;;;; SPDX-FileCopyrightText: 2014 John Cowan <cowan@ccil.org>
;;;;
;;;; SPDX-License-Identifier: MIT

(import
  (scheme base)
  (srfi 128)
  (ilists ilists))

(cond-expand
  (chibi
   (import (rename (except (chibi test) test-equal)
                   (test test-equal*))))
  (else
   (import (rename (srfi 64) (test-equal test-equal*)))))

(define (test-equal a b)
  (cond
    ((and (pair? a) (pair? b))
     (begin
       (test-equal (car a) (car b))
       (test-equal (cdr a) (cdr b))))
    ((and (vector? a) (vector? b))
     (vector-for-each
       test-equal
       a
       b))
    ((and (ipair? a) (ipair? b))
     (begin
       (test-equal (icar a) (icar b))
       (test-equal (icdr a) (icdr b))))
    (else (test-equal* a b))))

(test-begin "ilists")

(test-group "ilists/constructors"
  (define abc (ilist 'a 'b 'c))
  (define abc-dot-d (ipair* 'a 'b 'c 'd))
  (define abc-copy (ilist-copy abc))
  (test-equal 'a (icar abc))
  (test-equal 'b (icadr abc))
  (test-equal 'c (icaddr abc))
  (test-equal (ipair 2 1) (xipair 1 2))
  (test-equal 'd (icdddr abc-dot-d))
  (test-equal (iq c c c c) (make-ilist 4 'c))
  (test-equal (iq 0 1 2 3) (ilist-tabulate 4 values))
  (test-equal (iq 0 1 2 3 4) (iiota 5))
  (test-equal abc abc-copy)
  (test-assert (not (eq? abc abc-copy)))
) ; end ilists/constructors

(test-group "ilists/predicates"
  (test-assert (ipair? (ipair 1 2)))
  (test-assert (proper-ilist? '()))
  (test-assert (proper-ilist? (iq 1 2 3)))
  (test-assert (ilist? '()))
  (test-assert (ilist? (iq 1 2 3)))
  (test-assert (dotted-ilist? (ipair 1 2)))
  (test-assert (dotted-ilist? 2))
  (test-assert (null-ilist? '()))
  (test-assert (not (null-ilist? (iq 1 2 3))))
  (test-error (null-ilist? 'a))
  (test-assert (not-ipair? 'a))
  (test-assert (not (not-ipair? (ipair 'a 'b))))
  (test-assert (ilist= = (iq 1 2 3) (iq 1 2 3)))
  (test-assert (ilist= = (iq 1 2 3) (iq 1 2 3) (iq 1 2 3)))
  (test-assert (not (ilist= = (iq 1 2 3 4) (iq 1 2 3))))
  (test-assert (not (ilist= = (iq 1 2 3) (iq 1 2 3 4))))
  (test-assert (ilist= = (iq 1 2 3) (iq 1 2 3)))
  (test-assert (not (ilist= = (iq 1 2 3) (iq 1 2 3 4) (iq 1 2 3 4))))
  (test-assert (not (ilist= = (iq 1 2 3) (iq 1 2 3) (iq 1 2 3 4))))
) ; end ilist/predicates

(test-group "ilist/cxrs"
  (define ab (ipair 'a 'b))
  (define cd (ipair 'c 'd))
  (define ef (ipair 'e 'f))
  (define gh (ipair 'g 'h))
  (define abcd (ipair ab cd))
  (define efgh (ipair ef gh))
  (define abcdefgh (ipair abcd efgh))
  (define ij (ipair 'i 'j))
  (define kl (ipair 'k 'l))
  (define mn (ipair 'm 'n))
  (define op (ipair 'o 'p))
  (define ijkl (ipair ij kl))
  (define mnop (ipair mn op))
  (define ijklmnop (ipair ijkl mnop))
  (define abcdefghijklmnop (ipair abcdefgh ijklmnop))
  (test-equal 'a (icaar abcd))
  (test-equal 'b (icdar abcd))
  (test-equal 'c (icadr abcd))
  (test-equal 'd (icddr abcd))
  (test-equal 'a (icaaar abcdefgh))
  (test-equal 'b (icdaar abcdefgh))
  (test-equal 'c (icadar abcdefgh))
  (test-equal 'd (icddar abcdefgh))
  (test-equal 'e (icaadr abcdefgh))
  (test-equal 'f (icdadr abcdefgh))
  (test-equal 'g (icaddr abcdefgh))
  (test-equal 'h (icdddr abcdefgh))
  (test-equal 'a (icaaaar abcdefghijklmnop))
  (test-equal 'b (icdaaar abcdefghijklmnop))
  (test-equal 'c (icadaar abcdefghijklmnop))
  (test-equal 'd (icddaar abcdefghijklmnop))
  (test-equal 'e (icaadar abcdefghijklmnop))
  (test-equal 'f (icdadar abcdefghijklmnop))
  (test-equal 'g (icaddar abcdefghijklmnop))
  (test-equal 'h (icdddar abcdefghijklmnop))
  (test-equal 'i (icaaadr abcdefghijklmnop))
  (test-equal 'j (icdaadr abcdefghijklmnop))
  (test-equal 'k (icadadr abcdefghijklmnop))
  (test-equal 'l (icddadr abcdefghijklmnop))
  (test-equal 'm (icaaddr abcdefghijklmnop))
  (test-equal 'n (icdaddr abcdefghijklmnop))
  (test-equal 'o (icadddr abcdefghijklmnop))
  (test-equal 'p (icddddr abcdefghijklmnop))
) ; end ilists/cxrs

(test-group "ilists/selectors"
  (define ten (ilist 1 2 3 4 5 6 7 8 9 10))
  (define abcde (iq a b c d e))
  (define dotted (ipair 1 (ipair 2 (ipair 3 'd))))
  (test-equal 'c (ilist-ref (iq a b c d) 2))
  (test-equal 1 (ifirst ten))
  (test-equal 2 (isecond ten))
  (test-equal 3 (ithird ten))
  (test-equal 4 (ifourth ten))
  (test-equal 5 (ififth ten))
  (test-equal 6 (isixth ten))
  (test-equal 7 (iseventh ten))
  (test-equal 8 (ieighth ten))
  (test-equal 9 (ininth ten))
  (test-equal 10 (itenth ten))
  (test-error (ilist-ref '() 2))
  (test-equal '(1 2) (call-with-values (lambda () (icar+icdr (ipair 1 2))) list))
  (test-equal (iq a b) (itake abcde 2))
  (test-equal (iq c d e) (idrop abcde 2))
  (test-equal (iq c d e) (ilist-tail abcde 2))
  (test-equal (iq 1 2) (itake dotted 2))
  (test-equal (ipair 3 'd) (idrop dotted 2))
  (test-equal (ipair 3 'd) (ilist-tail dotted 2))
  (test-equal 'd (idrop dotted 3))
  (test-equal 'd (ilist-tail dotted 3))
  (test-equal abcde (iappend (itake abcde 4) (idrop abcde 4)))
  (test-equal (iq d e) (itake-right abcde 2))
  (test-equal (iq a b c) (idrop-right abcde 2))
  (test-equal (ipair 2 (ipair 3 'd)) (itake-right dotted 2))
  (test-equal (iq 1) (idrop-right dotted 2))
  (test-equal 'd (itake-right dotted 0))
  (test-equal (iq 1 2 3) (idrop-right dotted 0))
  (test-equal abcde (call-with-values (lambda () (isplit-at abcde 3)) iappend))
  (test-equal 'c (ilast (iq a b c)))
  (test-equal (iq c) (last-ipair (iq a b c)))
) ; end ilists/selectors

(test-group "ilists/misc"
  (test-equal 0 (ilength '()))
  (test-equal 3 (ilength (iq 1 2 3)))
  (test-equal (iq x y) (iappend (iq x) (iq y)))
  (test-equal (iq a b c d) (iappend (iq a b) (iq c d)))
  (test-equal (iq a) (iappend '() (iq a)))
  (test-equal (iq x y) (iappend (iq x y)))
  (test-equal '() (iappend))
  (test-equal (iq a b c d) (iconcatenate (iq (a b) (c d))))
  (test-equal (iq c b a) (ireverse (iq a b c)))
  (test-equal (iq (e (f)) d (b c) a) (ireverse (iq a (b c) d (e (f)))))
  (test-equal (ipair 2 (ipair 1 'd)) (iappend-reverse (iq 1 2) 'd))
  (test-equal (iq (one 1 odd) (two 2 even) (three 3 odd))
    (izip (iq one two three) (iq 1 2 3) (iq odd even odd)))
  (test-equal (iq (1) (2) (3)) (izip (iq 1 2 3)))
  (test-equal (iq 1 2 3) (iunzip1 (iq (1) (2) (3))))
  (test-equal (iq (1 2 3) (one two three))
    (call-with-values
      (lambda () (iunzip2 (iq (1 one) (2 two) (3 three))))
      ilist))
  (test-equal (iq (1 2 3) (one two three) (a b c))
    (call-with-values
      (lambda () (iunzip3 (iq (1 one a) (2 two b) (3 three c))))
      ilist))
  (test-equal (iq (1 2 3) (one two three) (a b c) (4 5 6))
    (call-with-values
      (lambda () (iunzip4 (iq (1 one a 4) (2 two b 5) (3 three c 6))))
      ilist))
  (test-equal (iq (1 2 3) (one two three) (a b c) (4 5 6) (#t #f #t))
    (call-with-values
      (lambda () (iunzip5 (iq (1 one a 4 #t) (2 two b 5 #f) (3 three c 6 #t))))
      ilist))
  (test-equal 3 (icount even? (iq 3 1 4 1 5 9 2 5 6)))
  (test-equal 3 (icount < (iq 1 2 4 8) (iq 2 4 6 8 10 12 14 16)))
) ; end ilists/misc

(test-group "ilists/folds"
  ;; We have to be careful to test-equal both single-list and multiple-list
  ;; code paths, as they are different in this implementation.

  (define lis (iq 1 2 3))
  (define (z x y ans) (ipair (ilist x y) ans))
  (define squares (iq 1 4 9 16 25 36 49 64 81 100))
  (test-equal 6 (ifold + 0 lis))
  (test-equal (iq 3 2 1) (ifold ipair '() lis))
  (test-equal 2 (ifold
            (lambda (x count) (if (symbol? x) (+ count 1) count))
            0
            (iq a 0 b)))
  (test-equal 4 (ifold
            (lambda (s max-len) (max max-len (string-length s)))
            0
            (iq "ab" "abcd" "abc")))
  (test-equal 32 (ifold
             (lambda (a b ans) (+ (* a b) ans))
             0
             (iq 1 2 3)
             (iq 4 5 6)))
  (test-equal (iq (b d) (a c))
    (ifold z '() (iq a b) (iq c d)))
  (test-equal lis (ifold-right ipair '() lis))
  (test-equal (iq 0 2 4) (ifold-right
                   (lambda (x l) (if (even? x) (ipair x l) l))
                   '()
                   (iq 0 1 2 3 4)))
  (test-equal (iq (a c) (b d))
    (ifold-right z '() (iq a b) (iq c d)))
  (test-equal (iq (c) (b c) (a b c))
    (ipair-fold ipair '() (iq a b c)))
  (test-equal (iq ((b) (d)) ((a b) (c d)))
    (ipair-fold z '() (iq a b) (iq c d)))
  (test-equal (iq (a b c) (b c) (c))
    (ipair-fold-right ipair '() (iq a b c)))
  (test-equal (iq ((a b) (c d)) ((b) (d)))
    (ipair-fold-right z '() (iq a b) (iq c d)))
  (test-equal 5 (ireduce max 0 (iq 1 3 5 4 2 0)))
  (test-equal 1 (ireduce - 0 (iq 1 2)))
  (test-equal -1 (ireduce-right - 0 (iq 1 2)))
  (test-equal squares
   (iunfold (lambda (x) (> x 10))
     (lambda (x) (* x x))
     (lambda (x) (+ x 1))
     1))
  (test-equal squares
    (iunfold-right zero?
      (lambda (x) (* x x))
      (lambda (x) (- x 1))
      10))
  (test-equal (iq 1 2 3) (iunfold null-ilist? icar icdr (iq 1 2 3)))
  (test-equal (iq 3 2 1) (iunfold-right null-ilist? icar icdr (iq 1 2 3)))
  (test-equal (iq 1 2 3 4)
    (iunfold null-ilist? icar icdr (iq 1 2) (lambda (x) (iq 3 4))))
  (test-equal (iq b e h) (imap icadr (iq (a b) (d e) (g h))))
  (test-equal (iq b e h) (imap-in-order icadr (iq (a b) (d e) (g h))))
  (test-equal (iq 5 7 9) (imap + (iq 1 2 3) (iq 4 5 6)))
  (test-equal (iq 5 7 9) (imap-in-order + (iq 1 2 3) (iq 4 5 6)))
  (set! z (let ((count 0)) (lambda (ignored) (set! count (+ count 1)) count)))
  (test-equal (iq 1 2) (imap-in-order z (iq a b)))
  (test-equal '#(0 1 4 9 16)
    (let ((v (make-vector 5)))
      (ifor-each (lambda (i)
                  (vector-set! v i (* i i)))
                (iq 0 1 2 3 4))
    v))
  (test-equal '#(5 7 9 11 13)
    (let ((v (make-vector 5)))
      (ifor-each (lambda (i j)
                  (vector-set! v i (+ i j)))
                (iq 0 1 2 3 4)
                (iq 5 6 7 8 9))
    v))
  (test-equal (iq 1 -1 3 -3 8 -8)
    (iappend-map (lambda (x) (ilist x (- x))) (iq 1 3 8)))
  (test-equal (iq 1 4 2 5 3 6)
    (iappend-map ilist (iq 1 2 3) (iq 4 5 6)))
  (test-equal (vector (iq 0 1 2 3 4) (iq 1 2 3 4) (iq 2 3 4) (iq 3 4) (iq 4))
    (let ((v (make-vector 5)))
      (ipair-for-each (lambda (lis) (vector-set! v (icar lis) lis)) (iq 0 1 2 3 4))
    v))
  (test-equal (vector (iq 5 6 7 8 9) (iq 6 7 8 9) (iq 7 8 9) (iq 8 9) (iq 9))
    (let ((v (make-vector 5)))
      (ipair-for-each (lambda (i j) (vector-set! v (icar i) j))
                (iq 0 1 2 3 4)
                (iq 5 6 7 8 9))
    v))
  (test-equal (iq 1 9 49)
    (ifilter-map (lambda (x) (and (number? x) (* x x))) (iq a 1 b 3 c 7)))
  (test-equal (iq 5 7 9)
    (ifilter-map
      (lambda (x y) (and (number? x) (number? y) (+ x y)))
      (iq 1 a 2 b 3 4)
      (iq 4 0 5 y 6 z)))
) ; end ilists/folds

(test-group "ilists/filtering"
  (test-equal (iq 0 8 8 -4) (ifilter even? (iq 0 7 8 8 43 -4)))
  (test-equal (list (iq one four five) (iq 2 3 6))
    (call-with-values
      (lambda () (ipartition symbol? (iq one 2 3 four five 6)))
      list))
  (test-equal (iq 7 43) (iremove even? (iq 0 7 8 8 43 -4)))
) ; end ilists/filtering

(test-group "ilists/searching"
  (test-equal 2 (ifind even? (iq 1 2 3)))
  (test-equal #t (iany  even? (iq 1 2 3)))
  (test-equal #f (ifind even? (iq 1 7 3)))
  (test-equal #f (iany  even? (iq 1 7 3)))
  (test-error (ifind even? (ipair 1 (ipair 3 'x))))
  (test-error (iany  even? (ipair 1 (ipair 3 'x))))
  (test-equal 4 (ifind even? (iq 3 1 4 1 5 9)))
  (test-equal (iq -8 -5 0 0) (ifind-tail even? (iq 3 1 37 -8 -5 0 0)))
  (test-equal (iq 2 18) (itake-while even? (iq 2 18 3 10 22 9)))
  (test-equal (iq 3 10 22 9) (idrop-while even? (iq 2 18 3 10 22 9)))
  (test-equal (list (iq 2 18) (iq 3 10 22 9))
    (call-with-values
      (lambda () (ispan even? (iq 2 18 3 10 22 9)))
      list))
  (test-equal (list (iq 3 1) (iq 4 1 5 9))
    (call-with-values
      (lambda () (ibreak even? (iq 3 1 4 1 5 9)))
      list))
  (test-equal #t (iany integer? (iq a 3 b 2.7)))
  (test-equal #f (iany integer? (iq a 3.1 b 2.7)))
  (test-equal #t (iany < (iq 3 1 4 1 5) (iq 2 7 1 8 2)))
  (test-equal #t (ievery integer? (iq 1 2 3 4 5)))
  (test-equal #f (ievery integer? (iq 1 2 3 4.5 5)))
  (test-equal #t (ievery (lambda (a b) (< a b)) (iq 1 2 3) (iq 4 5 6)))
  (test-equal 2 (ilist-index even? (iq 3 1 4 1 5 9)))
  (test-equal 1 (ilist-index < (iq 3 1 4 1 5 9 2 5 6) (iq 2 7 1 8 2)))
  (test-equal #f (ilist-index = (iq 3 1 4 1 5 9 2 5 6) (iq 2 7 1 8 2)))
  (test-equal (iq a b c) (imemq 'a (iq a b c)))
  (test-equal (iq b c) (imemq 'b (iq a b c)))
  (test-equal #f (imemq 'a (iq b c d)))
  (test-equal #f (imemq (ilist 'a) (iq b (a) c)))
  (test-equal (iq (a) c) (imember (ilist 'a) (iq b (a) c)))
  (test-equal (iq 101 102) (imemv 101 (iq 100 101 102)))
) ; end ilists/searching

(test-group "ilists/deletion"
  (test-equal (iq 1 2 4 5) (idelete 3 (iq 1 2 3 4 5)))
  (test-equal (iq 3 4 5) (idelete 5 (iq 3 4 5 6 7) <))
  (test-equal (iq a b c z) (idelete-duplicates (iq a b a c a b c z)))
) ; end ilists/deletion

(test-group "ilists/alists"
  (define e (iq (a 1) (b 2) (c 3))) 
  (define e2 (iq (2 3) (5 7) (11 13)))
  (test-equal (iq a 1) (iassq 'a e))
  (test-equal (iq b 2) (iassq 'b e))
  (test-equal #f (iassq 'd e))
  (test-equal #f (iassq (ilist 'a) (iq ((a)) ((b)) ((c)))))
  (test-equal (iq (a)) (iassoc (ilist 'a) (iq ((a)) ((b)) ((c)))))
  (test-equal (iq 5 7) (iassv 5 e2))
  (test-equal (iq 11 13) (iassoc 5 e2 <))
  (test-equal (ipair (iq 1 1) e2) (ialist-cons 1 (ilist 1) e2))
  (test-equal (iq (2 3) (11 13)) (ialist-delete 5 e2))
  (test-equal (iq (2 3) (5 7)) (ialist-delete 5 e2 <))
) ; end ilists/alists

(test-group "ilists/replacers"
  (test-equal (ipair 1 3) (replace-icar (ipair 2 3) 1))
  (test-equal (ipair 1 3) (replace-icdr (ipair 1 2) 3))
) ; end ilists/replacers

(test-group "ilists/conversion"
  (test-equal (ipair 1 2) (pair->ipair '(1 . 2)))
  (test-equal '(1 . 2) (ipair->pair (ipair 1 2)))
  (test-equal (iq 1 2 3) (list->ilist '(1 2 3)))
  (test-equal '(1 2 3) (ilist->list (iq 1 2 3)))
  (test-equal (ipair 1 (ipair 2 3)) (list->ilist '(1 2 . 3)))
  (test-equal '(1 2 . 3) (ilist->list (ipair 1 (ipair 2 3))))
  (test-equal (ipair (ipair 1 2) (ipair 3 4)) (tree->itree '((1 . 2) . (3 . 4))))
  (test-equal '((1 . 2) . (3 . 4)) (itree->tree (ipair (ipair 1 2) (ipair 3 4))))
  (test-equal (ipair (ipair 1 2) (ipair 3 4)) (gtree->itree (cons (ipair 1 2) (ipair 3 4))))
  (test-equal '((1 . 2) . (3 . 4)) (gtree->tree (cons (ipair 1 2) (ipair 3 4))))
  (test-equal 6 (iapply + (iq 1 2 3)))
  (test-equal 15 (iapply + 1 2 (iq 3 4 5)))
) ; end ilists/conversion

(test-group
  "comparators"

  (let ((c ipair-comparator))
   (test-equal #t (comparator-test-type c (ipair 1 2)))
   (test-equal #f (comparator-test-type c 1))
   (test-equal #t (=? c (ipair 1 2) (ipair 1 2)))
   (test-equal #f (=? c (ipair 1 2) (ipair 1 3)))
   (test-equal #f (=? c (ipair 1 2) (ipair 3 1)))
   (test-equal #t (<? c (ipair 1 2) (ipair 1 3)))
   (test-equal #f (>? c (ipair 1 2) (ipair 1 3)))
   (test-equal #t (<? c (ipair 1 2) (ipair 3 1)))
   (test-equal #f (>? c (ipair 1 2) (ipair 3 1)))
   (test-equal (comparator-hash c (ipair 1 2))
         (comparator-hash c (ipair 1 2)))))

(test-end)
