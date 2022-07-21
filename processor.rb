require 'find'
require 'fileutils'

class Processor
  def self.process(source_dir, target_dir)
    new(source_dir, target_dir).process
  end

  def initialize(source_dir, target_dir)
    @source_dir = source_dir
    @target_dir = target_dir
    @words = []
    @buckets = {}
  end

  def process
    files = walk_directory
    files.each do |path|
      contents = IO.read(path).force_encoding('ISO-8859-1').encode('utf-8', replace: '?')
      @words.concat(contents.split.flatten)
    rescue StandardError => e
      p e
      puts path
      exit(1)
    end
    bucket_words
    write_buckets
  end

  def walk_directory
    file_names = []
    Find.find(@source_dir) do |path|
      name = File.basename(path)
      if name[0] == '.'
        Find.prune
      elsif File.file?(path)
        file_names << path
      end
    end
    file_names
  end

  def bucket_words
    @words.sort.each do |word|
      word.downcase!
      @buckets[word[0]] ||= []
      @buckets[word[0]] << word
    end
  end

  def write_buckets
    FileUtils.rm_rf(@target_dir)
    FileUtils.mkdir_p(@target_dir)
    @buckets.each do |letter, words|
      File.write(File.join(@target_dir, letter), words.join("\n"))
    end
  end
end

Processor.process('./source_data', './processed_data')