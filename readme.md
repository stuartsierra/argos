Argos
=====

Copyright (c) Stuart Halloway. All rights reserved.  The use and
distribution terms for this software are covered by the Eclipse Public
License 1.0 (http://opensource.org/licenses/eclipse-1.0.php) which can
be found in the file epl-v10.html at the root of this distribution.
By using this software in any fashion, you are agreeing to be bound by
the terms of this license.  You must not remove this notice, or any
other, from this software.

Argos tests how your local copy of Clojure works with a bunch of
different open-source libraries. Used as a sanity check for changes to
Clojure itself.

To run all tests with default Clojure:

    ./script/argos.sh

To run tests with a Clojure JAR at `/tmp/clojure.jar`:

    ./script/argos.sh -j /tmp/clojure.jar

For more command-line options, run:

    ./script/argos.sh -h

To add new projects to the script, edit `projects.txt` and add a line
like `$user/$project` where `$user` is a GitHub username and
`$project` is a GitHub project name owned by that user.
