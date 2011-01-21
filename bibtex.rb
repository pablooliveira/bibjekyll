# This plugin interfaces bibtex2html (http://www.lri.fr/~filliatr/bibtex2html/) with Jekyll
# to generate an html bibliography list from bibtex entries.
# For this to work, the bibtex entries must be enclosed in a special liquid block:
# {% bibtex style.bst %}
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
    Options = "-nofooter -noheader -use-table -nokeywords -nokeys -nodoc"

    def initialize(tag_name, style, tokens)
      super
      @style = style
    end

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
      stylepath = File.join(context['site']['source'], @style)
      file = File.join(context['site']['destination'],context['page']['url'])
      dirname = File.dirname(file)

      # ensure that the destination directory exists
      FileUtils.mkdir_p(dirname)

      # enter the destination directory
      Dir.chdir(dirname) do
        basename = File.basename(file).split('.')[-2]
        outname = basename + ".html"
        bibsource = basename + "_bib.html"
        # write the content of the {% bibtex %} block to temp
        temp = basename + ".bib"
        File.open(temp, 'w') {|f| f.write(content)}

        # If a previous bibsource file exists, we backup its content.
        if File.exists?(bibsource)
          backup = IO.read(bibsource)
        else
          backup = ""
        end

        # call bibtex2html
        system("bibtex2html #{Options} -s #{stylepath} -o #{basename} #{temp}")

        # When appropriate merge the new and old bibsource files.
        if File.exists?(bibsource)
          File.open(temp, 'a') {|f| f.write(backup)}
        end

        File.delete(temp)

        # return the produced output
        IO.read(outname)
      end
    end
  end
end
Liquid::Template.register_tag('bibtex', Jekyll::BibtexBlock)
