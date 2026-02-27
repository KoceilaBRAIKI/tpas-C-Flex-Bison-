#!/bin/bash
BIN="./bin/tpcas"

echo "--- TESTS VALIDES ---"
for f in test/good/*.tpc; do
    $BIN < "$f" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "$(basename $f) : OK"
    else
        echo "$(basename $f) : ECHEC"
    fi
done

echo ""
echo "--- TESTS ERREURS ---"
for f in test/syn-err/*.tpc; do
    $BIN < "$f" > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "$(basename $f) : OK"
    else
        echo "$(basename $f) : ECHEC"
    fi
done