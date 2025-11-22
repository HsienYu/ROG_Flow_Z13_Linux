#!/bin/bash
cd "$(dirname "$0")"
sudo DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY .venv/bin/python3 keyboard_rgb_simple.py
