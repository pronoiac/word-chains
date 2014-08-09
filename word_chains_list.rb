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
    @dict_count = @dictionary.count
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
    if $debug[1]
      $stderr.puts "\nExploring: #{source}..."
    end
    @current_words = [source]
    @new_current_words = []
    @adjacent_word_group = []
    steps = 1
    word_count = 1
    until @current_words.empty? 
      @new_current_words = []
      if $debug[2]
        $stderr.print "#{steps}: "
      end
      @current_words.each do |word|
        # puts "current word: #{word}"
        adjacent_words(word).each do |adjacent|
          next if @all_seen_words.include?(adjacent)
          # debugger
          @all_seen_words[adjacent] = word
          @new_current_words << adjacent
          word_count += 1
          # debug - shows progress
          if $debug[3]
            $stderr.print "."
          end
        end
      end
      if $debug[2]
        $stderr.puts " #{word_count}"
      end
      
      dump_status_list if $debug[0]
      @current_words = @new_current_words
      steps += 1
    end
    # new return: total reachable words, step count
    if $debug[4] # eh. 
      puts "explore_current_words debug: "
      p @current_words.count
      p steps
    end
    
    return [word_count, steps]
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
    @all_seen_words = {"asdf" => nil}
    total_word_count = 0
    
    
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
      total_word_count += word_count
      
      # print output - TSV, baby
      puts "#{word_count}\t#{steps}\t#{word}"
      if $debug[5]
        $stderr.print "Total words: #{total_word_count} of #{@dict_count} = "
        $stderr.puts "#{total_word_count.to_f / @dict_count * 100}%"
      end
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
  $debug = [false, true, true, true, false, true]
  chainer = WordChainer.new
  chainer.exhaustive_list
end

# $debug[n], n:
  # 0 - dump new words at the end of each step
  # 1 - put "exploring: " to stderr
  # 2 - print "." for each new word
  # 3 - put step # & cumulative word count 
  # 4 - ECW debug. 
  # 5 - print totals after each word, to stderr


# testing

all_the_words
