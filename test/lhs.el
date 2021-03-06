;;; lhs.el --- Test for left hand side highlighting

;; Copyright (C) 2014 by Syohei YOSHIDA

;; Author: Syohei YOSHIDA <syohex@gmail.com>

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;; Code:

(require 'cl-lib)

(require 'ert)
(require 'go-eldoc)

;;
;; Tests for left hand side
;;

(ert-deftest one-return-value ()
  "Function has one return value"
  (with-go-temp-buffer
    "
package main
func foo(arg int) error {
}

func main () {
        err := foo(10)
}
"
    (goto-char (point-max))
    (backward-cursor-on "err")
    (let ((got (go-eldoc--documentation-function))
          (expected "foo: (arg int) error"))
      (should (string= got expected))

      (let ((highlighted-part (substring got -5)))
        (should (eq (get-text-property 0 'face highlighted-part)
                    'eldoc-highlight-function-argument))))))

(ert-deftest one-return-value-with-name ()
  "Function has one named return value"
  (with-go-temp-buffer
    "
package main
func foo(arg int) (ret error) {
}

func main () {
        err := foo(10)
}
"
    (goto-char (point-max))
    (backward-cursor-on "err")
    (let ((got (go-eldoc--documentation-function))
          (expected "foo: (arg int) (ret error)"))
      (should (string= got expected)))))

(ert-deftest multiple-return-values ()
  "Function has multile return values"
  (with-go-temp-buffer
    "
package main
func foo(arg int) (int, double, error) {
}

func main () {
        bar, baz, err := foo(10)
}
"
    (goto-char (point-max))
    (backward-cursor-on "bar")
    (let ((got (go-eldoc--documentation-function))
          (expected "foo: (arg int) (int, double, error)"))
      (should (string= got expected))
      (should (eq (get-text-property 0 'face (substring got -19 -16))
                  'eldoc-highlight-function-argument))
      (should-not (get-text-property 0 'face (substring got -14 -8)))

      (forward-cursor-on "baz")
      (let ((got (go-eldoc--documentation-function)))
        (should (string= got expected))
        (should (eq (get-text-property 0 'face (substring got -14 -9))
                    'eldoc-highlight-function-argument))
        (should-not (get-text-property 0 'face (substring got -19 -16))))

      (forward-cursor-on "err")
      (let ((got (go-eldoc--documentation-function)))
        (should (string= got expected))
        (should (eq (get-text-property 0 'face (substring got -6 -2))
                    'eldoc-highlight-function-argument))
        (should-not (get-text-property 0 'face (substring got -19 -16)))
        (should-not (get-text-property 0 'face (substring got -14 -9)))))))

(ert-deftest separated-by-semicolon ()
  "assignment expression with semicolon"
  (with-go-temp-buffer
    "
package main
func foo(arg int) error {
}

func main () {
        if err := foo(10); err != nil {
        }
}
"
    (goto-char (point-max))
    (backward-cursor-on "if")
    (forward-cursor-on "err")
    (let ((got (go-eldoc--documentation-function))
          (expected "foo: (arg int) error"))
      (should (string= got expected))

      (let ((highlighted-part (substring got -5)))
        (should (eq (get-text-property 0 'face highlighted-part)
                    'eldoc-highlight-function-argument))))

    (forward-cursor-on "10")
    (let* ((got (go-eldoc--documentation-function))
           (highlighted-part (substring got 6 13)))
      (should (eq (get-text-property 0 'face highlighted-part)
                  'eldoc-highlight-function-argument)))))

;;; lhs.el end here
