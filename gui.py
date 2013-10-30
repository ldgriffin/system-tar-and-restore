#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import division
from __future__ import print_function
from __future__ import unicode_literals
from __future__ import absolute_import

# Standard Library imports
import sys
import os
import re
import shlex
import subprocess
from collections import OrderedDict

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


def get_disks():
    get_size = lambda disk: subprocess.check_output(shlex.split("lsblk -d -n -o size %s" % disk))[:-1]

    pattern = re.compile( r"^/dev/[sh]d[a-z]\d+$|^/dev/md\d+$|^/dev/mapper/\w+-\w+$")

    potential_disks = ["/dev/" + path for path in sorted(os.listdir("/dev/"))] +\
                      ["/dev/mapper/" + path for path in sorted(os.listdir("/dev/mapper/"))]

    disks = ((disk, get_size(disk)) for disk in potential_disks if pattern.match(disk))
    return OrderedDict(disks)

#Tooltip code adopted from:
#https://github.com/python/cpython/blob/3ae6caaaa321edabe7baf9f2dbfe9b9f222ac628/Lib/idlelib/ToolTip.py

class ToolTipBase:
    def __init__(self, button, delay=750):
        self.button = button
        self.delay = delay
        self.tipwindow = None
        self.id = None
        self.x = self.y = 0
        self._id1 = self.button.bind("<Enter>", self.enter)
        self._id2 = self.button.bind("<Leave>", self.leave)
        self._id3 = self.button.bind("<ButtonPress>", self.leave)
        #self._id4 = self.button.bind("<Motion>", self.motion)

    ##----these methods handle the callbacks on "<Enter>", "<Leave>" and "<Motion>"---------------##
    ##----events on the parent widget; override them if you want to change the widget's behavior--##

    def enter(self, event=None):
        self.schedule()

    def leave(self, event=None):
        self.unschedule()
        self.hidetip()

    ##------the methods that do the work:---------------------------------------------------------##

    def schedule(self):
        self.unschedule()
        self.id = self.button.after(self.delay, self.showtip)

    def unschedule(self):
        id = self.id
        self.id = None
        if id:
            self.button.after_cancel(id)

    def showtip(self):
        if self.tipwindow:
            return
        # The tip window must be completely outside the button;
        # otherwise when the mouse enters the tip window we get
        # a leave event and it disappears, and then we get an enter
        # event and it reappears, and so on forever :-(
        x = self.button.winfo_rootx()
        y = self.button.winfo_rooty() + self.button.winfo_height() + 1
        self.tipwindow = tw = tk.Toplevel(self.button)
        tw.wm_overrideredirect(1)
        tw.wm_geometry("+%d+%d" % (x, y))
        self.showcontents()

    def showcontents(self, text="Your text here"):
        # Override this in derived class
        label = ttk.Label(self.tipwindow, text=text, justify="left",
                          background="#ffffe0", relief="solid", borderwidth=1)
        label.pack()

    def hidetip(self):
        tw = self.tipwindow
        self.tipwindow = None
        if tw:
            tw.destroy()


class ToolTip(ToolTipBase):
    def __init__(self, button, text):
        ToolTipBase.__init__(self, button)
        self.text = text
    def showcontents(self):
        ToolTipBase.showcontents(self, self.text)


class FormLayoutMixin(object):
    """ A Mixin class defining help methods for creating FormLayouts """

    def add_entry(self, row, label, variable, state=None, column=1, help=None, *args, **kwargs):
        """ This method adds a row with a `ttk.Label` and a `ttk.Entry`. """
        # create the widgets
        label = ttk.Label(self, text=label)
        entry = ttk.Entry(self, textvariable=variable, state=state)
        if help:
            tooltip = ToolTip(entry, help)
        # place the widgets
        label.grid(row=row, column=column + 0, sticky="nse")
        entry.grid(row=row, column=column + 1, sticky="nsew")

    def add_entry_with_button(self, row, label, variable, bt_text, callback, state=None, width=None, column=1, help=None, *args, **kwargs):
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
        if help:
            tooltip = ToolTip(entry, help)
        button = ttk.Button(self, text=bt_text, width=width, command=callback)

        # place the widgets
        label.grid(row=row, column=column + 0, sticky="nse")
        entry.grid(row=row, column=column + 1, sticky="nsew")
        button.grid(row=row, column=column + 2, sticky="nsew")

    def add_choose_directory(self, row, label, variable, help=None, *args, **kwargs):
        callback = lambda: variable.set(filedialog.askdirectory())
        self.add_entry_with_button(row=row, label=label, variable=variable,
                                   state="readonly", bt_text="...",
                                   callback=callback, help=help, *args, **kwargs)

    def add_open_filename(self, row, label, variable, state="readonly", multiple=False, help=None, *args, **kwargs):
        if multiple:
            callback = lambda: variable.set(filedialog.askopenfilenames())
        else:
            callback = lambda: variable.set(filedialog.askopenfilename())
        self.add_entry_with_button(row=row, label=label, variable=variable,
                                   state=state, bt_text="...",
                                   callback=callback, help=help, *args, **kwargs)

    def add_saveas_filename(self, row, label, variable, help=None, *args, **kwargs):
        callback = lambda: variable.set(filedialog.asksaveasfilename())
        self.add_entry_with_button(row=row, label=label, variable=variable,
                                   state="readonly", bt_text="...",
                                   callback=callback, help=help, *args, **kwargs)

    def add_combobox(self, row, label, variable, values, state="readonly", column=1, help=None, *args, **kwargs):
        """ This method adds a row with a `ttk.Label` and a `ttk.Combobox`. """
        # create the widgets
        label = ttk.Label(self, text=label)
        box = ttk.Combobox(self, textvariable=variable, state=state, values=values)
        if help:
            tooltip = ToolTip(box, help)
        # place the widgets
        label.grid(row=row, column=column + 0, sticky="nse")
        box.grid(row=row, column=column + 1, sticky="nsew")

    def add_scrolledtext(self, row, variable=None, column=1, help=None, *args, **kwargs):
        """ Adds a tk ScrolledText. """
        scrolled_text = ScrolledText(self, variable=variable)
        if help:
            tooltip = ToolTip(scrolled_text, help)
        scrolled_text.grid(row=row, column=column + 1, sticky="nsew")
        return scrolled_text

    def add_readonly_text(self, row, label=None, variable=None, column=1, help=None, text="", *args, **kwargs):
        """ Adds a `tk.Text` widget """
        text_widget = tk.Text(self, textvariable=variable)
        text_widget.insert("insert", text)
        text_widget.configure(state=tk.DISABLED)
        text_widget.grid(row=row, column=column + 1, sticky="nsew")


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
            command = "xterm -hold -e su -c '%s'" % self.command.get()
        else:
            command = "xterm -hold -e sudo %s" % self.command.get()

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
        "home_folder": ("Include /home/*",
                        "Only include /home/*'s hidden files and directories.",
                        "Exclude /home/*"),
    }

    ARGUMENTS = {
        "Include /home/*": "",
        "Only include /home/*'s hidden files and directories.": "-h",
        "Exclude /home/*": "-h -n",
        "gzip": "-c gzip",
        "xz": "-c xz",
        "tar": "-a tar",
        "bsdtar": "-a bsdtar",
        "": "",
    }

    DESCRIPTION = (
        "This script will make a tar backup image of this system.\n"
        "\n"
        " ==> Make sure you have enough free space.\n"
        " ==> Also make sure you have GRUB or SYSLINUX packages installed.\n"
        "\n"
        "GRUB PACKAGES:\n"
        " -> Arch: grub-bios\n"
        " -> Debian: grub-pc\n"
        " -> Fedora: grub2\n"
        "\n"
        "SYSLINUX PACKAGES:\n"
        " -> Arch: syslinux\n"
        " -> Debian: syslinux extlinux\n"
        " -> Fedora: syslinux syslinux-extlinux\n")

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
        self.add_choose_directory(row=1, variable=self.archive_directory,
                                  label="Destination directory:",
                                  help="Choose the directory where the archive is going to be saved to.")

        self.add_combobox(row=2, label="Archiver:", variable=self.archiver,
                          values=self.COMBO_CHOICES["archiver"],
                          help="Choose the archiver program.")

        self.add_combobox(row=3, label="Compression:", variable=self.compression,
                          values=self.COMBO_CHOICES["compression"],
                          help="Choose the type of compression.")

        self.add_combobox(row=4, label="Home directory:", variable=self.home_folder,
                          values=self.COMBO_CHOICES["home_folder"],
                          help="Choose what you want to do with the /home/* directory.")

        self.add_entry(row=5, label="Additional options:",
                       variable=self.additional_options,
                       help="Add additional options that will be passed as arguments to the archiver program.")

        self.add_entry(row=6, label="Exclude:", variable=self.excluded_directories,
                       help="Specify paths of files and directories that you want to exclude from the archive.")

        self.add_entry_with_button(row=7, label="Command:", variable=self.command,
                                   bt_text="Execute", callback=self.cb_execute_command,
                                   help="This is the command that will be executed.")

        self.add_readonly_text(row=8, text=self.DESCRIPTION)

        self.columnconfigure(2, weight=1)

    def cb_gather_arguments(self, *args, **kwargs):
        arguments = ['%s -i cli -q -d "%s"' % (self.SCRIPT_NAME, self.archive_directory.get())]
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
        "disks": [""] + ["%s: %s" % (path, size) for path, size in get_disks().items()]
    }

    DESCRIPTION = (
        "This script will restore a backup image of your system or transfer this\n"
        "system in user defined partitions.\n"
        "\n"
        "==> Make sure you have created and formatted at least one partition\n"
        "for root (/) and optionally partitions for /home and /boot.\n"
        "\n"
        "==> Make sure that target LVM volume groups are activated and target\n"
        "RAID arrays are properly assembled.\n"
        "\n"
        "==> If you didn't include /home directory in the backup and you already\n"
        "have a seperate /home partition, simply enter it when prompted.\n"
        "\n"
        "==> Also make sure that this system and the system you want to restore\n"
        "have the same architecture.\n"
        "\n"
        "==> In case of GNU tar, Fedora backups can only be restored from a Fedora\n"
        "enviroment, due to extra tar options.\n")


    def __init__(self, parent):
        # In Python 2 we can't use super() because the Tkinter objects derive
        # from old-style classes. In Python 3 using "ttk.Frame.__init__()"
        # seems to work ok, but better be safe than sorry :P
        if PY_VERSION < 3:
            NotebookTab.__init__(self, parent)
        else:
            super(RestoreTab, self).__init__(parent)
        self.parent = parent

        self.archive_path = tk.StringVar()
        self.username = tk.StringVar()
        self.password = tk.StringVar()
        self.archiver = tk.StringVar()
        self.bootloader = tk.StringVar()
        self.kernel_options = tk.StringVar()
        self.root = tk.StringVar()
        self.home = tk.StringVar()
        self.boot = tk.StringVar()
        self.swap = tk.StringVar()
        self.custom_partitions = tk.StringVar()
        self.mount_options = tk.StringVar()
        self.command = tk.StringVar()

        self.archive_path.trace("w", self.cb_gather_arguments)
        self.username.trace("w", self.cb_gather_arguments)
        self.password.trace("w", self.cb_gather_arguments)
        self.archiver.trace("w", self.cb_gather_arguments)
        self.bootloader.trace("w", self.cb_gather_arguments)
        self.kernel_options.trace("w", self.cb_gather_arguments)
        self.root.trace("w", self.cb_gather_arguments)
        self.home.trace("w", self.cb_gather_arguments)
        self.boot.trace("w", self.cb_gather_arguments)
        self.swap.trace("w", self.cb_gather_arguments)
        self.custom_partitions.trace("w", self.cb_gather_arguments)
        self.mount_options.trace("w", self.cb_gather_arguments)
        self.command.trace("w", self.cb_gather_arguments)

        self.archiver.set("tar")
        self.bootloader.set("grub")

        self.create_UI()

    def create_UI(self):
        self.add_open_filename(row=1, variable=self.archive_path, state="normal",
                               label="Archive URI:",
                               help="Choose the archive URI. It can be either a url or filepath.")

        self.add_entry(row=2, label="Username:", variable=self.username,
                       help="Optional. Used for authentication when the archive is on the network.")

        self.add_entry(row=3, label="Password:", variable=self.password,
                       help="Optional. Used for authentication when the archive is on the network.")

        self.add_combobox(row=4, label="Archiver:", variable=self.archiver,
                          values=self.COMBO_CHOICES["archiver"],
                          help="Choose the archiver program.")

        self.add_combobox(row=5, label="Bootloader:", variable=self.bootloader,
                          values=self.COMBO_CHOICES["bootloader"],
                          help="Choose the bootloader.")

        self.add_entry(row=6, label="Kernel options.",
                       variable=self.kernel_options,
                       help="Optional. Specify additional kernel options for SysLinux.")

        self.add_combobox(row=7, label="Root partition:", variable=self.root,
                          values=self.COMBO_CHOICES["disks"],
                          help="Choose the root partition (/).")

        self.add_combobox(row=8, label="Home partition:", variable=self.home,
                          values=self.COMBO_CHOICES["disks"],
                          help="Optional. Choose the home partition (/home/).")

        self.add_combobox(row=9, label="Boot partition:", variable=self.boot,
                          values=self.COMBO_CHOICES["disks"],
                          help="Optional. Choose the boot partition (/home/).")

        self.add_combobox(row=10, label="Swap partition:", variable=self.swap,
                          values=self.COMBO_CHOICES["disks"],
                          help="Optional. Choose the swap partition (/home/).")

        self.add_entry(row=11, label="Custom partitions:",
                       variable=self.custom_partitions,
                       help="Specify custom partitions for fstab. The syntax is 'mountpoint=device' (e.g. '/dev/sda2=/mnt/data').")

        self.add_entry(row=12, label="Mount options:",
                       variable=self.mount_options,
                       help="Specify a comma separated list of mount options for the root partition.")

        self.add_entry_with_button(row=13, label="Command:", variable=self.command,
                                   bt_text="Execute", callback=self.cb_execute_command,
                                   help="This is the command that will be executed.")

        self.add_readonly_text(row=14, text=self.DESCRIPTION)

    def cb_gather_arguments(self, *args, **kwargs):
        arguments = ['%s -i cli -q' % self.SCRIPT_NAME]

        archive_path = self.archive_path.get()
        username = self.username.get()
        password = self.password.get()
        archiver = self.archiver.get()
        bootloader = self.bootloader.get()
        kernel_options = self.kernel_options.get()
        root = self.root.get()
        home = self.home.get()
        boot = self.boot.get()
        swap = self.swap.get()
        custom_partitions = self.custom_partitions.get()
        mount_options = self.mount_options.get()

        if archive_path.startswith("http"):
            arguments.append("-u %s" % archive_path)
        else:
            arguments.append("-f %s" % archive_path)

        arguments.append("-n %s" % username if username else "")
        arguments.append("-p %s" % password if password else "")
        arguments.append("-a %s" % archiver)
        arguments.append("-g" if bootloader == "grub" else "-S")
        arguments.append("-k %s" % kernel_options if kernel_options else "")
        arguments.append("-r %s" % root.split(": ")[0] if root else "")
        arguments.append("-h %s" % home.split(": ")[0] if home else "")
        arguments.append("-b %s" % boot.split(": ")[0] if boot else "")
        arguments.append("-s %s" % swap.split(": ")[0] if swap else "")
        arguments.append("-c %s" % custom_partitions if custom_partitions else "")
        arguments.append("-m %s" % mount_options if mount_options else "")

        # remove empty arguments
        arguments = [arg.strip() for arg in arguments if arg]

        self.command.set(" ".join(arguments))


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
