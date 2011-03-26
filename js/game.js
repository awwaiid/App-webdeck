
// Magical utility to make all cards draggable, always
(function ($) {
   jQuery.fn.liveDraggable = function (opts) {
      this.live("mouseover", function() {
         if (!$(this).data("init")) {
            $(this).data("init", true).draggable(opts);
         }
      });
   };
})(jQuery);

var max_zindex = 100;

function startMovingCard(event, ui) {
  ui.helper.css('z-index', max_zindex++);
}


function doneMovingCard(event, ui) {
  var id = ui.helper.attr('id');
  id = ui.helper.children('img').attr('id');
  var z = ui.helper.css('z-index');
  $.get('/movecard/' + id + '/' + ui.position.left + '/' + ui.position.top + '/' + z);
}

function got_instructions(data) {
  // alert("Got action: " + data.action);
  if(data.action == 'movecard') {
    //alert("Moving card " + data.id + " to " + data.x + "," + data.y);
    var card = $('#' + data.id);
    card.parent().css('z-index', data.z);
    card.parent().animate({
      top: data.y,
      left: data.x
    }, 1000);
  }
  if(data.sid) {
    poll_server(data.sid);
  }
}

function poll_server(sid) {
  $.ajax({
    url: "/stream?sid=" + sid,
    dataType: 'json',
    success: got_instructions
    //complete: function() { poll_server(sid) }
  });
}

function start_poll_stream() {
  $.getJSON('/stream', function(data) {
    alert("Starting stream on sid " + data.sid);
    poll_server(data.sid);
  });
}

$(function() {
  $.ajaxSetup({ cache: false });
  $('.card').liveDraggable({
    containment: 'window',
//    stack: '.card',
    start: startMovingCard,
    stop: doneMovingCard
  });
  // A slight delay will make chrome not show "loading..." all the time
  setTimeout(function () {
    start_poll_stream();
  }, 500);
});

