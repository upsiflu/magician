# This is SkryScanner, a Magician Wyfinding App

[Go to the Design Document](./DESIGN.md)

Code Challenge, Jan. 25, Flupsi


**How to compile and run:**

- Clone this repo and `cd` into the main directory.
- Install node, if you don't have it yet.
- Install elm: `npm install -g elm` (see [this guide](https://guide.elm-lang.org/install/elm.html) for more options)
- Compile the source live with `elm-reactor`
- Go to [localhost:8000](http://localhost:8000/src/Main.elm) to auto-compile and use the app.

**How to browse the API and documentation:**

- Install edp: `npm install -g elm-doc-preview`
- Launch a live documentation on port 8001: `edp --port 8001`
- Browse to [localhost:8001/packages/flupsi/magician/latest](http://localhost:8001/packages/flupsi/magician/latest)
- You can run elm-reactor on port 8000 and edp on 8001 simultaneously.

**How to explore the sources:**

- `cd` into the `src` directory
- Edit the modules
- While `elm-reactor` is running, it'll live (re-)compile any source file in this directory. In case of error, the browser will output nicely formatted error messages. The same is true for `edp`.

**How to run the test suite:**

- install elm-test: `npm install -g elm-test`
- run: `elm-test`
- edit the test suite in the `tests` directory

**How to verify the examples given in the documentation:**

- you can `npm install -g elm-verify-examples`
- proceed according to [the docs](https://github.com/stoeffel/elm-verify-examples)


**Outlook:**

_The magician will probably prefer a compiled web app served on the internet, that's for another day or two of coding..._
