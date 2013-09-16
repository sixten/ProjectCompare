This is a quick-and-dirty command-line tool to compare the contents of two
targets in an Xcode project.

We have a couple of products we maintain where different branded versions of the
same app are built as targets in the same overall project. When the contents of
those targets diverge, pain and misery results. There didn't seem to be an
existing tool to allow me to diff those targets against one another, so this was
born.
