#!/usr/bin/env python2
# pylint: disable=missing-docstring

from gnuradio import blocks
from gnuradio import gr
import osmosdr


SAMPLE_RATE = 3200000
BANDWIDTH = 1.75e6


class HackRFSink(gr.top_block):

    def __init__(self):
        gr.top_block.__init__(self, "Hackrf Dab Sink")

        self.hackrf = osmosdr.sink(args="numchan=" + str(1) + " " + "hackrf=0")
        self.hackrf.set_sample_rate(SAMPLE_RATE)
        self.hackrf.set_center_freq(218.640e6, 0)
        self.hackrf.set_freq_corr(0, 0)
        self.hackrf.set_gain(14, 0)
        self.hackrf.set_if_gain(47, 0)
        self.hackrf.set_bb_gain(14, 0)
        self.hackrf.set_antenna("", 0)
        self.hackrf.set_bandwidth(BANDWIDTH, 0)

        self.scaler = blocks.multiply_const_vcc((1, ))
        self.infile = blocks.file_source(
            gr.sizeof_gr_complex * 1,
            "/dev/stdin",
            False
        )

        self.connect((self.infile, 0), (self.scaler, 0))
        self.connect((self.scaler, 0), (self.hackrf, 0))


def main():
    transmitter = HackRFSink()
    transmitter.start()
    transmitter.wait()


if __name__ == '__main__':
    if gr.enable_realtime_scheduling() != gr.RT_OK:
        print("Error: failed to enable real-time scheduling.")
    main()
