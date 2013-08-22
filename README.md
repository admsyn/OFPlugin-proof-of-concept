OFPlugin
========

Proof of concept for an Xcode plugin that adds an openFrameworks menu item.

In its current state, it will parse your addon folder for addons, and will modify the currently open Xcode project to add a new "group" for whatever addon is selected. The [XcodeEditor](https://github.com/jasperblues/XcodeEditor) source is included, but it does not look like it does what we'd need it to do (add references to external addon files).
