$ ->
    viewModel = new cacoofinder.ViewModel()
    ko.applyBindings viewModel

    $("button[rel=popover]").popover(
        offset: 10
        placement: "below"
    ).click (e) ->
        e.preventDefault()