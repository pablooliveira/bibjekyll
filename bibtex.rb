# This plugin interfaces bibtex2html (http://www.lri.fr/~filliatr/bibtex2html/) with Jekyll
# to generate an html bibliography list from bibtex entries.
# For this to work, the bibtex entries must be enclosed in a special liquid block:
# {% bibtex %}
#   ....
# {% endbibtex %}

module Jekyll
  # Workaround for commit 5b680f8dd80aac1 in jekyll (remove orphaned files in destination)
  # that deletes all the files created by plugins.
  class Site
    def cleanup
    end
  end

  class BibtexBlock < Liquid::Block
    # The options that are passed to bibtex2html
    # BEWARE :
    #  * if the option -nobibsource is USED, you can put as MANY {% bibtex %}
    #    blocks as you like in the same source file.
    #  * if the option -nobibsource is NOT USED, you can only put a SINGLE
    #    {% bibtex %} block per source file.
    Options = "-nofooter -noheader -use-table -nokeywords -nokeys -nodoc"

    # The Bibtex style
    Style = "_plugins/style.bst"

    # Bibtex code may use {{ }} markups which interfere with liquid.
    # Therefore, we override parse to completely ignore the content
    # of the {% bibtex %} blocks.
    def parse(tokens)
      @nodelist ||= []
      @nodelist.clear
      while token = tokens.shift
        if token =~ IsTag and token =~ FullToken and block_delimiter == $1
            end_tag
            return
        else
          @nodelist << token
        end
      end
      assert_missing_delimitation!
    end

    def render(context)
      # get the content of the {% bibtex %} block
      content = super.join

      # get the complete paths for the style file and the source file
      stylepath = File.join(context['site']['source'], Style)
      file = File.join(context['site']['destination'],context['page']['url'])
      dirname = File.dirname(file)

      # ensure that the destination directory exists
      FileUtils.mkdir_p(dirname)

      # enter the destination directory
      Dir.chdir(dirname) do
        basename = File.basename(file).split('.')[-2]
        outname = basename + ".html"

        # write the content of the {% bibtex %} block to temp
        temp = basename + ".bib"
        File.open(temp, 'w') {|f| f.write(content)}

        # call bibtex2html
        system("bibtex2html #{Options} -s #{stylepath} -o #{basename} #{temp}")
        # XXX
        # If the option -nobibsource is NOT USED, bibtex2html will create an
        # additional file called {basename + "_bib.html"} containing the bib
        # source. When multiple {% bibtex %} blocks are used in the same source,
        # these additional files are overwritten ...

        File.delete(temp)

        # return the produced output
        IO.read(outname)
      end
    end
  end
end


Liquid::Template.register_tag('bibtex', Jekyll::BibtexBlock)
