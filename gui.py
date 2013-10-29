#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import division
from __future__ import print_function
from __future__ import unicode_literals
from __future__ import absolute_import

# Standard Library imports
import sys
import os
import shlex
import subprocess

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
        scrolled_text = ScrolledText(self, variable=variable)
        scrolled_text.grid(row=row, column=column + 1, sticky="nsew")
        return scrolled_text


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
        # check for sudo existence. If it does not exist, use "su -c"
        try:
            subprocess.check_call(["which", "sudo"], stderr=subprocess.PIPE)
        except subprocess.CalledProcessError:
            command = "xterm -hold -e su -c '%s -i cli -q'" % self.command.get()
        else:
            command = "xterm -hold -e sudo %s -i cli -q" % self.command.get()

        subprocess.call(shlex.split(command))

        ## Use local lookups to improve performance
        #terminal_insert = self.terminal.insert
        #terminal_yview_scroll = self.terminal.yview_scroll
        #terminal_update_idletasks = self.terminal.update_idletasks
        #terminal_update = self.terminal.update


        ##command = "tree /home/Prog"
        #proc = subprocess.Popen(command.split(" ", 1), stdin=subprocess.PIPE, stdout=subprocess.PIPE, )
        ##except OSError:
            ##pass
        #terminal_insert("end", "$ %s \n" % command)
        #for line in iter(proc.stdout.readline, ""):
            #terminal_insert("end", line)
            #terminal_yview_scroll(1, "unit")
            ##terminal_update_idletasks()
            #terminal_update()
        #terminal_insert("end", "\n")
        #terminal_yview_scroll(1, "unit")


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
        self.archive_directory = tk.StringVar()
        self.archiver = tk.StringVar()
        self.compression = tk.StringVar()
        self.home_folder = tk.StringVar()
        self.additional_options = tk.StringVar()
        self.excluded_directories = tk.StringVar()
        self.command = tk.StringVar()

        # Trace the Tkinter Control Variables!
        # http://stackoverflow.com/a/6549535/592289
        self.archive_directory.trace("w", self.cb_gather_arguments)
        self.archiver.trace("w", self.cb_gather_arguments)
        self.compression.trace("w", self.cb_gather_arguments)
        self.home_folder.trace("w", self.cb_gather_arguments)
        self.additional_options.trace("w", self.cb_gather_arguments)
        self.excluded_directories.trace("w", self.cb_gather_arguments)

        # Set default values to the Tkinter Variables
        self.archive_directory.set(os.path.expandvars("$HOME"))
        self.archiver.set("tar")
        self.compression.set("gzip")
        self.home_folder.set(self.COMBO_CHOICES["home_folder"][0])
        self.additional_options.set("")
        self.excluded_directories.set("")

        self.create_UI()

    def create_UI(self):
        self.add_choose_directory(row=1, variable=self.archive_directory, label="Choose destination directory:")
        self.add_combobox(row=2, label="Archiver:", variable=self.archiver, values=self.COMBO_CHOICES["archiver"])
        self.add_combobox(row=3, label="Compression:", variable=self.compression, values=self.COMBO_CHOICES["compression"])
        self.add_combobox(row=4, label="Home directory:", variable=self.home_folder, values=self.COMBO_CHOICES["home_folder"])
        self.add_entry(row=5, label="Additional archiver options:", variable=self.additional_options)
        self.add_entry(row=6, label="Excluded directories:", variable=self.excluded_directories)
        self.add_entry_with_button(row=7, label="Command:", variable=self.command, bt_text="Execute", callback=self.cb_execute_command)

        self.columnconfigure(2, weight=1)

    def cb_gather_arguments(self, *args, **kwargs):
        arguments = ['%s -d "%s"' % (self.SCRIPT_NAME, self.archive_directory.get())]
        for variable in (self.archiver, self.compression, self.home_folder):
            arguments.append(self.ARGUMENTS[variable.get()])

        additional_options = self.additional_options.get().strip()
        if additional_options:
            additional_options = " ".join(option for option in additional_options.split())

        excluded_dirs = self.excluded_directories.get().strip()
        if excluded_dirs:
            excluded_dirs = " ".join("--exclude=%s" % directory for directory in excluded_dirs.split())

        if additional_options or excluded_dirs:
            sep = " " if additional_options and excluded_dirs else ""
            arguments.append('-u "%s"' % sep.join((additional_options, excluded_dirs)))

        self.command.set(" ".join(arguments))


class RestoreTab(NotebookTab):
    SCRIPT_NAME = "restore.sh"

    COMBO_CHOICES = {
        "archiver": ("tar", "bsdtar"),
        "bootloader": ("grub", "syslinux"),
    }

    ARGUMENTS = {
        "tar": "-a tar",
        "bsdtar": "-a bsdtar",
        "grub": "-g",
        "syslinux": "-S",
        "": "",
    }


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
                           "Only include /home/* 's hidden files and directories",
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
