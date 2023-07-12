from tkinter import *
import matplotlib.backends.tkagg as tkagg
from matplotlib.backends.backend_agg import FigureCanvasAgg


class MatplotlibCanvas(Canvas):
    def __init__(self, parent, **kwargs):
        Canvas.__init__(self, parent, **kwargs)

        # self.fft_canvas.config(scrollregion=[0, 0, y, x])

        hbar = Scrollbar(parent, orient=HORIZONTAL)
        hbar.pack(side=BOTTOM, fill=X)

        hbar.config(command=self.xview)
        self.config(xscrollcommand=hbar.set)

        vbar = Scrollbar(self, orient=VERTICAL)
        vbar.pack(side=RIGHT, fill=Y)
        vbar.config(command=self.yview)
        self.config(yscrollcommand=vbar.set)

        self.pack(fill=BOTH, expand=YES)

    def draw_figure(self, figure, loc=(0, 0)):
        """ Draw a matplotlib figure onto a Tk canvas

        loc: location of top-left corner of figure on canvas in pixels.
        Inspired by matplotlib source: lib/matplotlib/backends/backend_tkagg.py
        """
        figure_canvas_agg = FigureCanvasAgg(figure)
        figure_canvas_agg.draw()
        figure_x, figure_y, figure_w, figure_h = figure.bbox.bounds
        figure_w, figure_h = int(figure_w), int(figure_h)
        photo = PhotoImage(master=self, width=figure_w, height=figure_h)

        # Position: convert from top-left anchor to center anchor
        self.create_image(loc[0] + figure_w / 2, loc[1] + figure_h / 2, image=photo)

        # Unfortunately, there's no accessor for the pointer to the native renderer
        tkagg.blit(photo, figure_canvas_agg.get_renderer()._renderer, colormode=2)

        # Return a handle which contains a reference to the photo object
        # which must be kept live or else the picture disappears
        self.photo  = photo


