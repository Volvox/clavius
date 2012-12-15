 window.onload = function(){


    freesound.apiKey = "ec0c281cc7404d14b6f5216f96b8cd7c";
    freesound.get_pack(17,
            function(pack){
                var msg = "";
                msg += "<strong>Url:</strong> " + pack.url + "<br>";
                pack.get_sounds(function(sounds){
                        msg += "Pack sounds:";
                        //grid width and height

                        var packSize = sounds.sounds.length,
                            timing = 16,
                            bw = 40*timing,
                            bh = 40*packSize,
                        //padding around grid
                            p = 10,
                        //size of canvas
                            cw = bw + (p*2) + 1,
                            ch = bh + (p*2) + 1,
                            canvas = $('<canvas/>').attr({width: cw, height: ch}).appendTo('body'),
                            context = canvas.get(0).getContext("2d"),
                            elemLeft = canvas.offsetLeft,
                            elemTop = canvas.offsetTop,
                            cells = [],
                            cellSize = 20,
                            amountA = packSize * timing,
                            amountB = amountA/cellSize,
                            edgeAmount = Math.floor( (amountA-1) / cellSize),
                            interval = null,
                            drawX = null,
                            drawY = null,
                            e = null,
                            x = null,
                            y = null;



                        function drawBoard(){
                            canvas.fillStyle = 'rgb(150, 150, 150)';

                            for(x = 0; x < amountB; x++) {
                                context.fillRect(x * cellSize, 0, 1, amountA);
                                context.fillRect(0, x * cellSize, amountA, 1);
                            }

                            canvas.fillStyle = 'rgb(0, 0, 0)';

                            // for (var x = 0; x <= bw; x += 40) {
                            //     context.moveTo(0.5 + x + p, p);
                            //     context.lineTo(0.5 + x + p, bh + p);
                            // }

                            // for (var x = 0; x <= bh; x += 40) {
                            //     context.moveTo(p, 0.5 + x + p);
                            //     context.lineTo(bw + p, 0.5 + x + p);
                            // }

                            // context.strokeStyle = "black";
                            // context.stroke();
                        }
                        drawBoard();


                    for (var sound in sounds.sounds){

                            var btn = document.createElement('button');
                            btn.id = sound;

                            for(var r=0; r<sounds.sounds.length; ++r){
                                var row = document.createElement('div');

                                for(var c=0; c<8; ++c){
                                    document.getElementById('grid').appendChild(btn);
                                }
                            }

                            btn.onclick = function(){
                                audio = new Audio(sounds.sounds[this.id]['preview-hq-mp3']);
                                audio.play();
                            };
                        }
                 // displayMessage(msg,"msg")
                });
                    displayMessage(msg,'msg')

            }, function(){ displayError("Sound could not be retrieved.")}
        );

    };



    function displayError(text){
        document.getElementById('error').innerHTML=text;
    }

    function displayMessage(text,place){
        document.getElementById(place).innerHTML=text;
    }
