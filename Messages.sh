#!/usr/bin/env bash

$XGETTEXT `find package -name '*.qml'` -o $podir/plasma_applet_org.nomad.networkmanagement.pot
