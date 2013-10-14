#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import division
from __future__ import print_function
from __future__ import unicode_literals
from __future__ import absolute_import

# Standard Library imports
import sys
import os

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

    def add_entry(self, row, label, variable, state=None, column=1):
        """ This method adds a row with a `ttk.Label` and a `ttk.Entry`. """
        # create the widgets
        label = ttk.Label(self, text=label)
        entry = ttk.Entry(self, textvariable=variable, state=state)
        # place the widgets
        label.grid(row=row, column=column + 0, sticky="nse")
        entry.grid(row=row, column=column + 1, sticky="nsew")

    def add_entry_with_button(self, row, label, variable, bt_text, callback, state=None, width=None, column=1):
        """
        This method adds a row with a `ttk.Label`, a `ttk.Entry` and a `ttk.Button`.

        It is probably a good idea not to use it directly but to create wrapper
        functions to simplify the passing of arguments. Alternatively, you may
        use `partial.functools`.

        :param int row: The row index in the FormLayout.
        :param str label: The text of the Label widget.
        :param variable: A "tkinter control variable" linked with the
                         `ttk.Entry` widget.
        :param str bt_text: The text of the `ttk.Button`.
        :param callback: A python function binded to the `ttk.Button`.
        :param str state: The state of the `ttk.Entry` widget. Defaults to `None`.
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

    def add_scrolledtext(self, row, variable=None, column=1, *args, **kwargs):
        """ Adds a tk ScrolledText. """
        self.terminal = ScrolledText(self, variable=variable)
        self.terminal.grid(row=row, column=column + 1, sticky="nsew")


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
    SCRIPT_NAME = "backup.sh"

    COMBO_CHOICES = {
        "archiver": ("tar", "bsdtar"),
        "compression": ("gzip", "xz"),
        "home_folder": ("Yes, include /home/*",
                        "Only include /home/*'s hidden files and directories.",
                        "No, exclude /home/*"),
    }

    ARGUMENTS = {
        "Yes, include /home/*": "",
        "Only include /home/*'s hidden files and directories.": "-h",
        "No, exclude /home/*": "-h -n",
        "gzip": "-c gzip",
        "xz": "-c xz",
        "tar": "-a tar",
        "bsdtar": "-a bsdtar",
        "": "",
    }

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

        # Set default values to the Tkinter Variables
        self.archive_filename.set(os.path.expandvars("$HOME"))
        self.archiver.set("tar")
        self.compression.set("gzip")
        self.home_folder.set(self.COMBO_CHOICES["home_folder"][0])
        self.additional_options.set("")

        self.create_UI()

    def create_UI(self):
        self.add_saveas_filename(row=1, variable=self.archive_filename,
                                 label="Choose archive's filename:")
        self.add_combobox(row=2, label="Archiver:", variable=self.archiver, values=self.COMBO_CHOICES["archiver"])
        self.add_combobox(row=3, label="Compression:", variable=self.compression, values=self.COMBO_CHOICES["compression"])
        self.add_combobox(row=4, label="Home directory:", variable=self.home_folder, values=self.COMBO_CHOICES["home_folder"])
        self.add_entry(row=5, label="Additional archiver options:", variable=self.additional_options)
        self.add_entry_with_button(row=6, label="Command:", variable=self.command, bt_text="Execute", callback=self.cb_execute_command)
        self.add_scrolledtext(row=7)

        self.columnconfigure(2, weight=1)
        self.rowconfigure(7, weight=1)

    def cb_gather_arguments(self, *args, **kwargs):
        arguments = [self.SCRIPT_NAME, "-d", self.archive_filename.get()]
        for variable in (self.archiver, self.compression, self.home_folder):
            arguments.append(self.ARGUMENTS[variable.get()])
        if self.additional_options.get():
            arguments.append("'%s'" % self.additional_options.get())
        self.command.set(" ".join(arguments))


class RestoreTab(NotebookTab):
    SCRIPT_NAME = "restore.sh"

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


class STAR_GUI(ttk.Frame):
    def __init__(self, parent=None):
        # In Python 2 we can't use super() because the Tkinter objects derive
        # from old-style classes. In Python 3 using "ttk.Frame.__init__()"
        # seems to work ok, but better be safe than sorry :P
        if PY_VERSION < 3:
            ttk.Frame.__init__(self, parent)
        else:
            super(STAR_GUI, self).__init__(parent)
        self.parent = parent

        # set theming
        self.style = ttk.Style()
        self.style.theme_use("default")
        self.pack(fill="both", expand=1)

        # create the notebook
        nb = ttk.Notebook(self, name='notebook')
        nb.pack(fill="both", expand="Y", padx=2, pady=3)

        # extend bindings to top level window allowing
        #   CTRL+TAB - cycles thru tabs
        #   SHIFT+CTRL+TAB - previous tab
        #   ALT+K - select tab using mnemonic (K = underlined letter)
        nb.enable_traversal()

        # Add the tabs
        nb.add(BackupTab(nb), text="Backup", underline=0)
        nb.add(RestoreTab(nb), text="Restore", underline=0)


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
    app = STAR_GUI(root)
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
