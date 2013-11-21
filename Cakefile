fs = require 'fs'
Snockets = require 'snockets'

NAME = 'jscube'
INPUT_FILE = "#{NAME}.coffee"
OUTPUT_FILE = "#{NAME}.min.js"

task 'build', "Build #{OUTPUT_FILE} from src/", ->
  console.log "Build #{OUTPUT_FILE} from source"
  snockets = new Snockets({'src'})
  js = snockets.getConcatenation INPUT_FILE, async: false, minify: true
  fs.writeFileSync OUTPUT_FILE, js

task 'clean', "remove #{OUTPUT_FILE}", ->
  console.log "Clean #{OUTPUT_FILE}"
  fs.unlinkSync OUTPUT_FILE if fs.existsSync OUTPUT_FILE
