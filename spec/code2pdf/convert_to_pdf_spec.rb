require 'spec_helper'
require 'digest/md5'
require 'pdf/inspector'

describe ConvertToPDF do
  describe '#pdf' do
    it 'creates a PDF file containing all desired source code' do
      path      = 'spec/fixtures/hello_world'
      pdf       = 'spec/fixtures/hello_world_output.pdf'
      original = 'spec/fixtures/hello_world.pdf'
      blacklist = 'spec/fixtures/hello_world/.code2pdf'

      convert_to_pdf = ConvertToPDF.new from: path, to: pdf, except: blacklist
      text_analyse = PDF::Inspector::Text.analyze(File.read("#{Dir.pwd}/#{pdf}"))
      text_analyse_original = PDF::Inspector::Text.analyze(File.read("#{Dir.pwd}/#{original}"))
      expect(text_analyse.strings).to eq(text_analyse_original.strings)
      File.delete(pdf)
    end

    it 'raises an error if required params are not present' do
      expect { ConvertToPDF.new(foo: 'bar') }.to raise_error(ArgumentError)
    end

    it 'raises an error if path does not exist' do
      path = 'spec/fixtures/isto_non_existe_quevedo'
      pdf  = 'spec/fixtures/isto_non_existe_quevedo.pdf'

      expect { ConvertToPDF.new(from: path, to: pdf) }.to raise_error(LoadError)
    end

    it 'raises an error if blacklist file is not valid' do
      path      = 'spec/fixtures/hello_world'
      pdf       = 'spec/fixtures/hello_world.pdf'
      blacklist = 'spec/fixtures/purplelist.yml'

      expect { ConvertToPDF.new from: path, to: pdf, except: blacklist }.to raise_error(LoadError)
    end
  end

  describe '#prepare_line_breaks' do
    let :pdf do
      ConvertToPDF.new from: 'spec/fixtures/hello_world', to: 'spec/fixtures/hello_world.pdf'
    end

    it 'converts strings with \n to <br> for PDF generation' do
      test_text = "test\ntest"
      expect(pdf.send(:prepare_line_breaks, test_text)).to eq('test<br>test')
    end
  end

  describe '#syntax_highlight' do
    let :pdf do
      ConvertToPDF.new from: 'spec/fixtures/hello_world', to: 'spec/fixtures/hello_world.pdf'
    end

    it 'returns file with syntax_highlight html clases' do
      path = 'spec/fixtures/hello_world/lib/hello.rb'
      output = File.read('spec/fixtures/syntax_highlight.html')
      content = pdf.send(:process_file, path)
      file = [path, content]
      expect(pdf.send(:syntax_highlight, file)).to eq(output)
    end
  end
end
