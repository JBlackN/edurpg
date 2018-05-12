// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

function initStatus() {
  $.get('/admin/initializer/status', function(data) {
    var current = 0;
    var total = 6;
    var msg = '';

    switch(data) {
      case 'kos':
        current = 1;
        msg = 'Načítání dat z KOSapi.';
        break;
      case 'class':
        current = 2;
        msg = 'Inicializace povolání.';
        break;
      case 'spec':
        current = 3;
        msg = 'Inicializace specializací a talentových stromů.';
        break;
      case 'achi_cat':
        current = 4;
        msg = 'Inicializace kategorií úspěchů.';
        break;
      case 'item':
        current = 5;
        msg = 'Inicializace artefaktových zbraní a jejich talentových stromů.';
        break;
      case 'quest':
        current = 6;
        msg = 'Inicializace titulů a úkolů.';
        break;
      case 'done':
        window.location.replace('/admin/dashboards/index');
        return;
      default:
        return;
    }

    $('#init-status').text(
      '[' +
      current +
      '/' +
      total +
      '] ' +
      msg
    );

    setTimeout(initStatus, 1000);
  });
}
