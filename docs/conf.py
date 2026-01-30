# Configuration file for the Sphinx documentation builder.
#
# This file only contains a selection of the most common options. For a full
# list see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html
# -- Path setup --------------------------------------------------------------
import os
import sys
from datetime import datetime
sys.path.insert(0, os.path.abspath('../../src'))

# -- Project information -----------------------------------------------------
project = 'Multimodhal'
author = 'Tolema'
release = '0.1.0'
copyright = f'2026-{datetime.now().year}, {author}'

# -- General configuration ---------------------------------------------------

# If your documentation needs a minimal Sphinx version, state it here.
needs_sphinx = '4.2.0'

# Add any Sphinx extension module names here, as strings. They can be
# extensions coming with Sphinx (named 'sphinx.ext.*') or your custom
# ones.
extensions = [
    'sphinx.ext.autodoc',
    'sphinx.ext.coverage',
    'sphinx.ext.doctest',
    'sphinx.ext.intersphinx',
    'sphinx.ext.mathjax',
    'sphinx.ext.napoleon',
    'sphinx.ext.viewcode',
]

# Mock modules in autodoc:
autodoc_mock_imports = [
    'matplotlib',
    'nilearn',
    'numpy',
    'pandas',
    'pygraphviz',
    'seaborn',
]

# # Add any paths that contain templates here, relative to this directory.
# templates_path = ['_templates']

# The suffix(es) of source filenames.
# You can specify multiple suffixes as a list of string:
source_suffix = ['.rst', '.md']

# The name of the Pygments (syntax highlighting) style to use.
pygments_style = 'default'

exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store']

# The theme to use for HTML and HTML Help pages.  See the documentation for
# a list of builtin themes.
html_theme = 'sphinx_rtd_theme'
html_static_path = ['_static']

# Output file base name for HTML help builder.
htmlhelp_basename = 'dwi_preproc_recon_doc'


# -----------------------------------------------------------------------------
# Custom functions
# -----------------------------------------------------------------------------
def setup(app):
    """Add extra formatting files."""
    app.add_css_file('theme_overrides.css')