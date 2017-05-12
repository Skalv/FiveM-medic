var documentWidth = document.documentElement.clientWidth;
var documentHeight = document.documentElement.clientHeight;

function showDashBoard(victimes) {
  $(".victimList tbody").html("");
  for (var i=0; i < victimes.length; i++) {
    $tr = $("<tr />");
    $tr.append("<th>"+victimes[i].id+"</th>");
    $tr.append("<th>"+victimes[i].street+"</th>");
    $tr.append("<th>"+victimes[i].victimState+"</th>");
    $tr.append("<th>tutu</th>");
    $(".victimList tbody").append($tr)
  }
  $('.dashboard').removeClass("hide");
}

// Initialisation du script
$(function() {
  // On écoute les event du serveur
  window.addEventListener('message', function(event) {
    switch (event.data.type) {
      case "medicDashboard":
        showDashBoard(event.data.victimes);
        break;
      case "vehList":
        // On affiche la liste des véhicules du joueur
        initVehList(event.data.vehicles);
        break;
    }
  });
});
