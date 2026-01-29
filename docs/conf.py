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
project = 'dwi_preproc_recon'
author = 'Tolema'
release = '0.1.0'
copyright = f'2021-{datetime.now().year}, {author}'

# -- General configuration ---------------------------------------------------

# If your documentation needs a minimal Sphinx version, state it here.
needs_sphinx = '4.2.0'

# Add any Sphinx extension module names here, as strings. They can be
# extensions coming with Sphinx (named 'sphinx.ext.*') or your custom
# ones.
extensions = [
    'nbsphinx',
    'nipype.sphinxext.apidoc',
    'nipype.sphinxext.plot_workflow',
    'recommonmark',
    'sphinx.ext.autodoc',
    'sphinx.ext.coverage',
    'sphinx.ext.doctest',
    'sphinx.ext.intersphinx',
    'sphinx.ext.linkcode',
    'sphinx.ext.mathjax',
    'sphinx_markdown_tables',
    'sphinxarg.ext',  # argparse extension
    'sphinxcontrib.apidoc',
    'sphinxcontrib.bibtex',
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

# Add any paths that contain templates here, relative to this directory.
templates_path = ['_templates']

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


# # Autodoc options
# autodoc_default_options = {
#     'members': True,
#     'undoc-members': True,
#     'show-inheritance': True,
# }


# -----------------------------------------------------------------------------
# intersphinx
# -----------------------------------------------------------------------------
_python_version_str = f'{sys.version_info.major}.{sys.version_info.minor}'
_python_doc_base = f'https://docs.python.org/{_python_version_str}'
intersphinx_mapping = {
    'python': (_python_doc_base, None),
    'numpy': ('https://numpy.org/doc/stable/', None),
    'scipy': (
        'https://docs.scipy.org/doc/scipy/reference',
        (None, './_intersphinx/scipy-objects.inv'),
    ),
    'matplotlib': (
        'https://matplotlib.org/stable/',
        (None, 'https://matplotlib.org/stable/objects.inv'),
    ),
    'pandas': ('https://pandas.pydata.org/pandas-docs/stable/', None),
    'nibabel': ('https://nipy.org/nibabel/', None),
    'nilearn': ('http://nilearn.github.io/stable/', None),
    'nipype': ('https://nipype.readthedocs.io/en/latest/', None),
}
suppress_warnings = ['image.nonlocal_uri']

# -----------------------------------------------------------------------------
# sphinxcontrib-bibtex
# -----------------------------------------------------------------------------
bibtex_bibfiles = ['../qsiprep/data/boilerplate.bib']
bibtex_style = 'unsrt'
bibtex_reference_style = 'author_year'
bibtex_footbibliography_header = ''
# -----------------------------------------------------------------------------
# Custom functions
# -----------------------------------------------------------------------------
def setup(app):
    """Add extra formatting files."""
    app.add_css_file('theme_overrides.css')