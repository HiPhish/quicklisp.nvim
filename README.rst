.. default-role: code

######################
 Quicklisp for Neovim
######################

A Neovim client for Quicklisp_, the Common Lisp package manager.

.. image:: doc/screenshot.png
   :align: center

.. _Quicklisp: https://www.quicklisp.org/


Installation
############

Install Quicklisp.nvim like any other Neovim plugin and execute afterwards
`:UpdateRemotePlugins`. Since this is a remote plugin you will also need to
install the `Common Lisp API client`, and you will need to have Quicklisp set
up for the API client's Common Lisp implementation. Please refer to the
included documentation of Quicklisp.nvim.

.. _Common Lisp API client: https://github.com/adolenc/cl-neovim/
.. _SBCL: http://sbcl.org/


Usage
#####

You can use Quicklisp functionality from within Neovim now. There are two
parts: Vimscript functions which give you data from Quicklisp for further
processing in your own scripts, and Vim commands to be executed manually. Here
is an example:

.. code-block: vim

   " Get a list of all packages containing "vim" in their name
   let vim_packages = QuicklispSystemApropos('vim')
   " Get a list of all packages depending on MessagePack
   let msgpack_packages = QuicklispWhoDependsOn('cl-messagepack')

   " Display human-readably all packages depending on MesagePack
   :Quicklisp who-depends-on cl-messagepack

As you can see the function- and command names resemble the names from
Quicklisp.


License
#######

Quicklisp.nvim is release under the terms of the MIT license. See the
`COPYING.txt`_ file for details.

.. _COPYING.txt: COPYING.txt


Self-promotion
##############

If you like this plugin please consider financially supporting its development,
every small amount helps; you can become a regular supporter through LiberaPay
or tip me with a one-time donation over Ko-Fi. Feel free to explore my other
software projects as well.

* http://hiphish.github.io/

* https://ko-fi.com/hiphish/

* https://liberapay.com/HiPhish/
