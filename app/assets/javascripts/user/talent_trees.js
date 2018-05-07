// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(function() {
  $('[data-toggle="popover"]').popover({
    container: 'body'
  })
})

$(document).ready(function() {
  $('.watch-unsaved').on('click', function(e) {
    if (window.unsavedChanges) {
      e.preventDefault();
      e.stopPropagation();
      $('#unsaved-alert').modal();
    }
  });

  $('#modal-tree-nosave').on('click', function(e) {
    window.unsavedChanges = false;
  });

  $('#modal-tree-save').on('click', function(e) {
    $('#tree-save').trigger('click');
  });
});
