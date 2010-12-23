This plugin interfaces [bibtex2html](http://www.lri.fr/~filliatr/bibtex2html/) with Jekyll
to generate an html bibliography list from bibtex entries.
For this to work, the bibtex entries must be enclosed in a special liquid block:
{% bibtex %}
   ....
{% endbibtex %}

Setup
-----

* Install [bibtex2html](http://www.lri.fr/~filliatr/bibtex2html/). 
* Copy bibtex.rb and style.bst to your plugins/ directory. 
* Edit bibtex.rb to tweak the options that are passed to bibtex2html. 

Example
-------
You can find a short usage example inside the example/ directory
(The actual pdf files are missing, so the links will be broken).
This code is what I use (with some css minor differences) to generate
my (publication list)[www.sifflez.org/publications].

Limitations
-----------

When the option -nobibsource is NOT USED, 
bibtex2html generates two html files: the first (source.html) contains
an html bibliography list and the second (source_bib.html) contains the
original bib entries.  It also links the bibliography entries with the
bib excerpts.

If you need this feature and decide to NOT USE -nobibsource, then you can
only put one {% bibtex %} block per file. This may change in the future. 

License
-------

This plugin is realeased under the MIT License.

Contact
-------

You can reach me at Pablo de Oliveira <pablo@sifflez.org>.
