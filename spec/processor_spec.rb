require_relative '../processor'
require_relative '../index_file'

describe Processor do
  subject(:processor) { Processor.new(options) }
  let(:options) { ProcessorOptions.new(path: './spec/fixtures/source_data', max_files: 1) }

  before(:all) do
    AppLogger = Logger.new(nil)
  end

  describe '#process' do
    let(:prefix) { 'ou' }
    let(:word) { 'our' }

    before do
      Index.delete_index
      Index.create_index
    end

    it 'creates an prefix index', :focus do
      processor.process

      expect(IndexFile.prefix_lines(prefix)).to eql [word]
    end

    it 'creates word index', :focus do
      processor.process
      hash = IndexFile.word_lines(word).first
      object = IndexFile.object(hash)

      expect(object).to include word
    end
  end
end