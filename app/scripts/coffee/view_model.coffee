class ViewModel
	@DIAGRAMS = "diagrams"
	@SHEETS = "sheets"
	@COMMENTS = "comments"
	@APIKEY = "apikey"

	@DIAGRAMS_ALL = "all"
	@DIAGRAMS_OWN = "own"
	@DIAGRAMS_SHARED = "shared"

	constructor: (@firstMode = ViewModel.DIAGRAMS) ->
		savedApiKey = localStorage["apiKey"]
		console.log "saved", savedApiKey
		@apiKey = ko.observable savedApiKey
		@currentMode = ko.observable if savedApiKey? and @firstMode isnt ViewModel.APIKEY then ViewModel.DIAGRAMS else ViewModel.APIKEY
		@currentMode.subscribe (newMode) =>
			if newMode is ViewModel.DIAGRAMS
				@loadDiagrams()

		@diagrams = ko.observableArray []
		@selectedDiagramId = ko.observable ""
		@filter = ko.observable ViewModel.DIAGRAMS_ALL
		@filteredDiagrams = ko.computed =>
			filter = @filter()
			filtered = []
			ko.utils.arrayForEach @diagrams(), (diagram) =>
				if filter is ViewModel.DIAGRAMS_OWN
					filtered.push diagram if diagram.own
				else if filter is ViewModel.DIAGRAMS_SHARED
					filtered.push diagram if diagram.shared
				else
					filtered.push diagram
			return filtered
		@sheets = ko.observableArray []
		@comments = ko.observableArray []

		@visibleHeader = ko.computed =>
			return @currentMode() isnt ViewModel.APIKEY

		if @currentMode() is ViewModel.DIAGRAMS
			@loadDiagrams()

		@inputComment = ko.observable ""

	clearAll: =>
		@diagrams []
		@sheets []
		@comments []
		@inputComment ""
		@selectedDiagramId ""
		@filter ViewModel.DIAGRAMS_ALL

	loadDiagrams: =>
		@diagrams []
		$.ajax
			url: "https://cacoo.com/api/v1/diagrams.json"
			data:
				apiKey: @apiKey()
			dataType: "json"
			type: "GET"
		.done (data) =>
			ko.utils.arrayForEach data.result, (diagram) =>
				@diagrams.push new cacoofinder.Diagram(diagram)
		.fail (xhr, textStatus, errorThrown) =>
			@currentMode ViewModel.APIKEY if xhr.status is 401
			@clearAll()

	changeFilter: (filter = ViewModel.DIAGRAMS_ALL) =>
		@currentMode ViewModel.DIAGRAMS if @currentMode() isnt ViewModel.DIAGRAMS
		@filter filter

	showSheets: (diagramId = "") =>
		@sheets []
		@currentMode ViewModel.SHEETS
		@selectedDiagramId diagramId
		if diagramId is ""
			console.log "Diagram not found."
			return
		$.ajax
			url: "https://cacoo.com/api/v1/diagrams/" + diagramId + ".json"
			data: 
				apiKey: @apiKey()
			dataType: "json"
			type: "GET"
		.done (data) =>
			ko.utils.arrayForEach data.sheets, (sheet) =>
				@sheets.push new cacoofinder.Sheet(sheet)
		.fail (xhr, textStatus, errorThrown) =>
			@currentMode ViewModel.APIKEY if xhr.status is 401
			@clearAll()

	showComments: (diagramId) =>
		@comments []
		@inputComment ""
		@currentMode ViewModel.COMMENTS
		@selectedDiagramId diagramId
		if diagramId is ""
			console.log "Diagram not found."
			return
		$.ajax
			url: "https://cacoo.com/api/v1/diagrams/" + diagramId + ".json"
			data: 
				apiKey: @apiKey()
			dataType: "json"
			type: "GET"
		.done (data) =>
			ko.utils.arrayForEach data.comments, (comment) =>
				@comments.unshift new cacoofinder.Comment(comment)
		.fail (xhr, textStatus, errorThrown) =>
			@currentMode ViewModel.APIKEY if xhr.status is 401
			@clearAll()

	createNewDiagram: =>
		$.ajax
			url: "https://cacoo.com/api/v1/diagrams/create.json"
			data: 
				apiKey: @apiKey()
			dataType: "json"
			type: "GET"
		.done (data) =>
			chrome.tabs.create url: data.url + "/edit"
		.fail (xhr, textStatus, errorThrown) =>
			if xhr.status is 400
			else if xhr.status is 403
				$(".alert-message strong").text "Sheet size limit exceeded!"
				$(".alert-message").addClass("error").fadeIn "fast"
				setTimeout (->
					$(".alert-message").fadeOut "slow"
				), 1400
			else xhr.status is 404

	createComment: =>
		comment = @inputComment()
		return if comment is "" or !@selectedDiagramId()?
		$.ajax
			url: "https://cacoo.com/api/v1/diagrams/" + @selectedDiagramId() + "/comments/post.json"
			data:
				content: comment
				apiKey: @apiKey()
			dataType: "json"
			type: "POST"
		.done (data) =>
			@inputComment ""
			console.log data
			@comments.unshift new cacoofinder.Comment(data)
		.fail (xhr, textStatus, errorThrown) =>
			@currentMode ViewModel.APIKEY if xhr.status is 401
			@clearAll()

	saveApiKey: =>
		unless @validateApiKey()
			$(".alert-message strong").text "Invalid API Key!"
			$(".alert-message").removeClass("success").addClass("error").fadeIn "fast"
			setTimeout (->
				$(".alert-message").fadeOut "slow"
			), 1400
			return
			
		localStorage["apiKey"] = @apiKey()
		$(".alert-message strong").text "Saved!"
		$(".alert-message").removeClass("error").addClass("success").fadeIn "fast"
		setTimeout (=>
			$(".alert-message").fadeOut "slow"
			@currentMode ViewModel.DIAGRAMS if @firstMode isnt ViewModel.APIKEY
		), 1400

	restoreApiKey: =>
		savedApiKey = localStorage["apiKey"]
		@apiKey if savedApiKey? then savedApiKey else ""

	resetApiKey: =>
		localStorage.removeItem "apiKey"
		@apiKey ""

	validateApiKey: =>
		valid = false
		$.ajax
			url: "https://cacoo.com/api/v1/account.json"
			data:
				apiKey: @apiKey()
			dataType: "json"
			type: "GET"
			async: false
			timeout: 3000
		.done (data) =>
			valid = true
		.fail (xhr, textStatus, errorThrown) =>
			valid = false
		return valid

@cacoofinder = {} unless @cacoofinder
@cacoofinder.ViewModel = ViewModel