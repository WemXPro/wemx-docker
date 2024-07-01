#!/bin/bash

show_help() {
    echo "Usage: wemx [options]"
    echo ""
    echo "Options:"
    echo "  -i, --install            Install the wemx"
    echo "  -u, --update             Update the wemx"
    echo "  -h, --help               Show this help message and exit"
}

INSTALL=false
UPDATE=false

if [ $# -eq 0 ]; then
    show_help
    exit 0
fi

for arg in "$@"; do
    case $arg in
        -i|--install)
        INSTALL=true
        shift
        ;;
        -u|--update)
        UPDATE=true
        shift
        ;;
        -h|--help)
        show_help
        exit 0
        ;;
        *)
        echo "Unknown option: $arg"
        show_help
        exit 1
        ;;
    esac
done

install_service() {
    /usr/local/bin/install.sh
}

update_service() {
    /usr/local/bin/update.sh
}

if [ "$INSTALL" = true ]; then
    install_service
fi

if [ "$UPDATE" = true ]; then
    update_service
fi
