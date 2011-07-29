; ioscheme bulletin board example
; 
; To make this work, run:
;
;   ./ioscheme -v -p 8000 init.scm bb.scm
;
; Then visit in a web browser:
;   http://localhost:8000/
;
(load "html.scm")
(load "sql.scm")

(sqlite-open "data-bb.sqlite3")

(run-query "SELECT sqlite_version()")
(run-query "CREATE TABLE notices (content TEXT);")

(define all-notices "SELECT * FROM notices;")

(define (notice-html-fragment notice)
  (sexp->html
    `(div @ ((class "notice"))
        ,(apply string-append notice))))

(define (query->html v)
  (letrec ((fn (lambda (i s)
    (if (= (vector-length v) i)
         s
         (fn (+ i 1) 
             (string-append (notice-html-fragment (vector-ref v i)) s))))))
    (fn 0 "")))

(define (index-html notices)
  (sexp->html
    `(html
       (head
         (link @ ((type "text/css")(href "base.css")(rel "stylesheet")(media "screen")))
         (title "ioscheme demonstration"))
       (body
         (div @ ((id "main"))
           (p @ ((id "header")) (a @ ((href "/index")) (h1 "(ioscheme)")))
           (p (form @ ((method "post") (action "/index"))
                (input @ ((type "text") (name "content")))
                (input @ ((type "hidden") (name "token") (value "1234")))
                (input @ ((type "submit") (value "post notice")))))
           (p ,(query->html notices)))))))

(define (index-handler method body parameters)
  (cond
    ((string-ci=? method "get") (list (cons 200 "OK")(cons "Content-Type" "text/html")(index-html (run-query all-notices))))
    ((string-ci=? method "post")
      (run-query
        (string-append
          "INSERT INTO notices (content) VALUES ('"
          (symbol->string(cdr(assq 'content body)))
          "');"))
      (list (cons 200 "OK")(cons "Content-Type" "text/html")(index-html (run-query all-notices))))
    (#t (list (cons 405 "Method Not Allowed")(cons "Content-Type" "text/html")"Method not allowed"))))

(define (delete-handler method body parameters)
  (cond
    ((string-ci=? method "get") 
      (run-query "DELETE FROM notices;") (list (cons 200 "OK")(cons "Content-Type" "text/html")(index-html (run-query all-notices))))
    (#t (list (cons 405 "Method Not Allowed")(cons "Content-Type" "text/html")"Method not allowed"))))

(define (receive method path body parameters)
    (cond ((string-ci=? path "/")           (index-handler method body parameters))
          ((string-ci=? path "/index")      (index-handler method body parameters))
          ((string-ci=? path "/delete-all") (delete-handler method body parameters))
      (#t (list (cons 404 "Not Found")(cons "Content-Type" "text/html") "Page does not exist" ))))

(display "Loaded web script.")(newline)


