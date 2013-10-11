#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import division
from __future__ import print_function
from __future__ import unicode_literals
from __future__ import absolute_import

# Standard Library imports
import sys

# cross-version compatibility
PY_VERSION = sys.version_info.major
if PY_VERSION < 3:
    import Tkinter as tk
    import ttk
    from tkFileDialog import askdirectory as tkaskdirectory
    from ScrolledText import ScrolledText as tkScrolledText
else:
    import tkinter as tk
    from tkinter import ttk
    from tkinter.filedialog import askdirectory as tkaskdirectory
    from tkinter.scrolledtext import ScrolledText as tkScrolledText


class STAR_GUI(ttk.Frame):
    def __init__(self, parent):
        # In Python 2 we can't use super() because the Tkinter objects derive
        # from old-style classes. In Python 3 using "ttk.Frame.__init__()"
        # seems to work ok, but better be safe than sorry :P
        if PY_VERSION < 3:
            ttk.Frame.__init__(self, parent)
        else:
            super(Backup, self).__init__(parent)

        # set theming
        self.style = ttk.Style()
        self.style.theme_use("default")
        self.pack(fill="both", expand=1)


def main():
    root = tk.Tk()
    root.title("System Tar And Restore")
    app = STAR_GUI(root)
    app.update()
    root.minsize(root.winfo_width(), root.winfo_height())
    root.mainloop()


if __name__ == '__main__':
    main()
