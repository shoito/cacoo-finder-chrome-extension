module.exports = (grunt) ->
	"use strict"
	
	#
	# Grunt configuration:
	#
	# https://github.com/cowboy/grunt/blob/master/docs/getting_started.md
	#
	grunt.initConfig
		
		# Project configuration
		# ---------------------
		
		# templateFiles:
		# 	footer: "app/template/footer.tmpl"
		# 	header: "app/template/header.tmpl"
		# 	header_static: "app/template/header_static.tmpl"
		# 	option: "app/template/option.tmpl"
		# 	result: "app/template/result.tmpl"
		# 	script: "app/template/script.tmpl"
		# 	tags: "app/template/tags.tmpl"

		# template:
		# 	files:
		# 		"app/template/main.tmpl": "app/app.html"
		# 		"app/template/main_static.tmpl": "app/index.html"

		# specify an alternate install location for Bower
		bower:
			dir: "app/components"

		
		# Coffee to JS compilation
		coffee:
			compile:
				files:
					"temp/scripts/*.js": "app/scripts/**/*.coffee"

				options:
					basePath: "app/scripts"

		
		# compile .scss/.sass to .css using Compass
		compass:
			dist:
				
				# http://compass-style.org/help/tutorials/configuration-reference/#configuration-properties
				options:
					css_dir: "temp/styles"
					sass_dir: "app/styles"
					images_dir: "app/images"
					javascripts_dir: "temp/scripts"
					force: true

		less:
			development:
				files:
					"temp/styles/*.css": "app/styles/**/*.less"

				options:
					basePath: "app/styles"

			production:
				files:
					"temp/styles/*.css": "app/styles/**/*.less"

				options:
					basePath: "app/styles"
					yuicompress: true
		
		# generate application cache manifest
		manifest:
			dest: ""

		
		# headless testing through PhantomJS
		mocha:
			all: ["test/**/*.html"]

		
		# default watch configuration
		watch:
			template:
				files: ["app/**/*.tmpl"]
				tasks: ["template"]

			coffee:
				files: "app/scripts/**/*.coffee"
				tasks: ["coffee", "concat"] #reload"

			less:
				files: ["app/scripts/**/*.less"]
				tasks: ["less"]

			# reload:
			# 	files: ["app/*.html", "app/styles/**/*.css", "app/scripts/**/*.js", "app/images/**/*"]
			# 	tasks: "reload"

		
		# default lint configuration, change this to match your setup:
		# https://github.com/cowboy/grunt/blob/master/docs/task_lint.md#lint-built-in-task
		lint:
			files: ["Gruntfile.js", "app/scripts/**/*.js", "spec/**/*.js"]

		
		# specifying JSHint options and globals
		# https://github.com/cowboy/grunt/blob/master/docs/task_lint.md#specifying-jshint-options-and-globals
		jshint:
			options:
				curly: true
				eqeqeq: true
				immed: true
				latedef: true
				newcap: true
				noarg: true
				sub: true
				undef: true
				boss: true
				eqnull: true
				browser: true

			globals:
				jQuery: true

		
		# Build configuration
		# -------------------
		
		# the staging directory used during the process
		staging: "temp"
		
		# final build output
		output: "dist"
		mkdirs:
			staging: "app/"

		
		# Below, all paths are relative to the staging directory, which is a copy
		# of the app/ directory. Any .gitignore, .ignore and .buildignore file
		# that might appear in the app/ tree are used to ignore these values
		# during the copy process.
		
		# concat css/**/*.css files, inline @import, output a single minified css
		css:
			"styles/main.css": ["styles/**/*.css"]

		
		# renames JS/CSS to prepend a hash of their contents for easier
		# versioning
		rev:
			js: "scripts/**/*.js"
			css: "styles/**/*.css"
			img: "images/**"

		# While Yeoman handles concat/min when using
		# usemin blocks, you can still use them manually
		concat:
			base:
				src: [
					"app/scripts/vendor/md5.min.js"
					"app/scripts/vendor/jquery-1.9.0.min.js"
					"app/scripts/vendor/bootstrap.min.js"
					"app/scripts/vendor/knockout-2.2.1.min.js"
					"temp/scripts/coffee/content.js"
					"temp/scripts/coffee/view_model.js"
				]
				dest: "app/scripts/base.js"
			app:
				src: [
					"temp/scripts/coffee/popup.js"
				]
				dest: "app/scripts/app.js"
			option:
				src: [
					"temp/scripts/coffee/option.js"
				]
				dest: "app/scripts/option.js"

		# usemin handler should point to the file containing
		# the usemin blocks to be parsed
		"usemin-handler":
			html: "index.html"

		
		# update references in HTML/CSS to revved files
		usemin:
			html: ["**/*.html"]
			css: ["**/*.css"]

		
		# HTML minification
		html:
			files: ["**/*.html"]

		
		# Optimizes JPGs and PNGs (with jpegtran & optipng)
		img:
			dist: "<config:rev.img>"

		
		# rjs configuration. You don't necessarily need to specify the typical
		# `path` configuration, the rjs task will parse these values from your
		# main module, using http://requirejs.org/docs/optimization.html#mainConfigFile
		#
		# name / out / mainConfig file should be used. You can let it blank if
		# you're using usemin-handler to parse rjs config from markup (default
		# setup)
		rjs:
			
			# no minification, is done by the min task
			optimize: "none"
			baseUrl: "./scripts"
			wrap: true

	grunt.loadNpmTasks "grunt-contrib-less"

	# Alias the `test` task to run the `mocha` task instead
	grunt.registerTask "test", "mocha"

	grunt.registerTask "template", "Generate html depending on configuration", ->
		conf = grunt.config("template")
		files = conf.files
		Object.keys(files).forEach (key) ->
			tmpl = grunt.file.read(key)
			console.log key
			grunt.file.write files[key], grunt.template.process(tmpl)