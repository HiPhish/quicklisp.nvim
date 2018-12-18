.. default-role:: code

###########################
 Hacking on Quicklisp.nvim
###########################

Setup
#####

You should first install the dependencies (the Common Lisp API client and
Quicklisp) by following their instructions.

https://github.com/adolenc/cl-neovim/
https://www.quicklisp.org/

If you are using Vlime while developing you should also connect your Vlime
connection to your running Neovim instance or else you will get errors when
compiling a file that contains Neovim code. Here is what is going on: a Vlime
connection is a connection to a running Swank server, which is a Common Lisp
process. Swank tries to compile your file your file, and when it sees a
`nvim:defun` or similar, it will require a connection. The easiest way to
satisfy the compiler is to execute 

.. code-block:: lisp

   (nvim:connect :file NVIM-LISTEN-ADDRESS)

where `NVIM-LISTEN-ADDRESS` is for example the value of `$NVIM_LISTEN_ADDRESS`.
