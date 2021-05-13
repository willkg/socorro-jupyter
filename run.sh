#!/bin/bash

# run.sh script for running Jupyter notebook environment.

function myenv {
    if [ ! -f "my.env" ]; then
        cp my.env.dist my.env
        echo "Creating my.env file. Edit it to set variables in Jupyter notebook environment."
    fi
}


function run {
    myenv
    docker-compose up jupyter
}


function shell {
    myenv
    docker-compose run --rm jupyter shell
}


"$@"
