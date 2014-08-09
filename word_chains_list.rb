require "set"
require "debugger"

class WordChainer
  attr_reader :dictionary, :current_words, :all_seen_words
  
  def initialize
    @dictionary = []
    dictionary_file = "dictionary.txt"
    puts "Reading words from #{dictionary_file}"
    # read dictionary into @dictionary, a set 
    File.foreach(dictionary_file) do |word|
      word.chomp!
      @dictionary << word
    end
  end 
  
  def adjacent_words(word)
    # return all words one letter different from word
    results = Set.new []
    
    # go letter by letter. 
    (0...word.length).each do |i|
      poss_word = word.dup
      ("a".."z").each do |letter|
        poss_word[i] = letter
        next if poss_word == word
        results << poss_word if @dictionary.include? poss_word
      end # / a..z
    end # i
    results.to_a
  end # /adjacent_words
  
  def run(source, target)
    @all_seen_words = {source => nil}
    
    explore_current_words(source)
  end
  
  def explore_current_words(source)
    @current_words = [source]
    @new_current_words = []
    @adjacent_word_group = []
    steps = 1
    until @current_words.empty? 
      @new_current_words = []
      @current_words.each do |word|
        # puts "current word: #{word}"
        adjacent_words(word).each do |adjacent|
          next if @all_seen_words.include?(adjacent)
          # debugger
          @all_seen_words[adjacent] = word
          @new_current_words << adjacent
          @adjacent_word_group << adjacent
          # debug - shows progress
          $stderr.print "."
        end
      end
      dump_status_list if $debug
      @current_words = @new_current_words
      steps += 1
    end
    # new return: total reachable words, step count
    if $debug
      puts "explore_current_words debug: "
      p @current_words.count
      p steps
    end
    
    return [@adjacent_word_group.count, steps]
  end # /explore_current_words
  
  def dump_status_list
    # print "Step #{@steps},
    puts "#{@new_current_words.count} new words, "
    puts "#{all_seen_words.count} words total previously: \n"
    #puts "#{@new_current_words}"
    @all_seen_words.each do |to_word, from_word|
      puts " #{to_word} <- #{from_word}"
    end 
    puts
  end
  
  def build_path(target)
    path = []
    current = target
    while true do
      # puts "#{current}"
      path << current
      current = @all_seen_words[current]
      break if current.nil?
    end
    path.reverse
  end # /build_path
  
  def exhaustive_list
    # @all_seen_words = []
    @all_seen_words = {"a" => nil}
    
    
    #print header
    puts "# count\tsteps\tword"
    
    # make a set of all the words in the dictionary
    # i thought i'd delete words as we went along, but n/m
    # iterate over the set. 
    @dictionary.each do |word|
      # skip it if word's already been seen. 
      next if @all_seen_words.include?(word)
      
      # find the set of reachable words 
        # instead of run, try explore_current_words
      word_count, steps = explore_current_words(word)
      
      # print output - TSV, baby
      puts "#{word_count}\t#{steps}\t#{word}"
    end # each word
  end
  
end

def testing
  # $debug = true
  chainer = WordChainer.new
  
  puts "Adjacent words for ruby"
  p chainer.adjacent_words("ruby")
  
  puts "adj: swam"
  p chainer.adjacent_words "swam"
  
  # puts "swam -> ruby?"
  # p chainer.run "swam", "ruby"
  
  # puts "rows -> tail?"
  # puts "vent -> beam? (slow - 4 min?)"
  # p chainer.run "vent", "beam"
  
  #p "market to toilet? (slow, 2 min?)"
  #p chainer.run "market", "toilet"
  
  # debugger
  #p chainer.build_path "toilet"
  
  puts "weather to heathen?"
  p chainer.run "weather", "heathen"
  p chainer.build_path "heathen"
  
  # p chainer.run "chunder", "plunder"
end # /testing

def all_the_words
  # $debug = true
  chainer = WordChainer.new
  chainer.exhaustive_list
end

# testing

all_the_words
