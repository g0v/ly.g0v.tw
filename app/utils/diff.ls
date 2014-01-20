make-line = -> {text: '', associate: -1}
not-right = (target) -> target isnt \right
not-left = (target) -> target isnt \left

# Generate line-based diff of the given texts.  Diff is enclosed by <em> tag.
#
# Example:
#   Input: texts 'a\nb\nd' and 'a\nc\nd'
#   Output: [{left: 'a', right: 'a'},
#            {left: '<em>b</em>', right: '<em>c</em>'},
#            {left: 'd', right: 'd'}]
line-based-diff = (text1, text2) ->
  # 1. Generate character-based diff
  # https://code.google.com/p/google-diff-match-patch/wiki/API
  dmp = new diff_match_patch
  dmp.Diff_Timeout = 1  # sec
  dmp.Diff_EditCost = 4
  ds = dmp.diff_main text1, text2
  dmp.diff_cleanupSemantic ds

  # 2. Convert character-based diff into line-based side-by-side diff.
  difflines = char-based-diff-to-diffline ds

  # 3. Add annotation.
  for line in difflines
    if line.left == '' and line.right != ''
      line.state = \insert
    else if line.left != '' and line.right == ''
      line.state = \delete
    else if line.left != '' and line.right != ''
      line.state = if line.left == line.right then \equal else \replace
    else
      line.state = \empty

  return difflines


char-based-diff-to-diffline = (ds) ->
  left_lines = [ make-line! ]
  right_lines = [ make-line! ]
  for [target, text] in ds
    target = switch target
             | 0  => \both
             | 1  => \right
             | -1 => \left

    lines = text / '\n'
    for line, i in lines
      if line != ''
        line = "<em>#line</em>" if target isnt \both
        if target is \both
          if left_lines[*-1].associate < 0
            left_lines[*-1].associate = right_lines.length - 1
          if right_lines[*-1].associate < 0
            right_lines[*-1].associate = left_lines.length - 1

      if not-right target
        left_lines[*-1].text += line
        if i != lines.length - 1
          left_lines.push make-line!
      if not-left target
        right_lines[*-1].text += line
        if i != lines.length - 1
          right_lines.push make-line!

  convert-to-difflines = (lines, side, difflines) ->
    last = 0
    for {text, associate}, i in lines
      while last < associate
        difflines[last][side] = ''
        last++
      difflines[last] ?= {}
      difflines[last][side] = text
      last++

  # Merge left lines and right into difflines.  This is done by refering to
  # "associate" link above, but it can be buggy.
  max = left_lines.length >? right_lines.length
  difflines = [ {} for i from 1 to max ]
  convert-to-difflines right_lines, \right, difflines
  convert-to-difflines left_lines, \left, difflines

  return difflines


# Currently it exports only for unit testing.
module?.exports = {char-based-diff-to-diffline}
