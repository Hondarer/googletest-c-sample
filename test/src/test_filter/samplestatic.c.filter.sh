#!/bin/bash

awk '{
    sub(/^[[:space:]]*return static_int;[[:space:]]*$/, "    return static_int + 234; /* Modify from test framework */");
    print;
}'
