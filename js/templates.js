window.require.register("view/ys/announcement", function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow, merge) {
  attrs = attrs || jade.attrs; escape = escape || jade.escape; rethrow = rethrow || jade.rethrow; merge = merge || jade.merge;
  var buf = [];
  with (locals || {}) {
  var interp;
  var __indent = [];
  buf.push('\n<div class="push"></div><a data-toggle="collapse" data-target="#announcement" class="btn btn-navbar pull-right">+</a>\n<h2>報告事項</h2>\n<section id="announcement" class="collapse">');
  // iterate content
  ;(function(){
    if ('number' == typeof content.length) {

      for (var item = 0, $$l = content.length; item < $$l; item++) {
        var entry = content[item];

  buf.push('\n  <div');
  buf.push(attrs({ 'id':("announcement-" + (item) + "") }, {"id":true}));
  buf.push('>\n    <h3>' + escape((interp = entry.subject) == null ? '' : interp) + '</h3>\n    <div class="content">' + ((interp =  renderConversation(entry.conversation) ) == null ? '' : interp) + '</div>\n  </div>');
      }

    } else {
      var $$l = 0;
      for (var item in content) {
        $$l++;      var entry = content[item];

  buf.push('\n  <div');
  buf.push(attrs({ 'id':("announcement-" + (item) + "") }, {"id":true}));
  buf.push('>\n    <h3>' + escape((interp = entry.subject) == null ? '' : interp) + '</h3>\n    <div class="content">' + ((interp =  renderConversation(entry.conversation) ) == null ? '' : interp) + '</div>\n  </div>');
      }

    }
  }).call(this);

  buf.push('\n</section>');
  }
  return buf.join("");
  };
});
window.require.register("view/ys/conversation", function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow, merge) {
  attrs = attrs || jade.attrs; escape = escape || jade.escape; rethrow = rethrow || jade.rethrow; merge = merge || jade.merge;
  var buf = [];
  with (locals || {}) {
  var interp;
  var __indent = [];
  // iterate conversation
  ;(function(){
    if ('number' == typeof conversation.length) {

      for (var $index = 0, $$l = conversation.length; $index < $$l; $index++) {
        var entry = conversation[$index];

  buf.push('\n<div class="well">');
  if ( entry[0] == 'interp')
  {
   name = entry[1][0][0]
  buf.push('<a');
  buf.push(attrs({ 'data-toggle':('collapse'), 'data-target':('#interpellation-' + (name) + ''), "class": ('btn') + ' ' + ('pull-right') }, {"data-toggle":true,"data-target":true}));
  buf.push('>+</a>\n  <h4>' + escape((interp = name) == null ? '' : interp) + '</h4>\n  <div');
  buf.push(attrs({ 'id':("interpellation-" + (name) + ""), "class": ('interp') + ' ' + ('collapse') + ' ' + ('in') }, {"id":true}));
  buf.push('>' + ((interp = renderConversation(entry[1])) == null ? '' : interp) + '</div>');
  }
  else if ( entry[0] == 'interpdoc')
  {
   name = entry[1][0]
  buf.push('<a');
  buf.push(attrs({ 'data-toggle':('collapse'), 'data-target':('#interpellation-' + (name) + ''), "class": ('btn') + ' ' + ('pull-right') }, {"data-toggle":true,"data-target":true}));
  buf.push('>+</a>\n  <div');
  buf.push(attrs({ 'id':("interpellation-" + (name) + ""), "class": ('interp') + ' ' + ('collapse') + ' ' + ('in') }, {"id":true}));
  buf.push('>' + ((interp = renderConversation(entry[1])) == null ? '' : interp) + '</div>');
  }
  else
  {
  if ( entry[0])
  {
  buf.push('<span class="speaker label">' + escape((interp = entry[0]) == null ? '' : interp) + '</span>');
  }
  buf.push('\n  <div class="content">' + ((interp = entry[1]) == null ? '' : interp) + '</div>');
  }
  buf.push('\n</div>');
      }

    } else {
      var $$l = 0;
      for (var $index in conversation) {
        $$l++;      var entry = conversation[$index];

  buf.push('\n<div class="well">');
  if ( entry[0] == 'interp')
  {
   name = entry[1][0][0]
  buf.push('<a');
  buf.push(attrs({ 'data-toggle':('collapse'), 'data-target':('#interpellation-' + (name) + ''), "class": ('btn') + ' ' + ('pull-right') }, {"data-toggle":true,"data-target":true}));
  buf.push('>+</a>\n  <h4>' + escape((interp = name) == null ? '' : interp) + '</h4>\n  <div');
  buf.push(attrs({ 'id':("interpellation-" + (name) + ""), "class": ('interp') + ' ' + ('collapse') + ' ' + ('in') }, {"id":true}));
  buf.push('>' + ((interp = renderConversation(entry[1])) == null ? '' : interp) + '</div>');
  }
  else if ( entry[0] == 'interpdoc')
  {
   name = entry[1][0]
  buf.push('<a');
  buf.push(attrs({ 'data-toggle':('collapse'), 'data-target':('#interpellation-' + (name) + ''), "class": ('btn') + ' ' + ('pull-right') }, {"data-toggle":true,"data-target":true}));
  buf.push('>+</a>\n  <div');
  buf.push(attrs({ 'id':("interpellation-" + (name) + ""), "class": ('interp') + ' ' + ('collapse') + ' ' + ('in') }, {"id":true}));
  buf.push('>' + ((interp = renderConversation(entry[1])) == null ? '' : interp) + '</div>');
  }
  else
  {
  if ( entry[0])
  {
  buf.push('<span class="speaker label">' + escape((interp = entry[0]) == null ? '' : interp) + '</span>');
  }
  buf.push('\n  <div class="content">' + ((interp = entry[1]) == null ? '' : interp) + '</div>');
  }
  buf.push('\n</div>');
      }

    }
  }).call(this);

  }
  return buf.join("");
  };
});
window.require.register("view/ys/interpellation", function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow, merge) {
  attrs = attrs || jade.attrs; escape = escape || jade.escape; rethrow = rethrow || jade.rethrow; merge = merge || jade.merge;
  var buf = [];
  with (locals || {}) {
  var interp;
  var __indent = [];
  buf.push('\n<h2>質詢事項</h2>\n<div class="push"></div><a data-toggle="collapse" data-target="#interpellation-answers" class="btn pull-right">+</a>\n<h3>詢答</h3>\n<section id="interpellation-answers" class="collapse">');
  // iterate content.answers
  ;(function(){
    if ('number' == typeof content.answers.length) {

      for (var item = 0, $$l = content.answers.length; item < $$l; item++) {
        var entry = content.answers[item];

  buf.push('\n  <div');
  buf.push(attrs({ 'id':("interpellation-answer-" + (item) + "") }, {"id":true}));
  buf.push('>\n    <div class="content">' + ((interp =  renderConversation([entry]) ) == null ? '' : interp) + '</div>\n  </div>');
      }

    } else {
      var $$l = 0;
      for (var item in content.answers) {
        $$l++;      var entry = content.answers[item];

  buf.push('\n  <div');
  buf.push(attrs({ 'id':("interpellation-answer-" + (item) + "") }, {"id":true}));
  buf.push('>\n    <div class="content">' + ((interp =  renderConversation([entry]) ) == null ? '' : interp) + '</div>\n  </div>');
      }

    }
  }).call(this);

  buf.push('\n</section>\n<div class="push"></div><a data-toggle="collapse" data-target="#interpellation-questions" class="btn pull-right">+</a>\n<h3>質詢</h3>\n<section id="interpellation-questions" class="collapse">');
  // iterate content.questions
  ;(function(){
    if ('number' == typeof content.questions.length) {

      for (var item = 0, $$l = content.questions.length; item < $$l; item++) {
        var entry = content.questions[item];

  buf.push('\n  <div');
  buf.push(attrs({ 'id':("interpellation-question-" + (item) + "") }, {"id":true}));
  buf.push('>\n    <div class="content">' + ((interp =  renderConversation([entry]) ) == null ? '' : interp) + '</div>\n  </div>');
      }

    } else {
      var $$l = 0;
      for (var item in content.questions) {
        $$l++;      var entry = content.questions[item];

  buf.push('\n  <div');
  buf.push(attrs({ 'id':("interpellation-question-" + (item) + "") }, {"id":true}));
  buf.push('>\n    <div class="content">' + ((interp =  renderConversation([entry]) ) == null ? '' : interp) + '</div>\n  </div>');
      }

    }
  }).call(this);

  buf.push('\n</section>\n<div class="push"></div><a data-toggle="collapse" data-target="#interpellation" class="btn pull-right">+</a>\n<h3>質詢</h3>\n<section id="interpellation" class="collapse in">' + ((interp =  renderConversation(content.interpellation) ) == null ? '' : interp) + '</section>');
  }
  return buf.join("");
  };
});
window.require.register("view/ys/meta", function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow, merge) {
  attrs = attrs || jade.attrs; escape = escape || jade.escape; rethrow = rethrow || jade.rethrow; merge = merge || jade.merge;
  var buf = [];
  with (locals || {}) {
  var interp;
  var __indent = [];
  buf.push('\n<div class="meta">\n  <h1>立法院第 ' + escape((interp = ad) == null ? '' : interp) + ' 屆第 ' + escape((interp = session) == null ? '' : interp) + ' 會期 第 ' + escape((interp = sitting) == null ? '' : interp) + ' 次</h1>\n</div>');
  }
  return buf.join("");
  };
});
