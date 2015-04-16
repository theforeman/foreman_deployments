#!/bin/bash
DIAGRAM_DIR="./diagrams"

rm $DIAGRAM_DIR/*.svg $DIAGRAM_DIR/*.png
java -jar ./plantuml.jar -duration -tsvg -o "$DIAGRAM_DIR" "*.puml"
java -jar ./plantuml.jar -duration -o "$DIAGRAM_DIR" "*.puml"

