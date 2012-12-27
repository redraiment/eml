eml
===

Emacs-lisp Markup Language.

To convert S-expression to XML.
It can embed Emacs-lisp as script-let like JSP, PHP etc.

For instance:
```Lisp
(eml
 '(html
   (head
    (title "Hello EML")
    (meta (http-equiv . Content-Type)
          (content . "text/html; charset=UTF-8")))
   (body
    (h1 "Hello EML")
    (p "Hello Joe!")
    (ul
     <%
     (dotimes (i 10)
       (princ (eml '(li <%= i %>))))
     %>))))
```
It would output below (without indent):
```HTML
<html>
  <head>
    <title>Hello EML</title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
  </head>
  <body>
    <h1>Hello EML</h1>
    <p>Hello Joe!</p>
    <ul>
      <li>0</li>
      <li>1</li>
      <li>2</li>
      <li>3</li>
      <li>4</li>
      <li>5</li>
      <li>6</li>
      <li>7</li>
      <li>8</li>
      <li>9</li>
    </ul>
  </body>
</html>
```
