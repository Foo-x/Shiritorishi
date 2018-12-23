// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"
import "../css/app.scss"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"

import * as phoenix from "phoenix"
import websocketPortsFactory from "elm-phoenix-websocket-ports"
import localStoragePorts from "elm-local-storage-ports"

import { Elm } from "../elm/src/Main.elm"

const socketAddress = "/socket"
const websocketPorts = websocketPortsFactory(phoenix, socketAddress)

const elm = Elm.Main.init({
  node: document.getElementById("elm-container")
})

websocketPorts.register(elm.ports)
localStoragePorts.register(elm.ports)
