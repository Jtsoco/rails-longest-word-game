require 'open-uri'
class GamesController < ApplicationController

  def new
    @letters = alphabet
    @start_time = Time.now
  end

  def score
    @answer = params[:answer]
    @final_time = Time.now
    @total_time = (@final_time - params[:time].to_datetime).round(2)
    @letters = JSON.parse(params[:letters])
    @grid_failed = word_check_grid_failed(@answer, @letters)
    @english_failed = english_check(@answer)
    @score = final_score(@answer, @total_time)
    @message = message(@english_failed, @grid_failed, @total_time, @answer)
  end

  def alphabet
    alphabet = ('A'..'Z').to_a
    arr = []
    until arr.any?(/[AEIOU]/)
      arr = []
      10.times do
        arr << alphabet.sample
      end
    end
    arr
  end

  def word_check_grid_failed(answer, letters)
    word_check_failed = false
    answer_arr = answer.upcase.chars
    letters.each { |letter| word_check_failed = true if letters.count(letter) < answer_arr.count(letter) }
    word_check_failed = true unless answer_arr.all?(/[#{letters.join}]/)
    word_check_failed
  end

  def english_check(answer)
    data = JSON.parse(URI.open("https://wagon-dictionary.herokuapp.com/#{answer}").read)
    english_check_failed = false
    english_check_failed = true if (data["found"] == false) || (data["error"] == "word not found")
    english_check_failed
  end

  def final_score(answer, time)
    score = 0
    score = answer.length * (60 - time) if time < 60
    score
  end

  def message(english, grid, time, answer)
    if grid
      { score: 0, message: "not in the grid"}
    elsif english
      { score: 0, message: "not an English word"}
    elsif time > 60
      { score: 0, message: "Took longer than a minute, zero points!"}
    else
      { score: final_score(answer, time), message: "well done"}
    end
  end
end
