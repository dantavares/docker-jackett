#! /bin/sh

kill $(ps aux | grep jackett | grep -v grep | awk '{print $2}')
