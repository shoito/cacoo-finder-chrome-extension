class Content
	constructor: (obj) ->
		for key of obj
			@[key] = obj[key]
		# @updated = @convertTimeAgo @updated

	convertFileSize: (value) ->
		round = (value, baseSize) ->
			fractions = 2
			Math.round(value * Math.pow(10, fractions) / baseSize) / Math.pow(10, fractions)
		if value < 1024
			converted = value + "B"
		else if value >= 1024 and value < 1048576
			converted = round(value, 1024) + "KB"
		else if value >= 1048576 and value < 1073741824
			converted = round(value, 1048576) + "MB"
		else if value >= 1073741824 and value < 1099511627776
			converted = round(value, 1073741824) + "GB"
		else
			converted = round(value, 1099511627776) + "TB"
		return converted

	convertTimeAgo: (target) ->
		now = new Date().getTime()
		targetTime = new Date(target).getTime()
		diff = now - targetTime
		days = diff / 86400000
		return Math.floor(days) + " days ago"	if days > 1
		hours = diff / 3600000 - Math.floor(days) * 24
		return Math.floor(hours) + " hours ago"	if hours > 1
		minutes = diff / 60000 - Math.floor(days) * 24 * 60 - Math.floor(hours) * 60
		Math.floor(minutes) + " minutes ago"

class Diagram extends Content
	constructor: (obj) ->
		super obj

class Sheet extends Content
	constructor: (obj) ->
		super obj

class Comment extends Content
	constructor: (obj) ->
		super obj

@cacoofinder = {} unless @cacoofinder
@cacoofinder.Diagram = Diagram
@cacoofinder.Sheet = Sheet
@cacoofinder.Comment = Comment

