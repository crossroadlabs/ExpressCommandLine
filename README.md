[//]: https://www.iconfinder.com/icons/383207/doc_tag_icon#size=64
<p align="center">
	<a href="http://swiftexpress.io/">
		<img alt="Swift Express" src ="https://raw.githubusercontent.com/crossroadlabs/Express/master/logo-full.png" height=256/>
	</a>
	<a href="https://github.com/crossroadlabs/Express/blob/master/doc/index.md">
		<h5 align="right">Documentation    <img src="https://cdn0.iconfinder.com/data/icons/glyphpack/82/tag-doc-64.png" height=16/>
		</h5>
	</a>
</p>

[<h5 align="right">Live 🐧 server running Demo  <img src="https://cdn0.iconfinder.com/data/icons/glyphpack/34/play-circle-32.png" height=16/>
		</h5>](http://demo.swiftexpress.io/)

[<h5 align="right">Eating our own dog food  <img src="https://cdn0.iconfinder.com/data/icons/glyphpack/147/globe-full-32.png" height=16/>
		</h5>](http://swiftexpress.io/)


# Command Line Interface

![🐧 linux: ready](https://img.shields.io/badge/%F0%9F%90%A7%20linux-ready-red.svg)
[![Build Status](https://travis-ci.org/crossroadlabs/ExpressCommandLine.svg?branch=master)](https://travis-ci.org/crossroadlabs/ExpressCommandLine)
![Platform OS X | Linux](https://img.shields.io/badge/platform-OS%20X%20%7C%20Linux-orange.svg)
[![GitHub license](https://img.shields.io/badge/license-GPL v3-lightgrey.svg)](https://raw.githubusercontent.com/crossroadlabs/ExpressCommandLine/master/LICENSE)
[![GitHub release](https://img.shields.io/github/release/crossroadlabs/ExpressCommandLine.svg)](https://github.com/crossroadlabs/ExpressCommandLine/releases)

### [Swift Express](https://github.com/crossroadlabs/Express) is a simple, yet unopinionated web application server written in Swift

## Usage

### Create new project

This one creates a brand new initialized project, ready to use out of the box.

```sh
swift-express init YourProject
```

`swift-express init` has a few optional parameters:

* `--template git-url` allows specifying the project template git URL. Defaults to `https://github.com/crossroadlabs/ExpressTemplate.git`.
* `--path path/to/dir` specifies where to create the application. Defaults to the current directory.

### Initialise project dependencies

To download and build project dependencies call `bootstrap` command:

```sh
swift-express bootstrap
```

Optional parameters:

* `--spm` use Swift Package Manager instead of Carthage. Is default on Linux.
* `--carthage` use Carthage as package manager. Is default for OS X. Not available on Linux.
* `--fetch` fetch dependencies without building. Default is false. Always true for SPM as it has no separate build dependencies option.
* `--no-refetch` build dependencies without fetching. Default is false. Always false for SPM. 
* `--path path/to/the/app` can be used outside the app's folder explicitly specifying the path to the app.

### Update project dependencies

To update project dependencies according to `Cartfile` or `Package.swift` call `update` command:

```sh
swift-express update
```

Optional parameters:

* `--spm` use Swift Package Manager instead of Carthage. Is default on Linux.
* `--carthage` use Carthage as package manager. Is default for OS X. Not available on Linux.
* `--fetch` fetch dependencies without building. Default is false. Always true for SPM as it has no separate build dependencies option.
* `--path path/to/the/app` can be used outside the app's folder explicitly specifying the path to the app.

### Build project

Command line build interface for [Swift Express](https://github.com/crossroadlabs/Express) projects.

```sh
swift-express build
```

Build configuration can be specified like this:

```sh
swift-express build release
```

Default configuration is `debug`

Optional parameters:

* `--spm` use Swift Package Manager as build tool. Is default on Linux.
* `--xcode` use Xcode as build tool. Is default for OS X. Not available on Linux.
* `--dispatch` build with Dispatch support. Is default on OS X.
* `--force` force rebuild. Essentially cleans before building.
* `--path path/to/the/app` can be used outside the app's folder explicitly specifying the path to the app.

### Run the app

Command line interface for running [Swift Express](https://github.com/crossroadlabs/Express) apps.

```sh
swift-express run
```

Build configuration can be specified like this:

```sh
swift-express run release
```

Default configuration is `debug`

Optional parameters:

* `--spm` run app built by Swift Package Manager. Is default on Linux.
* `--xcode` run app built by Xcode. Is default for OS X. Not available on Linux.
* `--path path/to/the/app` can be used outside of the app's folder explicitly specifying the path to the app.

### Print help

This one prints short documentation for all the commands available.

```sh
swift-express help
```

Also can print short documentation for command

```sh
swift-express help bootstrap
```

## Installation

Please refer to the main Swift Express article here: [https://github.com/crossroadlabs/Express/blob/master/doc/gettingstarted/installing.md](https://github.com/crossroadlabs/Express/blob/master/doc/gettingstarted/installing.md)

## Changelog

* v0.2: Swift Package Manager support.
* v0.1: Initial Public Release

## Contributing

To get started, <a href="https://www.clahub.com/agreements/crossroadlabs/ExpressCommandLine">sign the Contributor License Agreement</a>.

## [![Crossroad Labs](http://i.imgur.com/iRlxgOL.png?1) by Crossroad Labs](http://www.crossroadlabs.xyz/)
