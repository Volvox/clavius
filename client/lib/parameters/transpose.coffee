class Transpose

    # should be invoked whenever playBuffer() is called within a loop
    # to compute proper pitch/octave for all notes or keys triggered
    # pitch/octave is set as the source.playbackRate.value in playBuffer()
    pitchShift: (letters, length, i, octave) ->
        letters = letters

        # @sounds.length
        length = length

        sounditem = i
        semitone = letters.length/(length - 1 - sounditem)

        if octave?
            switch octave
              when 0 then 1
              when -1 then 0.8
              when -2 then -1.6
              when 1 then 1.6
              when 2 then 3.2

        octave = octave or 1

        # note C (key G) should be 1.0 pitch — 0.90476 yields 1.0000026405641742
        pitchRate = Math.pow(2.0, 2.0 * (semitone - (0.90476 * octave)))