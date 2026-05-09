#!/usr/bin/env bash

makedeb --print-srcinfo > .SRCINFO
makedeb -si

# vim: set filetype=bash tabstop=2 foldmethod=marker expandtab:
