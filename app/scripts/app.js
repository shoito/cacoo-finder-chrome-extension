(function() {

  $(function() {
    var viewModel;
    viewModel = new cacoofinder.ViewModel();
    ko.applyBindings(viewModel);
    return $("button[rel=popover]").popover({
      offset: 10,
      placement: "below"
    }).click(function(e) {
      return e.preventDefault();
    });
  });

}).call(this);
