#!/bin/bash

sudo MIX_ENV=prod PORT=80 elixir --detached -S mix phx.server
