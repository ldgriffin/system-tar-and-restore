#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import division
from __future__ import print_function
from __future__ import unicode_literals
from __future__ import absolute_import

# Standard Library imports
import sys
import functools

# cross-version compatibility
PY_VERSION = sys.version_info.major
if PY_VERSION < 3:
    import Tkinter as tk
    import ttk
    import tkFileDialog as filedialog
    from ScrolledText import ScrolledText as ScrolledText
else:
    import tkinter as tk
    from tkinter import ttk
    from tkinter import filedialog
    from tkinter.scrolledtext import ScrolledText as ScrolledText


class FormLayoutMixin(object):
    """ A Mixin class defining help methods for creating FormLayouts """

    def add_entry(self, row, label, variable, column=1):
        """ This method adds a row with a `ttk.Label` and a `ttk.Entry`. """
        # create the widgets
        label = ttk.Label(self, text=label)
        entry = ttk.Entry(self, textvariable=variable)
        # place the widgets
        label.grid(row=row, column=column + 0, sticky="nse")
        entry.grid(row=row, column=column + 1, sticky="nsew")

    def add_entry_with_button(self, row, label, variable, state, bt_text, callback, width=None, column=1):
        """
        This method adds a row with a `ttk.Label`, a `ttk.Entry` and a `ttk.Button`.

        It is probably a good idea not to use it directly but to create wrapper
        functions to simplify the passing of arguments. Alternatively, you may
        use `partial.functools`.

        :param int row: The row index in the FormLayout.
        :param str label: The text of the Label widget.
        :param variable: A "tkinter control variable" linked with the
                         `ttk.Entry` widget.
        :param str state: The state of the `ttk.Entry` widget.
        :param str bt_text: The text of the `ttk.Button`.
        :param callback: A python function binded to the `ttk.Button`.
        :param int width: The width of the `ttk.Button`. Defaults to `None`
                          which means that it is not set.
        :param int column: The column index. Normally, it shouldn't be used.
                           Just added for flexibility. Defaults to 1.
        """
        # create the widgets
        label = ttk.Label(self, text=label)
        entry = ttk.Entry(self, textvariable=variable, state=state)
        button = ttk.Button(self, text=bt_text, width=width, command=callback)

        # place the widgets
        label.grid(row=row, column=column + 0, sticky="nse")
        entry.grid(row=row, column=column + 1, sticky="nsew")
        button.grid(row=row, column=column + 2, sticky="nsew")

    def add_choose_directory(self, row, label, variable, *args, **kwargs):
        callback = lambda: variable.set(filedialog.askdirectory())
        self.add_entry_with_button(row=row, label=label, variable=variable,
                                   state="readonly", bt_text="...",
                                   callback=callback, *args, **kwargs)

    def add_open_filename(self, row, label, variable, multiple=False, *args, **kwargs):
        if multiple:
            callback = lambda: variable.set(filedialog.askopenfilenames())
        else:
            callback = lambda: variable.set(filedialog.askopenfilename())
        self.add_entry_with_button(row=row, label=label, variable=variable,
                                   state="readonly", bt_text="...",
                                   callback=callback, *args, **kwargs)

    def add_saveas_filename(self, row, label, variable, *args, **kwargs):
        callback = lambda: variable.set(filedialog.asksaveasfilename())
        self.add_entry_with_button(row=row, label=label, variable=variable,
                                   state="readonly", bt_text="...",
                                   callback=callback, *args, **kwargs)

    def add_combobox(self, row, label, variable, values, state="readonly", column=1):
        """ This method adds a row with a `ttk.Label` and a `ttk.Combobox`. """
        # create the widgets
        label = ttk.Label(self, text=label)
        box = ttk.Combobox(self, textvariable=variable, state=state, values=values)
        # place the widgets
        label.grid(row=row, column=column + 0, sticky="nse")
        box.grid(row=row, column=column + 1, sticky="nsew")


class NotebookTab(ttk.Frame, FormLayoutMixin):
    def __init__(self, parent):
        # In Python 2 we can't use super() because the Tkinter objects derive
        # from old-style classes. In Python 3 using "ttk.Frame.__init__()"
        # seems to work ok, but better be safe than sorry :P
        if PY_VERSION < 3:
            ttk.Frame.__init__(self, parent)
        else:
            super(NotebookTab, self).__init__(parent)
        self.parent = parent

        # set theming
        self.style = ttk.Style()
        self.style.theme_use("default")
        self.pack(fill="both", expand=1)


    def create_UI(self, *args, **kwargs):
        raise NotImplementedError("You must implemement in subclasses!")

    def cb_gather_arguments(self, *args, **kwargs):
        raise NotImplementedError("You must implemement in subclasses!")

    def cb_execute_command(self, *args, **kwargs):
        pass


class BackupTab(NotebookTab):
    def __init__(self, parent):
        # In Python 2 we can't use super() because the Tkinter objects derive
        # from old-style classes. In Python 3 using "ttk.Frame.__init__()"
        # seems to work ok, but better be safe than sorry :P
        if PY_VERSION < 3:
            NotebookTab.__init__(self, parent)
        else:
            super(BackupTab, self).__init__(parent)
        self.parent = parent

        # Create Tkinter Control Variables
        # NOTE: You can't initialize their values here!
        self.archive_filename = tk.StringVar()
        self.archiver = tk.StringVar()
        self.compression = tk.StringVar()
        self.home_folder = tk.StringVar()
        self.additional_options = tk.StringVar()
        self.command = tk.StringVar()

        # Trace the Tkinter Control Variables!
        # http://stackoverflow.com/a/6549535/592289
        self.archive_filename.trace("w", self.cb_gather_arguments)
        self.archiver.trace("w", self.cb_gather_arguments)
        self.compression.trace("w", self.cb_gather_arguments)
        self.home_folder.trace("w", self.cb_gather_arguments)
        self.additional_options.trace("w", self.cb_gather_arguments)

        self.create_UI()

    def create_UI(self):
        pass

class RestoreTab(NotebookTab):
    def __init__(self, parent):
        # In Python 2 we can't use super() because the Tkinter objects derive
        # from old-style classes. In Python 3 using "ttk.Frame.__init__()"
        # seems to work ok, but better be safe than sorry :P
        if PY_VERSION < 3:
            NotebookTab.__init__(self, parent)
        else:
            super(RestoreTab, self).__init__(parent)
        self.parent = parent

    def create_UI(self):
        pass


class STAR_GUI(ttk.Frame, FormLayoutMixin):
    def __init__(self, parent):
        # In Python 2 we can't use super() because the Tkinter objects derive
        # from old-style classes. In Python 3 using "ttk.Frame.__init__()"
        # seems to work ok, but better be safe than sorry :P
        if PY_VERSION < 3:
            ttk.Frame.__init__(self, parent)
        else:
            super(Backup, self).__init__(parent)
        self.parent = parent

        # set theming
        self.style = ttk.Style()
        self.style.theme_use("default")
        self.pack(fill="both", expand=1)


class Test(ttk.Frame, FormLayoutMixin):
    def __init__(self, parent):
        # In Python 2 we can't use super() because the Tkinter objects derive
        # from old-style classes. In Python 3 using "ttk.Frame.__init__()"
        # seems to work ok, but better be safe than sorry :P
        if PY_VERSION < 3:
            ttk.Frame.__init__(self, parent)
        else:
            super(Backup, self).__init__(parent)
        self.parent = parent

        # set theming
        self.style = ttk.Style()
        self.style.theme_use("default")
        self.pack(fill="both", expand=1)

        self.add_entry(1, "fdsa", tk.StringVar())
        self.add_choose_directory(2, "asdf", tk.StringVar())
        self.add_open_filename(3, "asdf", tk.StringVar())
        self.add_open_filename(4, "asdf", tk.StringVar(), multiple=True)
        self.add_saveas_filename(5, "asdf", tk.StringVar())
        self.add_combobox(6, "combo", tk.StringVar(),
                          ["Include /home/*",
                           "Only include /home/* 's hidden files and folders",
                           "Exclude /home/*"])


def main():
    root = tk.Tk()
    root.title("System Tar And Restore")
    app = BackupTab(root)
    app.update()
    root.minsize(root.winfo_width(), root.winfo_height())
    root.mainloop()


def test():
    root = tk.Tk()
    root.title("System Tar And Restore")
    app = Test(root)
    app.update()
    root.minsize(root.winfo_width(), root.winfo_height())
    root.mainloop()


if __name__ == '__main__':
    main()
