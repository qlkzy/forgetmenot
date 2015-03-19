#!/bin/bash
find ~ -name '.git' -type d |
    sed -e 's/\.git$//'
