
  (function(){
   "use strict";
    var special = jQuery.event.special,

        uid1 = 'D' + (+new Date()),
        uid2 = 'D' + (+new Date() + 1),


    special.scrollstart = {
        setup: function() {

            var timer,
                handler =  function(evt) {

                    var _self = this,
                        _args = arguments;

                    if (timer) {
                        clearTimeout(timer);
                    } else {
                        evt.type = 'scrollstart';
                        jQuery.event.handle.apply(_self, _args);
                    }

                    timer = setTimeout( function(){
                        timer = null;
                    }, special.scrollstop.latency);
                };
            jQuery(this).bind('mousewheel mousedown', handler).data(uid1, handler);
        },
        teardown: function(){
            jQuery(this).unbind( 'mousewheel mousedown', jQuery(this).data(uid1) );
        }
    };

    special.scrollstop = {
        latency: 10,
        setup: function() {

            var timer,
                    handler = function(evt) {

                    var _self = this,
                        _args = arguments;

                    if (timer) {
                        clearTimeout(timer);
                    }
                    timer = setTimeout( function(){

                        timer = null;
                        evt.type = 'scrollstop';
                        jQuery.event.handle.apply(_self, _args);

                    }, special.scrollstop.latency);
                };
            jQuery(this).bind('mousewheel mousedown', handler).data(uid2, handler);
        },

        teardown: function() {
            jQuery(this).unbind( 'mousewheel mousedown', jQuery(this).data(uid2) );
        }
    };
})();


  $('html').scrollTop(0);

  var songs = [
     new Audio('http://www.mixtaperiot.com/wp/wp-content/media/E.V.A..mp3'),
     new Audio('http://fridaymixtape.net/mixtape/songs/129/10%20Far%20Fowls.mp3'),
     new Audio('http://manalogue.com/manalogue/Aphex%20Twin%20-%20We%20are%20the%20Music%20Makers.mp3'),
     new Audio('http://www.fluxblog.net/kraftwerk_europeendless.mp3')
  ];


  var currentSong=songs[0];
  var count=0;


  $(document).ready(function() {
      $(currentSong).on("loadeddata",function(){

          var pageHeight = 10 * currentSong.duration;
          $('body').css("height", pageHeight);

          currentSong.addEventListener("timeupdate", autoscroll, false);
          currentSong.play();

      });
  });

  function updateSong(direction){
    "use strict";
    currentSong.pause();

    if (direction==="+"){
      $(window).scrollTop(0);
      count++;
    }
    else if(direction==="-"){
      $(window).scrollTop($(document).height());
      count--;
    }

    currentSong = songs[count];
    currentSong.play();
  }

  currentSong.addEventListener('ended', function(e){
    "use strict";
    updateSong("+");
  });


  jQuery(window).bind('scrollstart', function(){
      "use strict";
      currentSong.pause();
      currentSong.removeEventListener('timeupdate', autoscroll, false);

      var duration = currentSong.duration;
      var scrollAmount = $(window).scrollTop();
      var documentHeight = $(document).height();
      var windowHeight = $(window).height();
      var songPercent = currentSong.currentTime / currentSong.duration;
      var scrollTotal = $(document).height() - $(window).height();
      var pixelsDown = songPercent * scrollTotal;


      // $('#msg').empty().append( "Song No. "+ (count+1) + " Duration: " + duration );
      var scrollPercent = $(window).scrollTop()*(currentSong.duration/scrollTotal);
      $("#seekbar").val(scrollPercent);

      if ($(window).scrollTop()/scrollTotal >= 1){
          updateSong("+");
      }
      else if (scrollPercent <= 0 && count > 0){
          updateSong("-");
      }

      currentSong.currentTime=scrollPercent;
      currentSong.play();
  });

  jQuery(window).bind('scrollstop', function(e){
      "use strict";
      currentSong.pause();
      console.log("stopped scrolling  "+ currentSong.currentTime);

      currentSong.addEventListener("timeupdate", autoscroll, false);
      currentSong.play();
  });


    function autoscroll(){
              // $("#time").val(currentSong.currentTime);
              //  $('#msg').empty().append($(window).scrollTop());
              var pixelsDown = ($(document).height()-$(window).height()) / currentSong.duration;
              $(window).scrollTop(currentSong.currentTime*pixelsDown);
        }