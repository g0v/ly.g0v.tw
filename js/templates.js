window.require.register("view/ys/announcement", function(exports, require, module) {
  module.exports = function anonymous(locals) {
  var buf = [];
  var locals_ = (locals || {}),content = locals_.content,renderConversation = locals_.renderConversation;jade.indent = [];
  buf.push("\n<div class=\"push\"></div><a data-toggle=\"collapse\" data-target=\"#announcement\" class=\"btn btn-navbar pull-right\">+</a>\n<h2>報告事項</h2>\n<section id=\"announcement\" class=\"collapse\">");
  // iterate content
  ;(function(){
    var $$obj = content;
    if ('number' == typeof $$obj.length) {

      for (var item = 0, $$l = $$obj.length; item < $$l; item++) {
        var entry = $$obj[item];

  buf.push("\n  <div" + (jade.attrs({ 'id':("announcement-" + (item) + "") }, {"id":true})) + ">\n    <h3>" + (jade.escape((jade.interp = entry.subject) == null ? '' : jade.interp)) + "</h3>\n    <div class=\"content\">" + (((jade.interp =  renderConversation(entry.conversation) ) == null ? '' : jade.interp)) + "</div>\n  </div>");
      }

    } else {
      var $$l = 0;
      for (var item in $$obj) {
        $$l++;      var entry = $$obj[item];

  buf.push("\n  <div" + (jade.attrs({ 'id':("announcement-" + (item) + "") }, {"id":true})) + ">\n    <h3>" + (jade.escape((jade.interp = entry.subject) == null ? '' : jade.interp)) + "</h3>\n    <div class=\"content\">" + (((jade.interp =  renderConversation(entry.conversation) ) == null ? '' : jade.interp)) + "</div>\n  </div>");
      }

    }
  }).call(this);

  buf.push("\n</section>");;return buf.join("");
  };
});
window.require.register("view/ys/conversation", function(exports, require, module) {
  module.exports = function anonymous(locals) {
  var buf = [];
  var locals_ = (locals || {}),conversation = locals_.conversation,renderConversation = locals_.renderConversation;jade.indent = [];
  // iterate conversation
  ;(function(){
    var $$obj = conversation;
    if ('number' == typeof $$obj.length) {

      for (var $index = 0, $$l = $$obj.length; $index < $$l; $index++) {
        var entry = $$obj[$index];

  buf.push("\n<div class=\"well\">");
  if ( entry[0] == 'interp')
  {
  name = entry[1][0][0]
  buf.push("<a" + (jade.attrs({ 'data-toggle':('collapse'), 'data-target':('#interpellation-' + (name) + ''), "class": [('btn'),('pull-right')] }, {"data-toggle":true,"data-target":true})) + ">+</a>\n  <h4>" + (jade.escape((jade.interp = name) == null ? '' : jade.interp)) + "</h4>\n  <div" + (jade.attrs({ 'id':("interpellation-" + (name) + ""), "class": [('interp'),('collapse'),('in')] }, {"id":true})) + ">" + (((jade.interp = renderConversation(entry[1])) == null ? '' : jade.interp)) + "</div>");
  }
  else if ( entry[0] == 'interpdoc')
  {
  name = entry[1][0]
  buf.push("<a" + (jade.attrs({ 'data-toggle':('collapse'), 'data-target':('#interpellation-' + (name) + ''), "class": [('btn'),('pull-right')] }, {"data-toggle":true,"data-target":true})) + ">+</a>\n  <div" + (jade.attrs({ 'id':("interpellation-" + (name) + ""), "class": [('interp'),('collapse'),('in')] }, {"id":true})) + ">" + (((jade.interp = renderConversation(entry[1])) == null ? '' : jade.interp)) + "</div>");
  }
  else
  {
  if ( entry[0])
  {
  buf.push("<span class=\"speaker label\">" + (jade.escape((jade.interp = entry[0]) == null ? '' : jade.interp)) + "</span>");
  }
  buf.push("\n  <div class=\"content\">" + (((jade.interp = entry[1]) == null ? '' : jade.interp)) + "</div>");
  }
  buf.push("\n</div>");
      }

    } else {
      var $$l = 0;
      for (var $index in $$obj) {
        $$l++;      var entry = $$obj[$index];

  buf.push("\n<div class=\"well\">");
  if ( entry[0] == 'interp')
  {
  name = entry[1][0][0]
  buf.push("<a" + (jade.attrs({ 'data-toggle':('collapse'), 'data-target':('#interpellation-' + (name) + ''), "class": [('btn'),('pull-right')] }, {"data-toggle":true,"data-target":true})) + ">+</a>\n  <h4>" + (jade.escape((jade.interp = name) == null ? '' : jade.interp)) + "</h4>\n  <div" + (jade.attrs({ 'id':("interpellation-" + (name) + ""), "class": [('interp'),('collapse'),('in')] }, {"id":true})) + ">" + (((jade.interp = renderConversation(entry[1])) == null ? '' : jade.interp)) + "</div>");
  }
  else if ( entry[0] == 'interpdoc')
  {
  name = entry[1][0]
  buf.push("<a" + (jade.attrs({ 'data-toggle':('collapse'), 'data-target':('#interpellation-' + (name) + ''), "class": [('btn'),('pull-right')] }, {"data-toggle":true,"data-target":true})) + ">+</a>\n  <div" + (jade.attrs({ 'id':("interpellation-" + (name) + ""), "class": [('interp'),('collapse'),('in')] }, {"id":true})) + ">" + (((jade.interp = renderConversation(entry[1])) == null ? '' : jade.interp)) + "</div>");
  }
  else
  {
  if ( entry[0])
  {
  buf.push("<span class=\"speaker label\">" + (jade.escape((jade.interp = entry[0]) == null ? '' : jade.interp)) + "</span>");
  }
  buf.push("\n  <div class=\"content\">" + (((jade.interp = entry[1]) == null ? '' : jade.interp)) + "</div>");
  }
  buf.push("\n</div>");
      }

    }
  }).call(this);
  ;return buf.join("");
  };
});
window.require.register("view/ys/interpellation", function(exports, require, module) {
  module.exports = function anonymous(locals) {
  var buf = [];
  var locals_ = (locals || {}),content = locals_.content,renderConversation = locals_.renderConversation;jade.indent = [];
  buf.push("\n<h2>質詢事項</h2>\n<div class=\"push\"></div><a data-toggle=\"collapse\" data-target=\"#interpellation-answers\" class=\"btn pull-right\">+</a>\n<h3>詢答</h3>\n<section id=\"interpellation-answers\" class=\"collapse\">");
  // iterate content.answers
  ;(function(){
    var $$obj = content.answers;
    if ('number' == typeof $$obj.length) {

      for (var item = 0, $$l = $$obj.length; item < $$l; item++) {
        var entry = $$obj[item];

  buf.push("\n  <div" + (jade.attrs({ 'id':("interpellation-answer-" + (item) + "") }, {"id":true})) + ">\n    <div class=\"content\">" + (((jade.interp =  renderConversation([entry]) ) == null ? '' : jade.interp)) + "</div>\n  </div>");
      }

    } else {
      var $$l = 0;
      for (var item in $$obj) {
        $$l++;      var entry = $$obj[item];

  buf.push("\n  <div" + (jade.attrs({ 'id':("interpellation-answer-" + (item) + "") }, {"id":true})) + ">\n    <div class=\"content\">" + (((jade.interp =  renderConversation([entry]) ) == null ? '' : jade.interp)) + "</div>\n  </div>");
      }

    }
  }).call(this);

  buf.push("\n</section>\n<div class=\"push\"></div><a data-toggle=\"collapse\" data-target=\"#interpellation-questions\" class=\"btn pull-right\">+</a>\n<h3>質詢</h3>\n<section id=\"interpellation-questions\" class=\"collapse\">");
  // iterate content.questions
  ;(function(){
    var $$obj = content.questions;
    if ('number' == typeof $$obj.length) {

      for (var item = 0, $$l = $$obj.length; item < $$l; item++) {
        var entry = $$obj[item];

  buf.push("\n  <div" + (jade.attrs({ 'id':("interpellation-question-" + (item) + "") }, {"id":true})) + ">\n    <div class=\"content\">" + (((jade.interp =  renderConversation([entry]) ) == null ? '' : jade.interp)) + "</div>\n  </div>");
      }

    } else {
      var $$l = 0;
      for (var item in $$obj) {
        $$l++;      var entry = $$obj[item];

  buf.push("\n  <div" + (jade.attrs({ 'id':("interpellation-question-" + (item) + "") }, {"id":true})) + ">\n    <div class=\"content\">" + (((jade.interp =  renderConversation([entry]) ) == null ? '' : jade.interp)) + "</div>\n  </div>");
      }

    }
  }).call(this);

  buf.push("\n</section>\n<div class=\"push\"></div><a data-toggle=\"collapse\" data-target=\"#interpellation\" class=\"btn pull-right\">+</a>\n<h3>質詢</h3>\n<section id=\"interpellation\" class=\"collapse in\">" + (((jade.interp =  renderConversation(content.interpellation) ) == null ? '' : jade.interp)) + "</section>");;return buf.join("");
  };
});
window.require.register("view/ys/meta", function(exports, require, module) {
  module.exports = function anonymous(locals) {
  var buf = [];
  var locals_ = (locals || {}),ad = locals_.ad,session = locals_.session,sitting = locals_.sitting;jade.indent = [];
  buf.push("\n<div class=\"meta\">\n  <h1>立法院第 " + (jade.escape((jade.interp = ad) == null ? '' : jade.interp)) + " 屆第 " + (jade.escape((jade.interp = session) == null ? '' : jade.interp)) + " 會期 第 " + (jade.escape((jade.interp = sitting) == null ? '' : jade.interp)) + " 次</h1>\n</div>");;return buf.join("");
  };
});
