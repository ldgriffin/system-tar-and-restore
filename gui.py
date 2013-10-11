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


