(function() {

  $(function() {
    var viewModel;
    viewModel = new cacoofinder.ViewModel(cacoofinder.ViewModel.APIKEY);
    return ko.applyBindings(viewModel);
  });

}).call(this);
