# Swift Express Command Line

[![GitHub license](https://img.shields.io/badge/license-GPL v3-lightgrey.svg)](https://raw.githubusercontent.com/crossroadlabs/ExpressCommandLine/master/LICENSE)
![Platform OS X | Linux](https://img.shields.io/badge/platform-OS%20X%20%7C%20Linux-orange.svg)

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

* `--path path/to/the/app` can be used outside the app's folder explicitly specifying the path to the app.

### Print help

This one prints short documentation for all the commands available.

```sh
swift-express help
```

## Installation

Please refer to the main Swift Express article here: [https://github.com/crossroadlabs/Express](https://github.com/crossroadlabs/Express)

## Changelog

* v0.1: Initial Public Release

## Contributing

To get started, <a href="https://www.clahub.com/agreements/crossroadlabs/ExpressCommandLine">sign the Contributor License Agreement</a>.

## [![Crossroad Labs](http://i.imgur.com/iRlxgOL.png?1) by Crossroad Labs](http://www.crossroadlabs.xyz/)