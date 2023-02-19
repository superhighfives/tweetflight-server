require 'ostruct'

class Lyrics

  def self.all
    [
      {id: 1, line: 'It was dark', time: 1},
      {id: 2, line: 'In the car park', time: 2},
      {id: 3, line: 'I heard a lark ascending', time: 3},
      {id: 4, line: 'And you laughed', time: 4},

      {id: 5, line: "And in my bones", time: 5},
      {id: 6, line: "I guess I've always known", time: 6},
      {id: 7, line: "There was a spark exploding", time: 7},
      {id: 8, line: "In the dry bark", time: 8},

      {id: 10, line: "you look sick", time: 9.5},
      {id: 12, line: "We are everything", time: 10.5},

      {id: 13, line: "And all my clothes", time: 14.5},
      {id: 14, line: "Well baby they were thrown", time: 15.5},
      {id: 15, line: "Into the sea", time: 16.5},
      {id: 16, line: "God I felt it when you left me", time: 17.5},

      {id: 17, line: "It hit me hard", time: 18.5},
      {id: 18, line: "In the car park", time: 19.5},
      {id: 19, line: "Cause I was always looking", time: 20.5},
      {id: 20, line: "For a spark", time: 21.5},

      {id: 21, line: "we can't lose", time: 23},
      {id: 23, line: "we never won", time: 24},

      {id: 25, line: "I'm going to make it anyway", time: 27},
      {id: 27, line: "I'm going to fake it baby", time: 29},

      {id: 29, line: "I feel it now", time: 32.5},
      {id: 30, line: "I feel it now", time: 33.5},
      {id: 31, line: "I feel it now", time: 34.5},
      {id: 32, line: "I feel it now", time: 35.5},
    ].map {|l| OpenStruct.new(l)}
  end

end