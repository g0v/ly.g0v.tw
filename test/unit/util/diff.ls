require! 'assert'
require! 'LiveScript'
require! '../../../app/utils/diff'

describe 'diff', ->
  describe 'char-based-diff-to-diffline', (_it_) ->
    expect-diff = (args) ->
      assert.deepEqual diff.char-based-diff-to-diffline(args.input), args.output

    it 'handles single line modification', ->
      expect-diff do
        input: [[0, 'aaa\nb'], [-1, 'b'], [1, 'c'], [0, 'b\nddd']],
        output: [{left: 'aaa', right: 'aaa'},
                 {left: 'b<em>b</em>b', right: 'b<em>c</em>b'},
                 {left: 'ddd', right: 'ddd'}]

    it 'handles single line insertion, case 1', ->
      expect-diff do
        input: [[0, 'aaa\n'], [1, 'bbb\n'], [0, 'ccc']]
        output: [{left: 'aaa', right: 'aaa'},
                 {left: '', right: '<em>bbb</em>'},
                 {left: 'ccc', right: 'ccc'}]

    it 'handles single line insertion, case 2', ->
      expect-diff do
        input: [[0, 'aaa'], [1, '\nbbb'], [0, '\nccc']]
        output: [{left: 'aaa', right: 'aaa'},
                 {left: '', right: '<em>bbb</em>'},
                 {left: 'ccc', right: 'ccc'}]

    it 'handles single line deletion', ->
      expect-diff do
        input: [[0, 'aaa\n'], [-1, 'bbb\n'], [0, 'ccc']]
        output: [{left: 'aaa', right: 'aaa'},
                 {left: '<em>bbb</em>', right: ''},
                 {left: 'ccc', right: 'ccc'}]

    it 'handles insert line followed by mod', ->
      expect-diff do
        input: [[0, 'aaa\n'], [-1, 'x'], [1, 'bbb\nX'], [0, 'YZ\nccc']]
        output: [{left: 'aaa', right: 'aaa'},
                 {left: '', right: '<em>bbb</em>'},
                 {left: '<em>x</em>YZ', right: '<em>X</em>YZ'},
                 {left: 'ccc', right: 'ccc'}]

    it 'handles insert line following mod', ->
      expect-diff do
        input: [[0, 'aaa\nXY'], [-1, 'z'], [1, 'Z\nbbb'], [0, '\nccc']]
        output: [{left: 'aaa', right: 'aaa'},
                 {left: 'XY<em>z</em>', right: 'XY<em>Z</em>'},
                 {left: '', right: '<em>bbb</em>'},
                 {left: 'ccc', right: 'ccc'}]
