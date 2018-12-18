.. default-role:: code

Things that would be nice to have:

- Health check for Quicklisp (requires somehow calling Lisp code from Neovim)
- Actual tests (how should I test a Quicklisp client with a mock Quicklisp?)
- Stream output instead of collecting it. Quicklisp sends output to
  `standard-output`, which we can capture in a string and echo out in Neovim,
  but this means the output will not gradually stream, it will appear all at
  once when the Quicklisp procedure terminates.
