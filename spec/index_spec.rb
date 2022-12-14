require 'fileutils'
require_relative '../index'

describe Index do
  subject(:index) { Index.new }

  before(:all) do
    AppLogger = Logger.new(nil)
  end

  describe '#write' do
    let(:prefix) { 'ar' }
    let(:word) { 'are' }
    let(:prefix_path) { IndexFile.prefix_path(prefix) }
    let(:word_path) { IndexFile.word_path(word) }
    let(:file_words) do
      { 123 => [word] }
    end

    before do
      IndexFile.base_path = './test_index'
      FileUtils.rm_rf(IndexFile.base_path)
      FileUtils.mkdir_p(IndexFile.prefixes_path)
      FileUtils.mkdir_p(IndexFile.words_path)
    end

    it 'writes a new prefix file if needed' do
      index.write(file_words)
      expect(File.exists?(prefix_path)).to be true
      expect(File.read(prefix_path).split).to eql [
        'are',
      ]
    end

    it 'appends to an existing prefix file if it exists' do
      File.write(prefix_path, "art\n")
      index.write(file_words)
      expect(File.exists?(prefix_path)).to be true
      expect(File.read(prefix_path).split).to eql [
        'art',
        'are',
      ]
    end

    it 'writes a new word file if needed' do
      index.write(file_words)
      expect(File.exists?(word_path)).to be true
      expect(File.read(word_path).split).to eql [
        '123',
      ]
    end

    it 'appends to an existing word file if it exists' do
      File.write(word_path, "456\n")
      index.write(file_words)
      expect(File.exists?(word_path)).to be true
      expect(File.read(word_path).split).to eql [
        '456',
        '123',
      ]
    end
  end

  describe '#search' do
    subject(:index) { Index.new }
    let(:term) { 'our' }

    it 'returns the total count of documents' do
      IndexFile.base_path = './spec/fixtures/test_index'
      result = index.search(term)
      expect(result).not_to eql []
      expect(result[0]).to include "Here is our forecast"
    end
  end
end
